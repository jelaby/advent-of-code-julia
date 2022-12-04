#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-03
=#
include("AoC.jl")

using Test
using Base.Iterators

charSet(s) = Set([c for c in s])

findDuplicate(l, r) = findDuplicate(charSet(l), r)
findDuplicate(l::Set, r) = first(l ∩ r)
findDuplicate(spec) = findDuplicate(SubString(spec, 1, length(spec)÷2), SubString(spec, 1+length(spec)÷2))
@test findDuplicate("abcd", "defg") == 'd'
@test findDuplicate("ABcd", "abcD") == 'c'
@test findDuplicate("ABcdabcD") == 'c'

priority(i) = 'a' <= i <= 'z' ? 1 + (i - 'a') : 27 + (i - 'A')
@test priority('a') == 1
@test priority('z') == 26
@test priority('A') == 27
@test priority('Z') == 52

part1(lines) = sum(priority.(findDuplicate.(lines)))
@test part1(AoC.exampleLines(3,1)) == 157

function findIdCards(lines)
    result = []
    for i in 1:3:length(lines)
        push!(result, findGroupIdCards(lines[i:i+2])...)
    end
    return result
end

findGroupIdCards(lines) = first(reduce(∩, charSet.(lines)))
@test findIdCards(AoC.exampleLines(3,1)) == ['r', 'Z']

part2(lines) = sum(priority.(findIdCards(lines)))
@test part2(AoC.exampleLines(3,1)) == 70

AoC.day(3, part1, part2)
