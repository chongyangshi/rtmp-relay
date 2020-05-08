SVC := rtmp-relay
COMMIT := $(shell git log -1 --pretty='%h')
PUBLIC_REPOSITIORY = icydoge/web

.PHONY: pull build push

all: pull build push clean
debug: pull build push-debug

build:
	docker build -t ${SVC} .

pull:
	docker pull golang:alpine

push:
	docker tag ${SVC}:latest ${PUBLIC_REPOSITIORY}:${SVC}
	docker tag ${SVC}:latest ${PUBLIC_REPOSITIORY}:${SVC}-${COMMIT}
	docker push ${PUBLIC_REPOSITIORY}:${SVC}
	docker push ${PUBLIC_REPOSITIORY}:${SVC}-${COMMIT}

push-debug:
	docker tag ${SVC}:latest ${PUBLIC_REPOSITIORY}:${SVC}-${COMMIT}-debug
	docker push ${PUBLIC_REPOSITIORY}:${SVC}-${COMMIT}-debug

clean:
	docker image prune -f
