`timescale 1fs/1fs
// File: simcluster_master.sv

module simcluster_master;
    `include "qemu_enum.svh"
    import qemu_simc_pkg::*;
    import "DPI-C" function string append_key_after_user(input string key);

    task setup_keys(string keys[]);
        int i;
        static string keys_s[1024];
        bit[7:0] msg[QEMU_BUF_SIZE - 1:0];
        bit[7:0] cmd;
        int rcv_size;

        for (i = 0; i < $size(keys); i++) begin
            keys_s[i] = keys[i];
            keys_s[i] = append_key_after_user(keys_s[i]);
        end

        $display("Avery: System verilog listening to AVY_PORT %0d", simcluster_SC_port);

        $scl_config(1, 1); // Skip checking next event time
//        $scl_config(2, 10); // Add usleep when too many non-blocking read returns empty

        $master_channel_total($size(keys), simcluster_SC_port);

        // It seems that we can't do better refactoring for passing parameters into
        // $module_dynamic_link_pseudo.
        case ($size(keys))
            0: begin
                $display("Avery: Please specify a least one key");
                $finish();
            end
            1: begin
                $module_dynamic_link_pseudo(keys_s[0]);
            end
            2: begin
                $module_dynamic_link_pseudo(keys_s[0], keys_s[1]);
            end
            3: begin
                $module_dynamic_link_pseudo(keys_s[0], keys_s[1], keys_s[2]);
            end
            4: begin
                $module_dynamic_link_pseudo(keys_s[0], keys_s[1], keys_s[2], keys_s[3]);
            end
            default: begin
                $display("Avery: Please modify simcluster_master.sv to support more keys");
                $finish();
            end
        endcase
`ifdef AVERY_SPDM
        // workaround for simcluster bug, will be repaired in the later PLI
        for (i = 0; i < $size(keys); i++) begin
            rcv_size = avy_mem_pkt_recv_dpi(keys_s[i], QEMU_BUF_SIZE, msg, 1);
            $display("[QEMU] @%0t: %s receiving hello packet 'h%0h", $time, keys_s[i], cmd);
        end
`endif
    endtask

    task setup_qemu(logic [7:0] num_of_keys);
`ifdef AEMU_AVP_EDB
        static string sc_key_edb = append_key_after_user(`simcluster_EDB_key);
`endif

`ifdef AVP_SimC
        static string sc_key_avp = append_key_after_user("key_avp");
`endif

        static string sc_key_qemu = append_key_after_user(`simcluster_QEMU_key);

        $display("Avery: System verilog listening to AVY_PORT %0d", simcluster_SC_port);

        $scl_config(1, 1); // Skip checking next event time
//        $scl_config(2, 10); // Add usleep when too many non-blocking read returns empty

        $master_channel_total(num_of_keys, simcluster_SC_port);
        $module_dynamic_link_pseudo(
`ifdef AEMU_AVP_EDB
            sc_key_edb,
`endif

`ifdef AVP_SimC
            sc_key_avp,
`endif

            sc_key_qemu
        );
    endtask
endmodule
