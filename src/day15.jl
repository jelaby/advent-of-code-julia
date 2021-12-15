#=
day15:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-15
=#

using AoC, Test

neighbourOffsets(dims) = CartesianIndex{dims}[
    [CartesianIndex(ntuple(i->i==j ? 1 : 0, dims)) for j in 1:dims];
    [CartesianIndex(ntuple(i->i==j ? -1 : 0, dims)) for j in 1:dims]
]

function findBestMove(cave)
    risks = fill(length(cave)*max(cave...), size(cave))
    risks[1] = 0

    moves = neighbourOffsets(ndims(cave))

    finished = false
    while !finished
        finished = true
        for I in CartesianIndices(cave)
            for move in moves
                J = I + move
                if checkbounds(Bool, cave, J)
                    risk = risks[I] + cave[J]
                    if risk < risks[J]
                        risks[J] = risk
                        finished = false
                    end
                end
            end
        end
    end

    return risks[end]
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
