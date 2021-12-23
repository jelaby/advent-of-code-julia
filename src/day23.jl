#=
day23:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-23
=#

using AoC, Test, Memoize, StructEquality

const PLAN1=Char[
' ' ' ' 'x' ' ' 'x' ' ' 'x' ' ' 'x' ' ' ' '
'#' '#' 'A' '#' 'B' '#' 'C' '#' 'D' '#' '#'
'#' '#' 'A' '#' 'B' '#' 'C' '#' 'D' '#' '#'
]

const PLAN2=Char[
' ' ' ' 'x' ' ' 'x' ' ' 'x' ' ' 'x' ' ' ' '
'#' '#' 'A' '#' 'B' '#' 'C' '#' 'D' '#' '#'
'#' '#' 'A' '#' 'B' '#' 'C' '#' 'D' '#' '#'
'#' '#' 'A' '#' 'B' '#' 'C' '#' 'D' '#' '#'
'#' '#' 'A' '#' 'B' '#' 'C' '#' 'D' '#' '#'
]

const ALLOWED_TO_STOP=Bool[1,1,0,1,0,1,0,1,0,1,1]

const MOVEMENT_COSTS=Dict('A'=>1,'B'=>10,'C'=>100,'D'=>1000)

const TARGET_ROOMS=['A','B','C','D']

const ROOM_X_POSITIONS=[3,5,7,9]
const CORRIDOR_Y_POSITION = 1

const X = 2
const Y = 1

testInitial = [
'A' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'#' '#' 'A' '#' ' ' '#' 'D' '#' 'B' '#' '#'
'#' '#' 'B' '#' 'C' '#' 'D' '#' 'C' '#' '#'
]

@def_structequal struct Move
    finalState::Array{Char,2}
    cost::Int
end

function Base.show(io::IO, m::Array{Char, 2})
    for y in 1:size(m,1)
        println(io)
        for x in 1:size(m,2)
            print(io, m[y,x])
        end
    end
end

isamphipod(c::Char) = c=='A' || c=='B' || c=='C' || c=='D'

const UP=CartesianIndex(-1,0)
const DOWN=CartesianIndex(1,0)
const LEFT=CartesianIndex(0,-1)
const RIGHT=CartesianIndex(0,1)

costFor(type, initialPosition, finalPosition) = MOVEMENT_COSTS[type] * ((initialPosition[Y]-CORRIDOR_Y_POSITION) + (finalPosition[Y]-CORRIDOR_Y_POSITION) + abs(finalPosition[X] - initialPosition[X]))
@test costFor('A', CartesianIndex(1,5), CartesianIndex(1,6)) == 1
@test costFor('C', CartesianIndex(1,5), CartesianIndex(1,6)) == 100
@test costFor('A', CartesianIndex(2,5), CartesianIndex(2,7)) == 4
@test costFor('C', CartesianIndex(2,5), CartesianIndex(2,7)) == 400
@test costFor('A', CartesianIndex(5,5), CartesianIndex(2,7)) == 7
@test costFor('C', CartesianIndex(5,5), CartesianIndex(2,7)) == 700
@test costFor('A', CartesianIndex(5,5), CartesianIndex(5,7)) == 10
@test costFor('C', CartesianIndex(5,5), CartesianIndex(5,7)) == 1000

function moveFor(initial, type, initialPosition, finalPosition)
    final = copy(initial)
    final[initialPosition] = ' '
    final[finalPosition] = type
    cost = costFor(type, initialPosition, finalPosition)
    return Move(final, cost)
end
@test moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(1,11)) == Move([
'A' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' 'B'
'#' '#' 'A' '#' ' ' '#' 'D' '#' ' ' '#' '#'
'#' '#' 'B' '#' 'C' '#' 'D' '#' 'C' '#' '#'
], 30)

function potentialCorridorMoves!(result, initial, plan, type, initialPosition, position, direction)
    P = position + direction
    while P[X]>=1 && P[X]<=size(initial, X)
        if plan[P] == ' ' && initial[P] == ' '
            push!(result, moveFor(initial, type, initialPosition, P))
        elseif plan[P] == 'x'
            if plan[end,P[X]] == type
                for y in lastindex(initial,1):-1:2
                    if initial[y,P[X]] == ' '
                        push!(result, moveFor(initial, type, initialPosition, CartesianIndex(y,P[X])))
                        break
                    end
                end
            end
        else
            #blocked by another amphipod
            break
        end
        P += direction
    end
