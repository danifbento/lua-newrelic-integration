#include <libnewrelic.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include <app.h>
#include <transaction.h>
#include <segment.h>
#include <custom_event.h>

/** for debug proposes we want to maintain state */
char *internal_filename;
FILE *internal_logfile;
newrelic_app_config_t *internal_app_config;
newrelic_app_t *internal_app;
newrelic_txn_t *web_transaction;
newrelic_txn_t *non_web_transaction;
newrelic_segment_t *segment;
newrelic_custom_event_t *custom_event;
newrelic_external_segment_params_t *external_segment_params;
newrelic_datastore_segment_params_t *datastore_segment_params;
newrelic_loglevel_t internal_loglevel;

newrelic_app_config_t *get_app_config_pointer() {
    if (internal_app_config != NULL) {
        return internal_app_config;
    }

    internal_app_config = (newrelic_app_config_t *) malloc(sizeof(newrelic_app_config_t));
    return internal_app_config;
}

newrelic_app_t *get_app_pointer() {
    if (internal_app != NULL) {
        return internal_app;
    }

    internal_app = (newrelic_app_t *) malloc(sizeof(newrelic_app_t));
    return internal_app;
}

newrelic_txn_t *get_transaction_pointer() {
    if (web_transaction != NULL) {
        return web_transaction;
    }
    web_transaction = (newrelic_txn_t *) malloc(sizeof(newrelic_txn_t));
    return web_transaction;
}

newrelic_segment_t *get_segment_pointer() {
    if (segment != NULL) {
        return segment;
    }
    segment = (newrelic_segment_t *) malloc(sizeof(newrelic_segment_t));
    return segment;
}

newrelic_custom_event_t *get_custom_event() {
    if (custom_event != NULL) {
        return custom_event;
    }

    custom_event = (newrelic_custom_event_t *) malloc(sizeof(newrelic_custom_event_t));
    return custom_event;
}

newrelic_external_segment_params_t *get_external_segment_params() {
    if (external_segment_params != NULL) {
        return external_segment_params;
    }

    external_segment_params = (newrelic_external_segment_params_t *) malloc(sizeof(newrelic_external_segment_params_t));
    return external_segment_params;
}

newrelic_datastore_segment_params_t *get_datastore_segment_params() {
    if (datastore_segment_params != NULL) {
        return datastore_segment_params;
    }

    datastore_segment_params = (newrelic_datastore_segment_params_t *) malloc(sizeof(newrelic_datastore_segment_params_t));
    return datastore_segment_params;
}

void _debug(const char *format, ...) {
    if (internal_logfile && internal_loglevel == NEWRELIC_LOG_DEBUG ) {
        va_list args;
        va_start(args, format);
        vfprintf(internal_logfile, format, args);
        va_end(args);
    }
}

bool newrelic_configure_log(const char *filename, newrelic_loglevel_t level)
{
    printf("DEBUG 'newrelic_configure_log' configuring log... %s[%d]\n", filename, level);

    internal_filename = (char *) malloc(255);
    strcpy(internal_filename, filename);

    internal_logfile = fopen(internal_filename, "a+");
    internal_loglevel = level;

    _debug("DEBUG 'newrelic_configure_log' no errors | filename: %s, level: %d\n", filename, level);

    return true;
}

bool newrelic_init(const char *daemon_socket, int time_limit_ms)
{
    if (time_limit_ms < 0)
    {
        _debug("DEBUG 'newrelic_init' invlid time_limit_ms - received < 0\n");
        return false;
    }

    _debug("DEBUG 'newrelic_init' no errors | daemon_socket: %s, time_limit_ms: %d\n", daemon_socket, time_limit_ms);
    return true;
}

newrelic_app_config_t *newrelic_create_app_config(const char *app_name, const char *license_key)
{
    if (app_name == NULL || strcmp(app_name, "") == 0) {
        _debug("DEBUG 'newrelic_create_app_config' invalid app_name - received empty\n");
        return NULL;
    }

    if (license_key == NULL || strcmp(license_key, "") == 0) {
        _debug("DEBUG 'newrelic_create_app_config' invalid license_key - received empty\n");
        return NULL;
    }

    _debug("DEBUG 'newrelic_create_app_config' no errors\n");
    return get_app_config_pointer();
}

