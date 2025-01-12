require('luacov')
local testcase = require('testcase')
local assert = require('assert')
local sleep = require('testcase.timer').sleep
local new_cache = require('cache.inmem').new

function testcase.new()
    -- test that returns an instance of cache
    assert(new_cache(10))

    -- test that throws an error if ttl is invalid
    local err = assert.throws(new_cache, 0)
    assert.match(err, 'ttl must be positive-integer')
end

function testcase.set()
    local c = assert(new_cache(2))

    -- test that set a value associated with key
    assert(c:set('foo', 'bar'))
    assert.equal(c:get('foo'), 'bar')

    -- test that set a value associated with key and ttl
    assert(c:set('foo', 'world', 1))
    assert.equal(c:get('foo'), 'world')

    -- test that return an error if value is invalid
    local ok, err = c:set('foo', {
        inf = 0 / 0,
    })
    assert.is_false(ok)
    assert.match(err, 'nan or inf number is not allowed')

    -- test that return an error if key is invalid
    ok, err = c:set('foo bar')
    assert.match(err, 'key must be string of "^[a-zA-Z0-9_%-]+$"')
    assert.is_false(ok)

    -- test that throws an error if val is invalid
    ok, err = c:set('foobar')
    assert.match(err, 'val must not be nil')
    assert.is_false(ok)

    -- test that throws an error if ttl is invalid
    ok, err = c:set('foobar', true, {})
    assert.match(err, 'ttl must be uint')
    assert.is_false(ok)
end

function testcase.get()
    local c = assert(new_cache(2))
    assert(c:set('foo', 'hello', 1))
    assert(c:set('bar', 'world'))

    -- test that get a value associated with key
    assert.equal(c:get('foo'), 'hello')

    -- test that get a value associated with key and set the lifetime
    assert.equal(c:get('foo', 1), 'hello')

    -- test that return nil after reached to ttl
    sleep(1)
    assert.is_nil(c:get('foo'))
    assert.equal(c:get('bar'), 'world')
    sleep(1)
    assert.is_nil(c:get('bar'))

    -- test that throws an error if key is invalid
    local val, err = c:get('foo bar')
    assert.match(err, 'key must be string of "^[a-zA-Z0-9_%-]+$"')
    assert.is_nil(val)

    -- test that throws an error if touch is invalid
    val, err = c:get('foobar', {})
    assert.match(err, 'ttl must be uint')
    assert.is_nil(val)
end

function testcase.delete()
    local c = assert(new_cache(2))

    -- test that delete a value associated with key
    assert(c:set('foo', 'bar'))
    assert.equal(c:get('foo'), 'bar')
    assert.is_true(c:delete('foo'))
    assert.is_nil(c:get('foo'))

    -- test that return false if a value associated with key not found
    assert.is_false(c:delete('foo'))

    -- test that throws an error if key is invalid
    local ok, err = c:delete('foo bar')
    assert.match(err, 'key must be string of "^[a-zA-Z0-9_%-]+$"')
    assert.is_false(ok)
end

function testcase.rename()
    local c = assert(new_cache(2))

    -- test that rename an oldkey to newkey
    assert(c:set('foo', 'bar'))
    assert(c:rename('foo', 'newfoo'))
    assert.is_nil(c:get('foo'))
    assert.equal(c:get('newfoo'), 'bar')

    -- test that return false if a value associated with key not found
    assert.is_false(c:rename('foo', 'bar'))

    -- test that throws an error if oldkey is invalid
    local ok, err = c:rename('foo bar')
    assert.match(err, 'key must be string of "^[a-zA-Z0-9_%-]+$"')
    assert.is_false(ok)

    -- test that throws an error if newkey is invalid
    ok, err = c:rename('foo', 'hello world')
    assert.match(err, 'key must be string of "^[a-zA-Z0-9_%-]+$"')
    assert.is_false(ok)
end

function testcase.keys()
    local c = assert(new_cache(2))
    assert(c:set('hello', 'b'))
    assert(c:set('world', 'b'))
    assert(c:set('foo', 'a'))
    assert(c:set('bar', 'b'))
    assert(c:set('baz', 'c'))

    -- test that return true
    local keys = {}
    assert.is_true(c:keys(function(k)
        keys[#keys + 1] = k
        return true
    end))
    table.sort(keys)
    assert.equal(keys, {
        'bar',
        'baz',
        'foo',
        'hello',
        'world',
    })

    -- test that abort by false
    keys = {}
    assert.is_true(c:keys(function(k)
        keys[#keys + 1] = k
        return #keys < 3
    end))
    assert.equal(#keys, 3)

    -- test that abort by error
    keys = {}
    local ok, err = c:keys(function(k)
        keys[#keys + 1] = k
        if #keys < 3 then
            return true
        end
        return false, 'abort by error'
    end)
    assert.match(err, 'abort by error')
    assert.is_false(ok)

    -- test that throws an error if callback argument is invalid
    ok, err = c:keys({})
    assert.match(err, 'callback must be callable')
    assert.is_false(ok)
end

function testcase.evict()
    local c = assert(new_cache(4))

    -- test that evict expired keys
    assert(c:set('foo', 'a', 1))
    assert(c:set('bar', 'b', 2))
    assert(c:set('baz', 'c', 3))
    for i, v in ipairs({
        {
            bar = 'b',
            baz = 'c',
        },
        {
            baz = 'c',
        },
        {},
    }) do
        sleep(1)
        assert.equal(c:evict(function(k)
            if i == 1 then
                assert.equal(k, 'foo')
            elseif i == 2 then
                assert.equal(k, 'bar')
            elseif i == 3 then
                assert.equal(k, 'baz')
            end
            return true
        end), 1)
        assert.equal({
            foo = c:get('foo'),
            bar = c:get('bar'),
            baz = c:get('baz'),
        }, v)
    end

    -- test that abort by false
    assert(c:set('foo', 'a', 1))
    assert(c:set('bar', 'b', 1))
    assert(c:set('baz', 'c', 1))
    sleep(1)
    assert.equal(c:evict(function()
        return false
    end), 0)

    -- test that abort by error
    local nevict, err = c:evict(function()
        return false, 'abort by error'
    end)
    assert.match(err, 'abort by error')
    assert.equal(nevict, 0)

    -- test that throws an error if callback argument is invalid
    nevict, err = c:evict({})
    assert.match(err, 'callback must be callable')
    assert.equal(nevict, 0)

    -- test that throws an error if callback argument is invalid
    nevict, err = c:evict(function()
    end, {})
    assert.match(err, 'n must be integer')
    assert.equal(nevict, 0)
end
