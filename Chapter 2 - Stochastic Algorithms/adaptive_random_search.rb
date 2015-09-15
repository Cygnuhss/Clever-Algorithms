# Adaptive Random Search looks for a best solution in a probabilistic way.
# It is an extension of Random Search and Localized Random Search.
#
# A random solution is sampled from the search space and serves as the seed for
# the walk towards an optimal solution.
# A fixed amount of steps will be made from the current solution in any direction.
# Two steps will be evaluated, one with a regular size, the other with a large
# size. Big steps are preferred over small steps if the cost is equal.
# A solution is stored if its cost is lower than the currently best solution's.
# After a given amount of iterations, the best solution is returned.
# The step size will decrease if there is no cost improvement for an extended
# period.
# Note that it cannot be guaranteed that the steps will be made in the right
# direction. The algorithm might be stuck in a local optimum.
# Thus, a globally best solution is not guaranteed. The chances of ending up
# with a local optimum and minimized by taking big steps as well as regular steps.
#
# The standard performed problem is a continuous function optimization that
# seeks min f(x) where f = sum_{n, i=1}(x_i^2), -5.0 <= x_i <= 5.0 and n = 2.
# The optimal solution is (v_0,...,v_{n-1}) = 0.0.
# Other problems can be defined through changing the objective_function and by
# changing the configurations.
#
# From Clever Algorithms: Nature-Inspired Programming Recipes.
# Pages 34–39.
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


# Select a random value from a given interval.
# The minimum and maximum values are included.
# Param::   min [Numeric] The lower end of the interval.
# Param::   max [Numeric] The upper end of the interval.
# Return::  [Numeric] The random value.
def random_in_bounds(min, max)
    return min + ((max - min) * rand())
end

# Create a d-dimensional vector with random values ranging from the minimum
# and maximum values specified by the search space dimensions.
# Param::   minmax [Array] The minimum and maximum values for each dimension
# =>        (the search space).
# Return::  [Array] The created random vector.
def random_vector(minmax)
    return Array.new(minmax.size) do |i|
        random_in_bounds(minmax[i][0], minmax[i][1])
    end
end


# Take a step in any direction.
# The step size determines the amount of change in values.
# Param::   minmax [Array] The minimum and maximum values for each dimension
# =>        (the search space).
# Param::   current [Array] The current position.
# Param::   step_size [Numeric] The amount with which values change ('move').
# Return::  [Array] The resulting step.
def take_step(minmax, current, step_size)
    position = Array.new(current.size)
    position.size.times do |i|
        min = [minmax[i][0], current[i] - step_size].max
        max = [minmax[i][1], current[i] + step_size].min
        position[i] = random_in_bounds(min, max)
    end
    return position
end

# Determine the step size.
# Param::   iteration [Integer] The current iteration.
# Param::   step_size [Numeric] The amount with which values change ('move').
# Param::   s_factor [Numeric] The factor for the smallest step size.
# Param::   l_factor [Numeric] The factor for the largest step size.
# Param::   iter_mult [Numeric] The factor that determines which iterations will
# =>        be large.
# Return::  [Numeric] The determined step size.
def large_step_size(iteration, step_size, s_factor, l_factor, iter_mult)
    return step_size * l_factor if iteration > 0 and iteration.modulo(iter_mult) == 0
    return step_size * s_factor
end

# Take a step and a big step in any direction.
# Param::   bounds [Array] The minimum and maximum values for each dimension
# =>        (the search space).
# Param::   current [Array] The current candidate position.
# Param::   step_size [Numeric] The amount with which the regular step values
# =>        change ('move').
# Param::   big_step_size [Numeric] The amount with which the big step values
# =>        change ('move').
# Return::  [Array][Array] The resulting step and big step.
def take_steps(bounds, current, step_size, big_step_size)
    # Initialize random candidate solutions from the search space and
    # evaluate their cost.
    step, big_step = {}, {}
    step[:vector] = take_step(bounds, current[:vector], step_size)
    step[:cost] = objective_function(step[:vector])
    big_step[:vector] = take_step(bounds, current[:vector], big_step_size)
    big_step[:cost] = objective_function(big_step[:vector])
    return step, big_step
end


# Search for the best solution in a given search space.
# Randomly select and evaluate candidates within a certain range from the
# currently best solution for a given amount of iterations.
# At the end of the iterations, return the current solution.
# Note that the current solution is always the currently best solution as well.
# Param::   max_iterations [Integer] The amount of iterations made before
# =>        returning an answer.
# Param::   bounds [Array] The d-dimensional space of potential solutions
# =>        returning the currently best solution.
# Param::   init_factor [Numeric] The factor for the initialized step size.
# Param::   s_factor [Numeric] The factor for the smallest step size.
# Param::   l_factor [Numeric] The factor for the largest step size.
# Param::   iter_mult [Numeric] The factor that determines which iterations will
# =>        be large.
# Param::   max_no_improv [Integer] The maximum amount of steps without
# =>        improvement.
# Return::  [Array] The vector that represents the currently best solution.
def search(max_iterations, bounds, init_factor, s_factor, l_factor,
        iter_mult, max_no_improv)
    step_size = (bounds[0][1] - bounds[0][0]) * init_factor
    # Initialize a random starting candidate solution from the search space and
    # evaluate its cost.
    current, count = {}, 0
    current[:vector] = random_vector(bounds)
    current[:cost] = objective_function(current[:vector])
    # Progress towards a better solution within the fixed number of steps.
    max_iterations.times do |iteration|
        big_step_size = large_step_size(iteration, step_size, s_factor, l_factor,
            iter_mult)
        step, big_step = take_steps(bounds, current, step_size, big_step_size)
        # Make the step if it results in a lower cost.
        if step[:cost] <= current[:cost] or big_step[:cost] <= current[:cost]
            # Making a big step is preferred over making the regular step.
            if big_step[:cost] <= step[:cost]
                step_size, current = big_step_size, big_step
            else
                current = step
            end
            count = 0
        else
            count += 1
            count, step_size = 0, (step_size / s_factor) if count >= max_no_improv
        end
        # Print the cost of the currently best solution.
        puts " > iteration=#{(iteration+1)}, current=#{current[:cost]}"
    end
    return current
end


if __FILE__ == $0
    # Set the problem configurations.
    problem_size = 2
    bounds = Array.new(problem_size) {|i| [-5, +5]}
    # Set the algorithm configurations.
    max_iterations = 1000
    init_factor = 0.05
    s_factor = 1.3
    l_factor = 3.0
    iter_mult = 10
    max_no_improv = 30
    # Execute the algorithm.
    best = search(max_iterations, bounds, init_factor, s_factor, l_factor,
        iter_mult, max_no_improv)
    # Print the best result.
    puts "Done. Best Solution: c=#{best[:cost]},
        v=#{best[:vector].inspect}"
end
