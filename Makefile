awg-arm7:
	cd amnezia-wg; GOOS=linux GOARCH=arm GOARM=7 make; cd ..

microtic-arm7: awg-arm7
	DOCKER_BUILDKIT=1  docker buildx build --platform linux/arm/v7 --output=type=docker --tag microtic-awg:latest .

export-arm7:
	docker save microtic-awg:latest > microtic-awg-arm7.tar

