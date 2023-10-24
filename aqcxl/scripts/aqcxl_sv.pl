#!/usr/bin/perl

use strict;
use File::Basename;

my $AVERY_EMU;
my $AVERY_AXI;
my $AVERY_NVME;
my $AVERY_QEMU;
my $AVERY_PLI;
my $AVERY_PCIE;
my $AVERY_SIM;
my $AVERY_XIL_LIB;
my $AVERY_AVP;

my $is_release_version= 1;
my $design_libs ="xil_defaultlib";
my $compile = '';
my $runtime = '';
my $test;
my $top;
my @opt_C;
my @opt_R;
my $opt_t = '';
my $opt_p = "cxl2.0";
my $opt_nvme = 0;
my $opt_b = 256;
my $opt_d = 0;
my $opt_n = 1234;
my $opt_s = '';
my $opt_sim = '';
my $opt_64 = '';
my $opt_w = '';
my $opt_qemu = 1;
my $opt_arm = 0;
my $opt_ieee = 0;
my $opt_ep_bfm = 1;
my $opt_sriov = 0;
# The Mobiveil NVMe IP
my $opt_ep_unex = 0;
# The Mobiveil NVMe with APB IP
my $opt_ep_unex_apb = 0;
my $UNEX;
my $unex_release_name= '';
my $unex_release_folder= '';
my $opt_hsw_bfm = 0;
my $opt_spdm = 0;
my $opt_gen6 = 0;
my $qemu_pli= '';
my $opt_sw = 0; # PCIe switch
my $opt_nDecoder= 1;
my $opt_nEP= 1;

sub show_usage {
    my $usage = '';
    chomp(my $prog = basename($0));
    if ($is_release_version) {
        $usage= "
$prog [-t test] [options]
       -s mti64|xm64|vcs64      choose a simulator
       -t test                  switch qdma tesetcase to pcie tesetcase
       -C opt                   simulator compilation time options
                                ex: -C +define+AVY_DUMMY
       -R opt                   simulator Runtime arguments
                                ex: configure the rc address range
                                  -R +MIO_BASE_ADDR=fe600000
                                  -R +MIO_LIMIT_ADDR=fe800000
                                  -R +PREF_MEM_BASE_ADDR=00000000f4000000
                                  -R +PREF_MEM_LIMIT_ADDR=00000000fc000000
       -n num                   random seed passed to simulator
       -sriov                   enable SR-IOV feature
       -gen6                    add in PCIe gen6 file/defines
       -p pcie|nvme|cxl(2.0|1.1) run EP as Avery PCIe(default), NVME or CXL
                                 *Only for cxl* 
                                 ex: 1 endpoint per root decoder, 2 decoders
                                  -p cxl2.0,nEP=1,nDecoder=2
                                     2 endpoint per root decoder, 1 decoder
                                  -p cxl2.0,nEP=2,nDecoder=1

 Ex.
     $prog -s xm64 -t apcit_qemu_basic.sv -qemu
     ";
    } else {
        $usage= "
$prog [-t test] [options]
       -s mti64|xm64|vcs64       choose a simulator
       -t test                   switch qdma tesetcase to pcie tesetcase
       -C opt                    simulator compilation time options
                                 ex: -C +define+AVY_DUMMY
       -R opt                    simulator Runtime arguments
                                 ex: configure the rc address range
                                  -R +MIO_BASE_ADDR=fe600000
                                  -R +MIO_LIMIT_ADDR=fe800000
                                  -R +PREF_MEM_BASE_ADDR=00000000f4000000
                                  -R +PREF_MEM_LIMIT_ADDR=00000000fc000000
       -n num                    random seed passed to simulator
       -w vcd|fsdb|awdb          dump waveform
       -hsw_bfm                  run Avery NVMe Host Software BFM and testcase
       -ep_unex                  run EP as Mobievil NVMe Combo IP (without APB)
       -ep_unex_apb              run EP as Mobievil NVMe Combo IP (with APB)
       -arm                      **
       -spdm                     attach openspdm server to EP
       -sriov                    enable SR-IOV feature.
       -gen6                    add in PCIe gen6 file/defines
       -p pcie|nvme|cxl(2.0|1.1) run EP as Avery PCIe(default), NVME or CXL
                                 *Only for cxl* 
                                 ex: 1 endpoint per root decoder, 2 decoders
                                  -p cxl2.0,nEP=1,nDecoder=2
                                     2 endpoint per root decoder, 1 decoder
                                  -p cxl2.0,nEP=2,nDecoder=1
 Ex.
     $prog -s xm64 -t anvmt_basic.sv -p nvme -ep_unex -hsw_bfm
     $prog -s xm64 -t apcit_qemu_basic.sv -qemu -p nvme -ep_unex_apb -arm

 Internal.
     $prog -s xm64 -t anvmt_basic.sv -p nvme -hsw_bfm -C +define+APCI_MPORT
     $prog -s xm64 -t apcit_qemu_basic.sv -qemu -p nvme -C  +define+APCI_MPORT

  QNVMe Monitor.
     $prog -s xm64 -t anvmt_model_controller.sv -p nvme -hsw_bfm -C +define+ANVM_MONITOR -R +dump_controller_registers
     $prog -s xm64 -t apcit_qemu_basic.sv -qemu -p nvme -C +define+ANVM_MONITOR
     ";
    }
    printf("$usage\n");
    exit 0;
}

