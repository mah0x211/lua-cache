local sleep = require('process').sleep;
local Cache = require('cache');
local InMem = require('cache.inmem');
local mem = ifNil( InMem.new() );
local key = 'key';
local defval = {
    test = 1
};
local expires = 1;
local cache, item, v;

ifNotNil( Cache.new() );
ifNotNil( Cache.new( mem, 0/0 ) );
cache = ifNil( Cache.new( mem, expires ) );

ifNotNil( cache:get( key ) );
item = ifNil( cache:get( key, defval ) );
v = ifNil( item.data );
ifNotEqual( v.test, 1 );

v.test = 2;
ifNotTrue( item:save() );

item = ifNil( cache:get( key ) );
v = ifNil( item.data );
ifEqual( v.test, 1 );
ifNotEqual( v.test, 2 );

sleep( expires );
ifNotNil( cache:get( key ) );
