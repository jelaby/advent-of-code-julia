#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-09
=#
using Test

lines = open(readlines, "src/day9-input.txt")
example1 = open(readlines, "src/day9-example-1.txt")
example2 = open(readlines, "src/day9-example-2.txt")

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

towards(to, from) = sign.(to .- from)
@test towards((3,2), (1,1)) == (1,1)

function moveTail(H,T)
    if any(Δ -> abs(Δ) > 1, H .- T)
        T = T.+towards(H,T)
    end
    return T
end
@test moveTail((1,1), (1,1)) == (1,1)
@test moveTail((2,1), (1,1)) == (1,1)
@test moveTail((3,1), (1,1)) == (2,1)
@test moveTail((2,2), (1,1)) == (1,1)
@test moveTail((3,2), (1,1)) == (2,2)

function doMove(rope, move::Move, trail)
    dir = direction(move.direction)
    for step in 1:move.distance
        rope[1] = rope[1] .+ dir
        for i in 2:length(rope)
            rope[i] = moveTail(rope[i-1],rope[i])
        end
        recordTail!(trail, rope[end])
    end
    return (rope, trail)
end

function doMoves(moves, ropeLength)
    rope = fill((1,1), ropeLength)
    trail = Set{Tuple{Int,Int}}([rope[end]])
    for move in moves
        (rope, trail) = doMove(rope, move, trail)
    end
    return trail
end

part1(lines) = length(doMoves(parseInput(lines), 2))
part2(lines) = length(doMoves(parseInput(lines), 10))

@test part1(example1) == 13
@test part2(example1) == 1
@test part2(example2) == 36

show(@time part1(lines))
show(@time part2(lines))
