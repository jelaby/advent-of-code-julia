#=
day25:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-25
=#

using AoC, Test

const RIGHT=CartesianIndex(1,0)
const LEFT=CartesianIndex(-1,0)
const UP=CartesianIndex(0,-1)
const DOWN=CartesianIndex(0,1)

function Base.show(io::IO, a::Array{Char,2})
    for y in 1:size(a, 2)
        println(io)
        for x in 1:size(a, 1)
            print(io, a[x,y])
        end
    end
end

function parseSeafloor(lines)
    seafloor = Array{Char}(undef, length(lines[1]), length(lines))
    for y in eachindex(lines)
        for x in eachindex(lines[y])
            seafloor[x,y] = lines[y][x]
        end
    end
    return seafloor
end

function bound(seafloor, P)
    maxima = size(seafloor)
    return CartesianIndex((mod1(P[axis],maxima[axis]) for axis in 1:ndims(seafloor))...)
end
@test bound(zeros(3,2), CartesianIndex(1,1)) == CartesianIndex(1,1)
@test bound(zeros(3,2), CartesianIndex(1,2)) == CartesianIndex(1,2)
@test bound(zeros(3,2), CartesianIndex(1,3)) == CartesianIndex(1,1)
@test bound(zeros(3,2), CartesianIndex(2,1)) == CartesianIndex(2,1)
@test bound(zeros(3,2), CartesianIndex(3,1)) == CartesianIndex(3,1)
@test bound(zeros(3,2), CartesianIndex(4,1)) == CartesianIndex(1,1)

function tryMove!(seafloor, newSeafloor, newRCandidates, newDCandidates, newTypeCandidates, type, position, direction)
    if seafloor[position] == type
        newPosition = bound(seafloor, position+direction)
        if seafloor[newPosition] == '.'
            newSeafloor[newPosition] = type
            newSeafloor[position] = '.'
            push!(newTypeCandidates, newPosition)
            push!(newRCandidates, bound(seafloor, position+LEFT))
            push!(newDCandidates, bound(seafloor, position+UP))
        end
    end
end

step(seafloor) = step(seafloor, CartesianIndices(seafloor), CartesianIndices(seafloor))
function step(seafloor, rcandidates, dcandidates)
    newSeafloor = copy(seafloor)
    newRCandidates = CartesianIndex[]
    newDCandidates = CartesianIndex[]
    for r in rcandidates
        tryMove!(seafloor, newSeafloor, newRCandidates, newDCandidates, newRCandidates, '>', r, RIGHT)
    end
    seafloor = newSeafloor
    newSeafloor = copy(seafloor)
    for d in union(dcandidates,newDCandidates)
        tryMove!(seafloor, newSeafloor, newRCandidates, newDCandidates, newDCandidates, 'v', d, DOWN)
    end
    return (newSeafloor, newRCandidates, newDCandidates)
end

@test step([['>','.'] ['.','.']])[1] == [['.','>'] ['.','.']]
@test step([['.','>'] ['.','.']])[1] == [['>','.'] ['.','.']]
@test step([['>','v'] ['.','.']])[1] == [['>','.'] ['.','v']]
@test step(parseSeafloor(exampleLines(25,10)))[1] == parseSeafloor(exampleLines(25,11))
@test step(parseSeafloor(exampleLines(25,11)))[1] == parseSeafloor(exampleLines(25,12))
@test step(step(parseSeafloor(exampleLines(25,10)))...)[1] == parseSeafloor(exampleLines(25,12))

function runToDeadlock(seafloor)
    rcandidates=CartesianIndices(seafloor)
    dcandidates=CartesianIndices(seafloor)

    turns = 0
    while !isempty(rcandidates) && !isempty(dcandidates)
        turns += 1
        (seafloor,rcandidates,dcandidates) = step(seafloor, rcandidates, dcandidates)
    end

    return (turns,seafloor)
end

function part1(lines)
    seafloor = parseSeafloor(lines)

    (turns, seafloor) = runToDeadlock(seafloor)

    @show seafloor

    return turns
end

@test part1(exampleLines(25,1)) == 58

@show @time part1(lines(25))