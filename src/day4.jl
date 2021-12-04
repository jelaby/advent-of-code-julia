#=
day4:
- Julia version: 1.5.2
- Author: Paul.Mealor
- Date: 2021-12-04
=#

using AoC, Test

using Base.Iterators: flatten




function createGame(lines)
    numbers = split(lines[1],",") .|> n->parse(Int, n)
    lines = lines[2:end]
    cards = Array{Int}(undef, 5,5,0)
    for line in 1:6:length(lines)
        card = flatten(lines[line+1:line+5] .|> strip .|> (l -> split(l, r" +")))
        card = parse.(Int, card) |> nn -> reshape(nn, 5,5)
        cards = cat(cards,card; dims=3)
    end
    return (numbers, cards)
end

function calcResult(number, card, ticks)
    return number * sum(filter(i->!ticks[i], eachindex(ticks)) .|> i->card[i])
end

function isWinner(card, ticks)
    for j in 1:size(card, 2)
        if reduce(&, ticks[:,j])
            return true
        end
    end
    for j in 1:size(card, 1)
        if reduce(&, ticks[j,:])
            return true
        end
    end
    return false
end


function bingoGame(lines)
    (numbers,cards) = createGame(lines)

    ticks = zeros(Bool, size(cards))

    winningCards = []
    results = []

    for number in numbers
        for i in setdiff(1:size(cards,3), winningCards)
            card=view(cards, :,:,i)
            cardTicks=view(ticks, :,:,i)
            for j in eachindex(card)
                if card[j] == number
                    cardTicks[j] = true
                end
            end

            if isWinner(card, cardTicks)
                push!(results, (number, card, cardTicks))
                push!(winningCards,i)
            end
        end
    end
    return results
end

part1(lines) = bingoGame(lines)[1] |> result -> calcResult(result...)
part2(lines) = bingoGame(lines)[end] |> result -> calcResult(result...)

@test part1(exampleLines(4,1)) == 4512
@test part2(exampleLines(4,1)) == 1924

lines(4) |> ll -> @time part1(ll) |> show
lines(4) |> ll -> @time part2(ll) |> show
