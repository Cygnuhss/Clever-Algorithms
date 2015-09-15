# Iterated Local Search looks for a best solution in a probabilistic way.
# It is a local search technique that can be used to refine results obtained
# from a global search.
#
# A random solution is sampled from the search space and serves as the seed for
# the walk towards an optimal solution.
# Each step, a random neighboring solution is selected and evaluated. If its
# cost is better than the current best solution, the neighbor is saved as the
# current best solution.
# After a given amount of iterations, the best solution is returned.
# The algorithm can be restarted for an improved result (Restart Hill Climbing)
# or run concurrently so that multiple runs are performed simultaneously
# (Parallel Hill Climbing).
#
# The standard performed problem is a Travelling Salesman Problem called 'Berlin52'.
# The cost function is the distance travelled in a round trip through all cities.
# The optimal solution for Berlin52 is 7542 units.
# Other problems can be defined through changing the one_max and by changing the
# configurations.
#
# From Clever Algorithms: Nature-Inspired Programming Recipes.
# Pages 44–49.
#
# Author::  Jelmer van Nuss
# Date::    15-09-2015


# Calculate the two dimensional Euclidean distance between two cities.
# Param::   c1 [Array] The position (X, Y) of the first city.
# Param::   c2 [Array] The position (X, Y) of the second city.
# Return::  [Float] The Euclidean distance between two cities.
def euclidean_distance_2d(c1, c2)
    return Math.sqrt((c1[0] - c2[0]) ** 2.0 + (c1[1] - c2[1]) ** 2.0).round
end

# Calculate the travel cost of a round trip along each city.
# Param::   permutation [Array] The order in which the cities are visited.
# Param::   cities [Array] The positions (X, Y) of all cities.
# Return::  [Float] The travel distance of the round trip.
def cost(permutation, cities)
    distance = 0
    permutation.each_with_index do |c1, i|
        c2 = (i == permutation.size - 1) ? permutation[0] : permutation[i + 1]
        distance += euclidean_distance_2d(cities[c1], cities[c2])
    end
    return distance
end


# Create a random permutation of cities.
# Each city will be visited only once, the travel is thus a round trip.
# Param::   cities [Array] The positions (X, Y) of all cities.
# Return::  [Array] The round trip.
def random_permutation(cities)
    permutation = Array.new(cities.size) {|i| i}
    permutation.each_index do |i|
        r = rand(permutation.size - i) + i
        permutation[r], permutation[i] = permutation[i], permutation[r]
    end
    return permutation
end

# Reverse parts of the original permutation to create a new permutation.
# Param::   permutation [Array] The order in which the cities are visited.
# Return::  [Array] A new permutation where parts are reversed.
def stochastic_two_opt(permutation)
    permutation = Array.new(permutation)
    c1, c2 = rand(permutation.size), rand(permutation.size)
    exclude = [c1]
    exclude << ((c1 == 0) ? permutation.size - 1 : c1 - 1)
    exclude << ((c1 == permutation.size - 1) ? 0 : c1 + 1)
    c2 = rand(permutation.size) while exclude.include?(c2)
    c1, c2 = c2, c1 if c2 < c1
    permutation[c1...c2] = permutation[c1...c2].reverse
    return permutation
end


# Search for potential better solutions than the current best.
# Param::   best [Array] The round trip with the current smallest distance.
# Param::   cities [Array] The positions (X, Y) of all cities.
# Param::   max_no_improv [Integer] The maximum amount of steps without
# =>        improvement.
# Return::  [Array] The round trip with a better result than the current best.
def local_search(best, cities, max_no_improv)
    count = 0
    begin
        # Initialize a candidate solution from the search space and
        # evaluate its cost.
        candidate = {:vector => stochastic_two_opt(best[:vector])}
        candidate[:cost] = cost(candidate[:vector], cities)
        count = (candidate[:cost] < best[:cost]) ? 0 : count + 1
        best = candidate if candidate[:cost] < best[:cost]
    end until count >= max_no_improv
    return best
end

# Exchange slices of the permutation to create a new permutation.
# Param::   permutation [Array] The order in which the cities are visited.
# Return::  [Array] A new permutation where sliced parts are exchanged.
def double_bridge_move(permutation)
    pos1 = 1 + rand(permutation.size / 4)
    pos2 = pos1 + 1 + rand(permutation.size / 4)
    pos3 = pos2 + 1 + rand(permutation.size / 4)
    p1 = permutation[0...pos1] + permutation[pos3...permutation.size]
    p2 = permutation[pos2...pos3] + permutation[pos1...pos2]
    return p1 + p2
end

# Search for potential better solutions than the current best.
# Param::   cities [Array] The positions (X, Y) of all cities.
# Param::   best [Array] The order in which the cities are visited.
# Return::  [Array] A round trip through the cities.
def perturbation(cities, best)
    candidate = {}
    candidate[:vector] = double_bridge_move(best[:vector])
    candidate[:cost] = cost(candidate[:vector], cities)
    return candidate
end


# Search for the best round trip through all cities.
# Randomly select and evaluate a first permutation, after which for some
# iterations the program will try to find a better solution.
# At the end of the iterations, return the current solution.
# Note that the current solution is always the currently best solution as well.
# Param::   cities [Array] The positions (X, Y) of all cities.
# Param::   max_iterations [Integer] The amount of iterations made before
# =>        returning an answer.
# Param::   max_no_improv [Integer] The maximum amount of steps without
# =>        improvement.
# Return::  [Array] The vector that represents the currently best solution.
def search(cities, max_iterations, max_no_improv)
    # Initialize a random starting candidate solution from the search space and
    # evaluate its cost.
    best = {}
    best[:vector] = random_permutation(cities)
    best[:cost] = cost(best[:vector], cities)
    best = local_search(best, cities, max_no_improv)
    # Progress towards a better solution within the fixed number of steps.
    max_iterations.times do |iteration|
        # Initialize a random neighbor solution from the search space and
        # evaluate its cost.
        candidate = perturbation(cities, best)
        candidate = local_search(candidate, cities, max_no_improv)
        # Replace the currently best solution if the cost is lower.
        best = candidate if candidate[:cost] < best[:cost]
        # Print the cost of the currently best solution.
        puts " > iteration=#{(iteration+1)}, best=#{best[:cost]}"
    end
    return best
end


if __FILE__ == $0
    # Set the problem configurations.
    berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],
        [880,660],[25,230],[525,1000],[580,1175],[650,1130],[1605,620],
        [1220,580],[1465,200],[1530,5],[845,680],[725,370],[145,665],
        [415,635],[510,875],[560,365],[300,465],[520,585],[480,415],
        [835,625],[975,580],[1215,245],[1320,315],[1250,400],[660,180],
        [410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
        [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],
        [95,260],[875,920],[700,500],[555,815],[830,485],[1170,65],
        [830,610],[605,625],[595,360],[1340,725],[1740,245]]
    # Set the algorithm configurations.
    max_iterations = 100
    max_no_improv = 50
    # Execute the algorithm.
    best = search(berlin52, max_iterations, max_no_improv)
    # Print the best result.
    puts "Done. Best Solution: c=#{best[:cost]},
        v=#{best[:vector].inspect}"
end
