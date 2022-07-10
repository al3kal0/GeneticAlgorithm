const std = @import("std");
const panic = std.debug.panic;


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

        var prng = std.rand.DefaultPrng.init(blk: {
                            var seed: u64 = undefined;
                            try std.os.getrandom(std.mem.asBytes(&seed));
                            break :blk seed;
                        });
            const rand = prng.random();
            const chromosomes = population.population; 
                    
            for(chromosomes) |chromosome|
            {
                chromosome.randomInit(rand);
            }     
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

