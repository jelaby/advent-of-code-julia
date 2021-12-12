#=
day11:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-11
=#

using AoC, Test, Memoize
using Random: shuffle

NEIGHBOURS = setdiff([CartesianIndex(i,j) for j in -1:1 for i in -1:1], [CartesianIndex(0,0)])
NOOP = (x...;y...)->nothing

function flash!(M, I, onUpdate=NOOP)
    onUpdate(M)
    for J in shuffle(NEIGHBOURS)
        if checkbounds(Bool, M, I+J) && M[I+J] <= 9
            M[I+J] += 1
            if M[I+J] > 9
                flash!(M, I+J, onUpdate)
            end
        end
    end
    return M
end

@test flash!([[1,2] [3,10]], CartesianIndex(2,2)) == [[2,3] [4,10]]
@test flash!([[1,2] [8,10]], CartesianIndex(2,2)) == [[2,3] [9,10]]
@test flash!([[1,2] [9,10]], CartesianIndex(2,2)) == [[3,4] [10,10]]

function round!(M, onUpdate=NOOP)
    for I in shuffle(CartesianIndices(M))
        if M[I] <= 9
            M[I] += 1
            onUpdate(M)
            if M[I] > 9
                flash!(M, I, onUpdate)
            end
        end
    end
    onUpdate(M; key=true)

    flashes = 0
    for I in eachindex(M)
        if M[I] > 9
            flashes += 1
            M[I] = 0
        end
    end

    return flashes
end

test1 = [[1,1,1,1,1] [1,9,9,9,1] [1,9,1,9,1] [1,9,9,9,1] [1,1,1,1,1]]
@test round!(test1) == 9
@test test1 == [[3,4,5,4,3] [4,0,0,0,4] [5,0,0,0,5] [4,0,0,0,4] [3,4,5,4,3]]

function rounds!(M, n, onUpdate=NOOP)
    flashes = 0
    for i in 1:n
        flashes += round!(M, onUpdate)
    end
    return flashes
end
@test rounds!(exampleIntMap(11,1), 1) == 0
@test rounds!(exampleIntMap(11,1), 2) == 35
@test rounds!(exampleIntMap(11,1), 3) == 35+45
@test rounds!(exampleIntMap(11,1), 10) == 204

function findBrightFlash(M, onUpdate=NOOP)
    round = 0
    while true
        round += 1
        flashes = round!(M, onUpdate)
        if flashes == length(M)
            return round
        end
    end
end

part1(M, onUpdate=NOOP) = rounds!(M, 100, onUpdate)
@test part1(exampleIntMap(11,1)) == 1656

part2(M,onUpdate=NOOP) = findBrightFlash(M, onUpdate)
@test part2(exampleIntMap(11,1)) == 195

intMap(11) |> m -> @time part1(m) |> show
intMap(11) |> m -> @time part2(m) |> show

using FileIO, ColorTypes, FixedPointNumbers

@memoize circle(r) = filter(I->I[1]^2 + I[2]^2<=r^2, [(i,j) for j in -r:r for i in -r:r]) .|> CartesianIndex

function writeImage(f, M, magnification, radius, flashRadius=radius)

    animation = zeros(RGB{N0f8}, (size(M) .* magnification .+ 1)..., 1000)
    frames = 0
    updates = 0

    octopus = circle(radius)
    flash = circle(flashRadius)

    function mapUpdate(M; key=false)
        updates += 1
        if !key && (updates % 20) != 0
            return
        end
        frames += 1
        if size(animation, 3) < frames
            newAnim = similar(animation, size(animation,1),size(animation,2),size(animation,3)*2)
            copyto!(newAnim, CartesianIndices(animation), animation, CartesianIndices(animation))
            animation = newAnim
        end
        frame = view(animation, :,:,frames)
        if flashRadius != radius
            for I in CartesianIndices(M)
                J = CartesianIndex(Tuple(I) .* magnification .+ 1 .- (magnification ÷ 2))
                if M[I] > 9
                    for K in flash
                        if checkbounds(Bool, frame, J+K)
                            frame[J+K] = 0.3
                        end
                    end
                end
            end
        end
        for I in CartesianIndices(M)
            J = CartesianIndex(Tuple(I) .* magnification .+ 1 .- (magnification ÷ 2))
            if M[I] <= 9
                for K in octopus
                    frame[J+K] = M[I]/20
                end
            else
                for K in octopus
                    frame[J+K] = 1.0
                end
            end
        end
    end

    f(M, mapUpdate)

    save("target/day11.gif", view(animation,:,:,1:frames))
end

writeImage((M,onUpdate)->rounds!(M,300,onUpdate), intMap(11), 20, 5, 15)