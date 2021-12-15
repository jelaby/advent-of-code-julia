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


function embiggen(cave)
    realCave = similar(cave, size(cave) .* 5)

    for I in CartesianIndices(cave)
        baseValue = cave[I]
        for j in I[2]:size(cave,2):size(realCave,2)
            value = baseValue
            for i in I[1]:size(cave,1):size(realCave,1)
                realCave[i,j] = value
                value = value < 9 ? value + 1 : 1
            end
            baseValue = baseValue < 9 ? baseValue + 1 : 1
        end
    end
    return realCave
end
#@test embiggen([[1];;]) == [[1,2,3,4,5] [6,7,8,9,1] [2,3,4,5,6] [6,7,8,1,2] [3,4,5,6,7]]
@test embiggen(exampleIntMap(15,1))[1:10,1:10] == exampleIntMap(15,1)
@test embiggen(exampleIntMap(15,1)) == exampleIntMap(15,2)

part1(cave) = findBestMove(cave, CartesianIndex(1,1))

part2(cave) = findBestMove(embiggen(cave), (1,1))


@test part1(exampleIntMap(15,1)) == 40
@test part2(exampleIntMap(15,1)) == 315

@show exampleIntMap(15,1) |> ll -> @time part1(ll)
@show exampleIntMap(15,1) |> ll -> @time part2(ll)

@show intMap(15) |> ll -> @time part1(ll)
@show intMap(15) |> ll -> @time part2(ll)
