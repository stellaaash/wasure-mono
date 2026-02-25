const std = @import("std");

const Vec3 = @import("Vec3.zig").Vec3;

pub const Point3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn add(self: Point3, comptime T: type, other: T) Point3 {
        return Point3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn subtract(self: Point3, comptime T: type, other: T) Vec3 {
        return Vec3{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }
};
