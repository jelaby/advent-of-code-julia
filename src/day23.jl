#=
day23:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-23
=#

using AoC, Test, Memoize, StructEquality

const PLAN=Char[
'#' '#' 'A' '#' 'B' '#' 'C' '#' 'D' '#' '#'
'#' '#' 'A' '#' 'B' '#' 'C' '#' 'D' '#' '#'
' ' ' ' 'x' ' ' 'x' ' ' 'x' ' ' 'x' ' ' ' '
]

const ALLOWED_TO_STOP=Bool[1,1,0,1,0,1,0,1,0,1,1]

const MOVEMENT_COSTS=Dict('A'=>1,'B'=>10,'C'=>100,'D'=>1000)

const TARGET_ROOMS=['A','B','C','D']

const ROOM_X_POSITIONS=[3,5,7,9]
const CORRIDOR_Y_POSITION = 3

const X = 2
const Y = 1

testInitial = [
'#' '#' 'B' '#' 'C' '#' 'D' '#' 'C' '#' '#'
'#' '#' 'A' '#' ' ' '#' 'D' '#' 'B' '#' '#'
'A' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
]

@def_structequal struct Move
    finalState::Array{Char,2}
    cost::Int
end

function Base.show(io::IO, m::Array{Char, 2})
    for y in size(m,1):-1:1
        println(io)
        for x in 1:size(m,2)
            print(io, m[y,x])
        end
    end
end

isamphipod(c::Char) = c=='A' || c=='B' || c=='C' || c=='D'

const UP=CartesianIndex(1,0)
const DOWN=CartesianIndex(-1,0)
const LEFT=CartesianIndex(0,-1)
const RIGHT=CartesianIndex(0,1)

costFor(type, initialPosition, finalPosition) = MOVEMENT_COSTS[type] * ((3-initialPosition[Y]) + (3-finalPosition[Y]) + abs(finalPosition[X] - initialPosition[X]))
@test costFor('A', CartesianIndex(3,5), CartesianIndex(3,6)) == 1
@test costFor('C', CartesianIndex(3,5), CartesianIndex(3,6)) == 100
@test costFor('A', CartesianIndex(2,5), CartesianIndex(2,7)) == 4
@test costFor('C', CartesianIndex(2,5), CartesianIndex(2,7)) == 400
@test costFor('A', CartesianIndex(1,5), CartesianIndex(2,7)) == 5
@test costFor('C', CartesianIndex(1,5), CartesianIndex(2,7)) == 500
@test costFor('A', CartesianIndex(1,5), CartesianIndex(1,7)) == 6
@test costFor('C', CartesianIndex(1,5), CartesianIndex(1,7)) == 600

function moveFor(initial, type, initialPosition, finalPosition)
    final = copy(initial)
    final[initialPosition] = ' '
    final[finalPosition] = type
    cost = costFor(type, initialPosition, finalPosition)
    return Move(final, cost)
end
@test moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(3,11)) == Move([
'#' '#' 'B' '#' 'C' '#' 'D' '#' 'C' '#' '#'
'#' '#' 'A' '#' ' ' '#' 'D' '#' ' ' '#' '#'
'A' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' 'B'
], 30)

function potentialCorridorMoves!(result, initial, type, initialPosition, position, direction)
    P = position + direction
    while P[X]>=1 && P[X]<=size(initial, X)
        if PLAN[P] == ' ' && initial[P] == ' '
            push!(result, moveFor(initial, type, initialPosition, P))
        elseif PLAN[P] == 'x'
            if PLAN[1,P[X]] == type
                if initial[1,P[X]] == ' '
                    push!(result, moveFor(initial, type, initialPosition, CartesianIndex(1,P[X])))
                elseif initial[2,P[X]] == ' '
                    push!(result, moveFor(initial, type, initialPosition, CartesianIndex(2,P[X])))
                end
            end
        else
            #blocked by another amphipod
            break
        end
        P += direction
    end
end

function potentialCorridorMoves(initial, type, initialPosition, position)::Array{Move}
    result = Move[]
    potentialCorridorMoves!(result, initial, type, initialPosition, position, LEFT)
    potentialCorridorMoves!(result, initial, type, initialPosition, position, RIGHT)
    sort!(result; by=m->m.cost)
    return result
end
@test potentialCorridorMoves(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(3,9)) == [
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(3,8)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(3,10)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(3,11)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(3,6)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(2,5)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(3,4)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(3,2)),
]


function potentialMoves(initial, I)::Array{Move}
    type = initial[I]
    if I[Y] < 3
        # move up out of burrow
        if I[Y] == 1
            if initial[I+UP] != ' '
                return []
            end
        end

        position = CartesianIndex(3,I[X])
        return potentialCorridorMoves(initial, type, I, position)
    else
        return potentialCorridorMoves(initial, type, I, I)
    end
end

function potentialMoves(initial)
    result=Move[]
    for I in CartesianIndices(initial)
        if isamphipod(initial[I])
            append!(result, potentialMoves(initial, I))
        end
    end
    return result
end

function iscomplete(state)
    for x in ROOM_X_POSITIONS
        for y in 1:2
            if state[y,x]!=PLAN[y,x]
                return false
            end
        end
    end
    return true
end

function costToReorganise(initial, precalculations=Dict{Array{Char,2}, Union{Int,Nothing}}())
    if haskey(precalculations, initial)
        return precalculations[initial]
    end
    precalculations[initial] = nothing

    best = nothing
    moves = potentialMoves(initial)
    for move in moves
        if iscomplete(move.finalState)
            @show :complete, move.cost
            if isnothing(best) || move.cost < best
                best = move.cost
            end
        else
            resultingCost = costToReorganise(move.finalState, precalculations)
            if resultingCost !== nothing && (best === nothing || move.cost + resultingCost < best)
                best = move.cost + resultingCost
            end
        end
    end
    precalculations[initial] = best
    return best
end

@test costToReorganise([
'#' '#' 'A' '#' 'D' '#' 'C' '#' 'A' '#' '#'
'#' '#' 'B' '#' 'C' '#' 'B' '#' 'D' '#' '#'
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
]) == 12521

@show @time costToReorganise([
'#' '#' 'B' '#' 'D' '#' 'A' '#' 'B' '#' '#'
'#' '#' 'A' '#' 'C' '#' 'C' '#' 'D' '#' '#'
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
])