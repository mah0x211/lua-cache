--[[
  
  Copyright (C) 2014 Masatoshi Teruya

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  
  cache.lua
  lua-cache
  
  Created by Masatoshi Teruya on 14/11/07.
  
--]]

-- modules
local typeof = require('util').typeof;
local KEYTYPE = {
    ['string']  = true
};
local VALTYPE = {
    ['boolean'] = true,
    ['string']  = true,
    ['table']   = true,
    ['number']  = typeof.finite,
};
local EKEYTYPE = 'key must be string';
local EVALTYPE = '%q must be boolean, string, table or finite number';
local EEXPTYPE = 'expires must be finite number'
local ERETTYPE = 'store returned an invalid value';
-- if expire <= 0 then forever
local DEFAULT_EXPIRES = 3600


-- class
local Cache = require('halo').class.Cache;

function Cache:init( store, expires )
    local own = protected( self );
    
    if expires ~= nil and not typeof.finite( expires ) then
        return nil, EEXPTYPE;
    -- cache storage should implement get, set and delete method
    elseif not typeof.table( store ) or 
           not typeof.Function( store.get ) or 
           not typeof.Function( store.set ) or 
           not typeof.Function( store.delete ) then
        return nil, 'store should implement get, set and delete method';
    end
    
    own.expires = expires or DEFAULT_EXPIRES;
    own.store = store;
    
    return self;
end


function Cache:get( key, defval )
    local own = protected( self );
    local val, err;
    
    if defval ~= nil and not typeof.table( defval ) then
        return nil, 'defval must be table';
    end
    
    val, err = own.store:get( key );
    if err then
        return nil, err;
    elseif val then
        return CacheItem.new( self, key, val, own.expires );
    -- create cache object instance with defval
    elseif defval then
        return CacheItem.new( self, key, defval, own.expires );
    end
    
    return nil;
end


function Cache:set( key, val, expires )
    local own = protected( self );
    local t = VALTYPE[type(val)];
    
    if expires ~= nil and not typeof.finite( expires ) then
        return false, EEXPTYPE;
    elseif not KEYTYPE[type(key)] then
        return false, EKEYTYPE;
    elseif t == true or t and t( val ) then
        -- boolean, err
        return own.store:set( key, val, expires or own.expires );
    end
    
    return false, EVALTYPE:format( 'val' );
end


function Cache:delete( key )
    if not KEYTYPE[type(key)] then
        return false, EKEYTYPE;
    end
    
    -- boolean, err
    return protected( self ).store:delete( key );
end


return Cache.exports;
