const std = @import("std");

const qm = @cImport({
    @cInclude("qm.h");
});

export fn op_time() void {
    const localSeconds = @as(f64, @floatFromInt(@rem(qm.local_time(), 86400)));
    qm.e_stack.*.type = @as(i16, qm.FLOATNUM);
    qm.e_stack.*.data.float_value = localSeconds;
    qm.e_stack = qm.e_stack + 1;
}

export fn op_timems() void {
    var localSeconds = @as(f64, @floatFromInt(@rem(qm.local_time(), 86400)));

    const time: std.posix.timespec = std.posix.clock_gettime(std.os.linux.clockid_t.REALTIME) catch |err| {
        std.debug.print("Zig Error: {any}\n", .{err});
        qm.process.status = 2;
        return;
    };

    const milliseconds = @as(f64, @floatFromInt(time.nsec)) / 1_000_000_000;

    localSeconds = localSeconds + milliseconds;

    qm.e_stack.*.type = @as(i16, qm.FLOATNUM);
    qm.e_stack.*.data.float_value = localSeconds;
    qm.e_stack = qm.e_stack + 1;
}
