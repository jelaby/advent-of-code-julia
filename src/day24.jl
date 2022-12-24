#=
day24:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-24
=#
using Test
using Base.Iterators
using Memoize
import Random
include("AoC.jl")

input = open(readlines, "src/day24-input.txt")
example1 = open(readlines, "src/day24-example-1.txt")
example2 = open(readlines, "src/day24-example-2.txt")

const LEFT = CartesianIndex(-1,0)
const RIGHT = CartesianIndex(1,0)
const UP = CartesianIndex(0,-1)
const DOWN = CartesianIndex(0,1)

struct Wind
    start::CartesianIndex
    direction::CartesianIndex
end

function parseMap(lines)
    winds = Vector{Wind}()
    xwinds = Dict{Int, Vector{Wind}}()
    ywinds = Dict{Int, Vector{Wind}}()

    for y in eachindex(lines)
        for x in eachindex(lines[y])
            c = lines[y][x]
            I = CartesianIndex(x-1,y-1)
            if c == '<'
                wind = Wind(I,LEFT)
                push!(winds, wind)
                push!(get!(xwinds,y,Vector{Wind}()), wind)
            elseif c == '>'
                wind = Wind(I,RIGHT)
                push!(winds, wind)
                push!(get!(xwinds,y,Vector{Wind}()), wind)
            elseif c == '^'
                wind = Wind(I,UP)
                push!(winds, wind)
                push!(get!(ywinds,x,Vector{Wind}()), wind)
            elseif c == 'v'
                wind = Wind(I,DOWN)
                push!(winds, wind)
                push!(get!(ywinds,x,Vector{Wind}()), wind)
            end
        end
    end
    return (;winds, xwinds, ywinds, dims=CartesianIndex(length(lines[1])-2,length(lines)-2))
end

manhattanDistance(a,b) = manhattanSize(b-a)
manhattanSize(v::CartesianIndex) = manhattanSize(Tuple(v))
manhattanSize(numbers) = sum(numbers)

const MOVES = filter(c->c[1] == 0 || c[2] == 0, [CartesianIndex(x,y) for x in 1:-1:-1 for y in 1:-1:-1])

precalculateWinds((;winds,dims)) = precalculateWinds(winds, dims)
precalculateWinds(winds,dims) = precalculateWinds(winds, dims, lcm(Tuple(dims)...))
function precalculateWinds(winds, dims, rounds)
    result = fill(false, Tuple(dims)...,rounds)
    for wind in winds
        for round in 1:rounds
            position = mod1.(Tuple(wind.start + round * wind.direction), Tuple(dims))
            result[CartesianIndex(Tuple(position)...,round)] = true
        end
    end
    return result
end

w=precalculateWinds(parseMap(example2))
for round in 1:size(w,3)
    println("Round $(round)")
    for y in 1:size(w,2)
        for x in 1:size(w,1)
            print(w[x,y,round] ? "▒" : " ")
        end
        println()
    end
    println("-" ^ size(w,1))
end
#
#exit()

function occupied(winds, round, position)
    x = CartesianIndex(Tuple(position)...,mod1(round, size(winds, ndims(winds))))
    return !checkbounds(Bool, winds, x) || winds[Tuple(position)...,mod1(round, size(winds, ndims(winds)))]
end

cacheForWinds(winds) = Array{Union{Missing, NamedTuple{(:time,:path),Tuple{Union{Nothing,Int},Union{Nothing,Vector{CartesianIndex}}}}}}(missing, size(winds))

cacheHits = 0
cacheAttempts = 0

function timeToTarget(winds, round, targetPosition, position, best=*(size(winds)...), cache=cacheForWinds(winds))
    if position == targetPosition
        return (;time=0,path=[position])
    end

    if (!checkbounds(Bool, winds, CartesianIndex(Tuple(position)...,1)))
        return (;time=nothing,path=nothing)
    end

    #global cacheAttempts
    #global cacheHits
    #cacheAttempts += 1
    cachePosition = CartesianIndex(Tuple(position)...,mod1(round, size(cache, ndims(cache))))
    cached = cache[cachePosition]
    if !ismissing(cached)
        #cacheHits += 1
        #if cacheAttempts % 100_000 == 0
        #    println("Cache hits: $(cacheHits)/$(cacheAttempts)\t$((cacheHits*100) ÷ cacheAttempts)")
        #end
        return cached
    else
        result = doTimeToTarget(winds, round, targetPosition, position, best, cache)

        cache[cachePosition] = result

        return result
    end

end
function doTimeToTarget(winds, round, targetPosition, position, best=*(size(winds)...), cache=cacheForWinds(winds))
    if position == targetPosition
        return (;time=0,path=[position])
    end

    if (!checkbounds(Bool, winds, CartesianIndex(Tuple(position)...,1)))
        return (;time=nothing,path=nothing)
    end

    if best !== nothing && manhattanDistance(position, targetPosition) > best
        return (;time=nothing,path=nothing)
    end

    if occupied(winds, round, position)
        return (;time=nothing,path=nothing)
    end

    result = nothing
    resultPath = nothing
    for move in MOVES
        (;time,path) = timeToTarget(winds, round+1, targetPosition, position+move, best - 1, cache)
        if time !== nothing && (result === nothing || time < best)
            result = time + 1
            best = result
            resultPath = [position,path...]
        end
    end

    return (;time=result,path=resultPath)
end

function part1(lines)
    (;winds,dims) = parseMap(lines)
    winds = precalculateWinds(winds,dims)

    (;time, path) = timeToTarget(winds, 1, dims + CartesianIndex(0,1), CartesianIndex(1,1))
    @show time, path
    return time + 1
end

#@time @test part1(example1) == 9
@time @test part1(example2) == 18

println("Calculating...")
@time result = part1(input)
println(result)
