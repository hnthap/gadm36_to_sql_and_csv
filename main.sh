#!/bin/sh

function main() {

    data_dir="temp_data"
    temp_db_path="$data_dir/demo.db"
    declare -a target_files=( \
        "$data_dir/0.csv" \
        "$data_dir/1.csv" \
        "$data_dir/2.csv" \
        "$data_dir/3.csv" \
    )
    declare -a urls=( \
        "https://data.apps.fao.org/catalog/dataset/1961e5b7-01a3-4d9f-bc05-9fd087871fde/resource/41621125-7666-4b0f-946d-586eb4707244/download/gadm36_0.csv" \
        "https://docs.google.com/spreadsheets/d/1S0_Wl0bM8EAyX23M4Yld7nIuh6esoWh9IVs_QrWYeBU/gviz/tq?tqx=out:csv&sheet=gadm36_1" \
        "https://data.apps.fao.org/catalog/dataset/16eedb5a-fc69-49fb-b3ea-ea772d189b04/resource/e900f155-86a0-4588-9295-ff3bc0ffcdcd/download/gadm36_2.csv" \
        "https://data.apps.fao.org/catalog/dataset/e53331d6-a4b4-405e-b4e7-6bccaf169b33/resource/ccbdd10e-d3e7-4613-bde2-f1efdc2e9b3f/download/gadm36_3.csv" \
    )

    # Remove the temporary database file
    task_name="deleting $temp_db_path if it exists"
    rm --force $temp_db_path
    if [[ $? -ne 0 ]]; then
        echo "FAILED $task_name"
        return 1
    fi
    echo "DONE $task_name"

    # Download data directly to ./temp_data from the website
    for i in {0..3}; do
        target_file="${target_files[$i]}"
        url="${urls[$i]}"
        task_name="deleting $target_file"
        rm "$target_file"
        if [[ $? -ne 0 ]]; then
            echo "FAILED $task_name"
            return 1
        fi
        echo "DONE $task_name"
        task_name="downloading $target_file from $url"
        wget -O "$target_file" "$url" --no-verbose
        if [[ $? -ne 0 ]]; then
            echo "FAILED $task_name"
            return 1
        fi
        echo "DONE $task_name"
    done

    # Populate raw data from CSV files to the temporary database
    for i in {0..3}; do 
        csv_file_name=$i.csv
        csv_path=$data_dir/$csv_file_name
        command=".import $csv_path raw_gadm36_$i --csv"
        task_name="importing $csv_path to database at $temp_db_path"
        sqlite3 "$temp_db_path" "$command"
        if [[ $? -ne 0 ]]; then
            echo "FAILED $task_name"
            return 1
        fi
        echo "DONE $task_name"
    done

    # Create necessary tables
    task_name="creating necessary tables in $temp_db_path"
    sqlite3 "$temp_db_path" < "01_schema.sql"
    if [[ $? -ne 0 ]]; then
        echo "FAILED $task_name"
        return 1
    fi
    echo "DONE $task_name"

    # Populate those tables with raw data
    task_name="populating those tables in $temp_db_path"
    sqlite3 "$temp_db_path" < "02_normalize.sql"
    if [[ $? -ne 0 ]]; then
        echo "FAILED $task_name"
        return 1
    fi
    echo "DONE $task_name"

    # Export each table to a CSV file
    task_name="exporting each table to a CSV file"
    sqlite3 "$temp_db_path" < "03_store.sql"
    if [[ $? -ne 0 ]]; then
        echo "FAILED $task_name"
        return 1
    fi
    echo "DONE $task_name"

    # Delete the temporary database and CSV files in disk
    declare -a deleted=( \
        $temp_db_path \
        # "${target_files[@]}" \
    )
    for deleted_file in "${deleted[@]}"; do
        task_name="deleting $deleted_file in disk"
        rm "$deleted_file"
        if [[ $? -ne 0 ]]; then
            echo "FAILED $task_name"
            return 1
        fi
        echo "DONE $task_name"
    done
}

main