bool newrelic_destroy_app_config(newrelic_app_config_t **config)
{
    if (config == NULL) {
        _debug("DEBUG 'newrelic_destroy_app_config' invalid config - received NULL\n");
        return false;
    }


    _debug("DEBUG 'newrelic_destroy_app_config' no erros\n");
    return true;
}

newrelic_app_t *newrelic_create_app(const newrelic_app_config_t *config, unsigned short timeout_ms){
    if (config == NULL) {
        _debug("DEBUG 'newrelic_create_app' invalid config - received NULL\n");
    }

    _debug("DEBUG 'newrelic_create_app' no errors | timeout_ms: %d\n", timeout_ms);
    return get_app_pointer();
}

bool newrelic_destroy_app(newrelic_app_t **app) {
    if (app == NULL || *app == NULL) {
        _debug("DEBUG 'newrelic_destroy_app' invalid app - received NULL\n");
        return false;
    }
    _debug("DEBUG 'newrelic_destroy_app' no errors\n");
    return true;
}

newrelic_txn_t *newrelic_start_web_transaction(newrelic_app_t *app, const char *name)
{
    if (app == NULL) {
        _debug("DEBUG 'newrelic_start_web_transaction' invalid app - received NULL\n");
        return NULL;
    }

    if (name == NULL || strcmp(name, "") == 0) {
        _debug("DEBUG 'newrelic_start_web_transaction' invalid name - received empty\n");
        return NULL;
    }

    _debug("DEBUG 'newrelic_start_web_transaction' no errors | name: %s\n", name);
    return get_transaction_pointer();
}

newrelic_txn_t *newrelic_start_non_web_transaction(newrelic_app_t *app, const char *name)
{
    if (app == NULL) {
        _debug("DEBUG 'newrelic_start_non_web_transaction' invalid app - received NULL\n");
        return NULL;
    }

    if (name == NULL || strcmp(name, "") == 0) {
        _debug("DEBUG 'newrelic_start_non_web_transaction' invalid name - received empty\n");
        return NULL;
    }

    _debug("DEBUG 'newrelic_start_non_web_transaction' no errors | name: %s\n", name);
    return get_transaction_pointer();
}

bool newrelic_set_transaction_timing(newrelic_txn_t *transaction, newrelic_time_us_t start_time, newrelic_time_us_t duration) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_set_transaction_timing' invalid transaction - received NULL\n");
        return false;
    }

    _debug("DEBUG 'newrelic_set_transaction_timing' no errors | start_time: %ld, duration: %ld\n", start_time, duration);
    return true;
}

bool newrelic_end_transaction(newrelic_txn_t **transaction_ptr) {
    if (transaction_ptr == NULL || *transaction_ptr == NULL) {
        _debug("DEBUG 'newrelic_end_transaction' invalid transaction - received NULL\n");
        return false;
    }

    _debug("DEBUG 'newrelic_end_transaction' no errors\n");
    return true;
}

bool newrelic_add_attribute_int(newrelic_txn_t *transaction, const char *key, const int value) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_add_attribute_int' invalid transaction - received NULL\n");
        return false;
    }

    if (key == NULL || strcmp(key, "") == 0) {
        _debug("DEBUG 'newrelic_add_attribute_int' invalid key - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_add_attribute_int' no erros | key: %s, value: %d\n", key, value);
    return true;
}

