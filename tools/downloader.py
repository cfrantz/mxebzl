#!/usr/bin/env python2
#############################################################################
#
# downloader.py - Download and Install Windows Cross Compiler for Bazel
#
# Run it like this:
#
# tools/downloader.py compiler [SDL2 ...]
#
# If you want to share cross compiler installations between workspaces,
# use the --altdest option to just point at your personal MXE install:
#
# tools/downloader.py --altdest /home/user/mxe
#
# The downloader can install new packages even with --altdest:
#
# tools/downloader.py --altdest /home/user/mxe compiler SDL2
#
#############################################################################
import argparse
import HTMLParser
import errno
import os
import os.path
import subprocess
import sys
import urllib
import urllib2 as u2

DISTRO = 'bionic'

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
        'libsamplerate',
        'ogg',
        'tiff',
        'vorbis',
        'zlib',
    ]
}

PKGS = {
#    'python': 'python_3.7.1.tar.xz'
}

TARGETS = {
    'shared': 'mxe-x86-64-w64-mingw32.shared',
    'static': 'mxe-x86-64-w64-mingw32.static',
}

LOCALS = []

flags = argparse.ArgumentParser(description='Windows Cross Compiler Downloader')
flags.add_argument('packages', metavar='PKG', type=str, nargs='*',
                   help='Packages to download')
flags.add_argument('--addons', dest='addons', default='',
                   help='Additiona packages dir not part of the MXE distribution.')
flags.add_argument('--cache', dest='cache', default=False, action='store_true',
                   help='Reuse files in tmp cache (False)')
flags.add_argument('--dest', default='tools/mxe',
                   help='Location to install packages')
flags.add_argument('--list', default=False, action='store_true',
                   help='List packages')
flags.add_argument('--altdest', default='',
                   help='Install packages in altdest, and symlink dest there')
flags.add_argument('--webroot', default='https://pkg.mxe.cc/repos/apt/pool/main/m',
                   help='Package download location (http://pkg.mxe.cc/repos/apt/pool/main/m)')
flags.add_argument('--tmp', default='/tmp/mxe',
                   help='Temporary download directory (/tmp/mxe)')
flags.add_argument('--wget_bin', default='/usr/bin/wget',
                   help='Location of wget binary (/usr/bin/wget)')
flags.add_argument('--tar_bin', default='/bin/tar',
                   help='Location of tar binary (/bin/tar)')
flags.add_argument('--shared', dest='shared', default=False, action='store_true',
                   help='Install shared library packages (False)')
flags.add_argument('--static', dest='static', default=False, action='store_true',
                   help='Install static library packages (False)')
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
    url = args.webroot + '/'
    req = u2.urlopen(url)
    html = req.read()
    hc = AHrefCollector()
    hc.feed(html)
    for filename in hc.hrefs:
        if TARGETS['shared'] not in filename:
            continue
        pkgname = (filename.replace(TARGETS['shared']+'-', '')
                   .replace(TARGETS['static']+'_', '')).split('_')
        PKGS[pkgname[0].replace('/', '')] = pkgname[0]

def resolve_to_archive(dirname):
    if not dirname.endswith('/'):
        return dirname

    url = '%s/%s' % (args.webroot, dirname)
    print("resolve:", url)
    req = u2.urlopen(url)
    html = req.read()
    hc = AHrefCollector()
    hc.feed(html)
    for filename in hc.hrefs:
        if DISTRO in filename:
            return dirname + filename
    raise Exception('Cannot resolve %r to a filename' % dirname, dirname)

def collect_addons(args):
    if not args.addons:
        return

    prefix = TARGETS['shared'] + '-'
    for filename in os.listdir(args.addons):
        if filename.startswith('mxe-') and filename.endswith('.tar.xz'):
            filename = filename.replace(prefix, '')
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
    if args.shared:
        targ.append(('shared', TARGETS['shared']))
    if args.static:
        targ.append(('static', TARGETS['static']))

    makedirs(args.tmp)
    for name, t in targ:
        filename = resolve_to_archive(t + '-' + PKGS[pkg])
        url = args.webroot + '/' + filename
        local =  os.path.join(args.tmp, os.path.basename(filename))
        addon =  os.path.join(args.addons, filename)

        # Transform the target and package names to how they appear on the
        # filesystem, then check if the package has already been installed.
        installed = os.path.join(args.dest, 'usr',
                                 t.replace('x86-64', 'x86_64'),
                                 'installed', pkg.replace('-', '_'))
        if os.path.exists(installed) and not args.force:
            print 'Skipping', name, pkg, 'because it is already installed.'
            continue

        if args.addons and os.path.isfile(addon):
            print 'Using addon file %r' % addon
            local = addon
        elif args.cache and os.path.isfile(local):
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
            if filename.endswith('.deb'):
                ar = subprocess.Popen(['ar', 'p', filename, 'data.tar.xz'],
                        stdout=subprocess.PIPE)
                tar = subprocess.call([args.tar_bin, '--strip-components=4',
                                       '-Jxf', '-'], stdin=ar.stdout)
            else:
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
        collect_addons(args)

    if (args.list):
        list_packages()
        sys.exit(0)

    download(args)
    install(args)
