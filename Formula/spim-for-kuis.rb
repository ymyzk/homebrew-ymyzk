class SpimForKuis < Formula
  desc "SPIM for Hardware and Software Laboratory Project 3 (Software)"
  homepage "https://github.com/ymyzk/spim-for-kuis"
  url "https://github.com/ymyzk/spim-for-kuis/archive/v9.1.17.1.tar.gz"
  sha256 "4641ab3dd14b076ec2a82264fdda6f1446da8c6c0d6a24c7cf897d1c88cc96f3"
  head "https://github.com/ymyzk/spim-for-kuis.git"

  bottle do
    root_url "https://github.com/ymyzk/spim-for-kuis/releases/download/v9.1.17.1"
    rebuild 1
    sha256 sierra:     "0758e03658aa2802541fbe7c6525fe126c97e8c9c0efa7dace8b7bc2aac9d6a6"
    sha256 el_capitan: "e485c4d369663c2884a8b92b0940fc28f0de3d7ddd7b8ccb0343bf857332618a"
  end

  conflicts_with "spim"

  def install
    cd "spim"
    system "make", "DEST_DIR=#{prefix}", "spim", "install"
  end

  test do
    # TODO
    system "false"
  end
end
