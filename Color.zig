const std = @import("std");

pub const Color = struct {
    r: f64,
    g: f64,
    b: f64,

    pub fn to_u24(self: Color) u24 {
        const r: u24 = @as(u24, @intFromFloat(self.r * 255.0)) << 16;
        const g: u24 = @as(u24, @intFromFloat(self.g * 255.0)) << 8;
        const b: u24 = @as(u24, @intFromFloat(self.b * 255.0));

        return r | g | b;
    }

    pub fn add(self: Color, other: anytype) Color {
        if (@TypeOf(other) == Color) {
            return .{
                .r = if (self.r + other.r > 1.0) 1.0 else self.r + other.r,
                .g = if (self.g + other.g > 1.0) 1.0 else self.g + other.g,
                .b = if (self.b + other.b > 1.0) 1.0 else self.b + other.b,
            };
        } else {
            return .{
                .r = if (self.r + other > 1.0) 1.0 else self.r + other,
                .g = if (self.g + other > 1.0) 1.0 else self.g + other,
                .b = if (self.b + other > 1.0) 1.0 else self.b + other,
            };
        }
    }

    pub fn multiply(self: Color, other: anytype) Color {
        if (@TypeOf(other) == Color) {
            return .{
                .r = if (self.r * other.r > 1.0) 1.0 else self.r * other.r,
                .g = if (self.g * other.g > 1.0) 1.0 else self.g * other.g,
                .b = if (self.b * other.b > 1.0) 1.0 else self.b * other.b,
            };
        } else {
            return .{
                .r = if (self.r * other > 1.0) 1.0 else self.r * other,
                .g = if (self.g * other > 1.0) 1.0 else self.g * other,
                .b = if (self.b * other > 1.0) 1.0 else self.b * other,
            };
        }
    }
};
