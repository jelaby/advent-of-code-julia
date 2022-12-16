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

struct Range
    start::Int
    stop::Int
end
Base.:(==)(a::Range,b::Range) = a.start == b.start && a.stop == b.stop

struct Row
    ranges::Vector{Range}
    Row(ranges) = new(sort(ranges, by=r->r.start))
end
Row() = Row([])
Base.:(==)(a::Row,b::Row) = a.ranges == b.ranges

Base.push!(::Nothing, range::UnitRange) = Base.push!(Row(), range)
Base.push!(row::Row, range::UnitRange) = Base.push!(row, Range(range.start, range.stop))
function Base.push!(row::Row, range::Range)
    if isempty(row.ranges)
        push!(row.ranges, range)
        return row
    end

    i = Base.Sort.searchsortedfirst(row.ranges, range, by=r->r.start)

    if i == 1
        insert!(row.ranges, i, range)
    else
        other = row.ranges[i-1]

        if other.stop >= range.stop
            # new entry is subset of existing
        elseif other.stop + 1 >= range.start
            # new entry abuts previous
            row.ranges[i-1] = Range(other.start, range.stop)
            i -= 1
        else
            insert!(row.ranges, i, range)
        end
    end

    # new entry abuts next one(s)
    while i+1 <= length(row.ranges) && row.ranges[i].stop + 1 >= row.ranges[i+1].start
        row.ranges[i] = Range(row.ranges[i].start, max(row.ranges[i].stop, row.ranges[i+1].stop))
        popat!(row.ranges, i+1)
    end

    return row
end

Base.length(range::Range) = range.stop + 1 - range.start
Base.length(row::Row) = sum(range -> length(range), row.ranges)

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
        return nothing
    else
        width = clearDistance(sensor) - offset
        return Range(sensor.position[1]-width,sensor.position[1]+width)
    end
end
@test clearCoords(Sensor(0,0,3,0), 0) == Range(-3,3)

beaconsOnRow(sensors, row) = filter([s.beacon for s in sensors]) do beacon
    beacon[2] == row
end
beaconPositionsOnRow(sensors, row) = Set([beacon[1] for beacon in beaconsOnRow(sensors, row)])
@test beaconPositionsOnRow([Sensor(0,0,0,0), Sensor(0,0,14,1), Sensor(0,0,17,0)], 0) == Set([0,17])
@test beaconPositionsOnRow([Sensor(0,0,0,0), Sensor(0,0,14,1), Sensor(0,0,17,0)], 1) == Set([14])

combine(::Nothing,::Nothing) = nothing
combine(::Nothing, range) = range
combine(range, ::Nothing) = range
combine(a::Range, b::Range) = combine(Row([a]), b)
combine(a::Row, b::Range) = push!(a,b)
clearCoordsOrBeacons(sensors, row) = foldl(combine, clearCoords.(sensors, row), init=Row())

@test combine(nothing,nothing)===nothing
@test combine(Range(1,3),nothing)==Range(1,3)
@test combine(Range(1,3),Range(2,6))==Row([Range(1,6)])
@test combine(Range(1,3),Range(4,6))==Row([Range(1,6)])
@test combine(Range(1,3),Range(5,6))==Row([Range(1,3),Range(5,6)])

@test combine(Row([Range(100,110),Range(120,130),Range(140,150)]), Range(99,151)) == Row([Range(99,151)])
@test combine(Row([Range(100,110),Range(120,130),Range(140,150)]), Range(99,150)) == Row([Range(99,150)])
@test combine(Row([Range(100,110),Range(120,130),Range(140,150)]), Range(99,149)) == Row([Range(99,150)])
@test combine(Row([Range(100,110),Range(120,130),Range(140,150)]), Range(100,149)) == Row([Range(100,150)])
@test combine(Row([Range(100,110),Range(120,130),Range(140,150)]), Range(101,149)) == Row([Range(100,150)])
@test combine(Row([Range(100,110),Range(120,130),Range(140,150)]), Range(101,151)) == Row([Range(100,151)])

parseSensors(lines) = parseSensor.(lines) |> sensors -> sort!(sensors, lt=(a,b) -> a.position[1]<b.position[1] || a.position[2]<b.position[2])


function tuningFrequency(gap)
    @show gap
    return gap[1]*4000000 + gap[2]
end


function findGap(row::Row, minPosition, maxPosition)
    for range in row.ranges
        if range.start > minPosition
            @show row
            return range.start - 1
        elseif range.stop < maxPosition
            @show row
            return range.stop + 1
        end
    end
    return nothing
end

function findGap(sensors::Vector{Sensor}, maxC)
    for i in 0:maxC
        row = clearCoordsOrBeacons(sensors,i)

        gap = findGap(row, 0, maxC)

        if gap !== nothing
            return (gap,i)
        end
    end
end


part1(lines, row) = parseSensors(lines) |> sensors -> length(clearCoordsOrBeacons(sensors, row)) - length(beaconPositionsOnRow(sensors,row))
part2(lines, maxC) = parseSensors(lines) |> sensors -> findGap(sensors, maxC) |> gap -> tuningFrequency(gap)

@show parseSensors(example1) |> sensors -> clearCoordsOrBeacons(sensors, 11)

@test part1(example1, 10) == 26
@test (parseSensors(example1) |> sensors -> findGap(sensors, 20)) == (14,11)
@test part2(example1, 20) == 56000011

println("Calculating...")
@time println(part1(lines, 2000000))
@time println(part2(lines, 4000000))
