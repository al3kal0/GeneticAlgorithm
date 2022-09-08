const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator; // std.heap.page_allocator;
const test_allocator = std.testing.allocator;

const Step = @import("Step.zig");
const Termination = @import("Termination.zig");
const Initialization = @import("Initialization.zig");

pub fn GeneticAlg(comptime T: type) type {
    // if(@typeInfo(@TypeOf(T)) !=  .Struct) @compileError("Type must be a Struct");

    return struct {
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
        term_condition: bool,
        allocator: Allocator,

        const Self = @This();
        pub const InnerType = @TypeOf(T);

        pub fn create(allocator: Allocator, max_size: usize) !Self {
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
                .allocator = allocator,
            };
        }

        pub fn destroy(self: Self) void {
            self.allocator.free(self.population);
            self.allocator.free(self.matingpool);
            self.allocator.free(self.population_fitness);
            self.allocator.free(self.matingpool_fitness);
            self.allocator.free(self.population_generations);
            self.allocator.free(self.matingpool_generations);
        }
        
        pub fn initialize(alg: Self, init_method: Initialization) void
        {
            init_method.initialize(alg);
        }
        
        pub fn run(alg: Self, steps: []Step) !void
        {   
            while(!alg.term_condition)
            {
                for(steps) |step| {
                    step.exec(alg);        
                }                                       
            }
        }

        pub fn sort(self: *Self) void {
            const population = self.population;
            const fitness = self.population_fitness;
            const generations = self.population_generations;
            const count = self.population_count;

            var i: usize = 0;
            while (i < count - 1) : (i += 1) {
                var j: usize = i + 1;
                while (j < count) : (j += 1) {
                    if (fitness[j] > fitness[i]) {
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


test "geneteicAlg test"
{        
    var rand_init = RandomInitialization.initialization();
    var algorithm = try GeneticAlg(Experiment).create(test_allocator, 200);
    defer algorithm.destroy();
    
    algoritm.initialize(rand_init);
    algorithm.run();
    
}

const Experiment = struct {
        mr: f32,
        sr: f32,
        cin: f32,
        time: f32,
        temp: f32,
    };
    
    const RandomInitialization = struct {
        
        const Self = @This();
        
        fn init(self: *Self, comptime alg: GeneticAlg(Experiment)) void {
            _ = self;
            
            const population = alg.population;
            
            for(population) |*chrom| {
                chrom.mr = 0.0;
                chrom.sr = 0.0;
                chrom.temp = 0.0;
                chrom.time = 0.0;
                chrom.cin = 0.0;          
            }
        }
        
        pub fn initialization(self: *Self) Initialization {
            return Initialization.init(self, init);
        }
    };
    
    const MaxGenTermination = struct {
        iteration: u32 = 0,
        max_iterations: u32 = 30,
    
        const Self = @This();
        
        fn term(self: *Self, comptime alg: GeneticAlg(Experiment)) bool {
            _ = alg;
            self.iteration += 1;                        
            return self.iteration >= self.max_iterations;
        }
        
        pub fn termination(comptime self: *Self) Termination {
            return Termination.init(self, term);
        }
    };