end

function potentialCorridorMoves(initial, plan, type, initialPosition, position)::Array{Move}
    result = Move[]
    potentialCorridorMoves!(result, initial, plan, type, initialPosition, position, LEFT)
    potentialCorridorMoves!(result, initial, plan, type, initialPosition, position, RIGHT)
    sort!(result; by=m->m.cost)
    return result
end
@test potentialCorridorMoves(testInitial, PLAN2, 'B', CartesianIndex(2,9), CartesianIndex(1,9)) == [
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(1,8)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(1,10)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(1,11)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(1,6)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(2,5)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(1,4)),
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(1,2)),
]


function potentialMoves(initial, plan, I)::Array{Move}
    type = initial[I]
    if I[Y] != CORRIDOR_Y_POSITION
        # move up out of burrow
        for y in I[Y]-1:-1:CORRIDOR_Y_POSITION
            if initial[y, I[X]] != ' '
                return []
            end
        end

        position = CartesianIndex(CORRIDOR_Y_POSITION,I[X])
        return potentialCorridorMoves(initial, plan, type, I, position)
    else
        return potentialCorridorMoves(initial, plan, type, I, I)
    end
end

function potentialMoves(initial, plan)
    result=Move[]
    for I in CartesianIndices(initial)
        if isamphipod(initial[I])
            append!(result, potentialMoves(initial, plan, I))
        end
    end
    return result
end

function iscomplete(state, plan)
    for I in CartesianIndices(plan)
        if state[I] != plan[I] && plan[I] != 'x'
            return false
        end
    end
    return true
end

function costToReorganise(initial, plan, precalculations=Dict{Array{Char,2}, Int}(), limit=typemax(Int))
    if limit <= 0
        return typemax(Int)
    end
    if haskey(precalculations, initial)
        return precalculations[initial]
    end
    precalculations[initial] = typemax(Int)

    best = typemax(Int)
    moves = potentialMoves(initial, plan)
    for move in moves
        if iscomplete(move.finalState, plan)
            if move.cost < best
                best = move.cost
            end
        else
            resultingCost = costToReorganise(move.finalState, plan, precalculations, best-move.cost)
            if resultingCost !== nothing && resultingCost < best - move.cost
                best = move.cost + resultingCost
            end
        end
    end
    precalculations[initial] = best
    return best
end

@test costToReorganise([
' ' ' ' ' ' ' ' ' '
'#' 'B' '#' 'A' '#'
],[
' ' 'x' ' ' 'x' ' '
'#' 'A' '#' 'B' '#'
]) == 46

@test costToReorganise([
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'#' '#' 'B' '#' 'C' '#' 'B' '#' 'D' '#' '#'
'#' '#' 'A' '#' 'D' '#' 'C' '#' 'A' '#' '#'
], PLAN1) == 12521

@show @time costToReorganise([
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'#' '#' 'A' '#' 'C' '#' 'C' '#' 'D' '#' '#'
'#' '#' 'B' '#' 'D' '#' 'A' '#' 'B' '#' '#'
], PLAN1)

@test costToReorganise([
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'#' '#' 'B' '#' 'C' '#' 'B' '#' 'D' '#' '#'
'#' '#' 'D' '#' 'C' '#' 'B' '#' 'A' '#' '#'
'#' '#' 'D' '#' 'B' '#' 'A' '#' 'C' '#' '#'
'#' '#' 'A' '#' 'D' '#' 'C' '#' 'A' '#' '#'
], PLAN2) == 44169

@show @time costToReorganise([
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'#' '#' 'A' '#' 'C' '#' 'C' '#' 'D' '#' '#'
'#' '#' 'D' '#' 'C' '#' 'B' '#' 'A' '#' '#'
'#' '#' 'D' '#' 'B' '#' 'A' '#' 'C' '#' '#'
'#' '#' 'B' '#' 'D' '#' 'A' '#' 'B' '#' '#'
], PLAN2)
