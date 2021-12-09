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

lowpointHeights(caveMap) = caveMap[vcat(filter(CartesianIndices(caveMap)) do i
    h = caveMap[i]
    return all(getOrMax(caveMap, i+j) > h for j in NEIGHBOURS)
end...)]
@test lowpointHeights(parseCaveMap(exampleLines(9,1))) == [1,0,5,5]

part1(lines) = parseCaveMap(lines) |> lowpointHeights |> hh -> sum(h+1 for h in hh)

@test part1(exampleLines(9,1)) == 15

lines(9) |> ll -> @time part1(ll) |> show