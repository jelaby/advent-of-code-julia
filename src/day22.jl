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

function followMovements(map, movements, position, direction, loopAround)
    for movement in movements
        position,direction = followMovement(map, movement, position, direction, loopAround)
    end
    return position,direction
end

Base.:*(a, b::CartesianIndex) = CartesianIndex((a * [Tuple(b)...])...)

followMovement(map, movement::Rotation, position, direction, loopAround) = (position, movement.transformation * direction)
@test followMovement(Char[], ROTATE_RIGHT, CartesianIndex(5,7), [1,0], nothing) == (CartesianIndex(5,7), [0,1])

function loopAround1(map, position, direction)
    originalPosition=position
    while checkbounds(Bool, map, position - direction) && map[position - direction] != SPACE
        position = position - direction
    end
    return (position,direction)
end

const LEFT = CartesianIndex(-1,0)
const RIGHT = CartesianIndex(1,0)
const UP = CartesianIndex(0,-1)
const DOWN = CartesianIndex(0,1)

function loopAround2Eg(map, position, direction)
    nextPosition = position + direction
    if position[1] == 9 && nextPosition[1] == 8
        if position[2] <= 4
            return (CartesianIndex(nextPosition[2]+4,5), CartesianIndex(0,1))
        else
            return (CartesianIndex(4+13-nextPosition[2],8), CartesianIndex(0,-1))
        end
    elseif position[1] == 12 && nextPosition[1] == 13
        if position[2] <= 4
            return (CartesianIndex(12,13-nextPosition[2]), CartesianIndex(-1,0))
        else
            return (CartesianIndex(17-(nextPosition[2]-4),9), CartesianIndex(0,1))
        end
    elseif nextPosition[1]==0
        return (CartesianIndex(17-(nextPosition[2]-4),12), CartesianIndex(0,-1))
    elseif nextPosition[2]==5 && nextPosition[2]==4
        if nextPosition[1]<=4
            return (CartesianIndex(13-nextPosition[1],1), CartesianIndex(0,1))
        else
            return (CartesianIndex(9,nextPosition[2]-4), CartesianIndex(1,0))
        end
    elseif position[2]==8 && nextPosition[2]==9
        if nextPosition[1] <= 4
            return (CartesianIndex(13-nextPosition[1],12), CartesianIndex(0,-1))
        else
            return (CartesianIndex(9,13-(nextPosition[1]-4)), CartesianIndex(1,0))
        end
    elseif nextPosition[2] == 0
        return (CartesianIndex(5-(nextPosition[1]-8),5), CartesianIndex(0,1))
    elseif nextPosition[2] == 13
        if nextPosition[1] <= 12
            return (CartesianIndex(5-(nextPosition[1]-8)), CartesianIndex(0,-1))
        else
            return (CartesianIndex(1,9-nextPosition[1]-12), CartesianIndex(1,0))
        end
    else
        throw(ArgumentError("You done messed up $(position) $(nextPosition)"))
    end
end

@memoize edge(map) = @show size(map,1) ÷ 3

function loopAround2(map, position, direction, l=edge(map))
    nextPosition = position + direction
    x,y = (position[1],position[2])
    x′,y′ = (nextPosition[1],nextPosition[2])
    #=
     ██
     █
    ██
    █
    =#
    if y′ == 0 && x <= 2l
        return (CartesianIndex(1, 3l + x-l), RIGHT)
    elseif y′ == 0 && x > 2l
        return (CartesianIndex(x-2l, 4l), UP)
    elseif x′ == 3l+1
        return (CartesianIndex(2l, 2l + (l+1-y)), LEFT)
    elseif y == l && y′ == l + 1
        return (CartesianIndex(2l, l + (x - 2l)), LEFT)
    elseif x == 2l && x′ == 2l+1 && y <= 2l
        return (CartesianIndex(2l + y - l, l), UP)
    elseif x == 2l && x′ == 2l+1 && y > 2l
        return (CartesianIndex(3l, l+1 - (y-2l)), LEFT)
    elseif y == 3l && y′ == 3l+1
        return (CartesianIndex(l, 3l + x-l), LEFT)
    elseif x == l && x′ == l+1
        return (CartesianIndex(l + y-3l, 3l), UP)
    elseif y′ == 4l+1
        return (CartesianIndex(2l+x, 1), DOWN)
    elseif x′ == 0 && y > 3l
        return (CartesianIndex(l + y-3l, 1), DOWN)
    elseif x′ == 0 && y <= 3l
        return (CartesianIndex(l+1, l+1 - (y-2l)), RIGHT)
    elseif y == 2l+1 && y′ == 2l
        return (CartesianIndex(l+1, l + x), RIGHT)
    elseif x == l+1 && x′ == l && y > l
        return (CartesianIndex(y-l, 2l+1), DOWN)
    elseif x == l+1 && x′ == l && y <= l
        return (CartesianIndex(1, 2l + (l+1-y)), RIGHT)
    else
        throw(ArgumentError("You done messed up $(position) $(nextPosition)"))
    end
