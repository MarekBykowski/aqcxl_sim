/*
 * |-----------------------------------------------------------------------|
 * |                                                                       |
 * |   Copyright Avery Design Systems, Inc. 2020.                          |
 * |     All Rights Reserved.       Licensed Software.                     |
 * |                                                                       |
 * |                                                                       |
 * | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AVERY DESIGN SYSTEMS   |
 * | The copyright notice above does not evidence any actual or intended   |
 * | publication of such source code.                                      |
 * |                                                                       |
 * |-----------------------------------------------------------------------|
 */

`timescale 1ps/1ps

/* If you replace ep0 BFM by DUT:

   1. Copy this file and remove all occurrence of ep0

   2. If use run_apci.pl, pass your own version of apci_top in this way:
        run_apci.pl -T my_apci_top.sv

*/

`include "apci_defines.svh"

`ifdef AVERY_NVME
`ifdef AEMU_EP_BFM
    `include "anvm_defines.svh"
`elsif AEMU_HSW_BFM
    `include "anvm_defines.svh"
`endif
`endif

module apci_top;

import avery_pkg::*;
import apci_pkg::*;

`ifdef AVERY_NVME
`ifdef AEMU_EP_BFM
    import anvm_pkg::*;
    import anvm_pcie_pkg::*;
`elsif AEMU_HSW_BFM
    import anvm_pkg::*;
    import anvm_pcie_pkg::*;
`endif
`endif

`ifdef AEMU_HSW_BFM
    import anvm_pkg_test::*;
`else
    import apci_pkg_test::*;
`endif

`ifdef ANVM_MONITOR
`include "anvm_ctrler_adaptor_monitor.sv"
monitor_cb mon_cb0;
anvm_ctrler_adaptor_monitor  adaptor_monitor0;

`endif //ANVM_MONITOR

`ifdef AVERY_AXI_BFM
//`include "aaxi_basic.h"
    import aaxi_pkg::*;
    import aaxi_pkg_xactor::*;
`endif

apci_device rc;
`ifdef AEMU_HSW_BFM
anvm_host_software       hsw; // the NVMe host software
anvm_host_nRC_adaptor    hadpt0; // Glue the software and PCIe host
`endif

`ifndef APCI_NUM_LANES
    `define APCI_NUM_LANES 8
`endif
`ifndef APCI_COMMON_CLOCK
    `define APCI_COMMON_CLOCK 0
`endif
`ifndef APCI_PCLK_AS_PHY_INPUT
    `define APCI_PCLK_AS_PHY_INPUT 0
`endif

`ifdef APCI_FIXED_WIDTH
    parameter GEN1_W   = 4;
    parameter GEN2_W   = 4;
    parameter GEN3_W   = 4;
    parameter GEN4_W   = 4;
    parameter GEN5_W   = 4;
    parameter GEN6_W   = 4;
    parameter CCIX_20G_W = 4;
    parameter CCIX_25G_W = 4;
    parameter GEN1_CLK = 0; // 62.5M
    parameter GEN2_CLK = 1; // 125M
    parameter GEN3_CLK = 2;
    parameter GEN4_CLK = 3;
    parameter GEN5_CLK = 4; // 1000M
    parameter GEN5_CLK = 5; // 2000M
    parameter CCIX_20G_CLK = 0; // 625M
    parameter CCIX_25G_CLK = 1; // 781.25M
`elsif APCI_FIXED_CLK // fixed  clock
    parameter GEN1_W   = 1;
    parameter GEN2_W   = 2;
    parameter GEN3_W   = 4;
    parameter GEN4_W   = 4;
    parameter GEN5_W   = `APCI_GEN5_DW;
    parameter GEN6_W   = 4;
    parameter CCIX_20G_W = `APCI_CCIX_20G_DW;
    parameter CCIX_25G_W = `APCI_CCIX_25G_DW;
    parameter GEN1_CLK = 2; // 2: 250M
    parameter GEN2_CLK = 2;
    parameter GEN3_CLK = 2;
    parameter GEN4_CLK = 3; // 3: 500M
    parameter GEN5_CLK = `APCI_GEN5_CLK; // 4: 1000M
    parameter GEN6_CLK = 5; // 5: 2000M
    parameter CCIX_20G_CLK = `APCI_CCIX_20G_CLK; // 3: 500M
    parameter CCIX_25G_CLK = `APCI_CCIX_25G_CLK; // 3: 500M
