{ lib
, installShellFiles
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "jutge";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "leixb";
    repo = "jutge";
    rev = "v${version}";
    hash = "sha256-qNMQCNoBeyCM5noVabizJKm+pCbVrcd3WWNmWnAuomM=";
  };

  vendorHash = "sha256-7nqkyoFumzltljz06kAoUbxKAylxjMCye4dnM5jvwFs=";

  ldflags = [ "-s" "-w" ];

  buildInputs = [ installShellFiles ];

  postInstall = ''
    $out/bin/jutge --completion-script-bash >jutge.bash
    $out/bin/jutge --completion-script-zsh >jutge.zsh

    installShellCompletion --cmd jutge jutge.{bash,zsh} ${./completion.fish}
  '';

  meta = with lib; {
    description = "Create, test, upload and check your problems from jutge.org without ever leaving the terminal";
    homepage = "https://github.com/leixb/jutge";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ leixb ];
    mainProgram = "jutge";
  };
}
