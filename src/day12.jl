#=
day12:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-12
=#

using AoC, Test, Memoize


function parseLink!(links, link)
    (start,finish) = split(link, "-")
    if finish != "start"; links[start] = union(get(links,start,[]), [finish]); end
    if start != "start"; links[finish] = union(get(links,finish,[]), [start]); end
    return links
end
@test parseLink!(Dict(), "a-b") == Dict("a"=>["b"], "b"=>["a"])
@test parseLink!(parseLink!(Dict(), "a-b"), "a-c") == Dict("a"=>["b","c"], "b"=>["a"], "c"=>["a"])

function parseLinks(links)
    result = Dict()
    for link in links
        parseLink!(result, link)
    end
    return result
end

@memoize manyVisitsAllowed(cave) = occursin(r"^[A-Z]+$", cave)

visit(links, cave; allowTwoVisits=false) = visit!(links, cave, Set(), []; allowTwoVisits)
function visit!(links, cave, paths, visited; allowTwoVisits=false)
    push!(visited, cave)
    if cave == "end"
        if visited ∉ paths
            push!(paths, copy(visited))
        end
        pop!(visited)
        return paths
    end

    for target in links[cave]
        if manyVisitsAllowed(target)
            paths = visit!(links, target, paths, visited; allowTwoVisits=allowTwoVisits)
        elseif allowTwoVisits
            paths = visit!(links, target, paths, visited; allowTwoVisits=(target ∉ visited))
        elseif target ∉ visited
            paths = visit!(links, target, paths, visited; allowTwoVisits=allowTwoVisits)
        end
    end

    pop!(visited)
    return paths
end
@test visit(Dict("start"=>["end"]), "start") == Set([["start", "end"],])

function part1(lines)
    links = parseLinks(lines)
    return visit(links, "start") |> length
end
@test part1(exampleLines(12,1)) == 10
@test part1(exampleLines(12,2)) == 19
@test part1(exampleLines(12,3)) == 226

function part2(lines)
    links = parseLinks(lines)
    return visit(links, "start"; allowTwoVisits=true) |> length
end
@test part2(exampleLines(12,1)) == 36
@test part2(exampleLines(12,2)) == 103
@test part2(exampleLines(12,3)) == 3509

lines(12) |> ll -> @time part1(ll) |> show
lines(12) |> ll -> @time part2(ll) |> show
