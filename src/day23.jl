#=
day23:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-23
=#

using AoC, Test, Memoize, StructEquality, DataStructures, Profile

const Burrow = Array{Char,2}

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

testInitial2 = [
'A' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'#' '#' 'A' '#' 'D' '#' ' ' '#' 'B' '#' '#'
'#' '#' 'B' '#' 'C' '#' 'D' '#' 'C' '#' '#'
]

@def_structequal struct Move
    finalState::Array{Char,2}
    cost::Int
end

function Base.show(io::IO, m::Array{Char, 2})
    for y in 1:size(m,1)
        y > 1 && print(io, "/")
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

function potentialCorridorMoves(initial, plan, type, initialPosition, position, direction)
    P = position + direction
    while P[X]>=1 && P[X]<=size(initial, X)
        if plan[P] == ' ' && initial[P] == ' '
        elseif plan[P] == 'x'
            if plan[end,P[X]] == type
                for y in lastindex(initial,1):-1:2
                    if initial[y,P[X]] == ' '
                        return (Move[moveFor(initial, type, initialPosition, CartesianIndex(y,P[X]))], true)
                    end
                end
            end
        else
            #blocked by another amphipod
            break
        end
        P += direction
    end

    result = Move[]
    P = position + direction
    while P[X]>=1 && P[X]<=size(initial, X)
        if plan[P] == ' ' && initial[P] == ' '
            push!(result, moveFor(initial, type, initialPosition, P))
        elseif plan[P] == 'x'
        else
            #blocked by another amphipod
            break
        end
        P += direction
    end
    return (result, false)
end

function potentialCorridorMoves(initial, plan, type, initialPosition, position)::Array{Move}
    result = Move[]
    (result,final) = potentialCorridorMoves(initial, plan, type, initialPosition, position, LEFT)
    if final
        return result
    end
    (more,final) = potentialCorridorMoves(initial, plan, type, initialPosition, position, RIGHT)
    if final
        return more
    end
    append!(result, more)
    return result
end
@test potentialCorridorMoves(testInitial, PLAN2, 'B', CartesianIndex(2,9), CartesianIndex(1,9)) == [
    moveFor(testInitial, 'B', CartesianIndex(2,9), CartesianIndex(2,5)),
]
@test sort(potentialCorridorMoves(testInitial2, PLAN2, 'B', CartesianIndex(2,9), CartesianIndex(1,9)); by=m->m.cost) == sort([
    moveFor(testInitial2, 'B', CartesianIndex(2,9), CartesianIndex(1,8)),
    moveFor(testInitial2, 'B', CartesianIndex(2,9), CartesianIndex(1,10)),
    moveFor(testInitial2, 'B', CartesianIndex(2,9), CartesianIndex(1,11)),
    moveFor(testInitial2, 'B', CartesianIndex(2,9), CartesianIndex(1,6)),
    moveFor(testInitial2, 'B', CartesianIndex(2,9), CartesianIndex(1,4)),
    moveFor(testInitial2, 'B', CartesianIndex(2,9), CartesianIndex(1,2)),
]; by=m->m.cost)


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

function addState!(stateCosts::SC, costStates::CS, state, cost) where SC<:AbstractDict{Burrow, Int} where CS<:AbstractDict{Int, Set{Burrow}}
    if haskey(stateCosts, state); throw(ArgumentError("Cannot add " * string(state) * "/" * string(cost) * " to " * string(stateCosts) * " as it is already present")); end
    stateCosts[state] = cost
    statesWithThisCost = get!(()->Set{Burrow}(), costStates, cost)
    push!(statesWithThisCost, state)
end

function popLastState!(stateCosts, costStates)
    (cost, states) = last(costStates)
    state = first(states)
    removeState!(stateCosts, costStates, state)
    return (state, cost)
end

function popFirstState!(stateCosts, costStates)
    (cost, states) = first(costStates)
    state = first(states)
    removeState!(stateCosts, costStates, state)
    return (state, cost)
end

