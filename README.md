#lua-cache

pluggable cache storage module.

---

## Dependencies

- util: https://github.com/mah0x211/lua-util
- halo: https://github.com/mah0x211/lua-halo


## Installation

```sh
luarocks install cache --from=http://mah0x211.github.io/rocks/
```


## Creating a Instance


### ins, err = cache.new( store, ttl )

this method create an instance of cache class.

**Parameters**

- store: must implement the `get`, `set` and `delete` methods in this table.
- ttl: number of default expiration seconds.

**Returns**

1. ins: instance.
2. err: error string.


## Instance Methods

### ok, err = cache:set( key, val [, ttl] )

set a key-value pair.

**Parameters**

- key: string
- val: boolean, string, table or number.
- ttl: number of expiration seconds. (optional)

**Returns**

1. ok: true on success, or false on failure.
2. err: error string.


### ok, err = cache:delete( key )

delete a value associated with a key.

**Parameters**

- key: string

**Returns**

1. ok: true on success, or false on failure.
2. err: error string.


### val, err = cache:get( key [, defval [, ttl]] )

returns value associated with a key. or, returns a defval argument if it is nil.

**Parameters**

- key: string
- defval: boolean, string, table or number. (optional)
- ttl: renew a number of expiration seconds. (optional)

**Returns**

1. val: boolean, string, table or number.
2. err: error string.


## Optional Instance Methods

### ok, err = cache:rename( okey, nkey )

rename the key name.

**Parameters**

- okey: string
- nkey: string

**Returns**

1. ok: true on success, or false on failure.
2. err: error string.


## Note 

`cache` module is an interface implementation for storage plugins.

if you need to create original plugins, please refer to the source of `lib/inmem.lua`.


## Built-in Module `cache.inmem`

this module use the lua table as an in-memory cache storage.

#### Usage

```
local inmem = require('cache.inmem');
local defaultExpires = 30;
local cache = inmem.new( defaultExpires );
local key = 'test key';
local val = 'test val';

cache:set( key, val ); -- true
cache:get( key ); -- 'test val'
cache:delete( key ); -- true

cache:set( key, val ); -- true
-- after 30 seconds
cache:get( key ); -- nil

-- use default value: 'default val'
cache:get( key, 'default val' ); -- 'default val'
```

## Related Module

- cache-resty-redis: https://github.com/mah0x211/lua-cache-resty-redis
- cache-resty-dict: https://github.com/mah0x211/lua-cache-resty-dict

