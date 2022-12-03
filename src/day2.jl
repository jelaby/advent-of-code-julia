#=
day2:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-02
=#
include("AoC.jl")

using Test

scores = Dict(:rock=>1, :paper=>2, :scissors=>3)
decoder1 = Dict("A"=>:rock, "B"=>:paper, "C"=>:scissors)
decoder2 = Dict("X"=>:rock, "Y"=>:paper, "Z"=>:scissors)

winners = Set([(:rock,:scissors),(:paper,:rock),(:scissors,:paper)])

iswinner(a,b) = (a,b) ∈ winners
@test iswinner(:rock,:paper) == false
@test iswinner(:paper,:rock) == true

score(a::Tuple{Symbol,Symbol}) = score(a...)
score(a,b) = scores[b] + ( iswinner(b,a) ? 6 : ( iswinner(a,b) ? 0 : 3 ) )
@test score(:rock, :scissors) == 3
@test score(:rock, :paper) == 8
@test score((:rock, :scissors)) == 3
@test score((:rock, :paper)) == 8
@test score((:rock, :rock)) == 4

game(lines::Vector{<:AbstractString}) = game(split.(lines) .|> pair -> (decoder1[pair[1]], decoder2[pair[2]]))
game(rounds::Vector{Tuple{Symbol,Symbol}}) = sum(score.(rounds))
@test game([(:rock, :paper)]) == 8
@test game([(:rock, :scissors)]) == 3
@test game([(:scissors, :scissors)]) == 6
@test game( [ (:rock, :paper), (:scissors, :paper) ] ) == 10

@test game(["A Y"]) == 8
@test game(["B X"]) == 1
@test game(["C Z"]) == 6
@test game(AoC.exampleLines(2,1)) == 15

show(AoC.lines(2) |> x -> @time game(x))

moves = [:rock, :paper, :scissors]

lose(opponent) = moves[findfirst(moves) do move
    iswinner(opponent, move)
end]
draw(opponent) = moves[findfirst(moves) do move
    !iswinner(opponent, move) && !iswinner(move, opponent)
end]
win(opponent) = moves[findfirst(moves) do move
    iswinner(move, opponent)
end]

outcomeDecoder = Dict("X" => lose, "Y" => draw, "Z" => win)
decodeOutcome(code)::Function = outcomeDecoder[code]

move(opponent, outcome) =  outcome(opponent)

score2(a::Tuple) = score2(a...)
score2(opponent, outcome) = score(opponent, outcome(opponent))

game2(lines::Vector{<:AbstractString}) = game(split.(lines) .|> (pair -> (decoder1[pair[1]], decodeOutcome(pair[2]))) .|> (pair -> (pair[1], pair[2](pair[1]))))
game2(rounds::Vector{Tuple{Symbol, <:Function}}) = sum(score2.(rounds))

@test game2(["A Y"]) == 4
@test game2(["B X"]) == 1
@test game2(["C Z"]) == 7
@test game2(AoC.exampleLines(2,1)) == 12

show(AoC.lines(2) |> x -> @time game2(x))
