
function main {
    $dataDir = "temp_data"
    $tempDbPath = "$dataDir/demo.db"
    $targetFiles = @(
        "$data_dir/0.csv",
        "$data_dir/1.csv",
        "$data_dir/2.csv",
        "$data_dir/3.csv"
    )
    $urls = @(
        "https://data.apps.fao.org/catalog/dataset/1961e5b7-01a3-4d9f-bc05-9fd087871fde/resource/41621125-7666-4b0f-946d-586eb4707244/download/gadm36_0.csv",
        "https://docs.google.com/spreadsheets/d/1S0_Wl0bM8EAyX23M4Yld7nIuh6esoWh9IVs_QrWYeBU/gviz/tq?tqx=out:csv&sheet=gadm36_1",
        "https://data.apps.fao.org/catalog/dataset/16eedb5a-fc69-49fb-b3ea-ea772d189b04/resource/e900f155-86a0-4588-9295-ff3bc0ffcdcd/download/gadm36_2.csv",
        "https://data.apps.fao.org/catalog/dataset/e53331d6-a4b4-405e-b4e7-6bccaf169b33/resource/ccbdd10e-d3e7-4613-bde2-f1efdc2e9b3f/download/gadm36_3.csv"
    )
    $necessaryFolders = @($dataDir, "out")

    # Create necessary folders
    foreach ($folderItem in $necessaryFolders) {
        New-Item -ItemType Directory -Force -Path $folderItem
    }

    # Remove the temporary database file
    if (Test-Path -Path $tempDbPath) {
        Write-Host "deleting $tempDbPath if it exists"
        Remove-Item -Force -Path $tempDbPath
    } else {
        Write-Host "confirmed $tempDbPath does not exist"
    }

    # Download data directly to ./temp_data from the website
    for ($i = 0; $i -le 3; $i = $i + 1) {
        $targetFile = $targetFiles[$i]
        $url = $urls[$i]
        Write-Host "downloading $targetFile"
        $OldProgressPreference = $ProgressPreference.PSObject.Copy()
        $ProgressPreference = "SilentlyContinue"
        Invoke-WebRequest -OutFile $targetFile -Uri $url
        $ProgressPreference = $OldProgressPreference.PSObject.Copy()
    }

    # Populate raw data from CSV files to the temporary database
    for ($i = 0; $i -le 3; $i = $i + 1) {
        $targetFile = $targetFiles[$i]
        $sqlite3Command = ".import $targetFile raw_gadm36_$i --csv"
        Write-Host "importing $targetFile to database at $tempDbPath"
        sqlite3.exe "$tempDbPath" "$sqlite3Command"
    }

    # Create necessary tables
    Write-Host "creating necessary tables in $tempDbPath"
    cmd.exe /c "sqlite3.exe $tempDbPath < 01_schema.sql"

    # Populate those tables with raw data
    Write-Host "populating those tables in $tempDbPath"
    cmd.exe /c "sqlite3.exe $tempDbPath < 02_normalize.sql"

    # Export each table to a CSV file
    Write-Host "exporting each table to a CSV file"
    cmd.exe /c "sqlite3.exe $tempDbPath < 03_store.sql"

    # Delete the temporary database and CSV files in disk
    $deletedFiles = $($tempDbPath; $targetFiles)
    foreach ($deletedFile in $deletedFiles) {
        if (Test-Path -Path $deletedFile) {
            Write-Host "deleting $deletedFile if it exists"
            Remove-Item -Force -Path $deletedFile
        } else {
            Write-Host "confirmed $deletedFile does not exist"
        }
    }
}

main
