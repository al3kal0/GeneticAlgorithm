const std = @import("std");
const panic = std.debug.panic;
const IStep = @import("GeneticAlg").IStep;

var prng = std.rand.DefaultPrng.init(blk: {
                        var seed: u64 = undefined;
                        try std.os.getrandom(std.mem.asBytes(&seed));
                        break :blk seed;
                    });
const rand = prng.random();                   
              

pub const Experiment = struct
{
    cNa2O3: f32,
    mr: f32,
    sr: f32,
    temp: f32,
    time: f32,

    // implement interface
    pub fn initialize(self: *Experiment) void
    {
        unreachable;
    }

    pub fn fitness(self: *Experiment) f32
    {
        unreachable;
    }

    pub fn repair(self: *Experiment) void
    {
        unreachable;
    }

    pub fn constrained(self: *Experiment) bool
    {
        unreachable;
    }
     
    pub fn randomMutation(self: *Experiment) void
    {
        unreachable;

        self.repair();
    }

    pub fn chromosome(self: *Experiment) IChromosome
    {
        return IChromosome.init(self);
    }   
};


pub const FitnessWSGA = struct
{
    pub fn runStep(self: FitnessWSGA, algorithm: *GeneticAlg) void
    {
        var population = algorithm.get_population();
        var fitness = algorithm.population.fitness;
        
        var i: usize = 0;
        while(i < fitness) : (i += 1)
        {
            fitness[i] = population[i].chromosome().fitness();
        }
    }
    
    pub fn deinit() void
    {
        return;
    }
    
    pub fn step(self: *FitnessWSGA) IStep
    {
        return IStep.init(self);
    }
}
