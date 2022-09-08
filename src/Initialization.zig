const std = @import("std");
const assert = std.debug.assert;
const Initialization = @This();


ptr: *anyopaque,
vtable: *const VTable,

pub  const VTable = struct {       
    initialize: *const initializeProto,    
};


const initializeProto = fn(ptr: *anyopaque, alg: anytype) void;


pub fn init(
    pointer: anytype,
    comptime initializeFn: fn(ptr: @TypeOf(pointer), alg: anytype) void,
) Initialization {
    const Ptr = @TypeOf(pointer);
    const ptr_info = @typeInfo(Ptr);
    
    assert(ptr_info == .Pointer);
    assert(ptr_info.Pointer.size == .One);
    
    const alignment = ptr_info.Pointer.alignment;
    
    const gen = struct {
        fn initializeImpl(ptr: *anyopaque, alg: anytype) void {
            const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
            return @call( .{ .modifier = .always_inline }, initializeFn, .{ self, alg });
        }     
        
        const vtable = VTable {
            .initialize = initializeImpl,
        };
    };
        
    return .{
       .ptr = pointer,
       .vtable = &gen.vtable,
    };
}