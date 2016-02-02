package = "cache"
version = "1.1.0-1"
source = {
    url = "git://github.com/mah0x211/lua-cache.git",
    tag = "v1.1.0"
}
description = {
    summary = "pluggable cache storage module",
    homepage = "https://github.com/mah0x211/lua-cache", 
    license = "MIT/X11",
    maintainer = "Masatoshi Teruya"
}
dependencies = {
    "lua >= 5.1",
    "util >= 1.2.0",
    "halo >= 1.1"
}
build = {
    type = "builtin",
    modules = {
        cache = "cache.lua",
        ['cache.inmem'] = "lib/inmem.lua"
    }
}

