# Versions and sources
OMT_GH_REPO := openmaptiles/openmaptiles
OMT_BRANCH := master
OMT_TOOLS_VERSION := 7.0.0

# Ensure we have all the tools available
EXECUTABLES = id pwd git docker rsync
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

WORKDIR ?= $$( pwd -P )

GIT := $$(which git)
DOCKER_OPTS  ?= -i --rm -u $$(id -u $${USER}):$$(id -g $${USER})
RUN_CMD := docker run ${DOCKER_OPTS} -v "$(WORKDIR):/workdir"


.PHONY: clean
clean:
	rm -rf openmaptiles

openmaptiles: # Clone the openmaptiles repository locally
	${GIT} clone https://github.com/${OMT_GH_REPO}.git \
		--branch ${OMT_BRANCH} \
		--single-branch \
		--depth 1 \
		openmaptiles

.PHONY: split
split: openmaptiles # Split the current style into the layer folders
	${RUN_CMD} \
		openmaptiles/openmaptiles-tools:${OMT_TOOLS_VERSION} \
			style-tools split \
				/workdir/openmaptiles/openmaptiles.yaml \
				/workdir/style.json
	rsync -rv --include="*/" --include="style.json" --exclude="*" \
		openmaptiles/layers/ layers/
	rm -rf openmaptiles

style.json: openmaptiles# Merges the layer from each OMT folder into a final style
	rsync -rv --include="*/" --include="style.json" --exclude="*" \
		layers/ openmaptiles/layers/
	${RUN_CMD} \
		openmaptiles/openmaptiles-tools:${OMT_TOOLS_VERSION} \
			style-tools merge \
				/workdir/openmaptiles/openmaptiles.yaml \
				/workdir/style.json \
				/workdir/style-header.json
	rm -rf openmaptiles
