#=
day1:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2020-12-01
=#

using AoC,Test

powerConsumption(lines) = gamma(lines) * epsilon(lines)

gamma(lines::AbstractArray{<:AbstractString}) = gamma([[c=='1' for c in line] for line in lines])
function gamma(lines::AbstractArray{<:AbstractArray{Bool}})
    total = zeros(Int, length(lines[1]))
    for line in  lines
        total += line
    end
    threshold = length(lines)/2
    return [b >= threshold for b in total] |> bb -> foldl(((g,b)->g*2+b), bb; init = 0)
end

epsilon(lines::Array{<:AbstractString}) = epsilon([[c=='1' for c in line] for line in lines])
function epsilon(lines::AbstractArray{<:AbstractArray{Bool}})
    @show lines
    total = zeros(Int, length(lines[1]))
    for line in  lines
        total += line
    end
    threshold = length(lines)/2
    return [b < threshold for b in total] |>( bb -> foldl(((g,b)->g*2+b), bb) )
end

lifeSupportRating(lines) = (@show oxygenGeneratorRating(lines)) * (@show co2ScrubberRating(lines))

oxygenGeneratorRating(lines::AbstractArray{<:AbstractString}) = oxygenGeneratorRating([[c=='1' for c in line] for line in lines])
function oxygenGeneratorRating(lines::AbstractArray{<:AbstractArray{Bool}})
    for bit in 1:length(lines[1])
        bitValue = gamma(lines) & (1<<(length(lines[1])-bit)) != 0
        lines = filter(l->l[bit] == bitValue, lines)
        if length(lines) == 1
            break
        end
    end
    return reduce((total,next)->total*2+next, lines[1])
end

@test oxygenGeneratorRating(exampleLines(3,1)) == 23

co2ScrubberRating(lines::AbstractArray{<:AbstractString}) = co2ScrubberRating([[c=='1' for c in line] for line in lines])
function co2ScrubberRating(lines)
    for bit in 1:length(lines[1])
        @show bitValue = epsilon(@show lines) & (1<<(length(lines[1])-bit)) != 0
        lines = filter(l->l[bit] == bitValue, lines)
        if (length(lines) == 1)
            break
        end
    end
    return reduce((total,next)->total*2+next, lines[1])
end

@test co2ScrubberRating(exampleLines(3,1)) == 10

@test lifeSupportRating(exampleLines(3,1)) == 230

show(exampleLines(3,1) |> ll -> @time powerConsumption(ll))
show(lines(3) |> ll -> @time powerConsumption(ll))
show(exampleLines(3,1) |> ll -> @time lifeSupportRating(ll))
show(lines(3) |> ll -> @time lifeSupportRating(ll))
