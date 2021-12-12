#=
day12:
- Julia version: 1.7.0
- Author: Paul.Mealor
- Date: 2021-12-12
=#

using AoC, Test


function parseLink!(links, link)
    (start,finish) = split(link, "-")
    links[start] = union(get(links,start,[]), [finish])
    links[finish] = union(get(links,finish,[]), [start])
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

function visit!(paths, visited, links, cave)
    visited = vcat(visited, cave)
    if cave == "end"
        push!(paths, visited)
        return paths
    end

    for target in links[cave]
        if occursin(r"^[A-Z]+$", target) || target ∉ visited
            visit!(paths, visited, links, target)
        end
    end

    return paths
end
@test visit!([], [], Dict("start"=>["end"], "end"=>["start"]), "start") == [["start","end"],]

function part1(lines)
    links = parseLinks(lines)
    paths = visit!([], [], links, "start")
    return length(paths)
end
@test part1(exampleLines(12,1)) == 10
@test part1(exampleLines(12,2)) == 19
@test part1(exampleLines(12,3)) == 226

lines(12) |> ll -> @time part1(ll) |> show