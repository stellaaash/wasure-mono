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

    pub fn add(self: Color, number: f64) Color {
        return Color{
            .r = @intFromFloat(@as(f64, @floatFromInt(self.r)) + number),
            .g = @intFromFloat(@as(f64, @floatFromInt(self.g)) + number),
            .b = @intFromFloat(@as(f64, @floatFromInt(self.b)) + number),
        };
    }

    pub fn multiply(self: Color, number: f64) Color {
        return Color{
            .r = @intFromFloat(@as(f64, @floatFromInt(self.r)) * number),
            .g = @intFromFloat(@as(f64, @floatFromInt(self.g)) * number),
            .b = @intFromFloat(@as(f64, @floatFromInt(self.b)) * number),
        };
    }
};
