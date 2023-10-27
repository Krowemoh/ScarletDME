const std = @import("std");

const Managed = std.math.big.int.Managed;

const qm = @cImport({
    @cInclude("qm.h");
});

const Arguments = struct { a: Managed, b: Managed };

fn get_arguments(allocator: std.mem.Allocator) !Arguments {
    var ok: bool = undefined;

    var s1: [1025]u8 = std.mem.zeroes([1025:0]u8);
    var s2: [1025]u8 = std.mem.zeroes([1025:0]u8);

    const arg2 = qm.e_stack - 1;
    ok = qm.k_get_c_string(arg2, &s2, 1024) > 0;
    qm.k_dismiss();

    if (!ok) {
        return error.InvalidArgument;
    }

    const arg1 = qm.e_stack - 1;
    ok = qm.k_get_c_string(arg1, &s1, 1024) > 0;
    qm.k_dismiss();

    if (!ok) {
        return error.InvalidArgument;
    }

    var a = try Managed.init(allocator);
    var b = try Managed.init(allocator);

    try a.setString(10,std.mem.sliceTo(&s1,0));
    try b.setString(10,std.mem.sliceTo(&s2,0));

    return .{ .a = a, .b = b }; 
}

fn bigInt_to_CString(allocator: std.mem.Allocator, a: Managed) ![]u8 {
    const ans = try a.toString(allocator,10,.lower);
    defer allocator.free(ans);

    const c_str = try allocator.alloc(u8,ans.len+1);

    @memset(c_str,0);
    @memcpy(c_str[0..ans.len],ans[0..]);

    return c_str;
}

export fn op_sadd() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator(); 

    var args = get_arguments(allocator) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer args.a.deinit();
    defer args.b.deinit();

    args.a.add(&args.a, &args.b) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };

    const c_str = bigInt_to_CString(allocator, args.a) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer allocator.free(c_str);

    const ret: [*c]const u8 = &c_str[0];

    qm.process.status = 0;
    qm.k_put_c_string(ret, qm.e_stack);
    qm.e_stack = qm.e_stack + 1;

    return;
}

export fn op_ssub() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator(); 

    var args = get_arguments(allocator) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer args.a.deinit();
    defer args.b.deinit();

    args.a.sub(&args.a, &args.b) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };

    const c_str = bigInt_to_CString(allocator, args.a) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer allocator.free(c_str);

    const ret: [*c]const u8 = &c_str[0];

    qm.process.status = 0;
    qm.k_put_c_string(ret, qm.e_stack);
    qm.e_stack = qm.e_stack + 1;

    return;
}

export fn op_smul() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator(); 

    var args = get_arguments(allocator) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer args.a.deinit();
    defer args.b.deinit();

    args.a.mul(&args.a, &args.b) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };

    const c_str = bigInt_to_CString(allocator, args.a) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer allocator.free(c_str);

    const ret: [*c]const u8 = &c_str[0];

    qm.process.status = 0;
    qm.k_put_c_string(ret, qm.e_stack);
    qm.e_stack = qm.e_stack + 1;

    return;
}

export fn op_sdiv() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator(); 

    var args = get_arguments(allocator) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer args.a.deinit();
    defer args.b.deinit();

    var q = Managed.init(allocator) catch | err | { 
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer q.deinit();

    var r = Managed.init(allocator) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer r.deinit();

    Managed.divTrunc(&q, &r, &args.a, &args.b) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };

    const c_str = bigInt_to_CString(allocator, q) catch | err | {
        std.debug.print("Zig Error: {any}\n", .{ err });
        qm.process.status = 2;
        return;
    };
    defer allocator.free(c_str);

    const ret: [*c]const u8 = &c_str[0];

    qm.process.status = 0;
    qm.k_put_c_string(ret, qm.e_stack);
    qm.e_stack = qm.e_stack + 1;

    return;
}
