local ffi = require 'ffi'

ffi.cdef([[
  /*
   * NEWRELIC C-SDK 1.3.0
   */

  /*
   * Log Levels
   */
  typedef enum _newrelic_loglevel_t {
    /*
     * The highest-priority loglevel; only errors are logged.
     */
    NEWRELIC_LOG_ERROR,
    /*
     * The loglevel for warnings and errors.
     */
    NEWRELIC_LOG_WARNING,

    /*
     * The loglevel for informational logs, warnings, and errors.
     */
    NEWRELIC_LOG_INFO,

    /* The highest-verbosity loglevel.
     */

    NEWRELIC_LOG_DEBUG,
  } newrelic_loglevel_t;

  /*
   * Whether to consider transactions for trace generation based on the apdex configuration or a
   * specific duration.
   *
   * Default: NEWRELIC_THRESHOLD_IS_APDEX_FAILING.
   */
  typedef enum _newrelic_transaction_tracer_threshold_t {
    /*
     * Use 4*apdex(T) as the minimum time a transaction must take before it is eligible for a
     * transaction trace.
     */
    NEWRELIC_THRESHOLD_IS_APDEX_FAILING,
    /*
     * Use the value given in the duration_us field as the minimum time a transaction must
     * take before it is eligible for a transaction trace.
     */
    NEWRELIC_THRESHOLD_IS_OVER_DURATION,
  } newrelic_transaction_tracer_threshold_t;

  /*
   * Controls the format of the sql put into transaction traces for supported sql-like products.
   *
   * Only relevant if the datastore_reporting.enabled field is set to true.
   *
   * If set to NEWRELIC_SQL_OFF, transaction traces have no sql in them.
   * If set to NEWRELIC_SQL_RAW, the sql is added to the transaction trace as-is.
   * If set to NEWRELIC_SQL_OBFUSCATED, alphanumeric characters are set to '?'.
   * For example 'SELECT * FROM table WHERE foo = 42' is reported as 'SELECT * FROM table WHERE foo = ?'.
   * These obfuscated queries are added to the transaction trace for supported datastore products.
   */
  typedef enum _newrelic_tt_recordsql_t {
    /*
     * When the record_sql field of the newrelic_transaction_tracer_config_t is set to NEWRELIC_SQL_OFF,
     * no queries are reported to New Relic.
     */
    NEWRELIC_SQL_OFF,

    /*
     * For the SQL-like datastores which are supported by the C SDK, when the record_sql field of the
     * newrelic_transaction_tracer_config_t is set to NEWRELIC_SQL_RAW the query param of the
     * newrelic_datastore_segment_config_t is reported as-is to New Relic.
     *
     * WARNING: This setting is not recommended
     */
    NEWRELIC_SQL_RAW,

    /*
     * For the SQL-like datastores which are supported by the C SDK, when the record_sql field of the
     * newrelic_transaction_tracer_config_t is set to NEWRELIC_SQL_RAW the query param of
     * the newrelic_datastore_segment_config_t is reported to New Relic with alphanumeric characters
     * set to '?'
     */
    NEWRELIC_SQL_OBFUSCATED
  } newrelic_tt_recordsql_t;

  /*
   * A time, measured in microseconds
   */
  typedef uint64_t newrelic_time_us_t;

  /*
   * Configuration used to configure transaction tracing
   */
  typedef struct _newrelic_transaction_tracer_config_t {
    /*
     * Whether to enable transaction traces.
     +
     * Controls whether slow datastore queries are recorded.
     *
     * Default: true.
     *
     * If set to true for a transaction, the transaction tracer records the top-10 slowest
     * queries along with a stack trace of where the call occurred.
     *
     * Default: true.
     */
    bool enabled;

    /*
     * Whether to consider transactions for trace generation based on the apdex configuration or a specific duration.
     *
     * Default: NEWRELIC_THRESHOLD_IS_APDEX_FAILING.
     */
    newrelic_transaction_tracer_threshold_t threshold;

    /*
     * Specify the threshold above which a datastore query is considered "slow", in microseconds.
     *
     * Only relevant if the datastore_reporting.enabled field is set to true.
     *
     *Default: 500000, or 0.5 second
     */
    newrelic_time_us_t duration_us;

    /*
     * Sets the threshold above which the New Relic SDK will record a stack trace for a
     * transaction trace, in microseconds.
     *
     * Default: 500000, or 0.5 seconds.
     */

    newrelic_time_us_t stack_trace_threshold_us;

    struct {
      bool enabled;
      /*
       *  Controls the format of the sql put into transaction traces for supported sql-like products.
       *
       * Only relevant if the datastore_reporting.enabled field is set to true.
       *
       * If set to NEWRELIC_SQL_OFF, transaction traces have no sql in them.
       * If set to NEWRELIC_SQL_RAW, the sql is added to the transaction trace as-is.
       * If set to NEWRELIC_SQL_OBFUSCATED, alphanumeric characters are set to '?'. For example
       * 'SELECT * FROM table WHERE foo = 42' is reported as 'SELECT * FROM table WHERE foo = ?'.
       * These obfuscated queries are added to the transaction trace for supported datastore products.
       *
       */
      newrelic_tt_recordsql_t record_sql;
      /*
       * Specify the threshold above which a datastore query is considered "slow", in microseconds.
       *
       * Only relevant if the datastore_reporting.enabled field is set to true.
       *
       * Default: 500000, or 0.5 seconds.
       */
      newrelic_time_us_t threshold_us;
    } datastore_reporting;
  } newrelic_transaction_tracer_config_t;

  /*
   * Configuration used to configure how datastore segments are recorded in a transaction.
   */
  typedef struct _newrelic_datastore_segment_config_t {

    /*
     * Configuration which controls whether datastore instance names are reported to New Relic.
     */
    bool instance_reporting;

    /*
     * Configuration which controls whether datastore database names are reported to New Relic.
     *
     * If set to true for a transaction, database names are reported to New Relic.
     * More specifically, the database_name field in a newrelic_datastore_segment_params_t passed
     * to newrelic_datastore_start_segment() is reported when the corresponding transaction is reported.
     */
    bool database_name_reporting;
  } newrelic_datastore_segment_config_t;

  /*
   * Specifies whether or not distributed tracing is enabled.
   * When set to true, distributed tracing is enabled for the C SDK.
   * The default configuration returned by newrelic_create_app_config()
   * sets this value to false
   */
  typedef struct _newrelic_distributed_tracing_config_t {
    /*
     * Specifies whether or not distributed tracing is enabled.
     */
    bool enabled;
  } newrelic_distributed_tracing_config_t;

  /*
   * Configuration used for span events.
   */
  typedef struct _newrelic_span_event_config_t {
    /*
     * Specifies whether or not span events are generated.
     */
    bool enabled;
  } newrelic_span_event_config_t;

  /*
   * Configuration used to describe application name, license key, as well as
   * optional transaction tracer and datastore configuration
   */
  typedef struct _newrelic_app_config_t{
    /*
     * Specifies the name of the application to which data shall be reported.
     */
    char app_name[255];

    /*
     * Specifies the New Relic license key to use.
     */
    char license_key[255];

    /*
     *Optional. Specifies the New Relic provided host. There is little reason
     * to ever change this from the default.
     */
    char redirect_collector[100];

    /*
     * Optional. Specifies the file to be used for C SDK logs.
     *
     * If no filename is provided, no logging shall occur
     */
    char log_filename[255];

    /*
     * Optional. Specifies the logfile's level of detail.
     *
     * There is little reason to change this from the default value except in troubleshooting
     * scenarios.
     *
     * Must be one of the following values: NEWRELIC_LOG_ERROR, NEWRELIC_LOG_WARNING
     * NEWRELIC_LOG_INFO (default), NEWRELIC_LOG_DEBUG
     */
    newrelic_loglevel_t log_level;

    /*
     * Configuration used to configure transaction tracing.
     */
    newrelic_transaction_tracer_config_t transaction_tracer;

    /*
     * Configuration used to configure how datastore segments are recorded in a transaction.
     */
    newrelic_datastore_segment_config_t datastore_tracer;

    /*
     * Configuration used for distributed tracing.
     */
    newrelic_distributed_tracing_config_t distributed_tracing;

    /*
     * Specifies whether or not span events are generated.
     *
     * When set to true, span events are generated by the C SDK. The default configuration
     * returned by newrelic_create_app_config() sets this value to true
     */
    newrelic_span_event_config_t span_events;
  } newrelic_app_config_t;


  /*
   * Segment configuration used to instrument external calls.
   */
  typedef struct _newrelic_external_segment_params_t {
    /*
     * The URI that was loaded; it cannot be NULL.
     *
     * This field is required to be a null-terminated string containing a
     * valid URI, and cannot be NULL.
     */
    const char *uri;

    /*
     * The procedure used to load the external resource.
     *
     * In HTTP contexts, this will usually be the request method
     * (eg GET, POST, et al). For non-HTTP requests, or protocols that encode more
     * specific semantics on top of HTTP like SOAP, you may wish to use a different
     * value that more precisely encodes how the resource was requested.
     *
     * If provided, this field is required to be a null-terminated string that does
     * not include any slash characters. It is also valid to provide NULL, in which
     * case no procedure will be attached to the external segment.
     */
    const char *procedure;

    /*
     * The library used to load the external resource.
     *
     * If provided, this field is required to be a null-terminated string that does
     * not include any slash characters. It is also valid to provide NULL, in which
     * case no library will be attached to the external segment.
     */
    const char *library;
  } newrelic_external_segment_params_t;

  /*
   * Segment configuration used to instrument calls to databases and object stores.
   */
  typedef struct {
    /*
     * Specifies the datastore type, e.g., "MySQL", to indicate that the segment
     * represents a query against a MySQL database.
     *
     * New Relic recommends using the predefined NEWRELIC_DATASTORE_FIREBIRD through
     * NEWRELIC_DATASTORE_SYBASE constants for this field. If this field points to a
     * string that is not one of NEWRELIC_DATASTORE_FIREBIRD through NEWRELIC_DATASTORE_SYBASE,
     * the resulting datastore segment shall be instrumented as an unsupported datastore.
     *
     * For SQL-like datastores supported by the C SDK, when the record_sql field of the
     * newrelic_transaction_tracer_config_t is set to NEWRELIC_SQL_RAW or NEWRELIC_SQL_OBFUSCATED,
     * the query param of the newrelic_datastore_segment_config_t is reported to New Relic.
     *
     * This field is required to be a non-empty, null-terminated string that does not include any
     * slash characters. Empty strings are replaced with the string NEWRELIC_DATASTORE_OTHER.
     */
    const char *product;

    /*
     * Optional. Specifies the table or collection being used or queried against.
     *
     * If provided, this field is required to be a null-terminated string that does not include any slash
     * characters. It is also valid to use the default NULL value, in which case the default string of
     * "other" will be attached to the datastore segment.
     */
    const char *collection;

    /*
     * Optional. Specifies the operation being performed: for example, "select" for an SQL SELECT query,
     * or "set" for a Memcached set operation. While operations may be specified with any case, New Relic
     * suggests using lowercase.
     *
     * If provided, this field is required to be a null-terminated string that does not include any slash
     * characters. It is also valid to use the default NULL value, in which case the default string of "other"
     * will be attached to the datastore segment.
     */
    const char *operation;

    /*
     * Optional. Specifies the datahost host name.
     *
     * If provided, this field is required to be a null-terminated string that does not include any slash
     * characters. It is also valid to use the default NULL value, in which case the default string of
     * "other" will be attached to the datastore segment.
     */
    const char *host;

    /*
     * Optional. Specifies the port or socket used to connect to the datastore.
     *
     * If provided, this field is required to be a null-terminated string.
     */

    const char *port_path_or_id;
    /*
     * Optional. Specifies the database name or number in use.
     *
     * If provided, this field is required to be a null-terminated string.
     */
    const char *database_name;

    /*
     * Optional. Specifies the database query that was sent to the server.
     *
     * For security reasons, this value is only used if you set product to a supported sql-like datastore,
     * NEWRELIC_DATASTORE_FIREBIRD, NEWRELIC_DATASTORE_INFORMIX, NEWRELIC_DATASTORE_MSSQL, etc.
     * This allows the SDK to correctly obfuscate the query. When the product is set otherwise,
     * no query information is reported to New Relic.
     *
     * If provided, this field is required to be a null-terminated string.
     */
    const char *query;
  } newrelic_datastore_segment_params_t;

  /*
   * A New Relic application. Once an application configuration is created with newrelic_create_app_config(),
   * call newrelic_create_app() to create an application to report data to the daemon; the daemon, in turn,
   * reports data to New Relic.
   */
  typedef struct _nr_app_and_info_t newrelic_app_t;

  /*
   * A New Relic transaction.
   *
   * A transaction is started using newrelic_start_web_transaction() or newrelic_start_non_web_transaction().
   * A started, or active, transaction is stopped using newrelic_end_transaction(). One may modify a
   * transaction by adding custom attributes or recording errors only after it has been started.
   */
  typedef struct _newrelic_txn_t newrelic_txn_t;

  /*
   * A segment within a transaction.
   *
   * Within an active transaction, instrument additional segments for greater granularity.
   *
   * -For external calls: newrelic_start_external_segment().
   * -For datastore calls: newrelic_start_datastore_segment().
   * -For arbitrary code: newrelic_start_segment().
   *
   * All segments must be ended with newrelic_end_segment().
   */
  typedef struct _newrelic_segment_t newrelic_segment_t;

  /*
   * A Custom Event.
   *
   * The C SDK provides a Custom Events API that allows one to send custom events to New Relic Insights.
   * To send an event, start a transaction and use the newrelic_create_custom_event() and
   * newrelic_record_custom_event() functions.
   */
  typedef struct _newrelic_custom_event_t newrelic_custom_event_t;

  /*
   * Configure the C SDK's logging system.
   *
   * If the logging system was previously initialized (either by a prior call to newrelic_configure_log()
   * or implicitly by a call to newrelic_init() or newrelic_create_app()), then invoking this
   * function will close the previous log file.
   *
   * @param filename The path to the file to write logs to. If this is the literal string "stdout" or "stderr",
   *                 then logs will be written to standard output or standard error, respectively
   * @param level    The lowest level of log message that will be output
   *
   * @returns true on success; false otherwise
   */
  bool newrelic_configure_log(const char *filename, newrelic_loglevel_t level);


  /*
   * Initialise the C SDK with non-default settings.
   *
   * Generally, this function only needs to be called explicitly if the daemon socket location needs to be customised.
   * By default, "/tmp/.newrelic.sock" is used, which matches the default socket location used by newrelic-daemon
   * if one isn't given.
   *
   * The daemon socket location can be specified in four different ways:
   *
   * To use a specified file as a UNIX domain socket (UDS), provide an absolute path name as a string.
   * To use a standard TCP port, specify a number in the range 1 to 65534.
   * To use an abstract socket, prefix the socket name with '@'.
   * To connect to a daemon that is running on a different host, set this value to '<host>:<port>',
   *    where '<host>' denotes either a host name or an IP address, and '<port>' denotes a valid port number.
   *    Both IPv4 and IPv6 are supported.
   * If an explicit call to this function is required, it must occur before the first call to newrelic_create_app().
   *
   * Subsequent calls to this function after a successful call to newrelic_init() or newrelic_create_app() will fail.
   *
   * @param daemon_socket The path to the daemon socket. If this is NULL, then the default will be used, which is to
   *                      look for a UNIX domain socket at /tmp/.newrelic.sock
   * @param time_limit_ms The amount of time, in milliseconds, that the C SDK will wait for a response from the
   *                      daemon before considering initialization to have failed. If this is 0, then a default
   *                      value will be used
   *
   * @returns true on success; false otherwise
   */
  bool newrelic_init(const char *daemon_socket, int time_limit_ms);

  /*
   * Create a populated application configuration.
   *
   * Given an application name and license key, this method returns an SDK configuration.
   * Specifically, it returns a pointer to a newrelic_app_config_t with initialized app_name
   * and license_key fields along with default values for the remaining fields. After the application
   * has been created with newrelic_create_app(), the caller should free the configuration using
   * newrelic_destroy_app_config()
   *
   * @param app_name    The name of the application
   * @param license_key A valid license key supplied by New Relic.
   *
   * @returns An application configuration populated with app_name and license_key; all other
   *          fields are initialized to their defaults.
   */
  newrelic_app_config_t * newrelic_create_app_config(const char *app_name, const char *licence_key);

  /*
   * Create an application.
   *
   * Given a configuration, newrelic_create_app() returns a pointer to the newly allocated application,
   * or NULL if there was an error. If successful, the caller should destroy the application with the
   * supplied newrelic_destroy_app() when finished.
   *
   * @param config     An application configuration created by newrelic_create_app_config()
   * @param timeout_ms Specifies the maximum time to wait for a connection to be established;
   *                   a value of 0 causes the method to make only one attempt at connecting to the daemon.
   *
   * @returns A pointer to an allocated application, or NULL on error; any errors resulting from a
   *          badly-formed configuration are loggeds
   */
  newrelic_app_t * newrelic_create_app(newrelic_app_config_t *config, unsigned short timeout_ms);

  /*
   * Destroy the application configuration.
   *
   * Given an allocated application configuration, newrelic_destroy_app_config()
   * frees the configuration
   */
  bool newrelic_destroy_app_config(newrelic_app_config_t **config);

  /*
   * Destroy the application.
   *
   * Given an allocated application, newrelic_destroy_app() closes the logfile handle and frees any
   * memory used by app to describe the application.
   *
   * @param app The address of the pointer to the allocated application
   *
   * @returns false if app is NULL or points to NULL; true otherwise
   *
   * WARNING: This function must only be called once for a given application.
   */
  bool newrelic_destroy_app(newrelic_app_t **app);

  /*
   * Get the SDK version.
   *
   * @returns A NULL-terminated string containing the C SDK version number.
   *          If the version number is unavailable, the string "NEWRELIC_VERSION" will be returned.
   */
  const char * newrelic_version(void);

  /*
   * Start a web based transaction.
   * Given an application pointer and transaction name, this function begins timing a new transaction.
   * It returns a valid pointer to an active New Relic transaction, newrelic_txn_t.
   * The return value of this function may be used as an input parameter to
   * functions that modify an active transaction.
   *
   * @param app  A pointer to an allocation application
   * @param name The name of the transaction
   *
   * @returns A pointer to the transaction
   *
   */
  newrelic_txn_t * newrelic_start_web_transaction(newrelic_app_t *app, const char *name);

  /*
   * End a transaction.
   * Given an active transaction, this function stops the transaction's timing,
   * sends any data to the New Relic daemon, and destroys the transaction.
   *
   * @param transaction_prt The address of a pointer to an active transaction.
   *
   * @returns false if transaction is NULL or points to NULL;
   *          false if data cannot be sent to newrelic; true otherwise.
   *
   * WARNING: This function must only be called once for a given transaction.
   */
  bool newrelic_end_transaction(newrelic_txn_t **transaction_ptr);

  /*
   * Record the start of a custom segment in a transaction.
   *
   * Given an active transaction this function creates a custom segment to be
   * recorded as part of the transaction. A subsequent call to newrelic_end_segment()
   * records the end of the segment.
   *
   * @param transaction An active transaction
   * @param name        The segment name. If NULL or an invalid name is passed, this defaults to "Unnamed segment"
   * @param category    The segment category. If NULL or an invalid category is passed, this defaults to "Custom"
   *
   * @returns A pointer to a valid custom segment; NULL otherwise
   */
  newrelic_segment_t * newrelic_start_segment(newrelic_txn_t *transaction, const char *name, const char *category);

  /*
   * Record the completion of a segment in a transaction.
   *
   * Given an active transaction, this function records the segment's metrics on the transaction.
   *
   * @param transaction An active transaction
   * @param segment_ptr The address of a valid segment. Before the function returns, any segment_ptr memory is freed;
   *        segment_ptr is set to NULL to avoid any potential double free errors.
   *
   * @returns true if the parameters represented an active transaction and custom segment to record as complete;
   *          false otherwise. If an error occurred, a log message will be written to the SDK log at LOG_ERROR level
   */
  bool newrelic_end_segment(newrelic_txn_t *transaction, newrelic_segment_t **segment_ptr);

  /*
   * Start a non-web based transaction.
   *
   * Given a valid application and transaction name, this function begins timing a new transaction and returns a
   * valid pointer to a New Relic transaction, newrelic_txn_t. The return value of this function may be used
   * as an input parameter to functions that modify an active transaction.
   *
   * @param app  A pointer to an allocation application
   * @param name The name of the transaction
   *
   * @returns A pointer to the transaction
   */
  newrelic_txn_t* newrelic_start_non_web_transaction(newrelic_app_t *app, const char *name);


  /*
   * Add a custom integer attribute to a transaction.
   *
   * Given an active transaction, this function appends an integer attribute to the transaction.
   *
   * @param transaction An active transaction
   * @param key         The name of the attribute
   * @param value       The integer value of the attribute
   *
   * @returns true if successful; false otherwise
   */
  bool newrelic_add_attribute_int(newrelic_txn_t *transaction, const char *key, const int value);

  /*
   * Add a custom long attribute to a transaction.
   *
   * Given an active transaction, this function appends a long attribute to the transaction.
   *
   * @param transaction An active transaction
   * @param key         The name of the attribute
   * @param value       The long value of the attribute
   *
   * @returns true if successful; false otherwise
   */
  bool newrelic_add_attribute_long(newrelic_txn_t *transaction, const char *key, const long value);

  /*
   * Add a custom double attribute to a transaction.
   *
   * Given an active transaction, this function appends a double attribute to the transaction
   *
   * @param transaction An active transaction
   * @param key         The name of the attribute
   * @param value       The double value of the attribute
   *
   * @returns true if successful; false otherwise
   */
  bool newrelic_add_attribute_double(newrelic_txn_t *transaction, const char *key, const double value);

  /*
   * Add a custom string attribute to a transaction.
   *
   * Given an active transaction, this function appends a string attribute to the transaction.
   *
   * @param transaction An active transaction
   * @param key         The name of the attribute
   * @param value       The string value of the attribute
   *
   * @returns true if successful; false otherwise
   */
  bool newrelic_add_attribute_string(newrelic_txn_t *transaction, const char *key, const char *value);

  /*
   * Record an error in a transaction.
   *
   * Given an active transaction, this function records an error inside of the transaction.
   *
   * @param transaction An active transaction
   * @param priority    The error's priority. The C SDK sends up one error per transaction.
   *                    If multiple calls to this function are made during a single transaction,
   *                    the error with the highest priority is reported to New Relic
   * @param errmsg      A string comprising the error message
   * @param errclass    A string comprising the error class
   *
   */
  void newrelic_notice_error(newrelic_txn_t * transaction, int priority, const char *errmsg, const char *errclass);

  /*
   * Ignore the current transaction.
   *
   * Given a transaction, this function instructs the C SDK to not send data to New Relic for that transaction.
   *
   * @param transaction An active transaction
   *
   * @returns true on success
   */
  bool newrelic_ignore_transaction(newrelic_txn_t * transaction);

  /*
   * Adds an int key/value pair to the custom event's attributes.
   *
   * Given a custom event, this function adds an integer attributes to the event.
   *
   * @param event A valid custom event
   * @param key   the string key for the key/value pair
   * @param value the integer value of the key/value pair
   *
   * @returns false indicates the attribute could not be added
   */
  bool newrelic_custom_event_add_attribute_int(newrelic_custom_event_t *event, const char *key, int value);

  /*
   * Adds a long key/value pair to the custom event's attributes.
   *
   * Given a custom event, this function adds a long attribute to the event.
   *
   * @param event A valid custom event
   * @param key   the string key for the key/value pair
   * @param value the long value of the key/value pair
   *
   * @returns false indicates the attribute could not be added
   */
  bool newrelic_custom_event_add_attribute_long(newrelic_custom_event_t *event, const char *key, long value);

  /*
   * Adds a double key/value pair to the custom event's attributes.
   *
   * Given a custom event, this function adds a double attribute to the event.
   *
   * @param event A valid custom event
   * @param key   the string key for the key/value pair
   * @param value the double value of the key/value pair
   *
   * @returns false indicates the attribute could not be added
   */
  bool newrelic_custom_event_add_attribute_double(newrelic_custom_event_t *event, const char *key, double value);

  /*
   * Adds a string key/value pair to the custom event's attributes.
   *
   * Given a custom event, this function adds a char* (string) attribute to the event.
   *
   * @param event A valid custom event
   * @param key   the string key for the key/value pair
   * @param value the string value of the key/value pair
   *
   * @returns false indicates the attribute could not be added
   */
  bool newrelic_custom_event_add_attribute_string (newrelic_custom_event_t *event, const char *key, const char *value);

  /*
   * Creates a custom event.
   *
   * Attributes can be added to the custom event using the newrelic_custom_event_add_* family of functions.
   * When the required attributes have been added, the custom event can be recorded using
   * newrelic_record_custom_event().
   *
   * When passed to newrelic_record_custom_event, the custom event will be freed.
   * If you can't pass an allocated event to newrelic_record_custom_event, use the newrelic_discard_custom_event
   * function to free the event.
   *
   * @param event_type The type/name of the event
   *
   * @returns A pointer to a custom event; NULL otherwise.
   */
  newrelic_custom_event_t * newrelic_create_custom_event(const char *event_type);

  /*
   * Records the custom event.
   *
   * Given an active transaction, this function adds the custom event to the transaction and timestamps it,
   * ensuring the event will be sent to New Relic
   *
   * @param transaction An active transaction
   * @param The address of a valid custom event created by newrelic_create_custom_event()
   */
  void newrelic_record_custom_event(newrelic_txn_t *transaction, newrelic_custom_event_t **event);

  /*
   * Frees the memory for custom events created via the newrelic_create_custom_event function.
   *
   * This function is here in case there's an allocated newrelic_custom_event_t that ends up not
   * being recorded as a custom event, but still needs to be freed
   *
   * @param The address of a valid custom event created by newrelic_create_custom_event()
   */
  void newrelic_discard_custom_event(newrelic_custom_event_t **event);

  /*
   * Generate a custom metric.
   *
   * Given an active transaction and valid parameters, this function creates a custom metric
   * to be recorded as part of the transaction.
   *
   * @param transaction  An active transaction
   * @param metric_name  The name/identifier for the metric
   * @param milliseconds The amount of time the metric will record, in milliseconds
   *
   * @return true on success
   */
  bool newrelic_record_custom_metric(newrelic_txn_t *transaction, const char *metric_name, double	milliseconds);

  /*
   * Accept a distributed trace payload.
   *
   * Accept newrelic headers, or a payload, created with newrelic_create_distributed_trace_payload().
   * Such headers are manually added to a service's outbound request. The receiving service gets the newrelic
   * header from the incoming request and uses this function to accept the payload and link corresponding spans
   * together for a complete distributed trace. Note that a payload must be accepted within an active transaction.
   *
   * @param transaction    An active transaction
   * @param payload        A string created by newrelic_create_distributed_trace_payload(). This value cannot be NULL
   * @param transport_type Transport type used for communicating the external call. It is strongly recommended that one
   *                       of NEWRELIC_TRANSPORT_TYPE_UNKNOWN through NEWRELIC_TRANSPORT_TYPE_OTHER are used for this
   *                       value.
   *                       If NULL is supplied for this parameter, an info-level message is logged and the default
   *                       value of NEWRELIC_TRANSPORT_TYPE_UNKNOWN is used
   *
   * @returns true on success
   */
  bool newrelic_accept_distributed_trace_payload(newrelic_txn_t *transaction,
                                                 const char *payload,
                                                 const char *transport_type);

  /*
   * Accept a distributed trace payload, an http-safe, base64-encoded string.
   *
   * This function offers the same behaviour as newrelic_accept_distributed_trace_payload()
   * but accepts a base64-encoded string for the payload.
   *
   * @see newrelic_accept_distributed_trace_payload()
   */
  bool newrelic_accept_distributed_trace_payload_httpsafe(newrelic_txn_t *transaction,
                                                          const char *payload,
                                                          const char *transport_type);

  /*
   * Create a distributed trace payload.
   *
   * Create a newrelic header, or a payload, to add to a service's outbound requests.
   * This header contains the metadata necessary to link spans together for a complete distributed trace.
   * The metadata includes: the trace ID number, the span ID number, New Relic account ID number, and
   * sampling information.
   * Note that a payload must be created within an active transaction.
   *
   * @param transaction An active transaction
   * @param segment     An active segment in which the distributed trace payload is being created, or NULL to
   *                    indicate that the payload is created for the root segment.
   *
   * @returns If successful, a string to manually add to a service's outbound requests.
   *          If the instrumented application has not established a connection to the daemon or if distributed
   *          tracing is not enabled in the newrelic_app_config_t, this function returns NULL. The caller is
   *          responsible for invoking free() on the returned string
   */
  char* newrelic_create_distributed_trace_payload(newrelic_txn_t *transaction, newrelic_segment_t *segment);

  /*
   * Create a distributed trace payload, an http-safe, base64-encoded string.
   *
   * This function offers the same behaviour as newrelic_create_distributed_trace_payload() but creates a
   * base64-encoded string for the payload. The caller is responsible for invoking free() on the returned string
   *
   * @see newrelic_create_distributed_trace_payload()
   */
  char* newrelic_create_distributed_trace_payload_httpsafe(newrelic_txn_t *transaction,
                                                           newrelic_segment_t *segment);

  /*
   * Set the parent for the given segment.
   *
   * This function changes the parent for the given segment to another segment.
   * Both segments must exist on the same transaction, and must not have ended.
   *
   * @param segment The segment to reparent
   * @param parent	The new parent segment
   *
   * @returns true if the segment was successfully reparented; false otherwise
   *
   * WARNING: Do not attempt to use a segment that has had newrelic_end_segment()
   *          called on it as a segment or parent: this will result in a use-after-free
   *          scenario, and likely a crash
   */
  bool newrelic_set_segment_parent(newrelic_segment_t *segment, newrelic_segment_t *parent);

  /*
   * Set the transaction's root as the parent for the given segment.
   *
   * Transactions are represented by a collection of segments. Segments are created by
   * calls to newrelic_start_segment(), newrelic_start_datastore_segment() and
   * newrelic_start_external_segment(). In addition, a transaction has an automatically-created
   * root segment that represents the entrypoint of the transaction. In some cases, users may
   * want to manually parent their segments with the transaction's root segment.
   *
   * @param segment	The segment to be parented
   *
   * @returns true if the segment was successfully reparented; false otherwise
   */
  bool newrelic_set_segment_parent_root(newrelic_segment_t *segment);

  /*
   * Override the timing for the given segment.
   *
   * Segments are normally timed automatically based on when they were started and ended.
   * Calling this function disables the automatic timing, and uses the times given instead.
   *
   * Note that this may cause unusual looking transaction traces, as this function does
   * not change the parent segment. It is likely that users of this function will also want
   * to use newrelic_set_segment_parent() to manually parent their segments.
   *
   * @param segment    The segment to manually time
   * @param start_time The start time for the segment, in microseconds since the start of the transaction
   * @param duration   The duration of the segment in microseconds
   *
   * @returns true if the segment timing was changed; false otherwise
   */
  bool newrelic_set_segment_timing(newrelic_segment_t *segment,
                                   newrelic_time_us_t start_time,
                                   newrelic_time_us_t duration);

  /*
   * Set a transaction name.
   *
   * Given an active transaction and a name, this function sets the transaction name
   * to the given name.
   *
   * @param transaction      An active transaction
   * @param transaction_name Name for the transaction
   *
   * @returns true on success
   *
   * WARNING: Do not use brackets [] at the end of your transaction name.
   * New Relic automatically strips brackets from the name. Instead, use
   * parentheses () or other symbols if needed
   */
  bool newrelic_set_transaction_name(newrelic_txn_t *transaction, const char *transaction_name);

  /*
   * Override the timing for the given transaction.
   *
   * Transactions are normally timed automatically based on when they were started and ended.
   * Calling this function disables the automatic timing, and uses the times given instead.
   *
   * Note that this may cause unusual looking transaction traces. This function manually alters
   * a transaction's start time and duration, but it does not alter any timing for the segments
   * belonging to the transaction. As a result, the sum of all segment durations may be substantively
   * greater or less than the total duration of the transaction.
   *
   * It is likely that users of this function will also want to use newrelic_set_segment_timing()
   * to manually time their segments.
   *
   * @param transaction The transaction to manually time.
   * @param start_time  The start time for the segment, in microseconds since the UNIX Epoch
   * @param duration    The duration of the transaction in microseconds
   *
   * @returns true if the segment timing was changed; false otherwise
   */
  bool newrelic_set_transaction_timing(newrelic_txn_t *transaction,
                                       newrelic_time_us_t start_time,
                                       newrelic_time_us_t duration);

  /*
   * Record the start of a datastore segment in a transaction.
   *
   * Given an active transaction and valid parameters, this function creates a datastore segment
   * to be recorded as part of the transaction. A subsequent call to newrelic_end_segment()
   * records the end of the segment.
   *
   * @param transaction An active transaction
   * @param params      Valid parameters describing a datastore segment
   *
   * @returns A pointer to a valid datastore segment; NULL otherwise
   */
  newrelic_segment_t * newrelic_start_datastore_segment(newrelic_txn_t *transaction,
                                                        const newrelic_datastore_segment_params_t *params);

  /*
   * Start recording an external segment within a transaction.
   *
   * Given an active transaction, this function creates an external segment inside of
   * the transaction and marks it as having been started. An external segment is generally used
   * to represent a HTTP or RPC request.
   *
   * @param transaction An active transaction
   * @param params      The parameters describing the external request. All parameters are copied,
   *                    and no references to the pointers provided are kept after this function returns
   */
  newrelic_segment_t * newrelic_start_external_segment(newrelic_txn_t *transaction,
                                                       const newrelic_external_segment_params_t *params);
]])

