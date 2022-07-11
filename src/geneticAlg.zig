const std = @import("std");
const expect = std.testing.expect;
const panic = std.debug.panic;
const allocator = std.heap.page_allocator;

// functions that any type of Population Chromosomes should implement
pub const IChromosome = struct
{
    ptr: *anyopaque,
    initialize: fn(*anyopaque) void,    
    fitness: fn(*anyopaque) f32,
    repair: ?fn(*anyopaque) void,
    constrained: ?fn(*anyopaque) bool,
    randomMutation: ?fn(*anyopaque) void,
    
    const Self = @This();
    
    pub fn init(ptr: anytype) Self
    {
        const Ptr = @TypeOf(ptr);
        const ptr_info = @typeInfo(Ptr);

        if (ptr_info != .Pointer) @compileError("ptr must be a pointer");
        if (ptr_info.Pointer.size != .One) @compileError("ptr must be a single item pointer");

        const alignment = ptr_info.Pointer.alignment;

        const gen = struct
        {
            pub fn initializeImpl(pointer: *anyopaque) void
            {
                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));

                return @call( .{ modifier = .always_inline}, ptr_info.Pointer.child.initialize, .{ self });
            }
        
            pub fn fitnessImpl(pointer: *anyopaque) f32
            {
                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));

                return @call( .{ .modifier = .always_inline}, ptr_info.Pointer.child.fitness, .{ self });
            }

            pub fn repairImpl(pointer: *anyopaque) void
            {
                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));

                return @call( .{.modifier = .always_inline}, ptr_info.Pointer.child.repair, .{self});
            } 

            pub fn constrainedImpl(pointer: *anyopaque) void
            {
                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));

                return @call( .{.modifier = .always_inline}, ptr_info.Pointer.child.constrained, .{self});
            }

            pub fn randomMutationImpl(pointer: *anyopaque) void
            {
                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));

                return @call( .{.modifier = .always_inline}, ptr_info.Pointer.child.randomMutation, .{self});
            }
        };

        return .{
            .ptr = ptr,
            .initialize = gen.initializeImpl,
            .fitness = gen.fitnessImpl,
            .repair = gen.repairImpl,
            .constrained = gen.constrainedImpl,
            .randomMutation = gen.randomMutationImpl,
        };
    }   
};


pub const IStep = struct
{
    ptr: *anyopaque,
    runStep: fn(*anyopaque, algorithm: *GeneticAlg) !void,
    deinit: fn(*anyopaque) void,
    
    const Self = @This();
    
    pub fn init(ptr: anytype) Self
    {
        const Ptr = @TypeOf(ptr);
        const ptr_info = @typeInfo(Ptr);

        if (ptr_info != .Pointer) @compileError("ptr must be a pointer");
        if (ptr_info.Pointer.size != .One) @compileError("ptr must be a single item pointer");

        const alignment = ptr_info.Pointer.alignment;
        
        const gen = struct
        {
            pub fn runStepImpl(pointer: *anyopaque) void
            {
                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));

                return @call( .{ modifier = .always_inline}, ptr_info.Pointer.child.runStep, .{ self });
            }
            
            pub fn deinitImpl(pointer: *anyopaque) void
            {
                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));

                return @call( .{ modifier = .always_inline}, ptr_info.Pointer.child.deinit, .{ self });
            }
        };
        
        return .{
            .ptr = ptr,
            .runStep = gen.runStepImpl,
            .deinit = gen.deinitImpl,
        };
    }
};




pub fn Population(
    comptime T: type,
    comptime count: comptime_int
) type
{
    return struct
    {
        population: []T,
        fitness: []f32,
        generation: []u16,  
        count: u32,  
        const Self = @This();

        pub fn init(allocator: *Allocator) !Self
        {
            return Population
            {
                .population = try allocator.alloc(T, count),
                .fitness = try allocator.alloc(f32, count),
                .generation = try allocator.alloc(u32, count),
                .count = count,
            };           
        }

        pub fn setValues(self: *Self) !Self
        {
            const initialization = T.chromosome().initialize;
        
            for(self.population) |entry|
            {
                initialization(&entry);
            }

            return self.*;
        }

        pub fn deinit(self: *Self, allocator: *Allocator) void
        {
            allocator.free(self.population);
            allocator.free(self.fitness);
            allocator.free(self.generation);
        }

        pub fn sort(self: *Self) void
        {
            var population = self.population;
            var fitness = self.fitness;
            
            var i: usize = 0;
            while(i < population.len - 1) : (i += 1)
            {
                var j: usize = i + 1;
                while(j < population.len) : (j += 1)
                {
                    if(fitness[j] > fitness[i])
                    {
                        const temp = population[i];
                        population[i] = population[j];
                        population[j] = temp;

                        const f = fitness[i];
                        fitness[i] = fitness[j];
                        fitness[j] = f;                                                
                    }
                }
            }
        }        
    };    
}

const PopulationSet = struct
{
    pub fn runStep(self: PopulationSet, algorithm: *GeneticAlg) void
    {
        var population = algorithm.get_population();
        var matingpool = algorithm.get_matingpool();
        var generations = algorithm.population.generations();
        
        var i: usize = 0;
        while(i < population.len) : (i += 1)
        {
            population[i] = matingpool[i];
            generation[i] += 1;
        }
    }
    
    pub fn deinit() void
    {
        return;
    }
    
    pub fn step(self: *PopulationSet) IStep
    {
        return IStep.init(self);
    }
}



pub fn GenetigAlg(
    comptime T: type,
    comptime count: comptime_int    
) type
{
    return struct
    {
        population: Population(T),
        matingpool: Population(T),
        steps: []*IStep,
        converged: bool = false,
        const Self = @This();

        pub inline fn get_population(self: *Self) []T
        {
            return self.population.population;
        }

        pub inline fn get_matingpool(self: *Self) []T
        {
            return self.matingpool.population;
        }

        pub fn deinit(self: *Self) void
        {
            for(steps) |step|
            {
                step.deinit();
            }             
        }

        pub fn run(self: *GenetigAlg) !void
        {
            while(!self.converged)
            {
                for(steps) |step|
                {
                    try step.runStep(self);
                }
            }
        }        
    };
}


test "GeneticAlg"
{
    const allocator = std.heap.page_allocator;
    
    var population = try Population(Experiment, 200).init(allocator).setValues();
    var matingpool = try Population(Experiment, 200).init(allocator);
    defer population.deinit(allocator);
    defer matingpool.deinit(allocator);

    var buffer = [512]u8;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var arena = std.heap.ArenaAllocator.init(fba.allocator());
    defer arena.deinit();
    const _arena = arena.allocator(); 
     
    const steps = [_]IStep
    {
        _arena.create(IStep, FitnessWSGA{}.step()),     // ??? 
        _arena.create(IStep, Selection.Proportional.init(allocator).step()),
        _arena.create(IStep, Crossover.OnePoint{}.step()),
        _arena.create(IStep, Mutation.Scramble{}.step()),
        _arena.create(IStep, PopulationSet{}.step()),
        _arena.create(IStep, Termination.MaxGeneration{}.step()),        
    };
        
    const geneticAlg = GeneticAlg
    {
        .population = population,
        .matingpool = matingpool,
        .steps = steps, 
    };
    defer geneticAlg.deinit();

    try geneticAlg.run();
}


