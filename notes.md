Dans cette prochaine demi-heure je vais vous parler d'une distribution linux
pas comme les autres qui s'appelle, au cas ou ça n'était pas clair: NIXOS.

Petite question pour ma curiosité :

* qui dans la salle à déjà entendu parlé de nixos ?
* qui l'a déjà essayé ?
* qui l'as mis en production ?

CLICK 

## Présentation

Je m'appelle tristan pinaudeau et mon premier job c'était "ingénieur SRE" à
Cdiscount. C'est probablement au cours de cette expérience que j'ai attrappé le
virus de l'automatisation et du "tout as code".

Aujourd'hui, je fait mon métier de passion puisque je suis pentester à capgemini

Mon attrait pour nixos vient probablement du croisement de ces deux expériences

mais vous allez très vite comprendre pourquoi

CLICK

## Introduction

Essayer de vous expliquer comment fonctionne nixos en 30 minutes c'est un peu
ambitieux donc mon objectif principale c'est qu'après cette conf, vous alliez
tester la distribution par vous même

voila ce qu'on va faire:

je vais vous exposer dans un premier temps ce qui me semble être les plus gros
problèmes techniques qu'on rencontre aujourd'hui dans la sécurisation de nos
systèmes

ensuite je vous expliquerais très rapidement les rudiment du système et ce qui
fait que cette distribution est différente de tous ce que vous connaissez

avec ces quelques informations en tête, je vais vous montrer un cas pratique
et puisqu'un extrait de code vaut mieux que 1000 mots, on regardera vraiment à
quoi ça ressemble de monter un système nixos

enfin, je ferais une petite synthèse de tous ce qu'on à vus

CLICK

### Constats

Alors, quelles sont ces problèmes que je prétend résoudre avec mon système
inconnu ?

CLICK

D'abord, et je l'ai mis en premier parcequ'il me semble que c'est le problème
principale: c'est un problème de visibilité. On ne sais pas aujourd'hui dans nos
infra quelles machines sont déployés avec quelle configuration et qu'est-ce qui
tourne dessus ?

CLICK

ensuite ce que j'appelle l'entropie des configurations: dans un SI un peu mature
vous trouverez autant de configuration différentes que de machines. chaque admin
à ses habitudes certain vont installé un même packet avec pip, d'autres vont
extraire un tar dans /opt, ont à besoin de normalisation

CLICK

comme les configurations sont toutes différentes, appliquer un patch de sécurité
est un enfer. Comment je fais si le patch introduit des incompatibilité ? Dans
quelle version sont mes logiciels ?

CLICK

C'est un point que je vie beaucoup au jour le jour: nos systèmes sont
incroyablement difficiles à auditer. on s'en ai accomoder au file du temps mais
les seuls audites qui sont possibles sont des audites "abstrait" qui se résument
à commenter des schéma d'architecture pas à jour ou alors des audites "dynamiques"
au petit bonheur la chance : on audite un master, on fait un test d'intrusion

CLICK

Enfin l'automatisation est difficile. Vous voulez retrouver votre état nominal
après un incident ? Il va falloir rejouer une documentation de déploiment
vieille et pas clair qui n'a aucune garantie de fonctionner.

CLICK

### Solutions Eventuelles

biensure, d'autres projet ont essayé d'apporter des solutions à ces problèmes.

CLICK

Naturellement la première solution à arriver c'est l'utilisation de GPO ou de
scripts ssh par exemple. le problème que c'est que cette solution est
difficilement scalable, pas assez robuste et pas normalisée et peut donc
conduire à beaucoup d'erreur

CLICK

En suite il y à les technologies d'infrastructure as code à proprement parler.
C'est une solutions génial qui est beaucoup plus scalable mais beaucoup de ces
solutions s'appuient sur un "état virtuel" du système qu'elles déploient qui les
met faces à un problème majeur: comment faire lorsque le système à été changé "à la main"?
Gérer les problèmes d'idempotence avec ces technos est une lutte de tous les
instants, ceux qui ont déjà travaillé avec des systèmes de ce type en conviendrons

CLICK

Enfin, biensure, les technologies de containerisations sont une forme de réponse
à ces problèmes mais la réponse est limité. Toutes les applications ne sont pas
containerisables et, surtout, il faut toujours des infrastructures physiques
pour porter ces plateformes de containerisations.

CLICK

### Le système parfait existe t-il ?

Alors, peut-on faire mieux ? A à quoi ressemblerais le système parfait :

CLICK

D'abord, il serait automatisable et très facile à déployer à l'échelle voir à redéployer en cas de panne.

CLICK

Toute la configuration du système doit être sous forme d'un code facilement auditable et versionnable

CLICK

Il doit nous permettre de faire exactement ce que l'on peut faire sur d'autres systèmes GNU/Linux, on ne veux pas être limité par la technos

CLICK

Le système doit nous garantir la reproductibilité et l'idempotence des déploiements et mises à jour.

CLICK

Enfin, il doit fonctionner sur des environnements virtualisés ou physiques.

CLICK

## Fonctionnement

plan

CLICK

### NPM? = Nix Package Manager

part d'un package manager cross-distribution basé sur un language fonctionnel pure

CLICK

### Package VS Derivation

exemple de ce qu'est une derivation
oubliez le dpkg hell

packages représenté par hash sha256, pas de collision de nom + tous est signé

CLICK

### Mirroir mon beau mirroir...

tellement plus simple que mirroir APT

CLICK

### Nix Store

screen du nix store
exemple de liens symboliques de tout un programme

CLICK

### Vous faites le lien ?

