app [main!] {
    pf: platform "../basic-cli/platform/main.roc",
}

import pf.Path exposing [Path]
import pf.Stdout
import ExerciseUtils exposing [raw_exercises!, exercise_number]

ensure_keys_match : List (U32, Path), List (U32, Path) -> Result {} [KeysDontMatch Path Path]
ensure_keys_match = |list_a, list_b|
    zipped = List.map2(list_a, list_b, Pair)
    _ = List.map_try(
        zipped,
        |Pair (num_a, path_a) (num_b, path_b)|
            if num_a != num_b || Path.display(path_a) != Path.display(path_b) then
                Err(KeysDontMatch(path_a, path_b))
            else
                Ok({}),
    )?
    Ok({})

build_imports : List (U32, Path), Str -> Str
build_imports = |entries, type|
    entries
    |> List.walk(
        "",
        |str, (num, content)| Str.concat(str, "import \"./${type}/${Path.display(content)}\" as ${type}_${Num.to_str(num)} : Str\n"),
    )

build_dict_entries : List (U32, Path), Str -> Str
build_dict_entries = |entries, type|
    entries
    |> List.walk_with_index(
        "",
        |str, (num, _), i|
            if i == 0 then
                Str.concat(str, "    Dict.insert(dict, ${Num.to_str(num)}, ${type}_${Num.to_str(num)})\n")
            else
                Str.concat(str, "    |> Dict.insert(${Num.to_str(num)}, ${type}_${Num.to_str(num)})\n"),
    )

filename = |path|
    as_str = Path.display(path)
    parts = Str.split_on(as_str, "/")
    Path.from_str(List.last(parts) ?? as_str)

exercise_entries! : Str => List (U32, Path)
exercise_entries! = |path|
    exercise_paths = raw_exercises!(Path.from_str(path))
    exercise_numbers = exercise_paths |> List.keep_oks(exercise_number)
    List.map2(exercise_numbers, exercise_paths, |a, b| (a, filename(b)))
    |> List.sort_with(
        |(k1, _), (k2, _)|
            if k1 == k2 then
                EQ
            else if k1 > k2 then
                GT
            else
                LT,
    )

main! = |_|
    Stdout.line!("Going to build exercises...")?
    exercises = exercise_entries!("./exercises")
    solved = exercise_entries!("./solved")
    ensure_keys_match(exercises, solved) ? |KeysDontMatch p1 p2| CouldNotFinish(Path.display(p1), Path.display(p2))
    exercises_imports = build_imports(exercises, "exercise")
    solved_imports = build_imports(solved, "solved")
    exercise_module_path = Path.from_str("./Exercises.roc")
    exercise_dict_entries = build_dict_entries(exercises, "exercise")
    solved_dict_entries = build_dict_entries(solved, "solved")
    Path.write_utf8!(
        """
        module [unsolved, check]

        # Exercises
        ${exercises_imports}

        #Solved
        ${solved_imports}

        ## Map of all unsolved exercises
        exercises : Dict U32 Str
        exercises =
            dict = Dict.empty({})
        ${exercise_dict_entries}

        ## Map of all solved exercises
        solved : Dict U32 Str
        solved =
            dict = Dict.empty({})
        ${solved_dict_entries}

        ## Get the text of the unsolved exercise for this number
        unsolved : U32 -> Result Str [InvalidEx]
        unsolved = |num|
            Dict.get(exercises, num)
            |> Result.map_err(|_| InvalidEx)

        ## Check if the text of the solved exercise with number `num`
        ## matches the given string
        check : U32, Str -> Result {} [Wrong, InvalidEx]
        check = |num, actual|
            expected = Dict.get(solved, num) ? |_| InvalidEx
            if expected == actual then
                Ok({})
            else
                Err(Wrong)
        """,
        exercise_module_path,
    )?

    Stdout.line!("DONE.")
