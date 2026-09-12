# Architecture de permissions multi-services et partage réseau sécurisé

> Transparence : `techcorp_setup.sh` est le script original, exécuté et
> validé tel quel (preuves d'exécution ci-dessous). `samba_network_share.sh`
> rassemble des commandes exécutées et validées une à une à la main pendant
> le projet, présentées ici sous forme de script pour faciliter la lecture
> et la reproduction.

## En bref
Une entreprise fictive à 4 départements (RH, IT, Finance, Direction) a besoin
d'un espace de fichiers où chaque service ne voit que ses propres documents,
avec en plus un espace commun accessible à tout le monde. Ce projet construit
cette solution en deux temps : d'abord sur la machine elle-même, ensuite
ouverte au réseau pour que chaque employé puisse s'y connecter depuis son
poste de travail, comme dans une vraie entreprise.

## Étape 1, organiser les accès sur la machine
Chaque département a son propre groupe Linux et son propre dossier, fermé
aux autres services (permissions 770 : le propriétaire et le groupe ont tous
les droits, les autres n'ont rien). Un réglage supplémentaire (le bit SGID)
garantit que tout nouveau fichier créé dans un dossier appartient
automatiquement au bon service, peu importe qui l'a créé.

Cette étape a d'abord été faite à la main, puis transformée en script
(`techcorp_setup.sh`) pour éviter de retaper les mêmes commandes à chaque
nouveau serveur. Le script vérifie toujours l'état existant avant d'agir :
il peut être relancé plusieurs fois sans jamais créer de doublon ni casser
quoi que ce soit (propriété appelée "idempotence").

Preuve, premier lancement (création) :

    rh creating...
    The service rh was successfully created
    user rh_awa is creating...
    The user rh_awa was successfully created

Preuve, second lancement (idempotence, rien ne casse) :

    The service rh already exists on the server
    the user rh_awa already exists

## Étape 2, ouvrir au réseau avec Samba
Une fois les accès organisés localement, Samba est utilisé pour rendre ce
système accessible depuis le réseau, comme un dossier partagé classique
d'entreprise, compatible Windows/Mac/Linux.

Un piège rencontré et résolu : même avec les bonnes permissions sur son
propre dossier, un employé ne pouvait pas y accéder, à cause du dossier
parent qui bloquait le passage. Solution : des ACL supplémentaires qui
autorisent la traversée du dossier parent sans donner de droit de listage.

Preuve par un vrai client réseau (smbclient) :

    Accès légitime (RH vers son propre dossier) :
    smb: \> ls
    awa1.txt   N   0   ...
    écriture confirmée

    Isolation testée (RH vers le dossier Finance) :
    tree connect failed: NT_STATUS_ACCESS_DENIED
    refus confirmé

## Ce que ce projet démontre
- Gestion des identités et des groupes Linux
- Modèle de permissions Unix et ACL avancées
- Scripting Bash idempotent et testé
- Configuration et sécurisation d'un service réseau (Samba/SMB)
- Méthodologie de test systématique, accès autorisés ET refus attendus

## Fichiers
- `techcorp_setup.sh` : script original, création automatisée des comptes et permissions
- `samba_network_share.sh` : synthèse des commandes de mise en réseau
- `samba_shares.conf` : exemple de configuration Samba
- `docs/` : rapports complets du projet
