#=
day20:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-20
=#

using AoC, Test

lineToBools(line) = BitVector([c == '#' for c in line])

function parseImage(lines)
    result = nothing

    for line in lines
        row = lineToBools(line)

        result = result===nothing ? row : hcat(result, row)
    end

    return result
end

parseLines(lines) = (lineToBools(lines[1]), parseImage(lines[3:end]))

@test parseLines(["#..#.#.","","##..","#..#","...#","#..."]) == (Bool[1,0,0,1,0,1,0], Bool[[1,1,0,0] [1,0,0,1] [0,0,0,1] [1,0,0,0]])




function embiggen(image, border)
    largeImage = fill!(similar(image, size(image) .+ 2*border), zero(eltype(image)))
    copyto!(largeImage, CartesianIndices((border+1:border+size(image,1), border+1:border+size(image,2))), image, CartesianIndices(image))
    return largeImage
end
@test embiggen(Bool[[1,0,1] [1,1,1] [1,0,0]], 2) == Bool[[0,0,0,0,0,0,0] [0,0,0,0,0,0,0] [0,0,1,0,1,0,0] [0,0,1,1,1,0,0] [0,0,1,0,0,0,0] [0,0,0,0,0,0,0] [0,0,0,0,0,0,0]]

function enhancePixel(pixels, indices, algo, infinity)
    index = 0
    for I in indices
        index = index * 2 + get(pixels, I, infinity)
    end
    return algo[index+1]
end
@test enhancePixel(Bool[[0,0,0] [0,0,0] [0,0,0]], CartesianIndices((1:3,1:3)), Bool[0,0,1,1,0], 0) == false
@test enhancePixel(Bool[[0,0,0] [0,0,0] [0,0,1]], CartesianIndices((1:3,1:3)), Bool[0,0,1,1,0], 0) == false
@test enhancePixel(Bool[[0,0,0] [0,0,0] [0,1,0]], CartesianIndices((1:3,1:3)), Bool[0,0,1,1,0], 0) == true
@test enhancePixel(Bool[[0,0,0] [0,0,0] [0,1,1]], CartesianIndices((1:3,1:3)), Bool[0,0,1,1,0], 0) == true
@test enhancePixel(Bool[[0,0,0] [0,0,0] [1,0,0]], CartesianIndices((1:3,1:3)), Bool[0,0,1,1,0], 0) == false

function enhance!(target, prev, algo, infinity)

    for I in CartesianIndices(prev)
        target[I] = enhancePixel(prev, CartesianIndices((I[1]-1:I[1]+1, I[2]-1:I[2]+1)), algo, infinity)
    end

    return target
end

function enhance(algo, image, n)
    image = embiggen(image, n+1)

    prev = similar(image)
    target = image

    infinity = false

    for pass in 1:n
        target, prev = prev, target
        enhance!(target, prev, algo, infinity)

        infinity = algo[(infinity ? 0b111111111 : 0)+1]
    end

    return target
end

function showImage(image)
    for row in eachcol(image)
        for b in row
            print(b ? "#" : ".")
        end
        println()
    end
end

function part1(lines; passes=2)
    (algo, image) = parseLines(lines)

    finalImage = enhance(algo, image, passes)

    return count(finalImage)
end


@test part1(exampleLines(20,1); passes=0) == 10
@test part1(exampleLines(20,1); passes=1) == 24
@test part1(exampleLines(20,1)) == 35
@test part1(exampleLines(20,1); passes=50) == 3351

@show lines(20) |> ll -> @time part1(ll)
@show lines(20) |> ll -> @time part1(ll; passes=50)
