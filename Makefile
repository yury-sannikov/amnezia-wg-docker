awg-arm7:
	cd amnezia-wg; make clean; GOOS=linux GOARCH=arm GOARM=7 make; cd ..
awg-mips:
	cd amnezia-wg; make clean; GOOS=linux GOARCH=mipsle GOMIPS=softfloat make; cd ..

build-arm7: awg-arm7
	DOCKER_BUILDKIT=1  docker buildx build --no-cache --platform linux/arm/v7 --output=type=docker --tag docker-awg:latest .

export-arm7: build-arm7
	docker save docker-awg:latest > docker-awg-arm7.tar

