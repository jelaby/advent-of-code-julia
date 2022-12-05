#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-05
=#
using Test

lines = open(readlines, "src/day5-input.txt")
example1 = open(readlines, "src/day5-example-1.txt")

struct Move
    count
    from
    to
end

function ensureSize!(v::Vector{T}, size) where T
    while length(v) < size
        push!(v, T())
    end
end

function parseInput(lines)

    stacks = Vector{Vector{Char}}()
    moves = Vector{Move}()

    for line in lines
        stackmatch = match(r"\[", line)
        movematch = match(r"^move (\d+) from (\d+) to (\d+)$", line)

        if !isnothing(stackmatch)

            for c in 2:4:length(line)
                i = (c+3)÷4
                crate = line[c]
                if crate != ' '
                    ensureSize!(stacks, i)
                    pushfirst!(stacks[i], crate)
                end
            end

        elseif !isnothing(movematch)

            push!(moves, Move(parse.(Int, movematch.captures)...))

        end
    end

    return (stacks=stacks, moves=moves)

end

function applyMove!(stacks, move::Move)
    stack = stacks[move.from]
    removed = stack[(end+1-move.count):end]
    stacks[move.from] = stack[1:max(0, length(stack) - move.count)]
    append!(stacks[move.to], reverse(removed))
    return stacks
end

top(stack) = stack[end]
tops(stacks) = top.(stacks)
@test tops([[1,2],[3,4]]) == [2,4]

function part1(lines)
    (; stacks, moves) = parseInput(lines)

    @show stacks moves

    for move in moves
        applyMove!(stacks, move)
    end

    return String(tops(stacks))
end
@test part1(example1) == "CMZ"



show(@time part1(lines))
