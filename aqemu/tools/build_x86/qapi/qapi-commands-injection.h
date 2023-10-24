/* AUTOMATICALLY GENERATED, DO NOT MODIFY */

/*
 * Schema-defined QAPI/QMP commands
 *
 * Copyright IBM, Corp. 2011
 * Copyright (C) 2014-2018 Red Hat, Inc.
 *
 * This work is licensed under the terms of the GNU LGPL, version 2.1 or later.
 * See the COPYING.LIB file in the top-level directory.
 */

#ifndef QAPI_COMMANDS_INJECTION_H
#define QAPI_COMMANDS_INJECTION_H

#include "qapi-types-injection.h"

ReadValue *qmp_readmem(int64_t addr, int64_t size, bool has_cpu, int64_t cpu, bool has_qom, const char *qom, Error **errp);
void qmp_marshal_readmem(QDict *args, QObject **ret, Error **errp);
void qmp_writemem(int64_t addr, int64_t val, int64_t size, bool has_cpu, int64_t cpu, bool has_qom, const char *qom, bool debug, Error **errp);
void qmp_marshal_writemem(QDict *args, QObject **ret, Error **errp);
void qmp_triggerevent(int64_t timens, int64_t eventid, Error **errp);
void qmp_marshal_triggerevent(QDict *args, QObject **ret, Error **errp);
void qmp_injectgpio(const char *devicename, bool has_gpio, const char *gpio, int64_t num, int64_t val, Error **errp);
void qmp_marshal_injectgpio(QDict *args, QObject **ret, Error **errp);

#endif /* QAPI_COMMANDS_INJECTION_H */
