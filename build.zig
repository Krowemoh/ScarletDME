const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    var cflags = [_][]const u8{
        "-Wall",
        "-Wformat=2",
        "-Wno-format-nonliteral",
        "-DLINUX",
        "-D_FILE_OFFSET_BITS=64",
        "-DGPL",
        "-fPIE",
        "-fPIC",
    };

    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseFast });

    const qmtic = b.addExecutable(.{ .name = "qmtic", .optimize = optimize,  });
    qmtic.linkLibC();

    qmtic.addCSourceFiles(&.{
        "gplsrc/qmtic.c",
        "gplsrc/inipath.c"
    }, &cflags);

    b.installArtifact(qmtic);

    const qmfix = b.addExecutable(.{ .name = "qmfix", .optimize = optimize,  });
    qmfix.linkLibC();

    qmfix.addCSourceFiles(&.{
        "gplsrc/qmfix.c",
        "gplsrc/ctype.c",
        "gplsrc/linuxlb.c",
        "gplsrc/dh_hash.c",
        "gplsrc/inipath.c"
    }, &cflags);

    b.installArtifact(qmfix);

    const qmconv = b.addExecutable(.{ .name = "qmconv", .optimize = optimize,  });
    qmconv.linkLibC();

    qmconv.addCSourceFiles(&.{
        "gplsrc/qmconv.c",
        "gplsrc/ctype.c",
        "gplsrc/linuxlb.c",
        "gplsrc/dh_hash.c",
    }, &cflags);

    b.installArtifact(qmconv);

    const qmidx = b.addExecutable(.{ .name = "qmidx", .optimize = optimize,  });
    qmidx.linkLibC();

    qmidx.addCSourceFiles(&.{
        "gplsrc/qmidx.c",
    }, &cflags);

    b.installArtifact(qmidx);

    const qmlnxd = b.addExecutable(.{ .name = "qmlnxd", .optimize = optimize,  });
    qmlnxd.linkLibC();

    qmlnxd.addCSourceFiles(&.{
        "gplsrc/qmlnxd.c",
        "gplsrc/qmsem.c",
    }, &cflags);

    b.installArtifact(qmlnxd);

    const qm = b.addExecutable(.{ .name = "qm", .optimize = optimize, });

    qm.linkLibC();
    qm.linkSystemLibrary("m");
    qm.linkSystemLibrary("crypt");
    qm.linkSystemLibrary("dl");
    qm.linkSystemLibrary("crypto");

    qm.addCSourceFiles(&.{
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
        "gplsrc/op_smath.c",
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
    }, &cflags);

    b.installArtifact(qm);
}
