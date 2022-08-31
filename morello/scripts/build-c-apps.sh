#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

c_apps_clean() {
	rm -fr ${EXAMPLES_BIN}
}

c_apps_build() {
	# Create examples/bin
	mkdir -p ${EXAMPLES_BIN}

	# Build test-app
	cd ${MORELLO_AARCH64_HOME}/examples/test-app
	make

	# Build morello-heap-app
	cd ${MORELLO_AARCH64_HOME}/examples/morello-heap-app
	make

	# Build morello-stack-app
	cd ${MORELLO_AARCH64_HOME}/examples/morello-stack-app
	make

	# Build morello-pthread-app
	cd ${MORELLO_AARCH64_HOME}/examples/morello-pthread-app
	make

	# Build morello-auxv-app
	cd ${MORELLO_AARCH64_HOME}/examples/morello-auxv-app
	make

	# Return in $MORELLO_AARCH64_HOME
	cd ${MORELLO_AARCH64_HOME}
}

c_apps_build $@