sub unsupport_option_value {
    my ($opt, $val) = @_;

    print ("Error: Unsupported value '$val' for option '$opt'. Please check supported value by -h\n");
    exit 1;
}

sub parse_arg {
    my ($argv_ref) = @_;
    my $argc = scalar(@{$argv_ref});

    for (my $i = 0; $i < $argc; $i++) {
        my $arg = ${$argv_ref}[$i];
        my $val = ${$argv_ref}[$i+1];

        if ($arg eq "-h") {
            &show_usage;
        }
        elsif ($arg eq "-s") {
            die ("$arg: Invalid usage of \"$arg\" option\n") if (not defined($val));
            die ("$arg: Unrecognized simulator name: $val\n") if ($val !~ m/(vcs|mti|nc|xm)(64)?/);
            $opt_sim= $1;
            if (defined($2)) {
                $opt_64= $2;
            }
            $opt_s= $val;
            $i++;
        }
        elsif ($arg eq "-p") {
            $opt_p = $val;
            if ($opt_p =~ /cxl/) {
                if (!($opt_p =~ /cxl2.0/ || $opt_p =~ /cxl2/ ||
                        $opt_p =~ /cxl1.1/ || $opt_p =~ /cxl$/)) {
                    print("Invalid cxl version \"$opt_p\" of \"$arg\" option\n");
                    &show_usage;
                }
            }
            if ($opt_p =~ /nvme/) {
                $opt_nvme = 1;
            }
            if ($opt_p =~ /nDecoder=(\d)/) {
                $opt_nDecoder = $1;
            }
            if ($opt_p =~ /nEP=(\d)/) {
                $opt_nEP = $1;
            }
            print("Configuring testbench under $opt_nEP endpoints per decoder with $opt_nDecoder decoder, total ".($opt_nEP*$opt_nDecoder)," endpoints\n");
        }
        elsif ($arg eq "-C") {
            push(@opt_C, $val);
        }
        elsif ($arg eq "-R") {
            push(@opt_R, $val);
        }
        elsif ($arg eq "-t") {
            $opt_t = $val;
            $opt_d = 1;
        }
        elsif ($arg eq "-n") {
            $opt_n = $val;
        }
        elsif ($arg eq "-w") {
            $opt_w = $val;
        }
        elsif ($arg eq "-qemu") {
            $opt_qemu= 1;
        }
        elsif ($arg eq "-arm") {
            $opt_arm= 1;
            $opt_ep_bfm= 0;
            $opt_ep_unex= 0;
            $opt_ep_unex_apb= 1;
        }
        elsif ($arg eq "-sriov") {
            $opt_sriov= 1;
        }
        elsif ($arg eq "-sw") {
            $opt_sw= 1;
        }
        elsif ($arg eq "-hsw_bfm") {
            $opt_hsw_bfm= 1;
        }
        elsif ($arg eq "-ep_bfm") {
            $opt_ep_bfm= 1;
            $opt_ep_unex= 0;
            $opt_ep_unex_apb= 0;
        }
        elsif ($arg eq "-ep_unex") {
            $opt_ep_bfm= 0;
            $opt_ep_unex= 1;
            $opt_ep_unex_apb= 0;
        }
        elsif ($arg eq "-ep_unex_apb") {
            $opt_ep_bfm= 0;
            $opt_ep_unex= 0;
            $opt_ep_unex_apb= 1;
        }
        elsif ($arg eq "-spdm") {
            $opt_spdm= 1;
        }
        elsif ($arg eq "-gen6") {
            $opt_gen6= 1;
        }
    }
}
sub vcs_execute {
    my $cmd = '';
    my $file_group = '';
    my $simulate = '';
    my $pli_lib = '';
    my $pli_tb = '';
    my $pli = '';
    my $vlog_stuff .= &gene_filelist;
    my $vcs_do = '';

    my $vcs_sim_opts = "-ucli -licqueue -l simulate.log";
    my $vcs_opts = "-full64 -sverilog -debug -ntb_opts +check+dep_check -licqueue";

    $pli_tb .= " -P $AVERY_PLI/tb_vcs64.tab";

    if ($is_release_version) {
        $vcs_do = "$AVERY_QEMU/vcs_lib/simulate_vcs.do";
    } else {
        $vcs_do = "$AVERY_AVP/scripts/vcs/simulate_vcs.do";
    }

    $pli .= "$AVERY_PLI/lib.linux/libtb_vcs64";
    $pli_lib .= "$qemu_pli";

    if ($opt_d) {
        $vlog_stuff .= " $test";
    }
    if ($opt_gen6) {
        $runtime .= " +apci_gen6";
    }

    $simulate .= "; ./simv $vcs_sim_opts -sv_lib $pli_lib -sv_lib $pli +ntb_random_seed=$opt_n -do $vcs_do $runtime";

    $cmd .= "vcs $vcs_opts ${pli}.so $pli_tb ${pli_lib}.so $vlog_stuff $compile -l vcs_compile.log";
    $cmd .= " $simulate ";

    return $cmd;
}

