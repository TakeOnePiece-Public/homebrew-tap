class VibeTabs < Formula
  desc "Restore named tmux workspaces for AI coding agents on macOS"
  homepage "https://github.com/TakeOnePiece-Public/vibe-tabs"
  url "https://github.com/TakeOnePiece-Public/vibe-tabs/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "730014f054810cc6ac76c9b67b0551657b10e77c0f7300a365010ec319db7a89"
  license "MIT"
  head "https://github.com/TakeOnePiece-Public/vibe-tabs.git", branch: "main"

  depends_on "jq"
  depends_on :macos
  depends_on "ripgrep"
  depends_on "tmux"
  depends_on "yq"

  def install
    libexec.install Dir["libexec/*"]
    bin.install "bin/vibe-tab", "bin/vibe-tabs", "bin/vibe-tabs-add", "bin/vibe-tabs-config"
    pkgshare.install ".vibe-tabs.yml.example"

    app = buildpath/"Vibe Tabs.app"
    system "/usr/bin/osacompile", "-o", app, libexec/"open-vibe-tabs.applescript"
    cp "assets/VibeTabs.icns", app/"Contents/Resources/VibeTabs.icns"
    system "/usr/bin/plutil", "-replace", "CFBundleIconFile", "-string", "VibeTabs", app/"Contents/Info.plist"
    system "/usr/bin/plutil", "-remove", "CFBundleIconName", app/"Contents/Info.plist"
    system "/usr/bin/plutil", "-replace", "CFBundleIdentifier", "-string", "com.takeonepiece.vibetabs",
app/"Contents/Info.plist"
    touch app
    system "/usr/bin/codesign", "--force", "--deep", "--sign", "-", app
    prefix.install app
  end

  def caveats
    <<~EOS
      Create your config from the example:
        cp "#{pkgshare}/.vibe-tabs.yml.example" "$HOME/.vibe-tabs.yml"

      Launch configured workspaces:
        vibe-tabs

      Open the macOS app, which you can then keep in the Dock:
        vibe-tabs --app

      On first launch, allow Vibe Tabs in:
        System Settings > Privacy & Security > Accessibility
    EOS
  end

  test do
    assert_match "Usage: vibe-tab", shell_output("#{bin}/vibe-tab 2>&1", 1)
    assert_predicate prefix/"Vibe Tabs.app", :directory?
    system "/usr/bin/codesign", "--verify", "--deep", "--strict", prefix/"Vibe Tabs.app"
  end
end
