const std = @import("std");

const qm = @cImport({
    @cInclude("qm.h");
});

const c = @cImport({
    @cInclude("zig_ssl_config.h");
    @cInclude("mbedtls/entropy.h");
    @cInclude("mbedtls/ctr_drbg.h");
    @cInclude("mbedtls/x509.h");
    @cInclude("mbedtls/ssl.h");
    @cInclude("mbedtls/net_sockets.h");
    @cInclude("mbedtls/error.h");
    @cInclude("mbedtls/debug.h");
    @cInclude("mbedtls/ssl_cache.h");
});

var allocator = std.heap.c_allocator;

export fn op_secure_server_socket() void {
    var ret: i32 = undefined;

    // Initalize SSL 
    var listen_fd = allocator.create(c.mbedtls_net_context) catch unreachable;

    var entropy = allocator.create(c.mbedtls_entropy_context) catch unreachable;
    defer allocator.destroy(entropy);

    var ctr_drbg = allocator.create(c.mbedtls_ctr_drbg_context) catch unreachable;
    defer allocator.destroy(ctr_drbg);

    var ssl = allocator.create(c.mbedtls_ssl_context) catch unreachable;

    var conf_ctx = c.zmbedtls_ssl_config_alloc();
    var conf: *c.mbedtls_ssl_config = @ptrCast(conf_ctx);
    defer c.zmbedtls_ssl_config_free(conf);

    var srvcrt = allocator.create(c.mbedtls_x509_crt) catch unreachable;
    defer allocator.destroy(srvcrt);

    var pkey = allocator.create(c.mbedtls_pk_context) catch unreachable;
    defer allocator.destroy(pkey);

    var cache = allocator.create(c.mbedtls_ssl_cache_context) catch unreachable;
    defer allocator.destroy(cache);

    c.mbedtls_net_init(listen_fd);

    c.mbedtls_entropy_init(entropy);
    c.mbedtls_ctr_drbg_init(ctr_drbg);
    c.mbedtls_ssl_init(ssl);

    c.zmbedtls_ssl_config_init(conf);

    c.mbedtls_x509_crt_init(srvcrt);
    c.mbedtls_pk_init(pkey);
    c.mbedtls_ssl_cache_init(cache);

    // Seed
    const pers = "SSL";
    ret = c.mbedtls_ctr_drbg_seed(ctr_drbg, c.mbedtls_entropy_func, entropy, pers, pers.len);
    if (ret != 0) {
        std.debug.print("Seed Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    // Set Certificate
    var certificate_path = "selfsigned.crt";
    ret = c.mbedtls_x509_crt_parse_file(srvcrt, certificate_path);
    if (ret != 0) {
        std.debug.print("Parsing Certificate Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    // Set Key
    var key_path = "selfsigned.key";
    ret = c.mbedtls_pk_parse_keyfile(pkey, key_path, 0);
    if (ret != 0) {
        std.debug.print("Parsing Key Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    // Create Socket
    ret = c.mbedtls_net_bind(listen_fd, null, "4433", c.MBEDTLS_NET_PROTO_TCP);
    if (ret != 0) {
        std.debug.print("Bind Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    ret = c.mbedtls_ssl_config_defaults(conf, c.MBEDTLS_SSL_IS_SERVER, c.MBEDTLS_SSL_TRANSPORT_STREAM, c.MBEDTLS_SSL_PRESET_DEFAULT);
    if (ret != 0) {
        std.debug.print("SSL Defaults failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    c.mbedtls_ssl_conf_rng(conf, c.mbedtls_ctr_drbg_random, ctr_drbg);
    c.mbedtls_ssl_conf_session_cache(conf, cache, c.mbedtls_ssl_cache_get, c.mbedtls_ssl_cache_set);
    c.mbedtls_ssl_conf_ca_chain(conf, srvcrt.next, null);

    ret = c.mbedtls_ssl_conf_own_cert(conf, srvcrt, pkey);
    if (ret != 0) {
        std.debug.print("SSL Conf Own Cert Returned: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    ret = c.mbedtls_ssl_setup(ssl, conf);
    if (ret != 0) {
        std.debug.print("SSL Setup Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    std.debug.print("CREATE.SECURE.SERVER.SOCKET, {any}",.{ listen_fd });
}

export fn op_secure_accept_socket() void {
    var ret: i32 = undefined;

    var client_fd = allocator.create(c.mbedtls_net_context) catch unreachable;
    c.mbedtls_net_init(client_fd);
    defer c.mbedtls_net_free(self.client_fd);

    ret = c.mbedtls_ssl_session_reset(ssl);
    if (ret != 0) {
        std.debug.print("Reset Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    ret = c.mbedtls_net_accept(listen_fd, client_fd, null, 0, null);
    if (ret != 0) {
        std.debug.print("Accept Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    c.mbedtls_ssl_set_bio(ssl, client_fd, c.mbedtls_net_send, c.mbedtls_net_recv, null);

    while (ret != 0) : (ret = c.mbedtls_ssl_handshake(ssl)) {
        if (ret != c.MBEDTLS_ERR_SSL_WANT_READ and ret != c.MBEDTLS_ERR_SSL_WANT_WRITE) {
            std.debug.print("SSL Handshake Failed: {}\n", .{ret});
            qm.process.status = 2;
            return;
        }
    }

    std.debug.print("ACCEPT.SECURE.SOCKET.CONNECTION",.{});
}

export fn op_secure_read_socket() void {
    var ret: i32 = undefined;
    var buffer: [1024]u8 = std.mem.zeroes([1024:0]u8);
    ret = c.mbedtls_ssl_read(ssl, &buffer, 1024);
    std.debug.print("READ.SECURE.SOCKET = {any}",.{ ret });
}

export fn op_secure_write_socket() void {
    var buffer = "Hello, World!";
    var ret: i32 = undefined;
    ret = c.mbedtls_ssl_write(ssl, buffer, buffer.len); 
    if (ret <= 0) {
        std.debug.print("SSL Write Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }
    var bytes = ret;

    std.debug.print("WRITE.SECURE.SOCKET = {any}",.{bytes});
}

export fn op_secure_close_socket() void {
    ret = c.mbedtls_ssl_close_notify(ssl);
    if (ret < 0) {
        std.debug.print("SSL Close Failed: {}\n", .{ret});
        qm.process.status = 2;
        return;
    }

    std.debug.print("CLOSE.SECURE.SOCKET",.{});
}
