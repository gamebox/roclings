app [main!] {
    pf: platform "../basic-cli/platform/main.roc",
    weaver: "../weaver/package/main.roc",
}

import pf.Stdout
import pf.Arg
import pf.Path
import weaver.Cli
import weaver.SubCmd
import "roc.ans" as roc_logo : Str
import Check
import Next
import Init

main! = |args|
    when Cli.parse_or_display_message(arg_parser, args, Arg.to_os_raw) is
        Ok(CheckAll) ->
            Check.run!(Path.from_str("."))
            |> Ok()

        Ok(Next) ->
            path = Path.from_str(".")
            when Next.run!(path) is
                Err(ExNotFound(_)) ->
                    Stdout.line!("You have completed Roclings! Way to go!!!")

                _ -> Ok({})

        Ok(Init) ->
            Init.run!({})

        Err(weave_message) ->
            Stdout.line!(weave_message)

check_cmd = SubCmd.empty(
    {
        name: "check",
        description: "Check if all solutions are correct",
        value: CheckAll,
    },
)
next_cmd = SubCmd.empty(
    {
        name: "next",
        description: "Check if your solution to the current exercise is correct, and then start the next exercise if it is",
        value: Next,
    },
)
init_cmd = SubCmd.empty(
    {
        name: "init",
        description: "Create a directory ready for you to start your Roclings journey!",
        value: Init,
    },
)

arg_parser =
    SubCmd.required([next_cmd, check_cmd, init_cmd])
    |> Cli.finish(
        {
            name: "roclings",
            description:
            """
            A fun, fast CLI tutorial for the Roc Programming Language.
            Inspired by Ziglings and Rustlings.

            ${roc_logo}
            """,
            version: "v0.1.0-alpha",
        },
    )
    |> Cli.assert_valid()
