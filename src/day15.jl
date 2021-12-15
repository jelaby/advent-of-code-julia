#=
day15:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-15
=#

using AoC, Test

const MOVES = [(1,0),(0,1),(-1,0),(0,-1)] .|> CartesianIndex

findBestMove(cave, position::Tuple) = findBestMove(cave, CartesianIndex(position))
function findBestMove(cave, position::CartesianIndex, targetPosition::CartesianIndex = CartesianIndex(size(cave)), risks = setindex!(fill(typemax(Int), size(cave)),0, size(cave)...))
    if risks[position] != typemax(Int)
        return risks[position]
    end
    best = typemax(Int)
    for move in MOVES
        newPosition = position + move
        if checkbounds(Bool, cave, newPosition)
            result = cave[newPosition] + findBestMove(cave, newPosition, targetPosition, risks)
            if result < best
                best = result
                risks[position] = result
            end
        end
    end
    return best
end
@test findBestMove([[1,2] [3,4]], (1,1)) == 6
@test findBestMove([[1,3,1] [1,1,1] [2,1,1]], (1,1)) == 4


part1(cave) = findBestMove(cave, CartesianIndex(1,1))


@test part1(exampleIntMap(15,1)) == 40

@show exampleIntMap(15,1) |> ll -> @time part1(ll)

println("Part1...")

@show intMap(15) |> ll -> @time part1(ll)

println("Done")
