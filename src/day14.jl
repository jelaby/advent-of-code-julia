#=
day14:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-14-14
=#
using Test
using Base.Iterators

lines = open(readlines, "src/day14-input.txt")
example1 = open(readlines, "src/day14-example-1.txt")

const AIR = '•'
const ROCK = '#'
const SAND = 'o'

parseVertex(vertex) = split.(vertex, ",") |> coords -> parse.(Int, coords) |> Tuple |> CartesianIndex
parseLines(lines) = [split.(line, " -> ") |> vertices -> parseVertex.(vertices) for line in lines]

function addFloor!(lines)
    vertices = flatten(lines)
    minx = minimum(vertex -> vertex[1], vertices)
    miny = minimum(vertex -> vertex[2], vertices)
    maxx = maximum(vertex -> vertex[1], vertices)
    maxy = maximum(vertex -> vertex[2], vertices)

    push!(lines, [CartesianIndex(1,maxy+2),CartesianIndex(maxx+maxy,maxy+2)])

    return lines
end

function drawCave(lines)
    vertices = flatten(lines)
    minx = minimum(vertex -> vertex[1], vertices)
    miny = minimum(vertex -> vertex[2], vertices)
    maxx = maximum(vertex -> vertex[1], vertices)
    maxy = maximum(vertex -> vertex[2], vertices)

    cave = fill(AIR, maxx, maxy)

    for line in lines
        for edge in [line[i:i+1] for i in 1:(length(line)-1)]
            if edge[1][1] != edge[2][1]
                y = edge[1][2]
                for x in edge[1][1]:sign(edge[2][1]-edge[1][1]):edge[2][1]
                    cave[x,y] = '#'
                end
            else
                x = edge[1][1]
                for y in edge[1][2]:sign(edge[2][2]-edge[1][2]):edge[2][2]
                    cave[x,y] = '#'
                end
            end
        end
    end

    return cave
end

function simulateSand!(cave, sandStart=CartesianIndex(500,0))
    escaped = false
    count = -1
    while !escaped
        count += 1
        escaped = simulateGrain!(cave, sandStart);
    end
    return count
end

function simulateSand!(cave, sandStart=CartesianIndex(500,0))
    escaped = false
    count = -1
    lastPath = [sandStart]
    while !escaped
        count += 1
        escaped = simulateGrain!(cave, lastPath);
    end
    return count
end

const DOWN = CartesianIndex(0,1)
const DOWNLEFT = CartesianIndex(-1,1)
const DOWNRIGHT = CartesianIndex(1,1)

function simulateGrain!(cave, lastPath)
    sand = pop!(lastPath)
    while true
        push!(lastPath, sand)

        if cave[sand + DOWN] == AIR
            sand += DOWN
        elseif cave[sand + DOWNLEFT] == AIR
            sand += DOWNLEFT
        elseif cave[sand + DOWNRIGHT] == AIR
            sand += DOWNRIGHT
        elseif checkbounds(Bool, cave, sand)
            cave[sand] = SAND
            pop!(lastPath)
            return false
        else
            return true
        end

        if !checkbounds(Bool, cave, sand+DOWN)
            return true
        end
    end
end


printCave(cave) = println.(String.(eachcol(cave)))

drawCave(parseLines(example1))

part1 = simulateSand! ∘ drawCave ∘ parseLines
part2 = (n->n+1) ∘ simulateSand! ∘ drawCave ∘ addFloor! ∘ parseLines

@test part1(example1) == 24
@test part2(example1) == 93

@time println(part1(lines))
@time println(part2(lines))
