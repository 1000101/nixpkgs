{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "sudo_pair";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "square";
    repo = pname;
    rev = "${pname}-v${version}";
    sha256 = "1ywzsyjbnawvgrxayfj8dq46dzsr68nwgdxpksbir5dsm3ig5ckg";
  };

  cargoPatches = [ ./cargo-lock.patch ];

  cargoSha256 = "1nxdkfx32n75kqshd8lzpczhivydfn3dvpx3z5hz1i2kcyzxx3q2";

  meta = with stdenv.lib; {
    description = "A plugin for sudo that requires another human to approve and monitor privileged sudo session";
    homepage = "https://github.com/square/sudo_pair";
    license = licenses.asl20;
    maintainers = with maintainers; [ maintainers."1000101" ];
    platforms = platforms.all;
  };

}
