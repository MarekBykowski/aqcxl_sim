/*
 * |-----------------------------------------------------------------------|
 * |                                                                       |
 * |   Copyright Avery Design Systems, Inc. 2021.                          |
 * |     All Rights Reserved.       Licensed Software.                     |
 * |                                                                       |
 * |                                                                       |
 * | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AVERY DESIGN SYSTEMS   |
 * | The copyright notice above does not evidence any actual or intended   |
 * | publication of such source code.                                      |
 * |                                                                       |
 * |-----------------------------------------------------------------------|
 */

/*
    .Purpose:
    Example shows how to generate ATS and use phys addr to do memory transfer.
*/

`timescale 1ps/1ps

program apcit_qemu_ats;

import avery_pkg::*;
import apci_pkg::*;
import apci_pkg_test::*;
import qemu_simc_pkg::*;
`include "apci_defines.svh"
`include "qemu_enum.svh"
import qemu_rx_pkg::*;
`include "qemu_rx_cmd.svh"

class mmio_callbacks extends apci_callbacks;
    apci_device bfm_handle;
    bit[7:0] msg[QEMU_BUF_SIZE - 1:0];

    function new(apci_device bfm_handle);
        this.bfm_handle = bfm_handle;
    endfunction

    virtual function void tx_pkt_exit_tl(
        apci_device   bfm,
        apci_tlp      tlp
    );
        static int rd_cnt = 0;
        // One mem_read tlp(tlp.req) may correspond to many cpld tlps(tlp). So we have to
        // calculate offset before we send a packet to host (qemu_dma_cmd).
        if (tlp.is_cpld() && tlp.req.is_mem_rd()) begin
            tlp.annotate($psprintf("From %0s addr 'h%0h length 'h%0h", tlp.sprint(0),
                tlp.req.get_addr(), tlp.get_length_dw()));
            mrd_dropped_cpld_tlp[tlp.req.get_addr()].push_back(tlp);

            tlp.user_ctrl.is_drop = 1;
        end
    endfunction

    virtual function void rx_pkt_enter_tl(
        apci_device   bfm,
        apci_tlp      tlp
    );
        static int rd_cnt = 0;
        bit[31:0]       memrd_dw;
        bit[63:0]       addr;
        bit[3:0]        first_be;
        bit[3:0]        last_be;
        qemu_cmd_e cmd= QEMU_CMD_IORD;

        if (!tlp.is_cpld() && tlp.is_mem_rd() || tlp.is_ats_request()) begin
            addr        = tlp.get_addr();
            memrd_dw    = tlp.get_length_dw();
            first_be   = tlp.get_first_be();
            last_be   = tlp.get_last_be();
            test_log.info($psprintf("RC RX received read_cb#%0d ADDR 'h%0h NDW 'h%0h", ++rd_cnt, addr, memrd_dw));
            if (tlp.is_ats_request())
                cmd = QEMU_CMD_ATSREQ;
            void'(qemu_dma_cmd(cmd, addr, memrd_dw, first_be, last_be, tlp.payload, msg));
        end
        if (tlp.u.msg.msg_code inside { APCI_MSG_assert_inta,
            APCI_MSG_assert_intb, APCI_MSG_assert_intc, APCI_MSG_assert_intd}) begin
`ifdef QEMU_DBG2
            $display("[rx_pkt_enter_tl] irq assert\n");
`endif
            void'(qemu_cmd_send(QEMU_CMD_INTR_ASSERT, 0, 0, msg));
        end else if (tlp.u.msg.msg_code inside { APCI_MSG_deassert_inta,
            APCI_MSG_deassert_intb, APCI_MSG_deassert_intc, APCI_MSG_deassert_intd}) begin
