#!/bin/bash
cd "D:/solidity-github-2.0"

# Remove stale lock file
if [ -f ".git/index.lock" ]; then
    echo "Removing stale lock file..."
    rm -f ".git/index.lock"
fi

# ✅ Add here — Remove any nested .git folders
find . -mindepth 2 -name ".git" -type d | while read nested; do
    echo "Removing nested git: $nested"
    rm -rf "$nested"
done

git add .

msg="Auto update $(date)"

git -c user.name="yashu780" -c user.email="sharmayashu740@gmail.com" \
commit -m "$msg" || {
    echo "[$(date)] Nothing to commit" >> git_log.txt
    read -p "Press any key to continue..."
    exit 0
}

git pull origin main --rebase
if [ $? -ne 0 ]; then
    echo "[$(date)] Pull failed" >> git_log.txt
    read -p "Press any key to continue..."
    exit 1
fi

git push origin main
if [ $? -ne 0 ]; then
    echo "[$(date)] Push failed" >> git_log.txt
    read -p "Press any key to continue..."
    exit 1
fi

echo "[$(date)] Auto push successful" >> git_log.txt
read -p "Press any key to continue..."