REPO=nicholasjackson/minecraft-prod
VERSION=0.1.0

build:
	cp -rf ../config ./config
	cp -rf ../mods ./mods
	cp -rf ../world ./world

	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name minecraft || true
	docker buildx use minecraft
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/amd64 \
		-t ${REPO}:${VERSION} \
	  . \
		--push
