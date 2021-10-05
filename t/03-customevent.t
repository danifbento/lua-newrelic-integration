# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket;
use Cwd qw(cwd);

plan tests => repeat_each() * (blocks() * 3);

my $pwd = cwd();

our $MainConfigWithoutNrConfig = qq{
    # env NEWRELIC_APP_LICENSE_KEY;
    # env NEWRELIC_APP_NAME;
};

our $MainConfig = qq{
    env NEWRELIC_APP_LICENSE_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    env NEWRELIC_APP_NAME=test-app;
};


our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
    init_worker_by_lua_block {
        local newrelic_agent = require("lua-nri.newrelic_agent")
        configuration = {
            log = {
                enabled = true,
                filename = "t/servroot/logs/error.log",
                level = newrelic_agent.consts.NEWRELIC_LOG_DEBUG,
            }
        }
        newrelic_agent.enable(configuration)
    }

    error_log logs/error.log debug;
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';

no_long_string();
#no_diff();

run_tests();

__DATA__
=== TEST 1: Create custom event.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            newrelic_agent.custom_event("CustomEvent")

            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_create_custom_event' no errors | event_type: CustomEvent

=== TEST 2: Record custom event.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            local custom_event = newrelic_agent.custom_event("CustomEvent")

            newrelic_agent.record_custom_event(custom_event)

            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_record_custom_event' no errors

=== TEST 3: Discard custom event.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            local custom_event = newrelic_agent.custom_event("CustomEvent")

            newrelic_agent.discard_custom_event(custom_event)

            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_discard_custom_event' no errors

=== TEST 4: Add attribute to custom event Int.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            local custom_event = newrelic_agent.custom_event("CustomEvent")

            newrelic_agent.custom_event_add_attribute(custom_event, "IntKey", 1)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_custom_event_add_attribute_int' no errors | key: IntKey, value: 1

=== TEST 5: Add attribute to custom event Long.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            local custom_event = newrelic_agent.custom_event("CustomEvent")

            newrelic_agent.custom_event_add_attribute(custom_event, "LongKey", 21474836491)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_custom_event_add_attribute_long' no errors | key: LongKey, value: 2147483649

=== TEST 6: Add attribute to custom event Double.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            local custom_event = newrelic_agent.custom_event("CustomEvent")

            newrelic_agent.custom_event_add_attribute(custom_event, "DoubleKey", 1.1)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_custom_event_add_attribute_double' no errors | key: DoubleKey, value: 1.1

=== TEST 7: Add attribute to custom event String.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            local custom_event = newrelic_agent.custom_event("CustomEvent")

            newrelic_agent.custom_event_add_attribute(custom_event, "StringKey", "StringValue")
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_custom_event_add_attribute_string' no errors | key: StringKey, value: StringValue
