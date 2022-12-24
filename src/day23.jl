#=
day23:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2323-12-23
=#
using Test
using Base.Iterators
using Memoize
include("AoC.jl")

input = open(readlines, "src/day23-input.txt")
example1 = open(readlines, "src/day23-example-1.txt")
example2 = open(readlines, "src/day23-example-2.txt")

Base.:(*)(a,b::Tuple) = Tuple((a * [b...]))
Base.:(*)(a,b::CartesianIndex) = CartesianIndex((a * Tuple(b))...)

const UP = CartesianIndex(0,-1)
const RIGHT = CartesianIndex(1,0)
const DOWN = CartesianIndex(0,1)
const LEFT = CartesianIndex(-1,0)

const MOVES = [UP,DOWN,LEFT,RIGHT]

const FRONT=[1;0;;0;1]
const FRONT_LEFT=[1;-1;;1;1]
const FRONT_RIGHT=[1;1;;-1;1]

const FACING_ATTEMPTS = [[1;0;;0;1],[-1;0;;0;-1],[0;-1;;1;0],[0;1;;-1;0]]

const VIEW=[FRONT_LEFT,FRONT,FRONT_RIGHT]
@show const NEIGHBOURS=filter!(c -> c != CartesianIndex(0,0), [CartesianIndex(x,y) for x in -1:1 for y in -1:1])

@test FRONT*UP == UP
@test FRONT_LEFT*UP == UP+LEFT
@test FRONT_RIGHT*UP == UP+RIGHT
@test FRONT*RIGHT == RIGHT
@test FRONT_LEFT*RIGHT == RIGHT+UP
@test FRONT_RIGHT*RIGHT == RIGHT+DOWN

struct Elf
    position::CartesianIndex
end
Elf(position, direction) = Elf(position)
Elf(px,py,dx,dy) = Elf(CartesianIndex(px,py))
Base.:(==)(a::Elf,b::Elf) = a.position == b.position

parseMapAsArray(lines) = [c == '#' for line in lines for c in line] |> cc -> reshape(cc, :, length(lines))
arrayToElves(map) = [Elf(I, UP) for I in filter(i->map[i], CartesianIndices(map))]
parseElves = arrayToElves ∘ parseMapAsArray


struct Movement
    current::Elf
    next::Elf
end

ahead(direction) = [v * direction for v in VIEW]
@test ahead(CartesianIndex(0,-1)) == [CartesianIndex(-1,-1),CartesianIndex(0,-1),CartesianIndex(1,-1)]

function moveElf(elves::Dict, elf::Elf, round)
    if !any(n->haskey(elves, elf.position + n), NEIGHBOURS)
        return elf
    end

    for attempt in 0:3
        direction = MOVES[mod1(round+attempt,length(MOVES))]
        if !any(v->haskey(elves, elf.position + v), ahead(direction))
            return Elf(elf.position + direction, direction)
        end
    end
    return elf
end

function round(elves, round)

    proposedMovements=Dict{CartesianIndex, Movement}()

    for elf in values(elves)
        proposal = moveElf(elves, elf, round)
        otherProposal = get(proposedMovements, proposal.position, nothing)
        if otherProposal !== nothing
            delete!(proposedMovements, proposal.position)
            proposedMovements[otherProposal.current.position] = Movement(otherProposal.current, otherProposal.current)
            proposedMovements[elf.position] = Movement(elf, elf)
        else
            proposedMovements[proposal.position] = Movement(elf, proposal)
        end
    end

    return Dict([elf.next.position => elf.next for elf in values(proposedMovements)])
end

function rounds(elves, count=typemax(Int))
    elves = Dict([elf.position=>elf for elf in elves])
    for i = 1:count
        nextElves = round(elves, i)
        if nextElves == elves
            println("Final round $(i)")
            return collect(values(nextElves))
        else
            elves = nextElves
        end
    end
    return collect(values(elves))
end
@test rounds([Elf(1,1,0,1)], 1) == [Elf(1,1,0,1)]
@test rounds([Elf(1,1,0,-1), Elf(1,0,0,-1)], 1) == [Elf(1,2,0,1),Elf(1,-1,0,-1)]
@test rounds([Elf(1,1,0,-1), Elf(1,0,0,-1)], 2) == [Elf(1,2,0,1),Elf(1,-1,0,-1)]

topLeft(elves) = (minimum(elf->elf.position[1],elves), minimum(elf->elf.position[2], elves))
bottomRight(elves) = (maximum(elf->elf.position[1],elves), maximum(elf->elf.position[2], elves))

function freeSpace(elves)
    size = (1,1) .+ bottomRight(elves) .- topLeft(elves)

    return *(size...) - length(elves)
end

function elvesToPlan(elves)

    tl = CartesianIndex(topLeft(elves))
    br = CartesianIndex(bottomRight(elves))

    size = br + CartesianIndex(1,1) - tl

    result = fill('.', Tuple(size))

    for elf in elves
        result[elf.position + CartesianIndex(1,1) - tl] = '#'
    end

    return join([String(row) for row in eachcol(result)],'\n') * "\n"
end

#parseElves(example1) |> elves -> rounds(elves,0) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,1) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,2) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,3) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,4) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,5) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,6) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,7) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,8) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,9) |> elvesToPlan |> println
#parseElves(example1) |> elves -> rounds(elves,10) |> elvesToPlan |> println
#
#parseElves(example2) |> elves -> rounds(elves,0) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,1) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,2) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,3) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,4) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,5) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,6) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,7) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,8) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,9) |> elvesToPlan |> println
#parseElves(example2) |> elves -> rounds(elves,10) |> elvesToPlan |> println

@test parseElves(example1) |> elves -> rounds(elves,0) |> elves -> freeSpace(elves) == 7*7 - 22
@test parseElves(example1) |> elves -> rounds(elves,1) |> elves -> freeSpace(elves) == 9*9 - 22
@test parseElves(example1) |> elves -> rounds(elves,2) |> elves -> freeSpace(elves) == 11*9 - 22
@test parseElves(example1) |> elves -> rounds(elves,3) |> elves -> freeSpace(elves) == 11*10 - 22
@test parseElves(example1) |> elves -> rounds(elves,4) |> elves -> freeSpace(elves) == 11*10 - 22
@test parseElves(example1) |> elves -> rounds(elves,5) |> elves -> freeSpace(elves) == 11*11 - 22
@test parseElves(example1) |> elves -> rounds(elves,10) |> elves -> freeSpace(elves) == 12*11 - 22

@test freeSpace([Elf(1,1,99,98),Elf(2,2,99,98)]) == 2
@test freeSpace([Elf(1,1,99,98),Elf(3,3,99,98)]) == 7

part1(lines) = parseElves(lines) |> elves->rounds(elves,10) |> elves -> freeSpace(elves)
part2(lines) = parseElves(lines) |> elves->rounds(elves) |> elves -> freeSpace(elves)

@time @test part1(example1) == 110
@time @test part2(example2) == 5 * 6 - 5

println("Calculating...")
@time result = part1(input)
println(result)
@time result = part2(input)
println(result)
