const std = @import("std");

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn add(comptime T: type, self: Color, number: T) Color {
        self.r += @trunc(number);
        self.g += @trunc(number);
        self.b += @trunc(number);
    }
};
