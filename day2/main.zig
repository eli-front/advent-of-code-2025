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
    var total_valid_1: u64 = 0;
    var total_valid_2: u64 = 0;

    // the power 10 table is fixed so we can precompute these (they are used every turn)
    const size = 9; // none of the ids are longer than 9 digits
    var pow10 = try allocator.alloc(u64, size + 1);
    defer allocator.free(pow10);

    pow10[0] = 1;
    for (1..size + 1) |k| pow10[k] = pow10[k - 1] * 10;

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

            // part 1
            if (length % 2 == 0) {
                // split number in half and compare the two halves
                // divisor 10^(length/2) is the number of places of the first half & second half
                // dividing the id by that (truncated) will give first half and modulo will give second half (remainder)
                // const divisor = std.math.pow(u32, 10, length / 2);
                const divisor = pow10[@intCast(length / 2)];
                const first_half = id / divisor;
                const second_half = id % divisor;

                if (first_half == second_half) {
                    total_valid_1 += @intCast(id);
                }
            }

            // part 2
            sizes: for (1..(length / 2 + 1)) |part_size| {
                // loop through possible part sizes from 1 to length
                // check if the portential part_size is a valid factor of length
                if (length % part_size != 0) continue;

                const parts_count = length / part_size;

                var last: u32 = 0;
                for (0..parts_count) |i| {
                    if (i == 0) {
                        last = @intCast(id / pow10[@intCast(length - part_size)]);
                    } else {
                        const next: u32 = @intCast((id / pow10[length - part_size * (i + 1)]) % (pow10[part_size]));

                        if (next != last) {
                            break;
                        }

                        last = next;

                        if (i == parts_count - 1) {
                            total_valid_2 += @intCast(id);
                            break :sizes;
                        }
                    }
                }
            }
        }
    }

    // output result
    const stdout = std.fs.File.stdout();
    const output_slice = try std.fmt.allocPrint(allocator, "Part1:{d}\nPart2:{d}\n", .{ total_valid_1, total_valid_2 });
    defer allocator.free(output_slice);
    try stdout.writeAll(output_slice);
}
