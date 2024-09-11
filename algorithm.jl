using Combinatorics, Random

struct Person
    abilities::Vector{Int}
    name::AbstractString
end

struct Duo
    abilities::Vector{Int}
    names::Vector{AbstractString}
end

function Person(abilities::Vector{Int})
    Person(abilities, randstring(3))
end

function Duo(p1::Person, p2::Person)
    Duo(p1.abilities + p2.abilities, [p1.name, p2.name])
end
function Duo(ps::Vector{Person})
    Duo(mapreduce(x -> x.abilities, +, ps), map(x -> x.name, ps))
end

function makepairs(people::Vector{Person})
    Duo.(collect(combinations(people, 2)))
end

function exclude(pair::Duo, list::Vector{Duo})
    newlist = filter(x -> !(pair.names[1] in x.names), list)
    filter!(x -> !(pair.names[2] in x.names), newlist)
    return newlist
end

function telescope(input::Vector)
    while eltype(input) != Vector{Duo}
        input = collect(Iterators.flatten(input))
    end
    return input
end

scores = [rand(1:100, 4) for i in 1:15]

people = Person.(scores)

pairs = makepairs(people)

function rate(pairs::Vector{Duo})
    sum = 0
    for i in 1:length(pairs)
        sum += pairs[i].abilities[i]
    end
    return sum
end

function tail(pairs::Vector{Duo}, existing::Vector{Duo})
    maxr = 0
    maxs = []
    for pair in pairs
        push!(existing, pair)
        r = rate(existing)
        #println(r," ",maxr)
        if r > maxr
            maxr = r
            maxs = [copy(existing)]
        elseif r == maxr
            push!(maxs, copy(existing))
        end
        pop!(existing)
    end
    return maxr, maxs
end

function body(pairs::Vector{Duo}, existing::Vector{Duo}, events::Int)
    maxr = 0
    maxs = []
    for pair in pairs 
        np = exclude(pair, pairs)
        push!(existing, pair)
        nr, ns = constructAndRate(np, existing, events)
        if nr > maxr
            maxr = nr
            maxs = [copy(ns)]
        elseif nr == maxr
            push!(maxs, copy(ns))
        end
        pop!(existing)
    end
    return maxr, maxs
end

function constructAndRate(pairs::Vector{Duo}, existing::Vector{Duo}, events::Int)
    maxr = 0
    maxs = []
    #na = Vector{Duo}(undef, length(existing)+1)
    #copyto!(na, existing)
    if events-1 == length(existing) #number of events
        tail(pairs, existing)
    else
        body(pairs, existing, events)
    end
    
end 

# println(pairs)
# t = time()
# thing = constructAndRate(pairs, Duo[], 4)
# println(time() - t, " seconds")
# println(thing[1])
# display(thing[2])
# println()