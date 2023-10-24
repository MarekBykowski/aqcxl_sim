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

`ifdef ANVM_UVM
`include "anvm_defines.svh"
`endif

// Use to include DUT's PIPE configuration
`include "defines_dut_pipe.svh"

module apci_top;

import apci_pkg::*;
import apci_pkg_test::*;

`ifdef ANVM_UVM
import anvm_pkg::*;
`ifdef AVERY_NVME // mean use ANVME's testbase
import anvm_pkg_test::*;
`endif
import anvm_pcie_pkg::*;
`endif

`ifdef AVERY_NVME
anvm_host_software       hsw     ; // the NVMe host software
anvm_host_nRC_adaptor    hadpt0  ; // Glue the software and PCIe host
`endif

apci_device rc;
//apci_device ep0;

`ifndef APCI_NUM_LANES
    `define APCI_NUM_LANES 8
`endif
`ifndef APCI_COMMON_CLOCK
    `define APCI_COMMON_CLOCK 0
`endif
`ifndef APCI_PCLK_AS_PHY_INPUT
    `define APCI_PCLK_AS_PHY_INPUT 0
`endif
`ifndef APCI_DYNAMIC_PRESET_COEF_UPDATES
    `define APCI_DYNAMIC_PRESET_COEF_UPDATES 0
`endif
`ifndef APCI_SERDES_MODE
    `define APCI_SERDES_MODE 0
`endif
`ifndef APCI_GEN1_DW
    `define APCI_GEN1_DW APCI_Width_8bit
`endif
`ifndef APCI_GEN2_DW
    `define APCI_GEN2_DW APCI_Width_16bit
`endif
`ifndef APCI_GEN3_DW
    `define APCI_GEN3_DW APCI_Width_32bit
`endif
`ifndef APCI_GEN4_DW
    `define APCI_GEN4_DW APCI_Width_32bit
`endif
`ifndef APCI_GEN5_DW
    `define APCI_GEN5_DW APCI_Width_32bit
`endif
`ifndef APCI_CCIX_20G_DW
    `define APCI_CCIX_20G_DW APCI_Width_8bit
`endif
`ifndef APCI_CCIX_25G_DW
    `define APCI_CCIX_25G_DW APCI_Width_8bit
`endif
`ifndef APCI_GEN1_CLK
    `define APCI_GEN1_CLK APCI_Pclk_250Mhz
`endif
`ifndef APCI_GEN2_CLK
    `define APCI_GEN2_CLK APCI_Pclk_250Mhz
`endif
`ifndef APCI_GEN3_CLK
    `define APCI_GEN3_CLK APCI_Pclk_250Mhz
`endif
`ifndef APCI_GEN4_CLK
    `define APCI_GEN4_CLK APCI_Pclk_500Mhz
`endif
`ifndef APCI_GEN5_CLK
    `define APCI_GEN5_CLK APCI_Pclk_1000Mhz
`endif
`ifndef APCI_CCIX_20G_CLK
    `define APCI_CCIX_20G_CLK APCI_CCIX_Pclk_2500Mhz
`endif
`ifndef APCI_CCIX_25G_CLK
    `define APCI_CCIX_25G_CLK APCI_CCIX_Pclk_3125Mhz
`endif
`ifndef APCI_MAX_DATA_WIDTH
    `define APCI_MAX_DATA_WIDTH APCI_Width_32bit
`endif

