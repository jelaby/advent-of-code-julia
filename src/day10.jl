#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-10
=#
using Test

lines = open(readlines, "src/day10-input.txt")
example1 = open(readlines, "src/day10-example-1.txt")


struct Device
    cycle::Int
    X::Int
end

struct Command
    command::Symbol
    args::Vector{Int}
end

Base.parse(::Type{Command}, line) = split(line, " ") |> parts -> Command(Symbol(parts[1]), parse.(Int, @view parts[2:end]))

eval(device::Device, ::Val{:noop}) = Device(device.cycle + 1, device.X)
eval(device::Device, ::Val{:addx}, arg::Int) = Device(device.cycle + 2, device.X + arg)
eval(device::Device, command::Command) = eval(device, Val(command.command), command.args...)

function signalStrength(program::Vector{Command}, limit, firstSample=20, sampleInterval=40)
    device = Device(1, 1)
    samplePoint = firstSample
    result = 0

    for command in program
        nextDevice = eval(device, command)

        if nextDevice.cycle > samplePoint
            result += device.X * samplePoint
            samplePoint+=sampleInterval
        end
        if nextDevice.cycle > limit
            return result
        end

        device = nextDevice
    end
    return result
end

@test signalStrength([Command(:noop,[]), Command(:addx, [3]), Command(:addx, [-5])], 3) == 0

@test signalStrength(parse.(Command, example1),20) == 420
@test signalStrength(parse.(Command, example1),60) == 420 + 1140
@test signalStrength(parse.(Command, example1),100) == 420 + 1140 + 1800
@test signalStrength(parse.(Command, example1),220) == 13140


part1(lines) = signalStrength(parse.(Command, lines), 220)

@test part1(example1) == 13140

show(@time part1(lines))
