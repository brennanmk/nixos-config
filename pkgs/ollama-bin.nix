{ lib, stdenv, fetchurl, autoPatchelfHook, zstd, makeWrapper
, cudaPackages, zlib, vulkan-loader
}:

let
  # Update version + hash when upgrading:
  #   nix-prefetch-url --unpack https://github.com/ollama/ollama/releases/download/v<version>/ollama-linux-amd64.tar.zst
  version = "0.32.6";
in
stdenv.mkDerivation {
  pname = "ollama-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-linux-amd64.tar.zst";
    hash = "sha256-3sL6UNJOaGjKPEyXfWnQWTmTchBflRqazDIKWnmq3Pw=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook makeWrapper zstd ];

  buildInputs = [
    stdenv.cc.cc.lib
    cudaPackages.cuda_cudart
    cudaPackages.libcublas
    zlib
    vulkan-loader
  ];

  # libcuda.so.1 is the NVIDIA driver stub — only present at runtime in /run/opengl-driver/lib
  autoPatchelfIgnoreMissingDeps = [ "libcuda.so.1" "libcudart.so.13" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/ollama \
      --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
  '';

  meta = {
    description = "Run large language models locally (pre-built binary, no build step)";
    homepage = "https://ollama.com";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ollama";
  };
}