sub mti_execute {
    my $cmd = '';
    my $file_group = '';
    my $elaborate = '';
    my $simulate = '';
    my $pli = '';
    my $vlog_stuff .= &gene_filelist;
    system "ln -f -s $AVERY_PLI/lib.linux/libtb_ms64.a libtb_ms64.so";
    $pli .= " -pli ./libtb_ms64.so ";
    $pli .= " -sv_lib $qemu_pli";

    if ($AVERY_XIL_LIB ne "") {
        $file_group .= "vlib questa_lib/work; ";
        $file_group .= "vlib questa_lib/msim; ";
        $file_group .= "vlib questa_lib/msim/xil_defaultlib; ";
        $file_group .= "vmap xil_defaultlib questa_lib/msim/xil_defaultlib; ";
        $compile .= " +define+AVY_BRAM_BAR2";
    }
    $simulate .= "vsim -64 -t 1fs -c -l simulate.log -lib xil_defaultlib ";
    if ($opt_d) {
        $vlog_stuff .= " $test";
        $simulate .= "apci_top";
        if ($opt_p =~ /axi/ and $opt_p =~ /dimm/) {
            $simulate .= " amem_top4";
	    }
        $simulate .= " $top ";
    } else {
        $simulate .= "apci_top apcit_xilinx_qdma ";
    }
    if ($opt_qemu) {
        $simulate .= "simcluster_master ";
    }
    if ($opt_gen6) {
        $runtime .= " +apci_gen6";
    }
    $runtime .= " -permit_unmatched_virtual_intf";
    $simulate .= "$runtime $pli -sv_lib ./libtb_ms64 -sv_seed $opt_n -do \"run -all; quit -force \" ";
    #$simulate .= "+apci_dbg_name=api,api_exit,cfg,avery_reg,cpl,ats,tr,mem,enum $pli -sv_lib ./libtb_ms64 -sv_seed $opt_n -do \"run -all; quit -force \" ";
    $cmd .= "$file_group";
    $cmd .= " vlog -64 -sv -l compile.log -work xil_defaultlib $vlog_stuff $compile ";
    $cmd .= "; $elaborate $simulate";
    return $cmd;
}

