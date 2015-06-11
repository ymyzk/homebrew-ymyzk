class Jakld < Formula
  desc "Scheme System JAKLD with Picture Language"
  homepage "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/index-j.html"
  url "http://www.yuasa.kuis.kyoto-u.ac.jp/~yuasa/jakld/jakld.jar"
  sha256 "05cd0cd2606d4c26b51081714a96d19bea48da78dc812bf434f6b53740d2eac2"
  version "20100725"

  depends_on :java

  def install
    libexec.install "jakld.jar"
    bin.write_jar_script libexec/"jakld.jar", "jakld"
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
