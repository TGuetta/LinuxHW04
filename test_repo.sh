#!/bin/bash

# Checking if the correct number of arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 URL_of_tar_gz_file Repository_Folder_Name"
    exit 1
fi

URL=$1
REPO_FOLDER=$2

# Step 1: Create new git repository folder
mkdir -p "$REPO_FOLDER"
cd "$REPO_FOLDER" || exit
git init

# Step 2: Add new file to the repo folder
touch logtest.log

# Step 3: Write current time with nanoseconds and repo folder created message
echo "$(date '+%Y-%m-%d %H:%M:%S.%N') - Repo Folder Created" >> logtest.log

# Step 4: Install curl and download the tar.gz file
sudo apt-get install curl -y
curl -L $URL -o data.tar.gz

# Step 5: Write download completion message
echo "$(date '+%Y-%m-%d %H:%M:%S.%N') – $URL downloaded" >> logtest.log

# Step 6: Extract the tar.gz file
tar -xzf data.tar.gz
rm data.tar.gz # Cleanup downloaded archive

# Step 7: Print all files in the extracted folder
EXTRACTED_FOLDER=$(ls -d */)
echo "Extracted folder content:" >> logtest.log
ls "$EXTRACTED_FOLDER" >> logtest.log

# Step 8: Commit all changes
git add .
git commit -m "Initial commit with downloaded content"

# Step 9: Create new branch BR_IMAGES and switch to it
git checkout -b BR_IMAGES

# Step 10: Copy all image files to Repo folder
find "$EXTRACTED_FOLDER" -type f \( -iname "*.jpg" -o -iname "*.png" \) -exec cp {} ./ \;

# Step 11: Commit branch BR_IMAGES
git add .
git commit -m "Added image files"

# Step 12: Create new branch BR_TEXT and switch to it
git checkout -b BR_TEXT

# Step 13: Copy all text and log files to Repo Folder
find "$EXTRACTED_FOLDER" -type f \( -iname "*.txt" -o -iname "*.log" \) -exec cp {} ./ \;

# Step 14: Commit branch BR_TEXT
git add .
git commit -m "Added text and log files"

# Step 15: Move to master branch and delete the extracted folder
git checkout master
rm -rf "$EXTRACTED_FOLDER"

# Step 16: Commit all changes
git add .
git commit -m "Cleaned up extracted folder"

# Step 17: Merge BR_IMAGES and BR_TEXT into master
git merge BR_IMAGES --no-edit
git merge BR_TEXT --no-edit

# Step 18: Print history list into logtest.log
echo "BR_IMAGES branch history:" >> logtest.log
git log BR_IMAGES --oneline >> logtest.log
echo "BR_TEXT branch history:" >> logtest.log
git log BR_TEXT --oneline >> logtest.log
echo "Master branch history:" >> logtest.log
git log master --oneline >> logtest.log

# Step 19: Push all branches to your github
git push origin master BR_IMAGES BR_TEXT