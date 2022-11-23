<!-- .slide: data-background="#ffffff" -->
# Nixos

_Tristan Pinaudeau @ <span class="highlight">Capgemini</span>_

NOTES:

* prochaine demi-heure
* distribution linux pas comme les autres
* n'était pas clair: NIXOS.

questions pour curiosité :

* qui à déjà entendu parlé de nixos ?
* qui l'a déjà essayé ?
* qui l'as mis en production ?

---

## Présentation

- <span class="highlight">SRE</span> à Cdiscount
- <span class="highlight">PENTESTER</span> à Capgemini

NOTES:

* m'appelle tristan pinaudeau
* mon premier job => ingénieur SRE => Cdiscount
  - attrappé le virus de l'automatisation et du "tout as code".
* métier de passion => pentester à capgemini
* attrait pour nixos => croisement de ces deux expériences
* allez très vite comprendre pourquoi

---

## Introduction

NOTES:

* expliquer nixos en 30 minutes => ambitieux
* objectif principale => vous tester par vous même
* mon plan
    - problèmes techniques dans sécurité systèmes
    - rudiment du systèm => distribution différente
    - avec ces infos => cas pratique
    - extrait de code > 1000 mots => à quoi ressemble projet
    - synthèse => conceptes s'articuler pour niveau sécurité rare

--

### Constats

- Inexhaustivité de la cartographie <!-- .element: class="fragment" -->
- Entropie des configurations <!-- .element: class="fragment" -->
- Gestion chaotique des patchs <!-- .element: class="fragment" -->
- Obscurité à l'audit <!-- .element: class="fragment" -->
- Automatisation complexe <!-- .element: class="fragment" -->

NOTES:

* cartographie
  - premier car important
  - problème de visibilité
  - quelles machines sont déployés
  - avec quelle configuration
  - qu'est-ce qui tourne dessus ?
* entropie des configurations
  - dans SI un peu mature
  - autant de configuration différentes que machine
  - admin => habitudes
    * packet avec pip
    * extraire tar dans /opt
    * j'en passe et des meilleurs.
  - ont à besoin de normalisation
* patchs
  - comme configs toutes différentes
  - appliquer patch = enfer
  - introduit des incompatibilité ?
  - versions de logiciels ?
  - freins à la bonne gestion
* obscure
  - incroyablement difficiles à auditer
  - accomoder au file du temps
  - seuls possibles
    * commenter schéma d'architecture pas à jour
    * faire des tests d'intrusion => aucune garantie
* automatisation
  - incident => état nominal
  - rejouer doc vieille et pas clair
  - aucune garantie de fonctionner

--

### Solutions Eventuelles

- GPO / Scripts <!-- .element: class="fragment" -->
- Infrastructure As Code <!-- .element: class="fragment" -->
- Containerisation <!-- .element: class="fragment" -->

NOTES:

autres projet ont essayé

* difficilement scalable + pas assez robuste + pas normalisée => beaucoup d'erreur
* plus scalable MAIS "état virtuel" => modif "à la main" => idempotence
* pas applicable partout + pb des infrastructures physiques

--

### Le système parfait existe t-il ?

- Automatisable <!-- .element: class="fragment" -->
- Versionnable <!-- .element: class="fragment" -->
- Liberté de configuration <!-- .element: class="fragment" -->
- Reproductibilité / Idempotance <!-- .element: class="fragment" -->
- Bare Metal & Env. Virtualisé <!-- .element: class="fragment" -->

NOTES:

peut-on faire mieux => à quoi ressemble système parfait ?

* automatisable => facile => à l'échelle => redéployer pour panne.
* code facilement auditable et versionnable
* faire pareil qu'autre système => veux pas limité par la technos
* garantir reproductibilité + idempotence des déploiements et mises à jour.
* fonctionne sur environnements physiques ou virtualisés.

---

## Fonctionnement

--

### NPM? = Nix Package Manager

![](dist/custom/phd.png)

NOTES:

* publication => Eelco Dolstra => 2006 => problèmes des PM traditionnels:
  - difficultée à gérer dépendances
  - sensibilité aux changements "cassants".
