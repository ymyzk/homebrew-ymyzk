class Jakld < Formula
  desc "Scheme System JAKLD with Picture Language"
  homepage "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/index-j.html"
  url "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/all.jar"
  version "20100725"
  sha256 "18a497b8462afde80cdb848cd5f93d3278e8791280cdff15a9cba4ff11ebb73c"

  option "with-picture-language", "Supports the picture language of SICP & tail-call optimizations"

  depends_on :java

  if build.with? "picture-language"
    resource "picture-language" do
      url "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/jakld.jar"
      sha256 "05cd0cd2606d4c26b51081714a96d19bea48da78dc812bf434f6b53740d2eac2"
    end
  end

  def install
    if build.with? "picture-language"
      jar_file_name = "jakld.jar"
      libexec.install resource("picture-language")
    else
      jar_file_name = "all.jar"
      libexec.install jar_file_name
    end
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
