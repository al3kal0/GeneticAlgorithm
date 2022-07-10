const std = @import("std");
const GeneticAlg = @import("geneticAlg.zig");


const prng = std.rand.DefaultPrng.init(blk: {
                            var seed: u64 = undefined;
                            try std.os.getrandom(std.mem.asBytes(&seed));
                            break :blk seed;
                        });
const rand = prng.random();


inline fn bitflip_mutation(comptime T: type, chromosome: *T) void
{
    const mutation = switch(rand.intRangeAtMost(u8, 0, 6))
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

    const offset = rand.intRangeAtMost(usize, @sizeOf(T) - @sizeOf(u8));
    var ptr = @ptrCast([*]u8, chromosome)
    ptr[offset].* ^= mutation;
    ptr[offset].chromosome().repair();
}

pub fn bitflip(algorithm: *GeneticAlg) void
{
    var population = algorithm.get_population();

    var i: usize = 0;
    while(i < population.len) : (i += 1)
    {
        if(MutationFactor > rand.float(f32))
        {
            bitflip_mutation(&population[i])               
        }        
    }   
}

pub fn random(algorithm: *GeneticAlg) void
{
    const MutationFactor = 0.1;
    var population = algorithm.get_population();

    var i: usize = 0;
    while(i < population.len) : (i += 1)
    {
        if(MutationFactor > rand.float(f32))
        {
            population[i].chromosome().randomMutation();
        }
    }
}

fn scramble_mutation(comptime T: type, chromosome: *T, offset: usize) void
{
    var _ptr = @ptrCast([*]u8, chromosome) + offset;
    var ptr = @ptrCast([*]u32, _ptr);

    ptr[0] ^= rand.int(u32);
    ptr[1] ^= rand.int(u32);
    ptr[2] ^= rand.int(u32);

    chromosome.chromosome().repair();
}

pub fn scramble(algorithm: *GeneticAlg) void
{
    const MutationFactor = 0.5;
    const MutationSize = 12;
    var population = algorithm.get_population();

    var i: usize = 0;
    while(i < population.len) : (i += 1)
    {
        if(MutationFactor > rand.float(f32))
        {
            const offset = rand.intRangeAtMost(usize, 0, @sizeOf(T) - MutationSize);
            scramble_mutation(&population[i], offset);
        }
    }
}

pub fn swap(algorithm: *GeneticAlg) void
{
    panic("not implemented yet\n", .{});
}

pub fn inversion(algorithm: *GeneticAlg) void
{
    panic("not implemented yet\n", .{});    
}