* Pour thèse => présente nouvelle approche => inspiré des languages fonctionnels
* comme languages fonctionnels pur:
  - isolation des packages entre eux
  - imutabilité
  - identification automatique de dépendances
* package + propriété = DÉRIVATION

--

### <span class="overline">Package</span> <span class="redify">Derivations<span>

![](dist/custom/drake.png)

NOTES:

* Il y en à ici qui ont déjà fait du packaging sous debian ?
* tous le respect que je dois à distribution comme débian
* packaging => enfer
* dpkg => aussi puissant qu'il est compliqué à prendre en main
* l'historique énorme => ne rend pas service.
* principe de dérivation =>  oublier
  - les packages obsures
  - qui mélangent système de build inconnus
  - scriptes esotériques
  - variables d'environnement mystiques
* définition de dérivation => syntaxe clair => accessible => novices.
* dérivation => déterministe => annonce dépendances.

--

### Nix Store

![](dist/custom/nixstore.png)

```
      DERIVATION = hash(hash(SRC) + hash(DEPENDANCES))
```

NOTES:

* dérivation => représenté par hash => intégrité
* également dérivations dont dépent => pour build => ou execution
* références les unes entre les autres => utilisant hash
* oublier => collision de nom => oeuvre d'un attaquant => ou simple accident.
* toutes stocké dans `/nix/store` => j'appellerais le nix store

--

### Mirroir mon beau mirroir...

![](dist/custom/github.png)

NOTES:

* dérivations simples à coder
* incroyable communauté => écrite + 80 000 dérivations
* installer tous vos packages préféré
* équivalent de mirroir APT => github
* nouveau mirroir => aussi simple que => fork

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

* encore un peu abstrait
* pointe vers un 'nix-profile'
* nix-profile => lien vers dérivation
* dérivation => liens vers nix store
* nixos = PM purement fonctionnel + liens + systemd

---

## Cas Pratique

--

### Situation initiale

```txt
├── docker-compose.yml
├── Makefile
└── template.env
```

NOTES:

* tourne => docker compose
* historiquement => debian ou centos
* passer sous nixos => philosophie "nix"

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

NOTES:

* Prémière étape => écrire dérivation
* debian vous jouiez la commande suivante
  - docker compose 
  - -p => nom projet
  - -f => chemin fichier yaml
* coeur de dérivation => nom => participe hash 
* sources du packet => fetchfromgithub => builtin => dépôt => docker-compose.yaml
* résultat dérivation => script
* $out => variable => chemin => nix store
* mkdir chmod docker => objet pkgs => définis dépendances => replacer par path store

dérivation docker-nextcloud => 30aine de lignes

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

NOTES:

* plus dure est déjà fait => reste configurer correctement système
* fichier => dans /etc/nixos/configuration.nix
* voyez => squelette => ajouter bloques => pour décrire système

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

NOTES:

* ajoute dérivation => aux sources autorisés => fichiers "release" debian
* rend accessible à l'entièreté du système
* enfin, on défini un service systemd
* qui sera déployé au démarrage
* qui execute le script généré par notre dérivation
* et le tous en donnant accès par exemlpe à secrets

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

NOTES:

Pour l'administration, il est toujours possible d'activer ssh et de
configurer le service par la même occasion, en 5 lignes

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

NOTES:

* La configuration réseau tiens en 10 lignes
* firewall local => pas cli IPTABLE
* quand c'est aussi simple d'activer un firewall local => plus excuse

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

NOTES:

* enfin, vous voudrez ajouter un ou plusieurs administrateur à votre système
* les ajouter dans des groupes
* leur installer des application isollées les uns des autres
* configurer leurs clefs SSH

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

NOTES:

* dérivation => 30aine de ligne
* 40aine de ligne généré automatiquement à l'installation du système
* pour la gestion des spécificités materiels, du bootloader et autre
* configuration globale ne dépasse pas les 70 lignes

--

### Le système parfait existe t-il ?

- Versionnable <!-- .element: class="fragment" -->
- Automatisable <!-- .element: class="fragment" -->
- Reproductibilité / Idempotance <!-- .element: class="fragment" -->
- Liberté de configuration <!-- .element: class="fragment" -->
- Bare Metal & Env. Virtualisé <!-- .element: class="fragment" -->

