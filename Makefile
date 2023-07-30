OSXCROSS_PATH:=/opt/osxcross
MATURIN_ARGS:=--release --strip --target-dir=../target -i 3.8

all: build

build: build-macos build-linux build-windows

build-macos:
	mkdir -p st3_osx
	mkdir -p st3_osx

	rustup target add x86_64-apple-darwin
	rustup target add aarch64-apple-darwin

	cd python-rust-dprint && \
		PATH="$(OSXCROSS_PATH)/bin:$(PATH)" \
		LD_LIBRARY_PATH="$(OSXCROSS_PATH)/lib" \
	  CC="$(OSXCROSS_PATH)/bin/o64-clang" \
	  CCX="$(OSXCROSS_PATH)/bin/o64-clang++" LIBZ_SYS_STATIC=1 \
	  maturin build --target x86_64-apple-darwin $(MATURIN_ARGS)

	cd python-rust-dprint && \
		PATH="$(OSXCROSS_PATH)/bin:$(PATH)" \
		LD_LIBRARY_PATH="$(OSXCROSS_PATH)/lib" \
	  CC="$(OSXCROSS_PATH)/bin/aarch64-apple-darwin20.4-clang" \
	  CCX="$(OSXCROSS_PATH)/bin/aarch64-apple-darwin20.4-clang++" LIBZ_SYS_STATIC=1 \
	  maturin build --target aarch64-apple-darwin $(MATURIN_ARGS)
	
	$(OSXCROSS_PATH)/bin/lipo -create \
 		target/aarch64-apple-darwin/release/libdprint_python_bridge.dylib \
 		target/x86_64-apple-darwin/release/libdprint_python_bridge.dylib \
 		-output st3_osx/dprint_python_bridge.so

build-linux:
	mkdir -p st3_linux_x64
	mkdir -p st3_linux_arm64

	rustup target add x86_64-unknown-linux-gnu
	rustup target add aarch64-unknown-linux-gnu

	cd python-rust-dprint && \
		maturin build --target x86_64-unknown-linux-gnu $(MATURIN_ARGS)
	cd python-rust-dprint && \
		maturin build --target aarch64-unknown-linux-gnu $(MATURIN_ARGS)

	cp target/x86_64-unknown-linux-gnu/release/libdprint_python_bridge.so \
		st3_linux_x64/dprint_python_bridge.so
	cp target/aarch64-unknown-linux-gnu/release/libdprint_python_bridge.so \
		st3_linux_arm64/dprint_python_bridge.so

build-windows:
	mkdir -p st3_windows_x64
	# mkdir -p st3_windows_arm64

	rustup target add x86_64-pc-windows-msvc
	# rustup target add aarch64-pc-windows-msvc

	cd python-rust-dprint && \
		maturin build --target x86_64-pc-windows-msvc $(MATURIN_ARGS)
# 	cd python-rust-dprint && \
# 		maturin build --target aarch64-pc-windows-msvc $(MATURIN_ARGS)

	cp target/x86_64-pc-windows-msvc/release/dprint_python_bridge.dll \
		st3_windows_x64/dprint_python_bridge.pyd
# 	cp target/aarch64-pc-windows-msvc/release/dprint_python_bridge.dll \
# 		st3_windows_arm64/dprint_python_bridge.pyd

test:
	maturin develop
	python -m test

.PHONY: test build build-macos build-linux build-windows all
