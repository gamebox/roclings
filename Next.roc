module [run!]

import pf.Stdout
import pf.Path exposing [Path]
import ExerciseUtils exposing [raw_exercises!, exercise_path]
import Exercises exposing [unsolved, check]
import Check exposing [print_check_result!]

run! : Path => Result {} _
run! = |path|
    num = Num.to_u32(raw_exercises!(path) |> List.len)
    if num > 0 then
        Stdout.line!("Checking your solutions for exercise ${Num.to_str(num)}...")?
        exercise_file_path = exercise_path(path, num)
        file_contents = Path.read_utf8!(exercise_file_path)?
        check_res = check(num, file_contents)
        print_check_result!(check_res, exercise_file_path)
        when check_res is
            Ok _ ->
                write_exercise!(num + 1, path)

            Err e ->
                Err(CheckError(e))
    else
        Stdout.line!("Setting up your first exercise...")?
        write_exercise!(1, path)

write_exercise! = |num, path|
    text = unsolved(num) ? |_| ExNotFound(num)
    exercise_file_path = exercise_path(path, num)
    Path.write_utf8!(text, exercise_file_path)?
    Stdout.line!(
        """
        Open this file in you browser and begin:

        ${Path.display(exercise_file_path)}

        When you think you have solved the exercise, just run `roclings next`.
        """,
    )

