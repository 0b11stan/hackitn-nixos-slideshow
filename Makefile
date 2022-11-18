PORT=8000
CTRNAME=revealjs

# change with docker if needed
CTRTECH=podman

all: build clean run

build:
	$(CTRTECH) build -t $(CTRNAME) .

run:
	$(CTRTECH) run \
		--name $(CTRNAME) \
		--publish $(PORT):$(PORT) \
		--env PORT=$(PORT) \
		--volume "$(PWD)/dist/:/root/reveal.js/dist/custom/:ro" \
		$(CTRNAME)

shell:
	$(CTRTECH) exec -it $(CTRNAME) /bin/sh

clean:
	-$(CTRTECH) stop $(CTRNAME)
	-$(CTRTECH) rm $(CTRNAME)
