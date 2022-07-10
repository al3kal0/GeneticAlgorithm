const GeneticAlg = @import("geneticAlg.zig");


var generation: u32 = 0;
var max_generation: u32 = 20;

/// defines a stopping condition function
/// NO need for IChromosome to be specific
pub fn maxGeneration(algorithm: *GeneticAlg) void
{
    algorithm.converged = if (generation >= max_generation) true else false;
    generation += 1;
}
