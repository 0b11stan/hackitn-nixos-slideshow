PORT=8000
CTRNAME=revealjs

# change with docker if needed
CTRTECH=podman

all: build clean run

build:
	$(CTRTECH) build -t $(CTRNAME) .

run:
	$(CTRTECH) run -it \
		--name $(CTRNAME) \
		--publish $(PORT):8000 \
		--volume "$(PWD)/dist/:/root/reveal.js/dist/custom/:ro" \
		$(CTRNAME) /bin/sh -c 'npm start -- --port=8000 --host=0.0.0.0'

shell:
	$(CTRTECH) exec -it $(CTRNAME) /bin/sh

clean:
	-$(CTRTECH) stop $(CTRNAME)
	-$(CTRTECH) rm $(CTRNAME)
