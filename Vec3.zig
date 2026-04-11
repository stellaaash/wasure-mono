const std = @import("std");

pub const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn add(self: Vec3, other: anytype) Vec3 {
        if (@TypeOf(self) == Vec3) {
            return Vec3{
                .x = self.x + other.x,
                .y = self.y + other.y,
                .z = self.z + other.z,
            };
        } else {
            return Vec3{
                .x = self.x + other,
                .y = self.y + other,
                .z = self.z + other,
            };
        }
    }

    pub fn sub(self: Vec3, other: anytype) Vec3 {
        if (@TypeOf(other) == Vec3) {
            return Vec3{
                .x = self.x - other.x,
                .y = self.y - other.y,
                .z = self.z - other.z,
            };
        } else {
            return Vec3{
                .x = self.x - other,
                .y = self.y - other,
                .z = self.z - other,
            };
        }
    }

    pub fn scale(self: Vec3, other: anytype) Vec3 {
        if (@TypeOf(other) == Vec3) {
            return Vec3{
                .x = self.x * other.x,
                .y = self.y * other.y,
                .z = self.z * other.z,
            };
        } else if (@TypeOf(other) == [3]Vec3) {
            // Multiplication by a 3x3 matrix
            const new_x: Vec3 = other[0].scale(self.x);
            const new_y: Vec3 = other[1].scale(self.y);
            const new_z: Vec3 = other[2].scale(self.z);

            return Vec3{
                .x = new_x.x + new_y.x + new_z.x,
                .y = new_x.y + new_y.y + new_z.y,
                .z = new_x.z + new_y.z + new_z.z,
            };
        } else {
            return Vec3{
                .x = self.x * other,
                .y = self.y * other,
                .z = self.z * other,
            };
        }
    }

    pub fn divide(self: Vec3, other: anytype) Vec3 {
        if (@TypeOf(other) == Vec3) {
            return Vec3{
                .x = self.x / other.x,
                .y = self.y / other.y,
                .z = self.z / other.z,
            };
        } else {
            return self.scale(1.0 / other);
        }
    }

    pub fn length(self: Vec3) f64 {
        return std.math.sqrt(self.dot(self));
    }

    pub fn dot(self: Vec3, other: Vec3) f64 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .x = self.y * other.z - self.z * other.y, .y = self.z * other.x - self.x * other.z, .z = self.x * other.y - self.y * other.x };
    }

    /// Normalize a vector to make it of unit length.
    pub fn normalize(self: Vec3) Vec3 {
        return self.divide(self.length());
    }
};