`else
    `ifdef AEMU_EP_UNEX
    parameter GEN1_W   = 4;
    parameter GEN2_W   = 4;
    `else
    parameter GEN1_W   = 2;
    parameter GEN2_W   = 2;
    `endif
    parameter GEN3_W   = 4;
    parameter GEN4_W   = 4;
    parameter GEN5_W   = 4;
    parameter GEN6_W   = 4;
    parameter CCIX_20G_W = 4;
    parameter CCIX_25G_W = 4;
    `ifdef AEMU_EP_UNEX
    parameter GEN1_CLK = 0; // 0: 62.5M
    parameter GEN2_CLK = 1; // 1: 125M
    `else
    parameter GEN1_CLK = 1; // 1: 125M
    parameter GEN2_CLK = 2; // 2: 250M
    `endif
    parameter GEN3_CLK = 2; // 3: 250M
    parameter GEN4_CLK = 3;
    parameter GEN5_CLK = 4; // 1000M
    parameter GEN6_CLK = 5; // 2000M
    parameter CCIX_20G_CLK = 0; // 625M
    parameter CCIX_25G_CLK = 1; // 781.25M
`endif

apci_pipe_intf rc_pif[`APCI_NUM_LANES]();
apci_pipe_intf ep_pif[`APCI_NUM_LANES]();

`ifdef APCI_MPORT
apci_pipe_intf rc_pif1[`APCI_NUM_LANES]();
apci_pipe_intf ep_pif1[`APCI_NUM_LANES]();

`endif

`ifdef AEMU_EP_BFM
`ifdef AEMU_EP_UNEX
    `include "connect_ep_unex.svh"
`else
    `include "connect_ep_bfm.svh"
`ifdef ACXL_AXI_MC
    `include "apci_backend_tb.svh"
`endif // ACXL_AXI_MC
`endif // AEMU_EP_UNEX
`endif // AEMU_EP_BFM

`ifdef APCI_NEW_PHY
    wire [`APCI_NUM_LANES-1:0] tx_data, tx_datan, rx_data, rx_datan;
    wire clkreq_n; // optional for L1 PM Substates
    apci_phy #(
	`ifdef APCI_SERDES_MODE
	.SERDES_MODE      (1),
	.PCLK_AS_PHY_INPUT(1),
	`endif
	.COMMON_CLOCK    (`APCI_COMMON_CLOCK),
	.NUM_LANES       (`APCI_NUM_LANES),
	`ifdef APCI_DISABLE_PAM4
	.PAM4_2BIT_ENCODE(0),
	`endif
	.GEN1_DATA_WIDTH (GEN1_W  ),
	.GEN2_DATA_WIDTH (GEN2_W  ),
	.GEN3_DATA_WIDTH (GEN3_W  ),
	.GEN4_DATA_WIDTH (GEN4_W  ),
	.GEN5_DATA_WIDTH (GEN5_W  ),
	.GEN6_DATA_WIDTH (GEN6_W  ),
	.GEN1_CLOCK_RATE (GEN1_CLK),
	.GEN2_CLOCK_RATE (GEN2_CLK),  //  1: 125, 2: 250 Mhz, 3: 500Mhs
	.GEN3_CLOCK_RATE (GEN3_CLK),
	.GEN4_CLOCK_RATE (GEN4_CLK),
	.GEN5_CLOCK_RATE (GEN5_CLK),
	.GEN6_CLOCK_RATE (GEN6_CLK)
    ) rc_phy(
	.pifs(rc_pif),
	.txp(tx_data),
	.txn(tx_datan),
	.rxp(rx_data),
	.rxn(rx_datan),
	.clkreq_n (clkreq_n)
    );
    apci_phy #(
	`ifdef APCI_SERDES_MODE
	.SERDES_MODE      (1),
	.PCLK_AS_PHY_INPUT(1),
	`endif
	.COMMON_CLOCK    (`APCI_COMMON_CLOCK),
	.NUM_LANES       (`APCI_NUM_LANES),
	`ifdef APCI_DISABLE_PAM4
	.PAM4_2BIT_ENCODE(0),
	`endif
	.GEN1_DATA_WIDTH (GEN1_W  ),
	.GEN2_DATA_WIDTH (GEN2_W  ),
	.GEN3_DATA_WIDTH (GEN3_W  ),
	.GEN4_DATA_WIDTH (GEN4_W  ),
	.GEN5_DATA_WIDTH (GEN5_W  ),
	.GEN6_DATA_WIDTH (GEN6_W  ),
	.GEN1_CLOCK_RATE (GEN1_CLK),
	.GEN2_CLOCK_RATE (GEN2_CLK),  //  1: 125, 2: 250 Mhz, 3: 500Mhs
	.GEN3_CLOCK_RATE (GEN3_CLK),
	.GEN4_CLOCK_RATE (GEN4_CLK),
	.GEN5_CLOCK_RATE (GEN5_CLK),
	.GEN6_CLOCK_RATE (GEN6_CLK)
    ) ep_phy(
	.pifs(ep_pif),
	.txp(rx_data),
	.txn(rx_datan),
	.rxp(tx_data),
	.rxn(tx_datan),
	.clkreq_n (clkreq_n)
    );
    // Replaced by PAM4 converter
    // Gen6 - PAM4 Signaling