bool newrelic_add_attribute_long(newrelic_txn_t *transaction, const char *key, const long value) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_add_attribute_long' invalid transaction - received NULL\n");
        return false;
    }

    if (key == NULL || strcmp(key, "") == 0) {
        _debug("DEBUG 'newrelic_add_attribute_long' invalid key - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_add_attribute_long' no erros | key: %s, value: %ld\n", key, value);
    return true;
}
bool newrelic_add_attribute_double(newrelic_txn_t *transaction, const char *key, const double value) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_add_attribute_double' invalid transaction - received NULL\n");
        return false;
    }

    if (key == NULL || strcmp(key, "") == 0) {
        _debug("DEBUG 'newrelic_add_attribute_double' invalid key - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_add_attribute_double' no erros | key: %s, value: %f\n", key, value);
    return true;
}
bool newrelic_add_attribute_string(newrelic_txn_t *transaction, const char *key, const char *value) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_add_attribute_string' invalid transaction - received NULL\n");
        return false;
    }

    if (key == NULL || strcmp(key, "") == 0) {
        _debug("DEBUG 'newrelic_add_attribute_string' invalid key - received empty\n");
        return false;
    }

    if (value == NULL || strcmp(value, "") == 0) {
        _debug("DEBUG 'newrelic_add_attribute_string' invalid value - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_add_attribute_string' no erros | key: %s, value: %s\n", key, value);
    return true;
}
void newrelic_notice_error(newrelic_txn_t *transaction, int priority, const char *errmsg, const char *errclass) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_notice_error' invalid transaction - received NULL\n");
        return;
    }

    if (errmsg == NULL || strcmp(errmsg, "") == 0) {
        _debug("DEBUG 'newrelic_notice_error' invalid errmsg - received empty\n");
        return;
    }

    if (errclass == NULL || strcmp(errclass, "") == 0) {
        _debug("DEBUG 'newrelic_notice_error' invalid errclass - received empty\n");
        return;
    }

    _debug("DEBUG 'newrelic_notice_error' no errors | priority: %d, errmsg: %s, errclass: %s\n", priority, errmsg, errclass);
    return;
}

newrelic_segment_t *newrelic_start_segment(newrelic_txn_t *transaction, const char *name, const char *category) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_start_segment' invalid transaction - received NULL\n");
        return NULL;
    }

    if (name == NULL || strcmp(name, "") == 0) {
        _debug("DEBUG 'newrelic_start_segment' invalid name - received empty, default='Unnamed Segment'\n");
        return get_segment_pointer();
    }

    if (category == NULL || strcmp(category, "") == 0) {
        _debug("DEBUG 'newrelic_start_segment' invalid category - received empty, default='Custom'\n");
        return get_segment_pointer();
    }

    _debug("DEBUG 'newrelic_start_segment' no errors | name: %s, category: %s\n", name, category);
    return get_segment_pointer();
}
newrelic_segment_t *newrelic_start_datastore_segment(newrelic_txn_t *transaction, const newrelic_datastore_segment_params_t *params) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_start_datastore_segment' invalid transaction - received NULL\n");
        return NULL;
    }

    if (params == NULL) {
        _debug("DEBUG 'newrelic_start_datastore_segment' invalid params - received NULL\n");
        return NULL;
    }

    _debug("DEBUG 'newrelic_start_datastore_segment' no errors | product: %s, collection: %s, operation: %s, host: %s, port: %s, database_name: %s, query: %s\n", params->product, params->collection, params->operation, params->host, params->port_path_or_id, params->database_name, params->query);
    return get_segment_pointer();
}

newrelic_segment_t *newrelic_start_external_segment(newrelic_txn_t *transaction, const newrelic_external_segment_params_t *params) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_start_external_segment' invalid transaction - received NULL\n");
        return NULL;
    }

    if (params == NULL) {
        _debug("DEBUG 'newrelic_start_external_segment' invalid params - received NULL\n");
        return NULL;
    }

    _debug("DEBUG 'newrelic_start_external_segment' no errors | uri: %s, procedure: %s, library: %s\n", params->uri, params->procedure, params->library);
    return get_segment_pointer();
}
bool newrelic_set_segment_parent(newrelic_segment_t *segment, newrelic_segment_t *parent) {
    if (segment == NULL) {
        _debug("DEBUG 'newrelic_set_segment_parent' invalid segment - received NULL\n");
        return false;
    }

    if (parent == NULL) {
        _debug("DEBUG 'newrelic_set_segment_parent' invalid parent - received NULL\n");
        return false;
    }

    _debug("DEBUG 'newrelic_set_segment_parent' no errors\n");
    return true;
}

bool newrelic_set_segment_parent_root(newrelic_segment_t *segment) {

    if (segment == NULL) {
        _debug("DEBUG 'newrelic_set_segment_parent_root' invalid segment - received NULL\n");
        return false;
    }

    _debug("DEBUG 'newrelic_set_segment_parent_root' no errors\n");
    return true;
}

