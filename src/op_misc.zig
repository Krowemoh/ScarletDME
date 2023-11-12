const std = @import("std");

const qm = @cImport({
    @cInclude("qm.h");
});

//void op_time() {
//  InitDescr(e_stack, INTEGER);
//  (e_stack++)->data.value = local_time() % 86400L;
//}

export fn op_time() void {
    var localSeconds = @as(f64,@floatFromInt(@rem(qm.local_time(),86400)));

    qm.e_stack.*.type = @as(i16, qm.FLOATNUM);
    qm.e_stack.*.data.float_value = localSeconds;
    qm.e_stack = qm.e_stack + 1;
}

export fn op_timems() void {
    var localSeconds = @as(f64,@floatFromInt(@rem(qm.local_time(),86400)));

    var time: std.os.timespec = undefined;
    std.os.clock_gettime(0, &time) catch | err |{
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    var milliseconds = @as(f64,@floatFromInt(time.tv_nsec))/1_000_000_000;

    localSeconds = localSeconds + milliseconds;

    qm.e_stack.*.type = @as(i16, qm.FLOATNUM);
    qm.e_stack.*.data.float_value = localSeconds;
    qm.e_stack = qm.e_stack + 1;
}

export fn op_fork() void {
    qm.e_stack.*.type = @as(i16, qm.INTEGER);
    qm.e_stack.*.data.value = 1;
    qm.e_stack = qm.e_stack + 1;
}
