/* AUTOMATICALLY GENERATED, DO NOT MODIFY */

/*
 * Schema-defined QAPI types
 *
 * Copyright IBM, Corp. 2011
 * Copyright (c) 2013-2018 Red Hat Inc.
 *
 * This work is licensed under the terms of the GNU LGPL, version 2.1 or later.
 * See the COPYING.LIB file in the top-level directory.
 */

#ifndef QAPI_TYPES_INJECTION_H
#define QAPI_TYPES_INJECTION_H

#include "qapi/qapi-builtin-types.h"

typedef struct ReadValue ReadValue;

typedef struct q_obj_readmem_arg q_obj_readmem_arg;

typedef struct q_obj_writemem_arg q_obj_writemem_arg;

typedef struct q_obj_triggerevent_arg q_obj_triggerevent_arg;

typedef struct q_obj_FAULT_EVENT_arg q_obj_FAULT_EVENT_arg;

typedef struct q_obj_injectgpio_arg q_obj_injectgpio_arg;

struct ReadValue {
    int64_t value;
};

void qapi_free_ReadValue(ReadValue *obj);
G_DEFINE_AUTOPTR_CLEANUP_FUNC(ReadValue, qapi_free_ReadValue)

struct q_obj_readmem_arg {
    int64_t addr;
    int64_t size;
    bool has_cpu;
    int64_t cpu;
    bool has_qom;
    char *qom;
};

struct q_obj_writemem_arg {
    int64_t addr;
    int64_t val;
    int64_t size;
    bool has_cpu;
    int64_t cpu;
    bool has_qom;
    char *qom;
    bool debug;
};

struct q_obj_triggerevent_arg {
    int64_t timens;
    int64_t eventid;
};

struct q_obj_FAULT_EVENT_arg {
    int64_t eventid;
    int64_t timens;
};

struct q_obj_injectgpio_arg {
    char *devicename;
    bool has_gpio;
    char *gpio;
    int64_t num;
    int64_t val;
};

#endif /* QAPI_TYPES_INJECTION_H */
