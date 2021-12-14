#=
day14:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-14
=#

using AoC, Test
using StructEquality # https://docs.juliahub.com/StructEquality/TwsrV/1.0.0/


@def_structequal struct Rule{T}
    target::T
    results::Vector{T}
end

function parseRule(line)
    captures = match(r"^((.)(.)) -> (.)", line).captures
    return Rule(String(captures[1]),[captures[2]*captures[4],captures[4]*captures[3]])
end
@test parseRule("AB -> C") == Rule("AB",["AC","CB"])

function toPairs(line::T) where T
    result = Dict{T,BigInt}()
    for i in 1:length(line)-1
        pair = line[i:i+1]
        result[pair] = get(result,pair,0) + 1
    end
    return result
end
@test toPairs("ABCD") == Dict("AB"=>1,"BC"=>1,"CD"=>1)

parseInput(lines) = (toPairs(lines[1]), parseRule.(lines[3:end]))
@test parseInput(["ABCD","","AB -> C", "AC -> D"]) == (Dict("AB"=>1,"BC"=>1,"CD"=>1), [Rule("AB",["AC","CB"]),Rule("AC",["AD","DC"])])


doStep(input::Tuple) = doStep(input...)
function doStep(state, rules)
    newState = copy(state)
    for rule in rules
        elementCount = get(state,rule.target,0)
        if elementCount != 0
            newState[rule.target] -= elementCount
            if newState[rule.target] == 0
                delete!(newState, rule.target)
            end
            for sequence in rule.results
                newState[sequence] = get(newState,sequence,0) + elementCount
            end
        end
    end
    return newState
end
@test doStep(parseInput(exampleLines(14,1))) == Dict("NC"=>1,"CN"=>1,"NB"=>1,"BC"=>1,"CH"=>1,"HB"=>1)

doSteps(input::Tuple, n) = doSteps(input..., n)
function doSteps(state, rules, n)
    for i in 1:n
        state = doStep(state, rules)
    end
    return state
end
@test doSteps(parseInput(exampleLines(14,1)),1) == toPairs("NCNBCHB")
@test doSteps(parseInput(exampleLines(14,1)),2) == toPairs("NBCCNBBBCBHCB")
@test doSteps(parseInput(exampleLines(14,1)),3) == toPairs("NBBBCNCCNBBNBNBBCHBHHBCHB")
@test doSteps(parseInput(exampleLines(14,1)),4) == toPairs("NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB")

function answer(lines, steps)
    lastElement = lines[1][end]
    state = doSteps(parseInput(lines), steps)
    counts = Dict{Char, BigInt}(lastElement=>1)
    for (pair,count) in state
        counts[pair[1]] = get(counts,pair[1],0)+count
    end
    mostElementCount = argmax(pair->pair[2], counts)[2]
    leastElementCount = argmin(pair->pair[2], counts)[2]
    return mostElementCount - leastElementCount
end
part1(lines) = answer(lines, 10)
part2(lines) = answer(lines, 40)
@test part1(exampleLines(14,1)) == 1588
@test part2(exampleLines(14,1)) == 2188189693529
@show "testing complete"

@show lines(14) |> ll -> @time part1(ll)
@show lines(14) |> ll -> @time part2(ll)
@show lines(14) |> ll -> @time answer(ll,400)
@show lines(14) |> ll -> @time answer(ll,4000)
