class Ochacaml < Formula
  desc "Shift/reset-extension of Caml Light"
  homepage "http://www.is.ocha.ac.jp/~asai/OchaCaml/"
  url "http://caml.inria.fr/pub/distrib/caml-light-0.75/cl75unix.tar.gz"
  version "20140414"
  sha256 "ac2ad4c7b28716ec3f0e2e24b8b092b99253a573ac8de7da396e08e8bcd10fd2"

  patch do
    url "https://github.com/ymyzk/ochacaml/raw/140414/ochacaml.diff"
    sha256 "c4ee52d2199ae7f7e9a4387b740e94653e9e458f6ca7da6f26fd6547fdfc48d9"
  end

  bottle do
    root_url "https://github.com/ymyzk/ochacaml/releases/download/140414"
    rebuild 1
    sha256 cellar: :any, sierra:     "9f6b344abbdab1db7619b1f73a18fe81ca23e10988ad9cee59ff694a0d567fd4"
    sha256 cellar: :any, el_capitan: "c6dbc694c02a6d129a11e2fc893ed83eb34fb8e09c2615d07b72e65a0cc59d98"
  end

  def install
    cd "src"

    system "make", "configure"
    system "make", "world"

    libexec.install Dir["./*"]
    (bin + "ochacaml").write <<~EOS
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
