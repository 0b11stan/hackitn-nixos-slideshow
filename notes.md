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
ambitieux donc mon objectif principale c'est que directement après cette conf
vous annuliez tous vos plan et que vous alliez tester la distribution par vous
même

voila ce qu'on va faire:

je vais vous exposer dans un premier temps ce qui me semble être les plus gros
problèmes techniques qu'on rencontre aujourd'hui dans la sécurisation de nos
systèmes

ensuite je vous expliquerais très rapidement les rudiment du système et ce qui
fait que cette distribution est différente de tous ce que vous connaissez

avec ces quelques informations en tête, je vais vous montrer un cas pratique

puisqu'un extrait de code vaut mieux que 1000 mots, on regardera vraiment à
quoi ça ressemble de monter un système nixos

enfin, je ferais une petite synthèse de tous ce qu'on à vus en montrant comment
ces conceptes peuvent s'articuler pour assurer un niveau de sécurité rarement
atteint par d'autres distributions

CLICK

### Constats

Quels problèmes sont à l'origines de la création de ce projet

CLICK

D'abord, et je l'ai mis en premier parcequ'il me semble que c'est le problème
principale: c'est un problème de visibilité. On ne sais pas aujourd'hui dans nos
infra quelles machines sont déployés avec quelle configuration et qu'est-ce qui
tourne dessus ?

CLICK

ensuite ce que j'appelle l'entropie des configurations: dans un SI un peu mature
vous trouverez autant de configuration différentes que de machines. chaque admin
à ses habitudes certain vont installé un même packet avec pip, d'autres vont
extraire un tar dans /opt, j'en passe et des meilleurs.
ont à besoin de normalisation

CLICK

comme les configurations sont toutes différentes, appliquer un patch de sécurité
est un enfer. Comment je fais si le patch introduit des incompatibilité ? Dans
quelle version sont mes logiciels ? Ces questions sont des freins à la bonne
gestion de la sécurité d'un parc informatique en constante croissance

CLICK

nous systèmes deviennent alors obscurent et sont incroyablement difficiles à
auditer. on s'en ai accomoder au file du temps mais
les seuls audites qui sont possibles aujourd'hui sont des audites "abstrait" qui
se résument à commenter des schéma d'architecture pas à jour ou à faire des
tests d'intrusion au petit bonheur la chance qui n'ont aucune garantie
d'exhaustivité

CLICK

Enfin l'automatisation est complexe. Si vous voulez retrouver votre état nominal
après un incident il va falloir rejouer une documentation de déploiment
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
solutions s'appuient sur un "état virtuel" du système qu'elles déploient

ça les met faces à un problème majeur: comment faire lorsque le système à été changé "à la main"?
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

Enfin, le même code devrait sur des environnements physiques ou virtualisés.

CLICK

## Fonctionnement

Rentrons dans le dure du sujet et voyons maintenant comment fonctionne le
système.

CLICK

### NPM? = Nix Package Manager

Tout part d'une publication de Eelco Dolstra en 2006 qui met en lumière les problèmes
des gestionnaires de paquet traditionnels, notemment leur difficultée à gérer
les dépendances et leurs sensibilité aux changements "cassants".

Pour sa thèse, il présente donc une nouvelle approche inspiré des languages
fonctionnels

comme avec des languages fonctionnels pur il veux assurer l'isolation des
packages entre eux, leurs imutabilité et l'identification automatique de toutes les
dépendances nécessaire au fonctionnement de chaque package.

Ainsi on pour nommer un système de packaging avec de telles propriétés, on ne
parlera pas de paquet mais de DÉRIVATIONS.

CLICK

### Package VS Derivation

Il y en à ici qui ont déjà fait du packaging sous debian ?

Avec tous le respect que je dois à une distribution comme débian, le packaging 
sous débian est un enfer. Dpkg est un outil aussi puissant qu'il est compliqué
à prendre en main et l'historique énorme qu'il traine avec lui ne lui rend pas
service.

Avec ce principe de dérivation, vous pouvez oublier les packages obsures qui
mélangent système de build inconnus, scriptes esotériques et variables
d'environnement mystiques. La définition de chaque dérivation est contenue dans
un fichier très clair à lire et qui est accessible même pour les plus novices.

Pour que chaque dérivation soit généré de façon déterministe elle annonce de
façon très clair toutes ces dépendances.

CLICK

### Nix Store

Une fois build, chacune de ces dérivation est représenté par un hash qui
assure l'intégrité de la dérivation mais également de toutes les dérivations
"sources" qui sont nécessaire à son build ou à son execution.

Les dérivation se font toutes références les unes entre les autres en utilisant
ce hash,

vous pouvez dès lors oublier toutes les problématiques de collision de nom, qu'elles
soient l'oeuvre d'un attaquant ou d'un simple accident.

Comme vous pouvez le voir, ces dérivations sont toutes stocké dans `/nix/store`.
que j'appellerais le nix store

