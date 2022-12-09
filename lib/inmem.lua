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
local time = os.time
local pairs = pairs
local new_minheap = require('minheap').new
local new_cache = require('cache').new
-- constants
local ERELEASE = 'failed to release cached key'

--- @class cache.inmem
local InMem = {}

--- init
---@param ttl? integer
---@return cache? c
---@return any err
function InMem:init(ttl)
    self.data = {}
    self.heap = new_minheap()
    return new_cache(self, ttl)
end

--- set
--- @param key string
--- @param val string
--- @param ttl integer
--- @return boolean ok
--- @return any err
function InMem:set(key, val, ttl)
    local item = self.data[key]
    local exp = time() + ttl

    -- replace old item with new item
    self.data[key] = {
        exp = exp,
        val = val,
        node = assert(self.heap:push(exp, key), 'failed to hold new cache key'),
    }
    if item then
        -- evict old item
        assert(self.heap:del(item.node.idx), ERELEASE)
    end

    return true
end

--- get
--- @param key string
--- @param ttl integer
--- @return string? val
--- @return any err
--- @return boolean? timeout
function InMem:get(key, ttl)
    local item = self.data[key]

    -- not defined
    if not item then
        return nil
    elseif item.exp <= time() then
        -- delete expired item
        self.data[key] = nil
        assert(self.heap:del(item.node.idx), ERELEASE)
        return nil
    elseif ttl ~= nil then
        -- update ttl
        item.exp = time() + ttl
    end

    return item.val
end

--- delete
--- @param key string
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function InMem:delete(key)
    local item = self.data[key]
    if item then
        self.data[key] = nil
        assert(self.heap:del(item.node.idx), ERELEASE)
        return true
    end
    return false
end

--- rename
--- @param oldkey string
--- @param newkey string
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function InMem:rename(oldkey, newkey)
    local item = self.data[oldkey]
    if item then
        self.data[newkey], self.data[oldkey] = item, nil
        return true
    end
    return false
end

--- keys
--- @param callback fun(string):(boolean,any)
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function InMem:keys(callback)
    for k in pairs(self.data) do
        local ok, err = callback(k)
        if not ok then
            if err ~= nil then
                return false, err
            end
            return true
        end
    end
    return true
end

--- evict
--- @param callback fun(string):(boolean,any)
--- @param n integer
--- @return integer nevict
--- @return any err
--- @return boolean? timeout
function InMem:evict(callback, n)
    local nevict = 0
    local t = time()
    local node = self.heap:peek()

    while n ~= 0 and node do
        local key = node.val
        local item = self.data[key]
        if not item then
            -- remove index
            assert(self.heap:del(node.idx), ERELEASE)
        elseif item.exp <= t then
            local ok, err = callback(key)
            if not ok then
                if err ~= nil then
                    return nevict, err
                end
                return nevict
            end

            -- remove expired key and index
            self.data[key] = nil
            assert(self.heap:del(node.idx), ERELEASE)
            nevict = nevict + 1
        else
            return nevict
        end

        n = n - 1
        node = self.heap:peek()
    end

    return nevict
end

return {
    new = require('metamodule').new(InMem),
}
