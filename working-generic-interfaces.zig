// Step.zig

const std = @import("std");
const assert = std.debug.assert;
const Generic = @import("main.zig").Generic;

// Runtime interface <-------

pub fn Step(comptime T: type) type {
   
    const execProto = fn(ptr: *anyopaque, *Generic(T)) void;

    const VTable = struct {
        exec: *const execProto,
    };
    
    
    return struct {
        ptr: *anyopaque,
        vtable: *const VTable,
        
        const Self = @This();
        
        pub fn init(
            pointer: anytype,
            comptime execFn: fn(ptr: @TypeOf(pointer), alg: *Generic(T)) void,
        ) Self {
            
            const Ptr = @TypeOf(pointer);
            const ptr_info = @typeInfo(Ptr);
            
            assert(ptr_info == .Pointer);
            assert(ptr_info.Pointer.size == .One);
            
            const alignment = ptr_info.Pointer.alignment;
            
            const gen = struct {
                fn execImpl(ptr: *anyopaque, alg: *Generic(T)) void {
                    const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
                    return @call( .{ .modifier = .always_inline }, execFn, .{ self, alg });
                }
                
                const vtable = VTable{
                    .exec = execImpl,
                };
            };
            
            return .{
                .ptr = pointer,
                .vtable = &gen.vtable,
            };
            
        }
    
    
        pub fn exec(self: *Self, alg: *Generic(T)) void {
            self.vtable.exec(self, alg);
        }
    };
}


// end of file Step.zig

// main.zig
const std = @import("std");
const Allocator = std.mem.Allocator;
const Step = @import("Step.zig").Step;
const test_allocator = std.testing.allocator;

pub fn Generic(comptime T: type) type {
    return struct {
        val0: T,
        val1: T,
        buffer: []T,
        term_condition: bool,
        allocator: Allocator,
        
        const Self = @This();
        
        pub fn create(allocator: Allocator) !Self {
            return .{
                .val0 = undefined,
                .val1 = undefined,
                .buffer = try allocator.alloc(T, 200),
                .term_condition = false,              
                .allocator = allocator, 
            };
        }
        
        pub fn destroy(self: *Self) void {
            self.allocator.free(self.buffer);
        }
        
        pub fn initialize(alg: *Self, init: *Step(T)) void {
            init.exec(alg);
        }
        
        pub fn run(alg: *Self, init: *Step(T), term: *Step(T)) void {
            init.exec(alg);
            while(!alg.term_condition) {
               term.exec(alg); 
            }
        }
    };
}



test "test interface" {
    
    const Experiment = struct {
        time: f32,
        temp: f32,       
    };
    
    const InitStep = struct {
        val: u8,
        
        const Self = @This();
        
        fn init(self: *Self, alg: *Generic(Experiment)) void {
            _ = self;
            for(alg.buffer) |*chrom| {
                chrom.* = Experiment{ .time = 56.4, .temp = 102.8 };
            }
        }
        
        pub fn step(self: *Self) Step(Experiment) {
            return Step(Experiment).init(self, init);
        }
    };
    
    const TermStep = struct {
        iteration: u32,
        max_iterations: u32,
        
        const Self = @This();
        
        fn term(self: *Self, alg: *Generic(Experiment)) void {
            self.iteration += 1;
            alg.term_condition = self.iteration >= self.max_iterations;
        }
        
        pub fn step(self: *Self) Step(Experiment) {
            return Step(Experiment).init(self, term);
        }
            
    };
    
    var generic = try Generic(Experiment).create(test_allocator);
    defer generic.destroy();
    var init_step = InitStep{ .val = undefined };
    var term_step = TermStep{ .iteration = 0, .max_iterations = 30 };
    var _term = term_step.step();
    var _init = init_step.step();
    
    generic.run(&_init, &_term);
    
}

// end of file main.zig



// -------------------------------------------------------------------------------------------



// Comptime interface <---------

pub fn Generic(comptime T: type) type {
    return struct {
        val0: T,
        val1: T,
        val2: T,
    };
}

pub fn Initialization(
    comptime T: type,
    comptime Context: type,
    comptime initFn: fn(*Context, *Generic(T)) void,
) type {
    return struct {
        context: Context,
        
        const Self = @This();
        
        pub fn init(self: *Self, alg: *Generic(T)) void {
            initFn(&self.context, alg);
        }
    };
}

pub const RandomInit = struct {
    iteration: u32 = 0,
    
    const Self = @This();
    pub const Init = Initialization(V, Self, initImpl);
    
    fn initImpl(self: *Self, generic: *Generic(V)) void {
        self.iteration += 1;
        generic.val0.v0 = 0.89;
    }
    
    // copies context as a field to the interface
    pub fn initialization(self: Self) Init {
        return .{ .context = self };    
    }
};


// target struct
    const V = struct {
        v0: f32,
        v1: f32,
        v2: f32,
    };

test "test interface" {
    
    var genv = Generic(V){ .val0 = undefined, .val1 = undefined, .val2 = undefined };
    var rand_init = RandomInit{}; 
    var interface = rand_init.initialization();
    
    interface.init(&genv);
    try std.testing.expect(genv.val0.v0 == 0.89);
    try std.testing.expect(interface.context.iteration == 1);
}


