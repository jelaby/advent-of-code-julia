#=
day1:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2020-12-01
=#

import AoC

function countIncreases(depths::Vector{T}) where T
    return foldl((sum(depths[i:i+2]) for i in 1:length(depths)-2); init=(increases=0,prev=typemax(T))) do x,current
        return (increases=x.increases + (current > x.prev), prev=current)
    end |> r->r.increases
end

@show countIncreases(AoC.exampleInts(1,1))
@show countIncreases(AoC.ints(1))