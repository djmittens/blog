#!/bin/sh

echo "Generating site"
#hugo --theme=hugo_theme_robust --buildDrafts
docker run --rm --name "hugo" -P \
       -u $(id -u):$(id -g)\
       -e HUGO_THEME="hugo_theme_robust" \
       -e HUGO_DESTINATION="/output" \
       -v $(pwd):/src  \
       -v $(pwd)/public:/output \
       jojomi/hugo

echo "Fixing permissions(Ugh, those guys really need a better setup)"
chown -R $(id -u):$(id -g) public
