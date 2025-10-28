# Weird OCI Images

This is a collection of OCI images that are somewhat non-standard, intended for testing OCI tooling.
The `Makefile` both assembles the images and pushes them to `ghcr.io`.

## deleted-passwd

* `ghcr.io/burgerdev/weird-images/deleted-passwd:latest`

This is a busybox image, but with the `/etc/passwd` file removed.
It could be useful for surfacing problems with whiteout files.

## gid

* `ghcr.io/burgerdev/weird-images/gid:latest`

TODO(burgerdev): describe

## noenv

* `ghcr.io/burgerdev/weird-images/noenv:latest`

Does not contain an [`Env`](https://github.com/opencontainers/image-spec/blob/26647a49f642c7d22a1cd3aa0a48e4650a542269/config.md?plain=1#L152) property in the config.

## reused-layer

* `ghcr.io/burgerdev/weird-images/reused-layer/a:latest`
* `ghcr.io/burgerdev/weird-images/reused-layer/b:latest`

These images are basically `busybox`, but they contain an extra empty layer.
The layer order is reversed between `a` and `b`.
This might help surface caching errors.

## zstd

* `ghcr.io/burgerdev/weird-images/zstd:latest`

This image contains a `zstd` layer, which is not very common with images in the wild.
