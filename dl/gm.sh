#!/bin/bash

# ./gm.sh develop uat
# ./gm.sh uat production

# ตรวจสอบจำนวน argument
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source_branch> <target_branch>"
  echo "Example: $0 develop uat"
  exit 1
fi

SOURCE_BRANCH=$1
TARGET_BRANCH=$2

set -e  # ถ้ามี error ให้ script หยุดทันที

echo "🔄 Start merging $SOURCE_BRANCH => $TARGET_BRANCH"

# ตรวจสอบว่าอยู่ใน git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "❌ This directory is not a git repository"
  exit 1
fi

# checkout ไปที่ target branch (uat)
echo "➡️  Checkout to $TARGET_BRANCH"
git checkout $TARGET_BRANCH 2>/dev/null || git switch $TARGET_BRANCH

# pull branch ปลายทางให้ล่าสุด
echo "⬇️  Pull latest $TARGET_BRANCH from origin"
git pull origin $TARGET_BRANCH

# merge source branch (develop)
echo "🔀 Merge $SOURCE_BRANCH into $TARGET_BRANCH"
git merge $SOURCE_BRANCH

# push ขึ้น remote
echo "⬆️  Push $TARGET_BRANCH to origin"
git push origin $TARGET_BRANCH

echo "✅ Merge completed: $SOURCE_BRANCH => $TARGET_BRANCH"
