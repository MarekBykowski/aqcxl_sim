#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use constant {
    X86 => 1,
    ARM => 2,
    AARCH64 => 3,
    MICROB  => 4,
};

use constant {
    LINUX => 1,
    FREERTOS => 2,
};

my %ENVH;
my $cur_dir;
my $prog;
my $is_release_version= 1;

my $opt_qt= 10000000;
# opt_qt set to 10^7 because larger number will cause Zynq board boot-up error
my $opt_n;
my $opt_bfm= 0;
my $opt_pci= 0;
my $opt_nvme=0;
my $opt_cxl= 0;
my $opt_axi= 0;
my $opt_enet= 0;
my $opt_cxl_1_1= 0;
my $opt_pass= 0;
my $opt_ats= 0;

my $opt_uimg= 0;
my $opt_qc;
my $opt_cimg;
my $opt_dimg;
my $opt_kernel;
my $opt_rd;
my $opt_mroot;
my $opt_dtb;
my $opt_elf;
my $opt_arch= X86;
my $opt_gdb= 0;
my $opt_valgrind= 0;
my $opt_dbg_sc= 0;
my $opt_Nway= 0;
my $opt_cache_cap= 0;
my $opt_line_size= 0;
my $opt_kgdb= 0;
my $opt_Q= "";
my $opt_vnc= 0;
my $opt_regr= 0;
my $opt_sv= 0;
my $opt_q= 0;
my $opt_dbg_qemu= 0;
my $opt_port= 9210;
my $opt_ip='127.0.0.1';
my $opt_dbg_bios= 0;
my $opt_kvm= 1;
my $opt_hotplug= 0;
my $opt_kmsg= 0;
my $opt_qemu_gdb= 0;
my $opt_io_warp= 1;
my $opt_dma_warp= 0;
my $opt_bios= "";
my $opt_ovmf= 0;
my $opt_ovmf_code= "";
my $opt_ovmf_vars= "";
my $opt_nDecoder= 1;
my $opt_nEP= 1;
my $opt_static= 0;
my $opt_os= LINUX;
my $opt_snapshot= 0;
my $opt_nographic= 0;
my $AVERY_AVP;
my $AVERY_QEMU;
my $QEMU_DIR="";
my $QEMU_MACH;
my $PETA_PROJ_PATH;
my $SC_PROJ_DIR;
my $SC_PROG_NAME;
my $DPI_DIR;
my $DPI_PROG_NAME;
my $hdm_cnt= 1;
my $cpu_type= "Broadwell";

my $GIT_SERVER= "emudemo\@avery147";
my $uver= "16.04";
my $uimg= "ubuntu-$uver-server-amd64.iso";
#my $uver= "18.04.4";
#my $uimg= "ubuntu-$uver-live-server-amd64.iso";
my $uimg_path;
my $ssh_port;
my $log_dir= "log";
my $qemu_log= "$log_dir/qemu.log";
my $pswd_host;
my $regr_log_dir;
my $bios_dbg_pipe= "qemudebugpipe";
my $uname= getpwuid($<);
my $tmp_qemu_dir;
my $opt_sw = 0;
my $opt_perf = 0;

# for process control
my %PID;
my $pid_prog= $$;

my $start_run = time();

sub set_env {
    if (!$is_release_version) {
        $ENVH{"AVERY_AVP"}= $ENV{"AVERY_AVP"};
        $AVERY_AVP= $ENV{"AVERY_AVP"};
    } else {
        if ($opt_axi) {
            $ENVH{"AVERY_QAXI"}= $ENV{"AVERY_QAXI"};
            $AVERY_QEMU= $ENV{"AVERY_QAXI"};
        } elsif ($opt_cxl) {
            $ENVH{"AVERY_QCXL"}= $ENV{"AVERY_QCXL"};
            $AVERY_QEMU= $ENV{"AVERY_QCXL"};
        } elsif ($opt_enet) {
            $ENVH{"AVERY_QENET"}= $ENV{"AVERY_QENET"};
            $AVERY_QEMU= $ENV{"AVERY_QENET"};
        } elsif ($opt_nvme) {
            $ENVH{"AVERY_QNVME"}= $ENV{"AVERY_QNVME"};
            $AVERY_QEMU= $ENV{"AVERY_QNVME"};
        } elsif ($opt_pci) {
            $ENVH{"AVERY_QPCI"}= $ENV{"AVERY_QPCI"};
            $AVERY_QEMU= $ENV{"AVERY_QPCI"};
        }
        $AVERY_QEMU .= "/aqemu";
    }

    # env variable check
    foreach my $ENV_KEY (keys %ENVH) {
        if(!$ENVH{$ENV_KEY} or ! -e $ENVH{$ENV_KEY}) {
            die ("$prog: Error: env variable $ENV_KEY is not setup properly\n");
        }
    }
}

sub set_qemu_env {
    my $build_dir;
    my $qemu_type;

    $ssh_port= &check_port("SSH", 2222);

    # release doesn't have $QEMU_DIR
    if ($opt_arch eq X86) {
        $qemu_type= "x86_64-softmmu";
        if ($is_release_version) {
            $build_dir= $AVERY_QEMU."/tools/build_x86";
        } else {
            if ($opt_cxl) {
                $QEMU_DIR= $AVERY_AVP."/tools/qemu-cxl";
            } else {
                $QEMU_DIR= $AVERY_AVP."/tools/qemu";
            }
            # TODO: merge cxl-qemu and qemu repos into one
            # This is a workaround
            $QEMU_DIR= $AVERY_AVP."/tools/qemu-cxl";
            if (! -e $QEMU_DIR) {
                $QEMU_DIR= $AVERY_AVP."/tools/qemu";
            }
            # workaround end
            $build_dir= $QEMU_DIR."/build_x86";
        }
        $QEMU_MACH= $build_dir."/$qemu_type/qemu-system-x86_64";
        if (not defined($opt_cimg)) {
            &check_qcow;
        }
    } elsif ($opt_arch eq MICROB) {
        if ($is_release_version) {
            $build_dir= $AVERY_QEMU."/tools/build_microb";
        } else {
            $QEMU_DIR= $AVERY_AVP."/tools/qemu-cxl";
            $build_dir= $QEMU_DIR."/build_microb";
        }
        $qemu_type= "microblazeel-softmmu";
        $QEMU_MACH= $build_dir."/$qemu_type/qemu-system-microblazeel";
    } else {
        if ($is_release_version) {
            $build_dir= $AVERY_QEMU."/tools/build_aarch64";
        } else {
            $QEMU_DIR= $AVERY_AVP."/tools/qemu-cxl";
            $build_dir= $QEMU_DIR."/build_aarch64";
        }
        $qemu_type= "aarch64-softmmu";
        $QEMU_MACH= $build_dir."/$qemu_type/qemu-system-aarch64";
    }

    if (!$is_release_version) {
        &check_qemu_machine($build_dir, $qemu_type);
    }

    if ($opt_uimg) {
        &check_uimg;
    }

    if ($opt_dbg_bios and ! -e "$cur_dir/$bios_dbg_pipe") {
        system ("mkfifo $cur_dir/$bios_dbg_pipe");
    }
}

sub set_dpi_env {
    if(!$is_release_version) {
        $DPI_DIR= $AVERY_AVP."/srcs_sv/dpi/";
        $DPI_PROG_NAME= "libqemu64.so";

        &make_prog($DPI_DIR, $DPI_PROG_NAME, "", "");
    }
}

