class MacosInit < Formula
  desc "Simplified cloud-init for macOS"
  homepage "https://github.com/jirutka/macos-init"
  version "0.1.1"
  url "https://github.com/jirutka/macos-init/archive/v#{version}/macos-init-#{version}.tar.gz"
  sha256 ""
  license "MIT"

  # Required only for the cloud-init/nocloud platform.
  depends_on "yq" => :recommended

  def install
    system "make", "install", "PREFIX=#{prefix}", "LAUNCHD_DAEMON_DIR=#{prefix}"
  end

  def post_install
    # Prepare directory for logs.
    mkdir_p var/"log"
  end

  service do
    name macos: "cz.jirutka.macos-init"
    require_root true
  end

  test do
    system "macos-init", "--version"
  end
end

