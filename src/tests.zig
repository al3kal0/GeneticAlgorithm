const std = @import("std");
const expect = std.testing.expect;

const AA = struct
{
    const string = "aaabbbbccccdddddeeeeefffff\n"; // some other struct
    
    a: f32,
    b: f32,
    c: f32,
    
};

test "AA"
{
    const aa = AA{ .a = 1.0, .b = 2.0, .c = 4.0 };
    std.debug.print("{}\n", .{aa});

    try expect(aa.b == 2.0);
    try expect(@sizeOf(AA) == 12);
}
