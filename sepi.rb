class Sepi < Formula
  desc "The concurrent, message-passing programming language"
  homepage "http://gloss.di.fc.ul.pt/sepi/"
  url "http://download.gloss.di.fc.ul.pt/sepi/terminal/sepi.jar"
  version "20150518"
  sha256 "6dafdf30dd754a408b5bb61858467cd5c82cc1ebfc1123f02aad8681eceb939e"

  def install
    libexec.install "sepi.jar"
    bin.write_jar_script libexec/"sepi.jar", "sepi"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test sepi`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
