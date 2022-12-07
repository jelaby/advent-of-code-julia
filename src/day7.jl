#=
day3:
- Julia version: 1.8.3
- Author: Paul.Mealor
- Date: 2022-12-05
=#
using Test

lines = open(readlines, "src/day7-input.txt")
example1 = open(readlines, "src/day7-example-1.txt")

abstract type Node
end

struct Dir <: Node
    name::String
    parent::Union{Dir,Nothing}
    children::Dict{String, Node}
end
Dir(name) = Dir(name, nothing, Dict())
Dir(name, parent) = Dir(name, parent, Dict())

struct File <: Node
    name::String
    size::Int
end

function parseInput(lines)

    root = Dir("/")
    pwd = root
    mode = :command

    for line in lines

        if !isnothing(match(r"^\$\s*cd\s+\.\.", line))

            mode=:command
            pwd = pwd.parent

        elseif !isnothing(match(r"^\$\s*cd\s+/", line))

            mode=:command
            pwd = root

        elseif (cd = match(r"^\$\s*cd\s+(.*)", line)) !== nothing

            mode=:command
            name = cd.captures[1]
            pwd = pwd.children[name]

        elseif !isnothing(match(r"^\$\s*ls", line))

            mode=:ls

        elseif mode==:ls

            if (ls = match(r"(\d+)\s+(.+)", line)) !== nothing

                pwd.children[ls.captures[2]] = File(ls.captures[2], parse(Int, ls.captures[1]))

            elseif (ls = match(r"dir\s+(.+)", line)) !== nothing

                pwd.children[ls.captures[1]] = Dir(ls.captures[1], pwd)

            else
                println("Unrecognised ls " * line)
            end

        else

            println(line * " not expected in " * String(mode) * " mode")

        end
    end

    return root
end

@test parseInput(["\$ ls", "dir foo", "\$ cd foo"]).name=="/"
@test parseInput(["\$ ls", "dir foo", "\$ cd foo"]).children["foo"].name=="foo"

size(dir::Dir) = sum(size.(values(dir.children)))
size(file::File) = file.size

function find(condition, dir::Dir, result=Vector{Node}())
    if condition(dir)
        push!(result, dir)
    end

    for child in values(dir.children)
        find(condition, child, result)
    end
    return result
end
function find(condition, file::File, result)
    if condition(file)
        push!(result, file)
    end
    return result
end

part1(lines) = parseInput(lines) |> root -> find(d-> typeof(d)==Dir && size(d)≤100000, root) |> r->sum([size(d) for d in r])

@test part1(example1) == 95437

show(@time part1(lines))
