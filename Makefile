all:
	mkdir -p build
	cargo build --release --target=x86_64-apple-darwin
	cargo build --release --target=aarch64-apple-darwin
	lipo -create target/aarch64-apple-darwin/release/libdprint_python_bridge.dylib target/x86_64-apple-darwin/release/libdprint_python_bridge.dylib -output build/dprint_python_bridge.so

.PHONY: test
test:
	python -m test