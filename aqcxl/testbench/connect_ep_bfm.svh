// Used for connect Avery PCIe EP BFM or optionally Avery NVMe Controller BFM
`include "qemu_enum.svh"
apci_device ep0;
`ifdef APCI_MPORT
apci_device ep1;
`endif
`ifdef AVERY_SPDM
`include "spdm_dpi.svh"
`endif

`ifdef AVERY_NVME
// Make sure Avery Controller BFM supports CMB fully.
class ctrler_cb extends anvm_ctrler_callbacks;
    int max_cq;
    static longint unsigned dev_n = 'h30;

    virtual function void after_created_capability(
            anvm_controller       bfm,
            anvm_ctrler_registers nvme_cap);
        max_cq= nvme_cap.MAX_NUM_Q;
        // For PMR
        nvme_cap.pmr_sup.dv=0;
        nvme_cap.pmr_cmss.dv=0;

        nvme_cap.cmb_sup         .set_dv(1); // this field is introducted in spec 1.4
        nvme_cap.cmbsz_sqs       .set_dv(1);
        nvme_cap.cmbsz_cqs       .set_dv(1);
        nvme_cap.cmbsz_lists     .set_dv(1);
        nvme_cap.cmbsz_rds       .set_dv(1);
        nvme_cap.cmbsz_wds       .set_dv(1);
        nvme_cap.cmbsz_size_units.set_dv(2); // 1: 64k
        nvme_cap.cmbsz_size      .set_dv(4); // 2

        nvme_cap.cmbloc_cqmms   .set_dv(1);
        nvme_cap.cmbloc_cqpds   .set_dv(1);
        nvme_cap.cmbloc_cdpmls  .set_dv(1);
        nvme_cap.cmbloc_cdpcils .set_dv(1);
        nvme_cap.cmbloc_cdmmms  .set_dv(1);
        nvme_cap.cmbloc_cqda    .set_dv(1);

`ifdef AVERY_NVME_ZNS
        nvme_cap.cmd_set_sup.set_dv('h41); // this field is introducted in spec 1.4
        nvme_cap.io_cmd_set_select.set_dv('h6);
`endif
        bfm.set("enable_to_ready_delay_ns", 1);
    endfunction

    virtual function void after_created_features(
            anvm_controller          bfm,
            ref anvm_ctrler_features features
        );
        int random_size= $urandom_range(2, max_cq-1);//(1<<16)-1 may violate cap.MAX_NUM_Q
        foreach (features.cap_map[i]) begin
            features.cap_map[i].changeable= 1;
        end
        foreach (features.num_of_q[i]) begin
            features.num_of_q[i].cq = random_size;//(1<<16)-1 may violate cap.MAX_NUM_Q
            features.num_of_q[i].sq = random_size;//(1<<16)-1 may violate cap.MAX_NUM_Q
        end
    endfunction

    virtual function void after_created_identify_ctrler(
            anvm_controller     bfm,
            anvm_istruct_ct     ctrler_struct);
        ctrler_struct.optional_admin_cmd_sup.directives = 1;
        ctrler_struct.optional_admin_cmd_sup.dev_selftest = 1;
        ctrler_struct.optional_admin_cmd_sup.ns_mng_attach = 1;
        ctrler_struct.optional_admin_cmd_sup.fw_act_and_dl = 1;
        ctrler_struct.optional_admin_cmd_sup.format_nvm = 1;
        ctrler_struct.optional_admin_cmd_sup.security = 1;
        if (bfm.get("is_primary_ctrler"))
            ctrler_struct.optional_admin_cmd_sup.virtual_mng = 1;
        else
            ctrler_struct.optional_admin_cmd_sup.virtual_mng = 0;
        ctrler_struct.optional_nvm_cmd_sup.reservation = 1;
        ctrler_struct.optional_nvm_cmd_sup.verify = 1;
        ctrler_struct.optional_nvm_cmd_sup.timestamp = 1;
        ctrler_struct.optional_nvm_cmd_sup.save_select = 1;
        ctrler_struct.optional_nvm_cmd_sup.write_zeros = 1;
        ctrler_struct.optional_nvm_cmd_sup.dataset_mng = 1;
        ctrler_struct.optional_nvm_cmd_sup.write_uncor = 1;
        ctrler_struct.optional_nvm_cmd_sup.compare = 1;
        ctrler_struct.num_namespaces= 1;
        ctrler_struct.max_data_transfer_size= 1;
        // For kernel version about 4.15, there is an error when using two
        // device with identical serial_number. But they seem not to repair it
        // in old kernel version (like 4.15).
        ctrler_struct.serial_number = 128'h5952455641 + (dev_n << 'd40); // AVERY#
        dev_n++;
        ctrler_struct.model_number = 64'h454d564e; // NVME
        ctrler_struct.firmware_revision = 64'h63372e32; // 2.7c
        ctrler_struct.logpage_attributes.persistent_event_log = 1;
        ctrler_struct.logpage_attributes.telemetry_sup = 0;
        ctrler_struct.logpage_attributes.cmd_effects = 0;
        ctrler_struct.format_nvm_attributes.crypt_erase = 1;
        ctrler_struct.format_nvm_attributes.format_all = 1;
    endfunction

    virtual function void after_created_identify_namespace(
            anvm_controller     bfm,
            ref anvm_istruct_ns ns_structs[$]
        );

        foreach (ns_structs[i]) begin
            anvm_istruct_ns ns = ns_structs[i];
            ns.e2e_protect_cap = -1;
            ns.e2e_protect_cap.rsvd = 0;
            //ns.num_of_lba_formats= 'hd;
            foreach(ns.lba_formats[k]) begin
                if (k <= ns_structs[i].num_of_lba_formats) begin
                    //ns.lba_formats[k].lba_data_size = 'hc;
                    ns.lba_formats[k].metadata_size = 0;

                    // pi_type != 0 will use the reftag
                    // but Kernel 3.13 won't set it
                    ns.e2e_protect_settings.pi_type = 0;
                end

            end
        end
    endfunction

    virtual function void after_created_subsys_stream(
            anvm_controller      bfm,
            ref anvm_directive_param_stream subsys_stream_param
        );
        //bfm.set("directive_supported", 'b01);
    endfunction
endclass

anvm_ctrler_nEP_adaptor cadpt0 ; // Glue the NVMe controller and PCIe EP
anvm_controller         ctrler0; // the NVMe Controller
ctrler_cb               cb0;

`ifdef APCI_MPORT
anvm_ctrler_nEP_adaptor cadpt1 ; // Glue the NVMe controller and PCIe EP
anvm_controller         ctrler1; // the NVMe Controller
ctrler_cb               cb1;
`endif

`endif // AVERY_NVME

task automatic set_ep(apci_device ep, virtual apci_pipe_intf pif[]);
    apci_cfg_space ep_csps[$];

`ifdef AVERY_CXL
`ifdef AVERY_NVME
    ep.cfg_info.n_physical_func[0] = 2; // port 1 has 2 physical functions
`else
    ep.cfg_info.n_physical_func[0] = 1; // port 1 has 2 physical functions
`endif
`endif // AVERY_CXL

    #10us; // intentionally slower
    ep.assign_vi(0, pif);
    //ep.cfg_info.modcp128b_set_tx_cnt   = 4;  // for internal testing purpose, shorten the pattern
    //ep.cfg_info.modcp128b_lidl_tx_cnt  = 8;  // for internal testing purpose, shorten the pattern
    //ep.cfg_info.SRIS_modcp_set_tx_cnt  = 4;  // for internal testing purpose, shorten the pattern
    //ep.cfg_info.modcp1b1b_set_tx_cnt   = 4;  // for internal testing purpose, shorten the pattern
    //ep.cfg_info.modcp1b1b_lidl_tx_cnt  = 8;  // for internal testing purpose, shorten the pattern
    //ep.cfg_info.idle_to_rlock_cnt      = 16; // for internal testing purpose, shorten the pattern
    ep.cfg_info.speed_sup               = 3;//target_speed;
    ep.cfg_info.doe_sup                 = 1;// doe support
`ifdef AQEMU_SRIOV
    ep.cfg_info.SRIOV_sup               = 1;
`else
    ep.cfg_info.SRIOV_sup               = 0;
`endif

`ifdef AVERY_CXL
    ep.cfg_info.cxl_sup = 2;
`ifdef AVERY_CXL_1_1
    ep.cfg_info.cxl_sup = 1;
`endif /* AVERY_CXL_1_1 */
    ep.cxl_cfg_info.cxl_io_cap    = 1;
    ep.cxl_cfg_info.cxl_mem_cap   = 1;
    ep.cxl_cfg_info.cxl_cache_cap = 1;
    ep.cfg_info.speed_sup = 5;
`endif

    //ep.cfg_info.expansion_rom_sup       = 0;
    if ($test$plusargs("apci_gen4"))
        ep.cfg_info.speed_sup           = 4;
    else if ($test$plusargs("apci_gen5"))
        ep.cfg_info.speed_sup           = 5;
    else if ($test$plusargs("apci_gen6")) begin
        ep.cfg_info.speed_sup           = 6;
        ep.cfg_info.use_serdes = 1;
        ep.cfg_info.msi_sup = 0; // msi/msix locate in bar0 will cause pcie 6 to
        ep.cfg_info.msix_sup = 0; // not boot in the kernel driver
    end

    ep.port_set_tracker(-1, "cfg", 1);
    ep.port_set_tracker(-1, "tl" , 1);
    ep.port_set_tracker(-1, "dll", 1);
    ep.port_set_tracker(-1, "phy", 1);
    ep.set("start_bfm", 1);
    ep.wait_event("bfm_started");
    ep.set("auto_speedup", 1);
endtask

`ifdef AVERY_NVME
task automatic set_ctrler(apci_device ep, anvm_controller ctrler, string ctrler_name,
    anvm_ctrler_nEP_adaptor cadpt, string cadpt_name, ctrler_cb cb);
    cadpt = new(cadpt_name);
    ctrler = new(ctrler_name);
    cb = new();
`ifndef AVERY_CXL
    cadpt.my_connect(ep, ctrler, 0); // attach ctrler0 to PCIe function num 0
`else
    cadpt.my_connect(ep, ctrler, 1); // attach ctrler0 to PCIe function num 1
`endif // AVERY_CXL
    ctrler.append_callback(cb);
    ctrler.cfg_info.spec_revision= 14;
`ifdef AVERY_NVME_ZNS
    ctrler.cfg_info.zoned_namespace_sup = 1;
`endif // AVERY_NVME_ZNS

    #1ps;
    // It is just a workaround for fix the timing issue of
    // ANVM_ERROR: test_log@95140.000ns : bfm ctrler0 is already started.
    // anvm_testcase_base::pre_bfm_started() callback may not function
    // properly if used. Try delay calling of set("start_bfm") later than
    // start_test::test.run
    ctrler.set("start_bfm", 1);
    ctrler.set_tracker("cmd", 1);
endtask
`endif // AVERY_NVME

task automatic set_class_code(apci_device ep);
    apci_cfg_space ep_csps[$];

    ep.port_get_cfg_space(-1, ep_csps);
`ifdef AVERY_NVME
    ep_csps[0].type0.class_code.set_v('h010802);
`endif // AVERY_NVME
`ifdef AVERY_CXL
    ep_csps[0].type0.class_code.set_v('h050210);
`endif // AVERY_CXL
endtask

initial begin
    ep0= new("ep0", null, APCI_DEVICE_ep);

    set_ep(ep0, ep_pif);
`ifdef AVERY_NVME
    set_ctrler(ep0, ctrler0, "ctrler0", cadpt0, "cadpt0", cb0);
`endif // AVERY_NVME
    set_class_code(ep0);
end

`ifdef APCI_MPORT
initial begin
    ep1= new("ep1", null, APCI_DEVICE_ep);

    set_ep(ep1, ep_pif1);
`ifdef AVERY_NVME
    set_ctrler(ep1, ctrler1, "ctrler1", cadpt1, "cadpt1", cb1);
`endif // AVERY_NVME
    set_class_code(ep1);
end
`endif

// AvyRD 0620: Workaround for ep's cfg rd 0x30 = 0xffff_f000 (PCI expansion rom setting)
class my_ep_cb extends apci_callbacks;
    // Use callback to force BFM having smaller Bars so total can fit into under 4G.
    // Then it is possible for BFM to set prefetch base to 0.

    virtual function void setup_cfg_space(apci_device bfm, apci_cfg_space csp);
        /* bar_type:
             bit3: 1 for prefetchable
             bit2: 1 for 64-bit
             bit1: reserved
             bit0: 0 for memory
        */
        if (csp.type0 && !csp.is_vf && !csp.cxl_device) begin
            csp.type0.bar0.set_dv({28'hfff0_000, 4'b0000}); // 32-bit mio
            csp.type0.bar0.set_write_mask('h000f_ffff); // 1MB

            csp.type0.bar1.set_dv({28'hfff0_000, 4'b0000}); // 32-bit mio
            csp.type0.bar1.set_write_mask('h0000_ffff); // 64KB

            csp.type0.bar2.set_dv({28'hfff0_000, 4'b0100});
            csp.type0.bar2.set_write_mask('h000f_ffff); // 1MB

            csp.type0.bar3.set_dv(-1); // disable bars
            csp.type0.bar3.set_write_mask(0);

            csp.type0.bar4.set_dv(0); // disable bars
            csp.type0.bar4.set_write_mask(-1);

            csp.type0.bar5.set_dv(0); // disable bars
            csp.type0.bar5.set_write_mask(-1);

            csp.type0.vendor_id.set_dv('h18ef);

            // here set PCI expansion rom setting
            csp.type0.expansion_rom_base_addr.set_dv(21'b0_0000_0000_0000_0000);
            csp.type0.expansion_rom_base_addr.set_write_mask(21'b0_0000_0000_0000_0001);
        end

        csp.type0.int_line.set_dv('h0a);
        csp.type0.int_pin.set_dv('h01);

        csp.pcie.function_level_reset_cap.set_dv('h1);

        if (csp.sriov) begin
            bit[3:0] bar_type = {
                1'b1, // 1 for prefetchable
                1'b1, // 0 for 32-bit
                1'b0, // reserved
                1'b0 };  // 0 for memory

            // if SR-IOV is set, bar address will change and cause VCS error
            csp.sriov.bar0.set_dv(0);
            csp.sriov.bar1.set_dv(0);
            csp.sriov.bar2.set_dv(0);
            csp.sriov.bar3.set_dv(0);
            csp.sriov.bar4.set_dv(0);
            csp.sriov.bar5.set_dv(0);
            csp.sriov.bar0.set_write_mask(-1);
            csp.sriov.bar1.set_write_mask(-1);
            csp.sriov.bar2.set_write_mask(-1);
            csp.sriov.bar3.set_write_mask(-1);
            csp.sriov.bar4.set_write_mask(-1);
            csp.sriov.bar5.set_write_mask(-1);

        end

`ifdef AVERY_CXL
        if (csp.type0 && csp.cxl_device) begin
            csp.type0.bar0.set_dv({28'h0, 4'b1100}); // 64 pref
            csp.type0.bar0.set_write_mask('h000f_ffff); // 1MB

            csp.type0.bar1.set_dv(32'h0);
            csp.type0.bar1.set_write_mask(0);

            csp.type0.bar2.set_dv({28'h0, 4'b1100}); // 64 pref
            csp.type0.bar2.set_write_mask('h000f_ffff); // 1MB

            csp.type0.bar3.set_dv({28'h0, 4'b0000});
            csp.type0.bar3.set_write_mask(0);

            csp.type0.bar4.set_dv({28'h0, 4'b1100}); // 64 pref
            csp.type0.bar4.set_write_mask('h000f_ffff); // 1MB

            csp.type0.bar5.set_dv({28'h0, 4'b0000}); // high address of bar4
            csp.type0.bar5.set_write_mask(0);

            csp.type0.vendor_id.set_dv('h18EF);
            csp.type0.class_code.set_dv('h050210);

            // here set PCI expansion rom setting
            csp.type0.expansion_rom_base_addr.set_dv(21'b0_0000_0000_0000_0000);
            csp.type0.expansion_rom_base_addr.set_write_mask(21'b0_0000_0000_0000_0001);
        end

//        if (csp.flexbus_port != null) begin
//            csp.flexbus_port.dvsec_revision.set_dv(0);
//        end
`endif
    endfunction

`ifdef AVERY_CXL
    virtual task rx_device_cmd(apci_device bfm, acxl_device_cmd cmd);
        if (cmd.opcode == ACXL_DC_identify_mem_dev) begin
            acxl_cmd_identify_mem_dev r;
            $cast(r, cmd.rsp);
            r.out.partition_alignment      = 0;
            r.out.persistent_only_capacity = 'h2000_0000 / (256 << 20);
            r.out.volatile_only_capacity   = 0;
            r.out.total_capacity           = 'h2000_0000 / (256 << 20);
            r.out.fw_revision              = 'h5952455641; // ascii AVERY
        end
    endtask
`endif

`ifdef AVERY_SPDM
    virtual function void rx_doe_data(
            input apci_device bfm,
            input apci_bdf_t  bdf,
            ref   bit[31:0]   rx_dwords[$],
            ref   bit[31:0]   user_tx_dwords[$]
        );
        bit[7:0] msg[QEMU_BUF_SIZE - 1:0];
        int ret = 0;
        int unsigned cmd[0:0];

        if (rx_dwords[0] != APCI_DOE_spdm && rx_dwords[0] != APCI_DOE_secured_spdm) begin
            return;
        end

        // Send doe request colleted from bfm to spdm server
        foreach (rx_dwords[i]) begin
            {msg[i * 4 + 3], msg[i * 4 + 2], msg[i * 4 + 1], msg[i * 4]} = rx_dwords[i];
        end
        ret = SendPlatformData(1, msg, rx_dwords[1] * 4);
        if (ret == -1) begin
            $display("Error when sending to SPDM server");
            $finish();
        end

        // Receive response from spdm server
        ret = ReceivePlatformData(cmd, msg, QEMU_BUF_SIZE);
        cmd[0] = avery_swap_endian(cmd[0]);
        if (ret == -1) begin
            $display("Error when receiving from SPDM server");
            $finish();
        end else if (cmd[0] == 0) begin
            $display("Unrecognized command from SPDM server");
            $finish();
        end
        for (int i= 0; i < ret / 4; i++) begin
            user_tx_dwords.push_back({msg[i * 4 + 3], msg[i * 4 + 2], msg[i * 4 + 1], msg[i * 4]});
        end
    endfunction
`endif
endclass

initial begin
    my_ep_cb cb;
    cb= new();
    wait (ep0 != null);
    ep0.append_callback(cb);
end
`ifdef APCI_MPORT
initial begin
    my_ep_cb cb1;
    cb1= new();
    wait (ep1 != null);
    ep1.append_callback(cb1);
end
`endif
