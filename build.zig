const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("opengl", "src/main.zig");

    switch (std.builtin.os.tag) {
        .windows => {
            exe.linkSystemLibrary("opengl32");
        },
        .linux, .freebsd, .openbsd => {
            exe.linkSystemLibrary("X11");
            exe.linkSystemLibrary("GL");
        },
        else => {
            @compileError("Platform not supported");
        },
    }
    exe.linkSystemLibrary("epoxy");
    exe.linkSystemLibrary("glfw3");
    exe.linkLibC();

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
