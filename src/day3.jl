#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-03
=#
include("AoC.jl")

using Test


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