-- local c-sdk lib https://github.com/newrelic/c-sdk/releases/tag/v1.3.0
-- $ ar -x libnewrelic.a
-- $ gcc -shared -lnewrelic -lpcre -lm -lpthread -rdynamic *.o -o libnewrelic.so
local nr = ffi.load('libnewrelic', true)

-- configure log
local newrelic_configure_log = function(filename, level)
  return nr.newrelic_configure_log(filename, level)
end

-- init
local newrelic_init = function()
  return nr.newrelic_init(nil, 1000)
end

-- create application
local newrelic_create_app = function(license_key, app_name, configuration)
  local config = nr.newrelic_create_app_config(app_name, license_key)

  local _configuration = configuration
  -- ensure that configuration has all main struct fields
  if _configuration == nil then
    _configuration = {}
  end
  if not (_configuration == nil) then
    if _configuration.transaction_tracer == nil then
       _configuration.transaction_tracer = {}
       _configuration.transaction_tracer.datastore_reporting = {}
    elseif _configuration.transaction_tracer.datastore_reporting == nil then
      _configuration.transaction_tracer.datastore_reporting = {}
    end
    if _configuration.distributed_tracing == nil then
      _configuration.distributed_tracing = {}
    end
    if _configuration.datastore_tracer == nil then
        _configuration.datastore_tracer = {}
    end
    if _configuration.span_events == nil then
       _configuration.span_events = {}
    end
    if _configuration.log == nil then
       _configuration.log = {}
    end
  end

  -- input configuration
  config.log_filename = _configuration.log.filename or ""
  config.log_level = _configuration.log.level or nil
  config.transaction_tracer.enabled =
          _configuration.transaction_tracer.enabled or true
  config.transaction_tracer.threshold =
          _configuration.transaction_tracer.threshold or ffi.C.NEWRELIC_THRESHOLD_IS_OVER_DURATION
  config.transaction_tracer.duration_us =
          _configuration.transaction_tracer.duration_us or 1
  config.transaction_tracer.stack_trace_threshold_us =
          _configuration.transaction_tracer.stack_trace_threshold_us or 1
  config.transaction_tracer.datastore_reporting.enabled =
          _configuration.transaction_tracer.datastore_reporting.enabled or true
  config.transaction_tracer.datastore_reporting.record_sql =
          _configuration.transaction_tracer.datastore_reporting.record_sql or ffi.C.NEWRELIC_SQL_RAW
  config.transaction_tracer.datastore_reporting.threshold_us =
          _configuration.transaction_tracer.datastore_reporting.threshold_us or 1
  config.datastore_tracer.instance_reporting =
          _configuration.datastore_tracer.instance_reporting or true
  config.datastore_tracer.database_name_reporting =
          _configuration.datastore_tracer.database_name_reporting or true
  config.distributed_tracing.enabled =
          _configuration.distributed_tracing.enabled or true
  config.span_events.enabled =
          _configuration.span_events.enabled or true

  local app = nr.newrelic_create_app(config, _configuration.waiting or 100)
  -- create a pointer to config
  local p = ffi.new('newrelic_app_config_t*[1]')
  p[0] = config
  nr.newrelic_destroy_app_config(p)
  return app
