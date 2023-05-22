{ pkgs, lib, ... }:

let
  cobblemon_modpack = pkgs.fetchzip {
    pname = "Cobblemon";
    version = "1.3.2";
    url = "https://cdn.modrinth.com/data/5FFgwNNP/versions/nvrqJg44/Cobblemon%20%5BFabric%5D%201.3.2.mrpack";
    sha256 = "sha256-F56AwHGoUN3HbDqvj+bFeFc9Z8jGJhGn5K73MzMsn8E=";
    extension = "zip";
    stripRoot = false;
  };
  cobblemon_files = pkgs.modrinth_server_modpack.override {
      modpack = cobblemon_modpack;
      extra_mods = lib.mapAttrsToList (name: value:
        let mod = pkgs.fetchurl { inherit (value) url sha512; }; in
          (pkgs.runCommand name {} ''
            mkdir -p $out/mods
            ln -s ${mod} $out/mods
          '')
        )
        {
          waystones = { url = "https://cdn.modrinth.com/data/LOpKHB2A/versions/kA4IuZjx/waystones-fabric-1.19.2-11.4.0.jar"; sha512 = "01a73bbb8a321b87bb744693f9cafaf7ac64a02f2b8ffdf6ef13c452e493abff580152e1e9ff4483326b30af4ba3f8c81cf4c2a3947112e0503fa53bb8983ba8"; };
          create = { url = "https://cdn.modrinth.com/data/Xbc0uyRg/versions/EkeMb3jA/create-fabric-0.5.0.i-1017%2B1.19.2.jar"; sha512 = "1912185fbb3150ec7fcc860c64144656c92f5b52c706387a1f0e27e6074051ae316f4463e25a692ad591ea7a3c28fc4ce3bca5bfc34411ad6e19df927da033f4"; };
          gravestones = { url = "https://cdn.modrinth.com/data/ssUbhMkL/versions/DoolHsey/gravestones-v1.13.jar"; sha512 = "1000cacb000b5acd2e5a4c513f4b945f786476236dcd226f837fd6801cc52b5b2170307c2681f8dc1dbeb392744199ca645a89e34ac493a1da9d3f946fb8ccd5"; };
          trade-cycling = { url = "https://cdn.modrinth.com/data/qpPoAL6m/versions/qLOXh29y/trade-cycling-fabric-1.19.2-1.0.5.jar"; sha512 = "aeee22b9b2e860902eaededa250ec2f69e0496cc177b864f3033688c4aaa3b423d8353cdd3906977a86a58c202931300acdd5e64a8b60d048335cfcea90f5b92"; };
          cobblemon-extras = { url = "https://cdn.modrinth.com/data/TXoSDUCh/versions/TQyYS6Wi/CobblemonExtras-fabric-1.0.4%2B1.19.2.jar"; sha512 = "6a7c1ef2e4c6c2b5f2a8c2d410127c9decc2a8b0d5a98a1a1b296c54dcf358d0d0a8f5a1bdb1139271a5098867945c4a9b1b49a4f43701db3833a1e22ceab55a"; };
        };
  };

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
      mods = pkgs.linkFarmFromDrvs "mods" (map pkgs.fetchurl (builtins.attrValues {
        lithium-fabric = { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/IQxlSIiw/lithium-fabric-mc1.19.2-0.10.2.jar"; sha512 = "2856942c4119142c64eb03108dd6931cb6cfcd09b8d29e889ccb7d79fee3e495b68c7ad16c5ecbc156de8cd430147dc602694fb383529b8f56bd96e1d55a0da6"; };
        fabric-api = { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/BXfHW8Ww/fabric-api-0.68.0%2B1.19.2.jar"; sha512 = "bfe8b60875794c60b589754f9f6abefdd97581463d31dc4d2ac68a0735aea060e925964ba5bfdbb14dcab1ec9f426fb8aebba86ca28bd0dfd052052b435786e7"; };
        lazydfu = { url = "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.3/lazydfu-0.1.3.jar"; sha512 = "dc3766352c645f6da92b13000dffa80584ee58093c925c2154eb3c125a2b2f9a3af298202e2658b039c6ee41e81ca9a2e9d4b942561f7085239dd4421e0cce0a"; };
        starlight = { url = "https://cdn.modrinth.com/data/H8CaAYZC/versions/1.1.1%2B1.19/starlight-1.1.1%2Bfabric.ae22326.jar"; sha512 = "68f81298c35eaaef9ad5999033b8caf886f3c583ae1edc25793bdd8c2cbf5dce6549aa8d969c55796bd8b0d411ea8df2cd0aaeb9f43adf0691776f97cebe1f9f"; };
        ferritecore = { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/kwjHqfz7/ferritecore-5.0.3-fabric.jar"; sha512 = "efbea36712322c71aee547ebc71b3644947e40bfa01d721fce5d5ba2db4aa6867e6a76f43d46e33ae8a2672f300bfc5b96510e164b1dd09cfae9cba0a195252d"; };
        c2me = { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/YaQCrYHB/c2me-fabric-mc1.19.2-0.2.0%2Balpha.9.0.jar"; sha512 = "53a359554ae3fa2e4b64eab3b34bac4d6624b23694fbaf5c324cc691767f8616827412805ad7a283d835ad9103f24b79f93a433f05d200ca9bc6916ed2fa2486"; };
        collective = { url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/Z5eRiXRf/collective-fabric-1.19.2-5.16.jar"; sha512 = "a2dfaed4c7678f13501c57d959b2a3839752f54f9f5fceb9127eebf1efe44a3560bdf1e895d5b29925c45a6ecc033c9d34c4184a5b3f6ab46087fd15b346a930"; };
        justmobheads = { url = "https://cdn.modrinth.com/data/jzTUm9hE/versions/kPzwZNnS/justmobheads-fabric_1.19.2-6.2.jar"; sha512 = "6cd0feee32d709cf46c72e1215c0619ef35f630cd9319459b658190160cafd2a76ec7d27e3c2b81a75f814a95136753543302f0d00a5b00ad78b232ad3216f6e"; };
        wooltweaks = { url = "https://cdn.modrinth.com/data/lqQsKUma/versions/SBui0t35/wooltweaks-fabric_1.19.2-2.3.jar"; sha512 = "c3c2769cd17d922ecca0d1376d3820b477f13ca08293efe80ea9331d1843c62ca28345424f67b7857b4d5a08f8f3f62a59cf43996c42d3a6f20209ef3c6c2f92"; };
        create = { url = "https://cdn.modrinth.com/data/Xbc0uyRg/versions/ZOucvJwc/create-fabric-0.5.0g-796%2B1.19.2.jar"; sha512 = "eca531efd09e486dc0b4bb8e84d3dfa4332e6bc8becbfbd2bce86908f67aa73d6b634b9c9cd115d0a3176a2964a92855f26216fff064a06631ba7ed3ff8c5959"; };
        gravestones = { url = "https://cdn.modrinth.com/data/ssUbhMkL/versions/DoolHsey/gravestones-v1.13.jar"; sha512 = "1000cacb000b5acd2e5a4c513f4b945f786476236dcd226f837fd6801cc52b5b2170307c2681f8dc1dbeb392744199ca645a89e34ac493a1da9d3f946fb8ccd5"; };
        terralith_v2 = { url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/Wd3Co0mZ/Terralith_v2.3.5.jar"; sha512 = "ebd964c409374f80c333ce10a22954353e17860c55c5db1605ef601d1e056d244667a7723157d4e5ac857233057a29c8b881f962d5f75956ff34c1da6ef8f2e0"; };
        trade-cycling = { url = "https://cdn.modrinth.com/data/qpPoAL6m/versions/qLOXh29y/trade-cycling-fabric-1.19.2-1.0.5.jar"; sha512 = "aeee22b9b2e860902eaededa250ec2f69e0496cc177b864f3033688c4aaa3b423d8353cdd3906977a86a58c202931300acdd5e64a8b60d048335cfcea90f5b92"; };
        villagers-follow-emeralds = { url = "https://cdn.modrinth.com/data/lH4RabB7/versions/v1.3.0/villagers-follow-emeralds-1.3.0%201.19.jar"; sha512 = "089fde4703f200c9ed0ab64122f66fd3e7a35040a92b1bc54e4be46ac123ef9ecc183a14c94a2f96977611fa6f218c3ee696b292705d8b4b00c69d80fe2ae4c2"; };
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
      cobblemon = {
        enable = true;
        autoStart = false;
        package = pkgs.fabricServers.fabric-1_19_2;
        serverProperties = {
          white-list = true;
          online-mode = false;
          hide-online-players = true;
          max-players = 3;
          motd = "Cobblemon + create";
          snooper-enabled = false;
          difficulty = "hard";
        };
        whitelist = {
          leixb = "3346ef95-ab68-409a-a25a-168f0eebce67";
          LeixB = "6d991b35-3140-3e0f-80f9-10a32d26150c";
          SpiderQueen = "1b743142-e762-3a42-84e8-204f7530985b";
          uctagusta = "e12cfc19-b45b-36c8-86b4-bf5b73c23898";
        };
        symlinks = lib.genAttrs ["mods" "fancymenu_data" "global_packs" "icon.png" "instance.png" "resourcepacks" "shaderpacks"] (name: "${cobblemon_files}/${name}");
      };
    };
  };
}
