const std = @import("std");
const Vec3 = @import("Vec3.zig").Vec3;

const Point3 = struct { x: f32, y: f32, z: f32 };

pub const Canvas = struct {
    width: usize,
    height: usize,
    data: []u24, // A single slice representing all the canvas
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Canvas {
        const data = try allocator.alloc(u24, width * height);
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

    pub fn get(self: *const Canvas, x: usize, y: usize) u24 {
        return self.data[y * self.width + x];
    }

    // Set a pixel's color, with the origin to the top left of the canvas
    fn set(self: *Canvas, x: usize, y: usize, color: u24) void {
        self.data[y * self.width + x] = color;
    }

    pub fn to_viewport(x: i32, y: i32) Vec3 {
        // TODO: Viewport size shouldn't be canvas size
        // 1 should be the viewport's width, height and its distance from the origin
        return Vec3{ .x = @floatFromInt(x * 1), .y = @floatFromInt(y * 1), .z = @floatFromInt(1) };
    }

    // Put a pixel on the canvas, using a coordinate system with the origin
    // at the center of the canvas
    pub fn put_pixel(self: *Canvas, x: usize, y: usize, color: u24) void {
        std.debug.assert(x < self.width);
        std.debug.assert(y < self.height);
        const converted_x = x + self.width / 2;
        const converted_y = y - self.height / 2;

        self.set(converted_x, converted_y, color);
    }
};
