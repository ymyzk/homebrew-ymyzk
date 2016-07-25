class Jakld < Formula
  desc "JAKLD"
  homepage "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/index.html"

  option "with-tail-recursive", "Supports tail recursive optimization"
  option "with-picture-language", "Supports the picture language of SICP & tail recursive optimization"

  depends_on :java

  if build.with? "tail-recursive"
    homepage "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/index-j.html"
    url "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/zenbu.tar"
    version "20080903"
  elsif build.with? "picture-language"
    url "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/jakld.jar"
    version "20100725"
    sha256 "05cd0cd2606d4c26b51081714a96d19bea48da78dc812bf434f6b53740d2eac2"
  else
    url "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/all.tar.gz"
    version "20100725"
    sha256 "235e4dd26c0daf6e4fe46e18dab044ab371e039e5c3114543a50d96574ab40f5"
  end

  def install
    jar_file_name = "jakld.jar"
    if build.without? "picture-language"
      classes = [
        "Char.class",
        "Contin.class",
        "Env.class",
        "Eval.class",
        "Function.class",
        "IO.class",
        "Lambda.class",
        "List.class",
        "Misc.class",
        "Num.class",
        "Pair.class",
        "Subr.class",
        "Symbol.class",
      ]
      if build.with? "tail-recursive"
        classes.push "Call.class"
      end
      system "jar", "cfe", jar_file_name, "Eval", *classes
    end
    libexec.install jar_file_name
    bin.write_jar_script libexec/jar_file_name, "jakld"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test jakld`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
