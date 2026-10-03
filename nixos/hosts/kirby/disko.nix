{
  # Root SSD only; the ZFS pool disks are deliberately not declared here
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLQ256HBJD-00BH1_S672NE2R678121";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
