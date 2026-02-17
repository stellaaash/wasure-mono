const std = @import("std");
const Canvas = @import("Canvas.zig").Canvas;

pub fn main() !void {
    var alloc: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = alloc.allocator();

    var canvas = try Canvas.init(gpa, 25, 25);
    defer canvas.deinit();

    std.debug.print("Canvas: {} by {}\n", .{ canvas.width, canvas.height });
}
