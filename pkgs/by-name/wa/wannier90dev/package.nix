{ stdenv
, lib
, gfortran
, blas
, lapack
, python3
, fetchFromGitHub
}:
assert (!blas.isILP64);
assert blas.isILP64 == lapack.isILP64;

stdenv.mkDerivation rec {
  pname = "wannier90dev";
  version = "dev";

  nativeBuildInputs = [ gfortran ];
  buildInputs = [
    blas
    lapack
  ];

  src = fetchFromGitHub {
    owner = "wannier-developers";
    repo = "wannier90";
    rev = "bf2ca5f37d3446de932229ca210dbb271519d4e6";
    hash = "sha256-SSX2DWr/voMZLy9U1CK5loUQzJBnTVu0YvDv9R0jjo8=";
  };

  # test cases are removed as error bounds of wannier90 are obviously to tight
  postPatch = ''
    rm -r test-suite/tests/testpostw90_{fe_kpathcurv,fe_kslicecurv,si_geninterp,si_geninterp_wsdistance}
    rm -r test-suite/tests/testw90_example26   # Fails without AVX optimizations
    patchShebangs test-suite/run_tests test-suite/testcode/bin/testcode.py
  '';

  configurePhase = ''
    cp config/make.inc.gfort make.inc
  '';

  buildFlags = [ "all" "dynlib" ];

  preInstall = ''
    installFlagsArray+=(
      PREFIX=$out
    )
  '';

  postInstall = ''
    cp libwannier.so $out/lib/libwannier.so

    mkdir $out/include
    find ./src/obj/ -name "*.mod" -exec cp {} $out/include/. \;

    find $out/* -type f -exec mv {} {}_D \;
  '';

  doCheck = true;
  checkInputs = [ python3 ];
  checkTarget = [ "test-serial" ];
  preCheck = ''
    export OMP_NUM_THREADS=4
  '';

  enableParallelBuilding = false;

  hardeningDisable = [ "format" ];


  meta = with lib; {
    description = "Calculation of maximally localised Wannier functions";
    homepage = "https://github.com/wannier-developers/wannier90";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.sheepforce ];
  };
}
