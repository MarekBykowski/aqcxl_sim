/* This file is autogenerated by tracetool, do not edit. */

#include "qemu/osdep.h"
#include "qemu/module.h"
#include "trace-qapi_commands_migration_trace_events.h"

uint16_t _TRACE_QMP_ENTER_QUERY_MIGRATE_DSTATE;
uint16_t _TRACE_QMP_EXIT_QUERY_MIGRATE_DSTATE;
uint16_t _TRACE_QMP_ENTER_MIGRATE_SET_CAPABILITIES_DSTATE;
uint16_t _TRACE_QMP_EXIT_MIGRATE_SET_CAPABILITIES_DSTATE;
uint16_t _TRACE_QMP_ENTER_QUERY_MIGRATE_CAPABILITIES_DSTATE;
uint16_t _TRACE_QMP_EXIT_QUERY_MIGRATE_CAPABILITIES_DSTATE;
uint16_t _TRACE_QMP_ENTER_MIGRATE_SET_PARAMETERS_DSTATE;
uint16_t _TRACE_QMP_EXIT_MIGRATE_SET_PARAMETERS_DSTATE;
uint16_t _TRACE_QMP_ENTER_QUERY_MIGRATE_PARAMETERS_DSTATE;
uint16_t _TRACE_QMP_EXIT_QUERY_MIGRATE_PARAMETERS_DSTATE;
uint16_t _TRACE_QMP_ENTER_CLIENT_MIGRATE_INFO_DSTATE;
uint16_t _TRACE_QMP_EXIT_CLIENT_MIGRATE_INFO_DSTATE;
uint16_t _TRACE_QMP_ENTER_MIGRATE_START_POSTCOPY_DSTATE;
uint16_t _TRACE_QMP_EXIT_MIGRATE_START_POSTCOPY_DSTATE;
uint16_t _TRACE_QMP_ENTER_X_COLO_LOST_HEARTBEAT_DSTATE;
uint16_t _TRACE_QMP_EXIT_X_COLO_LOST_HEARTBEAT_DSTATE;
uint16_t _TRACE_QMP_ENTER_MIGRATE_CANCEL_DSTATE;
uint16_t _TRACE_QMP_EXIT_MIGRATE_CANCEL_DSTATE;
uint16_t _TRACE_QMP_ENTER_MIGRATE_CONTINUE_DSTATE;
uint16_t _TRACE_QMP_EXIT_MIGRATE_CONTINUE_DSTATE;
uint16_t _TRACE_QMP_ENTER_MIGRATE_DSTATE;
uint16_t _TRACE_QMP_EXIT_MIGRATE_DSTATE;
uint16_t _TRACE_QMP_ENTER_MIGRATE_INCOMING_DSTATE;
uint16_t _TRACE_QMP_EXIT_MIGRATE_INCOMING_DSTATE;
uint16_t _TRACE_QMP_ENTER_XEN_SAVE_DEVICES_STATE_DSTATE;
uint16_t _TRACE_QMP_EXIT_XEN_SAVE_DEVICES_STATE_DSTATE;
uint16_t _TRACE_QMP_ENTER_XEN_SET_GLOBAL_DIRTY_LOG_DSTATE;
uint16_t _TRACE_QMP_EXIT_XEN_SET_GLOBAL_DIRTY_LOG_DSTATE;
uint16_t _TRACE_QMP_ENTER_XEN_LOAD_DEVICES_STATE_DSTATE;
uint16_t _TRACE_QMP_EXIT_XEN_LOAD_DEVICES_STATE_DSTATE;
uint16_t _TRACE_QMP_ENTER_XEN_SET_REPLICATION_DSTATE;
uint16_t _TRACE_QMP_EXIT_XEN_SET_REPLICATION_DSTATE;
uint16_t _TRACE_QMP_ENTER_QUERY_XEN_REPLICATION_STATUS_DSTATE;
uint16_t _TRACE_QMP_EXIT_QUERY_XEN_REPLICATION_STATUS_DSTATE;
uint16_t _TRACE_QMP_ENTER_XEN_COLO_DO_CHECKPOINT_DSTATE;
uint16_t _TRACE_QMP_EXIT_XEN_COLO_DO_CHECKPOINT_DSTATE;
uint16_t _TRACE_QMP_ENTER_QUERY_COLO_STATUS_DSTATE;
uint16_t _TRACE_QMP_EXIT_QUERY_COLO_STATUS_DSTATE;
uint16_t _TRACE_QMP_ENTER_MIGRATE_RECOVER_DSTATE;
uint16_t _TRACE_QMP_EXIT_MIGRATE_RECOVER_DSTATE;
uint16_t _TRACE_QMP_ENTER_MIGRATE_PAUSE_DSTATE;
uint16_t _TRACE_QMP_EXIT_MIGRATE_PAUSE_DSTATE;
uint16_t _TRACE_QMP_ENTER_CALC_DIRTY_RATE_DSTATE;
uint16_t _TRACE_QMP_EXIT_CALC_DIRTY_RATE_DSTATE;
uint16_t _TRACE_QMP_ENTER_QUERY_DIRTY_RATE_DSTATE;
uint16_t _TRACE_QMP_EXIT_QUERY_DIRTY_RATE_DSTATE;
uint16_t _TRACE_QMP_ENTER_SET_VCPU_DIRTY_LIMIT_DSTATE;
uint16_t _TRACE_QMP_EXIT_SET_VCPU_DIRTY_LIMIT_DSTATE;
uint16_t _TRACE_QMP_ENTER_CANCEL_VCPU_DIRTY_LIMIT_DSTATE;
uint16_t _TRACE_QMP_EXIT_CANCEL_VCPU_DIRTY_LIMIT_DSTATE;
uint16_t _TRACE_QMP_ENTER_QUERY_VCPU_DIRTY_LIMIT_DSTATE;
uint16_t _TRACE_QMP_EXIT_QUERY_VCPU_DIRTY_LIMIT_DSTATE;
uint16_t _TRACE_QMP_ENTER_SNAPSHOT_SAVE_DSTATE;
uint16_t _TRACE_QMP_EXIT_SNAPSHOT_SAVE_DSTATE;
uint16_t _TRACE_QMP_ENTER_SNAPSHOT_LOAD_DSTATE;
uint16_t _TRACE_QMP_EXIT_SNAPSHOT_LOAD_DSTATE;
uint16_t _TRACE_QMP_ENTER_SNAPSHOT_DELETE_DSTATE;
uint16_t _TRACE_QMP_EXIT_SNAPSHOT_DELETE_DSTATE;
TraceEvent _TRACE_QMP_ENTER_QUERY_MIGRATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_query_migrate",
    .sstate = TRACE_QMP_ENTER_QUERY_MIGRATE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_QUERY_MIGRATE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_QUERY_MIGRATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_query_migrate",
    .sstate = TRACE_QMP_EXIT_QUERY_MIGRATE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_QUERY_MIGRATE_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_MIGRATE_SET_CAPABILITIES_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_migrate_set_capabilities",
    .sstate = TRACE_QMP_ENTER_MIGRATE_SET_CAPABILITIES_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_MIGRATE_SET_CAPABILITIES_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_MIGRATE_SET_CAPABILITIES_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_migrate_set_capabilities",
    .sstate = TRACE_QMP_EXIT_MIGRATE_SET_CAPABILITIES_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_MIGRATE_SET_CAPABILITIES_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_QUERY_MIGRATE_CAPABILITIES_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_query_migrate_capabilities",
    .sstate = TRACE_QMP_ENTER_QUERY_MIGRATE_CAPABILITIES_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_QUERY_MIGRATE_CAPABILITIES_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_QUERY_MIGRATE_CAPABILITIES_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_query_migrate_capabilities",
    .sstate = TRACE_QMP_EXIT_QUERY_MIGRATE_CAPABILITIES_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_QUERY_MIGRATE_CAPABILITIES_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_MIGRATE_SET_PARAMETERS_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_migrate_set_parameters",
    .sstate = TRACE_QMP_ENTER_MIGRATE_SET_PARAMETERS_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_MIGRATE_SET_PARAMETERS_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_MIGRATE_SET_PARAMETERS_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_migrate_set_parameters",
    .sstate = TRACE_QMP_EXIT_MIGRATE_SET_PARAMETERS_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_MIGRATE_SET_PARAMETERS_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_QUERY_MIGRATE_PARAMETERS_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_query_migrate_parameters",
    .sstate = TRACE_QMP_ENTER_QUERY_MIGRATE_PARAMETERS_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_QUERY_MIGRATE_PARAMETERS_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_QUERY_MIGRATE_PARAMETERS_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_query_migrate_parameters",
    .sstate = TRACE_QMP_EXIT_QUERY_MIGRATE_PARAMETERS_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_QUERY_MIGRATE_PARAMETERS_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_CLIENT_MIGRATE_INFO_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_client_migrate_info",
    .sstate = TRACE_QMP_ENTER_CLIENT_MIGRATE_INFO_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_CLIENT_MIGRATE_INFO_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_CLIENT_MIGRATE_INFO_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_client_migrate_info",
    .sstate = TRACE_QMP_EXIT_CLIENT_MIGRATE_INFO_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_CLIENT_MIGRATE_INFO_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_MIGRATE_START_POSTCOPY_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_migrate_start_postcopy",
    .sstate = TRACE_QMP_ENTER_MIGRATE_START_POSTCOPY_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_MIGRATE_START_POSTCOPY_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_MIGRATE_START_POSTCOPY_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_migrate_start_postcopy",
    .sstate = TRACE_QMP_EXIT_MIGRATE_START_POSTCOPY_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_MIGRATE_START_POSTCOPY_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_X_COLO_LOST_HEARTBEAT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_x_colo_lost_heartbeat",
    .sstate = TRACE_QMP_ENTER_X_COLO_LOST_HEARTBEAT_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_X_COLO_LOST_HEARTBEAT_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_X_COLO_LOST_HEARTBEAT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_x_colo_lost_heartbeat",
    .sstate = TRACE_QMP_EXIT_X_COLO_LOST_HEARTBEAT_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_X_COLO_LOST_HEARTBEAT_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_MIGRATE_CANCEL_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_migrate_cancel",
    .sstate = TRACE_QMP_ENTER_MIGRATE_CANCEL_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_MIGRATE_CANCEL_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_MIGRATE_CANCEL_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_migrate_cancel",
    .sstate = TRACE_QMP_EXIT_MIGRATE_CANCEL_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_MIGRATE_CANCEL_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_MIGRATE_CONTINUE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_migrate_continue",
    .sstate = TRACE_QMP_ENTER_MIGRATE_CONTINUE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_MIGRATE_CONTINUE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_MIGRATE_CONTINUE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_migrate_continue",
    .sstate = TRACE_QMP_EXIT_MIGRATE_CONTINUE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_MIGRATE_CONTINUE_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_MIGRATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_migrate",
    .sstate = TRACE_QMP_ENTER_MIGRATE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_MIGRATE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_MIGRATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_migrate",
    .sstate = TRACE_QMP_EXIT_MIGRATE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_MIGRATE_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_MIGRATE_INCOMING_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_migrate_incoming",
    .sstate = TRACE_QMP_ENTER_MIGRATE_INCOMING_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_MIGRATE_INCOMING_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_MIGRATE_INCOMING_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_migrate_incoming",
    .sstate = TRACE_QMP_EXIT_MIGRATE_INCOMING_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_MIGRATE_INCOMING_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_XEN_SAVE_DEVICES_STATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_xen_save_devices_state",
    .sstate = TRACE_QMP_ENTER_XEN_SAVE_DEVICES_STATE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_XEN_SAVE_DEVICES_STATE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_XEN_SAVE_DEVICES_STATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_xen_save_devices_state",
    .sstate = TRACE_QMP_EXIT_XEN_SAVE_DEVICES_STATE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_XEN_SAVE_DEVICES_STATE_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_XEN_SET_GLOBAL_DIRTY_LOG_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_xen_set_global_dirty_log",
    .sstate = TRACE_QMP_ENTER_XEN_SET_GLOBAL_DIRTY_LOG_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_XEN_SET_GLOBAL_DIRTY_LOG_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_XEN_SET_GLOBAL_DIRTY_LOG_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_xen_set_global_dirty_log",
    .sstate = TRACE_QMP_EXIT_XEN_SET_GLOBAL_DIRTY_LOG_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_XEN_SET_GLOBAL_DIRTY_LOG_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_XEN_LOAD_DEVICES_STATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_xen_load_devices_state",
    .sstate = TRACE_QMP_ENTER_XEN_LOAD_DEVICES_STATE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_XEN_LOAD_DEVICES_STATE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_XEN_LOAD_DEVICES_STATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_xen_load_devices_state",
    .sstate = TRACE_QMP_EXIT_XEN_LOAD_DEVICES_STATE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_XEN_LOAD_DEVICES_STATE_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_XEN_SET_REPLICATION_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_xen_set_replication",
    .sstate = TRACE_QMP_ENTER_XEN_SET_REPLICATION_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_XEN_SET_REPLICATION_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_XEN_SET_REPLICATION_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_xen_set_replication",
    .sstate = TRACE_QMP_EXIT_XEN_SET_REPLICATION_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_XEN_SET_REPLICATION_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_QUERY_XEN_REPLICATION_STATUS_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_query_xen_replication_status",
    .sstate = TRACE_QMP_ENTER_QUERY_XEN_REPLICATION_STATUS_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_QUERY_XEN_REPLICATION_STATUS_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_QUERY_XEN_REPLICATION_STATUS_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_query_xen_replication_status",
    .sstate = TRACE_QMP_EXIT_QUERY_XEN_REPLICATION_STATUS_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_QUERY_XEN_REPLICATION_STATUS_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_XEN_COLO_DO_CHECKPOINT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_xen_colo_do_checkpoint",
    .sstate = TRACE_QMP_ENTER_XEN_COLO_DO_CHECKPOINT_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_XEN_COLO_DO_CHECKPOINT_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_XEN_COLO_DO_CHECKPOINT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_xen_colo_do_checkpoint",
    .sstate = TRACE_QMP_EXIT_XEN_COLO_DO_CHECKPOINT_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_XEN_COLO_DO_CHECKPOINT_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_QUERY_COLO_STATUS_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_query_colo_status",
    .sstate = TRACE_QMP_ENTER_QUERY_COLO_STATUS_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_QUERY_COLO_STATUS_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_QUERY_COLO_STATUS_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_query_colo_status",
    .sstate = TRACE_QMP_EXIT_QUERY_COLO_STATUS_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_QUERY_COLO_STATUS_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_MIGRATE_RECOVER_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_migrate_recover",
    .sstate = TRACE_QMP_ENTER_MIGRATE_RECOVER_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_MIGRATE_RECOVER_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_MIGRATE_RECOVER_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_migrate_recover",
    .sstate = TRACE_QMP_EXIT_MIGRATE_RECOVER_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_MIGRATE_RECOVER_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_MIGRATE_PAUSE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_migrate_pause",
    .sstate = TRACE_QMP_ENTER_MIGRATE_PAUSE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_MIGRATE_PAUSE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_MIGRATE_PAUSE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_migrate_pause",
    .sstate = TRACE_QMP_EXIT_MIGRATE_PAUSE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_MIGRATE_PAUSE_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_CALC_DIRTY_RATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_calc_dirty_rate",
    .sstate = TRACE_QMP_ENTER_CALC_DIRTY_RATE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_CALC_DIRTY_RATE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_CALC_DIRTY_RATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_calc_dirty_rate",
    .sstate = TRACE_QMP_EXIT_CALC_DIRTY_RATE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_CALC_DIRTY_RATE_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_QUERY_DIRTY_RATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_query_dirty_rate",
    .sstate = TRACE_QMP_ENTER_QUERY_DIRTY_RATE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_QUERY_DIRTY_RATE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_QUERY_DIRTY_RATE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_query_dirty_rate",
    .sstate = TRACE_QMP_EXIT_QUERY_DIRTY_RATE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_QUERY_DIRTY_RATE_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_SET_VCPU_DIRTY_LIMIT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_set_vcpu_dirty_limit",
    .sstate = TRACE_QMP_ENTER_SET_VCPU_DIRTY_LIMIT_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_SET_VCPU_DIRTY_LIMIT_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_SET_VCPU_DIRTY_LIMIT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_set_vcpu_dirty_limit",
    .sstate = TRACE_QMP_EXIT_SET_VCPU_DIRTY_LIMIT_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_SET_VCPU_DIRTY_LIMIT_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_CANCEL_VCPU_DIRTY_LIMIT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_cancel_vcpu_dirty_limit",
    .sstate = TRACE_QMP_ENTER_CANCEL_VCPU_DIRTY_LIMIT_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_CANCEL_VCPU_DIRTY_LIMIT_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_CANCEL_VCPU_DIRTY_LIMIT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_cancel_vcpu_dirty_limit",
    .sstate = TRACE_QMP_EXIT_CANCEL_VCPU_DIRTY_LIMIT_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_CANCEL_VCPU_DIRTY_LIMIT_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_QUERY_VCPU_DIRTY_LIMIT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_query_vcpu_dirty_limit",
    .sstate = TRACE_QMP_ENTER_QUERY_VCPU_DIRTY_LIMIT_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_QUERY_VCPU_DIRTY_LIMIT_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_QUERY_VCPU_DIRTY_LIMIT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_query_vcpu_dirty_limit",
    .sstate = TRACE_QMP_EXIT_QUERY_VCPU_DIRTY_LIMIT_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_QUERY_VCPU_DIRTY_LIMIT_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_SNAPSHOT_SAVE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_snapshot_save",
    .sstate = TRACE_QMP_ENTER_SNAPSHOT_SAVE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_SNAPSHOT_SAVE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_SNAPSHOT_SAVE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_snapshot_save",
    .sstate = TRACE_QMP_EXIT_SNAPSHOT_SAVE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_SNAPSHOT_SAVE_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_SNAPSHOT_LOAD_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_snapshot_load",
    .sstate = TRACE_QMP_ENTER_SNAPSHOT_LOAD_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_SNAPSHOT_LOAD_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_SNAPSHOT_LOAD_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_snapshot_load",
    .sstate = TRACE_QMP_EXIT_SNAPSHOT_LOAD_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_SNAPSHOT_LOAD_DSTATE 
};
TraceEvent _TRACE_QMP_ENTER_SNAPSHOT_DELETE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_enter_snapshot_delete",
    .sstate = TRACE_QMP_ENTER_SNAPSHOT_DELETE_ENABLED,
    .dstate = &_TRACE_QMP_ENTER_SNAPSHOT_DELETE_DSTATE 
};
TraceEvent _TRACE_QMP_EXIT_SNAPSHOT_DELETE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "qmp_exit_snapshot_delete",
    .sstate = TRACE_QMP_EXIT_SNAPSHOT_DELETE_ENABLED,
    .dstate = &_TRACE_QMP_EXIT_SNAPSHOT_DELETE_DSTATE 
};
TraceEvent *qapi_commands_migration_trace_events_trace_events[] = {
    &_TRACE_QMP_ENTER_QUERY_MIGRATE_EVENT,
    &_TRACE_QMP_EXIT_QUERY_MIGRATE_EVENT,
    &_TRACE_QMP_ENTER_MIGRATE_SET_CAPABILITIES_EVENT,
    &_TRACE_QMP_EXIT_MIGRATE_SET_CAPABILITIES_EVENT,
    &_TRACE_QMP_ENTER_QUERY_MIGRATE_CAPABILITIES_EVENT,
    &_TRACE_QMP_EXIT_QUERY_MIGRATE_CAPABILITIES_EVENT,
    &_TRACE_QMP_ENTER_MIGRATE_SET_PARAMETERS_EVENT,
    &_TRACE_QMP_EXIT_MIGRATE_SET_PARAMETERS_EVENT,
    &_TRACE_QMP_ENTER_QUERY_MIGRATE_PARAMETERS_EVENT,
    &_TRACE_QMP_EXIT_QUERY_MIGRATE_PARAMETERS_EVENT,
    &_TRACE_QMP_ENTER_CLIENT_MIGRATE_INFO_EVENT,
    &_TRACE_QMP_EXIT_CLIENT_MIGRATE_INFO_EVENT,
    &_TRACE_QMP_ENTER_MIGRATE_START_POSTCOPY_EVENT,
    &_TRACE_QMP_EXIT_MIGRATE_START_POSTCOPY_EVENT,
    &_TRACE_QMP_ENTER_X_COLO_LOST_HEARTBEAT_EVENT,
    &_TRACE_QMP_EXIT_X_COLO_LOST_HEARTBEAT_EVENT,
    &_TRACE_QMP_ENTER_MIGRATE_CANCEL_EVENT,
    &_TRACE_QMP_EXIT_MIGRATE_CANCEL_EVENT,
    &_TRACE_QMP_ENTER_MIGRATE_CONTINUE_EVENT,
    &_TRACE_QMP_EXIT_MIGRATE_CONTINUE_EVENT,
    &_TRACE_QMP_ENTER_MIGRATE_EVENT,
    &_TRACE_QMP_EXIT_MIGRATE_EVENT,
    &_TRACE_QMP_ENTER_MIGRATE_INCOMING_EVENT,
    &_TRACE_QMP_EXIT_MIGRATE_INCOMING_EVENT,
    &_TRACE_QMP_ENTER_XEN_SAVE_DEVICES_STATE_EVENT,
    &_TRACE_QMP_EXIT_XEN_SAVE_DEVICES_STATE_EVENT,
    &_TRACE_QMP_ENTER_XEN_SET_GLOBAL_DIRTY_LOG_EVENT,
    &_TRACE_QMP_EXIT_XEN_SET_GLOBAL_DIRTY_LOG_EVENT,
    &_TRACE_QMP_ENTER_XEN_LOAD_DEVICES_STATE_EVENT,
    &_TRACE_QMP_EXIT_XEN_LOAD_DEVICES_STATE_EVENT,
    &_TRACE_QMP_ENTER_XEN_SET_REPLICATION_EVENT,
    &_TRACE_QMP_EXIT_XEN_SET_REPLICATION_EVENT,
    &_TRACE_QMP_ENTER_QUERY_XEN_REPLICATION_STATUS_EVENT,
    &_TRACE_QMP_EXIT_QUERY_XEN_REPLICATION_STATUS_EVENT,
    &_TRACE_QMP_ENTER_XEN_COLO_DO_CHECKPOINT_EVENT,
    &_TRACE_QMP_EXIT_XEN_COLO_DO_CHECKPOINT_EVENT,
    &_TRACE_QMP_ENTER_QUERY_COLO_STATUS_EVENT,
    &_TRACE_QMP_EXIT_QUERY_COLO_STATUS_EVENT,
    &_TRACE_QMP_ENTER_MIGRATE_RECOVER_EVENT,
    &_TRACE_QMP_EXIT_MIGRATE_RECOVER_EVENT,
    &_TRACE_QMP_ENTER_MIGRATE_PAUSE_EVENT,
    &_TRACE_QMP_EXIT_MIGRATE_PAUSE_EVENT,
    &_TRACE_QMP_ENTER_CALC_DIRTY_RATE_EVENT,
    &_TRACE_QMP_EXIT_CALC_DIRTY_RATE_EVENT,
    &_TRACE_QMP_ENTER_QUERY_DIRTY_RATE_EVENT,
    &_TRACE_QMP_EXIT_QUERY_DIRTY_RATE_EVENT,
    &_TRACE_QMP_ENTER_SET_VCPU_DIRTY_LIMIT_EVENT,
    &_TRACE_QMP_EXIT_SET_VCPU_DIRTY_LIMIT_EVENT,
    &_TRACE_QMP_ENTER_CANCEL_VCPU_DIRTY_LIMIT_EVENT,
    &_TRACE_QMP_EXIT_CANCEL_VCPU_DIRTY_LIMIT_EVENT,
    &_TRACE_QMP_ENTER_QUERY_VCPU_DIRTY_LIMIT_EVENT,
    &_TRACE_QMP_EXIT_QUERY_VCPU_DIRTY_LIMIT_EVENT,
    &_TRACE_QMP_ENTER_SNAPSHOT_SAVE_EVENT,
    &_TRACE_QMP_EXIT_SNAPSHOT_SAVE_EVENT,
    &_TRACE_QMP_ENTER_SNAPSHOT_LOAD_EVENT,
    &_TRACE_QMP_EXIT_SNAPSHOT_LOAD_EVENT,
    &_TRACE_QMP_ENTER_SNAPSHOT_DELETE_EVENT,
    &_TRACE_QMP_EXIT_SNAPSHOT_DELETE_EVENT,
  NULL,
};

static void trace_qapi_commands_migration_trace_events_register_events(void)
{
    trace_event_register_group(qapi_commands_migration_trace_events_trace_events);
}
trace_init(trace_qapi_commands_migration_trace_events_register_events)