sub xm_execute {
    my $cmd = '';
    my $file_group = '';
    my $pli = "+loadpli1=$AVERY_PLI/lib.linux/libtb_xm64.so:wizard_bootstrap";
    my $file = '';
    my $xrun_opts = '';
    my $vlog_stuff .= &gene_filelist;
    my $sv = '';
    $pli .= " -sv_lib $qemu_pli";
    if ($is_release_version) {
        #$sv = " -v93";
        # v93 will somehow cause compilation error when using AXI package, need to check it later
        $sv = " -sv";
    } else {
        $sv = " -sv";
    }
    $xrun_opts .= " -64bit $sv -relax -access +rwc -namemap_mixgen -licqueue +xmstatus -l xm.log ";
    $xrun_opts .= " -sv_lib $AVERY_PLI/lib.linux/libtb_xm64.so";

    if ($opt_ep_unex_apb) {
        $file_group .= " -f $AVERY_EMU/demos/nvme/demo4/simulation/filelist/rtl_list_gen3_nc_apb";
        $file_group .= " $AVERY_EMU/demos/nvme/demo4/gpex_top/gpex_unex_top_apb.v";
    } elsif ($opt_ep_unex) {
        $xrun_opts .= " +sv_lib=$unex_release_folder/unex/sim/run/mvlm64.so";
        $file_group .= " -f $AVERY_EMU/demos/nvme/demo4/simulation/filelist/rtl_list_gen3_nc";
        $file_group .= " $AVERY_EMU/demos/nvme/demo4/gpex_top/gpex_unex_top.v";
    }

    if ($opt_ep_unex_apb or $opt_ep_unex) {
        $file_group .= " -v $AVERY_EMU/demos/pcie/demo4/pseudo/unisims.v";
        $file_group .= " +incdir+$AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/UD/src/chip/";
        $file_group .= " +incdir+$AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi4_dwidth_conv_32to256/hdl";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_crossbar/hdl/fifo_generator_v13_2_rfs.v";
        $file_group .= " -v $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_crossbar/hdl/axi_infrastructure_v1_1_vl_rfs.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_crossbar/hdl/axi_register_slice_v2_1_vl_rfs.v";
        $file_group .= " -v $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_crossbar/hdl/generic_baseblocks_v2_1_vl_rfs.v";
        $file_group .= " -v $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_crossbar/hdl/axi_data_fifo_v2_1_vl_rfs.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_crossbar/hdl/axi_crossbar_v2_1_vl_rfs.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_crossbar/sim/axi_crossbar.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_interconnect/simulation/fifo_generator_vlog_beh.v";
        $file_group .= " -v $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_interconnect/hdl/axi_interconnect_v1_7_vl_rfs.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_dwidth_converter_128to256/hdl/axi_dwidth_converter_v2_1_vl_rfs.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_dwidth_converter_128to256/sim/axi_dwidth_converter_128to256.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi_dwidth_converter/data_width_converter/sim/data_width_converter.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi4_dwidth_conv_32to256/hdl/axi_protocol_converter_v2_1_vl_rfs.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi4_dwidth_conv_256to32/sim/axi4_dwidth_conv_256to32.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi4_dwidth_conv_32to256/sim/axi4_dwidth_conv_32to256.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi4_protocol_conv_full2lite/sim/axi4_protocol_conv_full2lite.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/ES/src/core/xilinx/axi4_protocol_conv_lite2full/sim/axi4_protocol_conv_lite2full.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/UD/src/chip/axi_intf_rtl.sv";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/UD/src/chip/dut_csr_lite2apb.v";
        $file_group .= " $AVERY_EMU/demos/pcie/demo4/emulation_linux/VCU118_TBA/UD/src/chip/avy_axi2apb_conv.sv";
        $file_group .= " -top glbl $AVERY_QEMU/srcs/glbl.v";
    }

    $file_group .= $vlog_stuff;
    $file_group .= " -top apci_top";
    if ($opt_p =~ /axi/ and $opt_p =~ /dimm/) {
        $file_group .= " -top amem_top4";
    }
    $file_group .= " -top $top $test ";
    if ($opt_qemu) {
        $file_group .= " -top simcluster_master ";
    }
    if ($opt_gen6) {
        $runtime .= " +apci_gen6";
    }
    $compile .= " +define+AEMU_DUMMY";
    $compile .= " +apci_dbg_name=api,tlp_data_all";
    #$compile .= " +apci_dbg_name=api,api_exit,cfg,avery_reg,cpl,ats,tr,mem,enum,tlp_data_all,cxl_cache,cxl_hdm";
    if ($opt_hsw_bfm) {
        $compile .= " +define+ANVM_TOP_PATH=apci_top";
    }
    if ($opt_d) {
        $compile .= " +define+AVY_BRAM_BAR2";
    }
    $file .= "$file_group";

    $cmd .= "xrun $xrun_opts -svseed $opt_n +xmtimescale+1ps/1ps $runtime $pli $file $compile";
    return $cmd;
}

