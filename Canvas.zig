const std = @import("std");

const Point3 = struct { x: f32, y: f32, z: f32 };
const Vec3 = struct { x: f32, y: f32, z: f32 };

pub const Canvas = struct {
    width: u32,
    height: u32,
    data: []u24, // A single slice representing all the canvas
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, width: u32, height: u32) !Canvas {
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

    pub fn get(self: *const Canvas, x: u32, y: u32) u24 {
        return self.data[y * self.width + x];
    }

    // Set a pixel's color, with the origin to the top left of the canvas
    fn set(self: *Canvas, x: u32, y: u32, color: u24) void {
        self.data[y * self.width + x] = color;
    }

    pub fn to_viewport(x: u32, y: u32) Vec3 {
        // TODO: Viewport size shouldn't be canvas size
        // 1 should be the viewport's width, height and its distance from the origin
        return Vec3{ .x = x * 1, .y = y * 1, .z = 1 };
    }

    // Put a pixel on the canvas, using a coordinate system with the origin
    // at the center of the canvas
    pub fn put_pixel(self: *Canvas, x: u32, y: u32, color: u32) void {
        std.debug.assert(x < self.width);
        std.debug.assert(y < self.height);
        const converted_x = x + self.width / 2;
        const converted_y = y - self.height / 2;

        self.set(converted_x, converted_y, color);
    }
};
