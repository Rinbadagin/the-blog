#!bash
DOCKER_TAG='the-blog-main'
docker build --tag $DOCKER_TAG .
docker run -p 3000:3000 --mount type=bind,src=./storage,dst=/app/storage $DOCKER_TAG