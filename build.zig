const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const os = target.result.os.tag;

    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseFast });

    const cflags = [_][]const u8{
        "-Wall",
        "-Wformat=2",
        "-Wno-format-nonliteral",
        "-DLINUX",
        "-D_FILE_OFFSET_BITS=64",
        "-DGPL",
        "-fPIE",
        "-fPIC",
        "-fno-sanitize=undefined",
    };

    const qmtic = b.addExecutable(.{ .name = "qmtic", .root_module = b.createModule(.{ .optimize = optimize, .target = target }) });
    const qmfix = b.addExecutable(.{ .name = "qmfix", .root_module = b.createModule(.{ .optimize = optimize, .target = target }) });
    const qmconv = b.addExecutable(.{ .name = "qmconv", .root_module = b.createModule(.{ .optimize = optimize, .target = target }) });
    const qmidx = b.addExecutable(.{ .name = "qmidx", .root_module = b.createModule(.{ .optimize = optimize, .target = target }) });
    const qmlnxd = b.addExecutable(.{ .name = "qmlnxd", .root_module = b.createModule(.{ .optimize = optimize, .target = target }) });
    const qm = b.addExecutable(.{ .name = "qm", .root_module = b.createModule(.{ .optimize = optimize, .target = target }) });

    const smath = b.addLibrary(.{ .name = "op_smath", .root_module = b.createModule(.{
        .root_source_file = b.path("src/op_smath.zig"),
        .optimize = optimize,
        .target = target,
    }) });

    const misc = b.addLibrary(.{ .name = "op_misc", .root_module = b.createModule(.{
        .root_source_file = b.path("src/op_misc.zig"),
        .optimize = optimize,
        .target = target,
    }) });

    const hashmap = b.addLibrary(.{ .name = "op_hashmap", .root_module = b.createModule(.{
        .root_source_file = b.path("src/op_hashmap.zig"),
        .optimize = optimize,
        .target = target,
    }) });

    if (os == .macos) {
        qmtic.addIncludePath(b.path("/opt/homebrew/include"));
        qmtic.addLibraryPath(b.path("/opt/homebrew/lib"));

        qmfix.addIncludePath(b.path("/opt/homebrew/include"));
        qmfix.addLibraryPath(b.path("/opt/homebrew/lib"));

        qmconv.addIncludePath(b.path("/opt/homebrew/include"));
        qmconv.addLibraryPath(b.path("/opt/homebrew/lib"));

        qmidx.addIncludePath(b.path("/opt/homebrew/include"));
        qmidx.addLibraryPath(b.path("/opt/homebrew/lib"));

        qmlnxd.addIncludePath(b.path("/opt/homebrew/include"));
        qmlnxd.addLibraryPath(b.path("/opt/homebrew/lib"));

        qm.addIncludePath(b.path("/opt/homebrew/include"));
        qm.addLibraryPath(b.path("/opt/homebrew/lib"));

        smath.addIncludePath(b.path("/opt/homebrew/include"));
        smath.addLibraryPath(b.path("/opt/homebrew/lib"));

        misc.addIncludePath(b.path("/opt/homebrew/include"));
        misc.addLibraryPath(b.path("/opt/homebrew/lib"));

        hashmap.addIncludePath(b.path("/opt/homebrew/include"));
        hashmap.addLibraryPath(b.path("/opt/homebrew/lib"));
    }

    qmtic.linkLibC();

    qmtic.addCSourceFiles(.{
        .files = &.{ "gplsrc/qmtic.c", "gplsrc/inipath.c" },
        .flags = &cflags,
    });

    b.installArtifact(qmtic);

    qmfix.linkLibC();

    qmfix.addCSourceFiles(.{
        .files = &.{
            "gplsrc/qmfix.c",
            "gplsrc/ctype.c",
            "gplsrc/linuxlb.c",
            "gplsrc/dh_hash.c",
            "gplsrc/inipath.c",
        },
        .flags = &cflags,
    });

    b.installArtifact(qmfix);

    qmconv.linkLibC();

    qmconv.addCSourceFiles(.{
        .files = &.{
            "gplsrc/qmconv.c",
            "gplsrc/ctype.c",
            "gplsrc/linuxlb.c",
            "gplsrc/dh_hash.c",
        },
        .flags = &cflags,
    });

    b.installArtifact(qmconv);

    qmidx.linkLibC();

    qmidx.addCSourceFiles(.{
        .files = &.{
            "gplsrc/qmidx.c",
        },
        .flags = &cflags,
    });

    b.installArtifact(qmidx);

    qmlnxd.linkLibC();

    qmlnxd.addCSourceFiles(.{
        .files = &.{
            "gplsrc/qmlnxd.c",
            "gplsrc/qmsem.c",
        },
        .flags = &cflags,
    });

    b.installArtifact(qmlnxd);

    smath.addIncludePath(b.path("gplsrc"));
    smath.addIncludePath(b.path("src"));
    smath.linkLibC();

    misc.addIncludePath(b.path("gplsrc"));
    misc.addIncludePath(b.path("src"));
    misc.linkLibC();

    hashmap.addIncludePath(b.path("gplsrc"));
    hashmap.addIncludePath(b.path("src"));
    hashmap.linkLibC();

    qm.linkLibC();
    qm.linkSystemLibrary("m");

    if (os == .linux) {
        qm.linkSystemLibrary("crypt");
    }

    qm.linkSystemLibrary("dl");

    qm.addCSourceFiles(.{
        .files = &.{
            "gplsrc/qm.c",
            "gplsrc/analyse.c",
            "gplsrc/b64.c",
            "gplsrc/clopts.c",
            "gplsrc/config.c",
            "gplsrc/ctype.c",
            "gplsrc/dh_ak.c",
            "gplsrc/dh_clear.c",
            "gplsrc/dh_close.c",
            "gplsrc/dh_creat.c",
            "gplsrc/dh_del.c",
            "gplsrc/dh_exist.c",
            "gplsrc/dh_file.c",
            "gplsrc/dh_hash.c",
            "gplsrc/dh_misc.c",
            "gplsrc/dh_open.c",
            "gplsrc/dh_read.c",
            "gplsrc/dh_selct.c",
            "gplsrc/dh_split.c",
            "gplsrc/dh_write.c",
            "gplsrc/ingroup.c",
            "gplsrc/inipath.c",
            "gplsrc/kernel.c",
            "gplsrc/k_error.c",
            "gplsrc/k_funcs.c",
            "gplsrc/linuxio.c",
            "gplsrc/linuxlb.c",
            "gplsrc/linuxprt.c",
            "gplsrc/lnx.c",
            "gplsrc/lnxport.c",
            "gplsrc/messages.c",
            "gplsrc/netfiles.c",
            "gplsrc/object.c",
            "gplsrc/objprog.c",
            "gplsrc/op_arith.c",
            "gplsrc/op_array.c",
            "gplsrc/op_btree.c",
            "gplsrc/op_ccall.c",
            "gplsrc/op_chnge.c",
            "gplsrc/op_config.c",
            "gplsrc/op_debug.c",
            "gplsrc/op_dio1.c",
            "gplsrc/op_dio2.c",
            "gplsrc/op_dio3.c",
            "gplsrc/op_dio4.c",
            "gplsrc/op_exec.c",
            "gplsrc/op_find.c",
            "gplsrc/op_iconv.c",
            "gplsrc/op_jumps.c",
            "gplsrc/op_kernel.c",
            "gplsrc/op_loads.c",
            "gplsrc/op_locat.c",
            "gplsrc/op_lock.c",
            "gplsrc/op_logic.c",
            "gplsrc/op_misc.c",
            "gplsrc/op_mvfun.c",
            "gplsrc/op_oconv.c",
            "gplsrc/op_seqio.c",
            "gplsrc/op_sh.c",
            "gplsrc/op_skt.c",
            "gplsrc/op_sort.c",
            "gplsrc/op_stop.c",
            "gplsrc/op_str1.c",
            "gplsrc/op_str2.c",
            "gplsrc/op_str3.c",
            "gplsrc/op_str4.c",
            "gplsrc/op_str5.c",
            "gplsrc/op_sys.c",
            "gplsrc/op_tio.c",
            "gplsrc/pdump.c",
            "gplsrc/qmlib.c",
            "gplsrc/qmsem.c",
            "gplsrc/qmtermlb.c",
            "gplsrc/reccache.c",
            "gplsrc/strings.c",
            "gplsrc/sysdump.c",
            "gplsrc/sysseg.c",
            "gplsrc/telnet.c",
            "gplsrc/time.c",
            "gplsrc/to_file.c",
            "gplsrc/txn.c",
        },
        .flags = &cflags,
    });

    qm.linkLibrary(smath);
    qm.linkLibrary(misc);
    qm.linkLibrary(hashmap);

    b.installArtifact(qm);
}
