#############################################################################
#
# repository.bzl - download MXE cross compilers and libraries as
# bazel repositories.
#
#############################################################################

def _mxe_compiler_impl(ctx):
    print("Initializing mxe_compiler repository")
    ctx.symlink(ctx.attr.downloader_py, 'downloader.py')
    addons = ctx.path(ctx.attr.addons)

    cmd = [ctx.attr.python2,
           'downloader.py',
           '--dest=.',
           '--addons=' + str(addons.dirname),
           '--shared']

    if ctx.attr.cache:
        cmd.append('--cache')

    cmd.extend(ctx.attr.deps)
    result = ctx.execute(cmd)
    if result.return_code != 0:
        fail("STDOUT =\n%s\nSTDERR =\n%s\n\nFailed to fetch dependencies" % (
             result.stdout, result.stderr))
    ctx.symlink(ctx.attr.build_file, 'BUILD')
        
_mxe_compiler = repository_rule(
    implementation=_mxe_compiler_impl,
    attrs = {
        "addons": attr.label(
            doc = "Location of non-mxe supplied addon libraries.",
            default="@mxebzl//addons:BUILD",
            allow_files=True,
        ),
        "build_file": attr.label(
            doc = "Build file which exports the mxe toolchain files.",
            mandatory=True
        ),
        "cache": attr.bool(default=True),
        "deps": attr.string_list(
            doc = "List of mxe deps (e.g. compiler, SDL2, zlib, etc).",
            mandatory=True
        ),
        "downloader_py": attr.label(
            doc = "MXE downloader script.",
            default=Label("@mxebzl//tools:downloader.py"),
            allow_files=True
        ),
        "python2": attr.string(default="/usr/bin/python2"),
    },
)

def mxe_compiler(deps, **kwargs):
    _mxe_compiler(
        name = "mxe_compiler",
        deps = deps,
        build_file = "@mxebzl//compiler:mxe.BUILD",
        **kwargs
    )

