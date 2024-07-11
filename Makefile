
.PHONY: all noenv deleted-passwd zstd

# Usage: /usr/bin/env repo=ghcr.io/burgerdev/weird-images make -e 
repo=

images=images

all: noenv deleted-passwd zstd

noenv:
	rm -rf -- $(images)/noenv
	umoci init --layout $(images)/noenv
	umoci new --image $(images)/noenv:latest
	skopeo copy --dest-tls-verify=false oci:$(images)/noenv:latest docker://$(repo)/noenv:latest

deleted-passwd:
	podman build -t $(repo)/deleted-passwd:latest src/deleted-passwd
	podman push --tls-verify=false $(repo)/deleted-passwd:latest

assets/busybox:
	mkdir -p assets
	curl -sSfL https://github.com/burgerdev/busybox/releases/download/latest/busybox > assets/busybox

# TODO(burgerdev): there's a bug in crane, media type is set to gzip.
zstd: assets/busybox
	rm -rf -- $(images)/zstd
	umoci init --layout $(images)/zstd
	umoci new --image $(images)/zstd:latest
	skopeo copy --dest-tls-verify=false oci:$(images)/zstd:latest docker://$(repo)/zstd:latest
	tar -cf $(images)/zstd/busybox.tar.zstd --zstd -C assets busybox --transform 's|^|/bin/|'
	crane append -b $(repo)/zstd:latest -f images/zstd/busybox.tar.zstd -t $(repo)/zstd:latest

