#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-09
=#
using Test

lines = open(readlines, "src/day9-input.txt")
example1 = open(readlines, "src/day9-example-1.txt")

struct Move
    direction::Char
    distance::Int
end

parseInput(lines) = split.(lines, r"\s+") .|> pair -> Move(pair[1][1], parse(Int, pair[2]))
@test parseInput(["R 3"]) == [Move('R', 3)]

direction(::Val{'L'}) = (-1,0)
direction(::Val{'R'}) = (1,0)
direction(::Val{'U'}) = (0,1)
direction(::Val{'D'}) = (0,-1)
direction(dir::Char) = direction(Val(dir))

recordTail!(trail::Set, T) = push!(trail, T)

@test (2,1) .- (1,0) == (1,1)
@test any(x -> x > 1, (2,1)) == true
@test any(x -> x > 2, (2,1)) == false

function doMove(H,T, direction, trail)
    H2 = H .+ direction
    if any(Δ -> abs(Δ) > 1, H2 .- T)
        recordTail!(trail, H)
        return (H2, H, trail)
    end
    return (H2, T, trail)
end
@test doMove((1,1), (1,1), (1,0), Set([(1,1)])) == ((2,1), (1,1), Set([(1,1)]))
@test doMove((2,1), (1,1), (1,0), Set([(1,1)])) == ((3,1), (2,1), Set([(1,1),(2,1)]))
@test doMove((2,1), (1,1), (0,1), Set([(1,1)])) == ((2,2), (1,1), Set([(1,1)]))
@test doMove((2,2), (1,1), (0,1), Set([(1,1)])) == ((2,3), (2,2), Set([(1,1),(2,2)]))

function doMove(H,T, move::Move, trail)
    dir = direction(move.direction)
    for step in 1:move.distance
        (H,T,trail) = doMove(H,T, dir, trail)
    end
    return (H, T, trail)
end

function doMoves(moves)
    H = (1,1)
    T = (1,1)
    trail = Set{Tuple{Int,Int}}([T])
    for move in moves
        (H,T, trail) = doMove(H,T, move, trail)
    end
    return trail
end

part1(lines) = length(doMoves(parseInput(lines)))

@test part1(example1) == 13

show(@time part1(lines))
