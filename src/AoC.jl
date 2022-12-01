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
    export charMap, exampleCharMap
    export intMap, exampleIntMap
    export ints, exampleInts
    export parseLine

    file(f, day) = open(f, "src/day" * string(day) * "-input.txt")
    exampleFile(f, day, n) = open(f, "src/day" * string(day) * "-example-" * string(n) * ".txt")

    lines(day) = file(readlines, day)
    exampleLines(day, n) = exampleFile(readlines, day, n)

    firstLine(day) = file(readline, day)
    firstExampleLine(day, n) = exampleFile(readline, day, n)

    linesToCharMap(lines) = reshape([c for line in lines for c in line], length(lines[1]), length(lines))
    charMap(day) = lines(day) |> linesToCharMap
    exampleCharMap(day, n) = exampleLines(day, n) |> linesToCharMap

    intMap(day) = charMap(day) .|> c -> parse(Int, c)
    exampleIntMap(day, n) = exampleCharMap(day, n) .|> c -> parse(Int, c)

    ints(day) = lines(day) |> ll -> parse.(Int, ll)
    exampleInts(day, n) = exampleLines(day, n) |> ll -> parse.(Int, ll)

    parse(::Type{T}, string::AbstractString) where T<:AbstractString = string
    parse(type, string) = Base.parse(type, string)
    parseLine(line, types...) = split(line, r"\s+"; limit=length(types)) |> tt -> parse.(types, tt)
end