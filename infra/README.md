# Azure Lab Services

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FECUComputingAndSecurity%2FPeCanCTF-2022-Public%2Fmain%2Finfra%2Flab%2Flab.json)

Azure Lab Services provides on-demand virtual machines (VMs) via RDP or SSH, allowing players to participate without installing tools on their local machine. Lab VMs can be customised from a [template image](https://docs.microsoft.com/en-us/azure/lab-services/how-to-create-manage-template) or [compute gallery](https://docs.microsoft.com/en-us/azure/lab-services/approaches-for-custom-image-creation).

Once the lab plan is deployed, follow [this guide](https://docs.microsoft.com/en-us/azure/lab-services/tutorial-setup-lab) to create a lab and invite players. To use a custom image, first complete the guide below.

## Custom Kali Image

As of writing, the Azure Marketplace does not include a Kali image, so these steps can be used to create one.

Prerequisites:
* A Linux environment with approx 60GB free disk space and access to [loop devices](https://en.wikipedia.org/wiki/Loop_device). Note that most hosted CI runners (eg GitHub/GitLab) don't support this, but WSL2 works
* [Create an app registration](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal), or reuse the GitHub Actions one
* [Create and attach a compute gallery](https://docs.microsoft.com/en-us/azure/lab-services/how-to-attach-detach-shared-image-gallery)
* [Create a storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create), or reuse the rCTF one

Clone the repo and install dependencies.

```sh
git clone https://gitlab.com/kalilinux/build-scripts/kali-cloud.git
cd kali-cloud
sudo apt install --no-install-recommends ca-certificates debsums dosfstools fai-server fai-setup-storage fdisk make python3 python3-libcloud python3-marshmallow python3-pytest python3-yaml qemu-utils udev
```

Assign `Storage Account Contributor` to the app registration on the storage account, then create `config.yaml` with details from the app registration, compute gallery, and storage account.

```yaml
azure:
  auth:
    client: client-id
    secret: client-secret
  computegallery:
    tenant: tenant-id
    subscription: subscription-id
    group: rg-{{name}}-lab
    name: gal_{{name}}_lab
  storage:
    tenant: tenant-id
    subscription: subscription-id
    group: rg-{{name}}-rctf
    name: st{{name}}rctf
```

Build the image. This will use approx 40GB of disk space.

```sh
make image_kali-rolling_azure_amd64
```

Upload the image to the compute gallery. This can take several hours and will consume additional disk space to convert the image. The default image version outputted by the build script isn't compatible with compute galleries, so split it into 4-digit blocks eg 2022.0817.0025.

```sh
./bin/debian-cloud-images upload-azure-computegallery --computegallery-image kali-rolling --config-file $(pwd)/config.yaml --debug image_kali-rolling_azure_amd64.build.json --computegallery-version-override {{year}}.{{month}}{{day}}.XXXX
```

[Create a VM](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal) from the gallery image, using this `cloud-init` config in the custom data section.

```yaml
#cloud-config
bootcmd:
 - [ cp, "/usr/lib/systemd/network/80-ethernet.network.example", "/etc/systemd/network/80-ethernet.network" ]
runcmd:
 - systemctl enable xrdp --now
 - xfconf-query -c xfwm4 -p /general/use_compositing -s false
packages:
 - kali-desktop-xfce
 - xorg
 - xrdp
write_files:
- path: /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
  content: |
    [Allow Colord all Users]
    Identity=unix-user:*
    Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
    ResultAny=no
    ResultInactive=no
    ResultActive=yes
```

[Access the Serial Console](https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/serial-console-linux) and run this command to ensure the VM boots correctly.

```sh
mkdir /mnt && mount /dev/sda1 /mnt && sed -i 's/loop0p1/sda1/g' /mnt/boot/grub/grub.cfg
```

Select the reboot button above the console, then [create a gallery image version from the VM](https://docs.microsoft.com/en-us/azure/virtual-machines/capture-image-portal).

In the lab plan, [enable the image](https://docs.microsoft.com/en-us/azure/lab-services/how-to-attach-detach-shared-image-gallery#enable-and-disable-images) and it will be available for new labs. The `kali-rolling` container in the storage account can be deleted.