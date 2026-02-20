const std = @import("std");
const Canvas = @import("Canvas.zig").Canvas;
const Point3 = @import("Point3.zig").Point3;
const Vec3 = @import("Vec3.zig").Vec3;
const Sphere = @import("Sphere.zig").Sphere;
const Scene = @import("Scene.zig").Scene;

const canvas_width = 1080;
const canvas_height = 1080;
const background_color: u24 = 0x222222;

pub const scene = Scene{
    .spheres = [_]Sphere{ Sphere{
        .position = Point3{ .x = 0, .y = 0, .z = 3 },
        .color = 0xFF0000,
        .radius = 1,
    }, Sphere{
        .position = Point3{ .x = -1, .y = 1, .z = 4 },
        .color = 0x00FF00,
        .radius = 1,
    }, Sphere{
        .position = Point3{ .x = 1, .y = -1, .z = 2 },
        .color = 0x0000FF,
        .radius = 1,
    } },
    .projection_plane_d = 1,
    .viewport_aspect_ratio = 1,
};

/// Trace a ray through 3D space to determine a pixel's color.
fn trace_ray(origin: Point3, direction: Vec3, start: f64, finish: f64) u24 {
    var closest_t = std.math.inf(f64);
    var closest_color: u24 = background_color;

    for (&scene.spheres) |*sphere| {
        const t = sphere.intersect_ray(origin, direction);
        if (t[0] >= start and t[0] <= finish and t[0] < closest_t) {
            closest_t = t[0];
            closest_color = sphere.color;
        }
        if (t[1] >= start and t[1] <= finish and t[1] < closest_t) {
            closest_t = t[1];
            closest_color = sphere.color;
        }
    }
    return closest_color;
}

pub fn main() !void {
    var alloc: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = alloc.allocator();

    var canvas = try Canvas.init(gpa, canvas_width, canvas_height);
    defer canvas.deinit();

    // Main loop
    const origin = Point3{ .x = 0, .y = 0, .z = 0 };
    var y: i32 = -canvas_height / 2;
    while (y < canvas_height / 2) : (y += 1) {
        var x: i32 = -canvas_width / 2;
        while (x < canvas_width / 2) : (x += 1) {
            const direction = canvas.to_viewport(x, y);
            const color = trace_ray(origin, direction, 1, std.math.inf(f32));
            canvas.put_pixel(x, y, color);
        }
    }

    try canvas.write_to_file("out.ppm");
}
