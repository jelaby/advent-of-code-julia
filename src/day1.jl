#=
day1:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2020-12-01
=#

import AoC
import Base.sum

function countIncreases(depths)
    increases = 0

    prev = nothing
    for current in (sum(depths[i:i+2]) for i in 1:length(depths)-2)
        if !isnothing(prev) && current > prev
            increases+=1
        end
        prev = current
    end
    return increases
end

@show countIncreases(AoC.exampleInts(1,1))
@show countIncreases(AoC.ints(1))