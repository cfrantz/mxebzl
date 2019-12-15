# A simplistic packaing rule for windows binaries.

def _impl_winzip(ctx):
    args = [
        "--mxe=" + ctx.files.mxe[0].dirname,
        "--out=" + ctx.outputs.out.path,
    ]
    if ctx.attr.skip_dlls:
        args += ["--skip_dlls=" + ','.join(ctx.attr.skip_dlls)]
    if ctx.attr.zips:
        args += ["--combine_zips=" + ','.join([f.path for f in ctx.files.zips])]

    args += [f.path for f in ctx.files.files]
    # print("args ", args)
    ctx.actions.run(
        executable = ctx.executable.zip4win,
        arguments = args,
        inputs = ctx.files.files + ctx.files.mxe + ctx.files.zips,
        outputs = [ctx.outputs.out],
        progress_message="Packaging files into " + ctx.outputs.out.basename,
        mnemonic="WinZip"
    )

pkg_winzip = rule(
    implementation = _impl_winzip,
    attrs = {
        "files": attr.label_list(allow_files=True),
        "skip_dlls": attr.string_list(),
        "mxe": attr.label(
            default = "@mxe_compiler//:all",
            allow_files=True),
        "zip4win": attr.label(
            default=Label("//tools:zip4win"),
            cfg="host",
            executable=True,
            allow_files=True),
        "zips": attr.label_list(allow_files=True),
    },
    outputs = {
        "out":  "%{name}.zip",
    },
)
