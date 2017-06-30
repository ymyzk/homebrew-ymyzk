class Ott < Formula
  desc "Tool for writing definitions of programming languages and calculi"
  homepage "https://www.cl.cam.ac.uk/~pes20/ott/"
  url "https://github.com/ott-lang/ott/archive/0.25.tar.gz"
  sha256 "c6abbbeb8cd44dc973d45d30bc5a7e42e212f2feba45c8e0489fab3c3cbf0d78"
  head "https://github.com/ott-lang/ott.git"

  depends_on "ocaml"

  def install
    system "make", "world"
    bin.install "bin/ott"
  end

  test do
    system "false"
  end
end