`ifdef APCI_FIXED_WIDTH
    parameter GEN1_W   = APCI_Width_32bit;
    parameter GEN2_W   = APCI_Width_32bit;
    parameter GEN3_W   = APCI_Width_32bit;
    parameter GEN4_W   = APCI_Width_32bit;
    parameter GEN5_W   = APCI_Width_32bit;
    parameter CCIX_20G_W = APCI_Width_32bit;
    parameter CCIX_25G_W = APCI_Width_32bit;
    parameter GEN1_CLK = APCI_Pclk_62_5Mhz; // 62.5M
    parameter GEN2_CLK = APCI_Pclk_125Mhz; // 125M
    parameter GEN3_CLK = APCI_Pclk_250Mhz; // 250M
    parameter GEN4_CLK = APCI_Pclk_500Mhz; // 500M
    parameter GEN5_CLK = APCI_Pclk_1000Mhz; // 1000M
    parameter CCIX_20G_CLK = APCI_CCIX_Pclk_625Mhz; // 625M
    parameter CCIX_25G_CLK = APCI_CCIX_Pclk_781_25Mhz; // 781.25M
`else // fixed  clock
    parameter GEN1_W   = `APCI_GEN1_DW;
    parameter GEN2_W   = `APCI_GEN2_DW;
    parameter GEN3_W   = `APCI_GEN3_DW;
    parameter GEN4_W   = `APCI_GEN4_DW;
    parameter GEN5_W   = `APCI_GEN5_DW;
    parameter CCIX_20G_W = `APCI_CCIX_20G_DW;
    parameter CCIX_25G_W = `APCI_CCIX_25G_DW;
    parameter GEN1_CLK = `APCI_GEN1_CLK;
    parameter GEN2_CLK = `APCI_GEN2_CLK;
    parameter GEN3_CLK = `APCI_GEN3_CLK;
    parameter GEN4_CLK = `APCI_GEN4_CLK;
    parameter GEN5_CLK = `APCI_GEN5_CLK;
    parameter CCIX_20G_CLK = `APCI_CCIX_20G_CLK;
    parameter CCIX_25G_CLK = `APCI_CCIX_25G_CLK;
`endif

/*
Change after Release 2.3d:
By default, Only 8/16/32bit bus interfaces are available
To Run 64-bit/128-bit interface, please define "APCI_MAX_DATA_WIDTH=16"

For example1 (to run 64bit interface):
    `define APCI_MAX_DATA_WIDTH 8
    ...
    parameter GEN3_W   = APCI_Width_64bit;
    parameter GEN4_W   = APCI_Width_64bit;
    parameter GEN5_W   = APCI_Width_64bit;
    ...
    parameter GEN3_CLK = APCI_Pclk_125Mhz;
    parameter GEN4_CLK = APCI_Pclk_250Mhz;
    parameter GEN5_CLK = APCI_Pclk_500Mhz;

For example2 (to run 128bit interface):
    `define APCI_MAX_DATA_WIDTH 16
    parameter GEN3_W   = APCI_Width_128bit;
    parameter GEN4_W   = APCI_Width_128bit;
    parameter GEN5_W   = APCI_Width_128bit;
*/

apci_pipe_intf rc_pif0[`APCI_NUM_LANES]();
apci_pipe_intf ep_pif0[`APCI_NUM_LANES]();
`ifdef APCI_MPORT
apci_pipe_intf rc_pif1[`APCI_NUM_LANES]();
apci_pipe_intf ep_pif1[`APCI_NUM_LANES]();
`endif


`ifdef APCI_NEW_PHY
    wire [`APCI_NUM_LANES-1:0] tx_data, tx_datan, rx_data, rx_datan;
    wire clkreq_n; // optional for L1 PM Substates

    apci_phy #(
    .COMMON_CLOCK    (`APCI_COMMON_CLOCK),
    .NUM_LANES       (`APCI_NUM_LANES),
    .PCLK_AS_PHY_INPUT     (`APCI_PCLK_AS_PHY_INPUT),
    .SERDES_MODE    (`APCI_SERDES_MODE),
    .DYNAMIC_PRESET_COEF_UPDATES (`APCI_DYNAMIC_PRESET_COEF_UPDATES),
    .GENERATE_REF_CLK(0),  // 0 to disable reference clock at rc_pif[0].Clk
    .GEN1_DATA_WIDTH (GEN1_W  ),
    .GEN2_DATA_WIDTH (GEN2_W  ),
    .GEN3_DATA_WIDTH (GEN3_W  ),
    .GEN4_DATA_WIDTH (GEN4_W  ),
    .GEN5_DATA_WIDTH (GEN5_W  ),
    .CCIX_20G_DATA_WIDTH (CCIX_20G_W  ),
    .CCIX_25G_DATA_WIDTH (CCIX_25G_W  ),
    .GEN1_CLOCK_RATE (GEN1_CLK),
    .GEN2_CLOCK_RATE (GEN2_CLK),  //  1: 125, 2: 250 Mhz, 3: 500Mhs
    .GEN3_CLOCK_RATE (GEN3_CLK),
    .GEN4_CLOCK_RATE (GEN4_CLK),
    .GEN5_CLOCK_RATE (GEN5_CLK),
    .CCIX_20G_CLOCK_RATE (CCIX_20G_CLK),
    .CCIX_25G_CLOCK_RATE (CCIX_25G_CLK)
    ) rc_phy(
    .pifs     (rc_pif0),
    .txp      (tx_data),
    .txn      (tx_datan),
    .rxp      (rx_data),
    .rxn      (rx_datan),
    .clkreq_n (clkreq_n)
    );

