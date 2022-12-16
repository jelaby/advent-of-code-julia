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

struct UnitRanges
    a::Union{UnitRanges,UnitRange}
    b::UnitRange
end
UnitRanges(a::UnitRange, b::UnitRanges) = UnitRanges(b,a)
UnitRanges(a::UnitRanges, b::UnitRanges) = UnitRanges(UnitRanges(UnitRanges(a.a,a.b),b.a),b.b)

function Base.union(a::UnitRange, b::UnitRanges)
    aa = a ∪ b.a
    ab = a ∪ b.b

    if aa isa UnitRange
        return aa ∪ b.b
    elseif ab isa UnitRange
        return ab ∪ b.a
    else
        return UnitRanges(aa,b)
    end
end
Base.union(a::UnitRanges, b::UnitRange) = union(b,a)

Base.union(a::UnitRanges, b::UnitRanges) = a.a ∪ b ∪ a.b


function Base.union(a::UnitRange, b::UnitRange)
    if a.start <= b.start && a.stop >= b.stop
        return a;
    elseif b.start <= a.start && b.stop >= a.stop
        return b;
    elseif (a.start <= b.start && a.stop >= b.stop) ||
        (b.start <= a.start && b.stop >= a.stop) ||
        (a.stop + 1 == b.start) ||
        (b.stop + 1 == a.start)
        return min(a.start,b.start):max(a.stop,b.stop)
    else
        return UnitRanges(a,b)
    end
end
@test union(1:3,4:6) == 1:6
@test union(1:3,5:6) == UnitRanges(1:3,5:6)
@test (1:3) ∪ (5:6) ∪ (4:4) == 1:6

function Base.setdiff(a::UnitRange, b::UnitRange)
    if a.start <= b.start && a.stop >= b.stop
        return UnitRanges(a.start:b.start-1, b.stop+1:a.stop)
    elseif b.start <= a.start && b.stop >= a.stop
        return Nothing
    elseif a.start <= b.start && a.stop >= b.start
        return a.start:b.start-1
    elseif b.start <= a.start && b.stop >= a.start
        return b.stop+1:a.stop
    else
        return a
    end
end

function Base.setdiff(a::UnitRange, b::UnitRanges)
    return setdiff(setdiff(a,b.a),b.b)
end

function Base.setdiff(a::UnitRanges, b::UnitRanges)
    return setdiff(a.a,b) ∪ setdiff(a.b,b)
end

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
beaconPositionsOnRow(sensors, row) = Set([beacon[1] for beacon in beaconsOnRow(sensors, row)])
@test beaconPositionsOnRow([Sensor(0,0,0,0), Sensor(0,0,14,1), Sensor(0,0,17,0)], 0) == Set([0,17])
@test beaconPositionsOnRow([Sensor(0,0,0,0), Sensor(0,0,14,1), Sensor(0,0,17,0)], 1) == Set([14])

clearCoordsOrBeacons(sensors, row) = union(clearCoords.(sensors, row)...)

parseSensors(lines) = parseSensor.(lines) |> sensors -> sort!(sensors, by=sensor->sensor.position[1])


tuningFrequency(gap) = gap[1]*4000000 + gap[2]


function findGap(sensors, maxC)
    for row in 0:maxC
        gaps = setdiff(0:maxC, clearCoordsOrBeacons(sensors,row))
        if !isempty(gaps)
            return (first(gaps),row)
        end
    end
end


part1(lines, row) = parseSensors(lines) |> sensors -> length(clearCoordsOrBeacons(sensors, row)) - length(beaconPositionsOnRow(sensors,row))
part2(lines, maxC) = parseSensors(lines) |> sensors -> findGap(sensors, maxC) |> gap -> tuningFrequency(gap)

@test 14 ∉ parseSensors(example1) |> sensors -> clearCoordsOrBeacons(sensors, 11)

@test part1(example1, 10) == 26
@test (parseSensors(example1) |> sensors -> findGap(sensors, 20)) == (14,11)
@test part2(example1, 20) == 56000011

println("Calculating...")
@time println(part1(lines, 2000000))
@time println(part2(lines, 4000000))
