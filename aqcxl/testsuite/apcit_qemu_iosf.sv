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
        Example to simulate QEMU with Avery BFM.
*/

`timescale 1ps/1ps

program apcit_qemu_iosf;

import avery_pkg::*;
import apci_pkg::*;
import apci_pkg_test::*;
import qemu_simc_pkg::*;
`include "apci_defines.svh"
`include "qemu_enum.svh"
import qemu_rx_pkg::*;

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
        tlp_bookkept(tlp);
    endfunction

    virtual function void rx_pkt_enter_tl(
        apci_device   bfm,
        apci_tlp      tlp
    );
        dma_bookkept(tlp);
    endfunction

    virtual function void write_mem_cb(
        input bit             is_host_mem,
        input bit[63:0]       addr       ,
        input bit[3:0]        first_be   ,
        input bit[3:0]        last_be    ,
        ref   bit[31:0]       va[]       ,
        input avery_data_base src
    );
        if (is_host_mem) begin
            dma_bookcheck(addr, first_be, last_be, va);
        end
    endfunction
endclass

class mytest extends apci_testcase_base;
    mmio_callbacks mmio_cb;

    function new();
        super.new("apcit_qemu_iosf");
    endfunction

    virtual task test_body();
        apci_cfg_space   rc_cfg_spaces[$]; // cfg spaces for port0's functions
        bit sc_abort = 0;
        int result= 0, i;
        string keys[]= {`simcluster_QEMU_key};

        bit [31:0] mio_base_addr = 0;
        bit [31:0] mio_limit_addr = 0;
        bit [63:0] pref_mem_base_addr = 0;
        bit [63:0] pref_mem_limit_addr = 0;

`ifdef AVERY_CXL
        apci_cfg_seq_util cfg_util;
`endif

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
            // 1cH, IO limit and base
            // dv=1 to support 32-bit addressing. The upper 20-bit is used.
            // So it's 4k aligned. spec: PCI2PCI-bridge1.2 page 42
            // rc_cfg_spaces[0].type1.io_base.set_v(1);
            // rc_cfg_spaces[0].type1.io_limit.set_v(1);
            // rc_cfg_spaces[0].type1.secondary_status.set_v(1);

            // 20H, non-pretechable mem base and limit.
            // Only the upper 12-bit is used, so it's 1M aligned. spec: PCI2PCI-bridge1.2
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
            // rc_cfg_spaces[0].type1.ur_reporting_enable.set_v(1);
            // rc_cfg_spaces[0].type1.serr_enable.set_v(1);
            // 24H, prefetchable mem base and limit.
            // Only upper 12-bit is used, so it's 1M aligned.
            // rc_cfg_spaces[0].type1.pref_mem_base.set_v(1);
            // rc_cfg_spaces[0].type1.pref_mem_limit.set_v(1);

            // 28H, prefetchable mem base and limit upper
            // rc_cfg_spaces[0].type1.pref_mem_base_upper.set_v(1);

            // 2cH, pref mem limit upper
            // rc_cfg_spaces[0].type1.pref_mem_limit_upper.set_v(1);

            // 30H, IO limit upper
            // rc_cfg_spaces[0].type1.io_base_upper.set_v(1);
            // rc_cfg_spaces[0].type1.io_limit_upper.set_v(1);

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
        end join_none

`ifdef APCI_MPORT
        fork begin
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
        end join_none
`endif

        foreach (all_bfms[i]) begin
            all_bfms[i].port_wait_event(0, "dl_up");
        end

`ifdef AEMU_EP_BFM
	qemu_set_ep0(ep0);
`endif
`ifdef AVERY_CXL
        if (PM_SUP) begin
            test_log.step($psprintf("Power Management initialization"));
            rc.cxl_port_set(0, "initialize_pm", 1);
            rc.port_wait_cxl_event(0, "initialize_pm_done", 50us);
`ifndef AVERY_CXL_1_1
            cfg_util = new(rc);
            cfg_util.bdf_capability_search('h100, APCI_CAP_pm, pm_cap);
`endif
        end
`endif
        simcluster_master.setup_keys(keys);
`ifdef AVERY_SPDM
        result = spdm_sock_init();
        if (result == -1) begin
            $display("SPDM socket error!");
            $finish();
        end
`endif

        fork
            while (!sc_abort) qemu_wait_sc_cmd(sc_abort, rc, all_bfms);
`ifdef INTEL_IOSF
            forever test_dut(rc);
`endif
            forever @(posedge PERST_N or negedge PERST_N) $display("AEMU_INFO: PERST_N edge triggered 'h%x->h%x", !PERST_N, PERST_N);
            forever @(posedge RST_SG or negedge RST_SG) $display("AEMU_INFO: RESET SIGNAL edge triggered 'h%x->h%x", !RST_SG, RST_SG);
            forever @(negedge RST_SG) begin
                //* This part is for "Surprise System Reset"
                //* At "System Power Failure" situation do nothing
                if ((RST_TYPE == 0) && (PERST_N != 0)) rc.do_warm_reset(0);
`ifdef AEMU_EP_BFM
                if ((RST_TYPE == 0) && (PERST_N != 0)) ep0.do_warm_reset(0);
`endif
                @(posedge RST_SG);
                foreach (all_bfms[i]) begin
                    all_bfms[i].port_wait_event(0, "dl_up");
                end

`ifdef AVERY_CXL
                if (PM_SUP) begin
                    test_log.step($psprintf("Power Management initialization"));
                    rc.cxl_port_set(0, "initialize_pm", 1);
                    rc.port_wait_cxl_event(0, "initialize_pm_done", 50us);
`ifndef AVERY_CXL_1_1
                    cfg_util = new(rc);
                    cfg_util.bdf_capability_search('h100, APCI_CAP_pm, pm_cap);
`endif
                end
`endif

                rc_cfg_spaces[0].type1.bus_master_enable.set_v(1);
                rc_cfg_spaces[0].type1.mem_space_enable.set_v(1);
                rc_cfg_spaces[0].type1.io_space_enable.set_v(1);
                rc_cfg_spaces[0].type1.secondary_bus.set_v(1);
                rc_cfg_spaces[0].type1.subordinate_bus.set_v(1);
            end
        join_any
    endtask
endclass

`APCI_START_TEST
endprogram

// $Revision: 1.25 $
