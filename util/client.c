#include <libnewrelic.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

int main() {
    newrelic_configure_log("filename", NEWRELIC_LOG_DEBUG);

    newrelic_init("", -1);
    newrelic_init("socket", 1);

    newrelic_create_app_config(NULL, NULL);
    newrelic_create_app_config("App Name", "");
    newrelic_create_app_config("App Name", "License Key");

    newrelic_destroy_app_config(NULL);
    newrelic_destroy_app_config(get_app_config_pointer());

    newrelic_create_app(NULL, 0);
    newrelic_create_app(get_app_config_pointer(), 0);

    newrelic_start_web_transaction(NULL, "");
    newrelic_start_web_transaction(get_app_pointer(), "");
    newrelic_start_web_transaction(get_app_pointer(), "Name");

    newrelic_start_non_web_transaction(NULL, "");
    newrelic_start_non_web_transaction(get_app_pointer(), "");
    newrelic_start_non_web_transaction(get_app_pointer(), "Name");

    newrelic_set_transaction_timing(NULL, 0, 0);
    newrelic_set_transaction_timing(get_transaction_pointer(), 0, 0);

    newrelic_add_attribute_int(NULL, "", 0);
    newrelic_add_attribute_int(get_transaction_pointer(), "", 0);
    newrelic_add_attribute_int(get_transaction_pointer(), "Key", 1);

    newrelic_add_attribute_long(NULL, "", 0);
    newrelic_add_attribute_long(get_transaction_pointer(), "", 0);
    newrelic_add_attribute_long(get_transaction_pointer(), "Key", 10);

    newrelic_add_attribute_double(NULL, "", 0);
    newrelic_add_attribute_double(get_transaction_pointer(), "", 0);
    newrelic_add_attribute_double(get_transaction_pointer(), "Key", 0.1);

    newrelic_add_attribute_string(NULL, "", "");
    newrelic_add_attribute_string(get_transaction_pointer(), "", "");
    newrelic_add_attribute_string(get_transaction_pointer(), "Key", "");
    newrelic_add_attribute_string(get_transaction_pointer(), "Key", "Value");

    newrelic_notice_error(NULL, 0, "", "");
    newrelic_notice_error(get_transaction_pointer(), 0, "", "");
    newrelic_notice_error(get_transaction_pointer(), 0, "Error Message", "");
    newrelic_notice_error(get_transaction_pointer(), 0, "Error Message", "Error Class");

    newrelic_start_segment(NULL, "", "");
    newrelic_start_segment(get_transaction_pointer(), "", "");
    newrelic_start_segment(get_transaction_pointer(), "Name", "");
    newrelic_start_segment(get_transaction_pointer(), "Name", "Category");

    newrelic_start_datastore_segment(NULL, NULL);
    newrelic_start_datastore_segment(get_transaction_pointer(), NULL);

    newrelic_datastore_segment_params_t datastore_params = {
        .product = "MySQL",
        .collection = "Collection",
        .operation = "SELECT",
        .host = "localhost",
        .port_path_or_id = "3036",
        .database_name = "users",
        .query = "SELECT * FROM users"
    };
    newrelic_start_datastore_segment(get_transaction_pointer(), &datastore_params);

    newrelic_start_external_segment(NULL, NULL);
    newrelic_start_external_segment(get_transaction_pointer(), NULL);

    newrelic_external_segment_params_t external_params = {
        .uri = "Uri",
        .procedure = "Procedure",
        .library = "Library"
    };

    newrelic_start_external_segment(get_transaction_pointer(), &external_params);

    newrelic_set_segment_parent(NULL, NULL);
    newrelic_set_segment_parent(get_segment_pointer(), NULL);
    newrelic_set_segment_parent(get_segment_pointer(), get_segment_pointer());

    newrelic_set_segment_parent_root(NULL);
    newrelic_set_segment_parent_root(get_segment_pointer());

    newrelic_set_segment_timing(NULL, 0, 0);
    newrelic_set_segment_timing(get_segment_pointer(), 1, 1);

    newrelic_end_segment(NULL, NULL);
    newrelic_end_segment(get_transaction_pointer(), NULL);
    newrelic_segment_t *end_segment = NULL;
    newrelic_end_segment(get_transaction_pointer(), &end_segment);
    newrelic_segment_t *end_segment2= get_segment_pointer();
    newrelic_end_segment(get_transaction_pointer(), &end_segment2);

    newrelic_create_custom_event("");
    newrelic_create_custom_event("CustomEventType");

    newrelic_discard_custom_event(NULL);
    newrelic_custom_event_t *d_event = NULL;
    newrelic_discard_custom_event(&d_event);
    newrelic_custom_event_t *d_event2 = get_custom_event();
    newrelic_discard_custom_event(&d_event2);

    newrelic_record_custom_event(NULL, NULL);
    newrelic_record_custom_event(get_transaction_pointer(), NULL);
    newrelic_custom_event_t *r_event = NULL;
    newrelic_record_custom_event(get_transaction_pointer(), &r_event);
    newrelic_custom_event_t *r_event2 = get_custom_event();
    newrelic_record_custom_event(get_transaction_pointer(), &r_event2);

    newrelic_custom_event_add_attribute_int(NULL, "", 0);
    newrelic_custom_event_add_attribute_int(get_custom_event(), "", 0);
    newrelic_custom_event_add_attribute_int(get_custom_event(), "Attribute", 1);

    newrelic_custom_event_add_attribute_long(NULL, "", 0);
    newrelic_custom_event_add_attribute_long(get_custom_event(), "", 0);
    newrelic_custom_event_add_attribute_long(get_custom_event(), "Attribute", 1);

    newrelic_custom_event_add_attribute_double(NULL, "", 0);
    newrelic_custom_event_add_attribute_double(get_custom_event(), "", 0);
    newrelic_custom_event_add_attribute_double(get_custom_event(), "Attribute", 1.1);

    newrelic_custom_event_add_attribute_string(NULL, "", "");
    newrelic_custom_event_add_attribute_string(get_custom_event(), "", "");
    newrelic_custom_event_add_attribute_string(get_custom_event(), "Attribute", "");
    newrelic_custom_event_add_attribute_string(get_custom_event(), "Attribute", "Value");

    newrelic_record_custom_metric(NULL, "", 0);
    newrelic_record_custom_metric(get_transaction_pointer(), "", 0);
    newrelic_record_custom_metric(get_transaction_pointer(), "Custom/Metric", 0);
    newrelic_record_custom_metric(get_transaction_pointer(), "Custom/Metric", -1);

    newrelic_ignore_transaction(NULL);
    newrelic_ignore_transaction(get_transaction_pointer());

    newrelic_create_distributed_trace_payload(NULL, NULL);
    newrelic_create_distributed_trace_payload(get_transaction_pointer(), NULL);
    newrelic_create_distributed_trace_payload(get_transaction_pointer(), get_segment_pointer());

    newrelic_accept_distributed_trace_payload(NULL, "", "");
    newrelic_accept_distributed_trace_payload(get_transaction_pointer(), "", "");
    newrelic_accept_distributed_trace_payload(get_transaction_pointer(), "Payload", "");
    newrelic_accept_distributed_trace_payload(get_transaction_pointer(), "Payload", "Transport Type");

    newrelic_create_distributed_trace_payload_httpsafe(NULL, NULL);
    newrelic_create_distributed_trace_payload_httpsafe(get_transaction_pointer(), NULL);
    newrelic_create_distributed_trace_payload_httpsafe(get_transaction_pointer(), get_segment_pointer());

    newrelic_accept_distributed_trace_payload_httpsafe(NULL, "", "");
    newrelic_accept_distributed_trace_payload_httpsafe(get_transaction_pointer(), "", "");
    newrelic_accept_distributed_trace_payload_httpsafe(get_transaction_pointer(), "Payload", "");
    newrelic_accept_distributed_trace_payload_httpsafe(get_transaction_pointer(), "Payload", "Transport Type");

    newrelic_set_transaction_name(NULL, "");
    newrelic_set_transaction_name(get_transaction_pointer(), "");
    newrelic_set_transaction_name(get_transaction_pointer(), "Transaction Name");
    return 0;
}
