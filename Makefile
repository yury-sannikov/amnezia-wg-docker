awg-arm7:
	cd amnezia-wg; GOOS=linux GOARCH=arm GOARM=7 make; cd ..
awg-mips:
	cd amnezia-wg; GOOS=linux GOARCH=mipsle GOMIPS=softfloat make; cd ..

microtik-arm7: awg-arm7
	DOCKER_BUILDKIT=1  docker buildx build --platform linux/arm/v7 --output=type=docker --tag microtik-awg:latest .

export-arm7:
	docker save microtik-awg:latest > microtik-awg-arm7.tar