sub gene_filelist {
    my $vlog_stuff = '';
    my $src_dir = '';

    if ($opt_ieee) {
        $src_dir= "IEEE";
    } elsif ($opt_sim eq "xm") {
        $src_dir= "NC";
    } elsif ($opt_sim eq "mti") {
        $src_dir= "MTI";
    } elsif ($opt_sim eq "vcs") {
        $src_dir= "VCS";
    }

    if ($is_release_version) {
        # pcie files should be put before nvme files
        $vlog_stuff .= " +incdir+$AVERY_PCIE/src.$src_dir ";
        $vlog_stuff .= " +incdir+$AVERY_NVME/src.$src_dir ";
        $vlog_stuff .= " +incdir+$AVERY_QEMU/srcs_avy ";
        $vlog_stuff .= " +incdir+$AVERY_QEMU/testbench ";
        $vlog_stuff .= " +incdir+$AVERY_QEMU/src.$src_dir ";
        $vlog_stuff .= " $AVERY_PCIE/src/avery_pkg.sv ";
    } else {
        $vlog_stuff .= " +incdir+$AVERY_AVP/srcs_sv/srcs ";
        $vlog_stuff .= " +incdir+$AVERY_SIM/src ";
        $vlog_stuff .= " $AVERY_SIM/src/avery_pkg.sv ";
    }

    if ($opt_gen6) {
        $vlog_stuff .= " -f $AVERY_QEMU/filelist/avery_files_gen6.f ";
    } else {
        $vlog_stuff .= " -f $AVERY_QEMU/filelist/avery_files.f ";
    }

    if ($opt_p =~ /cxl/ || $opt_p =~ /pcie/) {
        $vlog_stuff .= " +incdir+$AVERY_PCIE/src.cxl";
        $vlog_stuff .= " +incdir+$AVERY_PCIE/src.sfi";
    }

    if ($opt_p =~ /axi/) {
        if ($is_release_version) {
            $vlog_stuff .= " -f $AVERY_QEMU/filelist/avery_files_axi_release.f ";
        } else {
            $vlog_stuff .= " -f $AVERY_QEMU/filelist/avery_files_axi.f ";
        }
    }

    if ($opt_p =~ /dimm/) {
        if ($is_release_version) {
            $vlog_stuff .= " -f $AVERY_QEMU/filelist/avery_files_dimm_release.f ";
        } else {
            $vlog_stuff .= " -f $AVERY_QEMU/filelist/avery_files_dimm.f ";
        }
    }

    if ($opt_nvme && ($opt_ep_bfm || $opt_hsw_bfm)) {
        $vlog_stuff .= " +incdir+$AVERY_PCIE/src.cxl";
        $vlog_stuff .= " +incdir+$AVERY_PCIE/src.sfi";
        $vlog_stuff .= " -f $AVERY_QEMU/filelist/avery_files_nvme.f ";
    }
    if ($opt_nvme && ($opt_ep_unex_apb or $opt_ep_unex)) {
        $vlog_stuff .= " -f $AVERY_QEMU/filelist/avery_files_axi.f ";
    }

    if ($is_release_version) {
        if ($opt_qemu) {
            $vlog_stuff .= " $AVERY_QEMU/src.$src_dir/qemu_simc_pkg.sv ";
            $vlog_stuff .= " $AVERY_QEMU/srcs_avy/simcluster_master.sv ";
            $vlog_stuff .= " $AVERY_QEMU/src.$src_dir/qemu_rx_pkg.sv ";
        }
        $vlog_stuff .= " $AVERY_QEMU/testbench/apci_top_qemu_ep.sv ";
    } else {
        if ($opt_qemu) {
            $vlog_stuff .= " $AVERY_QEMU/srcs/qemu_simc_pkg.sv ";
            $vlog_stuff .= " $AVERY_QEMU/srcs/simcluster_master.sv ";
            $vlog_stuff .= " $AVERY_QEMU/srcs/qemu_rx_pkg.sv ";
        }
        if ($opt_sw) {
            $vlog_stuff .= " $AVERY_QEMU/srcs/testbench/apci_top_rc_sw_ep.sv ";
        } else {
            $vlog_stuff .= " $AVERY_QEMU/srcs/apci_top_qemu_ep.sv ";
        }
    }

    return $vlog_stuff;
}

sub create_lib_mappings {
    my $file = "synopsys_sim.setup";
    my $lib_map_path="$AVERY_XIL_LIB/vcs64_patch2";
    my $sim_lib_dir="vcs_lib";
    my $lib = "$design_libs";
    my $mapping = "$lib:$sim_lib_dir/$lib";
    system "echo $mapping >> $file";
    my $incl_ref="OTHERS=$lib_map_path/synopsys_sim.setup";
    system "echo $incl_ref >> $file";
}

sub create_vcs_lib_dir {
    my $lib = "$design_libs";
    my $sim_lib_dir="vcs_lib";
    my $lib_dir="$sim_lib_dir/$lib";
}

sub copy_setup_file {
    my $file = "modelsim.ini";
    my $lib_map_path = "$AVERY_XIL_LIB/mti64_patch2";
    my $src_file = "$lib_map_path/$file";
    system "cp $src_file .";
}

