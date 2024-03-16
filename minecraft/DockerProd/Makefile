REPO=nicholasjackson/minecraft-prod
VERSION=0.1.1

build:
# Copy the config, mods and world directories
	cp -rf ../config ./config
	cp -rf ../mods ./mods
	cp -rf ../world ./world

# Build the docker image
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t ${REPO}:${VERSION} \
	  . \
		--push

# Remove the config, mods and world directories
	rm -rf ./config
	rm -rf ./mods
	rm -rf ./world