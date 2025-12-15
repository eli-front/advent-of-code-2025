const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day = b.option(u8, "day", "Day number to run (1-99)") orelse 1;

    const day_dir = b.fmt("day{d}", .{day});
    const source_path = b.fmt("{s}/main.zig", .{day_dir});

    const exe = b.addExecutable(.{
        .name = b.fmt("advent_of_code_2025_day{d}", .{day}),
        .root_module = b.createModule(.{
            .root_source_file = b.path(source_path),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);

    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
