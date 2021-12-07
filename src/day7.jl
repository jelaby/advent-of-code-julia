#=
day7:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-07
=#

using AoC, Test

parsePositions(line) = parse.(Int, split(line, ","))
@test parsePositions("5,34,3") == [5,34,3]

totalDistance(candidate, positions) = sum(p -> abs(candidate - p), positions)
@test totalDistance(4,[4,4]) == 0
@test totalDistance(1,[16,1,2,0,4,2,7,1,2,14]) == 41
@test totalDistance(2,[16,1,2,0,4,2,7,1,2,14]) == 37
@test totalDistance(3,[16,1,2,0,4,2,7,1,2,14]) == 39
@test totalDistance(10,[16,1,2,0,4,2,7,1,2,14]) == 71

totalDistance2(candidate, positions) = sum(p -> sum(1:abs(candidate - p)), positions)
@test totalDistance2(4,[4,4]) == 0
@test totalDistance2(5,[16,1,2,0,4,2,7,1,2,14]) == 168
@test totalDistance2(2,[16,1,2,0,4,2,7,1,2,14]) == 206

function bestPosition(positions)
    bestDistance = typemax(eltype(positions))
    result = -1
    for candidate = min(positions...):max(positions...)
        thisDistance = totalDistance(candidate, positions)
        if thisDistance < bestDistance
            bestDistance = thisDistance
            result = candidate
        end
    end
    return result
end

function bestPosition2(positions)
    bestDistance = typemax(eltype(positions))
    result = -1
    for candidate = min(positions...):max(positions...)
        thisDistance = totalDistance2(candidate, positions)
        if thisDistance < bestDistance
            bestDistance = thisDistance
            result = candidate
        end
    end
    return result
end

@test bestPosition([16,1,2,0,4,2,7,1,2,14]) == 2
@test bestPosition2([16,1,2,0,4,2,7,1,2,14]) == 5

function part1(line)
    positions = parsePositions(line)
    position = bestPosition(positions)
    return totalDistance(position, positions)
end

@test part1(firstExampleLine(7,1)) == 37

function part2(line)
    positions = parsePositions(line)
    position = bestPosition2(positions)
    return totalDistance2(position, positions)
end

@test part2(firstExampleLine(7,1)) == 168

firstLine(7) |> l -> @time part1(l) |> show
firstLine(7) |> l -> @time part2(l) |> show