`ifdef APCI_MPORT
    wire [`APCI_NUM_LANES-1:0] tx_data1, tx_datan1, rx_data1, rx_datan1;
    wire clkreq_n1; // optional for L1 PM Substates

    apci_phy #(
    .COMMON_CLOCK    (`APCI_COMMON_CLOCK),
    .NUM_LANES       (`APCI_NUM_LANES),
    .PCLK_AS_PHY_INPUT     (`APCI_PCLK_AS_PHY_INPUT),
    .SERDES_MODE    (`APCI_SERDES_MODE),
    .DYNAMIC_PRESET_COEF_UPDATES (`APCI_DYNAMIC_PRESET_COEF_UPDATES),
    .GENERATE_REF_CLK(0),  // 0 to disable reference clock at rc_pif[0].Clk
    .GEN1_DATA_WIDTH (GEN1_W  ),
    .GEN2_DATA_WIDTH (GEN2_W  ),
    .GEN3_DATA_WIDTH (GEN3_W  ),
    .GEN4_DATA_WIDTH (GEN4_W  ),
    .GEN5_DATA_WIDTH (GEN5_W  ),
    .CCIX_20G_DATA_WIDTH (CCIX_20G_W  ),
    .CCIX_25G_DATA_WIDTH (CCIX_25G_W  ),
    .GEN1_CLOCK_RATE (GEN1_CLK),
    .GEN2_CLOCK_RATE (GEN2_CLK),  //  1: 125, 2: 250 Mhz, 3: 500Mhs
    .GEN3_CLOCK_RATE (GEN3_CLK),
    .GEN4_CLOCK_RATE (GEN4_CLK),
    .GEN5_CLOCK_RATE (GEN5_CLK),
    .CCIX_20G_CLOCK_RATE (CCIX_20G_CLK),
    .CCIX_25G_CLOCK_RATE (CCIX_25G_CLK)
    ) rc_phy1 (
    .pifs     (rc_pif1),
    .txp      (tx_data1),
    .txn      (tx_datan1),
    .rxp      (rx_data1),
    .rxn      (rx_datan1),
    .clkreq_n (clkreq_n1)
    );
`endif // APCI_MPORT

`else  // PIPE phy

    apci_mpipe_box #(
    .COMMON_CLOCK          ( `APCI_COMMON_CLOCK),
    .PCLK_AS_PHY_INPUT     ( `APCI_PCLK_AS_PHY_INPUT),
    .DYNAMIC_PRESET_COEF_UPDATES ( `APCI_DYNAMIC_PRESET_COEF_UPDATES),
    .MAX_DATA_WIDTH        ( `APCI_MAX_DATA_WIDTH),
        .RANDOM_INITIAL_DISPARITY(0), // 0818 add
        .RANDOM_TX_POLARITY(0),

    .A_NUM_LANES           ( `APCI_NUM_LANES),
    .A_GEN1_DATA_WIDTH     ( GEN1_W  ),
    .A_GEN2_DATA_WIDTH     ( GEN2_W  ),
    .A_GEN3_DATA_WIDTH     ( GEN3_W  ),
    .A_GEN4_DATA_WIDTH     ( GEN4_W  ),
    .A_GEN5_DATA_WIDTH     ( GEN5_W  ),
    .A_CCIX_20G_DATA_WIDTH ( CCIX_20G_W  ),
    .A_CCIX_25G_DATA_WIDTH ( CCIX_25G_W  ),
    .A_GEN1_CLOCK_RATE     ( GEN1_CLK),
    .A_GEN2_CLOCK_RATE     ( GEN2_CLK),  //  1: 125, 2: 250 Mhz, 3: 500Mhs
    .A_GEN3_CLOCK_RATE     ( GEN3_CLK),
    .A_GEN4_CLOCK_RATE     ( GEN4_CLK),
    .A_GEN5_CLOCK_RATE     ( GEN5_CLK),
    .A_CCIX_20G_CLOCK_RATE ( CCIX_20G_CLK),
    .A_CCIX_25G_CLOCK_RATE ( CCIX_25G_CLK),

    .B_NUM_LANES           ( `APCI_NUM_LANES),
    .B_GEN1_DATA_WIDTH     ( GEN1_W  ),
    .B_GEN2_DATA_WIDTH     ( GEN2_W  ),
    .B_GEN3_DATA_WIDTH     ( GEN3_W  ),
    .B_GEN4_DATA_WIDTH     ( GEN4_W  ),
    .B_GEN5_DATA_WIDTH     ( GEN5_W  ),
    .B_CCIX_20G_DATA_WIDTH ( CCIX_20G_W  ),
    .B_CCIX_25G_DATA_WIDTH ( CCIX_25G_W  ),
    .B_GEN1_CLOCK_RATE     ( GEN1_CLK),
    .B_GEN2_CLOCK_RATE     ( GEN2_CLK),
    .B_GEN3_CLOCK_RATE     ( GEN3_CLK),
    .B_GEN4_CLOCK_RATE     ( GEN4_CLK),
    .B_GEN5_CLOCK_RATE     ( GEN5_CLK),
    .B_CCIX_20G_CLOCK_RATE ( CCIX_20G_CLK),
    .B_CCIX_25G_CLOCK_RATE ( CCIX_25G_CLK)
    ) mpipe_box(
    rc_pif0,
    ep_pif0
    );

`ifdef APCI_MPORT
    apci_mpipe_box #(
    .COMMON_CLOCK          ( `APCI_COMMON_CLOCK),
    .PCLK_AS_PHY_INPUT     ( `APCI_PCLK_AS_PHY_INPUT),
    .DYNAMIC_PRESET_COEF_UPDATES ( `APCI_DYNAMIC_PRESET_COEF_UPDATES),
    .MAX_DATA_WIDTH        ( `APCI_MAX_DATA_WIDTH),
        .RANDOM_INITIAL_DISPARITY(0), // 0818 add
        .RANDOM_TX_POLARITY(0),

    .A_NUM_LANES           ( `APCI_NUM_LANES),
    .A_GEN1_DATA_WIDTH     ( GEN1_W  ),
    .A_GEN2_DATA_WIDTH     ( GEN2_W  ),
    .A_GEN3_DATA_WIDTH     ( GEN3_W  ),
    .A_GEN4_DATA_WIDTH     ( GEN4_W  ),
    .A_GEN5_DATA_WIDTH     ( GEN5_W  ),
    .A_CCIX_20G_DATA_WIDTH ( CCIX_20G_W  ),
    .A_CCIX_25G_DATA_WIDTH ( CCIX_25G_W  ),
    .A_GEN1_CLOCK_RATE     ( GEN1_CLK),
    .A_GEN2_CLOCK_RATE     ( GEN2_CLK),  //  1: 125, 2: 250 Mhz, 3: 500Mhs
    .A_GEN3_CLOCK_RATE     ( GEN3_CLK),
    .A_GEN4_CLOCK_RATE     ( GEN4_CLK),
    .A_GEN5_CLOCK_RATE     ( GEN5_CLK),
    .A_CCIX_20G_CLOCK_RATE ( CCIX_20G_CLK),
    .A_CCIX_25G_CLOCK_RATE ( CCIX_25G_CLK),

    .B_NUM_LANES           ( `APCI_NUM_LANES),
    .B_GEN1_DATA_WIDTH     ( GEN1_W  ),
    .B_GEN2_DATA_WIDTH     ( GEN2_W  ),
    .B_GEN3_DATA_WIDTH     ( GEN3_W  ),
    .B_GEN4_DATA_WIDTH     ( GEN4_W  ),
    .B_GEN5_DATA_WIDTH     ( GEN5_W  ),
    .B_CCIX_20G_DATA_WIDTH ( CCIX_20G_W  ),
    .B_CCIX_25G_DATA_WIDTH ( CCIX_25G_W  ),
    .B_GEN1_CLOCK_RATE     ( GEN1_CLK),
    .B_GEN2_CLOCK_RATE     ( GEN2_CLK),
    .B_GEN3_CLOCK_RATE     ( GEN3_CLK),
    .B_GEN4_CLOCK_RATE     ( GEN4_CLK),
    .B_GEN5_CLOCK_RATE     ( GEN5_CLK),
    .B_CCIX_20G_CLOCK_RATE ( CCIX_20G_CLK),
    .B_CCIX_25G_CLOCK_RATE ( CCIX_25G_CLK)
    ) mpipe_box1 (
    rc_pif1,
    ep_pif1
    );
