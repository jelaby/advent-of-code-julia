#=
day1:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2020-12-01
=#

import AoC

function countIncreases(depths)
    increases = 0
    prev=typemax(eltype(depths))
    for depth in depths
        if depth > prev
            increases += 1
        end
        prev = depth
    end
    return increases
end
function countIncreases2(depths)
    return countIncreases((sum(depths[i:i+2]) for i in 1:length(depths)-2))
end

show(AoC.exampleInts(1,1) |> x -> @time countIncreases(x))
show(AoC.ints(1) |> x -> @time countIncreases(x))
show(AoC.exampleInts(1,1) |> x -> @time countIncreases2(x))
show(AoC.ints(1) |> x -> @time countIncreases2(x))
