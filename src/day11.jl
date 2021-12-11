#=
day11:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-11
=#

using AoC, Test

NEIGHBOURS = setdiff([CartesianIndex(i,j) for j in -1:1 for i in -1:1], [CartesianIndex(0,0)])

function flash!(M, I)
    for J in NEIGHBOURS
        if checkbounds(Bool, M, I+J) && M[I+J] <= 9
            M[I+J] += 1
            if M[I+J] > 9
                flash!(M, I+J)
            end
        end
    end
    return M
end

@test flash!([[1,2] [3,10]], CartesianIndex(2,2)) == [[2,3] [4,10]]
@test flash!([[1,2] [8,10]], CartesianIndex(2,2)) == [[2,3] [9,10]]
@test flash!([[1,2] [9,10]], CartesianIndex(2,2)) == [[3,4] [10,10]]

function round!(M)
    for I in CartesianIndices(M)
        if M[I] <= 9
            M[I] += 1
            if M[I] > 9
                flash!(M, I)
            end
        end
    end

    flashes = 0
    for I in CartesianIndices(M)
        if M[I] > 9
            flashes += 1
            M[I] = 0
        end
    end

    return flashes
end

test1 = [[1,1,1,1,1] [1,9,9,9,1] [1,9,1,9,1] [1,9,9,9,1] [1,1,1,1,1]]
@test round!(test1) == 9
@test test1 == [[3,4,5,4,3] [4,0,0,0,4] [5,0,0,0,5] [4,0,0,0,4] [3,4,5,4,3]]

function rounds!(M, n)
    flashes = 0
    for i in 1:n
        flashes += round!(M)
    end
    return flashes
end
@test rounds!(exampleIntMap(11,1), 1) == 0
@test rounds!(exampleIntMap(11,1), 2) == 35
@test rounds!(exampleIntMap(11,1), 3) == 35+45
@test rounds!(exampleIntMap(11,1), 10) == 204

function findBrightFlash(M)
    round = 0
    while true
        round += 1
        flashes = round!(M)
        if flashes == length(M)
            return round
        end
    end
end

part1(M) = rounds!(M, 100)
@test part1(exampleIntMap(11,1)) == 1656

part2(M) = findBrightFlash(M)
@test part2(exampleIntMap(11,1)) == 195

intMap(11) |> m -> @time part1(m) |> show
intMap(11) |> m -> @time part2(m) |> show
