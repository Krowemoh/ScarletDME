const std = @import("std");

const qm = @cImport({
    @cInclude("qm.h");
});

export fn op_sadd() void {
    const c_string = "3";

    std.debug.print("Hello",.{});

    qm.process.status = 0;

    qm.e_stack = qm.e_stack - 1;
    qm.e_stack = qm.e_stack - 1;

    qm.e_stack = qm.e_stack + 1;
    qm.k_put_c_string(c_string, qm.e_stack);
}
