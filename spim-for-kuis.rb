class SpimForKuis < Formula
  desc "SPIM for Hardware and Software Laboratory Project 3 (Software)"
  homepage "https://github.com/ymyzk/spim-for-kuis"
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
