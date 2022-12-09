require('luacov')
local testcase = require('testcase')
local new_cache = require('cache').new

function testcase.new()
    local fn = function()
    end
    local store = {
        set = fn,
        get = fn,
        delete = fn,
        rename = fn,
        keys = fn,
        evict = fn,
    }

    -- test that returns an instance of cache
    local c = assert(new_cache(store, 10))
    assert.match(c, '^cache: ', false)

    -- test that throws an error if store is invalid
    local err = assert.throws(new_cache, 0)
    assert.match(err, 'store must be table or userdata')

    err = assert.throws(new_cache, {}, 1)
    assert.match(err, 'store must be implemented the "set" method')

    -- test that throws an error if ttl is invalid
    err = assert.throws(new_cache, store, 0)
    assert.match(err, 'ttl must be positive-integer')
end

