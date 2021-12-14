#=
day14:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-14
=#

using AoC, Test


struct Rule
    left::Char
    right::Char
    middle::Char
end

parseRule(line) = Rule(getindex.(match(r"^(.)(.) -> (.)", line).captures, 1)...)
@test parseRule("AB -> C") == Rule('A','B','C')

parseInput(lines) = ([c for c in lines[1]], parseRule.(lines[3:end]))
@test parseInput(["ABCD","","AB -> C", "AC -> D"]) == (['A','B','C','D'], [Rule('A','B','C'),Rule('A','C','D')])

doStep(input::Tuple) = doStep(input...)
function doStep(state::Vector{T}, rules::Vector{Rule}) where T
    result = T[]
    left = state[1]
    for right in state[2:end]
        push!(result, left)
        for rule in rules
            if left == rule.left && right == rule.right
                push!(result, rule.middle)
            end
        end
        left = right
    end
    push!(result,left)
    return result
end
@test doStep(parseInput(exampleLines(14,1))) == ['N','C','N','B','C','H','B']

doSteps(input::Tuple, n) = doSteps(input..., n)
function doSteps(state, rules, n)
    for i in 1:n
        state = doStep(state, rules)
    end
    return state
end
@test doSteps(parseInput(exampleLines(14,1)),1) == [c for c in "NCNBCHB"]
@test doSteps(parseInput(exampleLines(14,1)),2) == [c for c in "NBCCNBBBCBHCB"]
@test doSteps(parseInput(exampleLines(14,1)),3) == [c for c in "NBBBCNCCNBBNBNBBCHBHHBCHB"]
@test doSteps(parseInput(exampleLines(14,1)),4) == [c for c in "NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB"]

function part1(lines)
    state = doSteps(parseInput(lines), 10)
    counts = Dict{Char, Int}()
    for e in state
        counts[e] = get(counts,e,0) + 1
    end
    mostElementCount = argmax(pair->pair[2], counts)[2]
    leastElementCount = argmin(pair->pair[2], counts)[2]
    return mostElementCount - leastElementCount
end
@test part1(exampleLines(14,1)) == 1588

@show lines(14) |> ll -> @time part1(ll)
