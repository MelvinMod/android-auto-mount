const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .linux,
        .abi = .android,
    });
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "android-auto-mount",
        .path = .{ .path = "android-auto-mount.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const run_cmd = b.addRunArtifact(lib);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the library");
    run_step.dependOn(&run_cmd.step);
}