sub set_sc_env {
    my %LIBH;
    my $LD_LIBRARY_PATH= $ENV{"LD_LIBRARY_PATH"};
    my $make_opt = "";

    if (not defined $LD_LIBRARY_PATH) {
        $LD_LIBRARY_PATH= "";
    }
    # if both opt_cxl and opt_pci is used, use avy_cxl_sc.exe
    if ($opt_cxl) {
        $SC_PROG_NAME= "bin/avy_cxl_sc.exe";
    } elsif ($opt_axi) {
        $SC_PROG_NAME= "bin/avy_axi_sc.exe";
    } elsif ($opt_enet) {
        $SC_PROG_NAME= "bin/avy_enet_sc.exe";
    } else {
        $SC_PROG_NAME= "bin/avy_pci_sc.exe";
    }
    if ($is_release_version) {
        $SC_PROJ_DIR= $AVERY_QEMU;

        $LIBH{"TOOLS"}= $AVERY_QEMU."/tools/";
        $LIBH{"LIBS"}= $AVERY_QEMU."/lib/";
    } else {
        $SC_PROJ_DIR= $AVERY_AVP."/srcs_sc";

        $LIBH{"LIBRP"}= $AVERY_AVP."/tools/libsystemctlm-soc/libremote-port/";
        $LIBH{"LIBSYSC"}= "/edatools/systemc-2.3.3-gcc-6.4/lib-linux64/";
        $LIBH{"LIBSTDCPP"}= "/edatools/gcc-6.4.0/usr/local/lib64";
        $LIBH{"LIBSIMCL"}= $AVERY_AVP."/tools/SimCluster/lib";
        $LIBH{"LIBSIMC"}= $SC_PROJ_DIR."/libsimc/";
        $LIBH{"LIBAPPENDKEY"}= $AVERY_AVP."/srcs_sv/dpi/";

        &make_prog($SC_PROJ_DIR, $SC_PROG_NAME, "Compiling SystemC program...", $make_opt);
    }

    foreach my $LIB_KEY (keys %LIBH) {
        if(! -e "$LIBH{$LIB_KEY}") {
            die ("$prog: Error: library $LIBH{$LIB_KEY} does not exist\n");
        } else {
            $LD_LIBRARY_PATH= $LIBH{$LIB_KEY}.":".$LD_LIBRARY_PATH;
        }
    }
    $ENV{"LD_LIBRARY_PATH"}= $LD_LIBRARY_PATH;
}

sub make_prog {
    my ($dir, $target, $log, $opt)= @_;

    my $errno;

    if ($opt_n) {
        return;
    }

    if ($log) {
        print ("$prog: $log\n");
    } else {
        print ("$prog: Compiling $target...\n");
    }

    if (! -e $dir) {
        die ("$prog: Error: $dir doesn't exist\n");
    }
    chdir $dir;

    $errno= system("make $opt -j16 2>&1");
    if ($errno or ! -e $target) {
        die ("$prog: Error: error returns from making $target\n");
    }
}

