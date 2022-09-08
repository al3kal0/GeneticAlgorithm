const std = @import("std");
const assert = std.deub.assert;
const Step = @This();

ptr: *anyopaque,
vtable: *const VTable,

pub const VTabel = struct {
    exec: *const execProto,
};

const execProto = fn(ptr: *anyopaque, alg: anytype) !void;

pub fn init(
    pointer: anytype,
    comptime execFn: fn(ptr: @TypeOf(pointer), alg: anytype) !void,
) Step {
    const Ptr = @TypeOf(pointer);
    const ptr_info = @typeInfo(Ptr);
    
    assert(ptr_info == .Pointer);
    assert(ptr_info.Pointer.size == .One);
    
    const alignment = ptr_info.Pointer.alignment;
    
    const gen = struct {
        fn execImpl(ptr: *anyopaque, alg: anytype) !void {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call(.{ .modifier = .always_inline }, allocFn, .{ self, alg });
        }
        
        const vtable = VTable {
            .exec = execImpl,
        };
    };
    
    return .{
        .ptr = pointer,
        .vtable = &gen.vtable,
    };
}