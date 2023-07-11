--- module setup
local _M = { _VERSION = '0.01' }
package.loaded[...] = _M -- avoid returning module at the end of file

local newrelic = require 'lua-nri.newrelic'

local license_key = os.getenv("NEWRELIC_APP_LICENSE_KEY")
local app_name = os.getenv("NEWRELIC_APP_NAME")

local newrelic_application = nil

local newrelic_application_enabled = false

_M.enabled = ('string' == type(license_key) and
             40 == #license_key) and
             (newrelic.version() == newrelic.COMPATIBLE_VERSION)

_M.enable = function(configuration)
  local _configuration = configuration or { }
  if _M.enabled then
    -- checking for log information
    if _configuration and _configuration.log and
       _configuration.log.enabled and
       not (_configuration.log.filename == nil) and
       not (_configuration.log.level == nil) then
       local log_created = newrelic.configure_log(_configuration.log.filename,
                                                  _configuration.log.level)
       if not log_created then
          ngx.log(ngx.ERR, "Impossible to create log at " .. _configuration.log.filename
                           .. " with the level " .. _configuration.log.level
                           .. "! Please, check if the folder exists and you have permissions to write")
       end
    end

    newrelic_application = newrelic.create_app(license_key, app_name, configuration)

    ngx.log(ngx.ERR, newrelic_application)

    newrelic_application_enabled = (newrelic_application ~= nil and _M.enabled)
  end
  if newrelic_application_enabled then
    ngx.log(ngx.INFO, 'Starting Newrelic Lua Agent for ' .. app_name)
  else
    ngx.log(ngx.ERR, 'Newrelic Lua Agent is not configured for ' .. (app_name or "invalid name"))
  end
end

_M.notice_error = function(priority, message, class)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.notice_error(transaction_id, priority, message, class)
  end
end

-- web transactions
_M.start_web_transaction = function()
  if newrelic_application_enabled and _M.enabled then
      ngx.ctx.nr_transaction_id = newrelic.start_web_transaction(newrelic_application, ngx.var.uri)
  end
end

_M.end_web_transaction = function()
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
      return newrelic.end_web_transaction(transaction_id)
  end
end


-- generic segment
_M.start_segment = function(name, category)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
      return newrelic.start_segment(transaction_id, name, category)
  end
end

_M.end_segment = function(segment_id)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id and segment_id then
    return newrelic.end_segment(transaction_id, segment_id)
  end
end


-- non web transactions
_M.start_non_web_transaction = function(name)
  if newrelic_application_enabled and _M.enabled then
    ngx.ctx.nr_transaction_id_non_web = newrelic.start_non_web_transaction(newrelic_application, name)
  end
end

_M.end_non_web_transaction = function()
  local transaction_id = ngx.ctx.nr_transaction_id_non_web
  if newrelic_application_enabled and _M.enabled then
    return newrelic.end_non_web_transaction(transaction_id)
  end
end

_M.ignore_transaction = function()
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.ignore_transaction(transaction_id)
  end
end

-- attributes
_M.add_attribute = function(name, value)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.add_attribute(transaction_id, name, value)
  end
end

-- custom events
_M.custom_event = function(type)
  if newrelic_application_enabled and _M.enabled then
    return newrelic.create_custom_event(type)
  end
end

_M.record_custom_event = function(event)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.record_custom_event(transaction_id, event)
  end
end

_M.discard_custom_event = function(event)
  if newrelic_application_enabled and _M.enabled and event then
    return newrelic.discard_custom_event(event)
  end
end

_M.custom_event_add_attribute = function(custom_event, name, value)
  if newrelic_application_enabled and _M.enabled then
    return newrelic.custom_event_add_attribute(custom_event, name, value)
  end
end

_M.record_custom_metric = function(name, milliseconds)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.record_custom_metric(transaction_id, name, milliseconds)
  end
end

_M.start_datastore_segment = function(product, collection, operation, host, port_path_or_id, database_name, query)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.start_datastore_segment(
      transaction_id,
      product,
      collection,
      operation,
      host,
      port_path_or_id,
      database_name,
      query)
  end
end

_M.start_external_segment = function(uri, procedure, library)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.start_external_segment(transaction_id, uri, procedure, library)
  end
end

_M.set_transaction_name = function(name)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.set_transaction_name(transaction_id, name)
  end
end

_M.set_transaction_timing = function(duration, start_time)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.set_transaction_timing(transaction_id, duration, start_time)
  end
end

_M.set_segment_timing = function(segment, duration, start_time)
  if newrelic_application_enabled and _M.enabled and segment then
    return newrelic.set_segment_timing(segment, duration, start_time)
  end
end

_M.set_segment_parent_root = function(segment)
  if newrelic_application_enabled and _M.enabled and segment then
    return newrelic.set_segment_parent_root(segment)
  end
end

_M.set_segment_parent = function(segment, parent_segment)
  if newrelic_application_enabled and _M.enabled and segment and parent_segment then
    return newrelic.set_segment_parent(segment, parent_segment)
  end
end

_M.create_distributed_trace_payload = function(segment)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id and segment then
    return newrelic.create_distributed_trace_payload(transaction_id, segment)
  end
end

_M.create_distributed_trace_payload_httpsafe = function(segment)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id and segment then
    return newrelic.create_distributed_trace_payload_httpsafe(transaction_id, segment)
  end
end

_M.accept_distributed_trace_payload = function(payload, transport_type)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.accept_distributed_trace_payload(transaction_id, payload, transport_type)
  end
end

_M.accept_distributed_trace_payload_httpsafe = function(payload, transport_type)
  local transaction_id = ngx.ctx.nr_transaction_id
  if newrelic_application_enabled and _M.enabled and transaction_id then
    return newrelic.accept_distributed_trace_payload_httpsafe(transaction_id, payload, transport_type)
  end
end


_M.consts = {
  -- log level
  NEWRELIC_LOG_ERROR   = newrelic.NEWRELIC_LOG_ERROR,
  NEWRELIC_LOG_WARNING = newrelic.NEWRELIC_LOG_WARNING,
  NEWRELIC_LOG_INFO    = newrelic.NEWRELIC_LOG_INFO,
  NEWRELIC_LOG_DEBUG   = newrelic.NEWRELIC_LOG_DEBUG,

  -- tracer threshold
  NEWRELIC_THRESHOLD_IS_APDEX_FAILING = newrelic.NEWRELIC_THRESHOLD_IS_APDEX_FAILING,
  NEWRELIC_THRESHOLD_IS_OVER_DURATION = newrelic.NEWRELIC_THRESHOLD_IS_OVER_DURATION,

  -- record sql
  NEWRELIC_SQL_OFF        = newrelic.NEWRELIC_SQL_OFF,
  NEWRELIC_SQL_RAW        = newrelic.NEWRELIC_SQL_RAW,
  NEWRELIC_SQL_OBFUSCATED = newrelic.NEWRELIC_SQL_OBFUSCATED,

  -- datastore params
  NEWRELIC_DATASTORE_FIREBIRD =  newrelic.NEWRELIC_DATASTORE_FIREBIRD,
  NEWRELIC_DATASTORE_INFORMIX =   newrelic.NEWRELIC_DATASTORE_INFORMIX,
  NEWRELIC_DATASTORE_MSSQL    =  newrelic.NEWRELIC_DATASTORE_MSSQL,
  NEWRELIC_DATASTORE_MYSQL    = newrelic.NEWRELIC_DATASTORE_MYSQL,
  NEWRELIC_DATASTORE_ORACLE   = newrelic.NEWRELIC_DATASTORE_ORACLE,
  NEWRELIC_DATASTORE_POSTGRES =  newrelic.NEWRELIC_DATASTORE_POSTGRES,
  NEWRELIC_DATASTORE_SQLITE   = newrelic.NEWRELIC_DATASTORE_SQLITE,
  NEWRELIC_DATASTORE_SYBASE   = newrelic.NEWRELIC_DATASTORE_SYBASE,

  -- datastore params
  NEWRELIC_DATASTORE_MEMCACHE =  newrelic.NEWRELIC_DATASTORE_MEMCACHE,
  NEWRELIC_DATASTORE_MONGODB  =  newrelic.NEWRELIC_DATASTORE_MONGODB,
  NEWRELIC_DATASTORE_ODBC     =  newrelic.NEWRELIC_DATASTORE_ODBC,
  NEWRELIC_DATASTORE_REDIS    =  newrelic.NEWRELIC_DATASTORE_REDIS,
  NEWRELIC_DATASTORE_OTHER    = newrelic.NEWRELIC_DATASTORE_OTHER,

  -- distributed segment
  NEWRELIC_TRANSPORT_TYPE_UNKNOWN =  newrelic.NEWRELIC_TRANSPORT_TYPE_UNKNOWN,
  NEWRELIC_TRANSPORT_TYPE_HTTP    =  newrelic.NEWRELIC_TRANSPORT_TYPE_HTTP,
  NEWRELIC_TRANSPORT_TYPE_HTTPS   =  newrelic.NEWRELIC_TRANSPORT_TYPE_HTTPS,
  NEWRELIC_TRANSPORT_TYPE_KAFKA   =  newrelic.NEWRELIC_TRANSPORT_TYPE_KAFKA,
  NEWRELIC_TRANSPORT_TYPE_JMS     =  newrelic.NEWRELIC_TRANSPORT_TYPE_JMS,
  NEWRELIC_TRANSPORT_TYPE_IRONMQ  =  newrelic.NEWRELIC_TRANSPORT_TYPE_IRONMQ,
  NEWRELIC_TRANSPORT_TYPE_AMQP    =  newrelic.NEWRELIC_TRANSPORT_TYPE_AMQP,
  NEWRELIC_TRANSPORT_TYPE_QUEUE   =  newrelic.NEWRELIC_TRANSPORT_TYPE_QUEUE,
  NEWRELIC_TRANSPORT_TYPE_OTHER   =  newrelic.NEWRELIC_TRANSPORT_TYPE_OTHER,
}
