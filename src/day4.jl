#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-04
=#
using Test

lines = open(readlines, "src/day4-input.txt")
example1 = open(readlines, "src/day4-example-1.txt")

part1(lines) = count(lines) do sections
    sections = parse.(Int, split(sections, r"[,-]"))
    (sections[1] <= sections[3] && sections[2] >= sections[4]) || (sections[3] <= sections[1] && sections[4] >= sections[2])
end
@test part1(["2-4,6-8"]) == 0
@test part1(["5-7,7-9"]) == 0
@test part1(["6-6,4-6"]) == 1
@test part1(example1) == 2

part2(lines) = count(lines) do sections
    sections = parse.(Int, split(sections, r"[,-]"))
    sections[1] <= sections[3] <= sections[2] || sections[3] <= sections[1] <= sections[4]
end
@test part2(["2-4,6-8"]) == 0
@test part2(["5-7,7-9"]) == 1
@test part2(["6-6,4-6"]) == 1
@test part2(example1) == 4

show(@time part1(lines))
show(@time part2(lines))
