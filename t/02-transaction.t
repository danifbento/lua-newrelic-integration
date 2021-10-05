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
=== TEST 1: Start web transaction.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        echo "OK";
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_start_web_transaction' no errors | name: /a

=== TEST 2: End transaction.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        echo "OK";
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_end_transaction' no errors

=== TEST 3: Transaction Attributes Int.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            newrelic_agent.add_attribute("IntKey", 1)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_add_attribute_int' no erros | key: IntKey, value: 1

=== TEST 4: Transaction Attributes Long.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            newrelic_agent.add_attribute("LongKey", 2147483649)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_add_attribute_long' no erros | key: LongKey, value: 2147483649

=== TEST 5: Transaction Attributes Double.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            newrelic_agent.add_attribute("DoubleKey", 1.1)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_add_attribute_double' no erros | key: DoubleKey, value: 1.1

=== TEST 6: Transaction Attributes String.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction()';
        content_by_lua_block {
            local newrelic_agent = require("lua-nri.newrelic_agent")
            newrelic_agent.add_attribute("StringKey", "StringValue")
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_add_attribute_string' no erros | key: StringKey, value: StringValue

=== TEST 7: Start non web transaction.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_non_web_transaction("/a-non-web")';
        echo "OK";
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_start_non_web_transaction' no errors | name: /a-non-web

=== TEST 8: End transaction.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_non_web_transaction("/a-non-web")';
        echo "OK";
        log_by_lua 'require("lua-nri.newrelic_agent").end_non_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_end_transaction' no errors

=== TEST 9: Ignore transaction.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction("/a-non-web")';
        content_by_lua_block {
            newrelic_agent = require('lua-nri.newrelic_agent')
            newrelic_agent.ignore_transaction()
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_ignore_transaction' no errors

=== TEST 10: Set transaction name.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction("/a-non-web")';
        content_by_lua_block {
            newrelic_agent = require('lua-nri.newrelic_agent')
            newrelic_agent.set_transaction_name("CustomName")
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_set_transaction_name' no errors | name: CustomName

=== TEST 11: Set transaction timing.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("lua-nri.newrelic_agent").start_web_transaction("/a-non-web")';
        content_by_lua_block {
            newrelic_agent = require('lua-nri.newrelic_agent')
            newrelic_agent.set_transaction_timing(100, 0)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_set_transaction_timing' no errors | start_time: 0, duration: 100
