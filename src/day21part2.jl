#=
day21part2:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-21
=#

using AoC, Test, Memoize




struct Universe{N}
    positions::NTuple{N, Int}
    scores::NTuple{N, Int}
end
Universe(positions) = Universe{length(positions)}(tuple(positions...), ntuple(_->0, length(positions)))
Universe(positions, scores) = Universe{length(positions)}(tuple(positions...), tuple(scores...))

@memoize function rolls(sides, dice)
    result = Dict{Int,Int}()
    for value in 1:sides
        if dice == 1
            result[value] = 1
        else
            for (otherValue, count) in rolls(sides, dice-1)
                result[value+otherValue] = get(result, value+otherValue, 0) + count
            end
        end
    end
    return result
end
@test rolls(6,1) == Dict(1=>1,2=>1,3=>1,4=>1,5=>1,6=>1)
@test rolls(2,1) == Dict(1=>1,2=>1)
@test rolls(2,2) == Dict(2=>1,3=>2,4=>1)
@test rolls(3,3) == Dict(5 => 6, 4 => 3, 6 => 7, 7 => 6, 9 => 1, 8 => 3, 3 => 1)

function incompleteUniverses(universes, targetScore)
    result = Dict{Universe, BigInt}()

    for (universe,count) in universes
        if max(universe.scores...) < targetScore
            result[universe] = count
        end
    end
    return result
end

function runround(universes, incomplete, player, squares, targetScore, sides, dice)

    for (universe,count) in incomplete
        universes[universe] -= count

        for (roll, rollCount) in rolls(sides, dice)
            positions = [universe.positions...]
            scores = [universe.scores...]

            positions[player] = mod1(positions[player] + roll, squares)
            scores[player] += positions[player]

            newUniverse = Universe(positions, scores)
            universes[newUniverse] = get(universes, newUniverse, 0) + count * rollCount
        end
    end

    for (universe, count) in universes
        if count == 0
            delete!(universes, universe)
        end
    end
end

function rungame(positions, squares, targetScore, sides, dice)
    player = 1

    universes = IdDict{Universe, BigInt}(Universe(positions)=>1)

    while true
        incomplete = incompleteUniverses(universes, targetScore)

        if isempty(incomplete)
            break
        end

        runround(universes, incomplete, player, squares, targetScore, sides, dice)

        player = mod1(player + 1, length(positions))
    end
    return universes
end

function winCounts(universes)
    result = Dict{Int, BigInt}()
    for (universe, count) in universes
        winner = argmax(p->universe.scores[p], 1:length(universe.scores))
        result[winner] = get(result, winner, big"0") + count
    end
    return result
end


@test winCounts(rungame([8,8], 10, 2, 2, 2)) == Dict{Int, BigInt}(1=>18, 2=>4)

function part2(positions; squares=10, targetScore=21, sides=3, dice=3)
    universes = rungame(positions, squares, targetScore, sides, dice)
    return max(values(winCounts(universes))...)
end

@test part2([4,8]; targetScore=1, sides=2, dice=1) == big"2"
@test part2([4,8]; targetScore=2, sides=2, dice=2) == big"4"
@test part2([9,4]; targetScore=2, sides=2, dice=1) == big"2"
@test part2([9,9]; targetScore=2, sides=2, dice=1) == big"3"
@test part2([8,8]; targetScore=2, sides=2, dice=2) == big"18"
@test part2([4,8]; targetScore=2, sides=3, dice=3) == big"183"
@test part2([4,8]) == big"444356092776315"

@show @time part2([7,5])
