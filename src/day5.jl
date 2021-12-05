#=
day5:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-05
=#

using AoC, Test
using Base.Iterators: filter

parseLine(line) = split(line, r",| -> ") |> cc -> parse.(Int, cc) |> cc -> reshape(cc, 2,2)
@test parseLine("3,5 -> 6,8") == [[3, 5] [6,8]]

parseLines(lines) = cat((parseLine.(lines))...; dims=3)
@test parseLines(["3,5 -> 6,8", "4,6 -> 2,3"]) == [[3,5] [6,8] ;;; [4,6] [2,3]]

maxX(lines) = max(lines[1,:,:]...)
maxY(lines) = max(lines[2,:,:]...)
maxCoord(lines) = [maxX(lines), maxY(lines)]
@test maxCoord([[1,2] [3,4] ;;; [5,3] [1,2]]) == [5,4]

minX(lines) = min(lines[1,:,:]...)
minY(lines) = min(lines[2,:,:]...)
minCoord(lines) = [minX(lines), minY(lines)]
@test minCoord([[0,2] [3,4] ;;; [5,3] [1,2]]) == [0,2]

mapOffset(lines) = [1,1] - minCoord(lines)

mapSize(lines) = maxCoord(lines) + mapOffset(lines)

direction(line) = direction(line[:,1],line[:,2])
direction(start, finish) = sign.(finish - start)
@test direction([[1,1] [7,7]]) == [1,1]
@test direction([[1,7] [7,7]]) == [1,0]
@test direction([[7,1] [1,7]]) == [-1,1]

function createMap(lines)
    map = zeros(Int, mapSize(lines)...)
    offset = mapOffset(lines)

    for line in eachslice(lines; dims=3)
        point = line[:,1] + offset
        endPoint = line[:,2] + offset
        dir = direction(line)
        while true
            map[point...]+=1
            if point == endPoint
                break
            end
            point += dir
        end
    end

    return map
end

selectPart1(lines) = cat(filter(eachslice(lines, dims=3)) do line
    (start, finish) = (line[:,1], line[:,2])
    return start[1] == finish[1] || start[2] == finish[2]
end...; dims=3)
@test selectPart1([[2,2] [4,4] ;;; [2,2] [2,5]]) == [[2,2] [2,5] ;;;]

part1(lines) = parseLines(lines) |> selectPart1 |> createMap |> map -> count(x -> x>=2, map)
part2(lines) = parseLines(lines) |> createMap |> map -> count(x -> x>=2, map)


@test part1(exampleLines(5,1)) == 5


lines(5) |> ll -> @time part1(ll) |> show
lines(5) |> ll -> @time part2(ll) |> show
