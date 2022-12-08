#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-08
=#
using Test

lines = open(readlines, "src/day8-input.txt")
example1 = open(readlines, "src/day8-example-1.txt")

heights(lines) = reshape([parse(Int, c) for line in lines for c in line], length(lines[1]), length(lines))

findVisible(heights) = count(CartesianIndices(heights)) do I
    I[1] == 1 || I[1] == size(heights, 1) ||
    I[2] == 1 || I[2] == size(heights, 2) ||
    heights[I] > reduce(max, heights[1:I[1]-1,I[2]]) ||
    heights[I] > reduce(max, heights[I[1]+1:end,I[2]]) ||
    heights[I] > reduce(max, heights[I[1],1:I[2]-1]) ||
    heights[I] > reduce(max, heights[I[1],I[2]+1:end])
end

scenicScore(heights, I, direction::Tuple) = scenicScore(heights, I, CartesianIndex(direction))
function scenicScore(heights, I, direction)
    height = heights[I]
    J = I
    score = 0
    while true
        J = J + direction
        if !checkbounds(Bool, heights, J)
            return score
        end
        score += 1
        if heights[J] >= height
            return score
        end
    end
end
@test scenicScore(heights(example1), CartesianIndex((3,2)), (1,0)) == 2
@test scenicScore(heights(example1), CartesianIndex((3,2)), (-1,0)) == 1
@test scenicScore(heights(example1), CartesianIndex((3,2)), (0,1)) == 2
@test scenicScore(heights(example1), CartesianIndex((3,2)), (0,-1)) == 1
@test scenicScore(heights(example1), CartesianIndex((3,4)), (1,0)) == 2
@test scenicScore(heights(example1), CartesianIndex((3,4)), (-1,0)) == 2
@test scenicScore(heights(example1), CartesianIndex((3,4)), (0,1)) == 1
@test scenicScore(heights(example1), CartesianIndex((3,4)), (0,-1)) == 2

findBestTree(heights) = maximum(CartesianIndices(heights)) do I
    scenicScore(heights, I, (1,0)) *
    scenicScore(heights, I, (-1,0)) *
    scenicScore(heights, I, (0,1)) *
    scenicScore(heights, I, (0,-1))
end

part1 = findVisible ∘ heights
part2 = findBestTree ∘ heights

@test part1(example1) == 21
@test part2(example1) == 8

show(@time part1(lines))
show(@time part2(lines))
