const GeneticAlg = @import("geneticAlg.zig");


// var generation: u32 = 0;
// var max_generation: u32 = 20;

/// defines a stopping condition function
/// NO need for IChromosome to be specific
pub fn maxGeneration(algorithm: *GeneticAlg) void
{
    algorithm.converged = if (generation >= max_generation) true else false;
    generation += 1;
}

pub MaxGeneration = struct
{
    generation: u32 = 0,
    max_generation: u32 = 20,
    
    pub fn runStep(self: *MaxGeneration, algorithm: *GeneticAlg) void
    {
        algorithm.converged = if(self.generation >= self.maxGeneration) true else false;
        self.generation += 1;
    } 
        
    pub fn deinit() void
    {
        return;
    }
    
    pub fn step(self: *MaxGeneration) IStep
    {
        return IStep.init(self);
    }
};
