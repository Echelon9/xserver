srcs_dri3 = [
	'dri3.c',
	'dri3_request.c',
	'dri3_screen.c',
]

libxserver_dri3 = []
if build_dri3
    libxserver_dri3 = static_library('libxserver_dri3',
        srcs_dri3,
        include_directories: inc,
        dependencies: common_dep,
        c_args: '-DHAVE_XORG_CONFIG_H'
        )
endif
