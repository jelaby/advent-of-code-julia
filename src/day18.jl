#=
day18:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-18
=#
using Test
using Base.Iterators
using Memoize
import LinearAlgebra
include("AoC.jl")

input = open(readlines, "src/day18-input.txt")
example1 = open(readlines, "src/day18-example-1.txt")

parseCoord(line) = split(line,",") |> parts -> parse.(Int,parts) |> parts -> (parts...,) |> CartesianIndex
parseCoords(lines) = parseCoord.(lines)
@test parseCoords(["1,2,3","4,5,6"]) == [CartesianIndex(1,2,3),CartesianIndex(4,5,6)]


function writeDroplet(coords)
    axiscount = length(coords[1])
    origin = fill(0, axiscount)
    extent = fill(0, axiscount)
    for axis in 1:axiscount
        origin[axis] = minimum(c->c[axis],coords)
        extent[axis] = maximum(c->c[axis],coords)
    end

    nought = CartesianIndex(ones(Int,axiscount)...)
    origin = CartesianIndex(origin...)
    extent = CartesianIndex(extent...)
    droplet = fill(false, Tuple(nought + extent - origin))

    for coord in coords
        droplet[coord + nought - origin] = true
    end

    return droplet
end

example1Coords = parseCoords(example1)

function countCommonFaces(droplet)
    axiscount = ndims(droplet)
    offsets = fill(0,axiscount,axiscount)
    offsets[LinearAlgebra.diagind(offsets)] .= 1
    neighbours = 0

    for I in CartesianIndices(droplet)
        for offset in eachrow(offsets)
            neighbour = I + CartesianIndex(offset...)
            if checkbounds(Bool, droplet, neighbour) && droplet[I] && droplet[neighbour]
                neighbours+=2
            end
        end
    end

    return neighbours
end
@test countCommonFaces([true false; false false;;;false false; false false]) == 0
@test countCommonFaces([true true; false false;;;false false; false false]) == 2
@test countCommonFaces([true true; false false;;;true false; false false]) == 4
@test countCommonFaces([true true; true false;;;true false; false false]) == 6
@test countCommonFaces([false, true, false, false, false]) == 0
@test countCommonFaces([false, true, true, false, false]) == 2
@test countCommonFaces([false, true, true, true, false]) == 4
@test countCommonFaces([false, true, true, true, true]) == 6


function part1(lines)
    coords = parseCoords(lines)
    droplet = writeDroplet(coords)
    faces = 6 * length(coords) - countCommonFaces(droplet)
    return faces
end

@time @test part1(example1) == 64

println("Calculating...")
@time println(part1(input))
