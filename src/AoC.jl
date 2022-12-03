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

    export day
    export lines, exampleLines
    export charMap
    export intMap
    export ints
    export parseLine, lineParser

    """ Parse each line of the input as an integer """
    ints(lines::Array{<:AbstractString}) = parse.(Int, lines)
    """ Produce a 2-dimensional array containing the characters of the input. The size of the first dimension is the length of the first line; the size of th second dimension is the number of lines """
    charMap(lines::Array{<:AbstractString}) = reshape([c for line in lines for c in line], length(lines[1], length[lines]))
    """ Produce a 2-dimensional array containing the numeric values of the input """
    intMap(lines::Array{<:AbstractString}) = charMap(lines) .|> c -> parse(Int, c)

    """ Open the given input file """
    file(f, day) = open(f, "src/day" * string(day) * "-input.txt")
    """ Open the given example input file """
    exampleFile(f, day, n) = open(f, "src/day" * string(day) * "-example-" * string(n) * ".txt")

    """ Read all the lines of the given input file """
    lines(day) = file(readlines, day)
    """ Read all the lines of the given example input file """
    exampleLines(day, n) = exampleFile(readlines, day, n)

    parse(::Type{T}, string::AbstractString) where T<:AbstractString = string
    parse(type, string) = Base.parse(type, string)
    """ Parse a line of text into a series of tokens separate by whitespace, then parse each token as the given type"""
    parseLine(line, types...) = split(line, r"\s+"; limit=length(types)) |> tt -> parse.(types, tt)

    """ Produce a function that calls `parseLine` """
    lineParser(types...) = line -> parseLine(line, types)

    """ Call `f` with the lines of the day, and display output and timing info """
    day(f, day) = lines(day) |> x -> show(@time f(x))
    """ Call `f1` and then `f2` with the lines of the day and display output and timing info """
    function day(day, f1, f2 = _ -> "Part 2 not ready")
        ll = lines(day)
        show(@time f1(ll))
        show(@time f2(ll))
    end
end