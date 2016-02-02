local inspect = require('util').inspect;
local sleep = require('process').sleep;
local InMem = require('cache.inmem');
local mem = ifNil( InMem.new() );
local key = 'key';
local newkey = 'newkey';
local val = {
    test = 1
};
local expires = 1;
local v;

-- invalid arguments
ifNotNil( mem:get( key ) );
ifTrue( mem:set() );
ifTrue( mem:set( 1 ) );

-- valid value
ifNotTrue( mem:set( key, 1 ) );

-- invalid ttl
ifTrue( mem:set( key, val, 0/0 ) );

-- copy val
ifNotTrue( mem:set( key, val ) );
v = ifNil( mem:get( key ) );
ifEqual( tostring( v ), tostring( val ) );
ifNotEqual( inspect( v ), inspect( val ) );


-- invalid rename arguments
ifTrue( mem:rename( key, 1 ) );

-- rename
v = ifNil( mem:get( key ) );
ifNotTrue( mem:rename( key, newkey ) );
ifNotNil( mem:get( key ) );
ifEqual( tostring( v ), tostring( mem:get( newkey ) ) );


-- delete
ifNotTrue( mem:delete( newkey ) );

-- test ttl
ifNotTrue( mem:set( key, val, expires ) );
sleep( expires );
ifNotNil( mem:get( key ) );
