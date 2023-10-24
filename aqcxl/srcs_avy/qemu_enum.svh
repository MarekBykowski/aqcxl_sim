/* This section belongs to defines
* */
`define SPDM_MSG_SIZE_MAX 'h1200
//parameter QEMU_BUF_SIZE= 1024;
parameter QEMU_BUF_SIZE= `SPDM_MSG_SIZE_MAX; // max(qemupkt, spdmmax)

`define simcluster_QEMU_key "key_qemu"
`define simcluster_EDB_key "key_edb"
`define simcluster_SPDM_RES_key "key_spdm_res"
`ifdef AVY_PORT
parameter simcluster_SC_port= `AVY_PORT;
`else
parameter simcluster_SC_port= 9210;
`endif
parameter PKT_HEADER_LEN= 32; // len(qemu_pkt_t) in bytes
parameter CMD_HEADER_LEN= 16; // len(qemu_cmd_t) in bytes

//PCI Express Capability ID (spec. 7.5)
parameter PCI_EXP_CAPID= 'h10;
parameter PCI_PM_CAPID= 'h01;
parameter CAP_SLTCTL_OFFSET= 'h18;

//PCI-E Configuration Mechanisms (spec. 7.2)
parameter PCIE_EXT_OFFSET= 'h100;
parameter PCIE_CAP_OFFSET= 'h40;

const bit [7:0] toSC= 'b01;
const bit [7:0] toEDB= 'b10;
const bit [7:0] toBOTH= 'b11;

/* This section belongs to structs
* */
typedef struct packed {
    bit [15:0] size; // in bytes
    bit [15:0] cmd;
    bit [63:0] addr;
    bit [15:0] bdf;
    bit [7:0] first_be;
    bit [7:0] last_be;
    bit [63:0] simtime_cmd;
    bit [63:0] simtime_cpl;
} qemu_pkt_t; //tlm format fields

typedef struct packed {
    bit [15:0] size; // in bytes
    bit [15:0] cmd;
    bit [63:0] addr;
    bit [7:0] first_be;
    bit [7:0] last_be;
    bit [15:0] unused; //for alignment purpose
} qemu_cmd_t; //tlm format fields

typedef union packed {
    qemu_cmd_t header;
    bit [CMD_HEADER_LEN/4 - 1:0][31:0] dword; //length in [32]
} qemu_sv2sc_u;

typedef union packed {
    qemu_pkt_t header;
    bit [PKT_HEADER_LEN/4 - 1:0][31:0] dword; //length in [32]
} qemu_sc2sv_u;

/* This section belongs to enum
* for cmd, just use the cmd_e directly
* for resp, use cmd_e >> 8 | QEMU_CMD_RESP
* */
typedef enum bit [7:0] {
    QEMU_CMD_RESP= 0,
    QEMU_CMD_IORD= 1,
    QEMU_CMD_IOWR= 2,
    QEMU_CMD_CFGRD= 3,
    QEMU_CMD_CFGWR= 4,
    QEMU_CMD_INTR_ASSERT= 5,
    QEMU_CMD_INTR_DEASSERT= 6,
    QEMU_CMD_MEMRD= 7,
    QEMU_CMD_MEMWR= 8,
    QEMU_CMD_ATSREQ= 9,
    QEMU_CMD_ATSINV= 10,
    QEMU_CMD_MEMINV= 11,
    // sv utility cmd counts from backward
    QEMU_UTIL_HELLO= 252, // Dummy cmd for some simcluster child process which isn't an initiater, will be fixed in later PLI
    QEMU_SV_LOGERR= 253,
    QEMU_UTIL_DBGVERB= 254,
    QEMU_UTIL_SETSV= 255
} qemu_cmd_e;

typedef enum int {
    PCIE= 1,
    CXL= 2,
    AXI= 3,
    ENET= 4
} vip_type_e;

