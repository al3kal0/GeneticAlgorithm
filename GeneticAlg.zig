const std = @import("std");
// const builtin = @import("builtin");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator; // std.heap.page_allocator;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

const interfaces = @import("interfaces.zig");
const IStep = interfaces.IStep;
const IInitialization = interfaces.IInitialization;
const ITermination = interfaces.ITermination;

pub fn GeneticAlg(comptime T: type) type
{
    // if(@typeInfo(@TypeOf(T)) !=  .Struct) @compileError("Type must be a Struct");
    
    return struct
    {
        population: []T,
        matingpool: []T,
        population_fitness: []f32,    
        matingpool_fitness: []f32,    
        population_generations: []u32,
        matingpool_generations: []u32,
        population_count: usize,
        matingpool_count: usize,
        population_maxSize: usize,
        iterations: u32,  
        // steps: []IStep,
        allocator: Allocator,

        const Self = @This();
        pub const InnerType = @TypeOf(T);        

        pub fn init(allocator: Allocator, max_size: usize) !Self
        {
            return Self{
                .population = try allocator.alloc(T, max_size),
                .matingpool = try allocator.alloc(T, max_size),  
                .population_fitness = try allocator.alloc(f32, max_size),
                .matingpool_fitness = try allocator.alloc(f32, max_size),
                .population_generations = try allocator.alloc(u32, max_size),
                .matingpool_generations = try allocator.alloc(u32, max_size),
                .population_count = 0,
                .matingpool_count = 0,
                .population_maxSize = max_size,
                .iterations = 0,
                // .steps = undefined,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void
        {
            self.allocator.free(self.population);
            self.allocator.free(self.matingpool);
            self.allocator.free(self.population_fitness);
            self.allocator.free(self.matingpool_fitness);
            self.allocator.free(self.population_generations);
            self.allocator.free(self.matingpool_generations);
        }

        // pub fn addStep(self: *Self, step: IStep) *Self
        // {
            // try self.steps.append(step);
            // 
            // return self;
        // }

        pub fn run(self: Self, comptime _init: IInitialization) void // , _term: ITermination) void
        {           
            _init.initialize(&self);

            // while(!_term.terminate(&self))
            // {
                // // for(self.steps) |step|
                // // {
                    // // step.runstep(self);
                    // // self.iterations += 1;
                // // }
                // continue;
            // }
        }

        pub fn sort(self: *Self) void
        {
            const population = self.population;
            const fitness = self.population_fitness;
            const generations = self.population_generations;
            const count = self.population_count;
        
            var i: usize = 0;
            while(i < count - 1) : (i += 1)
            {                 
                var j: usize = i + 1;
                while(j < count) : (j += 1)
                {
                    if(fitness[j] > fitness[i])
                    {
                        var _chrom = population[i];
                        population[i] = population[j];
                        population[j] = _chrom;

                        var _fit = fitness[i];
                        fitness[i] = fitness[j];
                        fitness[j] = _fit;

                        var _gen = generations[i];
                        generations[i] = generations[j];
                        generations[j] = _gen; 
                    }
                }
            }
        }
    };  
}


const Experiment = struct
{
    time: f32,
    temp: f32,
    cna2O: f32,
    sr: f32,
    mr: f32,

    const Self = @This();

    pub fn step(self: Self) IStep
    {
        return IStep.init(&self);
    }
};


/// initialize population
fn init_population(algorithm: GeneticAlg(Experiment)) void
{
    const population = algorithm.population;

    for(population) |*chromosome|
    {
         chromosome.* = Experiment{
                .temp = 0.0,
                .time = 0.0,
                .cna2O = 0.0,
                .sr = 0.0,
                .mr = 0.0,    
            };
    }
}

fn init_population_generic(comptime T: type, algorithm: anytype) void
{
    const alg: GeneticAlg(T) = @as(GeneticAlg(T), algorithm);    
    const population = alg.population; 

    for(population) |*chromosome|
    {
         chromosome.* = Experiment{
                .temp = 0.0,
                .time = 0.0,
                .cna2O = 0.0,
                .sr = 0.0,
                .mr = 0.0,    
            };
    }
}

fn init_population_generic_2(comptime T: type, algorithm: GeneticAlg(T)) void
{
    const population = algorithm.population; 

    for(population) |*chromosome|
    {
         chromosome.* = Experiment{
                .temp = 0.0,
                .time = 0.0,
                .cna2O = 0.0,
                .sr = 0.0,
                .mr = 0.0,    
            };
    }
}

test "generic"
{
    var algorithm = try GeneticAlg(Experiment).init(test_allocator, 200);
    defer algorithm.deinit();

    init_population(algorithm);
    init_population_generic(Experiment, algorithm);
    init_population_generic_2(Experiment, algorithm);
}


test "genetic algorithm"
{
    
    var algorithm = try GeneticAlg(Experiment).init(test_allocator, 200);
    defer algorithm.deinit();

    var zeroinit = ZeroInit{};
    // var maxgen = MaxGen{ .max_generation = 20};
     

    algorithm.run(
        zeroinit.initialization(),
        // maxgen.termination(Experiment),
        );
}

const ZeroInit = struct
{
    pub fn initialize(self: *ZeroInit, comptime T: type, algorithm: GeneticAlg(T)) void
    {
        _ = self;
        const population = algorithm.population;
        for(population) |*chromosome|
        {
            chromosome.* = Experiment{
                .temp = 0.0,
                .time = 0.0,
                .cna2O = 0.0,
                .sr = 0.0,
                .mr = 0.0,    
            };
        }
    }

    pub fn initialization(self: *ZeroInit) IInitialization
    {
        return IInitialization.init(self, initialize);
    }
};

// const MaxGen = struct
// {
    // generation: u32 = 0,
    // max_generation: u32,
// 
    // pub fn terminate(self: *MaxGen, comptime T: type, algorithm: GeneticAlg(T)) bool
    // {
        // self.generation += 1;
        // _ = algorithm;
        // 
        // return self.generation >= self.max_generation;
    // }
// 
    // pub fn termination(self: MaxGen, comptime T: type) ITermination
    // {
        // return ITermination.init(&self, terminate);
    // }
// };