bool newrelic_set_segment_timing(newrelic_segment_t *segment, newrelic_time_us_t start_time, newrelic_time_us_t duration) {
    if (segment == NULL) {
        _debug("DEBUG 'newrelic_set_segment_timing' invalid segment - received NULL\n");
        return false;
    }

    _debug("DEBUG 'newrelic_set_segment_timing' no errors | start_time: %ld, duration: %d\n", start_time, duration);
    return true;
}

bool newrelic_end_segment(newrelic_txn_t *transaction, newrelic_segment_t **segment_ptr) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_end_segment' invalid transaction - received NULL\n");
        return false;
    }

    if (segment_ptr == NULL || *segment_ptr == NULL) {
        _debug("DEBUG 'newrelic_end_segment' invalid segment - received NULL\n");
        return false;
    }

    _debug("DEBUG 'newrelic_end_segment' no errors\n");
    return true;
}

newrelic_custom_event_t *newrelic_create_custom_event(const char *event_type) {
    if (strcmp(event_type, "") == 0) {
        _debug("DEBUG 'newrelic_create_custom_event' invalid event_type - received empty\n");
        return NULL;
    }

    _debug("DEBUG 'newrelic_create_custom_event' no errors | event_type: %s\n", event_type);
    return get_custom_event();
}
void newrelic_discard_custom_event(newrelic_custom_event_t **event) {
    if (event == NULL || *event == NULL) {
        _debug("DEBUG 'newrelic_discard_custom_event' invalid event - received NULL\n");
        return;
    }

    _debug("DEBUG 'newrelic_discard_custom_event' no errors\n");
    return;
}
void newrelic_record_custom_event(newrelic_txn_t *transaction, newrelic_custom_event_t **event) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_record_custom_event' invalid transaction - received NULL\n");
        return;
    }

    if (event == NULL || *event == NULL) {
        _debug("DEBUG 'newrelic_record_custom_event' invalid event - received NULL\n");
        return;
    }

    _debug("DEBUG 'newrelic_record_custom_event' no errors\n");
    return;
}
bool newrelic_custom_event_add_attribute_int(newrelic_custom_event_t *event, const char *key, int value) {
    if (event == NULL) {
        _debug("DEBUG 'newrelic_custom_event_add_attribute_int' invalid event - received NULL\n");
        return false;
    }

    if (strcmp(key, "") == 0) {
        _debug("DEBUG 'newrelic_custom_event_add_attribute_int' invalid key - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_custom_event_add_attribute_int' no errors | key: %s, value: %d\n", key, value);
    return true;
}
bool newrelic_custom_event_add_attribute_long(newrelic_custom_event_t *event, const char *key, long value) {
    if (event == NULL) {
        _debug("DEBUG 'newrelic_custom_event_add_attribute_long' invalid event - received NULL\n");
        return false;
    }

    if (strcmp(key, "") == 0) {
        _debug("DEBUG 'newrelic_custom_event_add_attribute_long' invalid key - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_custom_event_add_attribute_long' no errors | key: %s, value: %ld\n", key, value);
    return true;
}
bool newrelic_custom_event_add_attribute_double(newrelic_custom_event_t *event, const char *key, double value)
{
    if (event == NULL) {
        _debug("DEBUG 'newrelic_custom_event_add_attribute_double' invalid event - received NULL\n");
        return false;
    }

    if (strcmp(key, "") == 0) {
        _debug("DEBUG 'newrelic_custom_event_add_attribute_double' invalid key - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_custom_event_add_attribute_double' no errors | key: %s, value: %f\n", key, value);
    return true;
}

bool newrelic_custom_event_add_attribute_string(newrelic_custom_event_t *event, const char *key, const char *value) {
    if (event == NULL) {
        _debug("DEBUG 'newrelic_custom_event_add_attribute_string' invalid event - received NULL\n");
        return false;
    }

    if (strcmp(key, "") == 0) {
        _debug("DEBUG 'newrelic_custom_event_add_attribute_string' invalid key - received empty\n");
        return false;
    }

    if (strcmp(value, "") == 0) {
        _debug("DEBUG 'newrelic_custom_event_add_attribute_string' invalid value - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_custom_event_add_attribute_string' no errors | key: %s, value: %s\n", key, value);
    return true;
}

const char *newrelic_version(void) {
    _debug("DEBUG 'newrelic_version' no errors");
    return "1.3.0";
}

bool newrelic_record_custom_metric(newrelic_txn_t *transaction, const char *metric_name, double milliseconds) {

    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_record_custom_metric' invalid transaction - received NULL\n");
        return false;
    }

    if (strcmp(metric_name, "") == 0) {
        _debug("DEBUG 'newrelic_record_custom_metric' invalid metric_name - received empty\n");
        return false;
    }

    if (milliseconds < 0) {
        _debug("DEBUG 'newrelic_record_custom_metric' invalid milliseconds - received < 0\n");
        return false;
    }

    _debug("DEBUG 'newrelic_record_custom_metric' no errors | metric_name: %s, milliseconds: %f\n", metric_name, milliseconds);
    return true;
}

bool newrelic_ignore_transaction(newrelic_txn_t *transaction) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_ignore_transaction' invalid transaction - received NULL\n");
        return false;
    }
    _debug("DEBUG 'newrelic_ignore_transaction' no errors\n");
    return true;
}

char *newrelic_create_distributed_trace_payload(newrelic_txn_t *transaction, newrelic_segment_t *segment) {
    char *value;

    value = (char *) malloc(sizeof(char));
    strcpy(value, "r");

    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_create_distributed_trace_payload' invalid transaction - received NULL\n");
        return value;
    }

    if (segment == NULL) {
        _debug("DEBUG 'newrelic_create_distributed_trace_payload' invalid segment - received NULL\n");
        return value;
    }

    _debug("DEBUG 'newrelic_create_distributed_trace_payload' no errors\n");

    return value;
}

