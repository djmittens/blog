#!/bin/sh

docker run --rm -ti --name "hugo" \
       -u $(id -u):$(id -g)\
       -e HUGO_THEME="hugo_theme_robust" \
       -e HUGO_WATCH="true" \
       -e HUGO_BASEURL="localhost:1313/" \
       -e HUGO_REFRESH_TIME="10" \
       -p 1313:1313 \
       -v /$(pwd)/:/src  \
       -v /$(pwd)/public:/output \
       jojomi/hugo