function removeState!(stateCosts, costStates, state)
    if !haskey(stateCosts, state); throw(ArgumentError("Cannot remove " * string(state) * " from " * string(stateCosts) * " as it is not present")); end
    cost = pop!(stateCosts, state, nothing)
    if !isnothing(cost)
        statesWithCost = costStates[cost]
        pop!(statesWithCost, state)
        if isempty(statesWithCost)
            pop!(costStates, cost)
        end
    end
end

function addOrReplaceState!(stateCosts, costStates, state, newCost)
    if haskey(stateCosts, state)
        removeState!(stateCosts, costStates, state)
    end
    addState!(stateCosts, costStates, state, newCost)
end

function costToReorganise(initial, plan)
    stateCosts = Dict{Burrow, Int}()
    costStates = SortedDict{Int, Set{Burrow}}()

    newStateCosts = Dict{Burrow, Int}()
    newCostStates = SortedDict{Int, Set{Burrow}}()

    addState!(stateCosts, costStates, initial, 0)
    addState!(newStateCosts, newCostStates, initial, 0)

    best = typemax(Int)

    pass = 0

    while !isempty(newStateCosts)
        if pass > 10000
            @show length(newStateCosts), length(stateCosts)
            pass = 0
        end
        pass += 1

        (mostExpensiveState, mostExpensiveCost) = popFirstState!(newStateCosts, newCostStates)

        if mostExpensiveCost >= best
            # discard - already slower than the best
        elseif get(stateCosts, mostExpensiveState, typemax(Int)) < mostExpensiveCost
            # discard - already reached this state more quickly
        elseif iscomplete(mostExpensiveState, plan)
            @show :complete, mostExpensiveState, mostExpensiveCost
            # this is the best cost for completion
            best = mostExpensiveCost
        else
            moves = potentialMoves(mostExpensiveState, plan)

            producedNewStates = false

            for move in moves
                newTotalCost = mostExpensiveCost + move.cost

                if newTotalCost < best

                    existingCost = get(stateCosts, move.finalState, typemax(Int))

                    if newTotalCost < existingCost
                        addOrReplaceState!(newStateCosts, newCostStates, move.finalState, newTotalCost)
                        addOrReplaceState!(stateCosts, costStates, move.finalState, newTotalCost)
                    end

                end
            end
        end
    end
    return best
end

@test costToReorganise([
' ' ' ' ' ' ' ' ' '
'#' 'B' '#' 'A' '#'
],[
' ' 'x' ' ' 'x' ' '
'#' 'A' '#' 'B' '#'
]) == 46

println("costToReorganise test complete")

@test costToReorganise([
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'#' '#' 'B' '#' 'C' '#' 'B' '#' 'D' '#' '#'
'#' '#' 'A' '#' 'D' '#' 'C' '#' 'A' '#' '#'
], PLAN1) == 12521

@show @time Profile.@profile costToReorganise([
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'#' '#' 'A' '#' 'C' '#' 'C' '#' 'D' '#' '#'
'#' '#' 'B' '#' 'D' '#' 'A' '#' 'B' '#' '#'
], PLAN1)
Profile.print()

#@test costToReorganise([
#' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
#'#' '#' 'B' '#' 'C' '#' 'B' '#' 'D' '#' '#'
#'#' '#' 'D' '#' 'C' '#' 'B' '#' 'A' '#' '#'
#'#' '#' 'D' '#' 'B' '#' 'A' '#' 'C' '#' '#'
#'#' '#' 'A' '#' 'D' '#' 'C' '#' 'A' '#' '#'
#], PLAN2) == 44169

@show @time costToReorganise([
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'#' '#' 'A' '#' 'C' '#' 'C' '#' 'D' '#' '#'
'#' '#' 'D' '#' 'C' '#' 'B' '#' 'A' '#' '#'
'#' '#' 'D' '#' 'B' '#' 'A' '#' 'C' '#' '#'
'#' '#' 'B' '#' 'D' '#' 'A' '#' 'B' '#' '#'
], PLAN2)
