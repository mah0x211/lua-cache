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
local time = os.time
local type = type
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
--- @field data table
--- @field ttl integer
local Cache = {}

--- init
--- @return cache
function Cache:init(ttl)
    if not is_pint(ttl) then
        error('ttl must be positive-integer', 2)
    end

    self.data = {}
    self.ttl = ttl
    return self
end

--- set_item
--- @param key string
--- @param val any
--- @param ttl integer
--- @return boolean ok
--- @return any err
function Cache:set_item(key, val, ttl)
    self.data[key] = {
        val = val,
        ttl = ttl or self.ttl,
        exp = (ttl or self.ttl) + time(),
    }
    return true
end

--- set
--- @param key string
--- @param val any
--- @param ttl integer
--- @return boolean ok
--- @return any err
function Cache:set(key, val, ttl)
    if not is_valid_key(key) then
        error(EKEY, 2)
    elseif val == nil then
        error(EVAL, 2)
    elseif ttl ~= nil and not is_uint(ttl) then
        error('ttl must be uint', 2)
    end
    return self:set_item(key, val, ttl)
end

--- get_item
--- @param key string
--- @param touch boolean
--- @return any val
--- @return any err
function Cache:get_item(key, touch)
    local item = self.data[key]
    if not item then
        return nil
    elseif item.exp then
        local t = time()
        if item.exp <= t then
            self.data[key] = nil
            return nil
        elseif touch then
            item.exp = t + item.ttl
        end
    end

    return item.val
end

--- get
--- @param key string
--- @param touch boolean
--- @return any val
--- @return any err
function Cache:get(key, touch)
    if not is_valid_key(key) then
        error(EKEY, 2)
    elseif touch ~= nil and type(touch) ~= 'boolean' then
        error('touch must be boolean', 2)
    end
    return self:get_item(key, touch)
end

--- del_item
--- @param key string
--- @return boolean ok
--- @return any err
function Cache:del_item(key)
    if self.data[key] ~= nil then
        self.data[key] = nil
        return true
    end
    return false
end

--- del
--- @param key string
--- @return boolean ok
--- @return any err
function Cache:del(key)
    if not is_valid_key(key) then
        error(EKEY, 2)
    end
    return self:del_item(key)
end

--- rename_item
--- @param oldkey string
--- @param newkey string
--- @return boolean ok
--- @return any err
function Cache:rename_item(oldkey, newkey)
    local item = self.data[oldkey]
    if item then
        self.data[newkey], self.data[oldkey] = item, nil
        return true
    end
    return false
end

--- rename
---@param oldkey string
---@param newkey string
---@return boolean ok
---@return any err
function Cache:rename(oldkey, newkey)
    if not is_valid_key(oldkey) or not is_valid_key(newkey) then
        error(EKEY, 2)
    end
    return self:rename_item(oldkey, newkey)
end

Cache = require('metamodule').new(Cache)
return Cache
