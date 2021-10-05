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
=== TEST 1: Start Segment.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            newrelic_agent.start_segment("CustomSegment", "CustomCategory")

            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_start_segment' no errors | name: CustomSegment, category: CustomCategory

=== TEST 2: Start datastore Segment.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            newrelic_agent.start_datastore_segment(newrelic_agent.consts.NEWRELIC_DATASTORE_MYSQL, "Collection", "SELECT", "localhost", "3036", "users", "SELECT * FROM users")

            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_start_datastore_segment' no errors | product: MYSQL, collection: Collection, operation: SELECT, host: localhost, port: 3036, database_name: users, query: SELECT * FROM users

=== TEST 3: Start external Segment.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            newrelic_agent.start_external_segment("Uri", "Procedure", "Library")

            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_start_external_segment' no errors | uri: Uri, procedure: Procedure, library: Library

=== TEST 4: End Segment.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            local segment = newrelic_agent.start_external_segment("Uri", "Procedure", "Library")
            newrelic_agent.end_segment(segment)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_end_segment' no errors

=== TEST 5: Set segment timing.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            local segment = newrelic_agent.start_external_segment("Uri", "Procedure", "Library")
            newrelic_agent.set_segment_timing(segment, 100, 0)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_set_segment_timing' no errors | start_time: 0, duration: 100

=== TEST 6: Set segment parent root.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            local segment = newrelic_agent.start_external_segment("Uri", "Procedure", "Library")
            newrelic_agent.set_segment_parent_root(segment)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_set_segment_parent_root' no errors

=== TEST 7: Set segment parent.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")

            local parent = newrelic_agent.start_segment("CustomSegment", "CustomCategory")
            local segment = newrelic_agent.start_external_segment("Uri", "Procedure", "Library")
            newrelic_agent.set_segment_parent(segment, parent)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_set_segment_parent' no errors