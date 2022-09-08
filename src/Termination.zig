const std = @import("zig");
const assert = std.debug.assert;
const Termination = @This();

ptr: *anyopaque,
vtable: *const VTable,

pub const VTable = struct {
    terminate: *const terminateProto,
};

const terminateProto = fn(ptr: *anyopaque, alg: anytype) bool;

pub fn init(
    pointer: anytype,
    comptime terminateFn: fn(ptr: @TypeOf(pointer), alg: anytype) bool,
) Termination {
    const Ptr = @TypeOf(pointer);
    const ptr_info = @typeInfo(Ptr);    
    
    assert(ptr_info == .Pointer);
    assert(ptr_info.Pointer.size == .One);
    
    const alignment = ptr_info.Pointer.alignment;
    
    const gen = struct {
        fn terminateImpl(ptr: *anyopaque, alg: anytype) bool {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call( .{ .modifier = .always_inline }, terminateFn, .{ self, alg });
        }
        
        const vtable = VTable {
            .terminate = terminateImpl,
        };
    };

    return .{
        .ptr = pointer,
        .vtable = &gen.vtable,        
    };    
}
