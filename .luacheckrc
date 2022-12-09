std = 'max'
include_files = {
    'cache.lua',
    'lib/***.lua',
    'test/*_test.lua',
}
ignore = {
    'assert',
    -- unused argument
    '212',
    -- line is too long.
    '631',
}
