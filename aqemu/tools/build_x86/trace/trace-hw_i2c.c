/* This file is autogenerated by tracetool, do not edit. */

#include "qemu/osdep.h"
#include "qemu/module.h"
#include "trace-hw_i2c.h"

uint16_t _TRACE_I2C_EVENT_DSTATE;
uint16_t _TRACE_I2C_SEND_DSTATE;
uint16_t _TRACE_I2C_SEND_ASYNC_DSTATE;
uint16_t _TRACE_I2C_RECV_DSTATE;
uint16_t _TRACE_I2C_ACK_DSTATE;
uint16_t _TRACE_ASPEED_I2C_BUS_CMD_DSTATE;
uint16_t _TRACE_ASPEED_I2C_BUS_RAISE_INTERRUPT_DSTATE;
uint16_t _TRACE_ASPEED_I2C_BUS_READ_DSTATE;
uint16_t _TRACE_ASPEED_I2C_BUS_WRITE_DSTATE;
uint16_t _TRACE_ASPEED_I2C_BUS_SEND_DSTATE;
uint16_t _TRACE_ASPEED_I2C_BUS_RECV_DSTATE;
uint16_t _TRACE_NPCM7XX_SMBUS_READ_DSTATE;
uint16_t _TRACE_NPCM7XX_SMBUS_WRITE_DSTATE;
uint16_t _TRACE_NPCM7XX_SMBUS_START_DSTATE;
uint16_t _TRACE_NPCM7XX_SMBUS_SEND_ADDRESS_DSTATE;
uint16_t _TRACE_NPCM7XX_SMBUS_SEND_BYTE_DSTATE;
uint16_t _TRACE_NPCM7XX_SMBUS_RECV_BYTE_DSTATE;
uint16_t _TRACE_NPCM7XX_SMBUS_STOP_DSTATE;
uint16_t _TRACE_NPCM7XX_SMBUS_NACK_DSTATE;
uint16_t _TRACE_NPCM7XX_SMBUS_RECV_FIFO_DSTATE;
uint16_t _TRACE_PCA954X_WRITE_BYTES_DSTATE;
uint16_t _TRACE_PCA954X_READ_DATA_DSTATE;
TraceEvent _TRACE_I2C_EVENT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "i2c_event",
    .sstate = TRACE_I2C_EVENT_ENABLED,
    .dstate = &_TRACE_I2C_EVENT_DSTATE 
};
TraceEvent _TRACE_I2C_SEND_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "i2c_send",
    .sstate = TRACE_I2C_SEND_ENABLED,
    .dstate = &_TRACE_I2C_SEND_DSTATE 
};
TraceEvent _TRACE_I2C_SEND_ASYNC_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "i2c_send_async",
    .sstate = TRACE_I2C_SEND_ASYNC_ENABLED,
    .dstate = &_TRACE_I2C_SEND_ASYNC_DSTATE 
};
TraceEvent _TRACE_I2C_RECV_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "i2c_recv",
    .sstate = TRACE_I2C_RECV_ENABLED,
    .dstate = &_TRACE_I2C_RECV_DSTATE 
};
TraceEvent _TRACE_I2C_ACK_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "i2c_ack",
    .sstate = TRACE_I2C_ACK_ENABLED,
    .dstate = &_TRACE_I2C_ACK_DSTATE 
};
TraceEvent _TRACE_ASPEED_I2C_BUS_CMD_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "aspeed_i2c_bus_cmd",
    .sstate = TRACE_ASPEED_I2C_BUS_CMD_ENABLED,
    .dstate = &_TRACE_ASPEED_I2C_BUS_CMD_DSTATE 
};
TraceEvent _TRACE_ASPEED_I2C_BUS_RAISE_INTERRUPT_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "aspeed_i2c_bus_raise_interrupt",
    .sstate = TRACE_ASPEED_I2C_BUS_RAISE_INTERRUPT_ENABLED,
    .dstate = &_TRACE_ASPEED_I2C_BUS_RAISE_INTERRUPT_DSTATE 
};
TraceEvent _TRACE_ASPEED_I2C_BUS_READ_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "aspeed_i2c_bus_read",
    .sstate = TRACE_ASPEED_I2C_BUS_READ_ENABLED,
    .dstate = &_TRACE_ASPEED_I2C_BUS_READ_DSTATE 
};
TraceEvent _TRACE_ASPEED_I2C_BUS_WRITE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "aspeed_i2c_bus_write",
    .sstate = TRACE_ASPEED_I2C_BUS_WRITE_ENABLED,
    .dstate = &_TRACE_ASPEED_I2C_BUS_WRITE_DSTATE 
};
TraceEvent _TRACE_ASPEED_I2C_BUS_SEND_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "aspeed_i2c_bus_send",
    .sstate = TRACE_ASPEED_I2C_BUS_SEND_ENABLED,
    .dstate = &_TRACE_ASPEED_I2C_BUS_SEND_DSTATE 
};
TraceEvent _TRACE_ASPEED_I2C_BUS_RECV_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "aspeed_i2c_bus_recv",
    .sstate = TRACE_ASPEED_I2C_BUS_RECV_ENABLED,
    .dstate = &_TRACE_ASPEED_I2C_BUS_RECV_DSTATE 
};
TraceEvent _TRACE_NPCM7XX_SMBUS_READ_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "npcm7xx_smbus_read",
    .sstate = TRACE_NPCM7XX_SMBUS_READ_ENABLED,
    .dstate = &_TRACE_NPCM7XX_SMBUS_READ_DSTATE 
};
TraceEvent _TRACE_NPCM7XX_SMBUS_WRITE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "npcm7xx_smbus_write",
    .sstate = TRACE_NPCM7XX_SMBUS_WRITE_ENABLED,
    .dstate = &_TRACE_NPCM7XX_SMBUS_WRITE_DSTATE 
};
TraceEvent _TRACE_NPCM7XX_SMBUS_START_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "npcm7xx_smbus_start",
    .sstate = TRACE_NPCM7XX_SMBUS_START_ENABLED,
    .dstate = &_TRACE_NPCM7XX_SMBUS_START_DSTATE 
};
TraceEvent _TRACE_NPCM7XX_SMBUS_SEND_ADDRESS_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "npcm7xx_smbus_send_address",
    .sstate = TRACE_NPCM7XX_SMBUS_SEND_ADDRESS_ENABLED,
    .dstate = &_TRACE_NPCM7XX_SMBUS_SEND_ADDRESS_DSTATE 
};
TraceEvent _TRACE_NPCM7XX_SMBUS_SEND_BYTE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "npcm7xx_smbus_send_byte",
    .sstate = TRACE_NPCM7XX_SMBUS_SEND_BYTE_ENABLED,
    .dstate = &_TRACE_NPCM7XX_SMBUS_SEND_BYTE_DSTATE 
};
TraceEvent _TRACE_NPCM7XX_SMBUS_RECV_BYTE_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "npcm7xx_smbus_recv_byte",
    .sstate = TRACE_NPCM7XX_SMBUS_RECV_BYTE_ENABLED,
    .dstate = &_TRACE_NPCM7XX_SMBUS_RECV_BYTE_DSTATE 
};
TraceEvent _TRACE_NPCM7XX_SMBUS_STOP_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "npcm7xx_smbus_stop",
    .sstate = TRACE_NPCM7XX_SMBUS_STOP_ENABLED,
    .dstate = &_TRACE_NPCM7XX_SMBUS_STOP_DSTATE 
};
TraceEvent _TRACE_NPCM7XX_SMBUS_NACK_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "npcm7xx_smbus_nack",
    .sstate = TRACE_NPCM7XX_SMBUS_NACK_ENABLED,
    .dstate = &_TRACE_NPCM7XX_SMBUS_NACK_DSTATE 
};
TraceEvent _TRACE_NPCM7XX_SMBUS_RECV_FIFO_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "npcm7xx_smbus_recv_fifo",
    .sstate = TRACE_NPCM7XX_SMBUS_RECV_FIFO_ENABLED,
    .dstate = &_TRACE_NPCM7XX_SMBUS_RECV_FIFO_DSTATE 
};
TraceEvent _TRACE_PCA954X_WRITE_BYTES_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "pca954x_write_bytes",
    .sstate = TRACE_PCA954X_WRITE_BYTES_ENABLED,
    .dstate = &_TRACE_PCA954X_WRITE_BYTES_DSTATE 
};
TraceEvent _TRACE_PCA954X_READ_DATA_EVENT = {
    .id = 0,
    .vcpu_id = TRACE_VCPU_EVENT_NONE,
    .name = "pca954x_read_data",
    .sstate = TRACE_PCA954X_READ_DATA_ENABLED,
    .dstate = &_TRACE_PCA954X_READ_DATA_DSTATE 
};
TraceEvent *hw_i2c_trace_events[] = {
    &_TRACE_I2C_EVENT_EVENT,
    &_TRACE_I2C_SEND_EVENT,
    &_TRACE_I2C_SEND_ASYNC_EVENT,
    &_TRACE_I2C_RECV_EVENT,
    &_TRACE_I2C_ACK_EVENT,
    &_TRACE_ASPEED_I2C_BUS_CMD_EVENT,
    &_TRACE_ASPEED_I2C_BUS_RAISE_INTERRUPT_EVENT,
    &_TRACE_ASPEED_I2C_BUS_READ_EVENT,
    &_TRACE_ASPEED_I2C_BUS_WRITE_EVENT,
    &_TRACE_ASPEED_I2C_BUS_SEND_EVENT,
    &_TRACE_ASPEED_I2C_BUS_RECV_EVENT,
    &_TRACE_NPCM7XX_SMBUS_READ_EVENT,
    &_TRACE_NPCM7XX_SMBUS_WRITE_EVENT,
    &_TRACE_NPCM7XX_SMBUS_START_EVENT,
    &_TRACE_NPCM7XX_SMBUS_SEND_ADDRESS_EVENT,
    &_TRACE_NPCM7XX_SMBUS_SEND_BYTE_EVENT,
    &_TRACE_NPCM7XX_SMBUS_RECV_BYTE_EVENT,
    &_TRACE_NPCM7XX_SMBUS_STOP_EVENT,
    &_TRACE_NPCM7XX_SMBUS_NACK_EVENT,
    &_TRACE_NPCM7XX_SMBUS_RECV_FIFO_EVENT,
    &_TRACE_PCA954X_WRITE_BYTES_EVENT,
    &_TRACE_PCA954X_READ_DATA_EVENT,
  NULL,
};

static void trace_hw_i2c_register_events(void)
{
    trace_event_register_group(hw_i2c_trace_events);
}
trace_init(trace_hw_i2c_register_events)
