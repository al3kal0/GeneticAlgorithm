
const std = @import("../std.zig");
const assert = std.debug.assert;
const math = std.math;
const mem = std.mem;
const GeneticAlg = @import("../GeneticAlgorithm.zig").GeneticAlg;

// pub const IStep = struct
// {
    // ptr: *anyopaque,
    // runstep: fn(*anyopaque, comptime T: type, GeneticAlg(T)) void,
    // // deinit: fn(*anyopaque) void,
    // 
    // const Self = @This();
    // const
    // 
    // pub fn init(ptr: anytype) IStep
    // {
        // const Ptr = @TypeOf(ptr);
        // const ptr_info = @typeInfo(Ptr);
// 
        // if (ptr_info != .Pointer) @compileError("ptr must be a pointer");
        // if (ptr_info.Pointer.size != .One) @compileError("ptr must be a single item pointer");
// 
        // const alignment = ptr_info.Pointer.alignment;
        // 
        // const gen = struct
        // {
            // pub fn runstepImpl(pointer: *anyopaque, comptime T: type, algorithm: GeneticAlg(T)) void
            // {
                // const self = @ptrCast(Ptr, @alignCast(alignment, pointer));
                // return @call( .{ .modifier = .always_inline}, ptr_info.Pointer.child.runstep, .{ self, T, algorithm });
            // }
            // 
            // // pub fn deinitImpl(pointer: *anyopaque) void
            // // {
            // //     const self = @ptrCast(Ptr, @alignCast(alignment, pointer));
            // //     return @call( .{ .modifier = .always_inline}, ptr_info.Pointer.child.deinit, .{ self });
            // // }
        // };
        // 
        // return .{
            // .ptr = ptr,
            // .runstep = gen.runstepImpl,
            // // .deinit = gen.deinitImpl,
        // };
    // }
// };

pub const IInitialization = struct
{
    ptr: *anyopaque,
    vtable: *const VTable,
    
    // const Self = @This();

    pub const VTable = struct {
        initialize: initializeProto,
    };

    const initializeProto = fn(ptr: *anyopaque, type, anytype) void;
    
    pub fn init(
        pointer: anytype, 
        comptime initializeFn: fn(ptr: @TypeOf(pointer), type, anytype) void,
    ) IInitialization
    {
        const Ptr = @TypeOf(pointer);
        const ptr_info = @typeInfo(Ptr);

        assert(ptr_info == .Pointer);       // @compileError("ptr must be a pointer");
        assert(ptr_info.Pointer.size == .One); //  @compileError("ptr must be a single item pointer");

        const alignment = ptr_info.Pointer.alignment;
        
        const gen = struct
        {
            pub fn initializeImpl(ptr: *anyopaque, algorithm: anytype) void
            {
                const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
                return @call( .{ .modifier = .always_inline}, initializeFn, .{ self, algorithm });
            }

            const vtable = VTable{
                .initialize = initializeImpl,    
            };
        };
        
        return .{
            .ptr = pointer,
            .vtable = &gen.vtable,
        };
    }
};

// pub const ITermination = struct
// {
    // ptr: *anyopaque,
    // vtable: *const VTable,
// 
    // pub const VTable = struct {
        // terminate: terminateProto,
    // };
// 
    // const terminateProto = fn(ptr: *anyopaque, comptime T: type, GeneticAlg(T)) bool;
    // 
    // // const Self = @This();
    // 
    // pub fn init(
        // ptr: anytype,
        // comptime terminateFn: fn(ptr: *anyopaque, comptime T: type, GeneticAlg(T)) bool,
    // ) ITermination
    // {
        // const Ptr = @TypeOf(ptr);
        // const ptr_info = @typeInfo(Ptr);
// 
        // assert(ptr_info == .Pointer); //  @compileError("ptr must be a pointer");
        // assert(ptr_info.Pointer.size == .One); //  @compileError("ptr must be a single item pointer");
// 
        // const alignment = ptr_info.Pointer.alignment;
        // 
        // const gen = struct
        // {
            // pub fn terminateImpl(pointer: *anyopaque, comptime T: type, algorithm: GeneticAlg(T)) void
            // {
                // const self = @ptrCast(Ptr, @alignCast(alignment, pointer));
                // return @call( .{ .modifier = .always_inline}, terminateFn, .{ self, T, algorithm });
            // }
        // };
// 
        // const vtable = VTable {
            // .terminate = terminateImpl,
        // };
        // 
        // return .{
            // .ptr = ptr,
            // .vtable = &gen.vtable,
        // };
    // }
// };

pub const IFitness = struct
{
    
};

pub const ISelection = struct
{
    
};

pub const ICrossover = struct
{
    
};

pub const IMutation = struct
{
    
};

pub const ISurvival = struct
{
    
};

pub const Steps = struct
{
    buffer: [512]u8,
    steps: [*]anyopaque,
};

