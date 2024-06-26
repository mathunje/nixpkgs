{ lib, stdenv, fetchFromGitHub, cmake, python3, vulkan-headers }:

stdenv.mkDerivation (finalAttrs: {
  pname = "vulkan-utility-libraries";
  version = "1.3.269";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Utility-Libraries";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7BN+U97dqpSyCYhHuFTPqokRnABH7Gt91njZPxItpzg=";
  };

  nativeBuildInputs = [ cmake python3 ];
  buildInputs = [ vulkan-headers ];

  meta = with lib; {
    description = "A set of utility libraries for Vulkan";
    homepage = "https://github.com/KhronosGroup/Vulkan-Utility-Libraries";
    platforms = platforms.all;
    license = licenses.asl20;
    maintainers = [];
  };
})
