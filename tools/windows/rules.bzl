# A simplistic packaing rule for windows binaries.

def _impl_winzip(ctx):
    args = [
        "--mxe=" + ctx.files.mxe[0].path,
        "--out=" + ctx.outputs.out.path,
    ]
    if ctx.attr.skip_dlls:
        args += ["--skip_dlls=" + ','.join(ctx.attr.skip_dlls)]

    args += [f.path for f in ctx.files.files]
    ctx.action(
        executable = ctx.executable.zip4win,
        arguments = args,
        inputs = ctx.files.files + ctx.files.mxe,
        outputs = [ctx.outputs.out],
        progress_message="Packaging files into " + ctx.outputs.out.basename,
        mnemonic="WinZip"
    )

_pkg_winzip = rule(
    implementation = _impl_winzip,
    attrs = {
        "files": attr.label_list(allow_files=True),
        "skip_dlls": attr.string_list(),
        "mxe": attr.label(
            mandatory=True,
            allow_files=True),
        "zip4win": attr.label(
            default=Label("//tools/windows:zip4win"),
            cfg="host",
            executable=True,
            allow_files=True)
    },
    outputs = {
        "out":  "%{name}.zip",
    },
)

def pkg_winzip(**kwargs):
    _pkg_winzip(
        mxe = select({
            "@mxebzl//tools/windows:win32_mode": "@mingw_compiler_win32//:mxe",
            "@mxebzl//tools/windows:win64_mode": "@mingw_compiler_win64//:mxe",
        }),
        **kwargs
    )