sub build_peta_proj {
    my $exec_cmd;
    my $PATH= $ENV{"PATH"};

    print ("$prog: Building PetaLinux project...\n");

    if (not defined $ENV{"PETALINUX"}) {
        die ("$prog: Install PetaLinux and set \$PETALINUX properly.
Please refer to \$AVERY_AVP/README.qemu for installation steps.\n");
    }
    if (not defined $PATH) {
        $PATH= "";
    }

    $PATH.= ":$ENV{PETALINUX}/tools/xsct/petalinux/bin";
    $PATH.= ":$ENV{PETALINUX}/tools/common/petalinux/bin";
    $PATH.= ":$ENV{PETALINUX}/tools/xsct/bin";
    $PATH.= ":$ENV{PETALINUX}/tools/xsct/gnu/microblaze/lin/bin";
    $PATH.= ":$ENV{PETALINUX}/tools/xsct/gnu/armr5/lin/gcc-arm-none-eabi/bin";
    $PATH.= ":$ENV{PETALINUX}/tools/xsct/gnu/aarch64/lin/aarch64-none/bin";
    $PATH.= ":$ENV{PETALINUX}/tools/xsct/gnu/aarch32/lin/gcc-arm-none-eabi/bin";

    $ENV{"PETALINUX_VER"}= "2019.1";
    $ENV{"PATH"}= $PATH;

    $exec_cmd.= "petalinux-build -c rootfs;";
    $exec_cmd.= "petalinux-build -c device-tree";

    chdir $PETA_PROJ_PATH;
    system($exec_cmd);
}

sub check_uimg {
    chdir $cur_dir;
    if (not defined($uimg_path)) {
        $uimg_path= "$AVERY_AVP/QEMU/pcie_sc_cosim/$uimg";
    }

    if (! -e $uimg_path) {
        if($is_release_version){
            die ("$prog: OS image does not exist. Please re-run $prog with \"-os_img <path>\" option.\n");
        } else {
            &get_uimg;
        }
    }
}

sub get_uimg {
    my $exec_cmd= "";
    my $uweb= "http://releases.ubuntu.com/$uver/$uimg";

    print ("$prog: Dowdloading ubuntu image from $uweb...\n");

    $exec_cmd.= "wget $uweb -O $uimg_path";
    system ($exec_cmd);
}

sub check_qcow {
    chdir $cur_dir;
    if (not defined($opt_qc)) {
        if ($is_release_version) {
            $opt_qc= $AVERY_QEMU."/ubuntu.qcow";
        } else {
            $opt_qc= $AVERY_AVP."/QEMU/pcie_sc_cosim/ubuntu.qcow";
        }
    }

    if ($opt_n) {
        return;
    }
    if (! -e $opt_qc) {
        print ("$prog: Can't find qcow file.\n");
        print ("You can move your pre-built qcow file to $opt_qc or add \"-qc <path>\" option.\n");
        print ("Create qcow automatically? <y/n>\n");
        chomp(my $input=<STDIN>);
        if ($input eq "y") {
            &build_qcow;
        } else {
            exit 0;
        }
    }
}

sub build_qcow {
    my $exec_cmd= "";

    chdir $cur_dir;
    print ("$prog: Building qcow ...\n");

    $exec_cmd.= "qemu-img create";
    $exec_cmd.= " -f qcow2 $opt_qc";
    $exec_cmd.= " -o preallocation=full 32G";

    system ($exec_cmd);
    $opt_uimg= 1;
}

sub check_qemu_machine {
    my ($build_dir, $qemu_type)= @_;

    if (! -e $QEMU_MACH) {
        if (! -e $QEMU_DIR) {
            print ("Please checkout qemu/ from avery server:\n");
            print ("\$ git clone $GIT_SERVER:~/qemu --branch tools\n");
            exit -1;
        }
        &config_qemu_machine($build_dir, $qemu_type);
    }
    if (!$is_release_version) {
        &make_prog($build_dir, $QEMU_MACH, "Building QEMU machine...", "");
    }
}

sub config_qemu_machine {
    my ($build_dir, $qemu_type)= @_;

    my $exec_cmd= "";
    my $errno= 0;

    print ("$prog: Configuring QEMU machine...\n");

    mkdir $build_dir;
    chdir $build_dir;

    $exec_cmd.= "../configure";
    $exec_cmd.= " --target-list=$qemu_type";
    $exec_cmd.= " --disable-sdl";
    if ($opt_arch eq X86){
        $exec_cmd.= " --audio-drv-list=oss";
        $exec_cmd.= " --disable-curl";
        $exec_cmd.= " --disable-libssh";
        $exec_cmd.= " --disable-xkbcommon";
        $exec_cmd.= " --disable-gtk";
        $exec_cmd.= " --disable-opengl";
        $exec_cmd.= " --disable-libiscsi";
        $exec_cmd.= " --disable-libudev";
        $exec_cmd.= " --disable-libusb";
        $exec_cmd.= " --disable-vnc-sasl";
        $exec_cmd.= " --disable-selinux";
        if ($opt_static) {
            $exec_cmd.= " --static";
        }
    }
    $exec_cmd.= " --enable-debug 2>&1";

    $errno= system($exec_cmd);
    if ($errno) {
        die ("$prog: Error: error returns from configure\n");
    }
}

sub show_usage {
    use File::Basename;
    chomp(my $prog= basename($0));
    my $usage= "";

    if ($is_release_version) {
    $usage= "
$prog [options]
     -qc <path>                         Specify the qcow path
     -bios <path>                       Specify the BIOS
     -os_img <path>                     Path to OS installation image
     -Q <QEMU option>                   Add additional QEMU option
     -kgdb                              Open serial port for kgdb
     -ip                                Assign ip for connection to master, two formats
                                        ip, ex. 127.0.0.1 (port will be default port)
                                        ip:port, ex. 127.0.0.1:9210
     -snapshot                          Temporary snapshot for QEMU
     -nographic                         Enables the nographic option of QEMU
     -kvm                               Enable Kernel-based Virtual Machine feature
     -nokvm                             Disable Kernel-based Virtual Machine feature
     -dut [bfm=<name>|passthru],n=<num> Specify QEMU's mode
                                        * bfm:
                                          Connect to Avery's BFM, available now:
                                            pcie cxl2.0 cxl1.1
                                        * Only for cxl:
                                          ex: 1 endpoint per root decoder, 2 decoders
                                          -dut bfm=cxl2.0,nEP=1,nDecoder=2
                                              2 endpoint per root decoder, 1 decoder
                                          -dut bfm=cxl2.0,nEP=2,nDecoder=1
                                        * passthru:
                                          Use the vfio passthrough mode
     [CXL Only options]
     -perf <offset>                     Specify Avery's Performance DVSEC Register offset
     [SC cache options]
     -Nway                              Number of ways(default: 0x10)
     -cache_cap                         Cache capacity(default: 0x1000000)
     -line_size                         Cache line size(default: 0x40)
Ex:
    \$ $prog -ip 192.168.1.17:12321 -qc <qcow> -bios <UEFI>
";
    } else {
    $usage= "
$prog [options]
    [QEMU related]
     -arch [X86]                        Specify QEMU machine's architecture
                                        (default: x86)
     -os [LINUX]                        Specify Operation System
                                        (default: LINUX)
     -os_img <path>                     Path to OS installation image
     -kvm                               Enable Kernel-based Virtual Machine feature
     -nokvm                             Disable Kernel-based Virtual Machine feature
     -kmsg                              Redirect the kernel message to a pusedo terminal
     -qemu_gdb                          Use QEMU's GDB port
     -bios <path>                       Specify the BIOS
     -ovmf,code=<path>,vars=<path>      Specify the path to OVMF_CODE.fd and OVMF_VAR.fd for UEFI
     -kgdb                              Open serial port for kgdb
     -Q <QEMU option>                   Add additional QEMU option
     -dbg_bios                          Turn on for BIOS debugging
     -ip                                Assign ip for connection to master, two formats
                                        ip, ex. 127.0.0.1 (port will be default port)
                                        ip:port, ex. 127.0.0.1:9210
     -qc <path>                         Specify the qcow path
                                        If not specified, the default path is
                                        \"\$AVERY_AVP/QEMU/pcie_sc_cosim/\"
     -cimg <path>                       Cloud image path
                                        Using cloud image to launch qemu
                                        Note: if you also add -qc arg, then -qc arg will be invalid!
     -dimg <path>                       Disk image file path
     -kernel <path>                     Kernel file path
     -rd <path>                         ramdisk file path
     -mroot <path>                      mounted root directory
     -snapshot                          Temporary snapshot for QEMU
    [DUT related]
     -dut [bfm=<name>|passthru],n=<num> Specify QEMU's mode
                                        * bfm:
                                          Connect to Avery's BFM, available now:
                                            pcie cxl2.0 cxl1.1
                                        * Only for cxl:
                                          ex: 1 endpoint per root decoder, 2 decoders
                                          -dut bfm=cxl2.0,nEP=1,nDecoder=2
                                              2 endpoint per root decoder, 1 decoder
                                          -dut bfm=cxl2.0,nEP=2,nDecoder=1
                                        * passthru:
                                          Use the vfio passthrough mode
                                        Use n to decide number of devices
     -hotplug                           Use hotplug to insert the remote-port-pci-device
     -io_warp                           Warp QEMU time within each individual MMIO
     -dma_warp                          Warp QEMU time between continuous DMA
     -dbg <N>                           Turn on debug verbosity for QEMU
                                        If N is not specified, debug verbosity
                                        is set to 0x1
     -AVY_PORT=<port>                   Assign port for SimCluster
     -dual                              Dual Port
     -qt <quantum>                      SystemC sync quantum, default is $opt_qt
   [SystemC debugging related]
     -dbg_sc <N>                        Turn on debug verbosity for SystemC
                                        If N is not specified, debug verbosity
                                        is set to 0xb
     -gdb                               Debug SystemC program with GDB
     -valgrind                          Run SystemC program with Valgrind
   [CXL Only options]
     -perf <offset>                     Specify Avery's Performance DVSEC Register offset
   [Others]
     -n                                 Just print QEMU command
     -q                                 Quiet
     -vnc                               Call vncviewer and connect to vnc port automatically
     -regr                              Run regression
     -sv                                Run run_qemusv.pl script

Ex:
    \$ $prog -dut bfm=cxl2.0 -ovmf -qc <qcow>
    \$ $prog -dut bfm=axi -arch AARCH64 -qc <qcow> -bios <bios>
    \$ $prog -dut bfm=enet -arch AARCH64 -os FREERTOS -dtb <dtb> -elf <elf>
";
    }

    print("$usage\n");
    exit(0);
}

sub parse_arg {
    my ($argv_ref)= @_;
    my $argc= scalar(@{$argv_ref});
    my $timestamp = localtime(time);
    my $run_cmd= "$log_dir/$prog";
    $run_cmd=~ s/\.pl/\.cmd/;

    chdir $cur_dir;
    mkdir $log_dir;

    open (my $fh, '>>', $run_cmd) or die ("$prog: Could not open file '$run_cmd' ($!)\n");
    print $fh "[".$timestamp."] " .$0." ".join(" ", @{$argv_ref})."\n";
    close $fh;

    for (my $i= 0; $i < $argc; $i++) {
        my $arg= ${$argv_ref}[$i];
        my $val= ${$argv_ref}[$i + 1];

        if ($arg eq "-h") {
            &show_usage;
        } elsif ($arg eq "-p") {
            # deprecated, use dut
            if (not defined($val)) {
                die ("$prog: $arg: Invalid project name\n");
            }
            if ($val =~ /passthru/) {
                $opt_pass = 1;
            }
            $i++;
        } elsif($arg eq "-ip"){
            $opt_ip = $val;
            my @ip_port = split(':', $opt_ip);
            $opt_ip = $ip_port[0];
            if ($ip_port[1]) {
                $opt_port = $ip_port[1];
            }
            $i++;
        } elsif ($arg eq "-dut") {
            if (not defined($val)) {
                die ("$prog: $arg: Invalid usage\n");
            }
            if ($val =~ /bfm=(nvme|pci|pcie|cxl1.1|cxl|axi|enet)/) {
                $opt_bfm= 1;
                if ($1 eq "pci" or $1 eq "pcie") {
                    $opt_pci= 1;
                } elsif ($1 eq "nvme") {
                    $opt_pci= 1;
                    $opt_nvme= 1;
                } elsif ($1 eq "cxl1.1") {
                    $opt_cxl_1_1= 1;
                    $opt_cxl= 1;
                } elsif ($1 eq "cxl") {
                    $opt_cxl= 1;
                } elsif ($1 eq "axi") {
                    $opt_axi= 1;
                } elsif ($1 eq "enet") {
                    $opt_enet= 1;
                }
            } elsif ($val =~ /passthru/) {
                $opt_pass = 1;
            } else {
                die ("$prog: $arg: Invalid usage\n");
            }
            if ($val =~ /nDecoder=(\d)/) {
                $opt_nDecoder= $1;
            }
            if ($val =~ /nEP=(\d)/) {
                $opt_nEP= $1;
            }
            print("Booting QEMU using $opt_nEP endpoints per decoder with $opt_nDecoder decoder, total ".($opt_nEP*$opt_nDecoder)," endpoints\n");
            $i++;
        } elsif ($arg eq "-arch") {
            if (not defined($val) or not defined(eval($val))) {
                die ("$prog: $arg: Invalid usage\n");
            }
            $opt_arch= eval($val);
            $i++;
        } elsif ($arg eq "-os") {
            if (not defined($val) or not defined(eval($val))) {
                die ("$prog: $arg: Invalid usage\n");
            }
            $opt_os= eval($val);
            $i++;
        } elsif ($arg eq "-qt") {
            if ($val =~ /\D/) {
                die ("$prog: $arg: Quantum value should be an positive integer\n");
            }
            $opt_qt= $val;
            $i++;
        } elsif ($arg eq "-qc") {
            if (not defined($val)) {
                die ("$prog: $arg: Must specify qcow path\n");
            }
            $opt_qc= $val;
            $i++
        } elsif ($arg eq "-cimg") {
            if (not defined($val)) {
                die ("$prog: $arg: Must specify cloud image path\n");
            }
            $opt_cimg= $val;
            $i++
        } elsif ($arg eq "-dimg") {
            if (not defined($val)) {
                die ("$prog: $arg: Must specify disk image path\n");
            }
            $opt_dimg= $val;
            $i++
        } elsif ($arg eq "-kernel") {
            if (not defined($val)) {
                die ("$prog: $arg: Must specify kernel path\n");
            }
            $opt_kernel= $val;
            $i++
        } elsif ($arg eq "-rd") {
            if (not defined($val)) {
                die ("$prog: $arg: Must specify ramdisk path\n");
            }
            $opt_rd= $val;
            $i++
        } elsif ($arg eq "-mroot") {
            if (not defined($val)) {
                die ("$prog: $arg: Must specify mounted root path\n");
            }
            $opt_mroot= $val;
            $i++
        } elsif ($arg eq "-dtb") {
            if (not defined($val)) {
                die ("$prog: $arg: Must specify device tree blob (dtb) path\n");
            }
            $opt_dtb= $val;
            $i++
        } elsif ($arg eq "-elf") {
            if (not defined($val)) {
                die ("$prog: $arg: Must specify elf file path\n");
            }
            $opt_elf= $val;
            $i++
        } elsif ($arg eq "-os_img") {
            if (not defined($val) and $is_release_version) {
                die ("$prog: $arg: Must specify an OS image path\n");
            }
            $opt_uimg= 1;
            $uimg_path= $val;
            $i++;
        } elsif ($arg eq "-gdb") {
            $opt_gdb= 1;
        } elsif ($arg eq "-bfm") {
            $opt_bfm= 1;
        } elsif ($arg eq "-valgrind") {
            $opt_valgrind= 1;
        } elsif ($arg eq "-dbg") {
            if (not defined($val) or $val =~ /^-/) {
                $opt_dbg_qemu= 1;
            } elsif ($val =~ /\d/) {
                $opt_dbg_qemu= $val;
                $i++;
            } else {
                die ("$prog: $arg: Debug verbosity should be an positive integer\n");
            }
        } elsif ($arg eq "-dbg_sc") {
            if (not defined($val) or $val =~ /^-/) {
                $opt_dbg_sc= 0xb;
            } elsif ($val =~ /\d/) {
                $opt_dbg_sc= $val;
                $i++;
            } else {
                die ("$prog: $arg: Debug verbosity should be an positive integer\n");
            }
        } elsif ($arg eq "-Nway") {
            if ($val =~ /\d/) {
                $opt_Nway= $val;
                $i++;
            } else {
                die ("$prog: $arg: Nway should be an positive integer\n");
            }
        } elsif ($arg eq "-cache_cap") {
            if ($val =~ /\d/) {
                $opt_cache_cap= $val;
                $i++;
            } else {
                die ("$prog: $arg: cache_cap should be an positive integer\n");
            }
        } elsif ($arg eq "-line_size") {
            if ($val =~ /\d/) {
                $opt_line_size= $val;
                $i++;
            } else {
                die ("$prog: $arg: line_size should be an positive integer\n");
            }
        } elsif ($arg eq "-n") {
            $opt_n= 1;
        } elsif ($arg eq "-kgdb") {
            $opt_kgdb= 1;
        } elsif ($arg eq "-Q") {
            if (not defined($val)) {
                die ("$prog: $arg: Invalid usage of \"-Q\" option\n");
            }
            $opt_Q= $val;
            $i++;
        } elsif ($arg eq "-vnc") {
            $opt_vnc= 1;
        } elsif ($arg eq "-regr") {
            $opt_regr= 1;
            #$opt_sv= 1;
            #$opt_q= 1;
        } elsif ($arg eq "-sv") {
            $opt_sv= 1;
        } elsif ($arg eq "-q") {
            $opt_q= 1;
        } elsif ($arg =~ m/-AVY_PORT=(.*)/) {
            $opt_port= $1;
            if (`netstat -talpn 2>&1|grep $1`) {
                print ("$prog: Port $1 is in use. Continue? <y/n>\n");
                chomp(my $input=<STDIN>);
                if ($input ne "y") {
                    exit 0;
                }
            }
        } elsif ($arg eq "-dbg_bios") {
            $opt_dbg_bios= 1;
        } elsif ($arg eq "-hotplug") {
            $opt_hotplug= 1;
        } elsif ($arg eq "-kvm") {
            $opt_kvm= 1;
        } elsif ($arg eq "-nokvm") {
            $opt_kvm= 0;
        } elsif ($arg eq "-perf") {
            if ($val =~ /\d/) {
                $opt_perf= $val;
                $i++;
            } else {
                die ("$prog: $arg: perf should be an positive integer which specifies the offset Avery's Performance measurement DVSEC registers are located\n");
            }
        } elsif ($arg eq "-kmsg") {
            $opt_kmsg= 1;
        } elsif ($arg eq "-qemu_gdb") {
            $opt_qemu_gdb= 1;
        } elsif ($arg eq "-io_warp") {
            $opt_io_warp= 1;
        } elsif ($arg eq "-dma_warp") {
            $opt_dma_warp= 1;
        } elsif ($arg eq "-bios") {
            if (not defined($val) or $val =~ /^-/) {
                die ("$prog: $arg: Must specify BIOS path\n");
            }
            $opt_bios= $val;
            $i++
        } elsif ($arg eq "-dual") {
            $opt_nDecoder= 2;
        } elsif ($arg eq "-sw") {
            $opt_sw= 1;
        } elsif ($arg eq "-cxl") {
            $opt_cxl= 1;
        } elsif ($arg eq "-cxl1.1") {
            $opt_cxl= 1;
            $opt_bfm= 1;
            $opt_cxl_1_1= 1;
        } elsif ($arg eq "-ats") {
            $opt_ats= 1;
        } elsif ($arg eq "-no_static") {
            $opt_static= 0;
        } elsif ($arg eq "-ovmf") {
            $opt_ovmf= 1;
            if (defined($val) and $val !~ /^-/) {
                if ($val =~ m/code=(.*),vars=(.*)/) {
                    $opt_ovmf_code= $1;
                    $opt_ovmf_vars= $2;
                } elsif ($val =~ m/vars=(.*),code=(.*)/) {
                    $opt_ovmf_code= $2;
                    $opt_ovmf_vars= $1;
                } else {
                    die ("$prog: $arg: Invalid usage of -ovmf\n");
                }
                if (not -e $opt_ovmf_code or not -e $opt_ovmf_vars) {
                    die ("$prog: OVMF path error\n");
                }
                $i++;
            }
        } elsif ($arg eq "-snapshot") {
            $opt_snapshot= 1;
        } elsif ($arg eq "-hdmN") {
            if (not defined($val)) {
                die ("$prog: $arg: Invalid usage\n");
            }
            $hdm_cnt= $val;
            $i++;
        } elsif ($arg eq "-cpu") {
            if (not defined($val)) {
                die ("$prog: $arg: Invalid usage\n");
            }
	    $cpu_type= $val;
            $i++
        } elsif ($arg eq "-nographic") {
            $opt_nographic= 1;
        } else {
            print ("$prog: $arg: Invalid option\n");
            &show_usage;
        }
    }

    if ($opt_pass) {
        (`id -un` eq "root\n") or die ("$prog: You must be root to use passthrough mode!\n");
    }
}

sub run_sc {
    my $exec_cmd= "";
    my $exec_opt= "";
    my $sc_prog= "";
    my $sc_log = "$log_dir/sc.log";

    &set_sc_env;

    chdir $cur_dir;

    $sc_prog= "$SC_PROJ_DIR/$SC_PROG_NAME";

    $exec_opt.= " unix:$tmp_qemu_dir";
    if ($opt_arch eq X86){
        $exec_opt.= "/qemu-rport-_machine_peripheral_avy";
    } elsif ($opt_os eq FREERTOS){
        $exec_opt.= "/qemu-rport-_cosim\@0";
    } else {
        $exec_opt.= "/qemu-rport-_machine_cosim";
    }
    $exec_opt.= " $opt_qt";
    $exec_opt.= " $opt_dbg_sc";
    $exec_opt.= " -port $opt_port";
    $exec_opt.= " -ip $opt_ip";
    if ($opt_Nway ne 0 || $opt_cache_cap ne 0 || $opt_line_size ne 0) {
        $exec_opt.= " -Nway $opt_Nway";
        $exec_opt.= " -cache_cap $opt_cache_cap";
        $exec_opt.= " -line_size $opt_line_size";
    }
    if ($opt_perf) {
        $exec_opt.= " -perf $opt_perf";
    }

    if ($opt_gdb) {
        print ("$prog: Starting $SC_PROG_NAME with GDB...\n");
        $exec_cmd.= "gdb $sc_prog -ex \'run $exec_opt\'";
    } elsif ($opt_valgrind) {
        print ("$prog: Starting $SC_PROG_NAME with Valgrind...\n");
        $exec_cmd.= "valgrind";
        $exec_cmd.= " --leak-check=full";
        $exec_cmd.= " --show-leak-kinds=all";
        $exec_cmd.= " --track-origins=yes";
        $exec_cmd.= " --log-file='$cur_dir/$log_dir/vg.log'";
        $exec_cmd.= " $sc_prog $exec_opt";
    } else {
        print ("$prog: Starting $SC_PROG_NAME ...\n");
        $exec_cmd.= "$sc_prog $exec_opt";
    }

    if (!$opt_q) {
        $exec_cmd.= " | tee $cur_dir/$sc_log";
    }

    print ("$exec_cmd\n");
    if (!$opt_n) {
        exec ($exec_cmd);
    }
}

sub get_ram_size {
    my $ram_size= 0;
    my $i= 0;

    $ram_size= `free -g|grep Mem|awk '{print \$2}' 2>&1`;
    chomp($ram_size);
    if (!$ram_size or $ram_size =~ /\D/ or $ram_size eq 0) {
        return 0;
    } else {
        while ($ram_size > 1) {
            $ram_size >>= 1;
            $i++;
        }
        return 1 << $i;
    }
}

sub run_qemu {
    my $exec_cmd= "";;
    my $proj_dir;
    my $kernel_dbg_port= &check_port("KERNEL_GDB", 9000);
    my $fw_dbg_port= &check_port("GDB_SERVER", 1234);
    my $rp_pci_dev;
    my $hdm_args;
    #my $ram_size= &get_ram_size;
    my $ram_size= 4;

    chdir $cur_dir;
    print ("$prog: Starting QEMU...\n");

    $exec_cmd.= $QEMU_MACH;

    if ($opt_qemu_gdb) {
        $exec_cmd.= " -gdb tcp::$kernel_dbg_port";
    }

    #$exec_cmd.= " -net nic ";
    #$exec_cmd.= " -net tap,script=/etc/qemu-ifup,downscript=/etc/qemu-ifdown";
    if ($opt_os ne FREERTOS) {
        $exec_cmd.= " -nic user"
                    .",hostfwd=tcp::$ssh_port-:22"
                    .",hostfwd=tcp::$fw_dbg_port-:$fw_dbg_port";
    }
    if ($opt_arch eq ARM) {
        # run on ARM
        $exec_cmd.= " -M arm-generic-fdt-7series";
        $exec_cmd.= " -machine linux=on";
        $exec_cmd.= " -serial /dev/null";
        $exec_cmd.= " -serial mon:stdio";
        $exec_cmd.= " -display none";
        $exec_cmd.= " -kernel $PETA_PROJ_PATH/build/qemu_image.elf";
        $exec_cmd.= " -dtb $PETA_PROJ_PATH/images/linux/system.dtb";
        $exec_cmd.= " -device loader,addr=0xf8000008,data=0xDF0D,data-len=4";
        $exec_cmd.= " -device loader,addr=0xf8000140,data=0x00500801,data-len=4";
        $exec_cmd.= " -device loader,addr=0xf800012c,data=0x1ed044d,data-len=4";
        $exec_cmd.= " -device loader,addr=0xf8000108,data=0x0001e008,data-len=4";
        $exec_cmd.= " -device loader,addr=0xF8000910,data=0xF,data-len=0x4";
        $exec_cmd.= " -icount 1";
    } elsif ($opt_arch eq AARCH64) {
        if($opt_os eq FREERTOS){
            $exec_cmd.= " -M arm-generic-fdt-7series";
            $exec_cmd.= " -append \"console=ttyS0\"";
            $exec_cmd.= " -serial stdio";#mon:stdio";   #This serial port will connect to uart0
            $exec_cmd.= " -serial pty";                 #This serial port will connect to uart1
            $exec_cmd.= " -display none";
            $exec_cmd.= " -kernel $opt_elf";
            $exec_cmd.= " -dtb $opt_dtb";
            $exec_cmd.= " -net nic,netdev=eth0";
            $exec_cmd.= " -netdev user,id=eth0";
        } else {
            $exec_cmd.= " -m 2G -M virt -cpu cortex-a53";
            $exec_cmd.= " -bios $opt_bios";
            $exec_cmd.= " -drive if=none,file=$opt_qc,id=hd0";
            $exec_cmd.= " -device virtio-blk-device,drive=hd0";
        }
    } elsif ($opt_arch eq MICROB) {
        $exec_cmd.= " -m 256 -M microblaze-fdt-plnx";
        $exec_cmd.= " -dtb $opt_dtb";
        $exec_cmd.= " -kernel $opt_elf";
    } else {
        # run on x86_64

        #### Serial port redirection ####
        if ($opt_kgdb) {
            my $kgdb_port= &check_port("KGDB", 4321);
            $exec_cmd.= " -serial tcp::$kgdb_port,server,nowait";
        }
        #$exec_cmd.= " -serial stdio";

        #$exec_cmd.= " -machine type=pc-q35-4.0,hmat=on";
        $exec_cmd.= " -machine type=pc-q35-4.0";
        
        if ($opt_cxl) {
            $exec_cmd.= ",nvdimm=on,cxl=on";
        }
        
        if ($opt_kvm) {
            $exec_cmd.= ",accel=kvm";
            #### Enable KVM ####
            $exec_cmd.= " -enable-kvm";
        }

        $exec_cmd.= " -cpu ".$cpu_type;

        #### Symmetric Multi-Processing ####
        $exec_cmd.= " -smp 8,sockets=2,cores=2,threads=2";

        #### Startup RAM size ####
        if ($ram_size > 0) {
            $exec_cmd.= " -m ".$ram_size."G";
            #    if ($opt_cxl) {
            #        $exec_cmd.= ",slots=4,maxmem=40964M";
            #    }
        }

        #### Boot from CD-ROM first ####
        $exec_cmd.= " -boot order=d";

        #### Disable Advanced Configuration and Power Interface ####
        ## Don't use this if we want to use PCIe hotplug
        #$exec_cmd.= " -no-acpi";

        #### Workaround for keyboard Error ####
        $exec_cmd.= " -k 'en-us'";

        $exec_cmd.= " -vga virtio";
        if ($opt_cimg){
            # Ref. https://github.com/Xilinx/systemctlm-cosim-demo/blob/master/pcie-ats-demo/pcie-ats-demo.md
            # cloud images can be found in https://cloud-images.ubuntu.com/releases/
            # choose one set on the site, here we take ubuntu-20.20 as an example
            if($opt_qc) {
                print("You are using cloud image, -qc option is invalid now\n");
            }
            $exec_cmd .= " -drive file=$opt_cimg,format=qcow2";
            if($opt_dimg && $opt_kernel && $opt_rd) {
                $exec_cmd .= " -drive file=$opt_dimg,format=raw";
                $exec_cmd .= " -kernel $opt_kernel";
                $exec_cmd .= " -initrd $opt_rd";
                $exec_cmd .= " -append \"root=/dev/sda1 ro console=tty1 console=ttyS0 intel_iommu=on\"";
            } else {
                die ("$prog: Please check if you have specified kernel, ramdisk and disk image!");
            }
        } else {
            if($opt_kernel || $opt_rd) {
                if($opt_kernel && $opt_rd) {
                    $exec_cmd .= " -kernel $opt_kernel";
                    $exec_cmd .= " -initrd $opt_rd";
                    if ($opt_mroot) {
                        $exec_cmd .= " -append \"root=$opt_mroot\"";
                    } else {
                        $exec_cmd .= " -append \"root=/dev/mapper/ubuntu--vg-ubuntu--lv\"";
                    }
                } else {
                    die ("$prog: Please check if you have specified kernel, ramdisk and mount directory!");
                }
            }
            if ($opt_snapshot) {
                $exec_cmd.= " -snapshot";
            }
            $exec_cmd.= " -drive file=$opt_qc,format=qcow2";
        }

        if ($is_release_version) {
            $exec_cmd.= " -L $AVERY_QEMU/tools/pc-bios";
        }

        if ($opt_dbg_bios) {
            $exec_cmd.= " -chardev pipe,path=$bios_dbg_pipe,id=seabios";
            $exec_cmd.= " -device isa-debugcon,iobase=0x402,chardev=seabios";
        }

        if ($is_release_version) {
            $proj_dir = $AVERY_QEMU;
        } else {
            $proj_dir = $AVERY_AVP;
        }

        if ($opt_ovmf) {
            if ($opt_ovmf_vars eq "") {
                # use local OVMF_VARS.fd
                if (! -e "$cur_dir/OVMF_VARS.fd") {
                    $opt_ovmf_vars = "$proj_dir";
                    if ($is_release_version) {
                        $opt_ovmf_vars .= "/tools";
                    }
                    $opt_ovmf_vars .= "/3rd_party/edk2-ovmf/x64/OVMF_VARS.fd";
                    system("cp $opt_ovmf_vars $cur_dir");
                }
                $opt_ovmf_vars = "$cur_dir/OVMF_VARS.fd"
            }
            if ($opt_ovmf_code eq "") {
                $opt_ovmf_code = "$proj_dir";
                if ($is_release_version) {
                    $opt_ovmf_code .= "/tools";
                }
                $opt_ovmf_code .= "/3rd_party/edk2-ovmf/x64/OVMF_CODE.fd";
            }
            $exec_cmd.= " -drive if=pflash,format=raw,readonly=on,file=$opt_ovmf_code";
            $exec_cmd.= " -drive if=pflash,format=raw,file=$opt_ovmf_vars";
            #$exec_cmd.= " -debugcon file:debug.log -global isa-debugcon.iobase=0x402";
            #$exec_cmd.= " -serial file:serial.log";
        } elsif (-e $opt_bios) {
            $exec_cmd.= " -bios $opt_bios";
        }

        if ($opt_kmsg) {
            $exec_cmd.= " -serial pty";
            print ("$prog: Redirect Kernel Message Usage:\n");
            print ("$prog:\t1. In QEMU GRUB, add \"console=ttyS0\" at the end of \"linux ...\"\n");
            print ("$prog:\t2. In host, \$ cat /dev/pts/<pts#>\n");
        }

        if ($opt_uimg) {
            #### OS installation ####
            $exec_cmd.= " -cdrom $uimg_path";
        } elsif ($opt_pass) {
            #$exec_cmd.= " -device ioh3420,id=root_port";
            #$exec_cmd.= " -device vfio-pci,host=01:00.0,bus=root_port";
            $exec_cmd.= " -device vfio-pci,host=01:00.0";
            #$exec_cmd.= " -device vfio-pci,host=01:00.4";
        } elsif ($opt_cxl) {
            if ($opt_bfm) {
                my $bdf;
                my $bus;

                if ($opt_cxl_1_1) {
                    $bdf= 0x0000;
                } else {
                    $bdf= 0x0100;
                }
                $bus= "rp";
                $exec_cmd.= " -device remote-port,id=avy";
                $exec_cmd.= " -machine-path $tmp_qemu_dir";

                for (my $i= 0; $i < $opt_nDecoder; $i++) {
                    $exec_cmd.= " -device pxb-cxl,id=cxl.$i,bus=pcie.0,bus_nr=".($i*8+52);
                    $rp_pci_dev.= " -device cxl-rp,id=$bus".($i*$opt_nDecoder).",bus=cxl.$i,chassis=0,slot=$i,port=".($i*2);
                    $rp_pci_dev.= " -device cxl-rp,id=$bus".($i*$opt_nDecoder+1).",bus=cxl.$i,chassis=1,slot=$i,port=".($i*2+1);
                    if ($i ne 0) {
                        $hdm_args .=","
                    }
                    $hdm_args.= "cxl-fmw.$i.targets.0=cxl.$i,cxl-fmw.$i.size=512M";


                    for (my $j= 0; $j < $opt_nEP; $j++) {
	                    $rp_pci_dev.= " -device cxl-type3,bus=$bus".($i*$opt_nDecoder+$j).",id=cxl-pmem".($i+$j).",bdf=".(($i+$j+1)*(0x100)).",size=512M,rp-adaptor0=avy,rp-chan0=".(($i+$j)*20).",debug=$opt_dbg_qemu";
	                    if ($opt_io_warp) {
	                        $rp_pci_dev.= ",io-warp=true";
	                    }
	                    if ($opt_ats) {
	                        $rp_pci_dev.= ",ats=true";
	                    }
	                    if ($opt_kvm) {
	                        $rp_pci_dev.= ",kvm-en=true";
	                    }
                        if ($opt_perf ne 0) {
	                        $rp_pci_dev.= ",avery-perf=$opt_perf";
                        }
                    }
                }
                $exec_cmd.= " $rp_pci_dev";
                $exec_cmd.= " -M $hdm_args";

                if ($opt_ats) {
                    $exec_cmd.= " -device intel-iommu,intremap=on,device-iotlb=on";
                }
            }
            if ($opt_nographic) {
                # Run the following option with GRUB "console=ttyS0 console=ttyS1"
                $exec_cmd.= " -nographic";
            }
            #$exec_cmd.= " -object memory-backend-ram,id=mem0,size=2048M";
            #$exec_cmd.= " -numa node,nodeid=0,memdev=mem0,";
            #$exec_cmd.= " -numa cpu,node-id=0,socket-id=0";

            #$exec_cmd.= " -object memory-backend-ram,id=mem1,size=2048M";
            #$exec_cmd.= " -numa node,nodeid=1,memdev=mem1,";
            #$exec_cmd.= " -numa cpu,node-id=1,socket-id=1";

            #$exec_cmd.= " -object memory-backend-ram,id=mem2,size=2048M";
            #$exec_cmd.= " -numa node,nodeid=2,memdev=mem2,";

            #$exec_cmd.= " -object memory-backend-ram,id=mem3,size=2048M";
            #$exec_cmd.= " -numa node,nodeid=3,memdev=mem3,";

            #$exec_cmd.= " -numa node,nodeid=4,";
            #$exec_cmd.= " -object memory-backend-file,id=nvmem0,share,mem-path=nvdimm-0,size=16384M,align=1G";
            #$exec_cmd.= " -device nvdimm,memdev=nvmem0,id=nv0,label-size=2M,node=4";

            #$exec_cmd.= " -numa node,nodeid=5,";
            #$exec_cmd.= " -object memory-backend-file,id=nvmem1,share,mem-path=nvdimm-1,size=16384M,align=1G";
            #$exec_cmd.= " -device nvdimm,memdev=nvmem1,id=nv1,label-size=2M,node=5";

            #$exec_cmd.= " -numa dist,src=0,dst=0,val=10";
            #$exec_cmd.= " -numa dist,src=0,dst=1,val=21";
            #$exec_cmd.= " -numa dist,src=0,dst=2,val=12";
            #$exec_cmd.= " -numa dist,src=0,dst=3,val=21";
            #$exec_cmd.= " -numa dist,src=0,dst=4,val=17";
            #$exec_cmd.= " -numa dist,src=0,dst=5,val=28";
            #$exec_cmd.= " -numa dist,src=1,dst=1,val=10";
            #$exec_cmd.= " -numa dist,src=1,dst=2,val=21";
            #$exec_cmd.= " -numa dist,src=1,dst=3,val=12";
            #$exec_cmd.= " -numa dist,src=1,dst=4,val=28";
            #$exec_cmd.= " -numa dist,src=1,dst=5,val=17";
            #$exec_cmd.= " -numa dist,src=2,dst=2,val=10";
            #$exec_cmd.= " -numa dist,src=2,dst=3,val=21";
            #$exec_cmd.= " -numa dist,src=2,dst=4,val=28";
            #$exec_cmd.= " -numa dist,src=2,dst=5,val=28";
            #$exec_cmd.= " -numa dist,src=3,dst=3,val=10";
            #$exec_cmd.= " -numa dist,src=3,dst=4,val=28";
            #$exec_cmd.= " -numa dist,src=3,dst=5,val=28";
            #$exec_cmd.= " -numa dist,src=4,dst=4,val=10";
            #$exec_cmd.= " -numa dist,src=4,dst=5,val=28";
            #$exec_cmd.= " -numa dist,src=5,dst=5,val=10";
        } elsif ($opt_pci eq 0 or $opt_bfm eq 0) {
            my $mon_port= &check_port("MONITOR", 4000);
            $exec_cmd.= " -monitor tcp::$mon_port,server,nowait";
            print ("$prog: Hotplug Usage:\n");
            print ("$prog:\t1. In host, \$ socat - TCP:127.0.0.1:$mon_port\n");
            print ("$prog:\t2. In QEMU monitor, (qemu) device_add remote-port-pci-device ...\n");
            print ("$prog:\t3. In QEMU, \$ echo 1 > /sys/bus/pci/rescan\n");
        }

        if ($opt_pci and $opt_bfm) {
            if (!$opt_hotplug) {
                if (!$opt_cxl) {
                    $exec_cmd.= " -device remote-port,id=avy";
                }
                if ($opt_sw) {
                    $exec_cmd.= " -device ioh3420,id=root_port0,chassis=0";
                    $exec_cmd.= " -device rp-upstream,id=upstream_port1,bus=root_port0";
                    #$exec_cmd.= " -device x3130-upstream,id=upstream_port1,bus=root_port0";
                    #$exec_cmd.= " -device x3130-downstream,id=downstream_port1,bus=upstream_port1,chassis=2,slot=0";
                    #$exec_cmd.= " -device x3130-downstream,id=downstream_port2,bus=upstream_port1,chassis=2,slot=1";
                    $exec_cmd.= " -device rp-downstream,id=downstream_port1,bus=upstream_port1,chassis=2,slot=0";
                    $exec_cmd.= " -device rp-downstream,id=downstream_port2,bus=upstream_port1,chassis=2,slot=1";
                    $exec_cmd.= " -device remote-port-pci-device,rp-adaptor0=avy,rp-chan0=0,bdf=0x300,bus=downstream_port1,debug=0x3,id=avy_dev0,auto-bar=false,bar0-size=0x10000c,bar1-size=0x0,bar2-size=0x10000c,bar3-size=0x0,bar4-size=0x10000c,bar5-size=0x0";
                    $exec_cmd.= " -device remote-port-pci-device,rp-adaptor0=avy,rp-chan0=0,bdf=0x400,bus=downstream_port2,debug=0x3,id=avy_dev1,auto-bar=false,bar0-size=0x10000c,bar1-size=0x0,bar2-size=0x10000c,bar3-size=0x0,bar4-size=0x10000c,bar5-size=0x0";
                } else {
                    for (my $i= 0; $i < $opt_nDecoder; $i++) {
                        # shift bdf by 1 if running opt_pci with opt_cxl
                        $rp_pci_dev= "remote-port-pci-device,rp-adaptor0=avy,rp-chan0=".($i*20).",bdf=".(($i+1)*(0x100+$opt_cxl)).",bus=root_port$i,debug=$opt_dbg_qemu,id=avy_dev$i";
                        if ($opt_io_warp) {
                            $rp_pci_dev.= ",io-warp=true";
                        }
                        if ($opt_dma_warp) {
                            $rp_pci_dev.= ",dma-warp=true";
                        }
                        if ($opt_ats) {
                            $rp_pci_dev.= ",ats=true";
                            $exec_cmd.= " -device intel-iommu,intremap=on,device-iotlb=on";
                        }
                        $exec_cmd.= " -device ioh3420,id=root_port$i,chassis=".($i+$opt_cxl);
                        $exec_cmd.= " -device $rp_pci_dev";
                    }
                }
            }
        }
    }


    if ($opt_bfm and !$opt_uimg and !$opt_pass) {
        $exec_cmd.= " -machine-path $tmp_qemu_dir";
        $exec_cmd.= " -sync-quantum $opt_qt";
    }

    $exec_cmd.= " $opt_Q";

    if ($opt_q or $opt_regr) {
        $exec_cmd.= " > $cur_dir/$qemu_log 2>&1";
    } else {
        $exec_cmd.= " 2>&1 | tee -a $cur_dir/$qemu_log";
    }

    open (my $fh, '>', $qemu_log) or die ("$prog: Could not open file '$qemu_log' ($!)\n");
    print $fh "$exec_cmd\n\n";
    close $fh;

    print ("$exec_cmd\n");

    if($opt_n) {
        exit 0;
    }

    exec ($exec_cmd);
}

sub save_dir {
    $cur_dir= getcwd();
}

sub check_port {
    my ($port_name, $port)= @_;
    my $check_cmd= "netstat -talpn 2>&1|grep";
    my $port_unused= `$check_cmd $port`;

    while($port_unused) {
        $port++;
        $port_unused= `$check_cmd $port`;
    }
    print ("$prog: $port_name port is set to $port\n");
    return $port;
}

sub get_prog_name {
    use File::Basename;
    chomp($prog= basename($0));
}

sub check_prog {
    my $result;

    $result= `pgrep -u \$\(whoami\) -d " " $prog`;
    chomp($result);
    $result=~ s/$$//g;
    $result=~ s/^\s+|\s$//g;

    if ($result) {
        print ("$prog: Found other $prog running (PID: $result). Continue? <y/n>\n");
        chomp(my $input=<STDIN>);
        if ($input ne "y") {
            exit 0;
        }
    }
}

sub run_regression {
    my $scr_path;
    if ($is_release_version) {
        $scr_path= $AVERY_QEMU;
    } else {
        $scr_path= $AVERY_AVP."/QEMU/";
    }
    exec ("$scr_path/scripts/run_tnvme_regr.pl $cur_dir $ssh_port $pswd_host");
}

sub run_sv {
    my $exec_cmd;

    chdir $cur_dir;
    $exec_cmd.= "$AVERY_AVP/scripts/run_qemusv.pl -s xm64 -t apcit_qemu_basic.sv -qemu -p nvme -C +define+AVY_PORT=$opt_port";
    if ($opt_nDecoder eq 2) {
        $exec_cmd.= "+APCI_MPORT";
    }
    if ($opt_q) {
        $exec_cmd.= " > /dev/null";
    }

    exec ($exec_cmd);
}

sub run_vnc {
    my $vnc_result='';

    chdir $cur_dir;
    sleep(5);
    # Try to connect to the vnc port provided by QEMU
    for (my $i= 0;$i < 100;$i++) {
        $vnc_result= `grep "VNC server running on" $qemu_log`;
        if ($vnc_result) {
            $vnc_result =~ s/.*:(\d+)$/$1/g;
            system ("vncviewer :$vnc_result > /dev/null");
            return;
        }
        sleep(3);
    }
    print ("$prog: VNC timeout. Check the QEMU-SC-SV connection.\n");
}

sub fork_proc {
    my ($pname, $cond, $func, @args)= @_;

    if ($cond and ($$ eq $pid_prog)) {
        $PID{$pname}= fork();
        if (!$PID{$pname}) {
            # child proc
            #setpgrp(0, 0);
            &$func(@args);
        }
    }
}

sub proc_ctrl {
    # Use setpgrp and negative pid to kill child process of each pid
    # Ref: https://stackoverflow.com/questions/27145798/
    my $rid;

    &fork_proc("sc", ($opt_bfm), \&run_sc,);
    &fork_proc("sv", ($opt_sv), \&run_sv,);
    &fork_proc("vnc", ($opt_vnc), \&run_vnc,);
    &fork_proc("regr", ($opt_regr), \&run_regression,);
    &fork_proc("qemu", 1, \&run_qemu,);

    # wait for all child process
    $rid = waitpid (-1, 0);
    &kill_all_proc($rid);
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

sub check_tmp_qemu_dir {
    $tmp_qemu_dir= "/tmp/avy_qemu_$uname\_$opt_port";
    if (! -e $tmp_qemu_dir) {
        system("mkdir $tmp_qemu_dir");
    }
}

sub main {
    # Override SIGINT(Ctrl-C)
    my $run_log;

    $SIG{'INT'} = \&kill_all_proc;
    &check_prog;

    $run_log= "$log_dir/$prog";
    $run_log=~ s/\.pl/\.log/;
    open (STDERR, ">&STDOUT");
    open (STDOUT, "|-", "tee", "$cur_dir/$run_log");

    &set_env;
    if(!$is_release_version) {
        &set_dpi_env;
        while (! -e "$DPI_DIR/$DPI_PROG_NAME"){};
    }

    &set_qemu_env;

    if ($opt_regr) {
        use Term::ReadKey;

        print ("$prog: host's password(for scp): ");
        # set to let input be invisible
        ReadMode('noecho');
        # read password
        $pswd_host = ReadLine(0);
        # reset, or it will affect the normal command prompt
        ReadMode(0);
    }
    &proc_ctrl;

    close(STDOUT);
}

&save_dir;
&get_prog_name;
&parse_arg(\@ARGV);
&check_tmp_qemu_dir;
&main;
