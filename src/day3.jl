#=
day1:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2020-12-01
=#

using AoC

function powerConsumption(lines)
    total = zeros(length(lines[1]))
    for line in  lines .|> (line -> [c=='1' ? 1 : 0 for c in line])
        total += line
    end
    @show total
    @show threshold = length(lines)/2
    @show gamma = [b > threshold for b in total] |>( bb -> foldl(((g,b)->g*2+b), bb) )
    @show epsilon = [b < threshold for b in total] |>( bb -> foldl(((g,b)->g*2+b), bb) )
    return gamma * epsilon
end


show(exampleLines(3,1) |> ll -> @time powerConsumption(ll))
show(lines(3) |> ll -> @time powerConsumption(ll))
