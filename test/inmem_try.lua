local inspect = require('util').inspect;
local sleep = require('process').sleep;
local InMem = require('cache.inmem');
local mem = ifNil( InMem.new() );
local key = 'key';
local val = {
    test = 1
};
local expires = 1;
local v;

ifNotNil( mem:get( key ) );
ifTrue( mem:set() );
ifTrue( mem:set( 1 ) );
ifNotTrue( mem:set( key, 1 ) );
ifTrue( mem:set( key, val, 0/0 ) );

ifNotTrue( mem:set( key, val, expires ) );
v = ifNil( mem:get( key ) );
ifEqual( v, val );
ifNotEqual( inspect( v ), inspect( val ) );

ifNotTrue( mem:delete( key ) );

ifNotTrue( mem:set( key, val, expires ) );
sleep( expires );
ifNotNil( mem:get( key ) );