end

local newrelic_destroy_app = function(application)
  local p = ffi.new('newrelic_app_t*[1]')
  p[0] = application
  return nr.newrelic_destroy_app(p)
end

-- wrapper for all add_attribute_* functions
local newrelic_add_attribute = function(transaction_id, name, value)
  if value == nil then
    return false
  end
  local s, _ = string.find(tostring(value), '[.]')
  if type(value) == "string" then
    return nr.newrelic_add_attribute_string(transaction_id, name, value)
  elseif type(value) == "number" and
        (not (s == nil) or (value > 9223372036854775808 or value < -9223372036854775807)) then
    return nr.newrelic_add_attribute_double(transaction_id, name, value)
  elseif type(value) == "number" and value < 2147483647 and value > -2147483648 then
    return nr.newrelic_add_attribute_int(transaction_id, name, value)
  else
    return nr.newrelic_add_attribute_long(transaction_id, name, value)
  end
end

-- custom event
local newrelic_create_custom_event = function(event_type)
  return nr.newrelic_create_custom_event(event_type)
end

local newrelic_record_custom_event = function(transaction_id, event)
  local p = ffi.new('newrelic_custom_event_t*[1]')
  p[0] = event
  return nr.newrelic_record_custom_event(transaction_id, p)
end

local newrelic_discard_custom_event = function(event)
  local p = ffi.new('newrelic_custom_event_t*[1]')
  p[0] = event
  return nr.newrelic_discard_custom_event(p)
