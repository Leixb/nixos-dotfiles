{location, ...}:

{
  fileSystems."/mnt/synology/video" = {
    device = "${location}:/volume1/video";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };

  fileSystems."/mnt/synology/books" = {
    device = "192.168.1.3:/volume1/books";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };

  fileSystems."/mnt/synology/music" = {
    device = "192.168.1.3:/volume1/music";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };

  fileSystems."/mnt/synology/photo" = {
    device = "192.168.1.3:/volume1/photo";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };

  fileSystems."/mnt/synology/downloads" = {
    device = "192.168.1.3:/volume1/Downloads";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };

  fileSystems."/mnt/synology/shared" = {
    device = "192.168.1.3:/volume1/Shared folder";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };

  fileSystems."/mnt/synology/docker" = {
    device = "192.168.1.3:/volume1/docker";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  };
}
