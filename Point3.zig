const std = @import("std");

const Vec3 = @import("Vec3.zig").Vec3;

pub const Point3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn add(self: Point3, comptime T: type, other: T) Point3 {
        if (T == Point3 or T == Vec3) {
            return Point3{
                .x = self.x + other.x,
                .y = self.y + other.y,
                .z = self.z + other.z,
            };
        } else {
            return Point3{
                .x = self.x + other,
                .y = self.y + other,
                .z = self.z + other,
            };
        }
    }

    pub fn subtract(self: Point3, comptime T: type, other: T) if (T == Point3) Vec3 else Point3 {
        if (T == Point3) {
            return Vec3{
                .x = self.x - other.x,
                .y = self.y - other.y,
                .z = self.z - other.z,
            };
        } else if (T == Vec3) {
            return Point3{
                .x = self.x - other.x,
                .y = self.y - other.y,
                .z = self.z - other.z,
            };
        } else {
            return Point3{
                .x = self.x - other,
                .y = self.y - other,
                .z = self.z - other,
            };
        }
    }
};