end

-- wrapper for all custom_event_add_attribute_* functions
local newrelic_custom_event_add_attribute = function(custom_event, name, value)
  if value == nil then
    return false
  end
  local s, _ = string.find(tostring(value), '[.]')
  if type(value) == "string" then
    return nr.newrelic_custom_event_add_attribute_string(custom_event, name, value)
  elseif type(value) == "number" and
        (not (s == nil) or (value > 9223372036854775808 or value < -9223372036854775807)) then
    return nr.newrelic_custom_event_add_attribute_double(custom_event, name, value)
  elseif type(value) == "number" and value < 2147483647 and value > -2147483648 then
    return nr.newrelic_custom_event_add_attribute_int(custom_event, name, value)
  else
    return nr.newrelic_custom_event_add_attribute_long(custom_event, name, value)
  end
end

local newrelic_record_custom_metric = function(transaction_id, name, milliseconds)
  return nr.newrelic_record_custom_metric(transaction_id, name, milliseconds)
end

local newrelic_version = function()
  return ffi.string(nr.newrelic_version())
end

-- notice error
local newrelic_notice_error = function(transaction_id, priority, message, class)
  nr.newrelic_notice_error(transaction_id, priority, message, class)
end


-- web transactions
local newrelic_start_web_transaction = function(application, name)
  return nr.newrelic_start_web_transaction(application, name)
