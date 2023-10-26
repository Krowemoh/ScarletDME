const std = @import("std");

const Managed = std.math.big.int.Managed;

const qm = @cImport({
    @cInclude("qm.h");
});

export fn op_sadd() void {
    var ok: bool = undefined;

    var s1: [1025]u8 = std.mem.zeroes([1025:0]u8);
    var s2: [1025]u8 = std.mem.zeroes([1025:0]u8);

    const arg2 = qm.e_stack - 1;
    ok = qm.k_get_c_string(arg2, &s2, 1024) > 0;
    qm.k_dismiss();

    if (!ok) {
        qm.process.status = 2;
        return;
    }

    const arg1 = qm.e_stack - 1;
    ok = qm.k_get_c_string(arg1, &s1, 1024) > 0;
    qm.k_dismiss();

    if (!ok) {
        qm.process.status = 2;
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator(); 

    var a = Managed.init(allocator) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer a.deinit();

    var b = Managed.init(allocator) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer b.deinit();

    a.setString(10,std.mem.sliceTo(&s1,0)) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };

    b.setString(10,std.mem.sliceTo(&s2,0)) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };

    a.add(&a, &b) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };

    const ans = a.toString(allocator,10,.lower) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };

    
    const c_str = allocator.alloc(u8,ans.len+1) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };

    defer allocator.free(c_str);

    @memset(c_str,0);
    @memcpy(c_str[0..ans.len],ans[0..]);

    const ret: [*c]const u8 = &c_str[0];

    qm.process.status = 0;
    qm.k_put_c_string(ret, qm.e_stack);
    qm.e_stack = qm.e_stack + 1;

    return;
}
