{pkgs, ...}:
{
  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers = {
      main = {
        enable = true;
        autoStart = false;
        package = pkgs.fabricServers.fabric;
        serverProperties = {
          white-list = true;
          online-mode = false;
          hide-online-players = true;
          max-players = 2;
          motd = "Cozy home";
          snooper-enabled = false;
          difficulty = "hard";
        };
        whitelist = {
          leixb = "3346ef95-ab68-409a-a25a-168f0eebce67";
          LeixB = "6d991b35-3140-3e0f-80f9-10a32d26150c";
          SpiderQueen = "1b743142-e762-3a42-84e8-204f7530985b";
        };

        symlinks = {
          mods = pkgs.linkFarmFromDrvs "mods" (map pkgs.fetchModrinthMod (builtins.attrValues {
            Lithium = { id = "Zs3sdHjK"; hash = "8d567ba2cf781962812fdc82e71c0c53b298dfb1549729b971d8a9e1ed7fa527"; };
            FabricAPI = { id = "RAzwgZkP"; hash = "796124805959b76e5bf2db928effc3e0eb94bb5c399ba857e763839f4912109a"; };
            LazyDFU = { id = "4SHylIO9"; hash = "8c7993348a12d607950266e7aad1040ac99dd8fe35bb43a96cc7ff3404e77c5d"; };
            Starlight = { id = "qH1xCwoC"; hash = "44da28466e6560816d470b31c3a31a14524c3ebd3cda7a887dd1dede6e2f6031"; };
            # Krypton = { id = "UJ6FlFnK"; hash = "2383b86960752fef9f97d67f3619f7f022d824f13676bb8888db7fea4ad1f76a"; };
            FerriteCore = { id = "7epbwkFg"; hash = "58ab281bc8efdb1a56dff38d6f143d2e53df335656d589adff8f07d082dbea77"; };
            C2ME = { id = "yU5A8Qx5"; hash = "528c8791f1c4ea538948689e410b2e6c8fe15951772f82558922257b4faf6696"; };
          }));
        };
      };
    };
  };
}
