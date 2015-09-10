# Stochastic Hill Climbing looks for a best solution in a probabilistic way.
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
# The standard performed problem is a binary string optimization called 'One Max'.
# The cost function reports the number of '1' bits in the string.
# The optimal solution is a string containing only '1' bits.
# Other problems can be defined through changing the one_max and by changing the
# configurations.
#
# From Clever Algorithms: Nature-Inspired Programming Recipes.
# Pages 40–43.
#
# Author::  Jelmer van Nuss
# Date::    10-09-2015


# Calculate the cost of a given vector with this cost function.
# The cost function is f = sum_{n, i=1}(1 if v_i = 1).
# Param::   vector [String] The vector whose cost has to be determined.
# Return::  [Float] The cost of the vector given this function.
def one_max(vector)
    return vector.inject(0.0) {|sum, v| sum + ((v == "1") ? 1 : 0)}
end


# Create a random bitstring.
# Param::   num_bits [Integer] The length of the bitstring.
# Return::  [String] The created random bitstring.
def random_bitstring(num_bits)
    return Array.new(num_bits) {|i| (rand < 0.5) ? "1" : "0"}
end

# Determine a random neighbor.
# Param::   bitstring [String] The bitstring whose neighbor has to be determined.
# Return::  [String] A random neighbor of the given bitstring.
def random_neighbor(bitstring)
    mutant = Array.new(bitstring)
    position = rand(bitstring.size)
    mutant[position] = (mutant[position] == "1") ? "0" : "1"
    return mutant
end


# Search for the best solution in a given search space.
# Randomly select and evaluate candidates within a certain range from the
# currently best solution for a given amount of iterations.
# At the end of the iterations, return the current solution.
# Note that the current solution is always the currently best solution as well.
# Param::   max_iterations [Integer] The amount of iterations made before
# Param::   num_bits [Integer] The length of the bitstring.
# Return::  [Array] The vector that represents the currently best solution.
def search(max_iterations, num_bits)
    # Initialize a random starting candidate solution from the search space and
    # evaluate its cost.
    candidate = {}
    candidate[:vector] = random_bitstring(num_bits)
    candidate[:cost] = one_max(candidate[:vector])
    # Progress towards a better solution within the fixed number of steps.
    max_iterations.times do |iteration|
        # Initialize a random neighbor solution from the search space and
        # evaluate its cost.
        neighbor = {}
        neighbor[:vector] = random_neighbor(candidate[:vector])
        neighbor[:cost] = one_max(neighbor[:vector])
        # Replace the currently best solution if the cost is lower.
        candidate = neighbor if neighbor[:cost] >= candidate[:cost]
        # Print the cost of the currently best solution.
        puts " > iteration=#{(iteration+1)}, best=#{candidate[:cost]}"
        break if candidate[:cost] == num_bits
    end
    return candidate
end


if __FILE__ == $0
    # Set the problem configurations.
    num_bits = 64
    # Set the algorithm configurations.
    max_iterations = 1000
    # Execute the algorithm.
    best = search(max_iterations, num_bits)
    # Print the best result.
    puts "Done. Best Solution: c=#{best[:cost]},
        v=#{best[:vector].inspect}"
end
