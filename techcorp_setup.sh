#!/bin/bash

create_service() {
    name_of_service="$1"
    similar_service=$(getent group "$name_of_service" | cut -d: -f 1)
    if [ "$name_of_service" = "$similar_service" ]; then
        echo "Le service $name_of_service existe deja"
    else
        groupadd "$name_of_service"
        echo "Le service $name_of_service a ete cree"
    fi
}

create_users() {
    user_name="$1"
    user_group="$2"
    user_exist=$(getent passwd "$user_name" | cut -d: -f 1)
    if [ "$user_exist" = "$user_name" ]; then
        echo "L'utilisateur $user_name existe deja"
    else
        if useradd -m -g "$user_group" -s /bin/bash "$user_name" 2> /dev/null; then
            echo "L'utilisateur $user_name a ete cree"
        else
            echo "Echec de la creation de $user_name (code $?)"
        fi
    fi
}

setup_service_folders() {
    service_name="$1"
    path="/data/${service_name}_folders"
    if [ -d "$path" ]; then
        echo "Le dossier $service_name existe deja"
    else
        mkdir -p "$path"
        echo "Le dossier $service_name a ete cree"
    fi

    if ls -ld "$path" | grep -q "rwxrws"; then
        echo "Permissions deja correctes"
    else
        chmod 770 "$path"
        chmod g+s "$path"
        echo "Permissions assignees"
    fi

    current_group=$(ls -ld "$path" | awk '{print $4}')
    if [ "$current_group" = "$service_name" ]; then
        echo "Groupe deja correct"
    else
        chown :"$service_name" "$path"
        echo "Groupe assigne"
    fi
}

services=("rh" "it" "finance" "direction")
employees=("rh_awa:rh" "rh_koffi:rh" "it_admin:it" "it_junior:it" \
    "finance_edwige:finance" "finance_bio:finance" "direction_ceo:direction")

for service in "${services[@]}"; do
    create_service "$service"
    setup_service_folders "$service"
done

for entry in "${employees[@]}"; do
    user="${entry%%:*}"
    group="${entry##*:}"
    create_users "$user" "$group"
done
