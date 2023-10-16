const std = @import("std");
const zlib = @import("zlib.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const shared = b.option(bool, "shared", "Build a shared library") orelse false;

    const lib = if (shared)
        zlib.createShared(b, target, optimize)
    else
        zlib.create(b, target, optimize);
    b.installArtifact(lib.step);

    b.getInstallStep().dependOn(&b.addInstallHeaderFile("zlib/zlib.h", "zlib.h").step);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
    });
    lib.link(tests, .{});

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
