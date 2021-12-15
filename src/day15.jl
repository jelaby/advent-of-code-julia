#=
day15:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-15
=#

using AoC, Test

const MOVES = [(1,0),(0,1),(-1,0),(0,-1)] .|> CartesianIndex

function findBestMove(cave)
    risks = fill(typemax(Int), size(cave))
    risks[size(cave)...] = 0

    finished = false
    while !finished
        finished = true
        for i in size(cave,1):-1:1
            for j in size(cave,2):-1:1
                I = CartesianIndex(i,j)
                risk = risks[I] + cave[I]
                for move in MOVES
                    J = I+move
                    if checkbounds(Bool, cave, J) && risks[J] > risk
                        risks[J] = risk
                        finished = false
                    end
                end
            end
        end
    end


    return risks[1,1]
end
@test findBestMove([[1,2] [3,4]]) == 6
@test findBestMove([[1,3,1] [1,1,1] [2,1,1]]) == 4


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
@test embiggen(exampleIntMap(15,1))[1:10,1:10] == exampleIntMap(15,1)
@test embiggen(exampleIntMap(15,1)) == exampleIntMap(15,2)

part1(cave) = findBestMove(cave)

part2(cave) = findBestMove(embiggen(cave))


@test part1(exampleIntMap(15,1)) == 40
@test part2(exampleIntMap(15,1)) == 315

@show exampleIntMap(15,1) |> ll -> @time part1(ll)
@show exampleIntMap(15,1) |> ll -> @time part2(ll)

@show intMap(15) |> ll -> @time part1(ll)
@show intMap(15) |> ll -> @time part2(ll)
