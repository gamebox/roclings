module [unsolved, check]

# Exercises
import "./exercise/exercise_001_hello_world.roc" as exercise_1 : Str


#Solved
import "./solved/exercise_001_hello_world.roc" as solved_1 : Str


## Map of all unsolved exercises
exercises : Dict U32 Str
exercises =
    dict = Dict.empty({})
    Dict.insert(dict, 1, exercise_1)


## Map of all solved exercises
solved : Dict U32 Str
solved =
    dict = Dict.empty({})
    Dict.insert(dict, 1, solved_1)


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