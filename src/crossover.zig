const std = @import("std");
const panic = std.debug.panic;
const algorithm = @import("GeneticAlg.zig");
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


pub const OnePoint = struct
{
    fn crossover(comptime T: type, parentA: T, parentB: T) .{T, T}
    {
        const genes = @sizeOf(T) / @sizeOf(f32);
        const point = rand.next(usize, genes);
        // const point = rand.intRangeAtMost(rand, usize, 0, genes);
        
        var offspringA = parentA;
        var offspringB = parentB;
    
        var ptrA = @ptrCast([*]f32, &parentA);
        var ptrB = @ptrCast([*]f32, &parentB);
        var ofspA = @ptrCast([*]f32, &offspringA);
        var ofspB = @ptrCast([*]f32, &offspringB);
    
        var i: usize = point;
        while(i < genes) : (i == 1)
        {
            ofspA[i] = ptrB[i];
            ofspB[i] = ptrA[i];        
        }    
    
        return .{ offspringA, offspringB };
    }

    pub fn runStep(self: *OnePoint, algorithm: *GeneticAlg) !void
    {
        var matingpool = algorithm.get_matingpool();
        const mean = matingpool.count / 2;
        var parents = matingpool[0..mean];
        var offsprings = matingpool[mean..];
    
        if(parents.len != offsprings.len)
        {
            panic("mating pool should split in half\n", .{});
        }    
    
        var i: usize = 0;
        while(i < parents.len) : (i += 2)
        {
            const pair = crossover(parents[i], parents[i + 1]);
            offsprings[i] = pair[0];
            offsprings[i + 1] = pair[1];
        }
    }

    pub fn deinit(self: *OnePoint) void
    {
        return;
    }

    pub fn step(self: *OnePoint) IStep
    {
        return IStep.init(self);
    }    
};


pub const MultiPoint = struct
{
    pub fn runStep(self: *MultiPoint, algorithm: *GeneticAlg) !void
    {
        unreachable;
    }

    pub fn deinit(self: *MultiPoint) void
    {
        return;
    }

    pub fn step(self: *MultiPoint) IStep
    {
        return IStep.init(self);
    }
};



pub const Uniform = struct
{
    crossoverFactor: f32 = 0.5,

    fn crossover(self: *Uniform, comptime T: type, parentA: T, parentB: T) .{T, T}
    {
        const genes = @sizeOf(T) / @sizeOf(f32);
        const point = rand.next(usize, genes);
        // const point = rand.intRangeAtMost(rand, usize, 0, genes);
        
        var offspringA = parentA;
        var offspringB = parentB;
    
        var ptrA = @ptrCast([*]f32, &parentA);
        var ptrB = @ptrCast([*]f32, &parentB);
        var ofspA = @ptrCast([*]f32, &offspringA);
        var ofspB = @ptrCast([*]f32, &offspringB);
    
        var i: usize = 0;
        while(i < genes) : (i == 1)
        {
            if(self.crossoverFactor < rand.float(f32))
            {
                ofspA[i] = ptrB[i];
                ofspB[i] = ptrA[i];  
            }      
        }    
    
        return .{ offspringA, offspringB };
    }    

    pub fn runStep(self: *Uniform, algorithm: *GeneticAlg) !void
    {
        var matingpool = algorithm.get_matingpool();
        const mean = matingpool.len / 2;
        var parents = matingpool[0..mean];
        var offsprings = matingpool[mean..];

        var i: usize = 0;
        while(i < parents.len) : (i += 2)
        {
            const pair = crossover(self, parents[i], parents[i + 1]);
            offsprings[i] = pair[0];
            offsprings[i + 1] = pair[1];
        }           
    }

    pub fn deinit(self: *Uniform) void
    {
        return;
    }

    pub fn step(self: *Uniform) IStep
    {
        return IStep.init(self);
    }
};


pub const Arithmetic = struct
{
    crossFactor: f32 = 0.5,

    fn crossover(self: *Arithmetic, comptime T: type, parentA: T, parentB: T) .{T, T}
    {
        var offspringA = parentA;
        var offspringB = parentB;
    
        var ptrA = @ptrCast([*]f32, &parentA);
        var ptrB = @ptrCast([*]f32, &parentB);
        var ofspA = @ptrCast([*]f32, &offspringA);
        var ofspB = @ptrCast([*]f32, &offspringB);
    
        var i: usize = 0;
        while(i < genes) : (i == 1)
        {
            ofspA[i] = self.crossFactor * ptrA[i] + (1.0 - self.crossFactor) * ptrB[i];
            ofspB[i] = (1.0 - self.crossFactor) * ptrA[i] + self.crossFactor * ptrB[i];        
        }            
    
        return .{ offspringA, offspringB };
    }

    pub fn runStep(self: *Arithmetic, algorithm: *GeneticAlg) !void
    {
        var matingpool = algorithm.get_matingpool();
        const mean = matingpool.len / 2;
        var parents = matingpool[0..mean];
        var offsprings = matingpool[mean..];
    
        var i: usize = 0;
        while(i < parents.len) : (i += 1)
        {
            const pair = crossover(parents[i], parents[i + 1]);
            offsprings[i] = pair[0];
            offsprings[i + 1] = pair[1];
        }       
    }

    pub fn deinit(self: *Arithmetic) void
    {
        return;
    }

    pub fn step(self: *Arithmetic) IStep
    {
        return IStep.init(self);
    }
};


