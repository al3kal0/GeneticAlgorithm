const std = @import("std");
const panic = std.debug.panic;
const algorithm = @import("GeneticAlg.zig");

const prng = std.rand.DefaultPrng.init(blk: {
                            var seed: u64 = undefined;
                            try std.os.getrandom(std.mem.asBytes(&seed));
                            break :blk seed;
                        });
const rand = prng.random();
pub var crossoverFactor: f32 = 0.5;
pub var CrossFactor: f32 = 0.5;

fn one_point_crossover(comptime T: type, parentA: T, parentB: T) .{T, T}
{
    const genes = @sizeOf(T) / @sizeOf(f32);
    const point = rand.intRangeAtMost(rand, usize, 0, genes);
    
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

pub fn onePoint(algorithm: *GeneticAlg) void
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
        const pair = one_point_crossover(parents[i], parents[i + 1]);
        offsprings[i] = pair[0];
        offsprings[i + 1] = pair[1];
    }
}

pub fn multiPoint(algorithm: *GeneticAlg) void
{
    unreachable;    
}


fn uniform_crossover(comptime T: type, parentA: T, parentB: T) .{T, T}
{
    const genes = @sizeOf(T) / @sizeOf(f32);
    const point = rand.intRangeAtMost(rand, usize, 0, genes);
    
    var offspringA = parentA;
    var offspringB = parentB;

    var ptrA = @ptrCast([*]f32, &parentA);
    var ptrB = @ptrCast([*]f32, &parentB);
    var ofspA = @ptrCast([*]f32, &offspringA);
    var ofspB = @ptrCast([*]f32, &offspringB);

    var i: usize = 0;
    while(i < genes) : (i == 1)
    {
        if(crossoverFactor < rand.float(f32))
        {
            ofspA[i] = ptrB[i];
            ofspB[i] = ptrA[i];  
        }      
    }    

    return .{ offspringA, offspringB };
} 

pub fn uniform(algorithm: *GeneticAlg, param: anytype) void
{
    var matingpool = algorithm.get_matingpool();
    const mean = matingpool.len / 2;
    var parents = matingpool[0..mean];
    var offsprings = matingpool[mean..];

    var i: usize = 0;
    while(i < parents.len) : (i += 2)
    {
        const pair = uniform_crossover(parents[i], parents[i + 1]);
        offsprings[i] = pair[0];
        offsprings[i + 1] = pair[1];
    }
}

fn arithmetic_crossover(comptime T: type, parentA: T, parentB: T) .{T, T}
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
        ofspA[i] = CrossFactor * ptrA[i] + (1.0 - CrossFactor) * ptrB[i];
        ofspB[i] = (1.0 - CrossFactor) * ptrA[i] + CrossFactor * ptrB[i];        
    }            

    return .{ offspringA, offspringB };
}

pub fn arithmetic(algorithm: *GeneticAlg) void
{
    var matingpool = algorithm.get_matingpool();
    const mean = matingpool.len / 2;
    var parents = matingpool[0..mean];
    var offsprings = matingpool[mean..];

    var i: usize = 0;
    while(i < parents.len) : (i += 1)
    {
        const pair = arithmetic_crossover(parents[i], parents[i + 1]);
        offsprings[i] = pair[0];
        offsprings[i + 1] = pair[1];
    }        
}
