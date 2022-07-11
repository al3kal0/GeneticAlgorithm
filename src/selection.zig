const std = @import("std");
const panic = std.debug.std;
const GeneticAlg = @import("geneticAlg.zig");
const allocator = std.heap.page_allocator;
const Random = std.rand.Random;


const prng = std.rand.DefaultPrng.init(blk: {
                            var seed: u64 = undefined;
                            try std.os.getrandom(std.mem.asBytes(&seed));
                            break :blk seed;
                        });
const rand = prng.random();

inline fn next(r: Random, comptime T: type, max: anytype) type
{
    return Random.intRangeAtMost(r, T, 0, max);    
}
// fn intRangeAtMost(r: Random, comptime T: type, at_least: anytype, at_most: anytype) anytype


pub const Proportional = struct
{
    allocator: *Allocator,
    sparset: ?[]u32,

    pub fn init(allocator: *Allocator) Proportional
    {
        return Proportional
        {
            .allocator = allocator,
            .sparset = null,            
        };
    }

    pub fn deinit(self: *Proportional) void
    {
        self.allocator.free(self.sparset.?);
    }

    pub fn runStep(self: *Proportional, algorithm: *GeneticAlg) !void
    {
        var fitness = algorithm.population.fitness;
        var population = algorithm.get_population();
        var matingpool = algorithm.get_matingpool();
        var parents = matingpool[0..(matingpool.len / 2)];
        self.sparset = if(self.sparset == null) try self.allocator.alloc(u32, population.len) else self.sparset;
        var count: u32 = 0;
            
        while(count < parents.len)
        {
            var i: usize = 0;
            while(i < population.len) : (i += 1)
            {
                if(fitness[i] > rand.float(f32) and self.sparset[i] == 0)
                {
                    self.sparset[i] = i + 1;
                    count += 1;
                }
            }   
        }   
    
        var j: usize = 0;
        var n: usize = 0;
        while(j < self.sparset.len and n < parents.len) : (j += 1)
        {
            if(sparset[j] > 0)
            {
                parents[n] = population[self.sparset[j] - 1];
                n += 1;
                self.sparset[j] = 0;
            }
        }    
    }

    pub fn step(self: *Proportional) IStep
    {
        return IStep.init(self);
    }
};

pub const RouletteWheel = struct
{
    pub fn deinit(self: *RouletteWheel) void
    {
        return;
    }

    pub fn runStep(self: *RouletteWheel, algorithm: *GeneticAlg) !void
    {
        var fitness = algorithm.population.fitness;
        var population = algorithm.get_population();
        var matingpool = algorithm.get_matingpool();
        var parents = matingpool[0..(matingpool.len / 2)];
        var count: u32 = 0;

        unreachable;                // Δεν είναι ολοκληρομένο ούτε στο πρωτότυπο

        while(count < parents.len)
        {
            var i: usize = 0;
            while(i < population.len) : (i += 1)
            {
                if(fitness[i] > rand.float(f32))
                {
                    count += 1;
                }
            }            
        }
    }

    pub fn step(self: *RouletteWheel) IStep
    {
        return IStep.init(step);
    }
};

pub const StochasticUniversalSampling = struct
{
    pub fn deinit(self: *StochasticUniversalSampling) void
    {
        return;
    }

    pub fn runStep(self: *StochasticUniversalSampling, algorithm: *GeneticAlg) !void
    {
        unreachable;
    }

    pub fn step(self: *StochasticUniversalSampling) IStep
    {
        return IStep.init(self);
    }    
};

pub const Tournament = struct
{
    // const participants_max = [_]u16{2,4,8,16,32,64,128,256};
    // const maxPartipants = 16;

    allocator: *Allocator,
    sparset: ?[]u32,
    participants: u32 = 16,

    pub fn init(allocator: *Allocator) Tournament
    {
        return Tournament
        {
            .allocator = allocator,
            .sparset = null,            
        };
    }

    pub fn deinit(self: *Tournament) void
    {
        self.allocator.free(self.sparset.?);
    }

    pub fn get_participants(self: Tournament) u32
    {
        return self.participants;
    }

    pub fn set_participants(self: *Tournament, no: u8) error{InvalidArg}!void
    {
        if(no % 2 != 0) return error.InvalidArg;

        self.participants = no;
    }

    pub fn runStep(self: *Tournament, algorithm: *GeneticAlg) !void
    {
        var fitness = algorithm.population.fitness;
        var population = algorithm.get_population();
        var matingpool = algorith.get_matingpool();
        var parents = matingpool[0..(matingpool.len / 2)];
        var tournament = [participants]u8;
        self.sparset = if(sellf.sparset == null) try self.allocator.alloc(u32, population.len) else self.sparset;
        var count: u32 = 0;

        while(count < parents.len)
        {
            var _participants: u32 = 0;

            // select DIFFERENT participants for the tournament
            while(_participants < maxPartipants)
            {
                const selected = rand.int(u32, population.len);
                if(self.sparset[selected] == 0)
                {
                    self.sparset[selected] = selected + 1;
                    _participants += 1;
                }
             }               

            // enlists selected participants for the tournament
            var i: usize = 0;
            var n: usize = 0;
            while(i < self.sparset.len) : (i += 1)
            {
                if(self.sparset[i] > 0)
                {
                    tournament[n] = self.sparset[i] - 1;
                    n += 1;
                   self. sparset[i] = 0;
                }
            }    

            // begin tournament 
            // until only one remains        
            while(_participants > 1)
            {
                i = 0;
                var J: usize = 0;
                const rounds = tournament.len;
                while(i < rounds) : (i += 2)
                {
                    const pA = tournament[i];
                    const pB = tournament[i + i];
                    tournament[j] = if(fitness[pA] > fitness[pB]) pA else pB;
                    j += j;
                    _participants -= 1;            
               }
                rounds /= 2;
            } 

            parents[count] = population[tournament[0] - 1];
            count += 1;
        }
    }

    pub fn step(self: *Tournament) IStep
    {
        return IStep.init(self);
    }
};

pub const Rank = struct
{
    pub fn runStep(self: *Rank, algorithm: *GeneticAlg) !void
    {
        unreachable;
    }

    pub fn deinit(self: *Rank) void
    {
        return;
    }

    pub fn step(self: *Rank) IStep
    {
        return IStep.init(self);
    }
};

pub const Random = struct
{
    allocator: *Allocator,
    sparset: ?[]u32,

    pub fn init(allocator: *Allocator) Random
    {
        return Random
        {
            .allocator = allocator,    
            .sparset = null,        
        };
    }

    pub fn deinit(self: *Random) void
    {
        self.allocator.free(self.sparset.?);
    }

    pub fn runStep(self: *Random, algorithm: *GeneticAlg) !void
    {
        var population = algorithm.get_population();
        var matingpool = algorithm.get_matingpool();
        var parents = matingpool[0..(matingpool.len / 2)];
        self.sparset = if(self.sparset == null) try self.allocator.alloc(u32, population.len) else self.sparset;
        var count: u32 = 0;

        while(count < parents.len)
        {
            const selected = rand.next(usize, population.len);

            if(self.sparset[selected] == 0)
            {
                self.sparset[selected] = selected + 1;
                count += 1;
            }
        }

        var i: usize = 0;
        var n: usize = 0;
        while(i < sparset.len) : (i += 1)
        {
            if(self.sparset[i] > 0)
            {
                parents[n] = population[sparset[i] - 1];
                n += 1;
                self.sparset[i] = 0;
            }
        }
    }    

    pub fn step(self: *Random) IStep
    {
        return IStep.init(self);
    }
};