sub setup_xilinx_sim_lib {
    if ($opt_s eq 'mti64') {
        &set_ini;
        &copy_setup_file;
        &create_mti_lib_dir;
    }
    elsif ($opt_s eq 'xm64') {
        &create_xm_lib_dir;
    }
    elsif ($opt_s eq 'vcs64') {
        # Avy RD: no need to add Xilinx lib
        #&create_lib_mappings;
        #&create_vcs_lib_dir;
    }
}

my %PID;
my $pid_prog = $$;
sub fork_proc {
    my ($pname, $cond, $func, @args)= @_;

    if ($cond and ($$ eq $pid_prog)) {
        $PID{$pname}= fork();
        if (!$PID{$pname}) {
            # child proc
            setpgrp(0, 0);
            &$func(@args);
        }
    }
}

sub check_sim {
    my ($sim)= @_;
    my $errno;

    $errno = system ("command -V $sim > /dev/null");
    die ("Please add \"$sim\" into your \$PATH\n") if ($errno);
}

sub execute_cmd {
    my $cmd;
    if ($opt_s eq 'mti64') {
        &check_sim("vsim");
        $cmd = &mti_execute;
    }
    elsif ($opt_s eq 'xm64') {
        &check_sim("xrun");
        $cmd = &xm_execute;
    }
    elsif ($opt_s eq 'vcs64') {
        &check_sim("vcs");
        $cmd = &vcs_execute;
    }
    exec ($cmd);
}

sub execute_spdm {
    my $cmd;
    my $openspdm;
    my $build_dir;
    my $errno;
    my $ver;

    if ($is_release_version) {
        $ENV{"LD_LIBRARY_PATH"}.= ":$AVERY_QEMU/../aqemu/tools/SimCluster/";
        $build_dir = "$AVERY_QEMU/../aqemu/tools/3rd_party/openspdm";
    } else {
        $openspdm = "$AVERY_AVP/tools/openspdm/";
        $build_dir = "$openspdm/Build/DEBUG_GCC/X64";

        if (! -e "$build_dir/SpdmResponderEmu") {
            $ver = `gcc -dumpversion|awk -F. '{print \$1}'`;
            if ($ver < 8) {
                die ("Error: gcc must >= 8\n");
            }

            $errno = system ("[ \"\$(ls -A $openspdm/UnitTest/CmockaLib/cmocka)\" ] && true || false");
            if ($errno) {
                $cmd = "cd $openspdm/UnitTest/CmockaLib/;";
                #$cmd .= "wget https://cmocka.org/files/1.1/cmocka-1.1.5.tar.xz;";
                $cmd .= "tar xf cmocka-1.1.5.tar.xz;";
                $cmd .= "mv cmocka-1.1.5 cmocka";
                $errno = system ($cmd);
                if ($errno) {
                    die ("Error: preparing for cmocka\n");
                }
            }

            $errno = system ("[ \"\$(ls -A $openspdm/OsStub/OpensslLib/openssl)\" ] && true || false");
            if ($errno) {
                $cmd = "cd $openspdm/OsStub/OpensslLib/;";
                #$cmd .= "wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz;";
                $cmd .= "tar xf openssl-1.1.1g.tar.gz;";
                $cmd .= "mv openssl-1.1.1g openssl";
                $errno = system ($cmd);
                if ($errno) {
                    die ("Error: preparing for openssl\n");
                }
            }

            $cmd = "cd $openspdm;";
            $cmd .= "make -f GNUmakefile ARCH=X64 TARGET=DEBUG CRYPTO=Openssl -e WORKSPACE=.";
            $errno = system ($cmd);
            if ($errno) {
                die ("Error: building openspdm\n");
            }
        }
    }
    $cmd = "cd $build_dir;";
    $cmd .= "./SpdmResponderEmu --trans PCI_DOE --pcap SpdmResponder.pcap 2>&1";
    exec ($cmd);
}

sub set_ini {
    my $pwd = `pwd`;
    $pwd =~ s/\n//g;
    $ENV{MODELSIM} = "$pwd/modelsim.ini";
}

sub create_mti_lib_dir {
    my $lib_dir = "questa_lib";
    system "rm -rf $lib_dir" if (-e "$lib_dir");
    system "mkdir $lib_dir";
}

sub compile_dpi() {
    my $cwd= `pwd`;
    chomp $cwd;
    system "cd $AVERY_AVP/srcs_sv/dpi; make";
    system "cd $cwd";
}

