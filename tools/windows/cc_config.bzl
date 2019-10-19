load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "artifact_name_pattern",
    "env_entry",
    "env_set",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "make_variable",
    "tool",
    "tool_path",
    "variable_with_value",
    "with_feature_set",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

def _impl(ctx):
    if (ctx.attr.cpu == "local"):
        toolchain_identifier = "local_linux"
    elif (ctx.attr.cpu == "win32"):
        toolchain_identifier = "mingw_win32"
    elif (ctx.attr.cpu == "win64"):
        toolchain_identifier = "mingw_win64"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "local"):
        host_system_name = "local"
    elif (ctx.attr.cpu == "win32"
        or ctx.attr.cpu == "win64"):
        host_system_name = "x86_64-linux"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "local"):
        target_system_name = "local"
    elif (ctx.attr.cpu == "win32"):
        target_system_name = "windows_win32"
    elif (ctx.attr.cpu == "win64"):
        target_system_name = "windows_win64"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "local"):
        target_cpu = "local"
    elif (ctx.attr.cpu == "win32"):
        target_cpu = "win32"
    elif (ctx.attr.cpu == "win64"):
        target_cpu = "win64"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "win32"
        or ctx.attr.cpu == "win64"):
        target_libc = "glibc_2.19"
    elif (ctx.attr.cpu == "local"):
        target_libc = "local"
    else:
        fail("Unreachable")

    compiler = "compiler"

    if (ctx.attr.cpu == "win32"
        or ctx.attr.cpu == "win64"):
        abi_version = "gcc-5.5.0"
    elif (ctx.attr.cpu == "local"):
        abi_version = "local"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "win32"
        or ctx.attr.cpu == "win64"):
        abi_libc_version = "glibc_2.19"
    elif (ctx.attr.cpu == "local"):
        abi_libc_version = "local"
    else:
        fail("Unreachable")

    cc_target_os = None

    builtin_sysroot = None

    all_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.clif_match,
        ACTION_NAMES.lto_backend,
    ]

    all_cpp_compile_actions = [
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.clif_match,
    ]

    preprocessor_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.clif_match,
    ]

    codegen_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.lto_backend,
    ]

    all_link_actions = [
        ACTION_NAMES.cpp_link_executable,
        ACTION_NAMES.cpp_link_dynamic_library,
        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ]

    action_configs = []

    features = []

    if (ctx.attr.cpu == "win32"):
        cxx_builtin_include_directories = [
                "%package(@mingw_compiler_win32//mxe/usr/i686-w64-mingw32.shared/include)%",
                "%package(@mingw_compiler_win32//mxe/usr/i686-w64-mingw32.shared/5.5.0/include)%",
                "%package(@mingw_compiler_win32//mxe/usr/lib/gcc/i686-w64-mingw32.shared/5.5.0/include-fixed)%",
            ]
    elif (ctx.attr.cpu == "win64"):
        cxx_builtin_include_directories = [
                "%package(@mingw_compiler_win64//mxe/usr/x86_64-w64-mingw32.shared/include)%",
                "%package(@mingw_compiler_win64//mxe/usr/x86_64-w64-mingw32.shared/5.5.0/include)%",
                "%package(@mingw_compiler_win64//mxe/usr/lib/gcc/x86_64-w64-mingw32.shared/5.5.0/include-fixed)%",
            ]
    elif (ctx.attr.cpu == "local"):
        cxx_builtin_include_directories = ["/usr/lib/gcc/", "/usr/local/include", "/usr/include"]
    else:
        fail("Unreachable")

    artifact_name_patterns = []

    make_variables = []

    if (ctx.attr.cpu == "win32"):
        tool_paths = [
            tool_path(
                name = "ar",
                path = "win32/i686-w64-mingw32.shared-ar",
            ),
            tool_path(
                name = "compat-ld",
                path = "win32/i686-w64-mingw32.shared-ld",
            ),
            tool_path(
                name = "cpp",
                path = "win32/i686-w64-mingw32.shared-cpp",
            ),
            tool_path(
                name = "dwp",
                path = "win32/i686-w64-mingw32.shared-dwp",
            ),
            tool_path(
                name = "gcc",
                path = "win32/i686-w64-mingw32.shared-gcc",
            ),
            tool_path(
                name = "gcov",
                path = "win32/i686-w64-mingw.shared-gcov",
            ),
            tool_path(
                name = "ld",
                path = "win32/i686-w64-mingw32.shared-ld",
            ),
            tool_path(
                name = "nm",
                path = "win32/i686-w64-mingw32.shared-nm",
            ),
            tool_path(
                name = "objcopy",
                path = "win32/i686-w64-mingw32.shared-objcopy",
            ),
            tool_path(
                name = "objdump",
                path = "win32/i686-w64-mingw32.shared-objdump",
            ),
            tool_path(
                name = "strip",
                path = "win32/i686-w64-mingw32.shared-strip",
            ),
        ]
    elif (ctx.attr.cpu == "win64"):
        tool_paths = [
            tool_path(
                name = "ar",
                path = "win64/x86_64-w64-mingw32.shared-ar",
            ),
            tool_path(
                name = "compat-ld",
                path = "win64/x86_64-w64-mingw32.shared-ld",
            ),
            tool_path(
                name = "cpp",
                path = "win64/x86_64-w64-mingw32.shared-cpp",
            ),
            tool_path(
                name = "dwp",
                path = "win64/x86_64-w64-mingw32.shared-dwp",
            ),
            tool_path(
                name = "gcc",
                path = "win64/x86_64-w64-mingw32.shared-gcc",
            ),
            tool_path(
                name = "gcov",
                path = "win64/x86_64-w64-mingw.shared-gcov",
            ),
            tool_path(
                name = "ld",
                path = "win64/x86_64-w64-mingw32.shared-ld",
            ),
            tool_path(
                name = "nm",
                path = "win64/x86_64-w64-mingw32.shared-nm",
            ),
            tool_path(
                name = "objcopy",
                path = "win64/x86_64-w64-mingw32.shared-objcopy",
            ),
            tool_path(
                name = "objdump",
                path = "win64/x86_64-w64-mingw32.shared-objdump",
            ),
            tool_path(
                name = "strip",
                path = "win64/x86_64-w64-mingw32.shared-strip",
            ),
        ]
    elif (ctx.attr.cpu == "local"):
        tool_paths = [
            tool_path(name = "ar", path = "/usr/bin/ar"),
            tool_path(name = "compat-ld", path = "/usr/bin/ld"),
            tool_path(name = "cpp", path = "/usr/bin/cpp"),
            tool_path(name = "dwp", path = "/usr/bin/dwp"),
            tool_path(name = "gcc", path = "/usr/bin/gcc"),
            tool_path(name = "gcov", path = "/usr/bin/gcov"),
            tool_path(name = "ld", path = "/usr/bin/ld"),
            tool_path(name = "nm", path = "/usr/bin/nm"),
            tool_path(name = "objcopy", path = "/usr/bin/objcopy"),
            tool_path(name = "objdump", path = "/usr/bin/objdump"),
            tool_path(name = "strip", path = "/usr/bin/strip"),
        ]
    else:
        fail("Unreachable")


    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(out, "Fake executable")
    return [
        cc_common.create_cc_toolchain_config_info(
            ctx = ctx,
            features = features,
            action_configs = action_configs,
            artifact_name_patterns = artifact_name_patterns,
            cxx_builtin_include_directories = cxx_builtin_include_directories,
            toolchain_identifier = toolchain_identifier,
            host_system_name = host_system_name,
            target_system_name = target_system_name,
            target_cpu = target_cpu,
            target_libc = target_libc,
            compiler = compiler,
            abi_version = abi_version,
            abi_libc_version = abi_libc_version,
            tool_paths = tool_paths,
            make_variables = make_variables,
            builtin_sysroot = builtin_sysroot,
            cc_target_os = cc_target_os
        ),
        DefaultInfo(
            executable = out,
        ),
    ]
cc_toolchain_config =  rule(
    implementation = _impl,
    attrs = {
        "cpu": attr.string(mandatory=True, values=["local", "win32", "win64"]),
    },
    provides = [CcToolchainConfigInfo],
    executable = True,
)