`endif // APCI_MPORT
`endif

// used to include DUT's PCIe connect (PIPE or Serial PHY)
`include "connect_dut.svh"

`ifdef AVERY_UVM
    `define APCI_UVM_NO_START_BFM
    //`include "apci_uvm_rcep_pkg.svh"
    import uvm_pkg::*;
    `ifdef AVERY_NVME
        `include "anvm_apci_uvm_tb.svh"
    `ifdef ANVM_MONITOR
        //--------------------------------------- Model Monitor ---------------------
        `include "dump_controller_registers.svh"
        //--------------------------------------- Model Monitor ---------------------
    `endif
    `else
        `include "apci_uvm_test_top.svh"
    `endif

    initial begin
    $display(" Avery apci_top initail %0t ", $time);
    $display(" Avery apci_top initail %0t ", $time);
    $display(" Avery apci_top initail %0t ", $time);

    wait (rc != null);
    //wait (ep0!= null);
    `ifdef AVERY_CXL
    rc.cfg_info.cxl_sup = 1;
    rc.cfg_info.speed_sup = 5;
    rc.set("bus_enum_full_equal", 1);
    //ep0.cfg_info.cxl_sup = 1;
    //ep0.cfg_info.speed_sup = 5;
    `endif

    $display(" Avery apci_top got RC 1, %0t ", $time);
    $display(" Avery apci_top got RC 1, %0t ", $time);
    $display(" Avery apci_top got RC 1, %0t ", $time);

    `ifdef AUTO_ENUM_OFF
    $display(" Avery apci_top got AUTO ENUM OFF 2, %0t ", $time);
    $display(" Avery apci_top got AUTO ENUM OFF 2, %0t ", $time);
    $display(" Avery apci_top got AUTO ENUM OFF 2, %0t ", $time);
        rc.set("auto_enum", 0);
    `endif

    //#40us;  // Avery RD hard code delay 0817
    //rc.cfg_info.dl_feature_sup=0;
    //rc.cfg_info.speed_sup=1;
        //rc.cfg_info.recov_idle_tx_cnt = 32;

    rc.set("start_bfm");
    //ep0.set("start_bfm");

    $display(" Avery apci_top got RC Start BFM 3, %0t ", $time);
    $display(" Avery apci_top got RC Start BFM 3, %0t ", $time);
    $display(" Avery apci_top got RC Start BFM 3, %0t ", $time);

    `ifdef AVERY_NVME
        wait (hsw != null);
        hsw.log.set_severity("NVME.2#1", ANVM_EXPECT);
    $display(" Avery apci_top got HSW Start BFM 4, %0t ", $time);
    $display(" Avery apci_top got HSW Start BFM 4, %0t ", $time);
    $display(" Avery apci_top got HSW Start BFM 4, %0t ", $time);
    `endif
    end
