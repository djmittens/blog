#!/bin/sh

docker run --rm --name "hugo" -P \
       -u $(id -u):$(id -g)\
       -e HUGO_THEME="hugo_theme_robust" \
       -e HUGO_WATCH="true" \
       -e HUGO_REFRESH_TIME="10" \
       -v /$(pwd)/:/src  \
       -v /$(pwd)/public:/output \
       jojomi/hugo
