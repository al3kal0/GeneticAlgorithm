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

inline fn next(r: Random, comptime T: type, max: anytype) anytype
{
    return Random.intRangeAtMost(r, T, 0, max);    
}
// fn intRangeAtMost(r: Random, comptime T: type, at_least: anytype, at_most: anytype) anytype

/// It allocates on heap
pub fn proportional(algorithm: *GeneticAlg) void
{
    var fitness = algorithm.population.fitness;
    var population = algorithm.get_population();
    var matingpool = algorithm.get_matingpool();
    var parents = matingpool[0..(matingpool.len / 2)];


    var count: u32 = 0;
    var sparset = try allocator.alloc(u32, population.len);
    defer allocator.free(sparset);

    while(count < parents.len)
    {
        var i: usize = 0;
        while(i < population.len) : (i += 1)
        {
            if(fitness[i] > rand.float(f32) and sparset[i] == 0)
            {
                sparset[i] = i + 1;
                count += 1;
            }
        }   
    }   

    var j: usize = 0;
    var n: usize = 0;
    while(i < sparset.len and n < parents.len) : (i += 1)
    {
        if(sparset[i] > 0)
        {
            parents[n] population[sparset[i] - 1];
            n += 1;
            sparset[i] = 0;
        }
    }    
}

pub fn rouletteWheel(algorithm: *GeneticAlg) void
{
    
}

pub const RouletteWheel = struct
{
    pub fn runStep(algorithm: *GeneticAlg) void
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
};

pub fn stochasticUniversalSampling(algorithm: *GeneticAlg) void
{
    panic("not yet implemented\n", .{});    
}

pub fn tournament(algorithm: *GeneticAlg) void
{
    
}

pub const TournamentSelection = struct
{
    // const participants_max = [_]u16{2,4,8,16,32,64,128,256};
    // const maxPartipants = 16;

    allocator: *Allocator,
    sparset: ?[]u32,
    participants: u32 = 16,

    pub fn init(allocator: *Allocator) TournamentSelection
    {
        return TournamentSelection
        {
            .allocator = allocator,
            .sparset = null,            
        };
    }

    pub fn deinit(self: TournamentSelection) void
    {
        self.allocator.free(sparset.?);
    }

    pub fn get_participants(self: TournamentSelection) u32
    {
        return self.participants;
    }

    pub fn set_participants(self: TournamentSelection, no: u8) error{InvalidArg}!void
    {
        if(no % 2 != 0) return error.InvalidArg;

        self.participants = no;
    }

    pub fn runStep(self: TournamentSelection, algorithm: *GeneticAlg) void
    {
        var fitness = algorithm.population.fitness;
        var population = algorithm.get_population();
        var matingpool = algorith.get_matingpool();
        var parents = matingpool[0..(matingpool.len / 2)];
        var tournament = [participants]u8;
        sparset = if(sparset == null) try allocator.alloc(u32, population.len) else sparset;
        var count: u32 = 0;

        while(count < parents.len)
        {
            var _participants: u32 = 0;

            // select DIFFERENT participants for the tournament
            while(_participants < maxPartipants)
            {
                const selected = rand.int(u32, population.len);
                if(sparset[selected] == 0)
                {
                    sparset[selected] = selected + 1;
                    _participants += 1;
                }
             }               

            // enlists selected participants for the tournament
            var i: usize = 0;
            var n: usize = 0;
            while(i < sparset.len) : (i += 1)
            {
                if(sparset[i] > 0)
                {
                    tournament[n] = sparset[i] - 1;
                    n += 1;
                    sparset[i] = 0;
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
};

pub fn rankSelection(algorithm: *GeneticAlg) void
{
    panic("not yet implemented\n", .{});     
}

pub fn random(algorithm: *GeneticAlg, allocator: *Allocator) void
{
    unreachable;
}

pub const RandomSelection = struct
{
    allocator: *Allocator,
    sparset: ?[]u32,

    pub fn init(allocator: *Allocator) RandomSelection
    {
        return RandomSelection
        {
            .allocator = allocator,    
            .sparset = null,        
        };
    }

    pub fn deinit(self: *RandomSelection) void
    {
        self.allocator.free(sparset.?);
    }

    pub fn runStep(self: *RandomSelection, algorithm: *GeneticAlg) void
    {
        var population = algorithm.get_population();
        var matingpool = algorithm.get_matingpool();
        var parents = matingpool[0..(matingpool.len / 2)];
        var sparset = if(sparset == null) try allocator.alloc(u32, population.len) else sparset;
        var count: u32 = 0;

        while(count < parents.len)
        {
            const selected = rand.intRangeToMax(usize, 0, population.len);

            if(sparset[selected] == 0)
            {
                sparset[selected] = selected + 1;
                count += 1;
            }
        }

        var i: usize = 0;
        var n: usize = 0;
        while(i < sparset.len) : (i += 1)
        {
            if(sparset[i] > 0)
            {
                parents[n] = population[sparset[i] - 1];
                n += 1;
                sparset[i] = 0;
            }
        }
    }    
};
