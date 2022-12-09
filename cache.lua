--
-- Copyright (C) 2014-2022 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
local floor = math.floor
local find = string.find
local format = string.format
local type = type
local getmetatable = debug.getmetatable
local encode = require('yyjson').encode
local decode = require('yyjson').decode
-- constants
local INF_POS = math.huge
local INF_NEG = -INF_POS
local KEY_PATTERN = '^[a-zA-Z0-9_%-]+$'
local EKEY = format('key must be string of %q', KEY_PATTERN)
local EVAL = 'val must not be nil'

--- is_callable
--- @return boolean ok
local function is_callable(v)
    if type(v) == 'function' then
        return true
    end

    local mt = getmetatable(v)
    if type(mt) == 'table' then
        return type(mt.__call) == 'function'
    end

    return false
end

--- is_int
--- @param x any
--- @return boolean
local function is_int(x)
    return type(x) == 'number' and x > INF_NEG and x < INF_POS and floor(x) == x
end

--- is_pint
--- @param x any
--- @return boolean
local function is_pint(x)
    return is_int(x) and x > 0
end

--- is_uint
--- @param x any
--- @return boolean
local function is_uint(x)
    return is_int(x) and x >= 0
end

--- is_valid_key
--- @param key string
--- @return boolean
local function is_valid_key(key)
    return type(key) == 'string' and find(key, KEY_PATTERN) ~= nil
end

--- @class cache
--- @field store cache.store
--- @field ttl integer
local Cache = {}

--- init
--- @param store cache.store
--- @param ttl integer
--- @return cache
function Cache:init(store, ttl)
    local t = type(store)
    if t ~= 'table' and t ~= 'userdata' then
        error('store must be table or userdata', 2)
    end

    -- cache store must be implemented the following methods
    local ok, err = pcall(function()
        for _, fname in ipairs({
            'set',
            'get',
            'delete',
            'rename',
            'keys',
            'evict',
        }) do
            if type(store[fname]) ~= 'function' then
                error(format('store must be implemented the %q method', fname))
            end
        end
    end)
    if not ok then
        error(err, 2)
    end
    self.store = store

    if not is_pint(ttl) then
        error('ttl must be positive-integer', 2)
    end
    self.ttl = ttl

    return self
end

--- set
--- @param key string
--- @param val any
--- @param ttl integer
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Cache:set(key, val, ttl)
    if not is_valid_key(key) then
        error(EKEY, 2)
    elseif val == nil then
        error(EVAL, 2)
    elseif ttl == nil then
        ttl = self.ttl
    elseif not is_uint(ttl) then
        error('ttl must be uint', 2)
    end

    local err
    val, err = encode(val)
    if not val then
        return false, err
    end

    return self.store:set(key, val, ttl)
end

--- get
--- @param key string
--- @param ttl integer
--- @return any val
--- @return any err
--- @return boolean? timeout
function Cache:get(key, ttl)
    if not is_valid_key(key) then
        error(EKEY, 2)
    elseif ttl ~= nil and not is_uint(ttl) then
        error('ttl must be uint', 2)
    end

    local val, err, timeout = self.store:get(key, ttl)
    if not val then
        return nil, err, timeout
    end

    val, err = decode(val)
    if not val then
        return nil, err
    end
    return val
end

--- delete
--- @param key string
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Cache:delete(key)
    if not is_valid_key(key) then
        error(EKEY, 2)
    end
    return self.store:delete(key)
end

--- rename
---@param oldkey string
---@param newkey string
---@return boolean ok
---@return any err
---@return boolean? timeout
function Cache:rename(oldkey, newkey)
    if not is_valid_key(oldkey) or not is_valid_key(newkey) then
        error(EKEY, 2)
    end
    return self.store:rename(oldkey, newkey)
end

--- keys
--- @param callback fun(string):(boolean,any)
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Cache:keys(callback)
    if not is_callable(callback) then
        error('callback must be callable', 2)
    end
    return self.store:keys(callback)
end

--- evict
--- @param callback fun(string):(boolean,any)
--- @param n integer
--- @return integer nevict
--- @return any err
--- @return boolean? timeout
function Cache:evict(callback, n)
    if not is_callable(callback) then
        error('callback must be callable', 2)
    elseif n ~= nil and not is_int(n) then
        error('n must be integer', 2)
    elseif n == nil or n == 0 then
        n = -1
    end
    return self.store:evict(callback, n)
end

return {
    new = require('metamodule').new(Cache),
}
