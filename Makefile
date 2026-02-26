ID := $(shell id -u)
GID := $(shell id -g)
ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
  DOCKER_PLATFORM := --platform linux/amd64
else
  DOCKER_PLATFORM :=
endif

default: docker/builder docker/runbuilder docker/build phog/computer-debian
dockerbuild: docker/builder docker/build
computer: phog/computer-debian
exec: docker/exec
start: v86/run

docker/builder: 
	-docker stop builder-alpine-3.14
	-docker rm server-new
	cd vendor/github.com/copy/v86/tools/docker/test-image && docker build $(DOCKER_PLATFORM) --no-cache -t builder\:alpine-3.14 .

docker/runbuilder:
	-docker stop builder-alpine-3.14
	-docker rm -f builder-alpine-3.14 || sleep 3
	docker run $(DOCKER_PLATFORM) -d -w=/v86 --name builder-alpine-3.14 --rm  \
	  -v "$(PWD)/vendor/github.com/copy/v86:/v86" -v "$(PWD)/computer:/v86/computer" \
	  -v "$(PWD)/src/browser/main.js:/v86/src/browser/main.js" \
	  -v "$(PWD)/copy/v86/index.html:/v86/index.html" \
	  -p 8000:8000 \
	  builder:alpine-3.14 \
	  sh -c "rm /v86/done; chown -R $(ID):$(GID) /root;chown -R $(ID):$(GID) .; \
	  mkdir /.rustup; chown -R $(ID):$(GID) /.rustup; touch /v86/done;  make run; sleep 10000"

docker/build: 
	-cd vendor/github.com/copy/v86 && make build/xterm.js
	-cd vendor/github.com/copy/v86 && \
	echo "************** build all **************" && \
	docker exec -w=/v86 -e \
	  PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin -u \
	  $(ID) "builder-alpine-3.14" \
	  sh -c "while [ ! -f /v86/done ]; do sleep 1;echo -n .; done; make clean; make all" 
	echo "************** build v86-fallback **************" && \
	docker exec -w=/v86 -e \
          PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	  "builder-alpine-3.14" make build/v86-fallback.wasm
	cd vendor/github.com/copy/v86 && \
	echo "************** build v86.wasm **************" && \
	docker exec -w=/v86 -e \
	  PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	  "builder-alpine-3.14" make build/libv86.js && \
	echo "************** build v86.wasm **************" && \
	docker exec -w=/v86 -e \
	  PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	  "builder-alpine-3.14" make build/v86.wasm
	cd vendor/github.com/copy/v86 && \
	tools/docker/exec/build.sh

docker/exec: 
	docker exec -w=/v86 -it -e \
	  PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin -u \
	  $(ID) "builder-alpine-3.14" /bin/bash

phog/rebuild: phog/computer-debian v86/run

phog/computer-debian:
	mkdir -p vendor/github.com/copy/v86/images || true
	cd computer && sh build-container.sh ""

v86/state: 
	docker exec -w=/v86 -it -e \
          PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:. -u \
          $(ID) "builder-alpine-3.14" \
          sh -c "while [ ! -f /v86/done ]; do sleep 1;echo -n .; done; computer/build-state.js" 

v86/run:
	-docker run $(DOCKER_PLATFORM) -d -w=/v86 --name builder-alpine-3.14 --rm  \
	  -v "$(PWD)/vendor/github.com/copy/v86:/v86" -v "$(PWD)/computer:/v86/computer" \
	  -v "$(PWD)/src/browser/main.js:/v86/src/browser/main.js" \
	  -v "$(PWD)/copy/v86/index.html:/v86/index.html" \
	  -p 8000:8000 \
	  builder:alpine-3.14 sh -c "make run; sleep 10000"
	docker cp $(PWD)/computer/phog.html builder-alpine-3.14:/v86/phog.html && \
	docker cp $(PWD)/computer/index.html builder-alpine-3.14:/v86/index.html && \
	docker cp $(PWD)/computer/script.js builder-alpine-3.14:/v86/script.js && echo "open localhost:8000" 
	#docker cp $(PWD)/vendor/github.com/copy/v86/images\:/v86/images 
