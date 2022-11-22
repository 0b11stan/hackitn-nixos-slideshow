<!-- .slide: data-background="#ffffff" -->
# Nixos

_Tristan Pinaudeau @ <span class="highlight">Capgemini</span>_

---

## Présentation


* <span class="highlight">SRE</span> à Cdiscount
* <span class="highlight">PENTESTER</span> à Capgemini

NOTES:

---

## Introduction

NOTES:

exposer le plan

--

### Constats

- Inexhaustivité de la cartographie <!-- .element: class="fragment" -->
- Entropie des configurations <!-- .element: class="fragment" -->
- Gestion chaotique des patchs <!-- .element: class="fragment" -->
- Obscurité à l'audit <!-- .element: class="fragment" -->
- Automatisation complexe <!-- .element: class="fragment" -->

NOTES:

--

### Solutions Eventuelles

- GPO / Scripts <!-- .element: class="fragment" -->
- Infrastructure As Code <!-- .element: class="fragment" -->
- Containerisation <!-- .element: class="fragment" -->

--

### Le système parfait existe t-il ?

- Automatisable <!-- .element: class="fragment" -->
- Versionnable <!-- .element: class="fragment" -->
- Liberté de configuration <!-- .element: class="fragment" -->
- Reproductibilité / Idempotance <!-- .element: class="fragment" -->
- Bare Metal & Env. Virtualisé <!-- .element: class="fragment" -->

---

## Fonctionnement

--

### NPM? = Nix Package Manager

![](dist/custom/phd.png)

--

### <span class="overline">Package</span> <span class="redify">Derivations<span>

![](dist/custom/drake.png)

--

### Nix Store

![](dist/custom/nixstore.png)

```
      DERIVATION = hash(hash(SRC) + hash(DEPENDANCES))
```

--

### Mirroir mon beau mirroir...

![](dist/custom/github.png)

--

### Vous faites le lien ?

```txt [1,2|4,5|7,8]
[tristan@demo:~]$ gcc --version
gcc (GCC) 11.3.0

[tristan@demo:~]$ which gcc
/home/tristan/.nix-profile/bin/gcc

[tristan@demo:~]$ ls -l /home/tristan/.nix-profile/bin/gcc
/home/tristan/.nix-profile/bin/gcc -> /nix/store/ykcrnkiicqg1pwls9kgnmf0hd9qjqp4x-gcc-wrapper-11.3.0/bin/gcc
```

NOTES:
![](dist/custom/nixlinks.png)

---

## Cas Pratique

--

### Situation initiale

```txt
├── docker-compose.yml
├── Makefile
└── template.env
```

--

### "Talk is cheap, ..."

```nix [5|3|4|8|12-17|19-28|25|23,26]
{pkgs, fetchFromGitHub, ...}: 
let
  argProjectName = "--project-name '$name'";
  argComposeFile = "--file '$src/docker-compose.yml'";
  dockercmd = "compose ${argProjectName} ${argComposeFile} up -d";
in
derivation {
  name = "docker-nextcloud";

  system = builtins.currentSystem;

  src = fetchFromGitHub {
    owner = "0b11stan";
    repo = "docker-nextcloud";
    rev = "main";
    sha256 = "sha256-Sh+9Apb71QJHeShgaUbqLXQJMEjrBfkY/tW4Piq7Kss=";
  };

  builder = "${pkgs.bash}/bin/bash";

  args = [ "-c"
    ''
      ${pkgs.coreutils}/bin/mkdir $out \
        && echo "${pkgs.docker}/bin/docker ${dockercmd}" \
        > $out/$name.sh \
        && ${pkgs.coreutils}/bin/chmod +x $out/$name.sh
    ''
  ];
}
```

--

### Configurations

```nix
          ###   /etc/nixos/configuration.nix   ###

{config, lib, pkgs, ...}:
let
  secretMySQLRootPassword = builtins.getEnv "MYSQL_ROOT_PASSWORD";
  secretMySQLPassword = builtins.getEnv "MYSQL_PASSWORD";
in {
  imports = [./hardware-configuration.nix];

  ...

  system.stateVersion = "22.05";
}
```

--

### Configuration - Nextcloud

```nix [1-3|5|7-19|10-12|14|15-18]
nixpkgs.overlays = [(self: super: {
  docker-nextcloud = super.callPackage ./docker-nextcloud.nix {};
})];

environment.systemPackages = [pkgs.docker-nextcloud];

systemd.services.nextcloud = {
  enable = true;
  restartIfChanged = true;
  wantedBy = ["multi-user.target"];
  after = ["docker.service"];
  bindsTo = ["docker.service"];
  documentation = ["https://github.com/0b11stan/docker-nextcloud"];
  script = "${pkgs.docker-nextcloud}/docker-nextcloud.sh";
  environment = {
    MYSQL_ROOT_PASSWORD = secretMySQLRootPassword;
    MYSQL_PASSWORD = secretMySQLPassword;
  };
};

```

