---
title: Docker + Capistrano + Rails Errors! "The asset "application.css" is not present in the asset pipeline"
date: 2017-06-05
tags:
---

Upon getting my Docker application running in production, I ran into this error message:

```
F, [2017-06-06T00:53:06.630911 #1] FATAL -- : [8957e40e-e8fa-4f2d-8072-4dab83c6269b] ActionView::Template::Error (The asset "application.css" is not present in the asset pipeline.):
```

The problem occurred because the Rails asset pipeline was missing files. The application in production mode couldn't find
the files it was looking for from the `rake assets:precompile` stage, which was performed by Capistrano _outside_ of the
Docker container. To fix this error I had to symlink the `public/assets` folder inside of the Docker container to
the file system outside like this:

```
#docker-compose.yml

version: '3'
services:
  web:
    container_name: myapp
    build: .
    command: bundle exec rails s -p 3000
    environment:
      - RAILS_ENV=${RAILS_ENV:-development}
      - DATABASE_URL=${DATABASE_URL}
      - RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES}
      - SECRET_KEY_BASE=${SECRET_KEY_BASE}
    extra_hosts:
      - dbhost:${LOCAL_IP:-127.0.0.1}
    ports:
      - ${HTTP_PORT:-80}:3000
    tty: true
    volumes:
      - ./log:/app/log
      - ./public/assets:/app/public/assets
```

Note that on the `volumes` section I link both the `log` and `public` assets folder. 