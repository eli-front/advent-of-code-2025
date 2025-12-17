const std = @import("std");
pub fn main() !void {
    // get problem input
    const allocator = std.heap.page_allocator;
    const file = std.fs.cwd().readFileAlloc("day1/input.txt", allocator, std.Io.Limit.limited(1 << 15)) catch |err| {
        std.debug.print("Failed to open input.txt\n{}", .{err});
        return;
    };
    defer allocator.free(file);

    // split into directions
    var directions_iter = std.mem.tokenizeSequence(u8, file, "\n");

    var pos_1: i16 = 50;
    var count_1: u16 = 0;

    // part 1
    while (directions_iter.next()) |raw| {
        const step = std.mem.trimRight(u8, raw, "\r");
        if (step.len < 2) continue;

        const direction = step[0];
        const num = try std.fmt.parseInt(i16, step[1..step.len], 10);

        switch (direction) {
            'R' => pos_1 += num,
            'L' => pos_1 -= num,
            else => continue,
        }

        pos_1 = @mod(pos_1, 100);
        if (pos_1 == 0) count_1 += 1;
    }
    // part 2
    directions_iter.reset();
    var pos_2: i16 = 50;
    var count_2: u16 = 0;
    while (directions_iter.next()) |raw| {
        const step = std.mem.trimRight(u8, raw, "\r");
        if (step.len < 2) continue;

        const direction = step[0];
        const num = try std.fmt.parseInt(i16, step[1..step.len], 10);

        const start_z = pos_2 == 0;

        switch (direction) {
            'R' => pos_2 += num,
            'L' => pos_2 -= num,
            else => continue,
        }

        count_2 += @abs(@divTrunc(pos_2, 100));

        if (!start_z and pos_2 <= 0) count_2 += 1;

        pos_2 = @mod(pos_2, 100);
    }

    // output result
    const stdout = std.fs.File.stdout();
    const output_slice = try std.fmt.allocPrint(allocator, "Part1:{d}\nPart2:{d}\n", .{ count_1, count_2 });
    defer allocator.free(output_slice);
    try stdout.writeAll(output_slice);
}
