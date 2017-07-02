package(default_visibility = ['//visibility:public'])

filegroup(
    name = 'gcc',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-gcc'],
)

filegroup(
    name = 'addr2line',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-addr2line'],
)

filegroup(
    name = 'ar',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-ar'],
)

filegroup(
    name = 'as',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-as'],
)

filegroup(
    name = 'c++filt',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-c++filt'],
)

filegroup(
    name = 'dlltool',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-dlltool'],
)

filegroup(
    name = 'dllwrap',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-dllwrap'],
)

filegroup(
    name = 'elfedit',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-elfedit'],
)

filegroup(
    name = 'gprof',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-gprof'],
)

filegroup(
    name = 'ld',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-ld'],
)

filegroup(
    name = 'ld.bfd',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-ld.bfd'],
)

filegroup(
    name = 'nm',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-nm'],
)

filegroup(
    name = 'objcopy',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-objcopy'],
)

filegroup(
    name = 'objdump',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-objdump'],
)

filegroup(
    name = 'ranlib',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-ranlib'],
)

filegroup(
    name = 'readelf',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-readelf'],
)

filegroup(
    name = 'size',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-size'],
)

filegroup(
    name = 'strings',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-strings'],
)

filegroup(
    name = 'strip',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-strip'],
)

filegroup(
    name = 'windmc',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-windmc'],
)

filegroup(
    name = 'windres',
    srcs = ['mxe/usr/bin/x86_64-w64-mingw32.shared-windres'],
)

filegroup(
  name = 'compiler_pieces',
  srcs = glob([
    'mxe/usr/x86_64-w64-mingw32.shared/**',
    'mxe/usr/libexec/gcc/x86_64-w64-mingw32.shared/**',
    'mxe/usr/lib/gcc/x86_64-w64-mingw32.shared/**',
  ]),
)

filegroup(
    name = 'compiler_components',
    srcs = [
        ':gcc',
        ':addr2line',
        ':ar',
        ':as',
        ':c++filt',
        ':dlltool',
        ':dllwrap',
        ':elfedit',
        ':gprof',
        ':ld',
        ':ld.bfd',
        ':nm',
        ':objcopy',
        ':objdump',
        ':ranlib',
        ':readelf',
        ':size',
        ':strings',
        ':strip',
        ':windmc',
        ':windres',
    ],
)

exports_files(["mxe"])
