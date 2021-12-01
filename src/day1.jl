#=
day1:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2020-12-01
=#

import AoC

function countIncreases(depths)
    increases = 0
    prev = depths[begin]
    for depth in depths[begin+1:end]
        if depth > prev
            increases+=1
        end
        prev = depth
    end
    return increases
end

@show countIncreases(AoC.exampleInts(1,1))
@show countIncreases(AoC.ints(1))