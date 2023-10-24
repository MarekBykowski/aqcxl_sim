/*
 * |-----------------------------------------------------------------------|
 * |                                                                       |
 * |   Copyright Avery Design Systems, Inc. 2022.                          |
 * |     All Rights Reserved.       Licensed Software.                     |
 * |                                                                       |
 * |                                                                       |
 * | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AVERY DESIGN SYSTEMS   |
 * | The copyright notice above does not evidence any actual or intended   |
 * | publication of such source code.                                      |
 * |                                                                       |
 * |-----------------------------------------------------------------------|
 */
`ifndef qemu2iosf_svh
`define qemu2iosf_svh

typedef struct{
    bit[31:0] pkt_type;
    bit[63:0] address;
    bit[15:0] bdf;
    bit[15:0] size;
    bit[7:0] cpl_status;
    bit[7:0] data[$];
} aiosf_pkt_t;

aiosf_pkt_t aiosf_cmd_Q[$];
aiosf_pkt_t aiosf_cpl_Q[$];
int aiosf_dbg = 0;

function void aiosf_set_dbg(input bit[31:0] level);
    $display("[AVERY] aiosf_set_dbg to level 'h%0h", level);
    aiosf_dbg = level;
endfunction

function automatic aiosf_get_kind(
    input apci_transaction tr,
    output bit[31:0] pkt_type
);
    if (tr.kind == APCI_TRANS_cfg) begin
        if (tr.is_write) pkt_type= 'h0;
        else pkt_type= 'h1;
    end
    else if (tr.kind inside {APCI_TRANS_mem, APCI_TRANS_io}) begin
        if (tr.is_write) pkt_type= 'h2;
        else pkt_type= 'h3;
    end else
        $display("[AVERY] ERROR: apci_transaction to iosf get_kind() unknown");
    return 0; 
endfunction

`protect
//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=prv(CDS_RSA_KEY_VER_2)
//pragma protect key_method=RSA
//pragma protect key_block
AohxLBnBFZyEeyBpa73wFA0qMrYKbRoMUFUFdwE2OoV0rlfDK0h1tDwBCFdfSTOj
9ZLLV6guUHy9lbk8QHEkA5gerrLp2yvnsZWxA3CfELXEaKvv0QpsNnALVvWOCYuv
h0UjMHNt2nbdz+seYHeqzigciSJXKK3U9m513lDl05df+zkgj06L/ifX4Jwzdv6Q
Hsdt+aEPZ770+UObDAkpaBrdQHzof/9tiKYPXR3PKr6B2/NYx97JI3YlLjrkDefK
4IF2Wofs674U7KRVqxtkimcfFMZOxDybsYZtztlBOD0fE5zSaXTm095plqD5adTU
TfK1n854fqvp9UsjQFwtzg==
//pragma protect end_key_block
//pragma protect digest_block
pO2Y9iU6+9nC/Zw32tXOPG3/HF0=
//pragma protect end_digest_block
//pragma protect data_block
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
//pragma protect end_data_block
//pragma protect digest_block
NIi1nR+LJ339xUkicd6HVlrdejA=
//pragma protect end_digest_block
//pragma protect end_protected
`endprotect

`endif

