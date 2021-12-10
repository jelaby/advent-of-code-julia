#=
day10:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-10
=#

using AoC, Test


SCORES = Dict(')'=>3, ']'=>57, '}'=>1197, '>'=>25137)
CLOSERS = Dict('('=>')', '['=>']', '{'=>'}', '<'=>'>')

function incorrectChar(line)
    expectedClosers = []
    for c in line
        closer = get(CLOSERS, c, nothing)
        if isnothing(closer)
            if isempty(expectedClosers)
                return nothing
            end
            expectedC = pop!(expectedClosers)
            if expectedC != c
                return c
            end
        else
            push!(expectedClosers, CLOSERS[c])
        end
    end
    return nothing
end
@test incorrectChar("{>") == '>'
@test incorrectChar("{()>") == '>'
@test incorrectChar("{<)") == ')'
@test incorrectChar("{()}") == nothing
@test incorrectChar("{()") == nothing

part1(lines) = incorrectChar.(lines) |> cc -> sum(isnothing(c) ? 0 : SCORES[c] for c in cc)

@test part1(exampleLines(10,1)) == 26397

lines(10) |> ll -> @time part1(ll) |> show