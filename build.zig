const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("opengl", "src/main.zig");

    switch (builtin.os.tag) {
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

    exe.addCSourceFile("deps/stb/stb_image.c", &.{"-std=c99"});
    exe.addIncludeDir("deps/stb");

    exe.addPackagePath("zalgebra", "deps/zalgebra/src/main.zig");
    exe.addPackagePath("gl33", "deps/zig-opengl/exports/gl_3v3.zig");

    exe.linkSystemLibrary("epoxy");
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("assimp");
    exe.linkSystemLibrary("c++");

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
