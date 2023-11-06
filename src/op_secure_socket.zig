const std = @import("std");

export fn op_secure_server_socket() void {
    std.debug.print("CREATE.SECURE.SERVER.SOCKET",.{});
}

export fn op_secure_accept_socket() void {
    std.debug.print("ACCEPT.SECURE.SOCKET.CONNECTION",.{});
}

export fn op_secure_read_socket() void {
    std.debug.print("READ.SECURE.SOCKET",.{});
}

export fn op_secure_write_socket() void {
    std.debug.print("WRITE.SECURE.SOCKET",.{});
}

export fn op_secure_close_socket() void {
    std.debug.print("CLOSE.SECURE.SOCKET",.{});
}
