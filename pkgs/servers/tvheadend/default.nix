{ lib
, stdenv
, fetchFromGitHub
, fetchpatch

# buildtime
, makeWrapper
, pkg-config
, python3
, which

# runtime
, avahi
, bzip2
, dbus
, ffmpeg
, gettext
, gnutar
, gzip
, libiconv
, openssl
, uriparser
, zlib
}:

let
  version = "4.2.8";

  dtv-scan-tables = stdenv.mkDerivation {
    pname = "dtv-scan-tables";
    version = "2020-05-18";
    src = fetchFromGitHub {
      owner = "tvheadend";
      repo = "dtv-scan-tables";
      rev = "e3138a506a064f6dfd0639d69f383e8e576609da";
      sha256 = "19ac9ds3rfc2xrqcywsbd1iwcpv7vmql7gp01iikxkzcgm2g2b6w";
    };
    nativeBuildInputs = [ v4l-utils ];
    installFlags = [ "DATADIR=$(out)" ];
  };
in stdenv.mkDerivation {
  pname = "tvheadend";
  inherit version;

  src = fetchFromGitHub {
    owner = "tvheadend";
    repo = "tvheadend";
    rev = "v${version}";
    sha256 = "1xq059r2bplaa0nd0wkhw80jfwd962x0h5hgd7fz2yp6largw34m";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # Pull upstream fix for -fno-common toolchain
    #   https://github.com/tvheadend/tvheadend/pull/1342
    # TODO: can be removed with 4.3 release.
    (fetchpatch {
      name = "fno-common.patch";
      url = "https://github.com/tvheadend/tvheadend/commit/bd92f1389f1aacdd08e913b0383a0ca9dc223153.patch";
      sha256 = "17bsx6mnv4pjiayvx1d57dphva0kvlppvnmmaym06dh4524pnly1";
    })
  ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    python3
    which
  ];

  buildInputs = [
    avahi
    bzip2
    dbus
    ffmpeg
    gettext
    gzip
    libiconv
    openssl
    uriparser
    zlib
  ];

  enableParallelBuilding = true;

  NIX_CFLAGS_COMPILE = [
    "-Wno-error=format-truncation"
    "-Wno-error=stringop-truncation"
  ];

  configureFlags = [
    # disable dvbscan, as having it enabled causes a network download which
    # cannot happen during build.  We now include the dtv-scan-tables ourselves
    "--disable-dvbscan"
    "--disable-bintray_cache"
    "--disable-ffmpeg_static"
    # incompatible with our libhdhomerun version
    "--disable-hdhomerun_client"
    "--disable-hdhomerun_static"
    "--disable-libx264_static"
    "--disable-libx265_static"
    "--disable-libvpx_static"
    "--disable-libtheora_static"
    "--disable-libvorbis_static"
    "--disable-libfdkaac_static"
    "--disable-libmfx_static"
  ];

  preConfigure = ''
    patchShebangs ./configure

    substituteInPlace src/config.c \
      --replace /usr/bin/tar ${gnutar}/bin/tar

    substituteInPlace src/input/mpegts/scanfile.c \
      --replace /usr/share/dvb ${dtv-scan-tables}/dvbv5

    # the version detection script `support/version` reads this file if it
    # exists, so let's just use that
    echo ${version} > rpm/version
  '';

  postInstall = ''
    wrapProgram $out/bin/tvheadend \
      --prefix PATH : ${lib.makeBinPath [ bzip2 ]}
  '';

  meta = with lib; {
    description = "TV streaming server and digital video recorder";
    longDescription = ''
      Tvheadend is a TV streaming server for Linux supporting DVB-S,
      DVB-S2, DVB-C, DVB-T, ATSC, IPTV,SAT>IP and other formats
      through the unix pipe as input sources.
    '';
    homepage = "https://tvheadend.org";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ simonvandel ];
  };
}
