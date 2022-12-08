#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-08
=#
using Test

lines = open(readlines, "src/day8-input.txt")
example1 = open(readlines, "src/day8-example-1.txt")


findVisible(heights) = count(CartesianIndices(heights)) do I
    I[1] == 1 || I[1] == size(heights, 1) ||
    I[2] == 1 || I[2] == size(heights, 2) ||
    heights[I] > reduce(max, heights[1:I[1]-1,I[2]]) ||
    heights[I] > reduce(max, heights[I[1]+1:end,I[2]]) ||
    heights[I] > reduce(max, heights[I[1],1:I[2]-1]) ||
    heights[I] > reduce(max, heights[I[1],I[2]+1:end])
end

part1(lines) = findVisible(reshape([parse(Int, c) for line in lines for c in line], length(lines[1]), length(lines)))

@test part1(example1) == 21

show(@time part1(lines))
#show(@time part2(lines))