`else
int target_speed = $urandom_range(3, 5);
initial begin
    rc  = new("rc",  null, APCI_DEVICE_rc, 1);
    //ep0 = new("ep0", null, APCI_DEVICE_ep);

    #10ps
    rc.assign_vi (0, rc_pif0);
    rc.cfg_info.modcp128b_set_tx_cnt       = 4;  // for internal testing purpose, shorten the pattern
    rc.cfg_info.modcp128b_lidl_tx_cnt      = 8;  // for internal testing purpose, shorten the pattern
    rc.cfg_info.SRIS_modcp_set_tx_cnt      = 4;  // for internal testing purpose, shorten the pattern
    rc.cfg_info.idle_to_rlock_cnt      = 16; // for internal testing purpose, shorten the pattern
    rc.cfg_info.speed_sup                  = target_speed;
    if ($test$plusargs("apci_gen4"))
    rc.cfg_info.speed_sup              = 4;
    else if ($test$plusargs("apci_gen5"))
    rc.cfg_info.speed_sup              = 5;
`ifdef AVERY_CXL
    rc.cfg_info.cxl_sup = 1;
    rc.cfg_info.speed_sup = 5;
    rc.set("bus_enum_full_equal", 1); // set Equalization_bypass_highest_rate_disable and No_Equalizaton_disable bit to 1 at the end of the bus enumeration
