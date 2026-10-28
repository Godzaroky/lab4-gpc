const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    rl.initWindow(1280, 720, "Wireframe");
    defer rl.closeWindow();

    var camera = rl.Camera3D{
        .position = .{ .x = 0, .y = 0, .z = 0 },
        .target = .{ .x = 0, .y = 0, .z = 0 },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45,
        .projection = .perspective,
    };

    var yaw: f32 = 45;
    var pitch: f32 = 25;
    var distance: f32 = 6;

    const model = try rl.loadModel("assets/mono.obj");
    defer rl.unloadModel(model);

    const bounds = rl.getModelBoundingBox(model);
    const size = bounds.max.subtract(bounds.min);
    const center = bounds.min.add(size.scale(0.5));
    const scale = 2.0 / @max(size.x, @max(size.y, size.z));
    const position = center.scale(-scale);

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();

        if (rl.isKeyDown(.a)) yaw -= 90 * dt;
        if (rl.isKeyDown(.d)) yaw += 90 * dt;
        if (rl.isKeyDown(.w)) pitch += 60 * dt;
        if (rl.isKeyDown(.s)) pitch -= 60 * dt;
        pitch = std.math.clamp(pitch, -89, 89);
        distance = std.math.clamp(distance - rl.getMouseWheelMove() * 0.5, 1, 20);

        const yaw_rad = std.math.degreesToRadians(yaw);
        const pitch_rad = std.math.degreesToRadians(pitch);
        camera.position = .{
            .x = distance * @cos(pitch_rad) * @sin(yaw_rad),
            .y = distance * @sin(pitch_rad),
            .z = distance * @cos(pitch_rad) * @cos(yaw_rad),
        };

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.beginMode3D(camera);
        rl.drawModelWires(model, position, scale, rl.Color.red);
        rl.endMode3D();

        rl.drawFPS(10, 10);
    }
}