end

local newrelic_end_web_transaction = function(transaction_id, nonWeb)
  nonWeb = nonWeb or false
  if not nonWeb and transaction_id then
    newrelic_add_attribute(transaction_id, "httpStatusCode", ngx.var.status)
    newrelic_add_attribute(transaction_id, "request.headers.accept", ngx.var.http_accept)
    newrelic_add_attribute(transaction_id, "request.headers.contentLength", ngx.var.http_content_length)
    newrelic_add_attribute(transaction_id, "request.headers.contentType", ngx.var.http_content_type)
    newrelic_add_attribute(transaction_id, "request.headers.host", ngx.var.http_host)
    newrelic_add_attribute(transaction_id, "request.headers.referer", ngx.var.http_referer)
    newrelic_add_attribute(transaction_id, "request.headers.userAgent", ngx.var.http_user_agent)
    newrelic_add_attribute(transaction_id, "request.headers.method", ngx.var.http_method)
    newrelic_add_attribute(transaction_id, "request.uri", ngx.var.uri)
    local headers, _ = ngx.resp.get_headers()
    newrelic_add_attribute(transaction_id, "response.headers.contentLength", headers['Content-Length'])
    newrelic_add_attribute(transaction_id, "response.headers.contentType", headers['Content-Type'])
    newrelic_add_attribute(transaction_id, "response.status", ngx.var.status)
  end
  -- create pointer to transaction
  local p = ffi.new('newrelic_txn_t*[1]')
  p[0] = transaction_id
  return nr.newrelic_end_transaction(p)
