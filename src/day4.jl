#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-04
=#
include("AoC.jl")

using Test



part1(lines) = count(split.(lines, r"[,-]")) do areas
    (areas[1] <= areas[3] && areas[2] >= areas[4]) || (areas[3] <= areas[1] && areas[4] >= areas[2])
end
@test part1(["2-4,6-8"]) == 0
@test part1(["5-7,7-9"]) == 0
@test part1(["6-6,4-6"]) == 1
@test part1(AoC.exampleLines(4,1)) == 2

AoC.day(4, part1)
