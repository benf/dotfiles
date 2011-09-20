doecho() {
	echo $@
	eval $@
}

home=~ben

if [ $(hostname) = "blx" ]; then
doecho export prefix=$home/.local
else
doecho export prefix=$home/dist
fi

doecho export 'ACLOCAL="aclocal -I '$prefix'/share/aclocal"'

doecho export LD_LIBRARY_PATH="$prefix/lib"
doecho export PKG_CONFIG_PATH=$LD_LIBRARY_PATH/pkgconfig
#doecho export C_INCLUDE_PATH="$prefix/include"

doecho export EGL_DRIVER=egl_dri2
#doecho export EGL_DRIVER=egl_gallium

doecho export EGL_LOG_LEVEL=debug
#doecho export EGL_PLATFORM=wayland

if [ "x$XDG_RUNTIME_DIR" = "x" ]; then
	doecho export XDG_RUNTIME_DIR=$home/src
fi
doecho export SDL_VIDEODRIVER=wayland
