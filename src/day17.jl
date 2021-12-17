#=
day17:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-17
=#

using Test, AoC




function launch(v, target)
    p = [0,0]
    maxHeight = p[2]
    while p[1] <= target[1,2] && p[2] >= target[2,1]
        if p[2] > maxHeight
            maxHeight = p[2]
        end
        if target[1,1] <= p[1] <= target[1,2] && target[2,1] <= p[2] <= target[2,1]
            return maxHeight
        end
        p = p + v
        v[2] -= 1
        v[1] -= sign(v[1])
    end
    return false
end
#@test launch([17,-4], [[20, -10] [30, -5]]) == false
#@test launch([7,2], [[20, -10] [30, -5]]) == 3
#@test launch([6,3], [[20, -10] [30, -5]]) == 6
@test launch([6,9], [[20, -10] [30, -5]]) == 45

function part1(target)
    maxHeight = 0
    for v_x ∈ 1:target[1,2]
        for v_y ∈ 1:-target[2,1]-1
            height = launch([v_x,v_y], target)
            if height > maxHeight
                @show maxHeight = height
            end
        end
    end
    return maxHeight
end



@test part1([[20, -10] [30, -5]]) == 45



@show part1([[96, -144] [125,-98]])