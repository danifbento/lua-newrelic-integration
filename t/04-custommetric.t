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
            newrelic_agent.record_custom_metric("CustomMetric", 100)
            ngx.say("OK")
        }
        log_by_lua 'require("lua-nri.newrelic_agent").end_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- shutdown_error_log
DEBUG 'newrelic_record_custom_metric' no errors | metric_name: CustomMetric, milliseconds: 100.0
