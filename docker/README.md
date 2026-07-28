# Setup Environment
## preparing docker-compose
```
brew install colima docker docker-compose docker-buildx
````

## Set PATH
```
mkdir -p ~/.docker/cli-plugins

ln -sfn $(brew --prefix)/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ln -sfn $(brew --prefix)/opt/docker-buildx/bin/docker-buildx   ~/.docker/cli-plugins/docker-buildx
```

## Confirm
```
colima list
docker version
docker compose version
docker buildx version
```

## start VM
```
colima start --cpu 4 --memory 8
colima status
```

## docker build
```
docker compose up -d                          # start
docker compose exec foundry forge --version   # confirm
docker compose exec foundry sh                # login
docker compose down                           # stop
```