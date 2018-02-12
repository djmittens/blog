#!/bin/sh
hugo --theme=hugo_theme_robust --buildDrafts
cd public && git commit -am "Publishing new version of the blog" && git push && cd ..
