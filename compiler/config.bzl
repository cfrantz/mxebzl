load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "tool_path")

def _impl(ctx):
    tool_paths = [
        tool_path(
            name = "gcc",
            path = "driver/gcc",
        ),
        tool_path(
            name = "ld",
            path = "driver/ld",
        ),
        tool_path(
            name = "ar",
            path = "driver/ar",
        ),
        tool_path(
            name = "cpp",
            path = "driver/cpp",
        ),
        tool_path(
            name = "gcov",
            path = "driver/gcov",
        ),
        tool_path(
            name = "nm",
            path = "driver/nm",
        ),
        tool_path(
            name = "objdump",
            path = "driver/objdump",
        ),
        tool_path(
            name = "strip",
            path = "driver/strip",
        ),
    ]
    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "win64-toolchain",
        host_system_name = "i686-unknown-linux-gnu",
        target_system_name = "win64-mxe-gcc",
        target_cpu = "k8",
        target_libc = "unknown",
        compiler = "mxe",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
