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

#include "qemu/osdep.h"
#include "qapi/error.h"
#include "qapi/qmp/qerror.h"
#include "qapi-visit-injection.h"

bool visit_type_ReadValue_members(Visitor *v, ReadValue *obj, Error **errp)
{
    if (!visit_type_int(v, "value", &obj->value, errp)) {
        return false;
    }
    return true;
}

bool visit_type_ReadValue(Visitor *v, const char *name,
                 ReadValue **obj, Error **errp)
{
    bool ok = false;

    if (!visit_start_struct(v, name, (void **)obj, sizeof(ReadValue), errp)) {
        return false;
    }
    if (!*obj) {
        /* incomplete */
        assert(visit_is_dealloc(v));
        ok = true;
        goto out_obj;
    }
    if (!visit_type_ReadValue_members(v, *obj, errp)) {
        goto out_obj;
    }
    ok = visit_check_struct(v, errp);
out_obj:
    visit_end_struct(v, (void **)obj);
    if (!ok && visit_is_input(v)) {
        qapi_free_ReadValue(*obj);
        *obj = NULL;
    }
    return ok;
}

bool visit_type_q_obj_readmem_arg_members(Visitor *v, q_obj_readmem_arg *obj, Error **errp)
{
    if (!visit_type_int(v, "addr", &obj->addr, errp)) {
        return false;
    }
    if (!visit_type_int(v, "size", &obj->size, errp)) {
        return false;
    }
    if (visit_optional(v, "cpu", &obj->has_cpu)) {
        if (!visit_type_int(v, "cpu", &obj->cpu, errp)) {
            return false;
        }
    }
    if (visit_optional(v, "qom", &obj->has_qom)) {
        if (!visit_type_str(v, "qom", &obj->qom, errp)) {
            return false;
        }
    }
    return true;
}

bool visit_type_q_obj_writemem_arg_members(Visitor *v, q_obj_writemem_arg *obj, Error **errp)
{
    if (!visit_type_int(v, "addr", &obj->addr, errp)) {
        return false;
    }
    if (!visit_type_int(v, "val", &obj->val, errp)) {
        return false;
    }
    if (!visit_type_int(v, "size", &obj->size, errp)) {
        return false;
    }
    if (visit_optional(v, "cpu", &obj->has_cpu)) {
        if (!visit_type_int(v, "cpu", &obj->cpu, errp)) {
            return false;
        }
    }
    if (visit_optional(v, "qom", &obj->has_qom)) {
        if (!visit_type_str(v, "qom", &obj->qom, errp)) {
            return false;
        }
    }
    if (!visit_type_bool(v, "debug", &obj->debug, errp)) {
        return false;
    }
    return true;
}

bool visit_type_q_obj_triggerevent_arg_members(Visitor *v, q_obj_triggerevent_arg *obj, Error **errp)
{
    if (!visit_type_int(v, "timens", &obj->timens, errp)) {
        return false;
    }
    if (!visit_type_int(v, "eventid", &obj->eventid, errp)) {
        return false;
    }
    return true;
}

bool visit_type_q_obj_FAULT_EVENT_arg_members(Visitor *v, q_obj_FAULT_EVENT_arg *obj, Error **errp)
{
    if (!visit_type_int(v, "eventid", &obj->eventid, errp)) {
        return false;
    }
    if (!visit_type_int(v, "timens", &obj->timens, errp)) {
        return false;
    }
    return true;
}

bool visit_type_q_obj_injectgpio_arg_members(Visitor *v, q_obj_injectgpio_arg *obj, Error **errp)
{
    if (!visit_type_str(v, "devicename", &obj->devicename, errp)) {
        return false;
    }
    if (visit_optional(v, "gpio", &obj->has_gpio)) {
        if (!visit_type_str(v, "gpio", &obj->gpio, errp)) {
            return false;
        }
    }
    if (!visit_type_int(v, "num", &obj->num, errp)) {
        return false;
    }
    if (!visit_type_int(v, "val", &obj->val, errp)) {
        return false;
    }
    return true;
}

/* Dummy declaration to prevent empty .o file */
char qapi_dummy_qapi_visit_injection_c;
