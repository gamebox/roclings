module [run!]

import pf.Stdout
import pf.Stdin
import pf.Path
import Next

run! : {} => Result {} _
run! = |_|
    Stdout.line!("Answer a few questions and then we can get started:")?
    Stdout.write!("Where would you like to put your Roclings directory (default './roclings'):")?
    user_input = Stdin.line!({})
    path =
        when user_input is
            Ok(user_path) ->
                Path.from_str(user_path)

            Err(ListWasEmpty) ->
                Path.from_str("./roclings")

            Err(e) ->
                return Err(PathProblem(e))
    Path.create_dir!(path) ? CreateDirProblem
    # TODO: Prompt the user to ensure they have proper editor support
    Next.run!(path)
