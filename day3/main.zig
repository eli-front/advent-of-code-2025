const std = @import("std");

pub fn main() !void {
    // get problem input
    const allocator = std.heap.page_allocator;
    const file = std.fs.cwd().readFileAlloc("day3/input.txt", allocator, std.Io.Limit.limited(1 << 15)) catch |err| {
        std.debug.print("Failed to open input.txt\n{}", .{err});
        return;
    };
    defer allocator.free(file);

    // split battery banks into an iter
    var banks_iter = std.mem.tokenizeSequence(u8, file, "\n");

    var joltage_1: u16 = 0;
    var joltage_2: u64 = 0;

    while (banks_iter.next()) |raw| {
        const bank = std.mem.trimRight(u8, raw, "\r\n");

        // part 1
        var bat_1 = bank[0];
        var bat_2 = bank[1];

        for (1..bank.len) |i| {
            if (bat_1 < bank[i] and i < bank.len - 1) {
                bat_1 = bank[i];
                bat_2 = bank[i + 1];
            } else if (bat_2 < bank[i]) {
                bat_2 = bank[i];
            }
        }

        joltage_1 += try std.fmt.parseInt(u8, &.{bat_1}, 10) * 10 + try std.fmt.parseInt(u8, &.{bat_2}, 10);

        // part 2 (generalized version of p1)
        const size = 12;

        var batteries: [size]u16 = undefined;

        for (&batteries, 0..) |*bat, i| {
            const min: u16 = if (i == 0) 0 else batteries[i - 1] + 1;

            for (min..(bank.len - (size - (i + 1)))) |j| {
                if (j == min) {
                    bat.* = @intCast(j);
                } else if (bank[j] > bank[bat.*]) {
                    bat.* = @intCast(j);
                }
            }

            joltage_2 += try std.fmt.parseInt(u8, &.{bank[bat.*]}, 10) * std.math.pow(u64, 10, @intCast(size - i - 1));
        }
    }

    // output result
    const stdout = std.fs.File.stdout();
    const output_slice = try std.fmt.allocPrint(allocator, "Part1:{d}\nPart2:{d}\n", .{ joltage_1, joltage_2 });
    defer allocator.free(output_slice);
    try stdout.writeAll(output_slice);
}
