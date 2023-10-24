package qemu_rx_pkg;
import avery_pkg::*;
import apci_pkg::*;
import apci_pkg_test::*;
import qemu_simc_pkg::*;

`include "qemu_enum.svh"
`ifdef INTEL_IOSF
`include "qemu_iosf.svh"
`endif
`ifdef AVERY_SPDM
`include "spdm_dpi.svh"
`endif

bit RST_TYPE = 0; // 1 for Hot 0 for Warm/Cold reset
bit PM_SUP = 0; // 1 for Power Management support
typedef bit[31:0] payload_t[$];
typedef apci_tlp acpi_tlp_q_t[$];
typedef payload_t addr_payload_hash_t[bit [63:0]];
typedef acpi_tlp_q_t addr_dropped_cpld_hash_t[bit [63:0]];
// size in bytes of the simcluster buffer
bit [31:0] qemu_debug_g= 3;
bit [31:0] vip_type_g= 0;
bit edb_logerror_jump_g= 0;
apci_tlp dropped_cpld_q[$];
addr_dropped_cpld_hash_t mrd_dropped_cpld_tlp;
addr_payload_hash_t mrd_dropped_cpld_payload;
bit[63 :0]  _all_one_64 = '1;
bit[63 :0]  _all_zero_64 = '0;
apci_atc_mgr atc_mgr;
bit[63:0] ats_xaddr;
bit[127:0] base_limit_Q[$];
bit[3:0] evict_mode = 4'b0011;
bit[63:0] max_clines = 8;
bit[11:0] pm_cap;
bit[11:0] exp_cap;
// Do not refactor PERST_N this is for sideband
bit PERST_N = 1; // active low
apci_device ep0;
apci_device all_bfms[$];
// use integer instead of int to avoid vpi issue
static integer aqemu_int1, aqemu_int3;

string sc_key= append_key_after_user(`simcluster_QEMU_key);
string edb_key= append_key_after_user(`simcluster_EDB_key);
`define SUBCMD_SHIFT (8)
`define CMD_MASK (8'hf)

`ifndef APCI_MPORT
`define PORT_NUM 1
`else
`define PORT_NUM 2
`endif

task automatic set_hdm_range(ref apci_device bfm);
    apci_bdf_t        hdm_bdf[`PORT_NUM];
    apci_addr_range_t hdm_ranges[`PORT_NUM][$];
    bit[63:0] ig = (1 << (8 + 6)); // 6 : 16 KB
    bit[63:0] iw = `PORT_NUM;
    bit[63:0] hdm_base = 64'h1_9000_0000;
    bit[63:0] hdm_len = 64'h0_4000_0000;

`ifdef AVERY_CXL_1_1
    hdm_bdf[0]  = 'h000;
`else
    for (int i = 0; i < `PORT_NUM; i++)
        hdm_bdf[i]  = (i + 1) * 'h100;
`endif

    /* Create RC HDM bkdoor mapping for single, 
     1 decoder 2 ep +APCI_MPORT
     2 decoder 2 ep +APCI_MPORT +SEPARATE_EP */
    if (`PORT_NUM == 1) begin
        apci_addr_range_t range;
        range.base = 64'h1_9000_0000;
        range.len =  64'h2000_0000;
        hdm_ranges[0].push_back(range);
    	bfm.cxl_bkdoor_add_hdm(0, hdm_ranges[0], hdm_bdf[0]);
    end
`ifdef SEPARATE_EP
    // for separate devices
    for (longint i = 0; i < `PORT_NUM; i++) begin
        apci_addr_range_t range;
        range.base = 64'h1_9000_0000 + 'h2000_0000 * i;
        range.len =  64'h2000_0000;
        hdm_ranges[i].push_back(range);
    end

    for (longint i = 0; i < `PORT_NUM; i++) begin
    	bfm.cxl_bkdoor_add_hdm(i, hdm_ranges[i], hdm_bdf[i]);
    end
`else
`ifdef APCI_MPORT
    // For iw == 2
    for (longint i = 0; i < (hdm_len / ig); i++) begin
        apci_addr_range_t range;
        range.base = hdm_base + i * ig;
        range.len = ig;
        hdm_ranges[(i % iw)].push_back(range);
    end
    for (int i = 0; i < `PORT_NUM; i++)
        bfm.cxl_bkdoor_add_hdm(i % iw, hdm_ranges[(i % iw)], hdm_bdf[(i % iw)]);
`endif // APCI_MPORT
`endif // SEPARATE_EP
endtask

