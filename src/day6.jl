#=
day6:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-06
=#

using AoC, Test
using DataStructures: counter

initialAges(lines) = split(lines[1], ",") |> age -> parse.(Int, age)
@test initialAges(["4,6,3,4"]) == [4,6,3,4]

ageMap(ages) = Dict(counter(ages)...)
@test ageMap([4,6,3,4,6]) == Dict(3=>1, 4=>2, 6=>2)

function round(ages)
    result = Dict()
    for age in keys(ages)
        if age == 0
            result[6] = get(result,6,0) + ages[age]
            result[8] = get(result,8,0) + ages[age]
        else
            result[age - 1] = get(result,age - 1,0) + ages[age]
        end
    end
    return result
end
@test round(Dict(1=>1, 2=>1, 3=>2, 4=>1)) == Dict(0=>1, 1=>1, 2=>2, 3=>1)
@test round(Dict(0=>1, 1=>1, 2=>2, 3=>1)) == Dict(0=>1, 1=>2, 2=>1, 6=>1, 8=>1)

function rounds(ages, count)
    for r in 1:count
        ages = round(ages)
    end
    return ages
end
@test rounds(Dict(1=>1, 2=>1, 3=>2, 4=>1),1) == Dict(0=>1, 1=>1, 2=>2, 3=>1)
@test rounds(Dict(1=>1, 2=>1, 3=>2, 4=>1),2) == Dict(0=>1, 1=>2, 2=>1, 6=>1, 8=>1)
@test rounds(Dict(1=>1, 2=>1, 3=>2, 4=>1),3) == Dict(0=>2, 1=>1, 5=>1, 6=>1, 7=>1, 8=>1)
@test rounds(Dict(1=>1, 2=>1, 3=>2, 4=>1),18) == Dict(0=>3, 1=>5, 2=>3, 3=>2, 4=>2, 5=>1, 6=>5, 7=>1, 8=>4)

countFishes(ages) = sum(values(ages))
@test countFishes(Dict(1=>1, 2=>1, 3=>2, 4=>1)) == 5

part1(lines, count) = lines |> initialAges |> ageMap |> ages -> rounds(ages, count) |> countFishes
@test part1(exampleLines(6,1), 18) == 26
@test part1(exampleLines(6,1), 80) == 5934
@test part1(exampleLines(6,1), 256) == 26984457539

lines(6) |> ll -> @time part1(ll, 80) |> show
lines(6) |> ll -> @time part1(ll, 256) |> show