bool newrelic_accept_distributed_trace_payload(newrelic_txn_t *transaction, const char *payload, const char *transport_type) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_accept_distributed_trace_payload' invalid transaction - received NULL\n");
        return false;
    }

    if (strcmp(payload, "") == 0) {
        _debug("DEBUG 'newrelic_accept_distributed_trace_payload' invalid payload - received empty\n");
        return false;
    }

    if (strcmp(transport_type, "") == 0) {
        _debug("DEBUG 'newrelic_accept_distributed_trace_payload' invalid transport_type - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_accept_distributed_trace_payload' no errors | payload: %s, transport_type: %s\n", payload, transport_type);
    return true;
}

char *newrelic_create_distributed_trace_payload_httpsafe(newrelic_txn_t *transaction, newrelic_segment_t *segment) {
    char *value;


    value = (char *) malloc(sizeof(char));
    strcpy(value, "r");

    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_create_distributed_trace_payload_httpsafe' invalid transaction - received NULL\n");
        return value;
    }

    if (segment == NULL) {
        _debug("DEBUG 'newrelic_create_distributed_trace_payload_httpsafe' invalid segment - received NULL\n");
        return value;
    }

    _debug("DEBUG 'newrelic_create_distributed_trace_payload_httpsafe' no errors\n");

    return value;
}

bool newrelic_accept_distributed_trace_payload_httpsafe(newrelic_txn_t *transaction, const char *payload, const char *transport_type) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_accept_distributed_trace_payload_httpsafe' invalid transaction - received NULL\n");
        return false;
    }

    if (strcmp(payload, "") == 0) {
        _debug("DEBUG 'newrelic_accept_distributed_trace_payload_httpsafe' invalid payload - received empty\n");
        return false;
    }

    if (strcmp(transport_type, "") == 0) {
        _debug("DEBUG 'newrelic_accept_distributed_trace_payload_httpsafe' invalid transport_type - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_accept_distributed_trace_payload_httpsafe' no errors | payload: %s, transport_type: %s\n", payload, transport_type);
    return true;
}

bool newrelic_set_transaction_name(newrelic_txn_t *transaction, const char *transaction_name) {
    if (transaction == NULL) {
        _debug("DEBUG 'newrelic_set_transaction_name' invalid transaction - received NULL\n");
        return false;
    }
    if (strcmp(transaction_name, "") == 0) {
        _debug("DEBUG 'newrelic_set_transaction_name' invalid transaction name - received empty\n");
        return false;
    }

    _debug("DEBUG 'newrelic_set_transaction_name' no errors | name: %s\n", transaction_name);

    return true;
}