sub check_env() {
    $AVERY_SIM = $ENV{"AVERY_SIM"};
    if ( -e "$AVERY_SIM") {
        print "Running on Avery internal version\n";
    } else {
        # for release kit
        print "Running on Avery EMU release", "$AVERY_SIM", " is empty\n";
        $AVERY_SIM = $ENV{"AVERY_PCIE"};
        #$is_release_version = 1;
    }
    $AVERY_PLI = $ENV{"AVERY_PLI"};
    if (! -e "$AVERY_PLI") {
        die "Error: env variable AVERY_PLI($AVERY_PLI) is not setup properly\n";
    }
    $AVERY_PCIE = $ENV{"AVERY_PCIE"};
    if (! -e "$AVERY_PCIE" && ($opt_p eq "pcie" || $opt_p =~ /cxl/ || $opt_nvme)) {
        die "Error: env variable AVERY_PCIE($AVERY_PCIE) is not setup properly\n";
    }
    $AVERY_NVME = $ENV{"AVERY_NVME"};
    if (! -e "$AVERY_NVME" && $opt_nvme) {
        die "Error: env variable AVERY_NVME($AVERY_NVME) is not setup properly\n";
    }
    # if not release, use the old env_var AVERY_QDMA
    $AVERY_XIL_LIB = $ENV{"AVERY_XIL_LIB"};
    if ($is_release_version) {
        if ($opt_p =~ /cxl/) {
            $AVERY_QEMU = $ENV{"AVERY_QCXL"};
            $AVERY_QEMU .= "/aqcxl";
        } elsif ($opt_p =~ /pci/) {
            $AVERY_QEMU = $ENV{"AVERY_QPCI"};
            $AVERY_QEMU .= "/aqpci";
        } else {
            $AVERY_QEMU = $ENV{"AVERY_QNVME"};
            $AVERY_QEMU .= "/aqnvme";
        }
    } else {
        $AVERY_AVP = $ENV{"AVERY_AVP"};
        if (! -e "$AVERY_AVP") {
            die "Error: env variable AVERY_AVP($AVERY_AVP) is not setup properly\n";
        }
        $AVERY_AXI = $ENV{"AVERY_AXI"};
        if (! -e "$AVERY_AXI") {
            die "Error: env variable AVERY_AXI($AVERY_AXI) is not setup properly\n";
        }
        #$AVERY_QEMU = ${"AVERY_QDMA"};
        $AVERY_QEMU = $AVERY_AVP."/srcs_sv";
    }
    if (! -e "$AVERY_QEMU") {
        die "Error: env variable AVERY_QEMU($AVERY_QEMU) is not setup properly\n";
    }
    if ($opt_ep_unex_apb) {
        $unex_release_name= "avery-unex_AVERY_UNEX_GPEX_V_1_0_20190403";
    } elsif ($opt_ep_unex) {
        $unex_release_name= "avery-unex_AVERY_UNEX_GPEX_V_1_0";
    }
    if ($opt_ep_unex_apb or $opt_ep_unex) {
        $AVERY_EMU = $ENV{"AVERY_EMU"};
        if (! -e "$AVERY_EMU") {
            die "Error: env variable AVERY_EMU($AVERY_EMU) is not setup properly\n";
        }
        $unex_release_folder= "$AVERY_EMU/ip/nvme/mobiveil/$unex_release_name/gpex_unex";
        $ENV{"UNEX"} = $UNEX = $unex_release_folder;
    }

}

sub create_xm_lib_dir {
    my $lib_dir = '';
    my $sim_lib_dir ="xcelium_lib";
    $lib_dir = "$sim_lib_dir/$design_libs";
}

