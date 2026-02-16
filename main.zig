const std = @import("std");

const Canvas = struct {
    width: u32,
    height: u32,
    data: []u8, // A single slice representing all the canvas
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, width: u32, height: u32) !Canvas {
        const data = try allocator.alloc(u8, width * height);
        return Canvas{
            .width = width,
            .height = height,
            .data = data,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Canvas) void {
        self.allocator.free(self.data);
    }

    pub fn get(self: *const Canvas, x: u32, y: u32) u8 {
        return self.data[y * self.height + x];
    }

    pub fn set(self: *const Canvas, x: u32, y: u32, color: u8) void {
        self.data[y * self.height + x] = color;
    }
};

pub fn main() void {
    var alloc: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = alloc.allocator();

    const canvas = Canvas.init(gpa, 25, 25);
    defer canvas.deinit();

    std.debug.print("Canvas: {} {}", .{ canvas.width, canvas.height });
}