--

### Configuration - Docker

```nix
  virtualisation.docker.enable = true;
```

--

### Configuration - SSH

```nix
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };
```

--

### Configuration - Réseau

```nix [2-4|7]
networking = {
  hostName = "nixos-harden";
  networkmanager.enable = true;
  useDHCP = true;
  firewall = {
    enable = true;
    allowedTCPPorts = [8080 22];
  };
};
```

--

### Configuration - User

```nix [2|4|5|6-8]
users.users = {
  tristan = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
    packages = [pkgs.neovim];
    openssh.authorizedKeys.keyFiles = [
      ./ssh-keys/silver-hp.pub
    ];
  };
};
```

--

## Résultats

```txt [4|5|3]
> wc -l src/*.nix src/*.sh

  69 src/configuration.nix
  34 src/docker-nextcloud.nix
  42 src/hardware-configuration.nix
   2 src/init.sh
 147 total
```

--

### Le système parfait existe t-il ?

- Versionnable <!-- .element: class="fragment" -->
- Automatisable <!-- .element: class="fragment" -->
- Reproductibilité / Idempotance <!-- .element: class="fragment" -->
- Liberté de configuration <!-- .element: class="fragment" -->
- Bare Metal & Env. Virtualisé <!-- .element: class="fragment" -->

---

## Synthèse

--

### Bonus - Isolation logicielle

```txt [1,4,5]
$ echo $PATH | tr ':' '\n'

  /run/wrappers/bin
  /home/tristan/.nix-profile/bin
  /etc/profiles/per-user/tristan/bin
  /nix/var/nix/profiles/default/bin
  /run/current-system/sw/bin
```

--

### SUPPRIMER ? Bonus - Nix shell

```txt [|1-3|5|7-10|12-13]
[tristan@demo:rustproject]$ tail -n 2 shell.nix
  LIBPCAP_LIBDIR = "${pkgs.libpcap}/lib";
}

[tristan@demo:rustproject]$ echo $LIBPCAP_LIBDIR

[tristan@demo:rustproject]$ nix-shell
this path will be fetched (0.06 MiB download, 0.30 MiB unpacked):
  /nix/store/x8m...1kw-bash-interactive-5.1-p16-dev
copying path '/nix/store/x8m...1kw-bash-interactive-5.1-p16-dev' from 'https://cache.nixos.org'...

[nix-shell:rustproject]$ echo $LIBPCAP_LIBDIR
/nix/store/pby...ipx-libpcap-1.10.1/lib
```

--

### Bonus - Root en readonly

```txt [1|3-7|9-11]
$ DERIVATION=$(ls -tp /nix/store/ | grep 'openssh.*/$')

$ ls -l /nix/store/$DERIVATION/etc/ssh/
total 504
-r--r--r-- 2 root root 505489  1 janv.  1970 moduli
-r--r--r-- 2 root root 1531  1 janv.  1970 ssh_config
-r--r--r-- 2 root root 3226  1 janv.  1970 sshd_config

$ sudo chmod +w /nix/store/$DERIVATION/etc/ssh/sshd_config
[sudo] Mot de passe de tristan :
chmod: modification des droits [...] Read-only file system
```

--

### Bonus - Rollback

```txt [1,2|9]
[tristan@demo:~]$ ls /boot/loader/entries/ | head -n 2
nixos-generation-131.conf  nixos-generation-132.conf

[tristan@demo:~]$ cat /boot/.../nixos-generation-131.conf
title NixOS
version Generation 131 NixOS 22.05.4120.16f4e04658c, Linux Kernel 5.15.78, Built on 2022-11-16
linux /efi/nixos/rax...xdm-linux-5.15.78-bzImage.efi
initrd /efi/nixos/846...sl3-initrd-linux-5.15.78-initrd.efi
options init=/nix/store/4jx...17f-nixos-system-demo-22.05.4120.16f4e04658c/init loglevel=4
machine-id b7bfdd5f273b49c6a30c4e26e84c8f21
```

-- 

### Les inconvenients

- Moins "Flexible" <!-- .element: class="fragment" -->
- Croissances du Nix store <!-- .element: class="fragment" -->
- Surcharge de Nixpkgs <!-- .element: class="fragment" -->
- Systemd centric <!-- .element: class="fragment" -->
- Adoption = changement d'OS <!-- .element: class="fragment" -->

--

### Conclusion

* https://github.com/0b11stan/hackitn-nixos-slideshow
* https://github.com/0b11stan/hackitn-nixos-demo

<!--
<img class="column" src="dist/custom/nixops.png" >
<img class="column" src="dist/custom/hydra.png" >
<img style="margin: 0" src="dist/custom/home-manager.png" >-->


NOTES:

Parler du rollback, de la sécu

---
<!-- .slide: data-background="#ffffff" -->

![](dist/custom/hackitnix.png)
