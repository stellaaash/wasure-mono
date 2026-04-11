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

const recursion_limit = 3;

pub const scene = Scene{
    .spheres = [_]Sphere{ Sphere{
        .position = Point3{ .x = 0, .y = -1, .z = 3 },
        .color = Color{ .r = 1.0, .g = 0.0, .b = 0.0 },
        .radius = 1,
        .specular = 500,
        .reflective = 0.2,
    }, Sphere{
        .position = Point3{ .x = -2, .y = 0, .z = 4 },
        .color = Color{ .r = 0.0, .g = 0.0, .b = 1.0 },
        .radius = 1,
        .specular = 500,
        .reflective = 0.3,
    }, Sphere{
        .position = Point3{ .x = 2, .y = 0, .z = 4 },
        .color = Color{ .r = 0.0, .g = 1.0, .b = 0.0 },
        .radius = 1,
        .specular = 10,
        .reflective = 0.4,
    }, Sphere{
        .position = Point3{ .x = 0, .y = -51, .z = 0 },
        .color = Color{ .r = 1.0, .g = 1.0, .b = 0.0 },
        .radius = 50,
        .specular = 1000,
        .reflective = 0.5,
    } },
    .lights = [_]Light{
        Light{ .type = .ambient, .intensity = 0.2, .position = null, .direction = null },
        Light{ .type = .point, .intensity = 0.6, .position = Point3{ .x = 2, .y = 1, .z = 0 }, .direction = null },
        Light{ .type = .directional, .intensity = 0.2, .position = null, .direction = Vec3{ .x = 1, .y = 4, .z = 4 } },
    },
    .projection_plane_d = 1,
    .viewport_aspect_ratio = 1,
};

/// Represents the up vector in our 3D world.
pub const world_up: Vec3 = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
/// The camera's position in the 3D world.
pub const camera_position: Point3 = .{ .x = 0.0, .y = 0.0, .z = 0.0 };
/// The vector the camera needs to look towards.
pub const camera_direction: Vec3 = .{
    .x = 0,
    .y = 0,
    .z = 1,
};
/// The matrix that will be used to rotate the viewport rays in order to make
/// the actual image to be in the right direction.
/// Each Vec3 represents a column in a matrix, NOT A LINE.
pub const rotation_matrix: [3]Vec3 = init_camera();

/// Initializes the rotation matrix according to the camera rotation on program start.
fn init_camera() [3]Vec3 {
    var matrix: [3]Vec3 = undefined;

    // Start with the Z axis, determined by the camera direction
    matrix[2] = camera_direction.normalize();
    // Then get the cross of Z with our Y reference, to get X
    matrix[0] = world_up.cross(matrix[2]).normalize();
    // Finally, get the actual up of the camera by crossing Z with our new X
    matrix[1] = matrix[0].cross(matrix[2]).normalize();

    return matrix;
}

/// Creates a new vector mirrored based on an axis.
fn reflect_ray(ray: Vec3, axis: Vec3) Vec3 {
    return axis.scale(2.0 * axis.dot(ray)).sub(ray);
}

/// Computes the intensity of the lightning hitting a particular point.
fn compute_lightning(point: Point3, normal: Vec3, view: Vec3, specular: f64) f64 {
    var intensity: f64 = 0.0;
    var t_max: f64 = undefined;

    for (scene.lights) |light| {
        if (light.type == .ambient) {
            intensity += light.intensity;
        } else {
            var light_direction: Vec3 = undefined;
            if (light.type == .point) {
                light_direction = light.position.?.subtract(point);
                t_max = 1;
            } else {
                light_direction = light.direction.?;
                t_max = std.math.inf(@TypeOf(t_max));
            }

            // Shadows
            const result = closest_intersect(point, light_direction, 0.001, t_max);
            const shadowed_sphere = result[0];
            // const shadowed_t = result[1];
            if (shadowed_sphere != null) {
                continue;
            }

            // Diffuse
            const n_dot_l = normal.dot(light_direction);
            if (n_dot_l > 0) {
                intensity += light.intensity * n_dot_l / (normal.length() * light_direction.length());
            }

            // Specular
            if (specular != -1) {
                const reflection = reflect_ray(light_direction, normal);
                const r_dot_v = reflection.dot(view);
                if (r_dot_v > 0) {
                    intensity += light.intensity * std.math.pow(f64, r_dot_v / (reflection.length() * view.length()), specular);
                }
            }
        }
    }

    return intensity;
}

/// Computes the closest intersecting point between a ray and objects in the scene.
fn closest_intersect(origin: Point3, direction: Vec3, start: f64, finish: f64) struct { ?*const Sphere, f64 } {
    var closest_sphere: ?*const Sphere = null;
    var closest_t = std.math.inf(f64);

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

    return .{ closest_sphere, closest_t };
}

/// Trace a ray through 3D space to determine a pixel's color.
fn trace_ray(origin: Point3, direction: Vec3, start: f64, finish: f64, recursion_depth: i32) Color {
    const result = closest_intersect(origin, direction, start, finish);
    const closest_sphere = result[0];
    const closest_t = result[1];

    if (closest_sphere == null) return background_color;

    const point = origin.add(direction.scale(closest_t));
    var normal = point.subtract(closest_sphere.?.*.position);
    normal = normal.divide(normal.length());
    const local_color = closest_sphere.?.color.multiply(compute_lightning(point, normal, direction.scale(-1), closest_sphere.?.specular));

    const reflective = closest_sphere.?.reflective;
    if (recursion_depth <= 0 or reflective <= 0) {
        return local_color;
    }

    const reflected = reflect_ray(direction.scale(-1), normal);
    const reflected_color = trace_ray(point, reflected, 0.001, std.math.inf(f64), recursion_depth - 1);

    return local_color.multiply(reflected_color.multiply(reflective).add(1.0 - reflective));
}

pub fn main() !void {
    std.debug.print("[!] - {} {} {}\n", .{ rotation_matrix[0].x, rotation_matrix[1].x, rotation_matrix[2].x });
    std.debug.print("[!] - {} {} {}\n", .{ rotation_matrix[0].y, rotation_matrix[1].y, rotation_matrix[2].y });
    std.debug.print("[!] - {} {} {}\n", .{ rotation_matrix[0].z, rotation_matrix[1].z, rotation_matrix[2].z });

    var alloc: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = alloc.allocator();

    var canvas = try Canvas.init(gpa, canvas_width, canvas_height);
    defer canvas.deinit();

    // Main loop
    var y: i32 = -canvas_height / 2;
    while (y < canvas_height / 2) : (y += 1) {
        var x: i32 = -canvas_width / 2;
        while (x < canvas_width / 2) : (x += 1) {
            const direction = canvas.to_viewport(x, y).scale(rotation_matrix);
            const color = trace_ray(camera_position, direction, 1, std.math.inf(f32), recursion_limit);

            canvas.put_pixel(x, y, color);
        }
    }

    try canvas.write_to_file("out.ppm");
}
