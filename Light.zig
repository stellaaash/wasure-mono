const std = @import("std");

const Vec3 = @import("Vec3.zig").Vec3;

/// Describes the type of a light
/// Ambient lightning affects all objects on the scene, regardless of angle
/// Point lights are points that emit light in all directions
/// Directional lights emit light from the same direction, from infinitely away
pub const Light_Type = enum {
    ambient,
    point,
    directional,
};

/// Represents a light on a 3D scene
pub const Light = struct {
    type: Light_Type,
    intensity: f32,
    direction: Vec3,
};