end

local newrelic_ignore_transaction = function(transaction_id)
  return nr.newrelic_ignore_transaction(transaction_id)
end

-- non web transactions
local newrelic_start_non_web_transaction = function(application, name)
  return nr.newrelic_start_non_web_transaction(application, name)
end

local newrelic_end_non_web_transaction = function(transaction_id)
  return newrelic_end_web_transaction(transaction_id, true)
end

-- segment
local newrelic_start_segment = function(transaction_id, name, category)
  return nr.newrelic_start_segment(transaction_id, name, category)
end

local newrelic_end_segment = function(transaction_id, segment_id)
  -- create pointer to segment
  local p = ffi.new('newrelic_segment_t*[1]')
  p[0] = segment_id
  return nr.newrelic_end_segment(transaction_id, p)
end

local newrelic_start_datastore_segment = function(
  transaction_id,
  product,
  collection,
  operation,
  host,
  port_or_path_id,
  database_name,
  query)
  local params = ffi.new("newrelic_datastore_segment_params_t", {
    product = product,
    collection = collection,
    operation = operation,
    host = host,
    port_or_path_id = port_or_path_id,
    database_name = database_name,
    query = query
  })
  return nr.newrelic_start_datastore_segment(transaction_id, params)
end

local newrelic_start_external_segment = function(transaction_id, uri, procedure, library)
  local params = ffi.new("newrelic_external_segment_params_t", {
    uri = uri,
    procedure = procedure,
    library = library
  })
  return nr.newrelic_start_external_segment(transaction_id, params)
