#!/bin/bash

if [[ $(git status -s) ]]
then
    echo "Working directory is dirty, please commit."
    exit 1;
fi

echo "Fetching gh-pages into ./public/"
git worktree add -B gh-pages public origin/gh-pages

echo "Clearing old files"
mkdir public
rm -rf public/*

source bin/build.sh

echo "Publishing..."
cd public && git add . && git commit -m "Publishing new version of the blog" && git push && cd ..

echo "Deleting publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktree/public
