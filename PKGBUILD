pkgname=caelestia-shell
pkgver=1.0.0
pkgrel=1
pkgdesc="The Caelestia shell configuration"
arch=('any')
url="https://github.com/Rust-Frog/CShell"
license=('GPL-3.0-only')
source=("git+https://github.com/Rust-Frog/CShell.git")
sha256sums=('SKIP')

build() {
  cd CShell
  # Build any assets if needed
}

package() {
  cd CShell
  install -Dm644 LICENSE "${pkgdir}/etc/xdg/quickshell/caelestia/LICENSE"
  cp -r services "${pkgdir}/etc/xdg/quickshell/caelestia/"
  cp -r modules "${pkgdir}/etc/xdg/quickshell/caelestia/"
  cp -r components "${pkgdir}/etc/xdg/quickshell/caelestia/"
  cp -r config "${pkgdir}/etc/xdg/quickshell/caelestia/"
  cp -r assets "${pkgdir}/etc/xdg/quickshell/caelestia/"
  cp shell.qml "${pkgdir}/etc/xdg/quickshell/caelestia/"
  install -Dm755 shell.nix "${pkgdir}/etc/xdg/quickshell/caelestia/shell.nix"
}