sub var_init {

    if ($opt_nvme && $opt_ep_unex_apb && $opt_s ne "xm64") {
        system("echo We does not support -p nvme and -ep_unex on mti/vcs now!!\t");
        exit;
    }

    $compile = join (' ', @opt_C);

    if ($opt_s eq "xm64") {
        $compile .= " +define+AVERY_NC";
    } elsif ($opt_s eq "vcs64") {
        $compile .= " +define+AVERY_VCS";
    }

    if ($opt_qemu) {
        $compile .= " +define+AUTO_ENUM_OFF";
    }

    if ($opt_w eq 'vcd') {
        $compile .= " +define+APCI_DUMP_VCD";
    } elsif ($opt_w eq 'fsdb') {
        $compile .= " +define+APCI_DUMP_FSDB";
    } elsif ($opt_w eq 'awdb') {
        $compile .= " +define+APCI_DUMP_AWDB";
    }

    if ($opt_hsw_bfm) {
        $compile .= " +define+AEMU_HSW_BFM+ANVM_USE_NEW_PCIE";
    }
    if ($opt_p =~ /cxl/) {
        $compile .= " +define+AVERY_CXL";
        $compile .= " +define+AVERY_CXL_HDM";
        $compile .= " +define+AVERY_SC_CACHE";
        if ($opt_p =~ /cxl1.1/) {
            $compile .= " +define+AVERY_CXL_1_1";
        }
        if ($opt_p =~ /axi/ and $opt_p =~ /dimm/) {
            $compile .= " +define+ACXL_AXI_MC";
        }
        if (($opt_nDecoder ne 1) or ($opt_nEP ne 1)) {
            $compile .= " +define+APCI_MPORT";
            if ($opt_nDecoder ne 1) {
                $compile .= " +define+SEPARATE_EP";
            }
        }
    }

    if ($opt_nvme) {
        $compile .= " +define+AVERY_NVME";
    }

    if ($opt_ep_bfm) {
        $compile .= " +define+AEMU_EP_BFM";
        if ($opt_nvme) {
            $compile .= " +define+ANVM_USE_NEW_PCIE";
        }
    }
    if ($opt_spdm) {
        $compile .= " +define+AVERY_SPDM";
    }

    if ($opt_sriov) {
        $compile .= " +define+AQEMU_SRIOV";
    }

    if ($opt_ep_unex_apb or $opt_ep_unex){
        $compile .= " +define+AVERY_AXI_BFM+AVY_IF_DATA_WIDTH=$opt_b+AAXI_MAX_ID_WIDTH=8";
        $compile .= " +define+AEMU_EP_UNEX+AEMU_NOT_LOGIC_SIM+APCI_OLD_PIPEBOX_MODE";
        if ($opt_ep_unex_apb) {
            $compile .= " +define+AEMU_UNEX_APB";
        }
    }

    $top = $opt_t;
    $test = $opt_t;
    $top =~ s/.sv//g;

    $runtime= join(' ', @opt_R);
}

sub set_t {
    #Search the path to find the test
    $test = &search_test_case($test);
}

sub search_test_case($)
{
    my ($test2) = @_;
    my $found = 0;
    my @test_dir_array;

    print "Search testcase: $test2 ...\n";
    if ($test2 eq "") {
        if ($opt_p eq "pcie") {
            $test2 = " apcit_xilinx_qdma $AVERY_QEMU/testsuite/apcit_xilinx_qdma.sv";
        }
        print "Use default testcase: $test2 ...\n";
        return $test2;
    }
    @test_dir_array = ("./",
                       "$AVERY_QEMU/srcs",
                       "$AVERY_QEMU/testsuite",
                       "$AVERY_PCIE/testsuite/dut",
                       "$AVERY_PCIE/testsuite/dut_ep",
                       "$AVERY_PCIE/testsuite/examples",
                       "$AVERY_PCIE/testsuite/internal",
                       "$AVERY_NVME/testsuite/examples",
                      );

    my @test_list2 = split / /, $test2;
    my $test_list2_size = @test_list2;
    foreach my $test2 (@test_list2) {
        foreach my $dir (@test_dir_array) {
            if ( -e "$dir/$test2" ) {
                $test2 = "$dir/$test2";
                $found++;
                last;
            }
        }
    }

    $test2= join " ", @test_list2;
    if ($test_list2_size ne $found) {
        print "Error: Some testname does not exist.\n";
        exit 1;
    }
    return $test2;
}

sub cat_log {
    if ($opt_s eq 'mti64') {
        system ("rm -rf mti.log") if (-e "mti.log");
        system ("cat compile.log elaborate.log simulate.log >> mti.log");
    }
    #elsif ($opt_s eq 'vcs64') {
    #    system ("rm -rf vcs.log") if (-e "vcs.log");
    #    system ("cat elaborate.log simulate.log vlogan.log >> vcs.log");
    #}
    else {}
}

sub main {
    $SIG{'INT'} = \&kill_all_proc;

    &check_env;
    if (!$is_release_version) {
        &compile_dpi;
        $qemu_pli .= "$AVERY_QEMU/dpi/libqemu64";
    } else {
        $qemu_pli .= "$AVERY_QEMU/../aqemu/lib/libqemu64";
    }

    if ($AVERY_XIL_LIB ne "") {
        &setup_xilinx_sim_lib;
    }
    &var_init;
    &set_t;
#    &execute_cmd;
    &fork_proc("sim_cmd", 1, \&execute_cmd,);
    &fork_proc("spdm", $opt_spdm, \&execute_spdm,);
    # wait for all child process
    &kill_all_proc(waitpid (-1, 0));
    &cat_log;
}

sub kill_all_proc {
    my ($rid)= @_;

    foreach my $p (keys %PID) {
        if ($rid eq $PID{$p}) {
            print ("\n$p returned.\n");
        } else {
            kill (9, -$PID{$p});
        }
    }
}

&parse_arg(\@ARGV);
&main;
