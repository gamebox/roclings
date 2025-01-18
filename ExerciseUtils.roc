module [raw_exercises!, exercise_numbers, exercise_number, exercise_path]

import pf.Path exposing [Path]

raw_exercises! : Path => List Path
raw_exercises! = |path|
    Path.list_dir!(path)
    ?? []

exercise_number : Path -> Result U32 [InvalidEx, InvalidNumStr]
exercise_number = |p|
    p_str = Path.display(p)
    if Str.starts_with(p_str, "exercise_") && Str.ends_with(p_str, ".roc") then
        Err(InvalidEx)
    else
        p_parts = Str.split_on(p_str, "_")
        when p_parts is
            [_, number, ..] -> Ok(Str.to_u32(number)?)
            _ -> Err(InvalidEx)

exercise_numbers : List Path -> List U32
exercise_numbers = |paths|
    paths
    |> List.keep_oks(exercise_number)

exercise_path = |path, i|
    Path.from_str("${Path.display(path)}/exercise_${padded(i)}.roc")

padded = |num|
    str = Num.to_str num
    remaining = Num.max(3 - Str.count_utf8_bytes(str), 0)
    if remaining > 0 then
        Str.concat(Str.repeat("0", remaining), str)
    else
        str
