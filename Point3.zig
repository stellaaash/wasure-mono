const std = @import("std");

const Vec3 = @import("Vec3.zig");

pub const Point3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn add(self: Point3, other: Point3) Point3 {
        Point3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn subtract(self: Point3, other: Point3) Vec3 {
        Vec3{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }
};
