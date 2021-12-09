#=
day9:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-09
=#

using AoC, Test


parseCaveMap(lines) = hcat([[parse(Int, c) for c in line] for line in lines]...)
@test parseCaveMap(["123","567"]) == [[1,2,3] [5,6,7]]

NEIGHBOURS=CartesianIndex.([(1,0),(-1,0),(0,-1),(0,1)])


getOrMax(A,I) = checkbounds(Bool,A,I) ? A[I] : typemax(eltype(A))
@test getOrMax([[1,2] [5,7]], CartesianIndex(1,1)) == 1
@test getOrMax([[1,2] [5,7]], CartesianIndex(2,1)) == 2
@test getOrMax([[1,2] [5,7]], CartesianIndex(1,2)) == 5
@test getOrMax([[1,2] [5,7]], CartesianIndex(2,2)) == 7
@test getOrMax([[1,2] [5,7]], CartesianIndex(0,1)) == typemax(Int)
@test getOrMax([[1,2] [5,7]], CartesianIndex(3,1)) == typemax(Int)

lowpointLocations(caveMap) = vcat(filter(CartesianIndices(caveMap)) do i
    h = caveMap[i]
    return all(getOrMax(caveMap, i+j) > h for j in NEIGHBOURS)
end...)
@test lowpointLocations(parseCaveMap(exampleLines(9,1))) == CartesianIndex.([(2,1),(10,1),(3,3),(7,5)])

lowpointHeights(caveMap) = caveMap[lowpointLocations(caveMap)]
@test lowpointHeights(parseCaveMap(exampleLines(9,1))) == [1,0,5,5]

part1(lines) = parseCaveMap(lines) |> lowpointHeights |> hh -> sum(h+1 for h in hh)
@test part1(exampleLines(9,1)) == 15

function findBasin(A, I, basin=Set())
    if I ∈ basin
        return basin
    else
        basin = union(basin, [I])
        for J in [I+n for n in NEIGHBOURS]
            if J ∉ basin && checkbounds(Bool, A, J) && A[J] < 9 && A[J] > A[I]
                basin = union(basin, findBasin(A, J, basin))
            end
        end
        return basin
    end
end

basinSize(A, I) = length(findBasin(A, I))
@test basinSize(exampleLines(9,1) |> parseCaveMap, CartesianIndex((2,1))) == 3
@test basinSize(exampleLines(9,1) |> parseCaveMap, CartesianIndex((10,1))) == 9
@test basinSize(exampleLines(9,1) |> parseCaveMap, CartesianIndex((3,3))) == 14
@test basinSize(exampleLines(9,1) |> parseCaveMap, CartesianIndex((7,5))) == 9

function part2(lines)
    caveMap = parseCaveMap(lines)
    basinSizes = [basinSize(caveMap, I) for I in lowpointLocations(caveMap)]
    return *(sort(basinSizes; lt = >)[1:3]...)
end
@test part2(exampleLines(9,1)) == 1134

lines(9) |> ll -> @time part1(ll) |> show
lines(9) |> ll -> @time part2(ll) |> show