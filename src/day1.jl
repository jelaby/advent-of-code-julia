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
    prev = sum(depths[begin:begin+2])
    for start in eachindex(depths)[begin+1:end-2]
        window = sum(depths[start:start+2])
        if window > prev
            increases+=1
        end
        prev = window
    end
    return increases
end

@show countIncreases(AoC.exampleInts(1,1))
@show countIncreases(AoC.ints(1))