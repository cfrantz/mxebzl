#############################################################################
#
# repository.bzl - download MXE cross compilers and libraries as
# bazel repositories.
#
#############################################################################

downloader_script = """#!/usr/bin/env python2
import argparse
import HTMLParser
import errno
import os
import os.path
import subprocess
import sys
import urllib
import urllib2 as u2

METAPKG = {
    'compiler': [
        'binutils',
        'gcc',
    ],
    'SDL2': [
        'sdl2-gfx',
        'sdl2-image',
        'sdl2-mixer',
        'sdl2-net',
        'sdl2-ttf',
        'sdl2',
    ],
    'SDL2-extras': [
        'freetype',
        'jpeg',
        'libpng',
        'libwebp',
        'ogg',
        'tiff',
        'vorbis',
        'zlib',
    ]
}

PKGS = {}

TARGETS = {
    'win32': 'i686-w64-mingw32.shared',
    'win64': 'x86-64-w64-mingw32.shared',
}

LOCALS = []

flags = argparse.ArgumentParser(description='Windows Cross Compiler Downloader')
flags.add_argument('packages', metavar='PKG', type=str, nargs='*',
                   help='Packages to download')
flags.add_argument('--cache', dest='cache', default=False, action='store_true',
                   help='Reuse files in tmp cache (False)')
flags.add_argument('--dest', default='tools/mxe',
                   help='Location to install packages')
flags.add_argument('--list', default=False, action='store_true',
                   help='List packages')
flags.add_argument('--altdest', default='',
                   help='Install packages in altdest, and symlink dest there')
flags.add_argument('--webroot', default='http://pkg.mxe.cc/repos/tar',
                   help='Package download location (http://pkg.mxe.cc/repos/tar)')
flags.add_argument('--tmp', default='/tmp/mxe',
                   help='Temporary download directory (/tmp/mxe)')
flags.add_argument('--wget_bin', default='/usr/bin/wget',
                   help='Location of wget binary (/usr/bin/wget)')
flags.add_argument('--tar_bin', default='/bin/tar',
                   help='Location of tar binary (/bin/tar)')
flags.add_argument('--win32', dest='win32', default=False, action='store_true',
                   help='Install win32 packages (False)')
flags.add_argument('--win64', dest='win64', default=False, action='store_true',
                   help='Install win64 packages (False)')
flags.add_argument('--force', action='store_true',
                   help='Install packages even if already installed.')

class AHrefCollector(HTMLParser.HTMLParser):
    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)
        self.hrefs = []
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'a' and 'href' in attrs:
            href = attrs['href']
            if href != '../':
                self.hrefs.append(href)


def download_pkg_list(args):
    print 'Downloading package list.'
    url = args.webroot + '/mxe-' + TARGETS['win64']
    req = u2.urlopen(url)
    html = req.read()
    hc = AHrefCollector()
    hc.feed(html)
    prefix = 'mxe-' + TARGETS['win64'] + '-'
    for filename in hc.hrefs:
        filename = filename.replace(prefix, '')
        filename = urllib.unquote(filename)
        (pkgname, suffix) = filename.split('_')
        PKGS[pkgname] = filename

def list_packages():
    print "Packages:"
    for k in sorted(PKGS.keys()):
        print "    ", k, "->", PKGS[k]
    print
    print "Meta-Packages:"
    for k in sorted(METAPKG.keys()):
        print "    ", k, "->", ', '.join(METAPKG[k])

def makedirs(d):
    try:
        os.makedirs(d)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise e

def download_pkg(args, pkg):
    targ = []
    if args.win32:
        targ.append(('win32', TARGETS['win32']))
    if args.win64:
        targ.append(('win64', TARGETS['win64']))

    makedirs(args.tmp)
    for name, t in targ:
        filename = 'mxe-' + t + '-' + PKGS[pkg]
        url = args.webroot + '/mxe-' + t + '/' + filename
        local =  os.path.join(args.tmp, filename)

        # Transform the target and package names to how they appear on the
        # filesystem, then check if the package has already been installed.
        installed = os.path.join(args.dest, 'usr',
                                 t.replace('x86-64', 'x86_64'),
                                 'installed', pkg.replace('-', '_'))
        if os.path.exists(installed) and not args.force:
            print 'Skipping', name, pkg, 'because it is already installed.'
            continue

        if args.cache and os.path.isfile(local):
            print 'Already have %r in cache as %r' % (url, local)
        else:
            print 'Downloading', url
            subprocess.call([args.wget_bin, url, '-O', local])
        LOCALS.append(local)

def download_metapkg(args, pkg):
    for p in METAPKG[pkg]:
        download_pkg(args, p)

def download(args):
    for pkg in args.packages:
        if pkg in METAPKG:
            download_metapkg(args, pkg)
        elif pkg in PKGS:
            download_pkg(args, pkg)
        else:
            print 'Unknown package name', pkg
            sys.exit(1)

def install(args):
    cwd = os.getcwd()
    try:
        makedirs(args.dest)
        os.chdir(args.dest)
        for filename in LOCALS:
            print 'Installing', filename
            subprocess.call([args.tar_bin, 'Jxf', filename])
    finally:
        os.chdir(cwd)


if __name__ == '__main__':
    args = flags.parse_args(sys.argv[1:])

    if (args.altdest):
        makedirs(args.altdest)
        os.unlink(args.dest)
        os.symlink(args.altdest, args.dest)

    if args.list or args.packages:
        download_pkg_list(args)

    if (args.list):
        list_packages()
        sys.exit(0)

    download(args)
    install(args)
"""

def _mxe_compiler(ctx):
    print("Initializing %s compiler repository" % ctx.attr.arch)
    ctx.file(ctx.attr.downloader_py, downloader_script, True)
    
    cmd = [ctx.attr.python2,
           ctx.attr.downloader_py,
           '--dest=mxe',
           '--' + ctx.attr.arch]

    if ctx.attr.cache:
        cmd.append('--cache')

    cmd.extend(ctx.attr.deps)
    result = ctx.execute(cmd)
    if result.return_code != 0:
        fail("STDOUT =\n%s\nSTDERR =\n%s\n\nFailed to fetch dependencies" %(
             result.stdout, result.stderr))
    ctx.symlink(ctx.attr.build_file, 'BUILD')
        
mxe_compiler = repository_rule(
    implementation=_mxe_compiler,
    attrs = {
        "arch": attr.string(mandatory=True),
        "build_file": attr.label(mandatory=True),
        "cache": attr.bool(default=False),
        "deps": attr.string_list(mandatory=True),
        "downloader_py": attr.string(default="downloader.py"),
        "python2": attr.string(default="/usr/bin/python2"),
    },
)

def mxe_compilers(arch=['win32', 'win64'], deps=['compiler'], cache=True,
                  downloader_py="downloader.py", python2="/usr/bin/python2"):
    for a in arch:
        mxe_compiler(
            name = "mingw_compiler_" + a,
            arch = a,
            build_file = "@mxebzl//tools:mingw_compiler_%s.BUILD" % a,
            cache = cache,
            deps = deps,
            downloader_py = downloader_py,
            python2 = python2,
        )
