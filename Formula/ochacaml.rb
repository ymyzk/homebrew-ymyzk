class Ochacaml < Formula
  desc "Shift/reset-extension of Caml Light"
  homepage "https://github.com/ymyzk/ochacaml"
  url "https://caml.inria.fr/pub/distrib/caml-light-0.75/cl75unix.tar.gz"
  version "20240719"
  sha256 "ac2ad4c7b28716ec3f0e2e24b8b092b99253a573ac8de7da396e08e8bcd10fd2"

  patch do
    url "http://pllab.is.ocha.ac.jp/~asai/OchaCaml/download/OchaCaml.diff"
    sha256 "f25735e8af920fc3cbd354670a57a396f5ebada062099244c55364b9ac568637"
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
