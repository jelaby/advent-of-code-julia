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

function runProgram(callback, state, program::Vector{Command})
    device = Device(1, 1)

    for command in program
        lastDevice = device
        device = eval(device, command)

        state = callback(state, device, lastDevice)
    end
    return state
end

function signalStrength(program::Vector{Command}, limit)
    return runProgram((; result=0, samplePoint=20), program) do state, device, lastDevice
        if device.cycle > state.samplePoint && state.samplePoint <= limit
            return (; result=state.result + lastDevice.X*state.samplePoint, samplePoint=state.samplePoint+40)
        else
            return state
        end
    end.result
end

@test signalStrength([Command(:noop,[]), Command(:addx, [3]), Command(:addx, [-5])], 3) == 0

@test signalStrength(parse.(Command, example1),20) == 420
@test signalStrength(parse.(Command, example1),60) == 420 + 1140
@test signalStrength(parse.(Command, example1),100) == 420 + 1140 + 1800
@test signalStrength(parse.(Command, example1),220) == 13140

function image(program::Vector{Command})
    image = runProgram(fill(false, 240), program) do image, device, lastDevice
        for cycle in lastDevice.cycle:device.cycle - 1
            pixelStart=lastDevice.X - 1
            pixelEnd=lastDevice.X + 1
            if pixelStart <= mod(cycle - 1, 40) <= pixelEnd
                image[cycle] = true
            end
        end
        return image
    end

    image = reshape([pixel ? '#' : '.' for pixel in image], 40, 6)
    return [String(row) for row in eachslice(image, dims=2)]
end
@test image(parse.(Command, example1)) == open(readlines, "src/day10-output-2.txt")

part1(lines) = signalStrength(parse.(Command, lines), 220)
part2(lines) = replace(join(image(parse.(Command, lines)), "\n"), '.'=>' ', '#'=>'█')

@test part1(example1) == 13140

@time println(part1(lines))
@time println(part2(lines))