`protected

    MTI!#X\ViUe_,[us@)o$IOjKms*!m1?7x#j1W[xmI'=@7a@Y=E*QAo=Du\^CG#LwsmTTwn2CJEe:
    [Z-}^uCG*Oo+';-xY<YO}VW<RbrQrO4"G{r[|Y?s?!z7ame>CGQ=O;13n}mV'C7TEEU@GqpRv^EH
    p$3>[xK-Apz;C#-$pRa5ViG[RJOZ_CV@'[zw5H]YkGx|#U*CZC@2O1<Y3R\?QBkZD1mR5,YB1emr
    7Kb/0|el_r$@s$]QokQCRAV^}?B~BQY-mE'N}h<=Xo_13$e?Ko)mV2usQEJpFTr'^<x>l'Q<Gpei
    B>'*rfp=[5x#z\hGk^OI*supZ1$^$eTB_*w\\-EB\xnHDmB$Wr5*E==r[v}[n;A7~jsDB'>^k3@&
    e*X}{C@\uV=}n_j$$,K]K]C3[@nXIRp;e*Ck#1<^lz$HnjK3\Quv5u-['*,*}=-mw]}-fY;juR@^
    \HUHl"N!7U-p!e1sQmR!$rA31O2zCQBUXeEZ=J;\~K,7iD_WwKX)j!]mZG1[iz>13nQ!#7D?\+-2
    ,;V{?svu=}ajp*e2YleW!DiTok<7?7E[D3n_=!]IO2=<},}<_W[j&C-vDu7}ZYzZklH{{=!2z2Ru
    _#XCp--<j!jGl"3_o5AwT2~}2l}D,\G{=^;1a72o7]-^_?4*BAzAelvKs}]T*JA#D@~Q~!1f<}~-
    +TTB2=ko$s*$'u*@le?XIT;[Q{B<fVHvUc{oT#KVj'e^TJl^W$~sBk1+Q*8a5U[EKZ>z*+r#s'Y1
    RC!JXDr/B)'Ri<,k+!XaQjO_A!Ioc5j#HAYG'UCJ@1_,rRJYV73$RIvZ_X5V75oz2Y~>WIC~^5V7
    1'1GOsI=*a'YVDQKpsEXo:Qu^1c{HwGY3O-!$vX43]=X2r<!Y7J<YYi>w$Qzl1a#1kVKOj]?ORun
    7upZeIzON;5~5^JC_Yu\I-lusP],DAz+7s/gl=kX&IL!O[JpSerQG~YB@3Y?X2C=vj*s>AjKjxiO
    >3+w@}]Ho],X^D'!e57>+-]R<[;XJGe!+DGe!'U\li}js2]?p}zZu$lGZkUZ'#pX^E1_#*@Qwt92
    poWqU,P9OQ,Bu$n3jljle'~lG\]KNGWQD$e*ri,jW*mz1'vV^~Ii\{r<_Xv2$7>s}{7D@r^lV*'X
    B8qwCjp5xn\!s7iO"0I>Dz,nITR{RZKCl>H$^>]YBmom$#hl<27lJ!jNmGVX<sHYkh",7p{wNj}^
    z_jm-f!${W[S}r\Zt7+<Dpm2Tx2~$5sw][Kh,Y[+_@m}e-H]XzW}IRV}\_uQ2v[UG,{$Kev7_Xn2
    _jG,^gLmUB$$D{<o#YEGQBEBC[7]Z=^JA{#lekTUxjpQ*1W!xlXw]JDT+@VDXYi~C_-x1=UEru]'
    I+z>_-2nrnRe~5JxJm2gluHG$m[QYXU+Uj$Z6{*A26}RxU*_O>lie;x+3a_K1ZLO{p{8J'V}^T~Z
    VK[lY]z1@Ox5OJU*zHvv=$Hm7vJ3i*Rl1kXY9mrm-nOVpJV*BGZDGWE$m[4='@K1CHYXReJi-$<G
    Z3wH{K\-vav35avV\JX$E{;osU!CJ1{j>1Wh7Z~^{A-O"[3HKd{xm<TnG'Y,*,5T5GYIvVlvJ!i]
    w<4~\=KByj'5{r=m@D;CwHQ>ziC5>3GuBm^$a$DJlOOvR\VZ-I@J~BHT??}DE[B#BujzjoZX$ICY
    TmID{Cnn;u1uJEmmv*~p2R#prm,pE%v^BK{O>lzerKTrj2sVp$O17u[sB]t_!+zQD}'jXj\tfAno
    >Vmp'LiEa[,n[X]I=]5ER>r\v'!{<j[Gosm{>#[={wW,2BmE5X=uDufyn\7#K=RJPWTrxz7Hk@wQ
    $%D<-~\r,=5*o^=U$CA[{m-s1;2{Ee}!'ogCmmx$kY{DX$OV>po|C[]]WHj<=-eVE*C](1,J-LBW
    G[r+l@?'K=VGQaoX\;HQBmGg]qDmak<nuHzZ!T}2E{kH^UYo<kO>GxHO*i#Q;vu[{*!>1mHx?G@s
    }=k>1m#DWC[sWo+H72j}Dld3IOBIo.-5-Yr!Kv1{*7ljjuwziHpGrY>nxXeR*El{l\8Dj{<o-@@r
    5k]wn_^R@'eTE!?mo^OoJ'id&io}~2=r@[px#H_1\pEjYw+sZO?5$7W$s&q#*BATpI#Y'>{'Za2v
    \-3VHw2/nnRr]\m{CY@+v=>=<Ur,R~wYo!QJ,O[Z{'k~n^!xlnZ;sa'vn}'l#pwl-Tu~kla;EwB1
    |#^H=x]T}YKKn^X;IwG=GBC~RHj_XOkr\TD*]!,VxOA@\,_;jIZoRjBH[rxjCu=rn{Uo7GQ~r=;]
    3waV]O32A$@su\u;xw$}]+'lwZwHo?*@1p[JmTaTuR;Kv\Z{CxZZ[1=<OJVpI]pT'k_1BvWX}J71
    Hr+U$EI;o&vkvE{VrVT\]VvZ<sYlQ!sAeCA[*1V=]$es3;lkrJQBV#zORkT*'oD;AzKn1Z~lITDB
    ~aw>RiFKBlKCslkD*;'V#j]*GAwVs[W3R>oeZHvIKr_vx@n+Bimm,f1^kUuoIwNK]RCv_AmQB@Uu
    [5RpOGoIN^IvCT*~}BeBiluE--5CO5mZ?WBwE*IO<CT@#8}#]{UTlxu5aBWoK~e=,ilEj]'^Kr++
    YA%'}~#[EKYx;JWw-<~ZxjZ7?IG,@AsClEX}!vWXC{jr2H?TGQ1h[,dW$s\w]o=ez}I}Kpu1JF,U
    O+ZlaB>D+$G;RAp:fE<YTvTx2Q^suGGevj7[[Q33pXa{^pZ,rBi5rH1G_V@uEX^TCpReKX$a^@OW
    R*r\U3a'=C[ETks3=Tr\3\1*x]*Diq~-Cs_^O,q!}vJ@V{~5%*opV1BaJ7eHX^]Yr\D{'y,+e>TU
    JX.<BU_Z{vmD\?xz>RWI?v'z{D+^D~@'i}B_z#_ja]=7'E{0ax'5_2'^uQ$XDI4]QV-nq=[{X{w,
    @C#EY65XU+lZ+#vQvE+^<<Tp]X:}DB\8'-FQk=1Xxl}7{E$vVIB}H~3Q}mC@<n!5s?T]pxi?'\J0
    Io2kVR;VdvvE$5!aKb/:X(kB\Q]>'su$p1k\$W]k@zS7^kYVRsmY>j~\232(@a[~XeiXnn>s=[Oo
    !vQwG==w<RAE@e!BH_7Xa*Z-ze*IO{]DGGj-Her}#Vow$i'Wu^Oi7EDa}HJA#13=Bo_Z^ZCU'JZo
    Co##*Yj~$WzZI[jaBv;nKHs7W5Ir,O7kx5W@]WA#JaxC,vVC-=m$ulR,_mAX^1YCal?x_YVW(&pO
    A{m+HW#UCaQ?!rPv>E{cqI[uvuE]!KrIDQ^'^uYaaE3ARj|zz>IG5Yn@5i[6Gnp$'uDsv\^*FJBk
    a'CzHw\~k,}5DV!1O*=O1iX\rEwQuXGEB}!var7#H(q!]r=o{@~_U}aA=w6Bkum*x~{*r#rC'5\*
    WR~s_\kIXT{e23z^Q_;1*_<v*v{vVQ[GpZ-y{anjF1$p=Q^Xz]awAvIs<,1->#[<Zx;!7ij[\x3v
    W7IuYR1Y?'2)8YipD^k~TD_[KBs@u;XQXxCnJ?l}$o9><Ir7n_?MmIYQz,ur>Azi]+^7ujvD'JX^
    ]exrQ7m5:B]3}OJ*u=ET}Qjt)=R~T3COeTI$T_}jK+}a<F=XRG5BrIus$I_O;5aL]]z-IB!GGD1Q
    i1+EoY{!>{n@Ex5voH,pI;{2vrV#@[oBzm'EirIUYQ~BrOBQpHp_GIV35EB'j+{a7ia?wDix_?<k
    y#^nn+o!O8~'w#D[n,uY-*x?meN3=<w+X-7Q~j1CZpT~>_s2TjlVl;[CXD!<o72vROQGApT'u,77
    vzk#,BOYkA<Dp,^KsCO3sZB&ljpTvBej}X@AIJx#}0ueO=EnKvxB[He+l3TXIC1j#DKEBAXn-2i{
    {+(xGp+l}Da-Oa>'3IzN:;$K{13O,moH,#XEVHEY>}#w11CiC*wo#I@BT'\E3u5Uk>lk2'IpGupD
    WKn}n$Ek$5BE$~>37rz?>w>eYConj$l_x#o*BDKZo$}ku_]Q;Y!{O}\?[lIHYB?^\N>+Xr7xD3$\
    J2Qrjz_;KGB5\wcrJn+P9153{|Yp>@]EA'^WHlaxa<i&skOiV{^TD#'>iTl?~^~=io_O=i$[Yauo
    EBF}~GpIzWjQp\K1Q@TAw;jisl}'IkV,kTw^2vHsI*HJU-?uz]v\<uzz$Hl;Q]#X,u],!|+-BxW_
    3<DBi}e51]fiVO@s*p?T^sv15I'aIC*@]l2P?A[j9CACQ^~Uz6o,oCnze<n7s;e}Hz>pBrsv#X.w
    q2{VB2Tx\u}[C~eZo2<axsKjk1v5'**m_=#nU}'={1!-wTw'!ljOWR[*J1*w+'aB[^CxA[!]CKr$
    H\]7j]pQU*W'w}E7lx=2[%1Oo-Yp!^"k][<>}?7]zkraTro,VuUR}@RYEBH=,aX$#Ra2o<[_G{[_
    I$*)BzGi:3*I^05[@rjW[k1ZmTh7^B='Q?oY'OYBn3*1<^;{lTHeG{u^IOpqpGww<T\G]a*CRlW^
    \sVAWHX7m1C_{ElnD;;Tg.l-j]]n5;{5{m0vYjaEx+,o{1eHI<#Onuz+{xjVn>k/EQ[\yB'#_G-H
    ;YnKW91-ZY?1?XWlH}$e{TC*{zE[<+[<Qzn[#^.'K5G*w5AxVVa\-$BYpOpa[j1m5$?Y+;ZE7j,E
    :-=,i}Ha=oJ-T%vCDJ$J<B31lUe-V]U{<>hX^wv1D$KU'Q;yr"[-H1E\A7$R>~Bxrk~n5eQEs@B\
    pVVZ*#V,mB~z!22_o{=nYn'o;#@OH3'\uYLXImTcI\p2_;Jp$=]5-RpjJDi#_@1#TGK_vX53E!^w
    $WeChTj_,${RAm=JCnYns0a<AD5UXB'*T5PEH-juoA~$_1<;a]$QWT5>a[Xj>wOxuKd9#'CaX1_z
    2*_uEG$n5aHJ~^K;D^7}#jZ3u-_XWVEI*Y-[7kJ<Oie^D#XC+}@HZ<JaVmO!_\G3=lis51YDSA{=
    aGC_3--m${G&KzHa8ju{O$?j1sAm7CEYC;jAIUeuGDTxmw7>'%7,U@g]'KA*5Q}I?ziM$zxu*RK>
    u=-3p#SD<'*_7Z~6([_Q]#T1[$@$!kx$J^@+kG@!6ueJlFv^@xv#Q;<8\x{\Ru~H@,#>=4i+O>CC
    <G-}/pZIelV7--{A_HoRxG#C^,T+H[Js[}kO[{eWAiY@VuEiChUvBw<w;;?OH<'G+5kAfv,><zIk
    ~W]reSIDrX}$DwO{=<_i;x;>l{HjK7~\@{]#GREW'JR*BI?o'[F3_A$q[mE#'Cr^i7@_^AD74\Er
    $Ts#}I+uJ~_}xdR2\nY/,aw2oAp>-1UG[\A,U^w!\{V#77v!0a7G~I#KU'B@D6ral}*n=_QoEr'@
    ;!o_s[#jo[I=#,1YAU3GX,iTv3\jD7CUnJ~rK'ox!I)E>G-px'7wa=~YE{{KU}TQjH*UrI~/IAD2
    7**<:~eXj$hG<@psQi7=mp?1^$aaGBwoM_t'5TA^n$H7o[pgl}kU.&ye!H?$A*KZeA726;9uX;mu
    }@{oj]res*~CY3^XAC[s7A3(=23'*nm*r3mTOWr;2&*zp^BLAA5-jQ=IwBZX!=uI7,xn%Ovg/Yeo
    a;]Ci;Q_[vxrvka]1OzK-vOeam{]iQ-]e~A*AR;Rapp[=1IEHxO'~^lJ-G*BHYR^Ct%01RkQEu7{
    DEA#a,uuP!rwjJDZ{$[ekC_Un;xV72=\TjHj>JI!He<3uK{D!{5!$^jIAiN}b*^#p^uADdQr3oD@
    1kOk*keo3[*BsYeTKBo7f@,e<x|CeWCxIs\omACRlU,GZsixBG\RA5+Qj[?VD{T>CQk1pl'N,ooV
    HR#B~5Hk>GY{F_T5uWBrQXDoIqDjk#w}#Ga'5!#AB5rAY5/BJsYw*~-xr{OCE#v]OukR5Zu'U@?$
    pO7gZC+ueZmx5H\lprGplmj}IXvIQ?^[T5D*B;Um$D}xC*Z'rvH=C)p5rTGE;!GAzm^X=Z@$lpws
    jOPp1I}x$I5:+\}A=~]3^<QD]G]B?[@{W_ku5,n=an{E1A+Xm'7>>X;,7X!-H{\B]GHnAHme\#o,
    O#r@BaOkso*^A<UI#5GRnA\EEE<]AvGJu]V5z-2;G*j2;a{nB;^+%keQG=E'3+H;_;xDv0UO~v]\
    v?#7i$BAmYn*7Bu}zK!{[mp[A_w>>*v;}u'z7C72sm@B,]$QRox1+Q7x]_C_l7~O>=$ZQJ#s+=_*
    nK[>@-!YKuOl3KR}5oO3l=]kTA5?KWO'pT7^{?^e15eUI[.}}>~O}>Q_Z[[s<,/D#\RDDV@52OJ#
    'T3~5;Ak]E=5uani5Co\zjKV1Xl0Xj.b;^K#ps$CNBK)C?17rK*!qHnVKWBD#fTQJ#n*s!r[Ew<w
    KCU$Z-KV>u}A3J&:7=J3Y-CG${Cv=nXsU>*Wh*?2\1i^-N?53HYxZ1Z>-Oi'[Hz+{A$[OJe[7wS-
    I_Q[CE>zkCxg_\@Hn}EzsW}2[z3nv+*H!oaO*,Kp~OM;D<}Y,WHinpK^@BB[2,sOQJsvZ~OVE}X2
    RD#{TH<_l>+$}R[^5'w%W$}]GCZ]Dv,u[$lXxRWsbDkH!>[A}<,6waskNWD'WRTTImj_j/gp!pO6
    W}!pI]TU2lziRQ#p'0'\ulJ>ARxi;l]IwTn's=[ip<VlUHYmUomT$[&:&'io$,=nHJ_zB{UX*IU$
    vtqo2_;^3{mr3K5QRw<*$}28,K2+:Vp@VPi-3EB2'D)0xsA,lD=@+1wRv@5u-r@ToI*sHH*Z\['H
    w5X^C?^?,3[*DJ2UIZWXL}eX^-12s!1H2q\7,BjKua+sO$jJeW7_=vV!nepI[$\ZQW?^knIDi!O]
    *Y@_ilU=olD>{o53Tn5[nkwTCoa7VjzIB!7XCJDG5_z!VvaXl[VnURG2[x-QGC;oJs}>;,&v]WZt
    RD~?l<mmM1U_}jk$]EJT[3-xr=3[YlQ_oj$$RS1HB]]Q#=l;*,'lrkQv<H_ix}mhs}tAXvE]DK!{
    =e5H-H;~BWQZXL:on;v=D<EY#1=rKI@kv[7z<n#1-Oug&!Dv~oHjHp7vYlp^Driz~a_vppRGv=eB
    oy^++kH{[}cx'RYZV#ZZCY=N{15AmYEJ7o{oZvU#QK+}|z!Qjp#<#2E#kv*OGhsB,uQkCnHpi]y!
    aCC2E}I*s5voY=I<'Qx/}sEaDxmsOQ^U'H]_OKVZFua$kl<<2Y['njU}U__+#l]5l?lH3Z^;^}ua
    Uxxk>WsRz_muZ1!{CE,[3%C'}?b-o,OIU!}pQV'$Z@zv#!@<*nDvl!B+{<e\^I+,T=oa+A2ep#!W
    1Juaz~@$8><[Dlgok2v@_r;unW~\A1s~$l\(=}eIxOZ@'eOQKpjwR-3==E]24}>C\H*n5D?uKCm*
    7-GIzalDr;x]QpRKV~>7;e;1z=Wpkx;[u{Dz}(;$*i\Yu#\eG,>I7Tv=T{ur]l^x{-$uv<p[BJ@[
    lTZV4[AYKr5@T\D=^zlnvww$,mCW[.@*2^-xl<C5;a57X\BR-#W}]_hr{zk~O2}d@$W~_jI2[i$}
    ,=;^{7I{:1a]=T]Eop\RQ{8UOT;Yj+r$RK]vo+V~+2{>$A]l+*pf,VnI$rmTp3@T^[E;_DUV7@<5
    Tl*;?1~~s~;Ti\uJ=l;l{-A{?{T~YHR\3V<~3'#@2YuTC#Bo=RYl*O<70=~uw@=H<XQk,AEB<\+(
    Q=Gi1Ozz6wRxeS%cmCnw#$i[^+7O'3w-$+K*rJK*?'Do$}->;nrDrBG35\l7QYk+ds;-1LSTe$s$
    BWJ3n7^^GaTI5]CL6kvV1;7znO-HlCv$^1-I{]zVsaHj1i=C#Jw3]Av2A~5'B'?W;CTOlOkW\+n7
    wjX_uEjXj7+EW+nrmzA~aV2su$u=XGwaeHxTT;[<nt<CAazOiQY'__~E+{OU\s]4(^!xGmV]jx?A
    o}<Yo\?,BvijXn[#Uuok3#XsZ25~-zQ]_qm+sTt>vm}5n12Kn1k@>jjcXe@aOs^B3G2+}#j<Iw-{
    z;jesBJ3vojk_Q*G)CR#=pBo?uzEzH*?W[1{OZx~HmC=QXpGO=u[R2e1U4*nV3C{!J=k-jC}?=fR
    D*?jXE>3\#ODl2=wv,saD+uZ7!\ldSZjZ]j+3j:.;r5apQ-\nla~7;v{2{]W)>}->W7+_Fv}yXt$
    a{@rjUnl+^ZC*=aoaCV_Y>ZRK=GC}7eI<CrrHj@C!R1?UYx,Dk\uvGudY5>+D3u!5?-s7U,~waW?
    AxD~@5-'3QOpB[\v%zi;<+E7?u<j}$n<*2\e<^EYH2--5a1e_^C@~2]jlHY>Izk<Ur}~@;vT_=W{
    YZQm+CXj1EDEpns@'$m}\JIx<vAnae7Y_<BKY3_l-7iX2)9MH{<[3envpgexj@A$kKRAB$^uZk]5
    vWri[p,3Z=*G!GSO{CH],{2zxA]=Dv];vaUIjOCxv3WA<xWC^VC/G_\z$j,5VKJpV[R*]OT'hE'l
    w'pAmcYJ2+aA}Dpi{JEH1KjXn_kv^p2RHD*VaepO!~HrI]"!5z]GoQI?DVXzeZ=Za_GJ_U'Kn2#B
    zU^B@r3J$V*o$p,pvw[I_z[%,MB=#RkIwz-\BRzvXrIr,7wBn,$lQD2T1oGlkYYV#X,OH'Vk3Q,~
    DjB75-H}po,ZBKTB\nUp$p#^z]^uI=rr1eY*B3o<{Kz}QrW5CWZ<ZUPt6KzOXi,Ok_p>Or}o?Z{x
    ;^JR>@5Y]Xp[\,2'@67I[;QI5JTpuUv7r^A7GCg5uG5%zIjIVuO57*oTsEH+!]7Y$[\ZCwpBTx+l
    eDQ~(l\x_lD<rl'>_Y#rE@O-ooY@@a_z>eW*xuRY\^ACzS,v_n)BZUOk}+=,^AEx$-\e[#*JU\K7
    3$[{{,>wSD{~MJBG*w123~+Q+^33rZEIU'JyTeBD,B5#@-[[Vwasf!U>RpGlsYIoXL17D{IQre8{
    Q@GR,#Q8UH$@pZEz;]O5I@lKz<!elwoeno,7pok{e31H!Uj=?BJ$l!o\$AzID_O+,}$a1iw+Gw5,
    ^~p}$ivrrT]nirB[=R{vdx+=2'E,7asK,H}1'$~IUHemY#.h)@L_s?K<7lC1G*]za@Q=KA,p>uUC
    5YpbpIzU|'^!eUe$$oJm3r$~rz+sI-xTKxr'3J}]<(x-*'ao,{!]p',I!<?DzUne{I;zTEoa@zS@
    njQs(K-}~8"JsnHC,rssaYsO3xDE71Tr!U;[Hlz"s7E}3nO2lKH]Uer[JDuJVGpuU^1+I3uTr'_K
    a-[3}Hl[|z1JxoD+$,K]DQs5;1=R]uTuIWEwZ{Vi>-C?T:G^TVB*-!2*oW2T-^gRVkYe?2mB3~la
    GRvKIRe1{n?IdaH5Vl@'!v,E=qqeT,[@XEOiYvUnziaI;u#H_ns@[K_?aQ[3+TJiaG[8KBw-uY7}
    swYlll1#u'!zZ_lHiju{(AsZ#*KjJEC2I27?]rkRCE[>+EesiwY*~XDn?+a-Q"]k13$5a]o{Emw<
    ;HIJU?c$U@^CA[RW=X;o{\Jir!#o5,'Cau$ok^'Tl$o,1pvAj<;;U{pJQR<ju{<$mrW~'XsO'r!+
    n5!I$YG\=#lEjHuT*eCX*aXs{3-,u}T#[1J}_Em!eXTm>~r'Iez7QZv[R**AsY=O_]7R;H!VYDmE
    x;BRpv23I<}\25s<\=K>*l55xK5-pkBvz3}$=\vaowJ_{n3QAw2'nnKis5#aXaDI<_u\2OX)G'<1
    ^iQU1D@KHU*~_kxus5WH[$*W=EEI9^,2jQq+7$n^=eHpzA^L>-lD\;jD?QzUCAz;s<~;8I]VX2VB
    \?RHa#^a[TeuH}mKs6s~s#T+3<0-[n7A[Bss~EIXCIeE2IQY,v?^T<_KAja5H^$,3>k)a+zBsim~
    @*UUMNI_^kp-TG+NIv#OIopsuOXrDue*wUe2QH{mUs]C,V$iApm~n<A+Rh\njjYO<!>]psD1AwRY
    ,<|I*zxjo^?rZr-OoWp3l;OieRu~t\mj?]!_{ZECIV5mB$%G7pH,wz1@E@j;I*2OV[JOGn~CAzJj
    Am?N$[-znj<#@eoo4nT1R|{X,IJH^QB;7agN*3[}3]@_Ae'OD>*^*{;Xqu\=T[vH!DY!<JI*Gv!O
    ]=kjIM\AXC#5'wi*EiLQ@ROz$CV[a*0Y>Rz$r,Ha]~WoX5r7)=H<Y[_z;Yz+oR513!sp{lw-eFn*
    aAPeW37/w}+1iB2TpjYpue'2jiYGAj>{OOY<x<m[oO-XCW7T#j]fz+2k^;zUhVYioow*>wxQ^y'e
    ie37z~$Hu~!V@mJS&RRuxw^$^\^T!vo[kb\W@EPiE{CYZzB*3rBYRDwDoGp{o<_gaqN]j!Zl[}J8
    ^RWnxVeeRI!*V'W@^x_Hzz5=BE6Urzi]Tu=5r5AY#Ealra@Z5Haj,,1NU77[{j}O#vm',>3J^Cip
    Mj;I#o51'mX1Zr?]-DG'TV]JC?T!re,X*(Q@*=]+vUuTu}:97;BV>Yl\^,$^zeQ5r>~Eu_3k<\]A
    a}UD#>UwU*?OU_D*0RE5!XX[;oHnUY=nsw>E{Y@nD5KIkRu5CuDu#wCW-%do<VvowTz7pR<KE;p_
    ?a;0EK}]A*QWto*-z)7fW\z=Y7R]DXK]QZo,oJYEkYOsX{$$%PDEC7<R<+o~oDH1[Cx_X-j?!l,A
    AU[E2<v[om+[!<olYBI_D{Ri~]k^5aGnr>MD#D'*=k#{1WQSWjGwPxQ3p,{[Go+'*~|ZoVDH'RX]
    E!_;xn<WO<Eg!en<K\@sJr2p!>1mKU;#JX>^\H>Qa.7aU3q'jomn>RZ-R![}W>rr7mJs]nJv#a^@
    E<njX!I}@D;oV5UPzVn=+wE,ppAEln]a*'lk$A2v~V*pV}mR*\Is^\B2hUsC<[U[RQu+'{l|oBI5
    <\aJyC7]ZrDJ^tmx;~y[\jCF'T!2U_J{i>wCfvInXD;\]__wxD+;Xdp,mJ_^;#\~\C[iwIzVwuJ{
    xk)ONCTjVHaU;%L]*_mCrE<VZn1Al#\mV;=-[$mGGK\U,v$M*3<ROlY'-o,uM7!Iul!*~s,?E<{\
    Wd[l}i{C~rOoIK'WKY2rw7Xx@!]E]HXoe1RWHx3j!nLl*p]lRG*BD\Yxk;}u$XTs->[l!-2<XCk}
    EIa$3W;mEprK>e2'Gek@1-UEH,37uX<rVli}m21*oOG~pUr,;3eV~H+r(H}X{w[]~]lQn~'ruY'2
    B-C\~<T3U=H-3rJW-sH,[~YY;L<<n=.l%U=D{EaJ[5XC[0]jeJQz[j+jp[D5KX,ZezUQ{5D;TQ@{
    {A^;pUYvZ+HEB~qOUQ+WrjnJlJA<Y#>55G+W${jFMrxpTI\{B$ZuBRCAG3[i{Jsp~_=}5E+p@XVo
    C*[s,Rvi_mjxn!O2X}CpB\]C',[~<=1,IxD*Xn<_GHH<UoaB~xF)[Dr=EU]D^,ITv'AuX-1[!z;z
    aT2\O^W@,-oJQE1_rTDD-Q;~/GTIa!A3AV_3rQIor,AKKB^OVCHzp,kr-BeA;/2C_>X'$[N=]<_v
    JamH'A-xH3pbm[rAKj={Zo$$LrVRZD]}'?CrX'%7IBjWwB=kl3=H'JeP<}J=5auB]1R!F,@<Kp_#
    {OTERfYx]?'GT[^v[[m,<1oQRI*1J>ZeQxU^1kIvx$$i5IISH_}#bXOOliBnA+z<l'pA+\^7={we
    =YiEk\jH<s#TrLOH!#Ua7ZvfLE6+D#Au_JCFaClm5HspW*nkxG#]K15v>*r>{E#an{jknY\{WEZI
    jm!=Cv,u%T'xo$mmRSe7p^qH5J1DsXu8Jp[5?5i_hF<aXUOHUjwA]v']=rN5aR[oOVj0QzHlVDjJ
    zk~Aj$D-u[w]vD^}5#>o'5mk]}J+UGj@IeG}l~\vV7<I$xJB[-I!=J,B]mw!EC!3nU]>~opaYT=_
    ,s3?&YwajOHvnBv$eC;l!BQO'2xGjiI-Q?<*,@*}**zX>*jnxI-l#kvzw95s$@5@pn@]G'e$kYA_
    ljwOQ1Pg#}X-?VlWG+B2+x!Jhn[Y^sB+CQrIk@[pp$G{+,$ROv[WmieXV!Ra>JrA5GDU'};+nqPV
    n_Kf!5QsEnRlQ>$BRn]<#x\ZE/5pej5Z-]UXAGrQ]XU{wA_?~I#RGOp3Ex.WQW<OplH1;75-xaQF
    ^k7phl<a!OTTsY!jkO@a7(e#~-$!r$k=Ojz}'kU}+]s,KR-vKnn-K^#azO\3rO\{O=^lO\hjwAK[
    nA=]DEBri_CVn!=C[D$XXx]^l5B5J^B\R!~aQ~s[re?sWH?zC}xYr~lmjl*xY[x;-K#JzU+OBC+=
    r3^?s37iEvEH'C]jQ;~RO+AG7>Hl~u]1p_Gzu_@}nT[E1'@nv~=w^pT3D*ThJO#ErOD=iOzaE~,@
    }mG]?pGnv>T=}+@Z]AXD:yI5!7,pO\z%pEQuiEDsCVj$3B?[^x@Zf(xa7o=7p?lAVzpD@r_7Ca]H
    3niRpspK@amzBiiV\i+YUKwR=i+oD'pRU${eEAXGQW<&Gu~KG7n3UU-uE2o*2E_HzA<Di]}UI]jl
    eG$[H=$}nr<zFpJTuR5AB\oCfwGaZvB_{>Gm}r@\w-ERX>72+Up{<r$1{BE!-oiIWp085s5XIl;2
    +p_zkAIJi]i3V^}yp}YiyV7],*W_e+IzV];=poU8$&b#XQ|$Y-~EsHn:\kIaK5~jvGT=f=X-#ylV
    J[WBXT3az5G!_JV#>j*JVpNU<E++oe$n>Ql1kKor;]Q'evs[DmoL7r*ZsI,VNoBEzuz#77_z\R3u
    j$j!,vD]p]*KC*=KDEHv><\GAW$\!<]EKl7^3EYke?(ZI-$^>sTWa;G$u=-/^"}owB?}<_QTl{]m
    mXGk5\~>O'D?XTb7#EJ[]RjCfTU;rUA~2,BI1#,V=Qeal~X=Uu\_n@w@?DJlYneX*BlOn]rk$V2!
    AWIQ#R-OuGG,u'$[15!@>nEXEa[>^LDDJw+>>Y$RD+@s5r5Vr<A-ZAVnv2E;Q=ulX.:/1Zo'ip@x
    ^pJZ<]w}^}5T1Y*=x1>^h,VK>_#X~r{z<KDDG\k~D;nT*$Y}1{]Zu[:,?VxQWQi\j2_=OTmpUYw7
    XQevkBz$+z5|%8]*z_[snaoQ_p}mn1ATYa]#p-r.pX!Z_]DY?EBH[KV=uY,jEH23b1w='2*GuC2>
    DvZHp<YY5,~[-'\15U'?k\?AWWQ17,1r@YG^G4$zvO>verAjIG_,GxnDsj|I?Q;kQWk7;1Xy$7Q.
    .7JG!IX2rI!oE#{*sJ]w]g9EsBokjR,ra~+@XYWz#JAc['2VKC[HQWQ-9;DwJ.slK!^mAz*Y]k$,
    pA=;H**['r>s@H-IrlxB5u{{}3rR,Wv'i=6Oj>*^wOxO;7{je~BB!AVDZZVnB1XD]Z]_*Y*eE]Op
    SVkJuIJ{R]?o@>p?,!rWu#5U7zD!HId_'Vj3-EOp}<B<<{RBnw}LmGJkuYi;11+lg*2e'AD[o@eo
    ABD>r,R-AJ5Uz'l=V]rOD_ZwTjB-ZQ~_1RjDxRR>!diQ[sTRrA-zeB|sku7';JpToUUU<J?L2oV?
    luRQ2VimsV*xSQj<GB!mBKH=#EHos^,p~z=Tr-CpDk{eG!TpJkG$#G];$RxI1Re7aZ_=?n7v3VEr
    C#e5x,E+>GHxI^i@<[J,jP~Q@re{QGBZCRY[p,[a'UW<u5sK_ITDn!V<snj?JmVl*wv|jH,Ie22-
    wsmOV$nBw-1Oy=7Ipv[XnQ~*@J,m]f(<B27}~,EDjl1j!,<~p$COz=BJH;U:BXR*@[vVUU~{,CU'
    1U\$]#,kEUYvjOzIE5-!>-ICBBsH5(BB>sp5\CcIkasQJp$rZ~Yl~5WLC]i}7z#A25-,gUB2vI71
    [Ckjn,{wK<U{_Z[n2r#7r\v/MQv{T8/E1mVNlejz)RVn;[@@T[5Ql.n*kz$#}RmwZB3pBE2]koCj
    7z_jR}>RRi[2H=8inAZP172^-5u}_]xO5]T>=DG!*mH}\VnQv=YDpa@R*zY~=!BQ-EUGv'AR*Q-{
    HV{^:HpkkgGV-!-'EmXe'!';x,{_\@=pH5U-H<sCJz:mpK~O?v[T^X]uo>pkXlJY^Q!D~xKL"sXU
    Vsmp;{Di}b~D>Y($X-H{1U;@[[_<GBl2^+57aYX2xZ5d\@~{/OQ\e^5[]5CuppGze]vp=uC1Wuo$
    3=z*wj#[<JUZ3p?B!#vT!;1vwvJwe[K>$#Y{7+B]~*W<2I1]njVksR0EN'2^,aR75eK*IjzWkj3C
    5r[1OY@~oesZ=:2H^T5CY=}1Ru^Ep#[AaUAv}#=js!=][=SvZ-2Ja!^7>'up\arGKxR>B5@rpUlu
    QG-Xa'kv=QW]D7]01am2WxCQC+~~^@e@Js2\3BTrGE-$DTdkaxA%c'7Z[Y&O1ZT+CX*VCZ>EuB$C
    }-vS$ka<5_GlP$C$Aj$\G!1K'+w37$K5UIwW,!QDjz!B^qu>BGVovmReD=j^*el$A^\TAj\ZHB[i
    s\15W[u\H_CEGa%alpr~^WDC-!78<BA]H-Y}pk7i;T2~GaK>jk[7SG,l@=@pu'rZvAGQ$I=v-<X=
    YxCiCH5'[BY2<eCDK%ICa~nl[?_RR,b7=lasEi3KAPm$~m~{Uv3aIeJ*~UD!MiaeWL2,R{zJs#,[
    XC$YXBj1+-EYkl2I*RIeDBW*-w$n5*1J=A7pj]s^}$lGQiwB?\TGTBwETJE?W5'ia@[noGI-15K]
    W#Qxiu'eDCjiDWVziui1Km1U)_p27?1?{2+U#DQJXZA!^>>f2GD3(/'$k7+'xe,-x2a_m@+$ZY5d
    ]5VvVm!rpXTCVQ2lJTs'1'HrlOoo'![jQ$u<ulXs$OCo7?~Rv7WHi$[][w<-m7R3JDp!e{_uC[Dv
    *\>$*5Y-@>UIDY3e2v5TbI,?zTpA}QV1I9JnB#=Y$=1v1m><e;R35;2^';QIY5lH7IeWJo$EYRB~
    +3AaT^r5<[<O,~q*<zW5JvHkO=@XVk[[WORmOInO!rinE{<]VlJp[oV{5Tz1A'{^$<H=YH2lJ>!,
    JABQi*?(,H,n\Q<Esx1l;$*aG#$^A$O@@5-BJ1ep#G'{zn_-F$#B>^j#rm'ulOmV\9GI_IMxkAU}
    DJQ(Ek1~z1DBMgaTX*0p2u1/Vc!CsoW[es"HvI#w<V^TpYuwIiYgOBu<OB*Y3CY5s[+}illG:|k'
    ==aD[A_Z>#Y\_ziYn\\XsO",O]{gAnzIS5{rua+1u3G;nu=JlK6jvuZiaj_YB,a,5w$SHewkql+;
    +1sUxXr]H4nUn=A1lu=KmAklse$1s#{j2p,35C,kGBADVXtvuE[1s}z!,IVkTxUAQo',Q-R]M5l=
    !]#*!_Q1CV?5XEZj]jn~;?'D<'5!vTzX>/ZjI-=p-,Ble]1I<ossla]]}uW]Z=pw@]BO~2pH*zUs
    KB6prj#lhCW!7ueE7&VOOE\Z[sXrJ#*Dr+q75J<+vi?%x?CiF|CwKTAwTp~v#-\rEeovsRfO=UHK
    nJex;*C\Y;@9MG+CDaIk\~pW\0T=Ykz-'-2GjB,5R?w-Di-n>A+sZG,[E2Wr}]{HDjY5Rxl{Hz?V
    X#n-x{%PxzCi}les2OI32RU-zK~paw=?Hr$C@]k=QBYZ1X,}B$m-l+jYX+z#X_3J{58}#J<#a3;:
    \lXe\TxQo@,AMpOXj*JG/CnG'?,O,S5zp~h1i7{}~w*u+x<G*#H{[,i6QBW[}K_ZVGU7>t5Xpr[;
    nCv=Z#RaBBlAjjQpoUp[#$21R!qIsrBYV3C'B7jQEB,fj5?B3n_DiUnYi}xAINY(o-]?n_opvljK
    Nns#{DXuA{'r*Vm_o#7Km2IQ2[1U}0[uajG5ma;\mQqfGklz<+r>=}E_cDkrnY{{U[u1B3YT~Rx<
    7*C7?RJYodWUCp0{s{BBGC{Y-;GQrjv}1w[']CW,Ho,]'+Bpk^1eXv?RwGaUrs1rOTxEWA=YHYR1
    1-<R+TZ,D-ee}C?er?\jspBz{skO7Vpm{J,'+nDjCjA^;^QoR!#B<w3=+7^y'>pCo_K#62A}<$l5
    ,u}O^IlHAu+}u5xK*aw~BRETI"i_eQrn}mS3e,*e>oAm',uH9_o}VAAz#.=ReO5aoeL('kvzzHR*
    7-+ChZrV~-EB?D4s5a^<O7;iIeAqv?lXgsx~#GmuV^UDlsD_^=\#?.l#EBiCBs7!$5*~<C#1~wC~
    V2H'a}7[X<#_eD3-eJdSV,;-$@~U'r7A!EllQ~X^xsz,Y)!Xr?I3w[F7>{w]so2+5I7U{EXs$?no
    Q+1x2UlOi$TFLpGQlIe{5*?\s=!@j3w{w/{Q?HJ5\@uaeB.5+p;RZ1+$vr1,wwxp9]QC@e+*sJ]a
    GiUWstvY$nr#G2ZV;uerlZ8lva~|p;V'^I[xDDlRVlU@]o~1mD,x6}^*k<B^DOEzz'?p;Y@5p\-H
    {Ywv7\}Iw|[{'1NQo[\V;IeKx~v!wK?RZ1+z<oWGUsURvIl:^EARBo*,oz=~!o?m3GTRSc$1WoSs
    GR>;jI*^s'x!XjU*JlOzW$+E3Z}lW'v\$_5(*os3=W^A}wUWA'?#WQ<A-{OK'IzOzw$B=Y2-OHCA
    WORHsa5WIW{7B~=HApaTIExlBmKXCW@_C#TpI}A{2jkV5RTwvkKk@Y=UOUsW7+wslmeQxCH@<>U'
    I$]>Rl#GMAxCUOw@XHHj]>e\JSzY>C%_+2sCswrl2,j?Unm}>E2Xs[T!]Br*j!J!T]m_u;k{6JHz
    *nC\+Ox?G$}>uM.p1?3m5J}s>DRH+zJ?ORnG!+B]@prk{'^[i~+OEC]Irz{bY+VGCY^!$\1nGHCl
    [zrB=U{ntDRzEYVEaT*7l0kO*772R!~}KU'2->,W*v0r'wp3^@{\W7I<Oj[!HeWXwD}BZ@kS_anX
    K+[5VO32D+_=CT3kw{Z*v~}JYWEXqpRCE#=T'2Xp!\~XK>nEk}1B,TwzJ$l6?<v[l}R+[!*OAG2K
    K'nJ4vlollJZRk{Y\}e}orz?IZ}5CA*WZ*O[!^*1BrC}5SvFWB>^XV{[('_oxs+7+xO$Wl<W}o+o
    uTz-nKe>-BOpO?RwaQV<RHsK$a7DO\?]mPE$QDE-HHE2p~K$n+{CxHYzC_Zl\kxl}vQrw$EA+p&[
    *X[B5lKi=]#IYl~I_=E}BO@ri'E+$-OpOVju51\_aEGwo@RBZBAO7)9]^?Tsoulrj;R}v~a:5uTH
    ~'U*H1a-mB5<>wd<+*pzp~3vB$X7mmxl!x3Rpo7vaEY;<[XIoiVmwn'nDzTE1O3!\lYvo5es2^ve
    #ZX;VvYr<O}jK;1^H^DIOz1=4{w,a@5+C\'25+IzRI{~p]GVnl[YA?e1xH$v+}zVC4R1e^iQ@D~r
    @{[2nl\Wp>9ImlwoV}ujo!<r#IusK=E}@>aI#E^mHH@gWCCXzmCj'9k'+BEuD=0^'UH21em[[ZD+
    [su{Ajx@Y#X35jI]=Bim<Cm*7o\X*l^V12U^7]TNO{*Z5\Cak[@roUxRkaGU=o,_GuJJ2TWuZYA<
    0[1}l8-A;#I?*$/X1wa,'=!7x{,\X3+W-[!On'2v5Tm2{,YER#_}[\mEVa["j5en}W*^R1pT*Gak
    Z\HG*<T5Ouu}Z13zE7Zz/&X1['vm{k|EI?'W'{7>.,mnQY~>-@C~'U-r~4T\57$;BK<nH?q=es{L
    r5Dv\u\T_oQVO%:QH,_]r1'pnXHtZ+2u!$^EW7JQP5ZI2}5YE5T5ZQ2o^Ya$muEZ5v;=n!_vz2$i
    K}7ew=QOvz,1=^$}<Azak*qp<,D#V-{\[*1=A7}7REC,A[#5V+[}Auw5w_+ulrXXxQigb_n+vc[[
`endprotected
