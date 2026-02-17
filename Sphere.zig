const std = @import("std");
const Point3 = @import("root").Point3;
const Vec3 = @import("root").Vec3;

const Sphere = struct {
    position: Point3,
    radius: f64,
    color: u8,

    /// Computes intersection points between a ray and a sphere
    pub fn intersect_ray(self: Sphere, origin: Point3, direction: Vec3) [2]f64 {
        const vector_to_origin = Vec3{ .x = origin.x - self.position.x, .y = origin.y - self.position.y, .z = origin.z - self.position.z };

        const a = direction.dot(direction);
        const b = 2 * vector_to_origin.dot(direction);
        const c = vector_to_origin.dot(vector_to_origin) - self.radius * self.radius;

        const discriminant = b * b - 4 * a * c;
        if (discriminant < 0) {
            return .{ std.math.inf(f64), std.math.inf(f64) };
        }

        const t1 = (-b + std.math.sqrt(discriminant)) / (2 * a);
        const t2 = (-b - std.math.sqrt(discriminant)) / (2 * a);
        return .{ t1, t2 };
    }
};
