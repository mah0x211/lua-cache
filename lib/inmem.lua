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
 
  lib/inmem.lua
  lua-cache
  
  Created by Masatoshi Teruya on 14/11/07.
  
--]]

-- modules
local clone = require('util.table').clone;
local typeof = require('util').typeof;
local time = os.time;

-- class
local InMem = require('halo').class.InMem;


function InMem:init()
    protected(self).data = {};
    return self;
end


function InMem:set( key, val, expires )
    if not typeof.string( key ) then
        return nil, 'key must be string';
    elseif not typeof.table( val ) then
        return nil, 'val must be table';
    elseif expires == nil then
        expires = 0;
    elseif not typeof.finite( expires ) then
        return nil, 'expires must be finite number';
    end
    
    protected(self).data[key] = {
        expires = expires <= 0 and 0 or time() + expires,
        val = clone( val )
    };
    
    return true;
end


function InMem:get( key )
    local data = protected(self).data;
    local item;
    
    if not typeof.string( key ) then
        return nil, 'key must be string';
    end
    
    item = data[key];
    -- not defined
    if not item then
        return nil;
    -- delete expired item
    elseif item.expires > 0 and item.expires <= time() then
        data[key] = nil;
        return nil;
    end
    
    return clone( item.val );
end


function InMem:delete( key )
    if not typeof.string( key ) then
        return nil, 'key must be string';
    end
    
    local data = protected(self).data;
    if data[key] then
        data[key] = nil;
    end
    
    return true;
end


return InMem.exports;
