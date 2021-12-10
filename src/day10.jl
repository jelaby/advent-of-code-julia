#=
day10:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-10
=#

using AoC, Test


SCORES = Dict(')'=>3, ']'=>57, '}'=>1197, '>'=>25137)
CLOSERS = Dict('('=>')', '['=>']', '{'=>'}', '<'=>'>')
AC_SCORES = Dict(')'=>1, ']'=>2, '}'=>3, '>'=>4)

function syntaxCheck(line)
    expectedClosers = []
    for c in line
        closer = get(CLOSERS, c, nothing)
        if isnothing(closer)
            if isempty(expectedClosers)
                return (nothing, expectedClosers)
            end
            expectedC = popfirst!(expectedClosers)
            if expectedC != c
                return (c, [])
            end
        else
            pushfirst!(expectedClosers, CLOSERS[c])
        end
    end
    return (nothing, expectedClosers)
end

incorrectChar(line) = syntaxCheck(line)[1]
@test incorrectChar("{>") == '>'
@test incorrectChar("{()>") == '>'
@test incorrectChar("{<)") == ')'
@test incorrectChar("{()}") == nothing
@test incorrectChar("{()") == nothing

part1(lines) = incorrectChar.(lines) |> cc -> sum(isnothing(c) ? 0 : SCORES[c] for c in cc)

@test part1(exampleLines(10,1)) == 26397


autocompleteChars(line) = syntaxCheck(line)[2]

function acScore(chars)
    score = 0
    for c in chars
        score *= 5
        score += AC_SCORES[c]
    end
    return score
end
@test acScore(['}','}',']',']',')','}',')',']']) == 288957

middleItem(A) = A[(length(A)+1) ÷ 2]
@test middleItem(['a','b','c']) == 'b'

function part2(lines)
    lines = filter(l->isnothing(incorrectChar(l)), lines)
    allChars = autocompleteChars.(lines)
    scores = acScore.(allChars)
    sort!(scores)
    return middleItem(scores)
end

@test part2(exampleLines(10,1)) == 288957

lines(10) |> ll -> @time part1(ll) |> show
lines(10) |> ll -> @time part2(ll) |> show
