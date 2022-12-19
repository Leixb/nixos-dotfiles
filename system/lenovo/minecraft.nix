{ pkgs, lib, ... }:

let
  base-config = {
    enable = true;
    autoStart = false;
    package = pkgs.fabricServers.fabric-1_19_2;
    serverProperties = {
      white-list = true;
      online-mode = false;
      hide-online-players = true;
      max-players = 3;
      motd = "Cozy home";
      snooper-enabled = false;
      difficulty = "hard";
    };
    whitelist = {
      leixb = "3346ef95-ab68-409a-a25a-168f0eebce67";
      LeixB = "6d991b35-3140-3e0f-80f9-10a32d26150c";
      SpiderQueen = "1b743142-e762-3a42-84e8-204f7530985b";
      uctagusta = "e12cfc19-b45b-36c8-86b4-bf5b73c23898";
    };

    symlinks = {
      mods = pkgs.linkFarmFromDrvs "mods" (map pkgs.fetchModrinthMod (builtins.attrValues {
        Lithium = { id = "IQxlSIiw"; hash = "71d175672d53346826d371a86146eaa1231e016e2df1b05d6a8cb6b48db4fce0"; };
        FabricAPI = { id = "BXfHW8Ww"; hash = "472ab867b3cef3e92d6c8e086ff0efb0076f33d5db0da1bb13a7258472ca6514"; };
        LazyDFU = { id = "4SHylIO9"; hash = "8c7993348a12d607950266e7aad1040ac99dd8fe35bb43a96cc7ff3404e77c5d"; };
        Starlight = { id = "qH1xCwoC"; hash = "2d07106e9ac267e3b889dad8a16eed34d746a148a1e070dbb2e0afa4ef97a573"; };
        # Krypton = { id = "UJ6FlFnK"; hash = "2383b86960752fef9f97d67f3619f7f022d824f13676bb8888db7fea4ad1f76a"; };
        FerriteCore = { id = "kwjHqfz7"; hash = "275d9371edf9580d3f19620469815f9051dedb8b47306f45aeda19ea43eb3d07"; };
        C2ME = { id = "YaQCrYHB"; hash = "e33a8c379bbe14ffad074a76034eee9500a54dc7d00142138f26c2bac215914d"; };
        Collective = { id = "Z5eRiXRf"; hash = "064f8e12a17fc459946cd0d9f9d59af1e7cef08178095f3dab3f38f8785e3e12"; };
        JustMobHeads = { id = "kPzwZNnS"; hash = "49825c6ebba4a9604386c71bf60548d251251a2f546d2f3c69ccbcf762fdad8a"; };
        # InfiniteTrading = { id = ""; hash = ""; };
        WoolTweaks = { id = "SBui0t35"; hash = "b6cf1e27509a5ccb799e8141dddf27996d96263b18162e9428238557fc8df45a"; };
        Create = { id = "ZOucvJwc"; hash = "557876b9cf2ee2b1df8f08aee00e56f9a6d6218ce0f6cdc1b39d575b26348e20"; };
        GraveStones = { id = "DoolHsey"; hash = "0c214c65cbd1572f3782bdee232894432a3c5d10f79ec22c04c4d9b7702e0a27"; };
        Terralith = { id = "Wd3Co0mZ"; hash = "d832487ce1def935fd91a094c7bc939efdb6f5ae444f16a36429c72cc1ecfb6c"; };
        TradeCycling = { id = "qLOXh29y"; hash = "f3451880df28408d016b6ba0cd8e796c1e205edc42f07ee7483b150def33559c"; };
        VillagersFollowEmeralds = { id = "8Qr46boW"; hash = "b3031235b893e647731da8587c1948fde77ed500c5fb2f2df22caa633af51526"; };
      }));
    };
  };
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers = {
      main = base-config;
      create = base-config;
      carla = lib.mkMerge [
        base-config
        {
          serverProperties.server-port = 19090;
        }
      ];
    };
  };
}
