# WEBSITE_PORT = 8000
#
# WEBSITE_SSH_USER = username
# WEBSITE_SSH_SERVER = example.org
# WEBSITE_DEST = /srv/http/example
#
# or ...
#
.include <env.mk>

BIN = ./bin
DIST = ./dist

.ifndef WEBSITE_DEST
.error "WEBSITE_DEST command is not defined. Hej då."
.endif

build: mustache
	@printf "%s" ${WEBSITE_S3BUCKET} > templates/s3bucket.mustache
	${BIN}/build

start: build deps
	httpserver --port ${WEBSITE_PORT} --dir ${DIST}

mustache:
	go build -o mustache mustache.go

deps:
	DEST=assets/lib ${BIN}/deps

sync:
	rsync -OPrv \
		--checksum \
		--copy-links \
		--delete-before \
		${DIST}/ \
		${WEBSITE_SSH_USER}@${WEBSITE_HOST}:${WEBSITE_DEST}

deploy: build sync

.PHONY: build deps
