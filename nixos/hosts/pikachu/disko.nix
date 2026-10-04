{
  # USB SSD; with no SD card inserted the Pi 5 EEPROM (BOOT_ORDER=0xf461) boots from it
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/ata-512GB_SSD_MQ22W66302083";
    content = {
      type = "gpt";
      partitions = {
        # Pi firmware, config.txt and kernel generations; must be the first partition
        FIRMWARE = {
          priority = 1;
          size = "1G";
          type = "0700";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
            mountOptions = [
              "noatime"
              "umask=0077"
            ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [ "noatime" ];
          };
        };
      };
    };
  };
}
