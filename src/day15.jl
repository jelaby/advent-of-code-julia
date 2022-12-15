#=
day15:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-15-15
=#
using Test
using Base.Iterators

lines = open(readlines, "src/day15-input.txt")
example1 = open(readlines, "src/day15-example-1.txt")

struct Sensor
    position::Tuple{Int,Int}
    beacon::Tuple{Int,Int}
end
Sensor(a,b,c,d) = Sensor((a,b),(c,d))

manhattanDistance(a,b) = sum(abs.(a.-b))
clearDistance(sensor::Sensor) = manhattanDistance(sensor.position, sensor.beacon)

parseSensor(line) = match(r"Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)", line) |>
    numbers -> parse.(Int, numbers) |>
    numbers -> Sensor(numbers...)

#=
   #
  ###
 ##S##
  ###
   #
=#

function clearCoords(sensor::Sensor, row)
    offset = abs(sensor.position[2] - row)
    if offset > clearDistance(sensor)
        return []
    else
        width = clearDistance(sensor) - offset
        return sensor.position[1]-width:sensor.position[1]+width
    end
end
@test clearCoords(Sensor(0,0,3,0), 0) == -3:3

beaconsOnRow(sensors, row) = filter([s.beacon for s in sensors]) do beacon
    beacon[2] == row
end
beaconPositionsOnRow(sensors, row) = [beacon[1] for beacon in beaconsOnRow(sensors, row)]
@test beaconPositionsOnRow([Sensor(0,0,0,0), Sensor(0,0,14,1), Sensor(0,0,17,0)], 0) == [0,17]
@test beaconPositionsOnRow([Sensor(0,0,0,0), Sensor(0,0,14,1), Sensor(0,0,17,0)], 1) == [14]

clearCoords(sensors, row) = symdiff(union(clearCoords.(sensors, row)...), beaconPositionsOnRow(sensors, row))

parseSensors(lines) = parseSensor.(lines)



part1(lines, row) = parseSensors(lines) |> sensors -> length(clearCoords(sensors, row))

@test part1(example1, 10) == 26

@time println(part1(lines, 2000000))
