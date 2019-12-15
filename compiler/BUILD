package(default_visibility = ["//visibility:public"])

load("//compiler:config.bzl", "cc_toolchain_config")

filegroup(name = "empty")

filegroup(
    name = "all",
    srcs = [
        "driver/ar",
        "driver/cpp",
        "driver/gcc",
        "driver/gcov",
        "driver/ld",
        "driver/nm",
        "driver/objdump",
        "driver/strip",
        "@mxe_compiler//:all",
    ]
)

cc_toolchain_suite(
    name = "win64",
    toolchains = {
        "k8": ":win64_toolchain",
    },
)

cc_toolchain(
    name = "win64_toolchain",
    toolchain_identifier = "win64-toolchain",
    toolchain_config = ":win64_toolchain_config",
    all_files = ":all",
    ar_files = ":all",
    compiler_files = ":all",
    dwp_files = ":empty",
    linker_files = ":all",
    objcopy_files = ":all",
    strip_files = ":all",
    supports_param_files = 0,
)

cc_toolchain_config(name = "win64_toolchain_config")