Plus besoin de se souvenir si vos binaire sont plutôt dans /bin /sbin /usr/bin ou
/usr/share/bin, tout est la !

CLICK

### Mirroir mon beau mirroir...

Et puisque les dérivations sont aussi simples à réaliser, l'incroyable communauté
derrière nixos à déjà écrite plus de 80 000 dérivations permettant d'installer
tous vos packages préférés. L'équivalent du mirroir APT de débian, c'est donc
ce dépot github.

Créer un nouveau mirroir est donc aussi simple que de fork le projet.

CLICK

### Vous faites le lien ?

J'imagine que tous ceci est encore un peu abstrait, qu'est-ce que ça donne
au jour le jour dans mon shell.

Et bien voyons voir avec un exemple, imaginons que j'ai installé gcc sur mon
poste nixos.

CLICK

Si je cherche à connaitre la localisation de mon binaire vous verrez qu'il pointe
vers un 'nix-profile'.

CLICK

Ce profile est lui même un lien vers une dérivation qui contient tous les
emplacementes du nix store auquels mon utilisateur à accès

Finalement nixos c'est un gestionaire de packet purement fonctionnel (nix donc)
qui s'appuie de façon très élégrantes sur les fonctionnalités de lien des
systèmes de fichier modernes le tout intégré avec systemd

CLICK

## Cas Pratique

Maintenant qu'on à expliqué les quelques bases du système, je vais essayer
d'éclaircir un peu à quoi ressemble le déploiement d'un système sur nixos

CLICK

### Situation initiale

Imaginons que vous ayez une application qui tourne avec docker compose
et que vous déployez donc jusqu'ici sur un debian ou centos classique

nous allons voir ce que cela donnerais de passer ce projet sous nixos en faisant
les chose selon la philosophie "nix"

CLICK

### "Talk is cheap, ..."

Prémière étape pour faire les choses bien, ça serait d'écrire une dérivation
(donc un package) pour déployer votre application 

debian vous jouiez la commande suivante :

docker compose 

CLICK

-p le nom de votre projet
-f le chemin vers votre fichier yaml

mettons ça dans des variables pour la lisibilité et continuons

CLICK

on est mainteanant dans le coeur de notre dérivation,
il faut lui donner un nom qui participera à générer le hash qu'on à vue tout à
l'herue, ici: docker-nextcloud

CLICK

maintenant on définie les sources du packet. la fonction fetchfromgithub est
une fonction intégré dans le système qui permet d'aller chercher un projet depuis
github, en l'occurence, le dépôt git qui contient notre fichier docker-compose.yaml

CLICK

enfin, on définie le résultat de notre dérivation : c'est à dire un script
qui lancera la commande voulue et qui sera stocké 

CLICK

dans $out, une variable qui contiendra le fameux chemin de ma dérivation dans le nix store
que l'on à vue auparavant

CLICK

vous remarquerez que l'orsque j'utilise des commandes comme mkdir chmod ou docker,
je les préfixes toujours d'un objet pkgs, c'est l'accès à cet objet qui
permet à nix de définir les dérivations exactes dont dépend mon packet
(en loccurence coreutils et docker) et de replacer dynamiquement ces variables
par leur chemin dans le nix store à l'execution du script

CLICK

### Configurations

Une fois cette dérivation d'une 30aine de ligne est écrite le plus dure est déjà
fait, il ne reste plus qu'a configurer correctement le reste du système

pour ça on écrit un fichier qui sera placé dans /etc/nixos/configuration.nix

c'est d'ailleurs un des seul fichier du répertoire /etc qui est ouvert à
l'écriture

ce que vous voyez c'est le squelette de ce fichier dans lesquelle on va ajouter
quelques bloques pour décrire notre système

CLICK

### Configuration - Nextcloud

D'abord, il faut dire à nixos d'installer notre application

pour ça on ajoute notre dérivation aux sources autorisés, que l'on pourrait
comparer aux fichiers "release" de debian et qui décis tous les packages que l'on
peut installer sur le système

CLICK

puis on installe notre dérivation docker-nextcloud que l'on rend accessible à
l'entièreté du système

CLICK

enfin, on défini un service systèmed

CLICK

qui sera déployé au démarrage

CLICK

qui execute le script généré par notre dérivation

CLICK

et le tous en donner accès par exemlpe à d'éventuels secrets en variable
d'environnement

CLICK

### Configuration - Docker

biensure, il est nécessaire d'installer docker, ce qui se fait en une ligne

CLICK

### Configuration - SSH

Pour l'administration, il est toujours possible d'activer ssh et de
configurer le service par la même occasion, en 5 lignes

CLICK

### Configuration - Réseau

La configuration réseau tiens en 10 lignes

CLICK

et nous permet de manipuler le firewall local de façon simplissime sans toucher
une seule fois à l'interface cryptique d'IPTABLE

quand c'est aussi simple d'activer un firewall local,
vous n'avez plus aucune excuse pour ne pas le faire

CLICK

