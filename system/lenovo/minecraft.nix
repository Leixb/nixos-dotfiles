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
        let mod = pkgs.fetchurl value; in
          (pkgs.runCommand name {} ''
            mkdir -p $out/mods
            ln -s ${mod} $out/mods
          '')
        )
        {
          waystones = { url = "https://cdn.modrinth.com/data/LOpKHB2A/versions/kA4IuZjx/waystones-fabric-1.19.2-11.4.0.jar"; sha512 = "01a73bbb8a321b87bb744693f9cafaf7ac64a02f2b8ffdf6ef13c452e493abff580152e1e9ff4483326b30af4ba3f8c81cf4c2a3947112e0503fa53bb8983ba8"; };
          create = { url = "https://cdn.modrinth.com/data/Xbc0uyRg/versions/q6x0xvc1/create-fabric-0.5.1-b-build.1079%2Bmc1.19.2.jar"; sha512 = "15a1fbebf4f15e56ec7ec6ee4943f18bbaea540514c74830cc1ac0e8023bcf55c5e1df9a5fed024de9eff57984301be86cb5fb582d84b4194b731cc3f082b60a"; };
          gravestones = { url = "https://cdn.modrinth.com/data/ssUbhMkL/versions/DoolHsey/gravestones-v1.13.jar"; sha512 = "1000cacb000b5acd2e5a4c513f4b945f786476236dcd226f837fd6801cc52b5b2170307c2681f8dc1dbeb392744199ca645a89e34ac493a1da9d3f946fb8ccd5"; };
          trade-cycling = { url = "https://cdn.modrinth.com/data/qpPoAL6m/versions/qLOXh29y/trade-cycling-fabric-1.19.2-1.0.5.jar"; sha512 = "aeee22b9b2e860902eaededa250ec2f69e0496cc177b864f3033688c4aaa3b423d8353cdd3906977a86a58c202931300acdd5e64a8b60d048335cfcea90f5b92"; };
          cobblemon-extras = { url = "https://cdn.modrinth.com/data/TXoSDUCh/versions/TQyYS6Wi/CobblemonExtras-fabric-1.0.4%2B1.19.2.jar"; sha512 = "6a7c1ef2e4c6c2b5f2a8c2d410127c9decc2a8b0d5a98a1a1b296c54dcf358d0d0a8f5a1bdb1139271a5098867945c4a9b1b49a4f43701db3833a1e22ceab55a"; };
          oh-the-biomes-youll-go = { url = "https://cdn.modrinth.com/data/uE1WpIAk/versions/9MInWvhi/Oh_The_Biomes_You%27ll_Go-fabric-1.19.2-2.0.1.1.jar"; sha512 = "003e21ff9c6f15685cc7a8e1869ce88627538b48e7620e77ee13b32c4321a6185de960e5eb5c41dc1a615178a89db1f94bb1d99f562f66b87d76b0775f141fb9"; };
          terrablender = { url = "https://cdn.modrinth.com/data/kkmrDlKT/versions/ywiJhcuG/TerraBlender-fabric-1.19.2-2.0.1.130.jar"; sha512 = "5051698ff405f593b7beb2fae2ed9eb5b08f89ec0d3f948d240c4b9a9babf00b91686b73aad3b06cfedb615ca1d30aab2ad144f26222b0fcb765cf2e8c9a48a0"; };
          gekolib = { url = "https://cdn.modrinth.com/data/8BmcQJ2H/versions/ATPZfRS1/geckolib-fabric-1.19-3.1.40.jar"; sha512 = "43a0e6da036b14ad288de5727b69209c09dec40144a8b0b4a2f2970c10679f6095f1db0f5e15fcf9e80e41b5bf276a574a5971118b3c3b4ac5d2b4517d330a2b"; };
          corgilib = { url = "https://cdn.modrinth.com/data/ziOp6EO8/versions/HaZfKDxj/CorgiLib-fabric-1.19.2-1.0.0.34.jar"; sha512 = "58e465fd2fb8587fc2a147faff2e568d40b248b9e34e887f2a9185c80c06b880f35201a83343447d0ff7c59a4b8d6c3752dc3478c4e1d19236c9b5c4339b4a1d"; };
          polymorph = { url = "https://cdn.modrinth.com/data/tagwiZkJ/versions/cnPRpn78/polymorph-fabric-0.46.1%2B1.19.2.jar"; sha512 = "02b24d3f56a7f47248c1f6da672a74c0e2e1221c238fe00bcb8860f9925138095c524a5823ec36fbae7c88beede13be14e4d27d2e18fd15142a7b31df64f7827"; };
          dungeonsarise = { url = "https://cdn.modrinth.com/data/8DfbfASn/versions/tKxOjh70/DungeonsArise-1.19.2-2.1.54-fabric.jar"; sha512 = "32bc53d2a584a9abb9e1e09444e9ee99925933f34effee72e6c052588f55b0051639d2811f4d771380d0480b6e1bdf634d6aa96b54a486733342440cad9dae12"; };
          farmersdelight = { url = "https://cdn.modrinth.com/data/4EakbH8e/versions/baQ9tohQ/farmers-delight-fabric-1.19.X-1.3.9.jar"; sha512 = "d86eb4c2da455c1afc8221de889ae9fd2a8c1e3fccb7da97dbe32331a116f0e0ae1fd7010761afc132449d5776665c3b65bbf95631ed120ef67dac4fcf4744d3"; };
          packitup = { url = "https://cdn.modrinth.com/data/czWH0F4i/versions/BXhMkYzT/pack_it_up-0.3.0%2B1.19.jar"; sha512 = "718e5f7e8365c5fd7c4deeabf9b52854074d008623c61326eec5138044ffd2c39a2dd904da310af326b1ffd01357631e955581b06c498db3601900498e699dec"; };
          comforts = { url = "https://cdn.modrinth.com/data/SaCpeal4/versions/CeY7jdWr/comforts-fabric-6.0.4%2B1.19.2.jar"; sha512 = "a383358aed152ffdf673115b9a1e83d572d6e3d92ed4dd5559ec9526d0ca3abb4be1badab87d3a275a5008753e7d1d3679ffc279236893e4ee9838042042c587"; };
          paladinfurniture = { url = "https://cdn.modrinth.com/data/SISz7Qd3/versions/v4hDp1AI/paladin-furniture-mod-1.1.1-fabric-mc1.19.jar"; sha512 = "1d6871a4b9eb092c5904455bcb3b7bbd46434df6362c839696ab98b38a1147ef8b969092c7b7d787ffacfff4956901c9563d734d5759cfbecd91dcc11dc98287"; };
          zenith = { url = "https://mediafilez.forgecdn.net/files/4606/378/zenith-0.6.6%2B1.19.2.jar"; sha256 = "e18f535dbe60b84d861fef205456b59b4e7a23b9bce5cac3309254d97151f4a3"; };
          patchouli = { url = "https://cdn.modrinth.com/data/nU0bVIaL/versions/NorgAU8F/Patchouli-1.19.2-77-FABRIC.jar"; sha512 = "499e5d558964c482aef0cd29affa12749c494b13859bf6471fc8d691b3e97f5ce3b5defc83f4ea9161f0532ec88da6049748136d60b44428a5cc8312d8cee066"; };
          more-slabs = { url = "https://cdn.modrinth.com/data/bdBzXqbS/versions/KFoS6drW/mssw-fabric-2.4.0%2B1.19.2.jar"; sha512 = "0a935d8287a32f30f5da3b9c81c581b19fe2b878178aab95eafc1ce7713bab929b330fa73f3a1b5d9905170757e1c2c9ec921834252399a737d69a7544652199"; };
          extended-drawers = { url = "https://cdn.modrinth.com/data/AhtxbnpG/versions/rVif6c1F/ExtendedDrawers-1.4.3%2Bmc.1.19.2.jar"; sha512 = "60a7c24740217e8d35ac95d39205ba23ecc70c1a8d61fc5c2b3308c8ba9a1bbe7120f9496cb65a58d5ac1662dd6d5966fb6b16948711c3ab28f6380488f70d15"; };
          ae2 = { url = "https://cdn.modrinth.com/data/XxWD5pD3/versions/Xc1WEGPd/appliedenergistics2-fabric-12.9.5.jar"; sha512 = "63c8936d845018d125e35954219b6a35969f4d00db798788e7c747cb6568881f3de7a7f5461fea1d709203b1a8e106466b097b206c898a524794e7f804b2212b"; };
          wthit = { url = "https://cdn.modrinth.com/data/6AQIaxuO/versions/Lv3CXyzs/wthit-fabric-5.16.2.jar"; sha512 = "80282b7dc33ba2e496b20dd6f81602d06b4759b9b9ccfa14321d84975565da2786bf9a0cd0710cf4a356c6c3181c640c236fbf3e3cde4d9b19cb4eb8f158ddd0"; };
          badpackets = { url = "https://cdn.modrinth.com/data/ftdbN0KK/versions/AifWRdyF/badpackets-fabric-0.2.1.jar"; sha512 = "f41e5aa02662c6d4f70084b1c604b806414776a18b90ed31432daa98123504c5bb403fece55b1350d85a91c40673c3cc0ec6497a7f65f5c1c55f7881304d0329"; };
          emi = { url = "https://cdn.modrinth.com/data/fRiHVvU7/versions/ZYREdR8e/emi-1.0.4%2B1.19.2%2Bfabric.jar"; sha512 = "eeeb79db645415646f4aa6ac476ac694a62aa7201bc9c8a7fc00bac69ccb1ef52f7b46da259406129eb9aa1a7bbd6c5c340125e353469b93e4c64a1b10febf89"; };
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
        jvmOpts = "-Xmx8G -Xms4G";
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
