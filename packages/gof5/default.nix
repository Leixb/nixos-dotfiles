{ lib
, fetchFromGitHub
, buildGo117Module
}:

buildGo117Module rec {
  pname = "gof5";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "kayrus";
    repo = pname;
    rev = "v${version}";
    sha256 = "10qh7rj8s540ghjdvymly53vny3n0qd0z0ixy24n026jjhgjvnpl";
  };

  # vendorSha256 = "1jpgh61yg7y0yccssjp0zssmy6dazaisxqa7vwgfv2rax78kzaj6";
  vendorSha256 = null;

  doCheck = false;

  # deleteVendor = true;

  # runVend = true;

  meta = with lib; {
    description = "Open Source F5 BIG-IP VPN client for Linux, MacOS, FreeBSD and Windows";
    homepage = "https://github.com/kayrus/gof5";
    license = licenses.asl20;
    maintainers = with maintainers; [ leixb ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