```
[tristan@demo:~]$ gcc --version
gcc (GCC) 11.3.0
```

CLICK

```
[tristan@demo:~]$ which gcc
/home/tristan/.nix-profile/bin/gcc
```

CLICK

```
[tristan@demo:~]$ ls -l /home/tristan/.nix-profile/bin/gcc
/home/tristan/.nix-profile/bin/gcc -> /nix/store/ykcrnkiicqg1pwls9kgnmf0hd9qjqp4x-gcc-wrapper-11.3.0/bin/gcc
```

CLICK

## Cas Pratique


CLICK

### Situation initiale

on part d'une app qui expose un service (ici un nextcloud par exemple)

CLICK

### "Talk is cheap, ..."

prémière étape, on écris une dérivation pour ça (comme un package debian mais tellement plus simple)

```
  argProjectName = "--project-name '$name'";
  argComposeFile = "--file '$src/docker-compose.yml'";
  dockercmd = "compose ${argProjectName} ${argComposeFile} up -d";
```

CLICK

```
  name = "docker-nextcloud";
```

CLICK

```
  src = fetchFromGitHub {
    owner = "0b11stan";
    repo = "docker-nextcloud";
    rev = "main";
    sha256 = "sha256-Sh+9Apb71QJHeShgaUbqLXQJMEjrBfkY/tW4Piq7Kss=";
  };
```

CLICK

```
  builder = "${pkgs.bash}/bin/bash";

  args = [ "-c"
    ''
      ${core}/mkdir $out \
        && echo "${pkgs.docker}/bin/docker ${dockercmd}" \
        > $out/$name.sh \
        && ${core}/chmod +x $out/$name.sh
    ''
  ];
```

CLICK

### Configurations

CLICK

### Configuration - Nextcloud

```
nixpkgs.overlays = [(self: super: {
  docker-nextcloud = super.callPackage ./docker-nextcloud.nix {};
})];
```

CLICK

```
environment.systemPackages = [pkgs.docker-nextcloud];
```

CLICK

```
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

CLICK

### Configuration - Docker

```nix
  virtualisation.docker.enable = true;
```

CLICK

### Configuration - SSH

```nix
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };
```

CLICK

### Configuration - Réseau

```nix
  networking = {
    hostName = "nixos-harden";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [8080 22];
    };
  };
```

CLICK

### Configuration - User

```nix
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

CLICK

## Résultats

```txt
> wc -l src/*.nix src/*.sh

  69 src/configuration.nix
  34 src/docker-nextcloud.nix
  42 src/hardware-configuration.nix
   2 src/init.sh
 147 total
```

CLICK

## Synthèse

en plus de précédent : fichiers changes de place => malware perdus

CLICK

### Bonus - Isolation logicielle

chaque logiciel à accès qu'a ses dépendances et chaque environnement utilisateur est isolé des autres

```
$ echo $PATH | tr ':' '\n'

  /run/wrappers/bin
  /home/tristan/.nix-profile/bin
  /etc/profiles/per-user/tristan/bin
  /nix/var/nix/profiles/default/bin
  /run/current-system/sw/bin
```

CLICK

### Bonus - Nix shell

pas vraiment pour prod mais c'est un gros point fort pour les dev

```
[tristan@demo:rustproject]$ tail -n 2 shell.nix
  LIBPCAP_LIBDIR = "${pkgs.libpcap}/lib";
}
```
CLICK

```
[tristan@demo:rustproject]$ echo $LIBPCAP_LIBDIR
```
CLICK

```
[tristan@demo:rustproject]$ nix-shell
this path will be fetched (0.06 MiB download, 0.30 MiB unpacked):
  /nix/store/x8mymrkpsmpwyvqssjbwsq851kscf1kw-bash-interactive-5.1-p16-dev
copying path '/nix/store/x8mymrkpsmpwyvqssjbwsq851kscf1kw-bash-interactive-5.1-p16-dev' from 'https://cache.nixos.org'...
```
CLICK

```
[nix-shell:rustproject]$ echo $LIBPCAP_LIBDIR
/nix/store/pby...ipx-libpcap-1.10.1/lib
```
CLICK

### Bonus - Root en readonly


```
$ DERIVATION=$(ls -tp /nix/store/ | grep 'openssh.*/$')
```
CLICK

```
$ ls -l /nix/store/$DERIVATION/etc/ssh/
total 504
-r--r--r-- 2 root root 505489  1 janv.  1970 moduli
-r--r--r-- 2 root root 1531  1 janv.  1970 ssh_config
-r--r--r-- 2 root root 3226  1 janv.  1970 sshd_config
```
CLICK

```
$ sudo chmod +w /nix/store/$DERIVATION/etc/ssh/sshd_config
[sudo] Mot de passe de tristan :
chmod: modification des droits [...] Read-only file system
```
CLICK

### Les inconvenients

- Moins "Flexible" <!-- .element: class="fragment" -->

étape supplémentaire pour changer conf (ex: /etc/host) problème que pour les desktop

CLICK

- Croissances du Nix store <!-- .element: class="fragment" -->

profustion possible des packets => problème que pour desktop => garbage collection

CLICK

- Surcharge de Nixpkgs <!-- .element: class="fragment" -->


CLICK

- Adoption = changement d'OS <!-- .element: class="fragment" -->

toutes technos d'IAC pareil mais du coup moins souple qu'ansible par exemple => cela dis possible de passer à nix avant

CLICK

### Conclusion

Très bonne doc et plein de projets subsidiaires : home-manager, flakes, hydra, nixops, ...

Parler du rollback, de la sécu

encourage à tester

Passez au stand capgemini pour questions
