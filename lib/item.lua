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
  
  lib/item.lua
  lua-cache
  
  Created by Masatoshi Teruya on 14/11/07.
  
--]]

-- modules
local typeof = require('util').typeof;
-- if expire <= 0 then forever
local DEFAULT_EXPIRES = 3600;
local VALID_VAL_TYPE = {
    ['boolean'] = true,
    ['string'] = true,
    ['table'] = true,
    ['number'] = typeof.finite
};

-- class
local Item = require('halo').class.Item;

function Item:__index( name )
    if name == 'data' then
        local own = protected( self );
        local tbl = own.tbl;
        
        return setmetatable( {}, {
            __index = function( _, key, val )
                return tbl[key];
            end,
            __newindex = function( _, key, val )
                if not typeof.string( key ) then
                    error( 'key must be string', 2 );
                elseif val ~= nil then
                    local t = VALID_VAL_TYPE[type(val)];
                    
                    if not t or not t( val ) then
                        error( 'val must be boolean, string, finite number, table or nil', 2 );
                    end
                end
                
                tbl[key] = val;
            end
        });
    end
    
    return nil;
end


-- cache: instance of Cache class
function Item:init( delegate, key, tbl, expires )
    local own = protected( self );
    
    -- cache should implement save and delete method
    if not typeof.table( delegate ) or 
       not typeof.Function( delegate.set ) or
       not typeof.Function( delegate.delete ) then
        return nil, 'delegate should implement save and delete method';
    elseif not typeof.string( key ) then
        return nil, 'key must be string';
    elseif expires ~= nil and not typeof.finite( expires ) then
        return nil, 'expires must be finite number';
    elseif tbl == nil then
        tbl = {};
    elseif not typeof.table( tbl ) then
        return nil, 'tbl must be table';
    end
    
    own.delegate = delegate;
    own.key = key;
    own.expires = expires or DEFAULT_EXPIRES;
    own.tbl = tbl;
    
    return self;
end


function Item:save()
    local own = protected( self );
    
    return own.delegate:set( own.key, own.tbl, own.expires );
end


function Item:delete()
    local own = protected( self );
    
    return own.delegate:delete( own.key );
end


return Item.exports;
