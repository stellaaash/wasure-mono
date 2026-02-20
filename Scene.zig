const Sphere = @import("Sphere.zig").Sphere;

/// Contains all elements to define a renderer scene in 3D space
pub const Scene = struct {
    spheres: [3]Sphere, // TODO: Dynamic size of spheres array
    projection_plane_d: f64,
    viewport_aspect_ratio: f64,
};
