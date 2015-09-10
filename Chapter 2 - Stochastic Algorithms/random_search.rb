# Random Search looks for a best solution in a probabilistic way.
#
# A random solution is sampled from the search space using a uniform probability
# distribution. Each sample is independent of previous samples (the algorithm
# has no memory).
# A solution is stored if its cost is lower than the currently best solution's.
# After a given amount of iterations, the best solution is returned.
# Note that it cannot be guaranteed that all solutions in the search space will
# be tested. Thus, a globally best solution is not guaranteed.
#
# The output can serve as the input for a local search technique (such as the
# Hill Climbing algorithm) that can be used to locate the best solution in the
# neighborhood of the solution found with Random Search.
#
# The standard performed problem is a continuous function optimization that
# seeks min f(x) where f = sum_{n, i=1}(x_i^2), -5.0 <= x_i <= 5.0 and n = 2.
# The optimal solution is (v_0,...,v_{n-1}) = 0.0.
# Other problems can be defined through changing the objective_function and by
# changing the configurations.
#
# From Clever Algorithms: Nature-Inspired Programming Recipes.
# Pages 30–33.
#
# Author::  Jelmer van Nuss
# Date::    10-09-2015


# Calculate the cost of a given vector with this cost function.
# The cost function is f = sum_{n, i=1}(x_i^2).
# Param::   vector [Array] The vector whose cost has to be determined.
# Return::  [Float] The cost of the vector given this function.
def objective_function(vector)
    return vector.inject(0) {|sum, x| sum + (x ** 2.0)}
end


# Create a d-dimensional vector with random values ranging from the minimum
# and maximum values specified by the search space dimensions.
# Param::   minmax [Array] The minimum and maximum values for each dimension
# =>        (the search space).
# Return::  [Array] The created random vector.
def random_vector(minmax)
    return Array.new(minmax.size) do |i|
        minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
    end
end

# Search for the best solution in a given search space.
# Randomly select and evaluate candidates for a given amount of iterations.
# At the end of the iterations, return the currently best candidate.
# Param::   search_space [Array] The d-dimensional space of potential solutions.
# Param::   max_iterations [Integer] The amount of iterations made before
# =>        returning the currently best solution.
# Return::  [Array] The vector that represents the currently best solution.
def search(search_space, max_iterations)
    best = nil
    max_iterations.times do |iteration|
        # Initialize a random candidate solution from the search space and
        # evaluate its cost.
        candidate = {}
        candidate[:vector] = random_vector(search_space)
        candidate[:cost] = objective_function(candidate[:vector])
        # Replace the currently best solution if the cost is lower.
        best = candidate if best.nil? or candidate[:cost] < best[:cost]
        # Print the cost of the currently best solution.
        puts " > iteration=#{(iteration+1)}, best=#{best[:cost]}"
    end
    return best
end


if __FILE__ == $0
    # Set the problem configurations.
    problem_size = 2
    search_space = Array.new(problem_size) {|i| [-5, +5]}
    # Set the algorithm configurations.
    max_iterations = 100
    # Execute the algorithm.
    best = search(search_space, max_iterations)
    # Print the best result.
    puts "Done. Best Solution: c=#{best[:cost]},
        v=#{best[:vector].inspect}"
end
