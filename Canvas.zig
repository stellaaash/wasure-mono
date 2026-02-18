const std = @import("std");
const Vec3 = @import("Vec3.zig").Vec3;
const scene = @import("root").scene;

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

    /// Set a pixel's color, with the origin to the top left of the canvas
    fn set(self: *Canvas, x: usize, y: usize, color: u24) void {
        self.data[y * self.width + x] = color;
    }

    /// Convert a pixel on the canvas to a Vector pointing to the point on the 3D viewport
    pub fn to_viewport(self: *const Canvas, x: i32, y: i32) Vec3 {
        const fx: f64 = @floatFromInt(x);
        const fy: f64 = @floatFromInt(y);
        const fw: f64 = @floatFromInt(self.width);
        const fh: f64 = @floatFromInt(self.height);
        return Vec3{
            .x = fx * scene.viewport_aspect_ratio / fw,
            .y = fy * scene.viewport_aspect_ratio / fh,
            .z = scene.projection_plane_d,
        };
    }

    /// Put a pixel on the canvas, using a coordinate system with the origin
    /// at the center of the canvas
    pub fn put_pixel(self: *Canvas, x: i32, y: i32, color: u24) void {
        std.debug.assert(x < self.width);
        std.debug.assert(y < self.height);

        const half_width: i32 = @intCast(self.width / 2);
        const half_height: i32 = @intCast(self.width / 2);
        const converted_x: usize = @intCast(x + half_width);
        const converted_y: usize = @intCast(y + half_height);

        self.set(converted_x, converted_y, color);
    }

    pub fn write_to_file(self: *Canvas, path: []const u8) !void {
        std.fs.cwd().deleteFile(path) catch {};
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();

        var buffer: [2048]u8 = undefined;

        // Create a writer that will borrow the buffer
        var file_writer = file.writer(&buffer);
        const writer_interface: *std.Io.Writer = &file_writer.interface;

        try writer_interface.print("P3\n", .{});
        try writer_interface.print("{} {}\n", .{ self.width, self.height });
        try writer_interface.print("255\n", .{});

        var y: u32 = 0;
        while (y < self.height) : (y += 1) {
            var x: u32 = 0;
            while (x < self.width) : (x += 1) {
                const color = self.get(x, y);
                const r = color >> 16 & 0xFF;
                const g = color >> 8 & 0xFF;
                const b = color >> 0 & 0xFF;

                try writer_interface.print("{} {} {}", .{ r, g, b });
                if (x < self.width - 1) {
                    try writer_interface.print("\t", .{});
                }
            }
            try writer_interface.print("\n", .{});
        }
        try writer_interface.flush();
    }
};
