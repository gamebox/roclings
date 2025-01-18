module [run!, print_check_result!]

import pf.Path
import pf.Stdout
import ExerciseUtils exposing [raw_exercises!, exercise_path]
import Exercises exposing [check]

run! = |path|
    Stdout.line!("Checking all solutions...") ?? {}
    num = Num.to_u32(raw_exercises!(path) |> List.len)
    List.range({ start: At(0), end: At(num) })
    |> List.for_each!(
        |i|
            exercise_file_path = exercise_path(path, i)
            when Path.read_utf8!(exercise_file_path) is
                Ok file_contents ->
                    check(i, file_contents)
                    |> print_check_result!(exercise_file_path)

                Err _ -> {},
    )

print_check_result! = |res, exercise_file_path|
    when res is
        Ok _ ->
            Stdout.line!("${Path.display(exercise_file_path)}: ✅") ?? {}

        Err _ ->
            Stdout.line!("${Path.display(exercise_file_path)}: ❌") ?? {}
