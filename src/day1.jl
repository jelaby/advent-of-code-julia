#=
day1:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2020-12-01
=#

include("AoC.jl")

using Test

function elves(lines)
    result::Vector{Vector{Int}} = []

    elf::Vector{Int} = []
    for line in lines
        if line == ""
            push!(result, elf)
            elf = []
        else
            push!(elf, parse(Int, line))
        end
    end
    if !isempty(elf)
        push!(result, elf)
    end

    return result
end
@test elves(AoC.exampleLines(1,1)) == [[1000,2000,3000],[4000],[5000,6000],[7000,8000,9000],[10000]]

function mostStockedElf(elves)

    totals = sum.(elves)

    return max(totals...)
end
@test mostStockedElf(elves(AoC.exampleLines(1,1))) == 24000

function mostStockedElves(elves, n)

    totals = sort(sum.(elves), rev=true)

    return sum(totals[1:3])
end
@test mostStockedElves(elves(AoC.exampleLines(1,1)), 3) == 45000


show(AoC.exampleLines(1,1) |> x -> @time mostStockedElf(elves(x)))
show(AoC.lines(1) |> x -> @time mostStockedElf(elves(x)))
show(AoC.exampleLines(1,1) |> x -> @time mostStockedElves(elves(x),3))
show(AoC.lines(1) |> x -> @time mostStockedElves(elves(x),3))