`ifdef QEMU_DBG2
            $display("[rx_pkt_enter_tl] irq deassert\n");
`endif
            void'(qemu_cmd_send(QEMU_CMD_INTR_DEASSERT, 0, 0, msg));
        end
    endfunction

    virtual function void write_mem_cb(
        input bit             is_host_mem,
        input bit[63:0]       addr       ,
        input bit[3:0]        first_be   ,
        input bit[3:0]        last_be    ,
        ref   bit[31:0]       va[]       ,
        input avery_data_base src
    );
        static int wr_cnt = 0;

        void'(qemu_dma_cmd(QEMU_CMD_IOWR, addr, va.size(), first_be, last_be, va, msg));
        wr_cnt++;
        test_log.info($psprintf("RC received write_cb#%0d: ADDR 'h%0h, FBE 'h%0h, LBE 'h%0h", wr_cnt, addr, first_be, last_be));
    endfunction
endclass

class mem_callback_ep extends apci_callbacks;
    apci_device bfm_handle;
`ifdef AVERY_CXL_1_1
        bit [63:0] ep_bar_offset= 64'ha_0010_1000;
`else
        bit [63:0] ep_bar_offset= 64'h8_0030_0000;
`endif
    /*  0x0 host physical address (high)
        0x4 host physical address (low)
        0x8 # of DWs
        0xc opcode (0=RD, 1=WR)
        0x10 enable (1=start)
        0x14 done
    */
    bit [63:0] host_address;
    bit [31:0] num_dwords;
    bit [31:0] enable;

    function new(apci_device bfm_handle);
        this.bfm_handle = bfm_handle;
        enable= 0;
    endfunction

    virtual function void read_mem_cb(
        input bit             is_host_mem,
        input bit[63:0]       addr       ,
        input bit[31:0]       ndw        ,
        input bit[3:0]        first_be   ,
        input bit[3:0]        last_be    ,
        ref   bit[31:0]       va[]       ,
        input avery_data_base src);
        int size, resp_err;
        static int rd_cnt = 0;

        if ((addr - ep_bar_offset) == 32'h14) begin
            test_log.info($psprintf("EP-DMA: received Read to offset 0x14 ( done bit ) %b", va[0]));
        end
    endfunction

    virtual function void write_mem_cb(
        input bit             is_host_mem,
        input bit[63:0]       addr       ,
        input bit[3:0]        first_be   ,
        input bit[3:0]        last_be    ,
        ref   bit[31:0]       va[]       ,
        input avery_data_base src);
        int size, resp_err;
        static int wr_cnt= 0;

        case(addr - ep_bar_offset)
            32'h0: begin
                host_address = 64'h10000000;
                num_dwords = 32 * 1024;
                enable = 1;
                test_log.info($psprintf("EP-DMA: ATS [ host_address ] = %h ", host_address));
                test_log.info($psprintf("EP-DMA: ATS [ num_dwords  ] = %h ", num_dwords));
                test_log.info($psprintf("EP-DMA: ATS [ enable ] = %h ", enable));
            end
            default:
                test_log.info($psprintf("EP-DMA: received Write to offset %h ep_bar_offset %h", addr, ep_bar_offset));
        endcase
    endfunction
endclass


class mytest extends apci_testcase_base;
    mmio_callbacks mmio_cb;
    mem_callback_ep dma_cb;

    function new();
        super.new("apcit_qemu_ats");
    endfunction

    virtual task pre_bfm_started();
        foreach(all_bfms[i]) begin
            all_bfms[i].cfg_info.ATS_sup = 1;
            all_bfms[i].cfg_info.PRI_sup = 1;
        end
    endtask

    virtual task test_body();
        apci_cfg_space   rc_cfg_spaces[$]; // cfg spaces for port0's functions
        bit sc_abort = 0;
        string keys[]= {`simcluster_QEMU_key};

        bit [31:0] mio_base_addr = 0;
        bit [31:0] mio_limit_addr = 0;
`ifdef AVERY_CXL_1_1
        bit [63:0] pref_mem_base_addr = 64'ha_0010_0000;
        bit [63:0] pref_mem_limit_addr = 64'ha_0020_0000;
`else
        bit [63:0] pref_mem_base_addr = 0;
        bit [63:0] pref_mem_limit_addr = 0;
