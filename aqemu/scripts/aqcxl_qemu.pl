#!/usr/bin/perl

use strict;
use warnings;
use Cwd;

my %ENVH;
my $exec= "run_qemu.pl ";
my $opt_dbg= 0;
my $opt_ovmf= 0;
my $opt_ovmf_code= "";
my $opt_ovmf_vars= "";
my $prog;

sub show_usage {
    use File::Basename;
    chomp($prog= basename($0));

    my $usage= "
$prog [options]
       -qc <path>              Specify the qcow path, default path being \"\$AVERY_QEMU\"
       -os_img <path>          Path to OS installation image
       -dbg <level>            Turn on debug verbosity for QEMU, default debug verbosity 0x3
       -Q <QEMU option>        Add additional QEMU option
       -AVY_PORT=<port>        Assign port for SimCluster
       -ovmf                   Enable UEFI from given location, default
                                code=\$AVERY_QEMU\/tools\/3rd_party\/edk2-ovmf\/x64\/OVMF_CODE  .fd,
                                vars=\$AVERY_QEMU\/tool\/3rd_party\/edk2-ovmf\/x64\/OVMF_VARS.  fd

  Ex:
      \$ $prog -dbg -AVY_PORT=10000 -ovmf
";

    print("$usage\n") ;
    exit(0);
}

sub parse_arg {
    my ($argv_ref)= @_;
    my $argc= scalar(@{$argv_ref});
    my $timestamp = localtime(time);

    for (my $i= 0; $i < $argc; $i++) {
        my $arg= ${$argv_ref}[$i];
        my $val= ${$argv_ref}[$i+1];

        if ($arg eq "-h") {
            &show_usage;
        } elsif ($arg eq "-dbg") {
            if (not defined($val) or $val =~ /^-/) {
                $opt_dbg= 1;
                $exec .= " -dbg 0x3";
            } elsif ($val =~ /\d/) {
                $opt_dbg= 1;
                $exec .= " -dbg $val";
                $i++;
            } else {
                die ("$prog: $arg: Debug verbosity should be an positive integer\n");
            }
        } elsif ($arg eq "-ovmf") {
            $opt_ovmf= 1;
            $exec .= " -ovmf";
            if (defined($val) and $val !~ /^-/) {
                if ($val =~ m/code=(.*),vars=(.*)/) {
                    $exec .= " $val";
                } elsif ($val =~ m/vars=(.*),code=(.*)/) {
                    $exec .= " $val";
                } else {
                    die ("$prog: $arg: Invalid usage of -ovmf\n");
                }
                $i++;
            }
        } else {
            $exec .= " $arg";
        }
    }
}

sub run_qemu {
    if ($opt_dbg eq 0) {
        $exec .= " -dbg 0x3";
    }
    if ($opt_ovmf eq 0) {
        $exec .= " -ovmf";
    }
    #default cxl
    $exec .= " -dut bfm=cxl2.0";
    system($exec);
}

&parse_arg(\@ARGV);
&run_qemu();