`endif
    rc.port_set_tracker(-1, "cfg", 1);
    rc.port_set_tracker(-1, "tl" , 1);
    rc.port_set_tracker(-1, "dll", 1);
    rc.port_set_tracker(-1, "phy", 1);
    rc.set("start_bfm", 1);
    rc.wait_event("bfm_started");
    rc.set("auto_speedup", rc.cfg_info.cxl_sup || $urandom_range(1, 10) < 9); // 80% chance to auto speedup
    rc.set("skip_equal_phase23", $urandom_range(1, 10) < 9); // 80% chance to skip phase 2 and 3

//    #10us; // intentionally slower
//    ep0.assign_vi(0, ep_pif0);
//    ep0.cfg_info.modcp128b_set_tx_cnt     = 4;  // for internal testing purpose, shorten the pattern
//    ep0.cfg_info.modcp128b_lidl_tx_cnt        = 8;  // for internal testing purpose, shorten the pattern
//    ep0.cfg_info.SRIS_modcp_set_tx_cnt        = 4;  // for internal testing purpose, shorten the pattern
//    ep0.cfg_info.idle_to_rlock_cnt        = 16; // for internal testing purpose, shorten the pattern
//    ep0.cfg_info.speed_sup            = target_speed;
//    if ($test$plusargs("apci_gen4"))
//  ep0.cfg_info.speed_sup              = 4;
//    else if ($test$plusargs("apci_gen5"))
//  ep0.cfg_info.speed_sup              = 5;
//`ifdef AVERY_CXL
//    ep0.cfg_info.cxl_sup = 1;
//    ep0.cfg_info.speed_sup = 5;
//`endif
//
//    ep0.port_set_tracker(-1, "cfg", 1);
//    ep0.port_set_tracker(-1, "tl" , 1);
//    ep0.port_set_tracker(-1, "dll", 1);
//    ep0.port_set_tracker(-1, "phy", 1);
//    ep0.set("start_bfm", 1);
//    ep0.wait_event("bfm_started");
//    ep0.set("auto_speedup", rc.cfg_info.cxl_sup || $urandom_range(1, 10) < 6); // 50% chance to auto speedup
end
`endif

`ifdef AVERY_NVME

