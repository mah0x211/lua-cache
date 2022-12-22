# lua-cache

[![test](https://github.com/mah0x211/lua-cache/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-cache/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-cache/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-cache)

pluggable cache storage module.

---

## Installation

```sh
luarocks install cache
```

## Usage

```lua
local sleep = require('nanosleep.sleep')

-- `cache.inmem` is built-in module
-- this module uses the lua table as in-memory cache storage.
local cache = require('cache.inmem')
-- default ttl: 2 seconds
local c = cache.new(2)
local key = 'test'
local val = 'test val'

print(c:set(key, val)) -- true
print(c:get(key)) -- 'test val'
print(c:delete(key)) -- true

print(c:set(key, val)) -- true
-- after 2 seconds
sleep(2)
print(c:get(key)) -- nil
```


## c = cache.new( store, ttl )

create an instance of cache.  

**Parameters**

- `store:table|userdata`: store must be implemented the following methods;
    - `set`, `get`, `delete`, `rename`, `keys` and `evict`.
- `ttl:integer`: default expiration seconds.

**Returns**

- `c:cache`: instance of `cache`.


## ok, err = cache:set( key, val [, ttl] )

set a key-value pair.  
this method calls the `store:set()` method after validating its arguments.

**Parameters**

- `key:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.
- `val:any`: any value except `nil`. this value will be encoded into JSON string.
- `ttl:integer`: expiration seconds greater or equal to `0`. (optional)

**Returns**

- `ok:boolean`: `true` on success, or `false` on failure.
- `err:any`: error message.


## val, err = cache:get( key [, ttl] )

get a value associated with a `key` and update an expiration seconds if `ttl` is specified.  
this method calls the `store:get()` method after validating its arguments.

**Parameters**

- `key:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.
- `ttl:integer`: update an expiration seconds. (optional)

**Returns**

- `val:any`: a value.
- `err:any`: error message.


## ok, err = cache:delete( key )

delete a value associated with a `key`.  
this method calls the `store:delete()` method after validating its arguments.

**Parameters**

- `key:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.

**Returns**

- `ok:boolean`: `true` on success, or `false` on failure.
- `err:any`: error message.


## ok, err = cache:rename( oldkey, newkey )

rename the `oldkey` name to `newkey`.  
this method calls the `store:rename()` method after validating its arguments.

**Parameters**

- `oldkey:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.
- `newkey:string`: a string that matched to the pattern `^[a-zA-Z0-9_%-]+$'`.

**Returns**

- `ok:boolean`: `true` on success, or `false` on failure.
- `err:any`: error message.


## ok, err = cache:keys( callback, ... )

execute a provided function once for each key. it is aborted if it returns `false` or an error.  
this method calls the `store:keys()` method after validating its arguments.

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



## n, err = cache:evict( callback [, n, ...] )

execute a provided function once before key is deleted. it is aborted if it returns `false` or an error.  
this method calls the `store:evict()` method after validating its arguments.

**Parameters**

- `callback:function`: a function that called with key.
    ```
    ok, err = callback(key)
    - ok:boolean: true on continue.
    - err:any: an error message.
    - key:string: cached key string.
    ```
- `n:integer`: maximum number of keys to be evicted.

**Returns**

- `n:integer`: number of keys evicted.
- `err:any`: error message.



## Note 

`cache` module is an interface implementation of the storage plugins.  
if you need to create original plugins, please refer to the source of `lib/inmem.lua`.

