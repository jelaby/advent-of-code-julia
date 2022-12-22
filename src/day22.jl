#=
day22:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2222-12-22
=#
using Test
using Base.Iterators
using Memoize
include("AoC.jl")

const SPACE= ' '
const OPEN = '.'
const WALL = '#'

input = open(readlines, "src/day22-input.txt")
example1 = open(readlines, "src/day22-example-1.txt")

parseMapSquare(c) = c
function fixLength(lines)
    len = maximum(length, lines)
    return [rpad(line, len, ' ') for line in lines]
end
parseMap(lines) = reshape([parseMapSquare(c) for line in fixLength(lines) for c in line], :, length(lines))

struct Rotation
    transformation::Array{Int}
end
ROTATE_RIGHT = Rotation([0;1;;-1;0])
ROTATE_LEFT = Rotation([0;-1;;1;0])

struct Movement
    distance::Int
end

function parseRotation(c)
    if c == 'R'
        return ROTATE_RIGHT
    elseif c == 'L'
        return ROTATE_LEFT
    else
        throw(ArgumentError("Unknown rotation $(c)"))
    end
end
@test parseRotation('R').transformation * [1,0] == [0,1]
@test parseRotation('R').transformation * [0,1] == [-1,0]
@test parseRotation('R').transformation * [-1,0] == [0,-1]
@test parseRotation('R').transformation * [0,-1] == [1,0]

@test parseRotation('L').transformation * [1,0] == [0,-1]
@test parseRotation('L').transformation * [0,-1] == [-1,0]
@test parseRotation('L').transformation * [-1,0] == [0,1]
@test parseRotation('L').transformation * [0,1] == [1,0]

function parseMovements(line)
    result = Vector{Union{Rotation,Movement}}()
    distance = 0
    for c in line
        if '0' <= c <= '9'
            distance = 10distance + (c - '0')
        else
            push!(result, Movement(distance))
            distance = 0
            push!(result, parseRotation(c))

        end
    end
    if distance != 0
        push!(result, Movement(distance))
    end
    return result
end

function parseInput(lines)
    map = parseMap(@view lines[1:end-2])
    movements = parseMovements(lines[end])
    return (map, movements)
end

function followMovements(map, movements, position, direction)
    for movement in movements
        position,direction = followMovement(map, movement, position, direction)
    end
    return position,direction
end

Base.:*(a, b::CartesianIndex) = CartesianIndex((a * [Tuple(b)...])...)

followMovement(map, movement::Rotation, position, direction) = (position, movement.transformation * direction)
@test followMovement(Char[], ROTATE_RIGHT, CartesianIndex(5,7), [1,0]) == (CartesianIndex(5,7), [0,1])

function loopAround(map, position, direction)
    originalPosition=position
    while checkbounds(Bool, map, position - direction) && map[position - direction] != SPACE
        position = position - direction
    end
    if map[position] == WALL
        return originalPosition
    end
    return position
end

function followMovement(map, movement::Movement, position, direction)
    for i in 1:movement.distance
        nextPosition = position + direction
        if !checkbounds(Bool, map, nextPosition) || map[nextPosition] == SPACE
            position = loopAround(map, position, direction)
        elseif map[nextPosition] == OPEN
            position = nextPosition
        elseif map[nextPosition] == WALL
            return (position,direction)
        else
            throw(ArgumentError("Unknown map type $(map[nextPosition])"))
        end
    end
    return (position,direction)
end

function findStart(map, position)
    while map[position] != OPEN
        position = position + CartesianIndex(1,0)
    end
    return position
end

function part1(lines)
    map,movements = parseInput(lines)

    position,direction = followMovements(map, movements, findStart(map, CartesianIndex(1,1)), CartesianIndex(1,0))

    return score(position,direction)
end

function score(direction)
    if direction == CartesianIndex(1,0)
        return 0
    elseif direction == CartesianIndex(-1,0)
        return 2
    elseif direction == CartesianIndex(0,1)
        return 1
    elseif direction == CartesianIndex(0,-1)
        return 3
    else
        throw(ArgumentError("Unknown direction $(direction)"))
    end
end
score(position,direction) = 1000*position[2] + 4*position[1] + score(direction)

@time @test part1(example1) == 6032

println("Calculating...")
@time result = part1(input)
println(result)
