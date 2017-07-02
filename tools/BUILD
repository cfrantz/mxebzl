package(default_visibility = ["//visibility:public"])

exports_files(["mxe"])

filegroup(
    name = "srcs",
    srcs = glob(["**"], exclude=["mxe/**"]) + [
        "//tools/windows:srcs",
    ],
)

py_binary(
    name = "downloader",
    srcs = ["downloader.py"],
)
