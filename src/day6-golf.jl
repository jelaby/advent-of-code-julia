#=
day6:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-06
=#

ages = zeros(BigInt, 9)
for age in open(readline, "src/day6-input.txt") |> l -> split(l, ",") |> age -> parse.(Int, age)
    ages[age + 1] += 1
end
for round in 1:256
    global ages = [ages[2:7]; ages[8] + ages[1]; ages[9]; ages[1]]
end
show(sum(ages))
