
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

gid:
	podman build -t $(repo)/gid:latest src/gid
	podman push --tls-verify=false $(repo)/gid:latest

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

# TODO(burgerdev): this is mostly copy-pasted from above - maybe there's an easier way?
reused-layer: assets/busybox
	rm -rf -- $(images)/reused-layer
	umoci init --layout $(images)/reused-layer
	umoci new --image $(images)/reused-layer:latest
	skopeo copy --dest-tls-verify=false oci:$(images)/reused-layer:latest docker://$(repo)/reused-layer/a:latest
	skopeo copy --dest-tls-verify=false oci:$(images)/reused-layer:latest docker://$(repo)/reused-layer/b:latest
	tar -czf $(images)/reused-layer/busybox.tar.gz -C assets busybox --transform 's|^|/bin/|'
	tar -czf $(images)/reused-layer/empty.tar.gz --files-from=/dev/null
	crane append -b $(repo)/reused-layer/a:latest -f images/reused-layer/busybox.tar.gz -t $(repo)/reused-layer/a:latest
	crane append -b $(repo)/reused-layer/a:latest -f images/reused-layer/empty.tar.gz -t $(repo)/reused-layer/a:latest
	crane append -b $(repo)/reused-layer/b:latest -f images/reused-layer/empty.tar.gz -t $(repo)/reused-layer/b:latest
	crane append -b $(repo)/reused-layer/b:latest -f images/reused-layer/busybox.tar.gz -t $(repo)/reused-layer/b:latest

