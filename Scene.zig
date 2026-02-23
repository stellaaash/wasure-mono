const Sphere = @import("Sphere.zig").Sphere;
const Light = @import("Light.zig").Light;

/// Contains all elements to define a renderer scene in 3D space
pub const Scene = struct {
    spheres: [3]Sphere, // TODO: Dynamic size of spheres array
    lights: [3]Light, // TODO: Dynamic size of lights array
    projection_plane_d: f64,
    viewport_aspect_ratio: f64,
};
