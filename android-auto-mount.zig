const std = @import("std");

var allocator = std.heap.page_allocator;
const images = [_][]const u8{
    "/data/android_auto.img",
    "/data/carvm.img",
};
const check_file = "/.android_auto_mounted";

export fn mount_partition(name: [*c]const u8, check: bool, path: [*:0]const u8) i32 {
    _ = check;
    _ = path;
    if (std.fs.cwd().access(check_file, .{})) |_| return 0 else |_| {}
    const name_str = std.mem.span(name);
    std.log.info("Checking mount point: {s}", .{name_str});

    for (images) |img| {
        if (std.fs.cwd().access(img, .{})) {
            std.log.info("Mounting partition '{s}' using '{s}'", .{ name_str, img });
            _ = std.process.Child.run(.{ .allocator = allocator, .argv = &.{ "mount", "-o", "ro,loop", img, name_str } }) catch {};
            
            if (std.fs.cwd().access(check_file, .{})) |_| {
                std.log.info("Mounted active partition: '{s}'", .{name_str});
                return 0;
            } else |_| {
                continue;
            }
        } else |_| {
            std.log.warn("Invalid partition or mount failed for '{s}' with image '{s}'", .{ name_str, img });
            _ = std.process.Child.run(.{ .allocator = allocator, .argv = &.{ "umount", "-l", name_str } }) catch {};
        }
    }

    if (std.fs.cwd().access("/userdata/super.img", .{})) |_| {
        std.log.info("Mapping super partition from /userdata/super.img", .{});
    } else |_| {}

    _ = std.process.Child.run(.{ .allocator = allocator, .argv = &.{ "losetup", "-r", "-f", "/userdata/super.img" } }) catch {};

    return 0;
}