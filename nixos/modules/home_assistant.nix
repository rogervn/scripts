{
  nixvirt,
  pkgs,
  ...
}: let
  haos_disk = "/vms/haos/haos.qcow2";
  net_if = "enp2s0";
in {
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirt = {
    enable = true;
    verbose = true;
    connections."qemu:///system" = {
      # No networks as we use macvtap
      networks = [];
      pools = [];

      domains = [
        {
          active = true;
          definition =
            nixvirt.lib.domain.writeXML
            (let
              base = nixvirt.lib.domain.templates.linux {
                name = "haos";
                uuid = "c58ee3e9-7989-4c87-a30c-8df7f5c8871f";
                vcpu = {count = 2;};
                memory = {
                  count = 4;
                  unit = "GiB";
                };
                virtio_video = false;
              };
            in
              base
              // {
                os = {
                  type = "hvm";
                  arch = "x86_64";
                  machine = "q35";
                  loader = {
                    readonly = true;
                    type = "pflash";
                    path = "${pkgs.OVMFFull.fd}/FV/OVMF_CODE.fd";
                  };
                  nvram = {
                    template = "${pkgs.OVMFFull.fd}/FV/OVMF_VARS.fd";
                    path = "/var/lib/libvirt/qemu/nvram/haos_VARS.fd";
                  };
                };
                devices =
                  base.devices
                  // {
                    controller = [
                      {
                        type = "scsi";
                        index = 0;
                        model = "virtio-scsi";
                      }
                    ];
                    disk = [
                      {
                        type = "file";
                        source = {file = "${haos_disk}";};
                        target = {
                          dev = "sda";
                          bus = "scsi";
                        };
                        driver = {
                          name = "qemu";
                          type = "qcow2";
                        };
                        boot = {order = 1;};
                      }
                    ];
                    interface = [
                      {
                        type = "direct";
                        source = {
                          dev = "${net_if}";
                          mode = "bridge";
                        };
                        mac = {address = "52:54:00:e0:f9:a3";};
                        model = {type = "virtio";};
                      }
                    ];
                    # Adapt to USB device
                    hostdev = [
                      {
                        mode = "subsystem";
                        type = "usb";
                        managed = true;
                        source = {
                          vendor = {id = 6790;}; # 0x1a86
                          product = {id = 21972;}; # 0x55d4
                        };
                      }
                    ];
                    console = [
                      {
                        type = "pty";
                        target = {
                          type = "serial";
                          port = 0;
                        };
                      }
                    ];
                  };
              });
        }
      ];
    };
  };
}
