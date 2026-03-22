#!/bin/bash

# Step 1: Find the 10 largest objects in git history
echo "Finding the 10 largest objects in git history..."
git verify-pack -v .git/objects/pack/pack-*.idx | sort -k 3 -n | tail -10 > largest_objects.txt

echo "Largest objects:"
cat largest_objects.txt

# Step 2: Map object IDs to file names
echo "Mapping object IDs to file names..."
while read -r line; do
  obj_id=$(echo $line | awk '{print $1}')
  git rev-list --all --objects | grep $obj_id
done < largest_objects.txt > large_files.txt

echo "Large files found:"
cat large_files.txt

# Step 3: Remove large files from git history
echo "Removing large files from git history..."
while read -r file_line; do
  file_path=$(echo $file_line | awk '{print $2}')
  if [ -n "$file_path" ]; then
    echo "Removing $file_path from history..."
    git filter-repo --path "$file_path" --invert-paths --force
  fi
done < large_files.txt

echo "Cleanup complete!"

echo "If you want to re-add your images tracked by LFS, run:"
echo "  brew install git-lfs"
echo "  git lfs install"
echo "  git lfs track \"*.jpg\" \"*.png\" \"*.jpeg\" \"*.gif\" \"*.psd\""
echo "  git add .gitattributes"
echo "  git add assets/images/"
echo "  git commit -m 'Re-add images tracked by LFS'"
echo "  git push origin main --force"