end

local newrelic_set_transaction_name = function(transaction_id, name)
  return nr.newrelic_set_transaction_name(transaction_id, name)
end

local newrelic_set_transaction_timing = function(transaction_id, duration, start_time)
  local _start_time = start_time or ngx.time()
  return nr.newrelic_set_transaction_timing(transaction_id, _start_time, duration)
end

local newrelic_set_segment_timing = function(segment_id, duration, start_time)
  local _start_time = start_time or ngx.time()
  return nr.newrelic_set_segment_timing(segment_id, _start_time, duration)
end

local newrelic_set_segment_parent_root = function(segment_id)
  return nr.newrelic_set_segment_parent_root(segment_id)
end

local newrelic_set_segment_parent = function(segment_id, parent_segment_id)
  return nr.newrelic_set_segment_parent(segment_id, parent_segment_id)
end

-- distributed trace payload
local newrelic_create_distributed_trace_payload = function(transaction_id, segment_id)
  return nr.newrelic_create_distributed_trace_payload(transaction_id, segment_id)
end

local newrelic_create_distributed_trace_payload_httpsafe = function(transaction_id, segment_id)
  return nr.newrelic_create_distributed_trace_payload_httpsafe(transaction_id, segment_id)
end

local newrelic_accept_distributed_trace_payload = function(transaction_id, payload, transport_type)
  return nr.newrelic_accept_distributed_trace_payload(transaction_id, payload, transport_type)
