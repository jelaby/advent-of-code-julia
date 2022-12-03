#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-03
=#
include("AoC.jl")

using Test
using Base.Iterators


findDuplicate(l, r) = findDuplicate(Set([c for c in l]), r)
findDuplicate(l::Set, r) = r[findfirst(item -> item ∈ l, r)]
findDuplicate(spec) = findDuplicate(SubString(spec, 1, length(spec)÷2), SubString(spec, 1+length(spec)÷2))
@test findDuplicate("abcd", "defg") == 'd'
@test findDuplicate("ABcd", "abcD") == 'c'
@test findDuplicate("ABcdabcD") == 'c'

priority(i) = 'a' <= i <= 'z' ? 1 + (i - 'a') : 27 + (i - 'A')
@test priority('a') == 1
@test priority('z') == 26
@test priority('A') == 27
@test priority('Z') == 52

findDuplicates(lines) = findDuplicate.(lines)

part1(lines) = sum(priority.(findDuplicates(lines)))

@test part1(AoC.exampleLines(3,1)) == 157

show(AoC.lines(3) |> x -> @time part1(x))


findCounts(lines::Vector{<:AbstractString}) = findCounts(flatten(lines .|> line -> Set([c for c in line])))
function findCounts(items)
    T = eltype(items)
    result = Dict{T, Int}()
    for i in items
        push!(result, i => get(result, i, 0) + 1)
    end
    return result
end
@test findCounts(["abcd", "cdef"]) == Dict('a' => 1, 'b' => 1, 'c' => 2, 'd' => 2, 'e' => 1, 'f' => 1)
@test findCounts(["abcb", "cdef"]) == Dict('a' => 1, 'b' => 1, 'c' => 2, 'd' => 1, 'e' => 1, 'f' => 1)

function findIdCards(lines)
    result = []
    for i in 1:3:length(lines)
        push!(result, findGroupIdCards(lines[i:i+2])...)
    end
    return result
end


findGroupIdCards(lines) = keys(filter(findCounts(lines)) do count
    count.second == 3
end)

@test findIdCards(AoC.exampleLines(3,1)) == ['r', 'Z']


part2(lines) = sum(priority.(findIdCards(lines)))

@test part2(AoC.exampleLines(3,1)) == 70

show(AoC.lines(3) |> x -> @time part2(x))