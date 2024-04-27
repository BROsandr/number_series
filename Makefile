CC_DEBUG_FLAGS?=\
		-Wshadow                  \
		-Wformat=2                \
		-Wfloat-equal             \
		-Wconversion              \
		-Wlogical-op              \
		-Wshift-overflow=2        \
		-Wduplicated-cond         \
		-Wcast-qual               \
		-Wcast-align              \
		-D_GLIBCXX_DEBUG          \
		-D_GLIBCXX_DEBUG_PEDANTIC \
		-fno-sanitize-recover     \
		-fstack-protector         \
		-Wsign-conversion         \
		-Weffc++                  \

MESON_DEBUG_FLAGS?=$(addprefix -D,\
		cpp_debugstl=true            \
		b_ndebug=false               \
		b_sanitize=address,undefined \
)	-Dcpp_args="${CC_DEBUG_FLAGS}"

BUILD_DIR?=${PWD}/build
MESON_EXTRA_CONFIGURE_FLAGS?=
MESON_BUILD_FLAGS?=

all: clean configure build

CONFIGURE_TIMESTAMP:=${BUILD_DIR}/.configure.timestamp

CONFIGURE_CMD:=meson setup "${BUILD_DIR}" ${MESON_DEBUG_FLAGS} ${MESON_EXTRA_CONFIGURE_FLAGS}
${CONFIGURE_TIMESTAMP}:
	mkdir -p "${BUILD_DIR}"
	${CONFIGURE_CMD}
	touch "${@}"

configure: clean ${CONFIGURE_TIMESTAMP}

BUILD_CMD:=meson compile -C "${BUILD_DIR}" ${MESON_BUILD_FLAGS}
build: ${CONFIGURE_TIMESTAMP}
	${BUILD_CMD}

clean:
	rm -rf "${BUILD_DIR}"

.PHONY: all clean build configure
