#=
day14:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-14
=#

using AoC, Test
using StructEquality # https://docs.juliahub.com/StructEquality/TwsrV/1.0.0/


struct Rule
    left::Char
    right::Char
    middle::Char
end

parseRule(line) = Rule(getindex.(match(r"^(.)(.) -> (.)", line).captures, 1)...)
@test parseRule("AB -> C") == Rule('A','B','C')

parseInput(lines) = ([c for c in lines[1]], parseRule.(lines[3:end]))
@test parseInput(["ABCD","","AB -> C", "AC -> D"]) == (['A','B','C','D'], [Rule('A','B','C'),Rule('A','C','D')])

@def_structequal mutable struct Node{T}
    value::T
    next::Union{Node{T},Nothing}
end
function Node(v::Vector{T}) where T
    node = nothing
    for c in v[end:-1:1]
        node = Node(c,node)
    end
    return node
end
@test Node(['a','b']) == Node{Char}('a',Node{Char}('b',nothing))
function insert!(node::Node{T}, e::T) where T
    e = Node(e,node.next)
    node.next = e
end
function toVector(node::Node{T}) where T
    result = T[]
    while !isnothing(node)
        push!(result, node.value)
        node = node.next
    end
    return result
end
@test toVector(Node('a',Node('b',nothing))) == ['a','b']

doStep(input::Tuple) = doStep(input...)
doStep(state::Vector{T}, rules::Vector{Rule}) where T = doStep(Node(state), rules) |> toVector
function doStep(state::Node{T}, rules::Vector{Rule}) where T
    result::Union{Nothing,Node{T}} = nothing
    left = state.value
    state = state.next

    while !isnothing(state)
        right = state.value
        result = Node(left, result)
        for rule in rules
            if left == rule.left && right == rule.right
                result = Node(rule.middle, result)
            end
        end
        left = right
    end
    result = Node(right, result)
    return result
end
@test doStep(parseInput(exampleLines(14,1))) == ['N','C','N','B','C','H','B']

doSteps(input::Tuple, n) = doSteps(input..., n)
doSteps(state::Vector{T}, rules::Vector{Rule}, n) where T = doSteps(Node(state), rules, n) |> toVector
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

function answer(lines, steps)
    state = doSteps(parseInput(lines), steps)
    counts = Dict{Char, Int}()
    for e in state
        counts[e] = get(counts,e,0) + 1
    end
    mostElementCount = argmax(pair->pair[2], counts)[2]
    leastElementCount = argmin(pair->pair[2], counts)[2]
    return mostElementCount - leastElementCount
end
part1(lines) = answer(lines, 10)
part2(lines) = answer(lines, 40)
@test part1(exampleLines(14,1)) == 1588
@test part2(exampleLines(14,1)) == 2188189693529

@show lines(14) |> ll -> @time part1(ll)
@show lines(14) |> ll -> @time part2(ll)
