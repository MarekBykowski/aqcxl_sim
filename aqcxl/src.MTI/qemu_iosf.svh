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

`protected

    MTI!#$\u_/)52rVvV^kI7$HD1k2[O};?$ZsG9xm=]=@7HlYie?$A7=p;Be-EYd#[x=q<I#]/-l]B
    7J~p#'+ssGl,Ni5mk-^r}Fcf5*k[uo]<,L<^VK]en;m}rC@7\*+RwB>-Cr,xv+2Ep,[ljkO*x@Y5
    zr}hK[!Il-l;kOk<l7m[sp!As1RA^z^}@}]Y=x-QPAwlekDi}H9Ip_oGX}G*//<-=["}8F'BZa7K
    QABbjJ=<wrp,H]nsC{-7}W>CKwlCOj?_hxBx*g#D<Y\;{+G7,,=TOZW8i$T1vmq#1,eTrnet@Q1r
    2pJ#@pV!O~_[gWtuaX1I+{C3957Q~PIxJp^n,WL!Aw$2RB[r#$u|YCrBYr?@Ts^C$DkAV_T}&KvD
    1;wzm}i!Ef'3_,1H{Kjo}szj^p^\'!#oN96ToEH2O3JEpBH&lQZQ,YkBHRG}c-a]1=i]O^#;Xv=]
    ^9,v-s>xBmrIku37KO8x=xiPkAA2X$U!CU!-eiV$}X,p@^7afUvDBqlSUYZAvw;3/,z1}8WY5*-[
    K+U$D5RLCUll'=BHKa52n'o,rue^<*QGT=kVIoC[Ka\$$Ywe7"L3CBioKKv2\*pYwu1,!7KaT,X#
    ]W+zf*T,H[3VJu'-a@]XDg[pirCK*r}2no[us@<xn#E5@[ruvT.7uz[2X2e"@5=XBEx>E5XrECv3
    {VIvTjRD_=E$p{I1G<{2,oQQ]m8@r?n8$$jn#Qm[\$BvRI+jB3{?zxm>>aw!oJXYHB3]1[l;R3rY
    Q23VNH^K\O\n{C?R2xD!r@vB2YBA~uE?=JHWu\W@VFaA+#bY*a=7HpVkR<Eh*Br@+H'Z=nvUIR*@
    WU+aK=[isn557&]_,pT{!Y$=<~BuJ;r_K]2HY3Q~TZ>'Y5.II>C[U3{3Xuv![1$$YTD+C_HGk>KE
    K*nswBCzlu7l3,QBp*k09"oW5]+p}R!Ei[C>-IC7-vUoWp}Bl?][-3HnTwGm-Wwh5{*i("/[[ZAG
    +2Q1,JuI5\!CDnrR}3^7lewCKx]^{aV3U5xrEZu5eHJ'@[k;v;TUCKn{I7!UlTOYY?R5!Yw3X]}^
    #Grz[*B15.VB;WA-}J^#C*G7xWxCkAR'RTsT-#\VOZIAaVOH+RqB)Jjz2xAYpT}@UuDaG'I}@5$?
    #Q\ZX/:<]!}DJ\7>+u5j$wGQX5o^?r7pJ'7]*vru']mw<w>sQUYionQGZT7{rBp(Qx+Q*_}H_uxn
    }u2~nUAaf!sJT\,~^-,e~s:m,O'\$X^lE}C>r;W}Xr]j!vEe7\rW8W<e\[7[;'B@{--ExjZ'TyeX
    o#DR1mpT-UGupkkB]C!e;XA\[-K6Q#K_])s3^R1aYz&@Dm]:g<+p>ysWJ@\]={=K[Oa*7}F_Cr$Y
    !ZmYTUDBwBBSy2-{VO#Y;tVZ-x]Ko?[]+pOXxe\B1*io?,13~YIK[2y7{IIp-[+7x=-}p}\cuwVI
    =^Rw]mAvZ_uI'hf;GjjqLo17i(7o$IC@Us{<@Iv3uoUI1aw<J$<5G$9nH[\l=?ojwE>H]wu[OeKl
    de2ljQaw{^_z7oDOGQTI{>e]^-7w@lYAvi=[jTC_I,R+}oRQ@21,KqX<oJxZ~?Yj^u7UZJ$[Bx-(
    >x,afsr\3R_$io?Rw}Jl7|5mG^,!QUTD3A'E=}[UQXD*e;WA<z:^2>eo\ZIkX1o*v[z.^CjDNaR,
    Xp$mZ3ll}:[#*@[YI#IwI^~5~#?Y2KHY']e^*pFoivu*#{}-ll#pJJA/P]rAjns-aBDppkADlzW~
    GsyYr}xwR=ERO}~D-j;|^vD3Ba7YgEO3oQwVW?TJ+3ro2CE_z7XYn*n+<VM?zY>X^wnz~a},!r'z
    3o7u1On/uImvjW1V?U~^H>Ue\D}'mX;T,xCja^D*<RejO}5+;w~3.4zV^HQCs#K*~m@jEwy7vB}J
    OY*uo>T,Rk382}_Q!-Ali[RoOeT?prmOS#^<a1B<Az,u>?l'?(NYJYHz@WQo-VQ}RK-X=!opCZ'>
    +VsYa-xL"_\V3O~mTDo;zY|~]UEcRTD{Fp'7{-E}<?{3GDBi$C<5[GpE^e@Z~il1Wva=u}<D<d;C
    iF<pDZv#H2>[uGv3'$BA;@8Z1Z3HzxT:T[$?Jn<O$T=lfB<Ur~O]{ei2e7?D>4WoYYSACB@>O8'5
    J{HR#kW+$^|e7\aVsl5_n{^RKa_r]?}$aBY'=s2j7}[pKruW+3rGDpOB$v$+CeRaRz$lwOKzDnIu
    [_Z4lWTeL7vvC}*?Vc}E7;bj;I1}\$$lZQ\-5*>GR3HAr^7VU$zT\I$Tqc,GD#jw}n'YX+lKZ['=
    }o5=pT|z3X@{^w+u[
`endprotected

`endif

