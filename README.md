lua-newrelic-integration
====

**Lua Newrelic SDK** for the *ngx_lua* based on **New Relic C SDK**.

**New Relic One** is a powerful full-stack data analysis platform for all your software's metrics, events, and logs. Now available with a modern, consumption pricing model. Explore the platform Get free access. Platform Capabilities AIOps Alerts Application Monitoring (APM) Browser Monitoring ...

[![Build Status](https://app.travis-ci.com/danifbento/lua-newrelic-integration.svg?branch=main)](https://app.travis-ci.com/danifbento/lua-newrelic-integration)

Table of Contents
=================

* [Status](#status)
* [Description](#description)
* [Synopsis](#synopsis)
* [API](#api)
* [Installation](#installation)
* [Tested with](#tested-with)
* [TODO](#todo)
* [Bugs and Patches](#bugs-and-patches)
* [Author](#author)
* [Copyright and License](#copyright-and-license)

Status
======

This library is being tested. By default SDK will send all data using SSL.

This library transposes all methods from C-SDK into Lua. It is based on the original [lua-resty-newrelic](https://github.com/saks/lua-resty-newrelic) from Aliaksandr "saksmlz" Rahalevich <saksmlz__at__gmail.com>.

Description
===========

This Lua library is a luajit ffi-based wrapper around [newrelic C-SDK](http://github.com/newrelic/c-sdk) for the ngx_lua nginx module.

Please read [newrelic C-SDK Documentation](https://newrelic.github.io/c-sdk/index.html) for more details on each function/method.

This library **can only** be used with luajit, **NOT** lua, because uses [luajit ffi](http://luajit.org/ext_ffi.html).

Synopsis
===========

```lua
    http {
        # you do not need the following line if you are using
        # the OpenResty bundle:
        lua_package_path "/path/to/nri-newrelic/lib/?.lua;;";

        env NEWRELIC_APP_LICENSE_KEY=<your newrelic lincense key>;
        env NEWRELIC_APP_NAME=<your newrelic application name>;

        init_worker_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
                configuration = {
                    log = {
                        enabled  = true,
                        filename = "logs/newrelic.log",
                        level    = newrelic_agent.consts.NEWRELIC_LOG_DEBUG,
                    }
                }
                newrelic_agent.enable(configuration)
        }

        server {
            location /test {
                rewrite_by_lua_block {
                    require('lua-nri.newrelic_agent').start_web_transaction()
                }

                # here you can use any directive that generates response body like: try_files,
                # proxy_pass, content_by_lua_*, etc.
                content_by_lua_block {
                    local newrelic_agent = require 'lua-nri.newrelic_agent'

                    local call_remote_host = function(uri)
                      ngx.log(ngx.ERR, 'Calling ' .. uri .. ' host...')
                      ngx.sleep(math.random())
                    end

                    local redis = require 'resty.redis'
                    local red = redis:new()
                    red:set_timeout(math.random(1000))

                    -- track database query
                    local redis_connect_segment_id = newrelic_agent.start_datastore_segment(
                        newrelic_agent.consts.NEWRELIC_DATASTORE_REDIS,
                        "Collection",
                        "GET",
                        "127.0.0.1",
                        "6379",
                        "database_name",
                        ""
                    )

                    local connect_ok, connect_err = red:connect('127.0.0.1', 6379)
                    newrelic_agent.end_segment(redis_connect_segment_id)

                    -- increment custom metric
                    if connect_ok then
                      newrelic_agent.record_custom_metric('redis_client/new_connect', 1)
                    else
                      -- log error to newrelic
                      newrelic_agent.notice_error('Failed to connect to redis', connect_err, debug.traceback(), '\n')
                    end

                    -- segment and sub_segment
                    local hello_segment_id = newrelic_agent.start_segment('hello', 'teste')
                    ngx.say('hello')

                    newrelic_agent.set_segment_timing(hello_segment_id, 1000)
                    local hello_sub_segment_id = newrelic_agent.start_segment('hello_sub_segment', 'teste')
                    newrelic_agent.set_segment_parent(hello_sub_segment_id, hello_segment_id)
                    -- create and accept distributed trace payload
                    local dt = newrelic_agent.create_distributed_trace_payload(hello_segment_id)
                    newrelic_agent.accept_distributed_trace_payload("payload", newrelic_agent.NEWRELIC_TRANSPORT_TYPE_HTTP)

                    newrelic_agent.end_segment(hello_sub_segment_id)
                    newrelic_agent.end_segment(hello_segment_id)

                    -- track remote call
                    local uri = 'http://google.com'
                    local external_segment_id = newrelic_agent.start_external_segment(uri, 'google home page', 'library')
                    call_remote_host(uri)
                    newrelic_agent.end_segment(external_segment_id)

                    -- add a custom event
                    local custom_event = newrelic_agent.custom_event("NewCustomEvent")
                    newrelic_agent.custom_event_add_attribute(custom_event, "give_int", 200)
                    newrelic_agent.custom_event_add_attribute(custom_event, "give_long", 2147483650)
                    newrelic_agent.custom_event_add_attribute(custom_event, "give_double", 1.0)
                    newrelic_agent.custom_event_add_attribute(custom_event, "give_string", "string_to_check_string")
                    newrelic_agent.record_custom_event(custom_event)

                    -- start/end a non web transction
                    newrelic_agent.start_non_web_transaction(ngx.var.uri .. "-non-web")
                    newrelic_agent.end_non_web_transaction()

                    -- set transaction properties
                    newrelic_agent.set_transaction_name("NewTransactionName")
                    newrelic_agent.set_transaction_timing(1000)

                }

                log_by_lua_block {
                    local newrelic_agent = require("lua-nri.newrelic_agent")
                    newrelic_agent.end_web_transaction()
                }
            }
        }
    }
```
API
==========

enable - enable the newrelic lua client
 * configuration: an object with all configuration fields
```lua
enable(configuration)
```

notice_error - add an error to the current transaction
 * priority: the priority of the error, the higher one will be reported to newrelic
 * message : the error message
 * class   : the error class
```lua
notice_error(priority, message, class)
```

start_web_transaction - start new web transaction (it creates the id under ngx.ctx.nr_transaction_id)
```lua
start_web_transaction()
```

end_web_transaction - end the current web transaction
```lua
end_web_transaction()
```

start_segment - start a new segment inside the transaction
 * name     : the name of the segment
 * category : the category of the segment
```lua
start_segment(name, category)
```

end_segment - end a given segment
```lua
end_segment(segment_id)
```

start_non_web_transaction - start a new non web transaction (it creates the id under ngx.ctx.nr_transaction_id_non_web)
```lua
start_non_web_transaction(name)
```

end_non_web_transaction - end a non web transaction
```lua
end_non_web_transaction()
```

ignore_transaction - ignores the current transaction
```lua
ignore_transaction()
```

add_attribute - add an attribute to the current transaction (it maps for int, long, double and string)
  * name : the name of the attribute
  * value: the value of the attribute
```lua
add_attribute(name, value)
```

custom_event - create a custom event
 * type: type of the event
```lua
custom_event(type)
```

record_custom_event - prepare event to be sent to New Relic, without this, the custom event is not sent
 * event: the event to be recorded
```lua
record_custom_event(event)
```

discard_custom_event - discard the given custom event
 * event: the event to be discarded
```lua
discard_custom_event(event)
```

custom_event_add_attribute - add an attribute to the custom event (it maps for int, long, double and string)
  * custom_event: the event to attach the attribute
  * name        : the name of the attribute
  * value       : the value of the attribute
```lua
custom_event_add_attribute(custom_event, name, value)
```

record_custom_metric - record a custom metric
 * name        : name of the metric
 * milliseconds: time duration to record
```lua
record_custom_metric(name, milliseconds)
```

start_datastore_segment - start a datastore segment
 * product        :
 * collection     : the collection of data
 * operation      : the operation being performed
 * host           : the host which receives the connection
 * port_or_path_id: the port of the host
 * database_name  : the database_name
 * query          : the performed query
```lua
start_datastore_segment(product, collection, operation, host, port_or_path_id, database_name, query)
```

start_external_segment - start a external segment
 * uri      : the uri of the segment
 * procedure: the procedure being executed
 * library  : the library being used
```lua
start_external_segment(uri, procedure, library)
```

set_transaction_name - override current transaction name
 * name: new name for the transaction
```lua
set_transaction_name(name)
```

set_transaction_timing - override current transaction time
 * duration  : duration of the transacion
 * start_time: begin of the transaction (if nil, it will use ngx.time())
```lua
set_transaction_timing(duration, start_time)
```

set_transaction_timing - override current segment time
 * segment   : segmetn to be override
 * duration  : duration of the segment
 * start_time: begin of the segment (if nil, it will use ngx.time())
```lua
set_segment_timing(segment, duration, start_time)
```

set_segment_parent_root - set segment as root
 * segment: segment to be rooted
```lua
set_segment_parent_root(segment)
```

set_segment_parent - set a new parent for a given segment
 * segment       : segment to be parented
 * parent_segment: the parent segment
```lua
set_segment_parent(segment, parent_segment)
```

create_distributed_trace_payload - create a trace payload
 * payload       : the payload to be sent
 * transport_type: the transport type (given by constants)
```lua
create_distributed_trace_payload(payload, transport_type)
```

create_distributed_trace_payload_httpsafe - create a httpsafe trace payload
 * payload       : the payload to be sent
 * transport_type: the transport type (given by constants)
```lua
create_distributed_trace_payload_httpsafe(payload, transport_type)
```

accept_distributed_trace_payload - accept a trace payload
 * payload       : the payload to be sent
 * transport_type: the transport type (given by constants)
```lua
accept_distributed_trace_payload(payload, transport_type)
```

accept_distributed_trace_payload_httpsafe - accept a httpsafe trace payload
 * payload       : the payload to be sent
 * transport_type: the transport type (given by constants)
```lua
accept_distributed_trace_payload_httpsafe(payload, transport_type)
```

Installation
============

Download and install http://github.com/newrelic/c-sdk following the instructions of the repository. You will get two artifacts after `make` on this repo:
* newrelic_daemon
* libnewrelic.a

You should run newrelic_daemon as:
```bash
$./newrelic_daemon -f --logfile stdout --loglevel debug
```

To get the *.so needed to run this library you need to:
```bash
$ ar -x libnewrelic.a
$ gcc -shared -lpcre -lm -lpthread -rdynamic *.o -o libnewrelic.so
```

And put libnewrelic.so on your LD_PATH

If you are using the OpenResty bundle (http://openresty.org ), then
just download lua file [newrelic.lua](https://github.com/danifbento/lua-newrelic-integration/blob/master/lib/lua-nri/newrelic.lua)
and [newrelic_agent.lua](https://github.com/danifbento/lua-newrelic-integration/blob/master/lib/lua-nri/newrelic_agent.lua)
files to the directiory where nginx will find it. Another way to install is to use `luarocks` running:

```bash
$ luarocks install lua-newrelic-integration
```

If you are using your own nginx + ngx_lua build, then you need to configure
the lua_package_path directive to add the path of your lua-newrelic-integration source
tree to ngx_lua's LUA_PATH search path, as in

```nginx
    # nginx.conf
    http {
        lua_package_path "/path/to/lua-nri/lib/?.lua;;";
        ...
    }
```

Ensure that the system account running your Nginx ''worker'' proceses have
enough permission to read the `.lua` file.

[Back to TOC](#table-of-contents)

Tested with
================

* Linux
* openresty 1.19.9.1
* C-SDK 1.3.0

TODO
================

- [ ] Add tests to each newrelic_agent/newrelic method
- [ ] Improve README with case scenarios
- [ ] Add examples
- [x] Add Travis CI

Bugs and Patches
================

Please report bugs or submit patches by

1. creating a ticket on the [GitHub Issue Tracker](http://github.com/danifbento/lua-newrelic-integration/issues),

[Back to TOC](#table-of-contents)

Author
======

Daniela Filipe Bento <danibento@overdestiny.com>.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2021, by Daniela Filipe Bento (danifbento) <danibento@overdestiny.com>.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)
