class SpimForKuis < Formula
  desc "SPIM for Hardware and Software Laboratory Project 3 (Software)"
  homepage "https://github.com/ymyzk/spim-for-kuis"
  url "https://github.com/ymyzk/spim-for-kuis/archive/v9.1.17.1.tar.gz"
  sha256 "4641ab3dd14b076ec2a82264fdda6f1446da8c6c0d6a24c7cf897d1c88cc96f3"
  version "9.1.17.1"
  head "https://github.com/ymyzk/spim-for-kuis.git"

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
