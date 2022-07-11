const std = @import("std");
const GeneticAlg = @import("geneticAlg.zig");
const Random = std.rand.Random;

const prng = std.rand.DefaultPrng.init(blk: {
                            var seed: u64 = undefined;
                            try std.os.getrandom(std.mem.asBytes(&seed));
                            break :blk seed;
                        });
const rand = prng.random();

inline fn next(r: Random, comptime T: type, max: anytype) type
{
    return r.intRangeAtMost(T, 0, max);
}


pub const Bitflip = struct
{
    mutationFactor: f32 = 0.1,

    fn mutation(comptime T: type, chromosome: *T) void
    {
        const _mutation = switch(rand.next(u8, 6))
        {
            0 => 0b000_0001,
            1 => 0b000_0010,
            2 => 0b000_0100,
            3 => 0b000_1000,
            4 => 0b001_0000,
            5 => 0b010_0000,
            6 => 0b100_0000,
            else => 0b000_0000,
        };
    
        const offset = rand.next(usize, @sizeOf(T) - @sizeOf(u8));
        var ptr = @ptrCast([*]u8, chromosome);
        ptr[offset] ^= _mutation;
        ptr[offset].chromosome().repair();
    }    

    pub fn runStep(self: *Bitflip, algorithm: *GeneticAlg) !void
    {
        var population = algorithm.get_population();
        
        var i: usize = 0;
        while(i < population.len) : (i += 1)
        {
            if(self.mutationFactor > rand.float(f32))
            {
                mutation(population[i]);             
            }        
        }  
    }

    pub fn deinit(self: *Bitflip) void
    {
        return;
    }

    pub fn step(self: *Bitflip) IStep
    {
        return IStep.init(self);
    }
};

pub const Random = struct
{
    mutationFactor: f32 = 0.1,   

    pub fn runStep(self: *Random, algorithm: *GeneticAlg) !void
    {
        var population = algorithm.get_population();
        
        var i: usize = 0;
        while(i < population.len) : (i += 1)
        {
            if(self.mutationFactor > rand.float(f32))
            {
                population[i].chromosome().randomMutation();
            }
        }
    }    

    pub fn deinit(self: *Random) void
    {
        return;
    }

    pub fn step(self: *Random) IStep
    {
        return IStep.init(self);
    }
};

pub const Scramble = struct
{
    mutationFactor: f32 = 0.5,
    
    const mutationSize = 12;

    fn mutation(comptime T: type, chromosome: *T, offset: usize) void
    {
        var _ptr = @ptrCast([*]u8, chromosome) + offset;
        var ptr = @ptrCast([*]u32, _ptr);
    
        ptr[0] ^= rand.int(u32);
        ptr[1] ^= rand.int(u32);
        ptr[2] ^= rand.int(u32);
    
        chromosome.chromosome().repair();
    }

    pub fn runStep(self: *Scramble, algorithm: *GeneticAlg)!void
    {        
        var population = algorithm.get_population();
    
        var i: usize = 0;
        while(i < population.len) : (i += 1)
        {
            if(self.mutationFactor > rand.float(f32))
            {
                const offset = rand.next(usize, @sizeOf(T) - mutationSize);
                mutation(population[i], offset);
            }
        }
    }

    pub fn deinit(self: *Scramble) void
    {
        return;
    }

    pub fn step(self: *Scramble) IStep
    {
        return IStep.init(self);
    }
};

pub const Swap = struct
{
    pub fn runStep(self: *Swap, algorithm: *GeneticAlg) !void
    {
        unreachable;
    }    

    pub fn deinit(self: *Swap) void
    {
        return;
    }

    pub fn step(self: *Swap) IStep
    {
        return IStep.init(self);
    }
};


pub const Inversion = struct
{
    pub fn runStep(self: *Inversion, algorithm: *GeneticAlg) !void
    {
        unreachable;
    }    

    pub fn deinit(self: *Inversion) void
    {
        return;
    }

    pub fn step(self: *Inversion) IStep
    {
        return IStep.init(self);
    }
};
