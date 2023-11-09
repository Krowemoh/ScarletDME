const std = @import("std");

const qm = @cImport({
    @cInclude("qm.h");
});

var allocator = std.heap.c_allocator;

export fn op_secure_server_socket() void {
    var ok: bool = undefined;

    var flags: i32 = undefined;
    var port_number: [31]u8 = std.mem.zeroes([31:0]u8);
    var ip_addr: [81]u8 = std.mem.zeroes([81:0]u8);

    const arg3 = qm.e_stack - 2;
    qm.k_get_int(arg3);
    flags = arg3.*.data.value;

    const arg2 = qm.e_stack - 3;
    ok = qm.k_get_c_string(arg2, &port_number, 31) > 0;
    if (!ok) {
        std.debug.print("Invalid string for port.\n", .{});
        qm.process.status = 2;
        return;
    }

    const port = std.fmt.parseInt(i32, std.mem.sliceTo(&port_number,0), 10) catch | err | {
        std.debug.print("Invalid parse int for port. - {}\n", .{err});
        qm.process.status = 2;
        return;
    };
    _ = port;
 
    const arg1 = qm.e_stack - 4;
    ok = qm.k_get_c_string(arg1, &ip_addr, 80) >= 0;

    if (std.mem.sliceTo(&ip_addr,0).len == 0) {
        @memcpy(ip_addr[0..7],"0.0.0.0");
    }

    if (!ok) {
        std.debug.print("Invalid string for ip address.\n", .{});
        qm.process.status = 2;
        return;
    }
 
    var ret: i32 = undefined;

    // Initalize SSL 
    var listen_fd = allocator.create(qm.mbedtls_net_context) catch unreachable;
    var entropy = allocator.create(qm.mbedtls_entropy_context) catch unreachable;
    var ctr_drbg = allocator.create(qm.mbedtls_ctr_drbg_context) catch unreachable;
    var ssl = allocator.create(qm.mbedtls_ssl_context) catch unreachable;
    var conf_ctx = qm.zmbedtls_ssl_config_alloc();
    var conf: *qm.mbedtls_ssl_config = @ptrCast(conf_ctx);
    var srvcrt = allocator.create(qm.mbedtls_x509_crt) catch unreachable;
    var pkey = allocator.create(qm.mbedtls_pk_context) catch unreachable;
    var cache = allocator.create(qm.mbedtls_ssl_cache_context) catch unreachable;

    qm.mbedtls_net_init(listen_fd);

    qm.mbedtls_entropy_init(entropy);
    qm.mbedtls_ctr_drbg_init(ctr_drbg);
    qm.mbedtls_ssl_init(ssl);

    qm.zmbedtls_ssl_config_init(conf);

    qm.mbedtls_x509_crt_init(srvcrt);
    qm.mbedtls_pk_init(pkey);
    qm.mbedtls_ssl_cache_init(cache);

    // Seed
    const pers = "ssl_server";
    ret = qm.mbedtls_ctr_drbg_seed(ctr_drbg, qm.mbedtls_entropy_func, entropy, pers, pers.len);
    if (ret != 0) {
        std.debug.print("Seed Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    // Set Certificate
    var certificate_path = "/home/nivethan/certs/selfsigned.crt";
    ret = qm.mbedtls_x509_crt_parse_file(srvcrt, certificate_path);
    if (ret != 0) {
        std.debug.print("Parsing Certificate Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    // Set Key
    var key_path = "/home/nivethan/certs/selfsigned.key";
    ret = qm.mbedtls_pk_parse_keyfile(pkey, key_path, 0);
    if (ret != 0) {
        std.debug.print("Parsing Key Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    // Create Socket
    ret = qm.mbedtls_net_bind(listen_fd, &ip_addr, &port_number, qm.MBEDTLS_NET_PROTO_TCP);
    if (ret != 0) {
        std.debug.print("Bind Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    ret = qm.mbedtls_ssl_config_defaults(conf, qm.MBEDTLS_SSL_IS_SERVER, qm.MBEDTLS_SSL_TRANSPORT_STREAM, qm.MBEDTLS_SSL_PRESET_DEFAULT);
    if (ret != 0) {
        std.debug.print("SSL Defaults failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    qm.mbedtls_ssl_conf_rng(conf, qm.mbedtls_ctr_drbg_random, ctr_drbg);
    qm.mbedtls_ssl_conf_session_cache(conf, cache, qm.mbedtls_ssl_cache_get, qm.mbedtls_ssl_cache_set);
    qm.mbedtls_ssl_conf_ca_chain(conf, srvcrt.next, null);

    ret = qm.mbedtls_ssl_conf_own_cert(conf, srvcrt, pkey);
    if (ret != 0) {
        std.debug.print("SSL Conf Own Cert Returned: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    ret = qm.mbedtls_ssl_setup(ssl, conf);
    if (ret != 0) {
        std.debug.print("SSL Setup Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    var socket: *qm.SOCKVAR = allocator.create(qm.SOCKVAR) catch unreachable;
    socket.server = 1;
    socket.fd = listen_fd;
    socket.entropy = entropy;
    socket.ctr_drbg = ctr_drbg;
    socket.ssl = ssl;
    socket.conf = conf;
    socket.srvcrt = srvcrt;
    socket.pkey = pkey;
    socket.cache = cache;

    qm.k_dismiss();
    qm.k_pop(2);
    qm.k_dismiss();

    qm.e_stack.*.type = qm.SOCK;
    qm.e_stack.*.data.sock = socket;
    qm.e_stack = qm.e_stack + 1;
}

export fn op_secure_accept_socket() void {
    var flags: i32 = undefined;
    var server_socket: *qm.DESCRIPTOR = undefined;

    const arg2 = qm.e_stack - 1;
    qm.k_get_int(arg2);
    flags = arg2.*.data.value;

    server_socket = qm.e_stack - 2;
    while (server_socket.*.type == qm.ADDR) : (server_socket = server_socket.*.data.d_addr) { }

    var ret: i32 = undefined;

    var client_fd = allocator.create(qm.mbedtls_net_context) catch unreachable;
    qm.mbedtls_net_init(client_fd);

    var sock = server_socket.*.data.sock.*;

    ret = qm.mbedtls_ssl_session_reset(sock.ssl);
    if (ret != 0) {
        std.debug.print("Reset Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    ret = qm.mbedtls_net_accept(sock.fd, client_fd, null, 0, null);
    if (ret != 0) {
        std.debug.print("Accept Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    qm.mbedtls_ssl_set_bio(sock.ssl, client_fd, qm.mbedtls_net_send, qm.mbedtls_net_recv, null);

    ret = qm.mbedtls_ssl_handshake(sock.ssl);
    while (ret != 0) : (ret = qm.mbedtls_ssl_handshake(sock.ssl)) {
        if (ret != qm.MBEDTLS_ERR_SSL_WANT_READ and ret != qm.MBEDTLS_ERR_SSL_WANT_WRITE) {
            std.debug.print("SSL Handshake Failed: {}\n", .{ret});
            qm.process.status = 2;
            return;
        }
    }

    var socket: *qm.SOCKVAR = allocator.create(qm.SOCKVAR) catch unreachable;
    socket.server = 0;
    socket.fd = client_fd;
    socket.ssl = sock.ssl;

    qm.k_pop(1);
    qm.k_dismiss();

    qm.e_stack.*.type = qm.SOCK;
    qm.e_stack.*.data.sock = socket;
    qm.e_stack = qm.e_stack + 1;
}

export fn op_secure_read_socket() void {
    var timeout: i32 = undefined;
    var flags: i32 = undefined;
    var max_len: usize = undefined;

    const arg4 = qm.e_stack - 1;
    qm.k_get_int(arg4);
    timeout = arg4.*.data.value;

    const arg3 = qm.e_stack - 2;
    qm.k_get_int(arg3);
    flags = arg3.*.data.value;

    const arg2 = qm.e_stack - 3;
    qm.k_get_int(arg2);
    max_len = @intCast(arg2.*.data.value);

    var client_socket = qm.e_stack - 4;
    while (client_socket.*.type == qm.ADDR) : (client_socket = client_socket.*.data.d_addr) { }

    var sock = client_socket.*.data.sock.*;

    var ret: i32 = undefined;

    var buffer = allocator.alloc(u8, max_len+1) catch unreachable;
    defer allocator.free(buffer);
    @memset(buffer,0);

    ret = qm.mbedtls_ssl_read(sock.ssl, &buffer[0], @as(usize,max_len));

    const retString: [*c]const u8 = &buffer[0];

    qm.k_pop(3);
    qm.k_dismiss();

    qm.k_put_c_string(retString, qm.e_stack);
    qm.e_stack = qm.e_stack + 1;
}

export fn op_secure_write_socket() void {
    var timeout: i32 = undefined;
    var flags: i32 = undefined;
    var str: ?*qm.STRING_CHUNK = undefined;

    const arg4 = qm.e_stack - 1;
    qm.k_get_int(arg4);
    timeout = arg4.*.data.value;

    const arg3 = qm.e_stack - 2;
    qm.k_get_int(arg3);
    flags = arg3.*.data.value;

    const arg2 = qm.e_stack - 3;
    qm.k_get_string(arg2);
    str = arg2.*.data.str.saddr;

    var client_socket = qm.e_stack - 4;
    while (client_socket.*.type == qm.ADDR) : (client_socket = client_socket.*.data.d_addr) { }

    var sock = client_socket.*.data.sock.*;

    var bytes_sent: i32 = 0;

    while (str != null) {
        var p: *qm.STRING_CHUNK = str.?;

        var len: usize = @intCast(p.bytes);
        var ret: i32 = qm.mbedtls_ssl_write(sock.ssl, &p.data, len);

        while (ret <= 0) : (ret = qm.mbedtls_ssl_write(sock.ssl, &p.data, len)) {
            if (ret == qm.MBEDTLS_ERR_NET_CONN_RESET) {
                std.debug.print("Connection reset: {}\n", .{ret});
                qm.process.status = 2;
                return;

            }
            if (ret != qm.MBEDTLS_ERR_SSL_WANT_READ and ret != qm.MBEDTLS_ERR_SSL_WANT_WRITE) {
                std.debug.print("SSL Write Failed: {}\n", .{ret});
                qm.process.status = 2;
                return;
            }
        }
        bytes_sent = bytes_sent + p.bytes;
        str = p.next;
    }

    qm.k_pop(2);
    qm.k_dismiss();
    qm.k_dismiss();

    qm.e_stack.*.type = qm.INTEGER;
    qm.e_stack.*.data.value = bytes_sent;
    qm.e_stack = qm.e_stack + 1;
}

export fn op_secure_close_socket() void {
    var descr = qm.e_stack - 1;
    while (descr.*.type == qm.ADDR) : (descr = descr.*.data.d_addr) { }

    var sock: qm.SOCKVAR = descr.*.data.sock.*;

    if (sock.server == 0) {
        var ret = qm.mbedtls_ssl_close_notify(sock.ssl);
        while (ret < 0) : (ret = qm.mbedtls_ssl_close_notify(sock.ssl)) {
            if (ret != qm.MBEDTLS_ERR_SSL_WANT_READ and ret != qm.MBEDTLS_ERR_SSL_WANT_WRITE) {
                std.debug.print("SSL Close Failed: {}\n", .{ret});
                qm.process.status = 2;
                return;
            }
        }
        qm.mbedtls_net_free(sock.fd);

    } else if (sock.server == 1) {
        qm.mbedtls_net_free(sock.fd);
        qm.mbedtls_entropy_free(sock.entropy);
        qm.mbedtls_ctr_drbg_free(sock.ctr_drbg);
        qm.zmbedtls_ssl_config_free(sock.conf);
        qm.mbedtls_x509_crt_free(sock.srvcrt);
        qm.mbedtls_pk_free(sock.pkey);
        qm.mbedtls_ssl_free(sock.ssl);
        qm.mbedtls_ssl_cache_free(sock.cache);
    }

    qm.k_pop(1);
}
