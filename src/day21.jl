#=
day21:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-21
=#

using AoC, Test

mutable struct Die
    next::Int
    max::Int
    rolls::Int
end
Die() = Die(1,100,0)

function roll!(die::Die)
    result = die.next
    die.next = mod1(die.next+1, die.max)
    die.rolls += 1
end

rolls(die::Die) = die.rolls



function rungame(positions, die, squares, targetScore)
    player = 1
    positions = [positions...]
    scores = zeros(length(positions))

    while max(scores...) < targetScore
        positions[player] = mod1(positions[player] + roll!(die) + roll!(die) + roll!(die), squares)
        scores[player] += positions[player]
        player = mod1(player + 1, length(positions))
    end
    return (positions, scores, die)
end

function part1(positions)
    (positions, scores, die) = rungame(positions, Die(), 10, 1000)
    return min(scores...) * rolls(die)
end

@test part1([4,8]) == 739785

@show @time part1([7,5])