end

local newrelic_accept_distributed_trace_payload_httpsafe = function(transaction_id, payload, transport_type)
  return nr.newrelic_accept_distributed_trace_payload_httpsafe(transaction_id, payload, transport_type)
end

-- return object
local _M = {

  COMPATIBLE_VERSION = "1.3.0",

  -- log level
  NEWRELIC_LOG_ERROR   = ffi.C.NEWRELIC_LOG_ERROR,
  NEWRELIC_LOG_WARNING = ffi.C.NEWRELIC_LOG_WARNING,
  NEWRELIC_LOG_INFO    = ffi.C.NEWRELIC_LOG_INFO,
  NEWRELIC_LOG_DEBUG   = ffi.C.NEWRELIC_LOG_DEBUG,

  -- tracer threshold
  NEWRELIC_THRESHOLD_IS_APDEX_FAILING = ffi.C.NEWRELIC_THRESHOLD_IS_APDEX_FAILING,
  NEWRELIC_THRESHOLD_IS_OVER_DURATION = ffi.C.NEWRELIC_THRESHOLD_IS_OVER_DURATION,

  -- record sql
  NEWRELIC_SQL_OFF        = ffi.C.NEWRELIC_SQL_OFF,
  NEWRELIC_SQL_RAW        = ffi.C.NEWRELIC_SQL_RAW,
  NEWRELIC_SQL_OBFUSCATED = ffi.C.NEWRELIC_SQL_OBFUSCATED,

  -- datastore params
  NEWRELIC_DATASTORE_FIREBIRD = "Firebird",
  NEWRELIC_DATASTORE_INFORMIX =   "Informix",
  NEWRELIC_DATASTORE_MSSQL    =  "MSSQL",
  NEWRELIC_DATASTORE_MYSQL    = "MYSQL",
  NEWRELIC_DATASTORE_ORACLE   = "Oracle",
  NEWRELIC_DATASTORE_POSTGRES =  "Postgres",
  NEWRELIC_DATASTORE_SQLITE   = "SQLite",
  NEWRELIC_DATASTORE_SYBASE   = "Sybase",

  -- datastore params
  NEWRELIC_DATASTORE_MEMCACHE =  "Memcached",
  NEWRELIC_DATASTORE_MONGODB  =  "MongoDB",
  NEWRELIC_DATASTORE_ODBC     =  "ODBC",
  NEWRELIC_DATASTORE_REDIS    =  "Redis",
  NEWRELIC_DATASTORE_OTHER    = "Other",

  -- distributed segment
  NEWRELIC_TRANSPORT_TYPE_UNKNOWN =  "Unknown",
  NEWRELIC_TRANSPORT_TYPE_HTTP    =  "HTTP",
  NEWRELIC_TRANSPORT_TYPE_HTTPS   =  "HTTPS",
  NEWRELIC_TRANSPORT_TYPE_KAFKA   =  "Kafka",
  NEWRELIC_TRANSPORT_TYPE_JMS     =  "JMS",
  NEWRELIC_TRANSPORT_TYPE_IRONMQ  =  "IronMQ",
  NEWRELIC_TRANSPORT_TYPE_AMQP    =  "AMQP",
  NEWRELIC_TRANSPORT_TYPE_QUEUE   =  "Queue",
  NEWRELIC_TRANSPORT_TYPE_OTHER   =  "Other",

  configure_log                             = newrelic_configure_log,
  init                                      = newrelic_init,
  create_app                                = newrelic_create_app,
  destroy_app                               = newrelic_destroy_app,
  version                                   = newrelic_version,
  start_web_transaction                     = newrelic_start_web_transaction,
  end_web_transaction                       = newrelic_end_web_transaction,
  start_segment                             = newrelic_start_segment,
  end_segment                               = newrelic_end_segment,
  start_non_web_transaction                 = newrelic_start_non_web_transaction,
  end_non_web_transaction                   = newrelic_end_non_web_transaction,
  ignore_transaction                        = newrelic_ignore_transaction,
  add_attribute                             = newrelic_add_attribute,
  notice_error                              = newrelic_notice_error,
  create_custom_event                       = newrelic_create_custom_event,
  custom_event_add_attribute                = newrelic_custom_event_add_attribute,
  record_custom_event                       = newrelic_record_custom_event,
  discard_custom_event                      = newrelic_discard_custom_event,
  record_custom_metric                      = newrelic_record_custom_metric,
  start_datastore_segment                   = newrelic_start_datastore_segment,
  start_external_segment                    = newrelic_start_external_segment,
  set_transaction_name                      = newrelic_set_transaction_name,
  set_transaction_timing                    = newrelic_set_transaction_timing,
  set_segment_timing                        = newrelic_set_segment_timing,
  set_segment_parent_root                   = newrelic_set_segment_parent_root,
  set_segment_parent                        = newrelic_set_segment_parent,
  create_distributed_trace_payload          = newrelic_create_distributed_trace_payload,
  create_distributed_trace_payload_httpsafe = newrelic_create_distributed_trace_payload_httpsafe,
  accept_distributed_trace_payload          = newrelic_accept_distributed_trace_payload,
  accept_distributed_trace_payload_httpsafe = newrelic_accept_distributed_trace_payload_httpsafe,
}

return _M
