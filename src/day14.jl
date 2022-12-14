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


function drawCave(lines)
    vertices = flatten(lines)
    minx = minimum(vertex -> vertex[1], vertices)
    miny = minimum(vertex -> vertex[2], vertices)
    maxx = maximum(vertex -> vertex[1], vertices)
    maxy = maximum(vertex -> vertex[2], vertices)

    @show (minx,miny),(maxx,maxy)

    cave = fill(AIR, maxx, maxy)

    @show lines

    for line in lines
        for edge in [line[i:i+1] for i in 1:(length(line)-1)]
            @show edge
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

const DOWN = CartesianIndex(0,1)

function simulateSand!(cave, sandStart=CartesianIndex(500,0))
    escaped = false
    count = -1
    while !escaped
        count += 1
        escaped = simulateGrain!(cave, sandStart);
    end
    return count
end

const DOWN = CartesianIndex(0,1)
const DOWNLEFT = CartesianIndex(-1,1)
const DOWNRIGHT = CartesianIndex(1,1)

function simulateGrain!(cave, sandStart)
    sand = sandStart
    while true

        if cave[sand + DOWN] == AIR
            sand += DOWN
        elseif cave[sand + DOWNLEFT] == AIR
            sand += DOWNLEFT
        elseif cave[sand + DOWNRIGHT] == AIR
            sand += DOWNRIGHT
        else
            cave[sand] = SAND
            return false
        end

        if !checkbounds(Bool, cave, sand+DOWN)
            return true
        end
    end
end


printCave(cave) = println.(String.(eachcol(cave)))

drawCave(parseLines(example1))

part1 = simulateSand! ∘ drawCave ∘ parseLines

@test part1(example1) == 24

@time println(part1(lines))