NOTES:

* bref, en moins de 150 lignes de configuration
* écrite dans un language limpide,
* vous êtes en mesure de déployer
* un système de façon reproductible
* en allant jusqu'a définir un service systèmd spécifique pour votre application
* le tous déployable sur des machines virtuelles ou physiques

---

## Synthèse

NOTES:

* que demander de plus me diriez vous ?
* le système offre beaucoup d'autres garanties

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

NOTES:

* chaque logiciel n'à accès qu'a ses dépendances
* chaque environnement utilisateur est isolé des autres

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

NOTES:

* FS root => readonly => en particulier le store
* attaquant => privesc => backdoor => openssh
  - emplacement openssh
  - file readonly
  - filesystem readonly
* seul moyen => réécrir un fichier nix 
  - doit correspondre au système
  - possible mais => augment complexité  attaques système
* facile à supperviser

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

NOTES:

* nixos => les erreurs coutent moins cher
* reboot => bootloader proposera entrée => précédents état de la configuration
* exemple: entrée de boot => point vers dérivation

-- 

### Les inconvenients

- Moins "Flexible" <!-- .element: class="fragment" -->
- Croissances du Nix store <!-- .element: class="fragment" -->
- Surcharge de Nixpkgs <!-- .element: class="fragment" -->
- Systemd centric <!-- .element: class="fragment" -->
- Adoption = changement d'OS <!-- .element: class="fragment" -->

NOTES:

* flexibilité => /etc/hosts => prix à payer pour garantie d'intégrité serveurs

* possibilités:
  - d'installer des version concurrente de plusieurs librairies
  - d'avoir des environnements isolés 
  - et de pouvoir rollback quand ont veux
* nécessite => code en doublons dans le nix store
* garbage collector très efficace => supprimer les D des N dernières générations

CLICK

vous l'avez peut-être vue tout à l'heure sur ma capture d'écran du dépôt github

de nixos mais il y à un peu d'embouteillage dans les issues

cette semaine je comptais :

* plus de 5000 issues
* et plus de 4000 pull request en attente

si c'est une preuve de la popularité croissante du projet

ça dénote aussi d'un manque de correlation entre la facilité à écrire des
dérivations et les moyens humains qui peuvent être déployés pour faire la revue
des codes

si le projet vous intéresse, c'est ici qu'on à besoin de vous

CLICK

si systemd vous donne des allergies, nixos n'est pas pour vous, comme on l'a vu
au dessus il s'appuie grandement sur ce système d'init pour avoir un controle
très fin sur les services qui sont executés

il existe bien des
projet de distribution équivalentes sans systèmd mais ils sont au stade
pré-embryonnaires


CLICK

Enfin, une dernière chose que l'on pourrait critiquer à propos de nixos c'est
sont manque d'adaptabilité aux environnements techniques en place, la ou ansible
peut être utilisé
du jour au lendemin pour déployer de l'infrastructure en s'adaptant à n'importe
quel distribution, nixos nécessite de nouvelles installation

cependant, si je me suis concentré sur nixos parceque je pense que c'est vraiment
la ou le projet dépoie tous son potentiel, n'oubliez pas que nix
est avant tout un gestionaire de packet et que celui-ci peut être installé sur
n'importe quel distribution linux

vous pouvez déjà commencer à utiliser vos premières dérivations nix en prod
avant même de passer sur nixos

CLICK

--

### Conclusion

<div class="column">
  <img src="dist/custom/slideshow.png">
  <p class="subtitle">https://github.com/0b11stan/hackitn-nixos-slideshow</p>
</div>
<div class="column">
  <img src="dist/custom/demo.png" >
  <p class="subtitle">https://github.com/0b11stan/hackitn-nixos-demo</p>
</div>

NOTES:

Très bonne doc et plein de projets subsidiaires : home-manager, flakes, hydra, nixops, ...

encourage à tester

Passez au stand capgemini pour questions

---
<!-- .slide: data-background="#ffffff" -->

![](dist/custom/hackitnix.png)
