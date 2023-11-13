const std = @import("std");

const qm = @cImport({
    @cInclude("qm.h");
});

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
    var pid: i32 = undefined;

    pid = std.os.fork() catch {
        qm.e_stack.*.type = @as(i16, qm.INTEGER);
        qm.e_stack.*.data.value = -1;
        qm.e_stack = qm.e_stack + 1;
        return;
    };

    if (pid == 0) {
    }

    qm.e_stack.*.type = @as(i16, qm.INTEGER);
    qm.e_stack.*.data.value = pid;
    qm.e_stack = qm.e_stack + 1;
}

export fn op_exitchild() void {
    qm.k_exit_cause = qm.K_EXIT_CHILD;
}
