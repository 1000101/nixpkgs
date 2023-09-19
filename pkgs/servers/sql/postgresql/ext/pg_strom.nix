{ lib
, stdenv
, fetchFromGitHub
, postgresql
, cudaPackages
}:

let
  rev = "374b1501e3b6b258fc4db27bd043179660a4b340";
in
stdenv.mkDerivation {
  pname = "pg-strom";
  version = "3.5";

  src = fetchFromGitHub {
    owner = "heterodb";
    repo = "pg-strom";
    inherit rev;
    sha256 = "sha256-am7J2Q364DSwF+krHTB9HFM7geCo9iU2C7JY08xmoys=";
  };

  buildInputs = [
    postgresql
    cudaPackages.cuda_nvcc
    cudaPackages.cudatoolkit
  ];

  NIX_LDFLAGS = [
    "-L${cudaPackages.cudatoolkit}/lib/stubs"
  ];

  makeFlags = [
    "PG_CONFIG=${postgresql}/bin/pg_config"
    "NVCC=${cudaPackages.cuda_nvcc}/bin/nvcc"
    "GITHASH=${rev}"
  ];

  installPhase = ''
    mkdir -p $out/{lib,share/postgresql/extension}

    cp *.so      $out/lib
    cp sql/*.sql $out/share/postgresql/extension
    cp *.control $out/share/postgresql/extension
  '';

  meta = with lib; {
    description = "PostgreSQL extension designed to accelerate mostly batch and analytics workloads with utilization of GPU and NVME-SSD";
    homepage = "https://github.com/heterodb/pg-strom";
    maintainers = with maintainers; [ _1000101 ];
    platforms = postgresql.meta.platforms;
    license = licenses.gpl2;
  };
}
