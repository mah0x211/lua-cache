rockspec_format = "3.0"
package = "cache"
version = "scm-1"
source = {
    url = "git+https://github.com/mah0x211/lua-cache.git",
}
description = {
    summary = "pluggable cache storage module",
    homepage = "https://github.com/mah0x211/lua-cache",
    license = "MIT/X11",
    maintainer = "Masatoshi Fukunaga",
}
dependencies = {
    "lua >= 5.1",
    "metamodule >= 0.4",
}
build = {
    type = "builtin",
    modules = {
        cache = "cache.lua",
    },
}