end

function followMovement(map, movement::Movement, position, direction, loopAround)
    try
        return doFollowMovement(map, movement, position, direction, loopAround)
    catch e
        throw(ArgumentError("Error when evaluating $(movement) at $(position) $(direction)"))
    end
end
function doFollowMovement(map, movement::Movement, position, direction, loopAround)
    for i in 1:movement.distance
        nextPosition = position + direction
        if !checkbounds(Bool, map, nextPosition) || map[nextPosition] == SPACE
            nextPosition,nextDirection = loopAround(map, position, direction)
            if map[nextPosition] == OPEN
                position,direction = (nextPosition, nextDirection)
            end
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

function execute(lines, loopAround)
    map,movements = parseInput(lines)

    position,direction = followMovements(map, movements, findStart(map, CartesianIndex(1,1)), CartesianIndex(1,0), loopAround)

    return score(position,direction)
end
part1(lines) = execute(lines, loopAround1)
part2(lines) = execute(lines, loopAround2)

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
#@time @test execute(example1, loopAround2Eg) == 5031

example2 = [
"  ....",
"  ....",
"  ..",
"  ..",
"....",
"....",
"..",
"..",
""]
@test part2([example2...,"2"]) == score(CartesianIndex(5,1),RIGHT)
@test part2([example2...,"4"]) == score(CartesianIndex(4,6),LEFT)
@test part2([example2...,"6"]) == score(CartesianIndex(2,6),LEFT)
@test part2([example2...,"8"]) == score(CartesianIndex(3,1),RIGHT)
@test part2([example2...,"1L"]) == score(CartesianIndex(4,1),UP)
@test part2([example2...,"1L1"]) == score(CartesianIndex(1,8),RIGHT)
@test part2([example2...,"1L3"]) == score(CartesianIndex(4,6),UP)
@test part2([example2...,"1L5"]) == score(CartesianIndex(4,4),UP)
@test part2([example2...,"1L7"]) == score(CartesianIndex(4,2),UP)
@test part2([example2...,"1R"]) == score(CartesianIndex(4,1),DOWN)
@test part2([example2...,"1R2"]) == score(CartesianIndex(4,3),DOWN)
@test part2([example2...,"1R4"]) == score(CartesianIndex(4,5),DOWN)
@test part2([example2...,"1R6"]) == score(CartesianIndex(2,8),LEFT)
@test part2([example2...,"1R8"]) == score(CartesianIndex(4,1),DOWN)
@test part2([example2...,"2L"]) == score(CartesianIndex(5,1),UP)
@test part2([example2...,"2L2"]) == score(CartesianIndex(1,7),UP)
@test part2([example2...,"2L4"]) == score(CartesianIndex(1,5),UP)
@test part2([example2...,"2L6"]) == score(CartesianIndex(4,3),RIGHT)
@test part2([example2...,"2L8"]) == score(CartesianIndex(5,1),UP)
@test part2([example2...,"2R"]) == score(CartesianIndex(5,1),DOWN)
@test part2([example2...,"2R2"]) == score(CartesianIndex(4,3),LEFT)
@test part2([example2...,"2R4"]) == score(CartesianIndex(1,5),DOWN)
@test part2([example2...,"2R6"]) == score(CartesianIndex(1,7),DOWN)
@test part2([example2...,"2R8"]) == score(CartesianIndex(5,1),DOWN)
@test part2([example2...,"4R0R1"]) == score(CartesianIndex(6,1),LEFT)

println("Calculating...")
@time result = part1(input)
println(result)
@test result == 146092
@time result = part2(input)
println(result)
@test result > 31446