`ifdef APCI_DISABLE_PAM4
    assign ep_phy.rxp1 = rc_phy.txp1;
    assign ep_phy.rxn1 = rc_phy.txn1;
    assign rc_phy.rxp1 = ep_phy.txp1;
    assign rc_phy.rxn1 = ep_phy.txn1;
`endif

    initial begin
	if ($test$plusargs("apci_tb_rcvr_detection")) begin
	    rc_phy.force_rcvr_detection(32'b10_1011);
	    ep_phy.force_rcvr_detection(32'b01_1111);
	    for(int i = 0; i < `APCI_NUM_LANES; i++)
		rc_phy.set_timing("TxDetect_to_PhyStatus", i, $urandom_range(3, 20));
	end

	if ($test$plusargs("apci_skew_inject")) begin
	    wait(rc != null);
	    rc.wait_event("bfm_started");
	    for (int i = 0; i < rc.port_get(0, "physical_linkwidth"); i++) begin
		rc.port_set_lane(0, i, "tx_skew_in_ps_gen1", $urandom_range(0, 20_000)); // 20ns
		rc.port_set_lane(0, i, "tx_skew_in_ps_gen2", $urandom_range(0, 8_000));
		rc.port_set_lane(0, i, "tx_skew_in_ps_gen3", $urandom_range(0, 6_000));
		rc.port_set_lane(0, i, "tx_skew_in_ps_gen4", $urandom_range(0, 5_000));
	    end
	end
    end
`else
    apci_mpipe_box #(
    .COMMON_CLOCK      (`APCI_COMMON_CLOCK),

    .A_NUM_LANES       (`APCI_NUM_LANES),
    .A_GEN1_DATA_WIDTH (GEN1_W  ),
    .A_GEN2_DATA_WIDTH (GEN2_W  ),
    .A_GEN3_DATA_WIDTH (GEN3_W  ),
    .A_GEN4_DATA_WIDTH (GEN4_W  ),
    .A_GEN5_DATA_WIDTH     ( GEN5_W  ),
    .A_CCIX_20G_DATA_WIDTH ( CCIX_20G_W  ),
    .A_CCIX_25G_DATA_WIDTH ( CCIX_25G_W  ),
    .A_GEN1_CLOCK_RATE (GEN1_CLK),
    .A_GEN2_CLOCK_RATE (GEN2_CLK),  //  1: 125, 2: 250 Mhz, 3: 500Mhs
    .A_GEN3_CLOCK_RATE (GEN3_CLK),
    .A_GEN4_CLOCK_RATE (GEN4_CLK),
    .A_GEN5_CLOCK_RATE     ( GEN5_CLK),
    .A_CCIX_20G_CLOCK_RATE ( CCIX_20G_CLK),
    .A_CCIX_25G_CLOCK_RATE ( CCIX_25G_CLK),

    .B_NUM_LANES       (`APCI_NUM_LANES),
    .B_GEN1_DATA_WIDTH (GEN1_W  ),
    .B_GEN2_DATA_WIDTH (GEN2_W  ),
    .B_GEN3_DATA_WIDTH (GEN3_W  ),
    .B_GEN4_DATA_WIDTH (GEN4_W  ),
    .B_GEN5_DATA_WIDTH     ( GEN5_W  ),
    .B_CCIX_20G_DATA_WIDTH ( CCIX_20G_W  ),
    .B_CCIX_25G_DATA_WIDTH ( CCIX_25G_W  ),
    .B_GEN1_CLOCK_RATE (GEN1_CLK),
    .B_GEN2_CLOCK_RATE (GEN2_CLK),
    .B_GEN3_CLOCK_RATE (GEN3_CLK),
    .B_GEN4_CLOCK_RATE (GEN4_CLK) ,
    .B_GEN5_CLOCK_RATE     ( GEN5_CLK),
    .B_CCIX_20G_CLOCK_RATE ( CCIX_20G_CLK),
    .B_CCIX_25G_CLOCK_RATE ( CCIX_25G_CLK)
    ) mpipe_box(
    rc_pif,
    ep_pif
    );

`ifdef APCI_MPORT
    apci_mpipe_box #(
    .COMMON_CLOCK      (`APCI_COMMON_CLOCK),

    .A_NUM_LANES       (`APCI_NUM_LANES),
    .A_GEN1_DATA_WIDTH (GEN1_W  ),
    .A_GEN2_DATA_WIDTH (GEN2_W  ),
    .A_GEN3_DATA_WIDTH (GEN3_W  ),
    .A_GEN4_DATA_WIDTH (GEN4_W  ),
    .A_GEN5_DATA_WIDTH     ( GEN5_W  ),
    .A_CCIX_20G_DATA_WIDTH ( CCIX_20G_W  ),
    .A_CCIX_25G_DATA_WIDTH ( CCIX_25G_W  ),
    .A_GEN1_CLOCK_RATE (GEN1_CLK),
    .A_GEN2_CLOCK_RATE (GEN2_CLK),  //  1: 125, 2: 250 Mhz, 3: 500Mhs
    .A_GEN3_CLOCK_RATE (GEN3_CLK),
    .A_GEN4_CLOCK_RATE (GEN4_CLK),
    .A_GEN5_CLOCK_RATE     ( GEN5_CLK),
    .A_CCIX_20G_CLOCK_RATE ( CCIX_20G_CLK),
    .A_CCIX_25G_CLOCK_RATE ( CCIX_25G_CLK),

    .B_NUM_LANES       (`APCI_NUM_LANES),
    .B_GEN1_DATA_WIDTH (GEN1_W  ),
    .B_GEN2_DATA_WIDTH (GEN2_W  ),
    .B_GEN3_DATA_WIDTH (GEN3_W  ),
    .B_GEN4_DATA_WIDTH (GEN4_W  ),
    .B_GEN5_DATA_WIDTH     ( GEN5_W  ),
    .B_CCIX_20G_DATA_WIDTH ( CCIX_20G_W  ),
    .B_CCIX_25G_DATA_WIDTH ( CCIX_25G_W  ),
    .B_GEN1_CLOCK_RATE (GEN1_CLK),
    .B_GEN2_CLOCK_RATE (GEN2_CLK),
    .B_GEN3_CLOCK_RATE (GEN3_CLK),
    .B_GEN4_CLOCK_RATE (GEN4_CLK) ,
    .B_GEN5_CLOCK_RATE     ( GEN5_CLK),
    .B_CCIX_20G_CLOCK_RATE ( CCIX_20G_CLK),
    .B_CCIX_25G_CLOCK_RATE ( CCIX_25G_CLK)
    ) mpipe_box1 (
    rc_pif1,
    ep_pif1
    );
`endif
`endif

`ifdef AVERY_UVM
    `include "apci_uvm_rcep_pkg.svh"
`else

class mycb extends apci_callbacks;
    virtual function void enum_done(
        input apci_device     bfm,
        input apci_device_mgr mgr
    );
        foreach(mgr.finfs[i]) if (mgr.finfs[i].bdf == 16'h0100) begin
            apci_func_info f = mgr.finfs[i];
            foreach(f.mem_ranges[j]) if (f.mem_ranges[j].bar_id == 0)
                f.mem_ranges.delete(j);
        end
    endfunction
endclass

initial begin
    apci_device_mgr  mgrs[$];
    #10us;
    wait(rc != null);

    rc.wait_event("bfm_started");
    rc.port_wait_ltssm(0, APCI_LTSSM_l0, 9000us, "Failed to enter L0");
    rc.collect_devices(-1, mgrs);
    //test_log.info($psprintf("Enumerated %0d devices", mgrs.size));
    //test_log.info($psprintf("************************BIOS ENUMERATION PASSED************************"));
end

initial begin
    mycb cb0;
    cb0 = new();
`ifdef APCI_MPORT
    rc  = new("rc",  null, APCI_DEVICE_rc, 2);
`else
    rc  = new("rc",  null, APCI_DEVICE_rc, 1);
`endif
    rc.log.enable_cfg_tracker   = 1;
    rc.log.enable_tl_tracker   = 1;
    rc.log.enable_dll_tracker  = 1;
    rc.log.enable_phy_tracker  = 1;

    #10ps
    rc.assign_vi (0, rc_pif);
`ifdef APCI_MPORT
    rc.assign_vi (1, rc_pif1);
`endif

    //rc.cfg_info.modcp128b_set_tx_cnt    = 4;  // for internal testing purpose, shorten the pattern
    //rc.cfg_info.modcp128b_lidl_tx_cnt   = 8;  // for internal testing purpose, shorten the pattern
    //rc.cfg_info.SRIS_modcp_set_tx_cnt   = 4;  // for internal testing purpose, shorten the pattern
    //rc.cfg_info.modcp1b1b_set_tx_cnt    = 4;  // for internal testing purpose, shorten the pattern
    //rc.cfg_info.modcp1b1b_lidl_tx_cnt   = 8;  // for internal testing purpose, shorten the pattern
    //rc.cfg_info.idle_to_rlock_cnt       = 16; // for internal testing purpose, shorten the pattern
    //rc.cfg_info.recov_rcvrcfg_ts2_tx_cnt = 20;
    rc.cfg_info.speed_sup = 3;
`ifdef AVERY_CXL
`ifdef AVERY_CXL_1_1
    rc.cfg_info.cxl_sup = 1;
`else /* !AVERY_CXL_1_1 */
    rc.cfg_info.cxl_sup = 2;
`endif /* AVERY_CXL_1_1 */
    rc.cxl_cfg_info.cxl_io_cap    = 1;
    rc.cxl_cfg_info.cxl_mem_cap   = 1;
    rc.cxl_cfg_info.cxl_cache_cap = 1;
    rc.cfg_info.speed_sup = 5;
`endif /* AVERY_CXL */
    if ($test$plusargs("apci_gen6")) begin
	rc.cfg_info.speed_sup  = 6;
	rc.cfg_info.use_serdes = 1;
    end

`ifdef AUTO_ENUM_OFF
    rc.set("auto_enum", 0);
`endif
    rc.set("start_bfm", 1);

    rc.log.set_severity_by_id(APCI4_2_4_2n1, AVY_WARNING);
    rc.log.set_severity_by_id(APCI_4r_4_2_4_2n1, AVY_WARNING);
    rc.log.set_severity_by_id(APCI4_2_7_3n2, AVY_WARNING);
    rc.log.set_severity_by_id(APCI4_2_7_3n3, AVY_WARNING);

    rc.log.set_severity_by_id(APCI4_2_4_1n18, AVY_WARNING);
    //rc.log.set_severity_by_id(APCI4_2_3_1n3, AVY_IGNORE);

    `ifdef AVY_REMOVE_BAR0
    rc.append_callback(cb0);
    `endif
    rc.wait_event("bfm_started");
`ifdef AVERY_CXL_1_1
    rc.cxl_port_set(-1, "bkdoor_assign_cxl11_behind_bus", 0);
`endif /* AVERY_CXL_1_1 */

    //rc.set("auto_speedup",       $urandom_range(1, 10) < 6); // 50% chance to auto speedup
    rc.set("auto_speedup",       1); // automatic speedup
    rc.set("skip_equal_phase23", 1); // 80% chance to skip phase 2 and 3

`ifdef AEMU_HSW_BFM
    hsw= new("hsw");
    hadpt0= new("hadpt0");
    // connection phase
    hadpt0.my_connect(rc, hsw);
    hsw.log.enable_cmd_tracker= 1;
    //hsw.set("watchdog_timeout", 10000ms, "anvm_pkg_test::anvm_testcase_base: 100ms watchdog timer expired");

    hsw.set("start_bfm", 1);
    hsw.wait_event("bfm_started");

    // enlarge the time of timeout for command
    // VAR: When BFM issues commands, this timeout is used. Unit is us.
    hsw.cfg_info.cmd_timeout_in_us= 20000;
`endif

`ifdef ANVM_MONITOR
	//--------host side monitor----------------
	if ($test$plusargs("dump_controller_registers"))  begin
	    $display("AVERY: %m: dumping controller registers, not enabling monitor  Time: %0t", $time);
	    end
	else begin
	    adaptor_monitor0 = new("adaptor_monitor0");
	    mon_cb0 = new();
	    mon_cb0.mon = adaptor_monitor0;
	    rc.append_callback(mon_cb0);

	    adaptor_monitor0.rc = rc; //pass handle to RC BFM
`ifdef AEMU_HSW_BFM
            adaptor_monitor0.hsw = hsw; //pass handle to HSW
`endif

	    //for Avery to Avery testbench only
	    adaptor_monitor0.ep0 = ep0; //pass handle to RC BFM
	    adaptor_monitor0.ctrler0 = ctrler0; //pass handle to RC BFM

	    //ignore these errors temporarily
            rc.log.set_severity_by_id(APCI4_2_3_2n1, AVY_WARNING);
            ep0.log.set_severity_by_id(APCI4_2_3_2n1, AVY_WARNING);
            rc.log.set_severity_by_id(APCI_4r_4_2_6_4_2_1_1n1, AVY_WARNING);
            ep0.log.set_severity_by_id(APCI_4r_4_2_6_4_2_1_1n1, AVY_WARNING);
`ifdef AEMU_HSW_BFM
            hsw.log.set_severity("NVME.3.1.6#2", ANVM_EXPECT); //<- expected when running bfm to bfm
`endif
	    end
	//--------host side monitor----------------
`endif // ANVM_MONITOR
end

`endif

`ifdef AEMU_HSW_BFM
task automatic start_test(anvm_testcase_base test);
    anvm_pkg_test::anvm_test_select(test.test_name);

    // !! Note: user shall not put any delays inside this task !!
    // Otherwise, pre_bfm_started() could be compromised.
    `avery_fork
        begin
            wait (hsw != null); // add HSW
            wait (hadpt0 != null); // add HSW
            wait (rc != null);

`ifdef AEMU_EP_BFM
            wait (ep0 != null);
            wait (cadpt0 != null);
            wait (ctrler0 != null);
`ifdef APCI_MPORT
            wait (ep1 != null);
            wait (cadpt1 != null);
            wait (ctrler1 != null);
`endif
`endif /* AEMU_EP_BFM */
        end

        begin
            repeat(10) begin
                #100us;
                if (hsw == null) test_log.info("Still waiting for hsw assigned");
                if (hadpt0 == null) test_log.info("Still waiting for hadpt0 assigned");
                if (rc == null) test_log.info("Still waiting for rc assigned");
`ifdef AEMU_EP_BFM
                if (ep0 == null) test_log.info("Still waiting for ep assigned");
                if (cadpt0 == null) test_log.info("Still waiting for cadpt0 assigned");
                if (ctrler0 == null) test_log.info("Still waiting for ctrler0 assigned");
`ifdef APCI_MPORT
                if (ep1 == null) test_log.info("Still waiting for ep1 assigned");
                if (cadpt1 == null) test_log.info("Still waiting for cadpt1 assigned");
                if (ctrler1 == null) test_log.info("Still waiting for ctrler1 assigned");
`endif
`endif /* AEMU_EP_BFM */
            end
            wait(0);
        end
    `avery_join_any
    test.add_host(hsw); // add HSW

`ifdef AEMU_EP_BFM
    test.add_controller(ctrler0);
`ifdef APCI_MPORT
    test.add_controller(ctrler1);
`endif
`endif /* AEMU_EP_BFM */
//    app_rc.port_wait_event(0, "dl_up");
    test.run();
endtask


`else // PCIe's testbase
task automatic start_test(apci_testcase_base test);
    apci_pkg_test::apci_test_select(test.test_name);
    fork
        begin
            wait (rc != null);
        end
        begin
            repeat(10) #100us $display("%m still waiting for rc assigned");
            wait(0);
        end
    join_any
    disable fork;
    test.add_rc(rc);
    test.add_ep(ep0);
`ifdef APCI_DUT_RC
    test.add_rc_app_bfm(rc);   // to run DUT0-RC test
    test.add_dut1_bfm(rc);     // to run DUT1-RC test
`else
    test.add_bfm(rc);
    test.add_rc_app_bfm(rc);
`endif
`ifdef APCI_NEW_PHY
    test_info.serial_phy = 1;
`else
    test_info.serial_phy = 0;
`endif
    test.run();
endtask
`endif

initial begin
    $timeformat(-9, 3, "ns", 8);
`ifdef APCI_DUMP_VCD
    $dumpfile("apci_top.vcd");
    $dumpvars(2, apci_top);
    $dumpon;
`endif
`ifdef APCI_DUMP_NC
    // need compilation arg " +access+r "
    $shm_open("apci_top.shm");
    $shm_probe(apci_top, "AMCTF");
    $shm_probe(board, "AMCTF");
`endif
`ifdef APCI_DUMP_VPD
    // may need -debug_pp argument
    $vcdplusfile("apci_top.vpd");
    $vcdpluson(0, apci_top);
`endif
`ifdef APCI_DUMP_WLF
    $wlfdumpvars(0, apci_top);
`endif
`ifdef APCI_DUMP_FSDB
    // Verdi path and PLI should be set and compiled correctly
    $fsdbDumpfile("apci_top.fsdb");
    $fsdbDumpvars(3, apci_top);
    $fsdbDumpon;
`endif
end

final begin
    if (rc)
        rc.my_report("pending_trans");
end

endmodule
