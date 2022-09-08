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

pub fn onepoint(comptime T: type,  algorithm: *GeneticAlg(T), genes: u32) void
{
    var matingpool = algorithm.matingpool;
    var mean = matingpool.len / 2;
    var parents = matingpool[0..mean];
    var offsprings = matingpool[mean..];    

    var i: usize = 0;
    while(i < parents.len) : (i += 2)
    {
        const  point = rand.next(1, genes - 1);
        var parentA = parents[i + 0];
        var parentB = parents[i + 1];
        var offspringA = offsprings[i + 0];
        var offspringB = offsprings[i + 1];
        
        offspringA.* = parentA.*;
        offspringB.* = parentB.*;

        var j: usize = @intCast(usize, point);
        while(j < genes) : (j += 1)
        {
            offspringA[j] = parentB[j];
            offspringB[j] = parentA[j];    
        }        
    }
}


pub fn multipoint(comptime T: type, algorithm: *GeneticAlg(T)) void
{
    var matingpool = algorithm.Matingpool;
    var mean = matingpool.Length / 2;
    var parents = matingpool[0..mean];
    var offsprings = matingpool[mean..];    

    var i: usize = 0;
    while(i < parents.len) : (i += 2)
    {        
        var parentA = parents[i + 0];
        var parentB = parents[i + 1];
        var offspringA = offsprings[i + 0];
        var offspringB = offsprings[i + 1];

        const points: [2]usize = undefined;
        points[0] = rand.next(1, genes - 2);
        points[1] = rand.next(points[0], genes - 1);
        
        offspringA.* = parentA.*;
        offspringB.* = parentB.*;

        var j: usize = @intCast(usize, points[0]);
        while(j < points[1]) : (j += 1)
        {
            offspringA[j] = parentB[j];
            offspringB[j] = parentA[j];    
        }        
    }
}

pub fn uniform(comptime T: type, algorithm: *GeneticAlg(T), crossover_factor: f32) void
{
    var matingpool = algorithm.Matingpool;
    var mean = matingpool.Length / 2;
    var parents = matingpool[0..mean];
    var offsprings = matingpool[mean..];

    var i: usize = 0;
    while(i < parents.len) : (i += 2)
    {        
        var parentA = parents[i + 0];
        var parentB = parents[i + 1];
        var offspringA = offsprings[i + 0];
        var offspringB = offsprings[i + 1];
        
        offspringA.* = parentA.*;
        offspringB.* = parentB.*;

        var j: usize = genes;
        while(j < points[1]) : (j += 1)
        {
            if(crossover_factor < rand.nextdouble())
            {
                offspringA[j] = parentB[j];
                offspringB[j] = parentA[j];                    
            }
        }        
    }
}


pub fn arithmetic(comptime T: type, algorithm: *GeneticAlg(T), crossFactor: f32) void
{
    var matingpool = algorithm.Matingpool;
    var mean = matingpool.Length / 2;
    var parents = matingpool[0..mean];
    var offsprings = matingpool[mean..];

    var i: usize = 0;
    while(i < parents.len) : (i += 2)
    {        
        var parentA = parents[i + 0];
        var parentB = parents[i + 1];
        var offspringA = offsprings[i + 0];
        var offspringB = offsprings[i + 1];
        
        offspringA.* = parentA.*;
        offspringB.* = parentB.*;

        var j: usize = genes;
        while(j < points[1]) : (j += 1)
        {
            if(crossover_factor < rand.nextdouble())
            {
                offspringA[j] = CrossFactor * parentA[j] + (1 - CrossFactor) * parentB[j];
                offspringB[j] = (1 - crossFactor) * parentA[j] + CrossFactor * parentB[j];                  
            }
        }        
    }
}
