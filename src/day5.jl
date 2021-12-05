#=
day5:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2021-12-05
=#

using AoC, Test
using Base.Iterators: flatten

parseLine(line) = tuple( (split(line, " -> ") .|> ( part -> split(part, ",") |> x -> parse.(Int, x) )) ...)
@test parseLine("3,5 -> 6,8") == ([3,5],[6,8])

parseLines(lines) = parseLine.(lines)
@test parseLines(["3,5 -> 6,8", "4,6 -> 2,3"]) == [([3,5],[6,8]),([4,6],[2,3])]

maxX(lines) = flatten(lines) .|> (cc -> cc[1]) |> xx -> max(xx...)
maxY(lines) = flatten(lines) .|> (cc -> cc[2]) |> yy -> max(yy...)
maxCoord(lines) = (maxX(lines), maxY(lines))
@test maxCoord([([1,2],[3,4]),([5,3],[1,2])]) == (5,4)

direction(line) = direction(line[1],line[2])
direction(start, finish) = sign.(finish - start)
@test direction(([1,1],[7,7])) == [1,1]
@test direction(([1,7],[7,7])) == [1,0]
@test direction(([7,1],[1,7])) == [-1,1]

function createMap(lines)
    map = zeros(Int, maxCoord(lines)...)

    for line in lines
        point = line[1]
        dir = direction(line)
        while true
            map[point...]+=1
            if point == line[2]
                break
            end
            point += dir
        end
    end

    return map
end

selectPart1(lines) = filter(lines) do line
    (start, finish) = line
    return start[1] == finish[1] || start[2] == finish[2]
end
@test selectPart1([((2,2),(4,4)), ((2,2),(2,5))]) == [((2,2),(2,5))]

part1(lines) = parseLines(lines) |> selectPart1 |> createMap |> map -> count(x -> x>=2, map)
part2(lines) = parseLines(lines) |> createMap |> map -> count(x -> x>=2, map)


@test part1(exampleLines(5,1)) == 5


lines(5) |> ll -> @time part1(ll) |> show
lines(5) |> ll -> @time part2(ll) |> show
