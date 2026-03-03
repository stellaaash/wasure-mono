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

    pub fn add(comptime T: type, self: Color, number: T) Color {
        self.r += @trunc(number);
        self.g += @trunc(number);
        self.b += @trunc(number);
    }
};
