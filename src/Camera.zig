const std = @import("std");
const zalgebra = @import("zalgebra");
const Vec3 = zalgebra.Vec3;
const Mat4 = zalgebra.Mat4;

position: Vec3 = Vec3.new(0.0, 0.0, 0.0),
front: Vec3 = Vec3.new(0.0, 0.0, -1.0),
up: Vec3 = Vec3.new(0.0, 1.0, 0.0),
right: Vec3 = Vec3.new(-1.0, 0.0, 0.0),
world_up: Vec3 = Vec3.new(0.0, 1.0, 0.0),
yaw: f32 = -90.0,
pitch: f32 = 0.0,
fov: f32 = 45.0,
// The tutorial uses the following two values directly in the camera
// but honestly I don't like this approach
speed: f32 = 2.5,
sensitivity: f32 = 0.1,

pub const Direction = enum {
    forward,
    backward,
    left,
    right,
};

const Self = @This();

pub fn init(position: Vec3, up: Vec3, yaw: f32, pitch: f32) Self {
    var camera = Self{
        .position = position,
        .world_up = up,
        .yaw = yaw,
        .pitch = pitch,
    };
    camera.updateCameraVectors();
    return camera;
}

pub fn default() Self {
    return .{
        .position = Vec3.new(0.0, 0.0, 0.0),
        .front = Vec3.new(0.0, 0.0, -1.0),
        .up = Vec3.new(0.0, 1.0, 0.0),
        .right = Vec3.new(-1.0, 0.0, 0.0),
        .world_up = Vec3.new(0.0, 1.0, 0.0),
        .yaw = -90.0,
        .pitch = 0.0,
        .fov = 45.0,
        .speed = 2.5,
        .sensitivity = 0.1,
    };
}

pub fn getViewMatrix(self: *Self) Mat4 {
    return Mat4.lookAt(self.position, self.position.add(self.front), self.up);
}

pub fn processKeyboard(self: *Self, direction: Direction, delta_time: f32) void {
    const velocity = self.speed * delta_time;

    switch (direction) {
        .forward => {
            self.position = self.position.add(self.front.scale(velocity));
        },
        .backward => {
            self.position = self.position.sub(self.front.scale(velocity));
        },
        .left => {
            self.position = self.position.sub(self.right.scale(velocity));
        },
        .right => {
            self.position = self.position.add(self.right.scale(velocity));
        },
    }
}

pub fn processMouseMovement(self: *Self, offset_x: f32, offset_y: f32) void {
    self.yaw += offset_x * self.sensitivity;
    self.pitch += offset_y * self.sensitivity;

    self.pitch = std.math.clamp(self.pitch, -89.0, 89.0);

    self.updateCameraVectors();
}

pub fn processMouseScroll(self: *Self, offset_y: f32) void {
    self.fov -= offset_y;
    self.fov = std.math.clamp(self.fov, 1.0, 45.0);
}

fn updateCameraVectors(self: *Self) void {
    var front = Vec3.one();
    front.x = std.math.cos(zalgebra.toRadians(self.yaw)) * std.math.cos(zalgebra.toRadians(self.pitch));
    front.y = std.math.sin(zalgebra.toRadians(self.pitch));
    front.z = std.math.sin(zalgebra.toRadians(self.yaw)) * std.math.cos(zalgebra.toRadians(self.pitch));

    self.front = front.norm();
    self.right = self.front.cross(self.world_up).norm();
    self.up = self.right.cross(self.front).norm();
}
