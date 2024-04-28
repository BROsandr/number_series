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

BUILD_TYPE?=debugoptimized
ifeq (${BUILD_TYPE},debugoptimized)
  CC_DEBUG_FLAGS+=-D_FORTIFY_SOURCE=1
else ifeq (${BUILD_TYPE},debug)
else
  $(error unknown BUILD_TYPE=${BUILD_TYPE})
endif

MESON_DEBUG_FLAGS?=$(addprefix -D,\
		cpp_debugstl=true            \
		b_ndebug=false               \
		b_sanitize=address,undefined \
)	-Dcpp_args="${CC_DEBUG_FLAGS}"

BUILD_DIR?=${PWD}/build
MESON_EXTRA_CONFIGURE_FLAGS?=
MESON_BUILD_FLAGS?=
out?=${BUILD_DIR}
PROGRAM_NAME:=number_series

default: clean configure build

CONFIGURE_TIMESTAMP:=${BUILD_DIR}/.configure.timestamp

CONFIGURE_CMD:=meson setup "${BUILD_DIR}" --buildtype "${BUILD_TYPE}" ${MESON_DEBUG_FLAGS} ${MESON_EXTRA_CONFIGURE_FLAGS}
${CONFIGURE_TIMESTAMP}:
	mkdir -p "${BUILD_DIR}"
	${CONFIGURE_CMD}
	touch "${@}"

configure: clean ${CONFIGURE_TIMESTAMP}

BUILD_CMD:=meson compile -C "${BUILD_DIR}" ${MESON_BUILD_FLAGS}
build: ${CONFIGURE_TIMESTAMP}
  ifdef ANALYZE
	  scan-build ${BUILD_CMD}
  else
	  ${BUILD_CMD}
  endif

install: build
	mkdir -p "${out}/bin"
	cp "${BUILD_DIR}/${PROGRAM_NAME}" "${out}/bin"

clean:
	rm -rf "${BUILD_DIR}"

.PHONY: default clean build configure install
