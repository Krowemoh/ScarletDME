const std = @import("std");

const qm = @cImport({
    @cInclude("qm.h");
});

var allocator = std.heap.c_allocator;

const V = []const u8;

fn qm_pop(n: i32) void {
    var i: i32 = 0;
    while (i < n) : (i = i + 1) {
        qm.k_dismiss();
    }
}

fn qm_error() void {
    qm.process.status = 2;
    qm.e_stack.*.type = qm.INTEGER;
    qm.e_stack.*.data.value = 0;
    qm.e_stack = qm.e_stack + 1;
}

export fn op_hashmap_init() void {
    qm.process.status = 0;

    var map = allocator.create(std.StringHashMap(V)) catch {
        std.debug.print("Failed to create map, possibly ran out of memory.", .{});
        qm_error();
        return;
    };
    map.* = std.StringHashMap(V).init(allocator);

    qm.hashmap = map;

    qm.k_put_c_string("HASHMAP.INIT", qm.e_stack);
    qm.e_stack = qm.e_stack + 1;
}

export fn op_hashmap_put() void {
    var ok: bool = undefined;

    var s2: [1025]u8 = std.mem.zeroes([1025:0]u8);
    var s3: [1025]u8 = std.mem.zeroes([1025:0]u8);

    const arg3 = qm.e_stack - 1;
    ok = qm.k_get_c_string(arg3, &s3, 1024) > 0;
    qm.k_dismiss();

    if (!ok) {
        std.debug.print("Failed to read value.", .{});
        qm_error();
        return;
    }

    const arg2 = qm.e_stack - 1;
    ok = qm.k_get_c_string(arg2, &s2, 1024) > 0;
    qm.k_dismiss();

    if (!ok) {
        std.debug.print("Failed to read child key.", .{});
        qm_error();
        return;
    }

    qm_pop(1);

    var map: *std.StringHashMap(V) = @alignCast(@ptrCast(qm.hashmap));

    var key = allocator.dupeZ(u8,std.mem.sliceTo(&s2,0)) catch {
        std.debug.print("Error in putting value in hashmap.", .{});
        qm_error();
        return;

    };
    var value = allocator.dupeZ(u8,std.mem.sliceTo(&s3,0)) catch { 
        std.debug.print("Error in putting value in hashmap.", .{});
        qm_error();
        return;
    };

    map.put(key, value) catch {
        std.debug.print("Error in putting value in hashmap.", .{});
        qm_error();
        return;
    };

    qm.e_stack.*.type = qm.INTEGER;
    qm.e_stack.*.data.value = 1;
    qm.e_stack = qm.e_stack + 1;
}

export fn op_hashmap_get() void {
    var ok: bool = undefined;

    var s2: [1025]u8 = std.mem.zeroes([1025:0]u8);

    const arg2 = qm.e_stack - 1;
    ok = qm.k_get_c_string(arg2, &s2, 1024) > 0;
    qm.k_dismiss();

    if (!ok) {
        std.debug.print("Failed to read child key.", .{});
        qm_error();
        return;
    }

    qm_pop(1);

    var map: *std.StringHashMap(V) = @alignCast(@ptrCast(qm.hashmap));

    var value = map.get(std.mem.sliceTo(&s2,0));
    var buffer: []const u8 = undefined;

    if (value) |v| {
        buffer = v;
    } else {
        qm_error();
        return;
    }

    const retString: [*c]const u8 = &buffer[0];

    qm.k_put_c_string(retString, qm.e_stack);
    qm.e_stack = qm.e_stack + 1;
}

