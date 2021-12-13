#=
day13:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-13
=#

using AoC, Test


parseCoordinate(line) = split(line,",") .|> c -> parse(Int, c)
@test parseCoordinate("12,56")==[12,56]

function parseFold(line)
    matches = match(r"fold along (.)=(.*)",line)
    return (matches.captures[1] == "x" ? 1 : 2, parse(Int, matches.captures[2]))
end
@test parseFold("fold along y=7") == (2,7)
@test parseFold("fold along x=5") == (1,5)

function parseFile(lines)
    dots = Set()
    folds = []

    mode = :dots
    for line in lines
        if line == ""
            mode = :folds
        elseif mode == :dots
            push!(dots, parseCoordinate(line))
        else
            push!(folds, parseFold(line))
        end
    end
    return (dots, folds)
end
@test parseFile(["3,4","5,6","","fold along x=7"]) == (Set([[3,4],[5,6]]), [(1,7)])

fold(dots, f) = fold(dots, f...)
function fold(dots, direction, location)
    result = Set()
    for dot in dots
        resultDot = [dot...]
        if dot[direction] > location
            resultDot[direction] = 2*location - dot[direction]
        end
        push!(result, resultDot)
    end
    return result
end
@test fold(Set([[3,5]]), (1,2)) == Set([[1,5],])
@test fold(Set([[3,5],(1,5)]), (1,2)) == Set([[1,5],])
@test fold(Set([[3,5]]), (1,4)) == Set([[3,5],])

function part1(lines)
    (dots, folds) = parseFile(lines)

    dots = fold(dots, folds[1])

    return length(dots)
end
@test part1(exampleLines(13,1)) == 17

using FileIO, ColorTypes, FixedPointNumbers

# do not transpose RGB
Base.transpose(x::RGB) = x

function part2(lines)
    (dots, folds) = parseFile(lines)

    for f in folds
        dots = fold(dots, f)
    end

    origin = CartesianIndex(1,1)

    image = zeros(RGB{N0f8}, max(get.(dots,1,0)...)+1, max(get.(dots,2,0)...)+1)
    for dot in dots
        image[CartesianIndex(dot...) + origin] = RGB(1,0,0)
    end

    image = transpose(image)

    for x in 1:size(image,1)
        line = ""
        for y in 1:size(image,2)
            line *= image[x,y] == RGB{N0f8}(0) ? "  " : "██"
        end
        println(line)
    end

    scale = 10
    image2 = similar(image, size(image).*scale)
    for I in CartesianIndices(image2)
        image2[I] = image[CartesianIndex(Tuple(I-origin) .÷ scale) + origin]
    end

    save("target/day13.gif", image2)
end
@test part1(exampleLines(13,1)) == 17

@show lines(13) |> ll -> @time part1(ll)

@time part2(lines(13))