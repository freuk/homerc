{ stdenv, fetchFromGitHub, obs-studio, cmake, qt5 }:

stdenv.mkDerivation rec {
  name = "obs-v4l2sink";

  nativeBuildInputs = [ cmake ];
  buildInputs = [ obs-studio qt5.qtbase ];

  # src = fetchFromGitHub {
  #   owner = "AndyHee";
  #   repo = "obs-v4l2sink";
  #   rev = "34488891aeaa38b9c536b1ac0e1ed87a7704d90b";
  #   sha256 = "03hgcgwfa2n89dy2kxsw5crd2skzs2cjmh91nib4h5vwq6zm3lks";
  # };
  src = ~/sandbox/obs-v4l2sink ;

  # patches = [ ./fix-path.patch  ];

  cmakeFlags = [
    "-DLIBOBS_INCLUDE_DIR=${obs-studio}/include/obs"
    "-DLIBOBS_LIB=${obs-studio}/lib"
    "-DCMAKE_CXX_FLAGS=-I${obs-studio.src}/UI/obs-frontend-api"
  ];

  installPhase = ''
    mkdir -p $out/share/obs/obs-plugins/v4l2sink/bin/64bit/
    cp v4l2sink.so $out/share/obs/obs-plugins/v4l2sink/bin/64bit/
  '';

}

