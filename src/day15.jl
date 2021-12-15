#=
day15:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-15
=#

using AoC, Test

const MOVES = [(1,0),(0,1),(-1,0),(0,-1)] .|> CartesianIndex


worstCaseResult(cave, startPosition, targetPosition) = cave[targetPosition] - 9 + 9*(+(Tuple(targetPosition)...) - +(Tuple(startPosition)...))
bestCaseResult(cave, startPosition, targetPosition) = cave[targetPosition] + min(cave[targetPosition-CartesianIndex(1,0)],cave[targetPosition-CartesianIndex(0,1)]) - 2 + +(Tuple(targetPosition-startPosition)...)

findBestMove(cave, position::Tuple) = findBestMove(cave, CartesianIndex(position))
function findBestMove(cave, position::CartesianIndex, targetPosition::CartesianIndex = CartesianIndex(size(cave)), totalRisk = 0, best=worstCaseResult(cave, position, targetPosition), visited=Set{CartesianIndex}())
    push!(visited, position)
    for move in MOVES
        newPosition = position + move
        if checkbounds(Bool, cave, newPosition)
            newTotalRisk = totalRisk + cave[newPosition]
            if newPosition == targetPosition
                @show newTotalRisk, visited
                delete!(visited, position)
                return newTotalRisk
            end
            if newTotalRisk+bestCaseResult(cave, newPosition, targetPosition) < best && newPosition ∉ visited
                result = findBestMove(cave, newPosition, targetPosition, newTotalRisk, best, visited)
                if result < best
                    best = result
                end
            end
        end
    end
    delete!(visited, position)
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
