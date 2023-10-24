/* AUTOMATICALLY GENERATED, DO NOT MODIFY */

/*
 * Schema-defined QAPI visitors
 *
 * Copyright IBM, Corp. 2011
 * Copyright (C) 2014-2018 Red Hat, Inc.
 *
 * This work is licensed under the terms of the GNU LGPL, version 2.1 or later.
 * See the COPYING.LIB file in the top-level directory.
 */

#ifndef QAPI_VISIT_INJECTION_H
#define QAPI_VISIT_INJECTION_H

#include "qapi/qapi-builtin-visit.h"
#include "qapi-types-injection.h"


bool visit_type_ReadValue_members(Visitor *v, ReadValue *obj, Error **errp);

bool visit_type_ReadValue(Visitor *v, const char *name,
                 ReadValue **obj, Error **errp);

bool visit_type_q_obj_readmem_arg_members(Visitor *v, q_obj_readmem_arg *obj, Error **errp);

bool visit_type_q_obj_writemem_arg_members(Visitor *v, q_obj_writemem_arg *obj, Error **errp);

bool visit_type_q_obj_triggerevent_arg_members(Visitor *v, q_obj_triggerevent_arg *obj, Error **errp);

bool visit_type_q_obj_FAULT_EVENT_arg_members(Visitor *v, q_obj_FAULT_EVENT_arg *obj, Error **errp);

bool visit_type_q_obj_injectgpio_arg_members(Visitor *v, q_obj_injectgpio_arg *obj, Error **errp);

#endif /* QAPI_VISIT_INJECTION_H */
