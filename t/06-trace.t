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
=== TEST 1: Create Distributed Trace Payload Segment.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            local segment = newrelic_agent.start_segment("CustomSegment", "CustomCategory")
            newrelic_agent.create_distributed_trace_payload(segment)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_create_distributed_trace_payload' no errors

=== TEST 2: Create Distributed Trace Payload HTTPSafe Segment.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            local segment = newrelic_agent.start_segment("CustomSegment", "CustomCategory")
            newrelic_agent.create_distributed_trace_payload_httpsafe(segment)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_create_distributed_trace_payload_httpsafe' no errors

=== TEST 3: Accept Distributed Trace Payload Segment.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            local segment = newrelic_agent.start_segment("CustomSegment", "CustomCategory")
            newrelic_agent.create_distributed_trace_payload(segment)
            newrelic_agent.accept_distributed_trace_payload("Payload", newrelic_agent.consts.NEWRELIC_TRANSPORT_TYPE_KAFKA)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_accept_distributed_trace_payload' no errors | payload: Payload, transport_type: Kafka

=== TEST 3: Accept Distributed Trace Payload Segment.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            local segment = newrelic_agent.start_segment("CustomSegment", "CustomCategory")
            newrelic_agent.create_distributed_trace_payload_httpsafe(segment)
            newrelic_agent.accept_distributed_trace_payload_httpsafe("Payload64", newrelic_agent.consts.NEWRELIC_TRANSPORT_TYPE_KAFKA)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_accept_distributed_trace_payload_httpsafe' no errors | payload: Payload64, transport_type: Kafka