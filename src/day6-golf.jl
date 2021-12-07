#=
day6:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-06
=#

ages = zeros(BigInt, 9)
open(readline, "src/day6-input.txt") |> l -> split(l, ",") |> aa -> parse.(Int, aa) .|> a -> ages[a + 1] += 1
1:256 .|> _ -> global ages = [ages[2:7]; ages[8] + ages[1]; ages[9]; ages[1]]
show(sum(ages))
