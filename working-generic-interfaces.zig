// Step.zig

const std = @import("std");
const assert = std.debug.assert;
const Generic = @import("main.zig").Generic;


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

pub fn Generic(comptime T: type) type {
    return struct {
        val0: T,
        val1: T,
        term_condition: bool,
        
        const Self = @This();
        
        pub fn create() !Self {
            return .{
                .val0 = undefined,
                .val1 = undefined,
                .term_condition = false,               
            };
        }
        
        pub fn initialize(alg: *Self, init: *Step(T)) void {
            init.exec(alg);
        }
    };
}

const TermStep = struct {
    iteration: u32,
    max_iterations: u32,
    
    fn term(self: *TermStep, alg: *Generic(f32)) void {
        self.iteration += 1;
        alg.term_condition = self.iteration >= self.max_iterations;
    }
    
    pub fn step(self: *TermStep) Step(f32) {
        return Step(f32).init(self, term);
    }
        
};

test "test interface" {
    var generic = try Generic(f32).create();
    var term_step = TermStep{ .iteration = 0, .max_iterations = 30 };
    var term = term_step.step();
    
    generic.initialize(&term);
    
}

// end of file main.zig
