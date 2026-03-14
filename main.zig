const std = @import("std");
const Canvas = @import("Canvas.zig").Canvas;
const Point3 = @import("Point3.zig").Point3;
const Vec3 = @import("Vec3.zig").Vec3;
const Sphere = @import("Sphere.zig").Sphere;
const Light = @import("Light.zig").Light;
const Scene = @import("Scene.zig").Scene;
const Color = @import("Color.zig").Color;

const canvas_width = 1080;
const canvas_height = 1080;
const background_color: Color = Color{ .r = 22, .g = 22, .b = 22 };

pub const scene = Scene{
    .spheres = [_]Sphere{ Sphere{
        .position = Point3{ .x = 0, .y = 0, .z = 3 },
        .color = Color{ .r = 1.0, .g = 0.0, .b = 0.0 },
        .radius = 1,
        .specular = 10,
    }, Sphere{
        .position = Point3{ .x = -1, .y = 1, .z = 4 },
        .color = Color{ .r = 0.0, .g = 1.0, .b = 0.0 },
        .radius = 1,
        .specular = 500,
    }, Sphere{
        .position = Point3{ .x = 1, .y = -1, .z = 2 },
        .color = Color{ .r = 0.0, .g = 0.0, .b = 1.0 },
        .radius = 1,
        .specular = 500,
    }, Sphere{
        .position = Point3{ .x = 0, .y = -50, .z = 0 },
        .color = Color{ .r = 1.0, .g = 1.0, .b = 0.0 },
        .radius = 50,
        .specular = 1000,
    } },
    .lights = [_]Light{
        Light{ .type = .ambient, .intensity = 0.2, .position = null, .direction = null },
        Light{ .type = .point, .intensity = 0.6, .position = Point3{ .x = 2, .y = 1, .z = 0 }, .direction = null },
        Light{ .type = .directional, .intensity = 0.2, .position = null, .direction = Vec3{ .x = 1, .y = 4, .z = 4 } },
    },
    .projection_plane_d = 1,
    .viewport_aspect_ratio = 1,
};

/// Computes the intensity of the lightning hitting a particular point.
fn compute_lightning(point: Point3, normal: Vec3) f64 {
    var intensity: f64 = 0.0;

    for (scene.lights) |light| {
        if (light.type == .ambient) {
            intensity += light.intensity;
        } else {
            var light_direction: Vec3 = undefined;
            if (light.type == .point) {
                light_direction = light.position.?.subtract(point);
            } else {
                light_direction = light.direction.?;
            }

            const n_dot_l = normal.dot(light_direction);
            if (n_dot_l > 0) {
                intensity += light.intensity * n_dot_l / (normal.length() * light_direction.length());
            }
        }
    }

    return intensity;
}

/// Trace a ray through 3D space to determine a pixel's color.
fn trace_ray(origin: Point3, direction: Vec3, start: f64, finish: f64) Color {
    var closest_t = std.math.inf(f64);
    var closest_sphere: ?*const Sphere = null;

    for (&scene.spheres) |*sphere| {
        const t = sphere.intersect_ray(origin, direction);
        if (t[0] >= start and t[0] <= finish and t[0] < closest_t) {
            closest_t = t[0];
            closest_sphere = sphere;
        }
        if (t[1] >= start and t[1] <= finish and t[1] < closest_t) {
            closest_t = t[1];
            closest_sphere = sphere;
        }
    }

    if (closest_sphere == null) return background_color;

    const point = origin.add(direction.scale(closest_t));
    var normal = point.subtract(closest_sphere.?.*.position);
    normal = normal.divide(normal.length());
    return closest_sphere.?.*.color.multiply(compute_lightning(
        point,
        normal,
    ));
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