### Configuration - User

enfin, vous voudrez ajouter un ou plusieurs administrateur à votre système

CLICK

les ajouter dans des groupes

CLICK

leur installer des application isollées les uns des autres

CLICK

configurer leurs clefs SSH

CLICK

## Résultats

Ca donne quoi ?

la dérivation qu'on à écrite faisait une 30aine de ligne

il y à une 40aine de ligne généré automatiquement à l'installation du système
pour la gestion des spécificités materiels, du bootloader et autre

et la configuration globale ne dépasse pas les 70 lignes


CLICK

## Système parfait

bref, en moins de 150 lignes de configuration

CLICK

écrite dans un language limpide,

CLICK

vous êtes en mesure de déployer

CLICK

un système de façon reproductible

CLICK

en allant jusqu'a définir un service systèmd spécifique pour votre application

CLICK

le tous déployable sur des machines virtuelles ou physiques

CLICK

## Synthèse

que demander de plus me diriez vous ?

CLICK

### Bonus - Isolation logicielle

ben je vais vous le dire, parceque le système offre beaucoup d'autres garanties

d'abord grâce au principe de profile qu'on à vu plus tôt chaque logiciel à accès
qu'a ses dépendances et chaque environnement utilisateur est isolé des autres

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

L'utilisation d'un système de déploiement prédictible et isolé permet
de mettre au point une fonctionnalités inutile en production mais
très puissante pour les dévellopeurs : les shell nix

pensez, environnement virtuel python mais en beaucoup mieux

les utilisateurs de nix peuvent créer des fichiers shell.nix pour leurs projets
dans lesquels ont peut définir les packets à installer pour faire fonctionner
le projet mais aussi éventuellement des variables d'environnement, des alias de
commande, et même des script bash à executer au démarrage du shell

ça ressemble à quoi ?

ici par exemple j'ai un projet qui utilise la lib pcap mais comme j'utilise
plusieurs version de cette lib j'ai besoin de définir son emplacement exacte :

CLICK

avant l'execution de l'environnement, la variable d'existe pas

CLICK 

après sont execution, notre shell point vers un nouveau nix-profile

CLICK

et le shell qu'on obtiens est bien chargé avec la variable voulue

CLICK

### Bonus - Root en readonly

Sur nixos, je l'ai déjà dis, la majorité du système de fichier root n'est pas
modifiable et c'est en particulier vrai pour le store dans lequel sont toutes
nos dérivations

mettons nous dans la peau d'un attaquant ayant réussi à faire une escalade de
privilège sur le système et voulant modifier la configuration openssh pour
péréniser son accès

il va d'abord devoir chercher l'emplacement d'openssh dans le store, ce qui
peut être réalisé avec un simplement avec un grep 

CLICK

il se rendra compte que les fichier qu'il veut modifier sont en readonly même
pour root

il suffit simplement de changez les droits d'accès me direz vous ?

CLICK

non plus, c'est le système fichier tout entier du store qui est monté en read only

le seul moyen de modifier les fichiers de configuration pour notre atttanquant 
est de réécrir un fichier nix 

qui doit correspondre au système s'il ne veux pas tout casser

et même si c'est toujours possible cela augment grandement la complexité de la
majorité des attaques système

d'autant qu'il est très facile de supperviser de telles actions

CLICK

### Bonus - rollback

enfin, un dernier bonus

sur nixos les erreurs coutent moins cher

à chaque reboot, le bootloader proposera différentes entrée qui correspondes à
tous les précédents état de la configuration

CLICK

comme vous pouvez le constater, mon entrée de boot point juste vers une
autre dérivation contenant l'initialisation de mon système par systemd

### Les inconvenients

Maintenant, parcequ'il faut bien en parler, voici quelques inconvenients et
reproches qui peuvent êtres faites à nixos

CLICK

d'abord le système est moins flexible que ce que vous pouvez connaitre dans
d'autres distrib

par exemple, si vous faites du devellopement web ou du pentest il va souvent
vous arriver de changer le fichier /etc/hosts de votre PC, sur nixos il faudra
passer par l'édition d'un fichier supplémentaire

c'est un peu lourd pour une utilisation desktop mais c'est le prix à payer pour
avoir la garantie d'intégrité qui est si cher à vos serveurs

CLICK

forcément la possibilité

* d'installer des version concurrente de plusieurs librairies
* d'avoir des environnements isolés 
* et de pouvoir rollback quand ont veux

viens avec la nécessité d'avoir un peut de code en doublons dans le nix store
pour conserver les anciennes versions du système

ne vous inquitez pas, pour pallier à la croissance parfois rapide du store il
existe un garbage
collector très efficace à qui vous pouvez demander de supprimer les
dérivation qui ne sont plus utilisés depuis vous N dernières générations

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

### Conclusion

Très bonne doc et plein de projets subsidiaires : home-manager, flakes, hydra, nixops, ...

encourage à tester

Passez au stand capgemini pour questions
