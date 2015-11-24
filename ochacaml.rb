class Ochacaml < Formula
  desc "Shift/reset-extension of Caml Light"
  homepage "http://www.is.ocha.ac.jp/~asai/OchaCaml/"
  url "http://caml.inria.fr/pub/distrib/caml-light-0.75/cl75unix.tar.gz"
  sha256 "ac2ad4c7b28716ec3f0e2e24b8b092b99253a573ac8de7da396e08e8bcd10fd2"
  version "20140414"

  patch do
    url "https://gist.github.com/ymyzk/aea4dee6951076f57254/raw/4a881a79c7909df1a4b339ffa25d2f114d8d491f/ochacaml_140414.diff"
    sha256 "c4ee52d2199ae7f7e9a4387b740e94653e9e458f6ca7da6f26fd6547fdfc48d9"
  end

  def install
    cd "src"

    system "make", "configure"
    system "make", "world"

    libexec.install Dir["./*"]
    (bin + "ochacaml").write <<-EOS.undent
      #!/bin/bash
      srcdir=#{libexec}
      exec $srcdir/camlrun $srcdir/toplevel/camltop -stdlib $srcdir/lib $*
    EOS
  end

  test do
    results = `echo 'reset (fun () -> "Hello " ^ (shift (fun k -> fun s -> k s))) "world!";;' | #{bin}/ochacaml`
    result = results.split("\n")[2]
    assert_equal result, '# - : string = "Hello world!"'
  end
end
