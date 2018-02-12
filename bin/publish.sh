#!/bin/bash

if [[ $(git status -s) ]]
then
echo "Working directory is dirty, please commit."
exit 1;
fi

echo "Fetching gh-pages into ./public/"
git worktree add -B gh-pages public origin/gh-pages

echo "Clearing old files"
rm -rf public/*

echo "Generating site"
hugo --theme=hugo_theme_robust --buildDrafts

echo "Publishing..."
cd public && git commit -am "Publishing new version of the blog" && git push && cd ..

echo "Deleting publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktree/public
