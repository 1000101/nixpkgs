{ blueprint-compiler
, desktop-file-utils
, fetchFromGitHub
, gobject-introspection
, lib
, libadwaita
, meson
, ninja
, python3
, stdenv
, wrapGAppsHook4
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cartridges";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "kra-mo";
    repo = "cartridges";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-d3KBZNnk5sU60CI9yOYaW8rzbY5tw6BQT8RaiD5P4Co=";
  };

  buildInputs = [
    libadwaita
    (python3.withPackages (p: with p; [
      pillow
      pygobject3
      pyyaml
      requests
    ]))
  ];

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    wrapGAppsHook4
  ];

  meta = with lib; {
    description = "A GTK4 + Libadwaita game launcher";
    longDescription = ''
      A simple game launcher for all of your games.
      It has support for importing games from Steam, Lutris, Heroic
      and more with no login necessary.
      You can sort and hide games or download cover art from SteamGridDB.
    '';
    homepage = "https://apps.gnome.org/app/hu.kramo.Cartridges/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.getchoo ];
    platforms = platforms.linux;
  };
})
