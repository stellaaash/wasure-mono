const std = @import("std");

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn to_u24(self: Color) u24 {
        const r: u24 = @as(u24, self.r) << 16;
        const g: u24 = @as(u24, self.g) << 8;
        const b: u24 = @as(u24, self.b);

        return r | g | b;
    }

    pub fn add(self: Color, comptime T: type, other: T) Color {
        if (T == Color) {
            return Color{
                .r = self.r +| other.r,
                .g = self.g +| other.g,
                .b = self.b +| other.b,
            };
        } else {
            return Color{
                .r = @intFromFloat(@as(f64, @floatFromInt(self.r)) + other),
                .g = @intFromFloat(@as(f64, @floatFromInt(self.g)) + other),
                .b = @intFromFloat(@as(f64, @floatFromInt(self.b)) + other),
            };
        }
    }

    pub fn multiply(self: Color, comptime T: type, other: T) Color {
        if (T == Color) {
            return Color{
                .r = @intFromFloat(@as(f64, @floatFromInt(self.r)) * @as(f64, @floatFromInt(other.r)) / 255.0),
                .g = @intFromFloat(@as(f64, @floatFromInt(self.g)) * @as(f64, @floatFromInt(other.g)) / 255.0),
                .b = @intFromFloat(@as(f64, @floatFromInt(self.b)) * @as(f64, @floatFromInt(other.b)) / 255.0),
            };
        } else {
            return Color{
                .r = @intFromFloat(@as(f64, @floatFromInt(self.r)) * other),
                .g = @intFromFloat(@as(f64, @floatFromInt(self.g)) * other),
                .b = @intFromFloat(@as(f64, @floatFromInt(self.b)) * other),
            };
        }
    }
};