`endif
        byte stu = 2; // 16k: (2 + 12) ^ 2
        apci_atpt_entry_t atpt_entry;

        //DMA variables
        bit continue_polling_for_dma = 1;

        //Poll for DMA to complete
`ifdef AVERY_CXL_1_1
        bit [63:0] ep_bar_offset= 64'ha_0010_1000;
`else
        bit [63:0] ep_bar_offset= 64'h8_0030_0000;
`endif
        apci_bar_t ranges[$];

        if (bfm.get("dev_type") != APCI_DEVICE_rc)
            return;

        begin
            rc.port_get_cfg_space(-1, rc_cfg_spaces);

//          rc.log.dbg_flag[APCI_DBG_api] = 1;
//          rc.log.dbg_flag[APCI_DBG_api_verbose] = 1;
//          rc.log.dbg_flag[APCI_DBG_api_exit] = 1;
//          rc.log.dbg_flag[APCI_DBG_tag] = 1;
//          rc.log.dbg_flag[APCI_DBG_tlp] = 1;
//          rc.log.dbg_flag[APCI_DBG_tlp_data] = 1;
//          rc.log.dbg_flag[APCI_DBG_tlp_data_all] = 1;
//          rc.log.dbg_flag[APCI_DBG_hang] = 1;
//          rc.log.dbg_flag[APCI_DBG_cpl] = 1;
//          rc.log.dbg_flag[APCI_DBG_tr] = 1;
//          rc.log.dbg_flag[APCI_DBG_credit] = 1;
//          rc.log.dbg_flag[APCI_DBG_cfg] = 1;
//          rc.log.dbg_flag[APCI_DBG_mem] = 1;
//          rc.log.dbg_flag[APCI_DBG_credit] = 1;

            rc_cfg_spaces[0].type1.bus_master_enable.set_v(1);
            rc_cfg_spaces[0].type1.mem_space_enable.set_v(1);
            rc_cfg_spaces[0].type1.io_space_enable.set_v(1);
            rc_cfg_spaces[0].type1.secondary_bus.set_v(1);
            rc_cfg_spaces[0].type1.subordinate_bus.set_v(1);

            rc_cfg_spaces[0].type1.bar0.set_write_mask('hffff_ffff);
            rc_cfg_spaces[0].type1.bar1.set_write_mask('hffff_ffff);

`ifdef APCI_MPORT
            rc_cfg_spaces[1].type1.bus_master_enable.set_v(1);
            rc_cfg_spaces[1].type1.mem_space_enable.set_v(1);
            rc_cfg_spaces[1].type1.io_space_enable.set_v(1);
            rc_cfg_spaces[1].type1.secondary_bus.set_v(2);
            rc_cfg_spaces[1].type1.subordinate_bus.set_v(2);

            rc_cfg_spaces[1].type1.bar0.set_write_mask('hffff_ffff);
            rc_cfg_spaces[1].type1.bar1.set_write_mask('hffff_ffff);
`endif
            rc_cfg_spaces[0].type1.mio_base.set_v(mio_base_addr >> 16);
            rc_cfg_spaces[0].type1.mio_limit.set_v(mio_limit_addr >> 16);

            rc_cfg_spaces[0].type1.pref_mem_base.set_v((pref_mem_base_addr >> 16) & 'hffff);
            rc_cfg_spaces[0].type1.pref_mem_limit.set_v((pref_mem_limit_addr >> 16) & 'hffff);
            rc_cfg_spaces[0].type1.pref_mem_base_upper.set_v(pref_mem_base_addr >> 32);
            rc_cfg_spaces[0].type1.pref_mem_limit_upper.set_v(pref_mem_limit_addr >> 32);

            rc_cfg_spaces[0].type1.io_base.set_v('h0000_0000 >> 16);
            rc_cfg_spaces[0].type1.io_limit.set_v('h0000_0000 >> 16);

`ifdef APCI_MPORT
            rc_cfg_spaces[1].type1.mio_base.set_v(mio_base_addr >> 16);
            rc_cfg_spaces[1].type1.mio_limit.set_v(mio_limit_addr >> 16);

            rc_cfg_spaces[1].type1.pref_mem_base.set_v((pref_mem_base_addr >> 16) & 'hffff);
            rc_cfg_spaces[1].type1.pref_mem_limit.set_v((pref_mem_limit_addr >> 16) & 'hffff);
            rc_cfg_spaces[1].type1.pref_mem_base_upper.set_v(pref_mem_base_addr >> 32);
            rc_cfg_spaces[1].type1.pref_mem_limit_upper.set_v(pref_mem_limit_addr >> 32);

            rc_cfg_spaces[1].type1.io_base.set_v('h0000_0000 >> 16);
            rc_cfg_spaces[1].type1.io_limit.set_v('h0000_0000 >> 16);
`endif
`ifdef AVERY_CXL
            // function void set_evict_mode(input bit[3:0] mode, input bit[63:0] num_lines);
            // modes
            // 0	Evict line when all bytes in cache line have been written
            // 1	Enable evict for ranges set using set_writethrough()
            // 2	Evict using LRU when valid cachelines >= num_lines
            // 3	Evict random valid line when valid cachelines >= num_lines
            // default: mode = 'b11, num_lines = 16
            set_evict_mode(4'b0011, 16);
`endif
        end

        mmio_cb = new(rc);
        rc.append_callback(mmio_cb);
// TODO replace this backdoor into APCI_SIM APIs
`ifdef AVERY_CXL_1_1
        atc_mgr = new('h000);
        rc.ats_ta.atc_mgrs['h000] = atc_mgr;
`else
        atc_mgr = new('h100);
        rc.ats_ta.atc_mgrs['h100] = atc_mgr;
`endif
        atc_mgr.stu = stu;
        atc_mgr.enabled = 1;
        continue_polling_for_dma = 1;

        fork begin
            forever begin
            @(
                rc_cfg_spaces[0].type1.mio_base.v or
                rc_cfg_spaces[0].type1.mio_limit.v or
                rc_cfg_spaces[0].type1.pref_mem_base.v or
                rc_cfg_spaces[0].type1.pref_mem_limit.v or
                rc_cfg_spaces[0].type1.pref_mem_base_upper.v or
                rc_cfg_spaces[0].type1.pref_mem_limit_upper.v
            );

            $display("rc_cfg_spaces[0].type1.mio_base : 'h%0h",
                rc_cfg_spaces[0].type1.mio_base.v);
            $display("rc_cfg_spaces[0].type1.mio_limit : 'h%0h",
                rc_cfg_spaces[0].type1.mio_limit.v);
            $display("rc_cfg_spaces[0] pref_mem_base : 'h%0h",
                rc_cfg_spaces[0].type1.pref_mem_base_upper.v << 16 | rc_cfg_spaces[0].type1.pref_mem_base.v);
            $display("rc_cfg_spaces[0] pref_mem_limit : 'h%0h",
                rc_cfg_spaces[0].type1.pref_mem_limit_upper.v << 16 | rc_cfg_spaces[0].type1.pref_mem_limit.v);
            end
`ifdef APCI_MPORT
            forever begin
            @(
                rc_cfg_spaces[1].type1.mio_base.v or
                rc_cfg_spaces[1].type1.mio_limit.v or
                rc_cfg_spaces[1].type1.pref_mem_base.v or
                rc_cfg_spaces[1].type1.pref_mem_limit.v or
                rc_cfg_spaces[1].type1.pref_mem_base_upper.v or
                rc_cfg_spaces[1].type1.pref_mem_limit_upper.v
            );

            $display("rc_cfg_spaces[1].type1.mio_base : 'h%0h",
                rc_cfg_spaces[1].type1.mio_base.v);
            $display("rc_cfg_spaces[1].type1.mio_limit : 'h%0h",
                rc_cfg_spaces[1].type1.mio_limit.v);
            $display("rc_cfg_spaces[1] pref_mem_base : 'h%0h",
                rc_cfg_spaces[1].type1.pref_mem_base_upper.v << 16 | rc_cfg_spaces[1].type1.pref_mem_base.v);
            $display("rc_cfg_spaces[1] pref_mem_limit : 'h%0h",
                rc_cfg_spaces[1].type1.pref_mem_limit_upper.v << 16 | rc_cfg_spaces[1].type1.pref_mem_limit.v);
            end
`endif
        end join_none

        foreach (all_bfms[i]) begin
            all_bfms[i].port_wait_event(0, "dl_up");
        end

        simcluster_master.setup_keys(keys);

        fork:ep_dma_blk
            apci_transaction dma_tr;
            apci_tlp ats_tlp;

            wait(ep0 != null);
            dma_cb = new(ep0);
            dma_cb.ep_bar_offset = ep_bar_offset;

            // Enable DMA related calback
            ep0.append_callback(dma_cb);

            while(continue_polling_for_dma) begin
                bit [31:0] va[];
                bit [63:0] done_addr, phys_addr;
                int dma_data = 'hdeadbeef;
                #100; // delay for order
                wait(dma_cb.enable == 1);
                test_log.step("Step 1: Trigger EP to send ATC translate requests");
                // TODO: check all values are correctly programmed
                if (atpt_entry.uaddr != dma_cb.host_address) begin
                    atpt_entry.bdf            = 0;// the pcie function's requester ID
                    atpt_entry.stu            = stu;
                    atpt_entry.uaddr          = dma_cb.host_address;
                    atpt_entry.len            = dma_cb.num_dwords;
                    atpt_entry.xaddr          = dma_cb.host_address + atpt_entry.len;
                    atpt_entry.no_snoop       = 0;
                    atpt_entry.untrans_access = 0;
                    atpt_entry.write          = 1;
                    atpt_entry.read           = 1;
                    rc.ats_add_atpt_entry(atpt_entry);
                end
                #100; // delay for order
                // Generate ATS request for 1 STU
                ats_tlp = new();
                void'(ats_tlp.randomize() with {
                    kind == APCI_TLP_mrd;
                    rand_addr inside {[dma_cb.host_address : dma_cb.host_address]};
                    u.req.length == 2;
                    u.req.at == 1;
                    u.req.lbe == 4'b1111;
                    u.req.fbe == 4'b1111;
                });
                ep0.post_tlp(ats_tlp);
                ats_tlp.wait_done(1e9, "from ep_dma_blk: ATS response not received");

                /* this adds xaddr to RC atpt entry address range
                   xaddr is only obtainable after host passes down ATSREQ resp
                   */
                wait (phys_addr != ats_xaddr);
                test_log.step("Step 2: Received translated address, updating atpt_entry");
                phys_addr = ats_xaddr;
                rc.ats_remove_atpt_entry(dma_cb.host_address, 'h100);
                atpt_entry.xaddr          = ats_xaddr;
                rc.ats_add_atpt_entry(atpt_entry);

                test_log.step("Step 3: EP sending DMA Transacions using ATS addresses");
                begin
                    dma_tr = new();
                    ok = dma_tr.randomize() with {
                        kind == APCI_TRANS_mem;
                        addr inside {[phys_addr : phys_addr]};
                        length == 8;
                        is_write  == 1;
                        };
                    if (!ok) test_log.fatal("randomization failed");
                    dma_tr.no_snoop = 0;
                    dma_tr.user_ctrl.at = 2;
                    dma_tr.user_ctrl.ats_nw = $urandom;
                    for(int i= 0; i < dma_tr.length; i++) begin
                        dma_tr.payload.push_back(dma_data);
                        dma_data = dma_data << 8;
		            end
                    ep0.post_transaction(dma_tr);
                end

                dma_cb.enable = 0;
                va = new[1];
                va[0] = 32'h1;
                done_addr = ep_bar_offset + 'h14;
                ep0.set_mem_dwords(done_addr, va, "Writing to DMA done bit" ) ;
            end//while
        join_none

        fork
            while (!sc_abort) qemu_wait_sc_cmd(sc_abort, rc, all_bfms);
        join_any
    endtask
endclass

`APCI_START_TEST
endprogram
