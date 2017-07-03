#############################################################################
#
# repository.bzl - download MXE cross compilers and libraries as
# bazel repositories.
#
#############################################################################

def _mxe_compiler(ctx):
    print("Initializing %s compiler repository" % ctx.attr.arch)
    ctx.symlink(ctx.attr.downloader_py, 'downloader.py')
    
    cmd = [ctx.attr.python2,
           'downloader.py',
           '--dest=mxe',
           '--' + ctx.attr.arch]

    if ctx.attr.cache:
        cmd.append('--cache')

    cmd.extend(ctx.attr.deps)
    result = ctx.execute(cmd)
    if result.return_code != 0:
        fail("STDOUT =\n%s\nSTDERR =\n%s\n\nFailed to fetch dependencies" % (
             result.stdout, result.stderr))
    ctx.symlink(ctx.attr.build_file, 'BUILD')
        
mxe_compiler = repository_rule(
    implementation=_mxe_compiler,
    attrs = {
        "arch": attr.string(mandatory=True),
        "build_file": attr.label(mandatory=True),
        "cache": attr.bool(default=True),
        "deps": attr.string_list(mandatory=True),
        "downloader_py": attr.label(
                default=Label("@mxebzl//tools:downloader.py"),
                allow_files=True),
        "python2": attr.string(default="/usr/bin/python2"),
    },
)

def mxe_compilers(arch=['win32', 'win64'], deps=['compiler'], **kwargs):
    for a in arch:
        mxe_compiler(
            name = "mingw_compiler_" + a,
            arch = a,
            build_file = "@mxebzl//tools:mingw_compiler_%s.BUILD" % a,
            deps = deps,
            **kwargs)
