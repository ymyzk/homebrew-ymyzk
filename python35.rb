require "formula"

class Python35 < Formula
  homepage "https://www.python.org/"

  VER="3.5"  # The <major>.<minor> is used so often.

  head "https://hg.python.org/cpython", :using => :hg, :branch => 'default'

  option :universal
  option "quicktest", "Run `make quicktest` after the build"

  depends_on "pkg-config" => :build
  depends_on "readline" => :recommended
  depends_on "sqlite" => :recommended
  depends_on "gdbm" => :recommended
  depends_on "openssl"
  depends_on "xz" => :recommended  # for the lzma module added in 3.3

  def site_packages_cellar
    prefix/"Frameworks/Python.framework/Versions/#{VER}/lib/python#{VER}/site-packages"
  end

  # The HOMEBREW_PREFIX location of site-packages.
  def site_packages
    HOMEBREW_PREFIX/"lib/python#{VER}/site-packages"
  end

  def install
    # Unset these so that installing pip and setuptools puts them where we want
    # and not into some other Python the user has installed.
    ENV["PYTHONHOME"] = nil
    ENV["PYTHONPATH"] = nil

    args = %W[
      --prefix=#{prefix}
      --enable-ipv6
      --datarootdir=#{share}
      --datadir=#{share}
      --enable-framework=#{frameworks}
    ]

    args << "--without-gcc" if ENV.compiler == :clang

    distutils_fix_superenv(args)

    if build.universal?
      ENV.universal_binary
      args << "--enable-universalsdk" << "--with-universal-archs=intel"
    end

    # Allow sqlite3 module to load extensions: http://docs.python.org/library/sqlite3.html#f1
    inreplace("setup.py", 'sqlite_defines.append(("SQLITE_OMIT_LOAD_EXTENSION", "1"))', 'pass') if build.with? "sqlite"

    # Allow python modules to use ctypes.find_library to find homebrew's stuff
    # even if homebrew is not a /usr/local/lib. Try this with:
    # `brew install enchant && pip install pyenchant`
    inreplace "./Lib/ctypes/macholib/dyld.py" do |f|
      f.gsub! 'DEFAULT_LIBRARY_FALLBACK = [', "DEFAULT_LIBRARY_FALLBACK = [ '#{HOMEBREW_PREFIX}/lib',"
      f.gsub! 'DEFAULT_FRAMEWORK_FALLBACK = [', "DEFAULT_FRAMEWORK_FALLBACK = [ '#{HOMEBREW_PREFIX}/Frameworks',"
    end

    system "./configure", *args

    system "make"

    ENV.deparallelize # Installs must be serialized
    # Tell Python not to install into /Applications (default for framework builds)
    system "make", "altinstall", "PYTHONAPPSDIR=#{prefix}"
    # Demos and Tools
    system "make", "frameworkinstallextras", "PYTHONAPPSDIR=#{share}/python3"
    system "make", "quicktest" if build.include? "quicktest"

    # Any .app get a " 3" attached, so it does not conflict with python 2.x.
    Dir.glob("#{prefix}/*.app") { |app| mv app, app.sub(".app", " 3.app") }

    # A fix, because python and python3 both want to install Python.framework
    # and therefore we can't link both into HOMEBREW_PREFIX/Frameworks
    # https://github.com/Homebrew/homebrew/issues/15943
    ["Headers", "Python", "Resources"].each{ |f| rm(prefix/"Frameworks/Python.framework/#{f}") }
    rm prefix/"Frameworks/Python.framework/Versions/Current"

    # Remove 2to3 because python2 also installs it
    #rm bin/"2to3"

    # Remove the site-packages that Python created in its Cellar.
    site_packages_cellar.rmtree
  end

  def post_install
    # Fix up the site-packages so that user-installed Python software survives
    # minor updates, such as going from 3.3.2 to 3.3.3:

    # Create a site-packages in HOMEBREW_PREFIX/lib/python#{VER}/site-packages
    site_packages.mkpath

    # Symlink the prefix site-packages into the cellar.
    site_packages_cellar.unlink if site_packages_cellar.exist?
    site_packages_cellar.parent.install_symlink site_packages

    # Write our sitecustomize.py
    rm_rf Dir["#{site_packages}/sitecustomize.py[co]"]
    (site_packages/"sitecustomize.py").atomic_write(sitecustomize)

    # And now we write the distutils.cfg
    cfg = prefix/"Frameworks/Python.framework/Versions/#{VER}/lib/python#{VER}/distutils/distutils.cfg"
    cfg.atomic_write <<-EOF.undent
      [global]
      verbose=1
      [install]
      prefix=#{HOMEBREW_PREFIX}
    EOF
  end

  def distutils_fix_superenv(args)
    # To allow certain Python bindings to find brewed software (and sqlite):
    sqlite = Formula["sqlite"].opt_prefix
    cflags = "CFLAGS=-I#{HOMEBREW_PREFIX}/include -I#{sqlite}/include"
    ldflags = "LDFLAGS=-L#{HOMEBREW_PREFIX}/lib -L#{sqlite}/lib"
    unless MacOS::CLT.installed?
      # Help Python's build system (setuptools/pip) to build things on Xcode-only systems
      # The setup.py looks at "-isysroot" to get the sysroot (and not at --sysroot)
      cflags += " -isysroot #{MacOS.sdk_path}"
      ldflags += " -isysroot #{MacOS.sdk_path}"
      args << "CPPFLAGS=-I#{MacOS.sdk_path}/usr/include" # find zlib
    end
    args << cflags
    args << ldflags
    # Avoid linking to libgcc http://code.activestate.com/lists/python-dev/112195/
    args << "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
    # We want our readline! This is just to outsmart the detection code,
    # superenv makes cc always find includes/libs!
    inreplace "setup.py",
              "do_readline = self.compiler.find_library_file(lib_dirs, 'readline')",
              "do_readline = '#{Formula["readline"].opt_lib}/libhistory.dylib'"
  end

  def sitecustomize
    <<-EOF.undent
      # This file is created by Homebrew and is executed on each python startup.
      # Don't print from here, or else python command line scripts may fail!
      # <https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Homebrew-and-Python.md>
      import os
      import sys

      if sys.version_info[0] != 3:
          # This can only happen if the user has set the PYTHONPATH for 3.x and run Python 2.x or vice versa.
          # Every Python looks at the PYTHONPATH variable and we can't fix it here in sitecustomize.py,
          # because the PYTHONPATH is evaluated after the sitecustomize.py. Many modules (e.g. PyQt4) are
          # built only for a specific version of Python and will fail with cryptic error messages.
          # In the end this means: Don't set the PYTHONPATH permanently if you use different Python versions.
          exit('Your PYTHONPATH points to a site-packages dir for Python 3.x but you are running Python ' +
               str(sys.version_info[0]) + '.x!\\n     PYTHONPATH is currently: "' + str(os.environ['PYTHONPATH']) + '"\\n' +
               '     You should `unset PYTHONPATH` to fix this.')
      else:
          # Only do this for a brewed python:
          opt_executable = '#{opt_bin}/python#{VER}'
          if os.path.realpath(sys.executable) == os.path.realpath(opt_executable):
              # Remove /System site-packages, and the Cellar site-packages
              # which we moved to lib/pythonX.Y/site-packages. Further, remove
              # HOMEBREW_PREFIX/lib/python because we later addsitedir(...).
              sys.path = [ p for p in sys.path
                           if (not p.startswith('/System') and
                               not p.startswith('#{HOMEBREW_PREFIX}/lib/python') and
                               not (p.startswith('#{rack}') and p.endswith('site-packages'))) ]

              # LINKFORSHARED (and python-config --ldflags) return the
              # full path to the lib (yes, "Python" is actually the lib, not a
              # dir) so that third-party software does not need to add the
              # -F/#{HOMEBREW_PREFIX}/Frameworks switch.
              # Assume Framework style build (default since months in brew)
              try:
                  from _sysconfigdata import build_time_vars
                  build_time_vars['LINKFORSHARED'] = '-u _PyMac_Error #{opt_prefix}/Frameworks/Python.framework/Versions/#{VER}/Python'
              except:
                  pass  # remember: don't print here. Better to fail silently.

              # Set the sys.executable to use the opt_prefix
              sys.executable = opt_executable

          # Tell about homebrew's site-packages location.
          # This is needed for Python to parse *.pth.
          import site
          site.addsitedir('#{site_packages}')
    EOF
  end

  test do
    # Check if sqlite is ok, because we build with --enable-loadable-sqlite-extensions
    # and it can occur that building sqlite silently fails if OSX's sqlite is used.
    system "#{bin}/python#{VER}", "-c", "import sqlite3"
    # Check if some other modules import. Then the linked libs are working.
    system "#{bin}/python#{VER}", "-c", "import tkinter; root = tkinter.Tk()"
  end
end
