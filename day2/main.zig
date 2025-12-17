const std = @import("std");

fn digitLength(n: u32) u32 {
    var num: u32 = n;
    var length: u32 = 0;
    // count how many times it can be divided by 10 to get the length
    while (num != 0) : (num /= 10) {
        length += 1;
    }
    return length;
}

pub fn main() !void {
    // get problem input
    const allocator = std.heap.page_allocator;
    const file = std.fs.cwd().readFileAlloc("day2/input.txt", allocator, std.Io.Limit.limited(1 << 15)) catch |err| {
        std.debug.print("Failed to open input.txt\n{}", .{err});
        return;
    };
    defer allocator.free(file);

    // split into id ranges (1-3, 12-44, etc)
    var id_ranges_iter = std.mem.tokenizeSequence(u8, file, ",");
    var total_valid: u64 = 0;

    while (id_ranges_iter.next()) |raw| {
        const range = std.mem.trimRight(u8, raw, "\r\n");
        if (range.len == 0) continue;
        const dash_index = std.mem.indexOf(u8, range, "-") orelse continue;
        const start_id = std.fmt.parseInt(u32, range[0..dash_index], 10) catch |err| {
            std.debug.print("Failed to parse start id: {s} \n{}", .{ raw, err });
            continue;
        };
        const end_id = std.fmt.parseInt(u32, range[dash_index + 1 .. range.len], 10) catch |err| {
            std.debug.print("Failed to parse start id2: {s} \n{}", .{ raw, err });
            continue;
        };

        for (start_id..end_id + 1) |id| {
            const length = digitLength(@intCast(id));

            // make sure length is even
            if (@mod(length, 2) != 0) continue;

            // split number in half and compare the two halves
            // divisor 10^(length/2) is the number of places of the first half & second half
            // dividing the id by that (truncated) will give first half and modulo will give second half (remainder)
            const divisor = std.math.pow(u32, 10, length / 2);
            const first_half = id / divisor;
            const second_half = id % divisor;

            if (first_half == second_half) {
                total_valid += @intCast(id);
            }
        }
    }

    // output result
    const stdout = std.fs.File.stdout();
    const output_slice = try std.fmt.allocPrint(allocator, "Result: {d}\n", .{total_valid});
    defer allocator.free(output_slice);
    try stdout.writeAll(output_slice);
}
