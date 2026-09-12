#!/bin/bash
# samba_network_share.sh
# Rassemble les commandes documentees et validees manuellement pour exposer
# l'architecture de permissions locale sur le reseau via Samba.
# Il s'agit d'une synthese de commandes reellement executees et testees,
# presentees ici sous forme de script pour la reproductibilite.

set -e

DEPARTMENTS=("rh" "it" "finance" "direction")

# Norme FHS : /srv est reserve aux ressources servies a d'autres (pas /home)
for dept in "${DEPARTMENTS[@]}"; do
    mkdir -p "/srv/samba/$dept"
    chown :"$dept" "/srv/samba/$dept"
    chmod 770 "/srv/samba/$dept"
    # ACL : autorise la traversee du dossier parent sans donner de droit
    # de listage ni d'ecriture (probleme rencontre et resolu pendant le projet)
    setfacl -m g:"$dept":x /srv/samba
done

echo "Structure de dossiers et permissions locales en place."
echo "Etape suivante : creer les comptes Samba avec smbpasswd -a -s <utilisateur>"
echo "puis configurer /etc/samba/smb.conf (voir samba_shares.conf fourni)."
