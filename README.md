# mxebzl
MXE cross compiler configuration for Bazel

## Adding the MXE compilers to your WORKSPACE

In your `WORKSPACE` file, reference this repository. Then load and
create the compilers repository and specify your dependencies.

```
git_repository(
    name = "mxebzl",
    remote = "https://github.com/cfrantz/mxebzl.git",
    commit = "HEAD",
)

load("@mxebzl//tools:repository.bzl", "mxe_compilers")
mxe_compilers(
    deps = [
        "compiler",
        # "SDL2",
        # "sqlite",
        # etc...
    ],
)
```

When you build your project, tell `bazel` about the configuration and
cpu architecture:

```
$ bazel build \
    --crosstool_top=@mxebzl//tools/windows:toolchain
    --cpu=win64 # or win32
    :hello_world
```

## Packaging your executable

You can also use the `pkg_winzip` rule to create a `zip` archive with your
executable, required DLLs and any other specified resources.

In your BUILD file:

```
package(default_visibility = ['//visibility:public'])
load("@mxebzl//tools/windows:rules.bzl", "pkg_winzip")

cc_binary(
    name = 'hello',
    srcs = ['hello.c'],
)

pkg_winzip(
    name = "hello-windows",
    files = [
        ":hello",
        # maybe some other non-exe resources, like a 'content' directory.
    ],
    skip_dlls = [
        # Any system DLLs the dependency analyzer says you need but you
        # aren't shipping with your package.
        # "winmm.dll",
        # etc...
    ],
    out = "whatever.zip", # Optional: defaults to ${name}.zip
)
```

As when building the binary, you also need to tell bazel about the
configuration when you build the package archive:

```
$ bazel build \
    --crosstool_top=@mxebzl//tools/windows:toolchain
    --cpu=win64 # or win32
    :hello-windows
```

After the build finishes, there will be a `hello-windows.zip` in the `bazel-bin`
directory.