task automatic start_test(anvm_testcase_base test);
    anvm_pkg_test::anvm_test_select(test.test_name);
    fork
        begin
            wait (hsw != null);
        end
        begin
            repeat(10) #100us $display("%m still waiting for hsw and ctrler0 assigned");
            wait(0);
        end
    join_any
    disable fork;
    test.add_host(hsw);

    if (rc)
    test.rcs.push_back(rc);
    //if (ep0)
    //  test.eps.push_back(ep0);
    test.run();
endtask

`else
task automatic start_test(apci_testcase_base test);
    apci_pkg_test::apci_test_select(test.test_name);
    // !! Note: user shall not put any delays inside this task !!
    // Otherwise, pre_bfm_started() could be compromised.
    fork
        begin
            wait (rc != null);
            //wait (ep0!= null);
        end
        begin
            //repeat(10) #100us $display("%m still waiting for rc and ep0 assigned");
            repeat(10) #100us $display("%m still waiting for rc assigned");
            wait(0);
        end
    join_any
    disable fork;
    test.add_rc(rc);
    //test.add_ep(ep0);
`ifdef APCI_DUT_RC
    //test.add_bfm(ep0);
    test.add_rc_app_bfm(rc);   // to run DUT0-RC test
    test.add_dut1_bfm(rc);     // to run DUT1-RC test
`else
    test.add_bfm(rc);
    test.add_rc_app_bfm(rc);
    //test.add_dut1_bfm(ep0);   // to run DUT1-EP tests
`endif
    if (rc && rc.get("bfm_started"))
    test_log.usage("RC shall not be started yet");
    //if (ep0 && ep0.get("bfm_started"))
    //  test_log.usage("EP shall not be started yet");
`ifdef APCI_NEW_PHY
    test_info.serial_phy = 1;
`else
    test_info.serial_phy = 0;
`endif
    test.run();
endtask
`endif

initial begin
    fork
    forever begin
        #50us;
        $display(" AVERY_TIMER@acpi_top %0t", $time);
    end
    join_any
end

initial begin
    $timeformat(-9, 3, "ns", 8);
`ifdef APCI_DUMP_VCD
    $dumpfile("apci_top.vcd");
    $dumpvars(0, apci_top);
    $dumpon;
`endif
`ifdef APCI_DUMP_NC
    // need compilation arg " +access+r "
    $shm_open("apci_top.shm");
    $shm_probe(apci_top, "AMCTF");
`endif
`ifdef APCI_DUMP_VPD
    // may need -debug_pp argument
    $vcdplusmemon(); // for interface array
    $vcdplusfile("apci_top.vpd");
    $vcdpluson(0, apci_top);
`endif
`ifdef APCI_DUMP_WLF
    $wlfdumpvars(0, apci_top);
`endif
`ifdef APCI_DUMP_FSDB
    // Verdi path and PLI should be set and compiled correctly
    $fsdbDumpfile("apci_top.fsdb");
    $fsdbDumpvars(0, apci_top);
    $fsdbDumpvars("+struct");
    $fsdbDumpvars("+mda");
    $fsdbDumpon;
`endif
end

final begin
`ifdef AVERY_NVME
    if (hsw)
    hsw.my_report("all");
`endif
    if (rc)
    rc.my_report("pending_trans");
    //if (ep0)
    //  ep0.my_report("pending_trans");
end

endmodule


