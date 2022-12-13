# lua-cache

[![test](https://github.com/mah0x211/lua-cache/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-cache/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-cache/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-cache)

general-purpose cache module.

---

## Installation

```sh
luarocks install cache
```

## Usage

```lua
local sleep = require('nanosleep.sleep')
local cache = require('cache')
-- default ttl: 2 seconds
local c = cache(2)

local key = 'test'
local val = 'test val'
print(c:set(key, val)) -- true
print(c:get(key)) -- 'test val'
print(c:del(key)) -- true

print(c:set(key, val)) -- true
-- after 2 seconds
sleep(2)
print(c:get(key)) -- nil
```


## c = cache( ttl [, ...] )

create an instance of cache.  
this function calls the `self:init_once()` method with passed arguments.

**Parameters**

- `ttl:integer|nil`: default expiration seconds.
- `...`: any values.

**Returns**

- `c:cache`: instance of cache.


## c = cache:init_once( ... )

initialize and return an instance.

**Parameters**

same as the `cache()` function.

**Returns**

same as the `cache()` function.


## ok, err = cache:set_item( key, val [, ttl] )

set a key-value pair.

**Parameters**

- `key:string`: a key string.
- `val:any`: any value.
- `ttl:integer|nil`: expiration seconds

**Returns**

-. `ok:boolean`: `true` on success, or `false` on failure.
-. `err:any`: error message.


## ok, err = cache:set( key, val [, ttl] )

set a key-value pair.  
this method calls the `self:set_item()` method after validating its arguments.

**Parameters**

- `key:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.
- `val:any`: any value except `nil`.
- `ttl:integer`: expiration seconds greater or equal to `0`. (optional)

**Returns**

-. `ok:boolean`: `true` on success, or `false` on failure.
-. `err:any`: error message.


## val, err = cache:get_item( key [, touch] )

get a value associated with a `key` and update an expiration seconds if `touch` is specified.

**Parameters**

- `key:string`: a string.
- `touch:boolean`: update an expiration seconds. (optional)

**Returns**

- `val:any`: a value.
- `err:any`: error message.


## val, err = cache:get( key [, touch] )

get a value associated with a `key` and update an expiration seconds if `touch` is specified.  
this method calls the `self:get_item()` method after validating its arguments.

**Parameters**

- `key:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.
- `touch:boolean`: update an expiration seconds. (optional)

**Returns**

- `val:any`: a value.
- `err:any`: error message.


## ok, err = cache:del_item( key )

delete a value associated with a `key`.

**Parameters**

- `key:string`: a string.

**Returns**

- `ok:boolean`: `true` on success, or `false` on failure.
- `err:any`: error message.


## ok, err = cache:del( key )

delete a value associated with a `key`.  
this method calls the `self:del_item()` method after validating its arguments.

**Parameters**

- `key:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.

**Returns**

- `ok:boolean`: `true` on success, or `false` on failure.
- `err:any`: error message.


## ok, err = cache:rename_item( oldkey, newkey )

rename the `oldkey` name to `newkey`.

**Parameters**

- `oldkey:string`: a string.
- `new key:string`: a string.

**Returns**

- `ok:boolean`: `true` on success, or `false` on failure.
- `err:any`: error message.


## ok, err = cache:rename( oldkey, newkey )

rename the `oldkey` name to `newkey`.  
this method calls the `self:rename_item()` method after validating its arguments.

**Parameters**

- `oldkey:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.
- `new key:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.

**Returns**

- `ok:boolean`: `true` on success, or `false` on failure.
- `err:any`: error message.


## ok, err = cache:keys( callback )

execute a provided function once for each key. it is aborted if it returns `false` or an error.

**Parameters**

- `callback:function`: a function that called with each key.
    ```
    ok, err = callback(key)
    - ok:boolean: true on continue.
    - err:any: an error message.
    - key:string: cached key string.
    ```

**Returns**

- `ok:boolean`: `true` on success, or `false` on failure.
- `err:any`: error message.



## n, err = cache:evict( callback [, n] )

execute a provided function once before key is deleted. it is aborted if it returns `false` or an error.

**Parameters**

- `callback:function`: a function that called with key.
    ```
    ok, err = callback(key)
    - ok:boolean: true on continue.
    - err:any: an error message.
    - key:string: cached key string.
    ```

**Returns**

- `n:integer`: number of keys evicted.
- `err:any`: error message.


