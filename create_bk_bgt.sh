#!/bin/bash

project_id=$1
name_date=$(date +%d%m%Y%H%M%S)

# Obtener los nombres de las instancias y clústeres en un solo comando, relacionándolos
clusters_info=$(gcloud bigtable clusters list --project=$project_id --format="value(INSTANCE,NAME)")

# Iterar sobre cada línea del resultado para obtener instancia y cluster
while IFS= read -r line; do
    instance=$(echo $line | awk '{print $1}')
    cluster=$(echo $line | awk '{print $2}')

    # Obtener las tablas de la instancia actual
    name_tables=($(gcloud bigtable tables list --instances=$instance --project=$project_id --format="value(NAME)"))

    # Iterar sobre cada tabla para crear el backup
    for name_table in "${name_tables[@]}"; do
        echo "Creando backup para la tabla $name_table en la instancia $instance del cluster $cluster"

        # Crear el backup
        gcloud bigtable backups create "$name_table-$name_date" \
            --project=$project_id \
            --cluster=$cluster \
            --instance=$instance \
            --table=$name_table \
            --retention-period=90d \
            --async
    done
done <<< "$clusters_info"