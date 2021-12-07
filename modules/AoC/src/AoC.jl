"""
# module AdventOfCode

- Julia version: 
- Author: Paul.Mealor
- Date: 2020-12-02

# Examples

```jldoctest
julia>
```
"""
module AoC

    export lines, exampleLines
    export firstLine, firstExampleLine
    export ints, exampleInts
    export parseLine

    lines(day) = open(readlines, "src/day" * string(day) * "-input.txt")
    exampleLines(day, n) = open(readlines, "src/day" * string(day) * "-example-" * string(n) * ".txt")

    firstLine(day) = open(readline, "src/day" * string(day) * "-input.txt")
    firstExampleLine(day, n) = open(readline, "src/day" * string(day) * "-example-" * string(n) * ".txt")

    ints(day) = lines(day) |> ll -> parse.(Int, ll)
    exampleInts(day, n) = exampleLines(day, n) |> ll -> parse.(Int, ll)

    parse(::Type{T}, string::AbstractString) where T<:AbstractString = string
    parse(type, string) = Base.parse(type, string)
    parseLine(line, types...) = split(line, r"\s+"; limit=length(types)) |> tt -> parse.(types, tt)
end