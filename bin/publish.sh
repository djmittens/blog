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

echo "Generating site"
#hugo --theme=hugo_theme_robust --buildDrafts
docker run --rm --name "hugo" -P \
       -e HUGO_THEME="hugo_theme_robust" \
       -e HUGO_DESTINATION="/output" \
       -v $(pwd):/src  \
       -v $(pwd)/public:/output \
       jojomi/hugo

echo "Fixing permissions(Ugh, those guys really need a better setup)"
sudo chown -R $(id -u):$(id -g) public

echo "Publishing..."
cd public && git add . && git commit -m "Publishing new version of the blog" && git push && cd ..

echo "Deleting publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktree/public
