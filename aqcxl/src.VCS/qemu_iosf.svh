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
dASHaKfRK<74Q1+g&f-g>c<acf59#],T&UUZLM(bAL:=dHWLGEbB1)0B-/-G:.gZ
5-\HICM-[K^FS:S?@(Fe1UY7\;QcWf8Z-7F-O&#/FV<O7:648BTM,/G7PJ04YU(Z
&,>aZ6O=:7b8#5B5_g)g2C8?D;,),.N)d8_&3H-/4BD_C9CFDf4c[QK0TW\a=6BS
NeUE,QVVP.A&d)?ZF^[7,Y<:W89=\e1N,@JL;a)A2H@N_4VTMW=PQAgS3GGJ8?S,
.RJV?;2L2VUK8@8>8+9OM.)7?>4XNZ(A8<Q.06]YcJM,@f)=,1c&X0Xa0V=6YAYM
Y&b=^^\U\U?F8^1A\#J\PdY^A.:RD3?Q-GLMeXGIU@OY&C&GN6/NZ<+B;M>gLdLL
3XRP0AI6-PW@<72=:TE/bb\&#Kg/#5eM#??#(/WED,I3,.Ba&Yb45.\910cWbOD>
(73B?.WgOg^J]G3,H6e:,2P(ZGgJf)J:-P3-g3[G\?.WPQY-P6gWVHceD3P<RB,f
\VCQ5)IQ+=<L&eFH0,RG4;WG]OHBbCCF+fY?O6WfLC]EM4/33#Jg27aae4LCaP++
4RC318M0+M/]KU=VRA;K6AdFD6]M-dMX6/b?A-,g9VN90QZ?5F;#2cTbf4/0ec3/
D(eB7FP3-5e]DOR^IV7#>NNgR,&WWV(bdW<g#3_#H6;=#I__<#K?9JC?-I@2G<U-
6(>:MFZ.1MD]OYJ>+EO?JgKU9U9B>9)X8;NEcdVXG+=[KRIM?0RQb6gI=PRP3AE?
+]WM\HE-=K:8ZHMG77O._HAN6,Z(WA26E:W;Df__#@>C;,Mbc^NcZH^HcR[44[&0
f>-EWe3eeD/:d_=7W>-YJ#/4bK\.3cM[3>gbC<9aNU-f5AEN1Q71gd@-MPgQBH?T
9SF3UK(^=7;_3fMeQMVM/0XGAE74+FE_gS]0MUMbESR\gMBFaM=&M(gGC=YV-N0J
J=d&=O845M:PGP?AeXG)QHC,[L;PDK]aE_X10ZEJFGHS;8LLHcX3#\P<WFfSe+a[
:M>FU3WNV=8DQJ7M.SB1^F]NX+_dQHaVbJgX/dSDcL\f[J>VN#Te8QCO-1b1J&P;
R(O^)\SL3WHZ\Y-[#0T9JG/9,L6BBf\MQ,S7,e:<H/(8M_QS3L<cYbF.6@ILJgQ0
YTLg9Icb/>/4-4>bNSb>&SWH:[2BUf(g3<O,2_6MFHGM8/df:J[J1-b=DGZ2>(CP
1XXUN[ge^Bb[,9?+aV\.Vd;FFG=OYf9c5a9IF6(A]fc/7RJ<5Q#bP,HPSJYR/Ya&
g,/BRfd575CVYQZV5&6cHT@^<F(NYb3H.gJY)T&U6SQ0\??FcGZ+Pb01FK=Z)49>
E@4VY6PE^XH[EA.:E2_#1)D@8EY?a5#^ReWd6UeCLE\.=MaD2_O^/>)-6dfUKHM?
>WTd=O4P8L7aP.@/2T+He1TCN\&1<FGR1Q7K7Tc6:\f#<@]/M&U9+#&\<d-G2ZKB
+1F/_[b&7dVTaQW-8)CMWgNTd7)J<+1]X-e=KF0.GTWaf163\07UIRg)M>7Ba>&N
87\5?M?&EYGTc#6::S/62b:-5(#7_40J\+L)H@>+[OWUAN]8>AKc?1TI#F7T??+[
60A>6T5,YRIS0AEX>cC#FJd;<.8ZX5RRD,[CI]c70Dd@<M].(,L.R]@.1e-;/_=O
Nb1\_=OAf8[0c;+[46a:1PFd7,,=[MdX[fS9-@Q[W];.O):^d5e(X]?8WF4g^2_G
_O.9^Lg_<W3>a?aKLDAT?bI\ecRZIe]WJDN6Pg#]Jc(X#[U;CfLP#_L6c:7:f&b5
TEfYYA-(82TSbH+H\8;&g5U=VDWKdP34M(,668R-KCJ+C6?AW#X\d^^dFJD\_0[<
cSQX@7/aa@XZd;b:X/;;aEFHIbUcUW1^/2@8:O0V8^W@PaTEXIa:)F^WC4B/>YOJ
,A3GD(fO9af7VTB2@He;4:PK7B/9<DgTQ:@113=O&cR?61,EU(<_.:EWV_++KfQU
6eC[W,XAJ;9/0NgZ2E&J3ab8<Z]0E(=65,YT@E,:NF30))W)O7_JVF)KI]JF+_E0
YNa;YbfMJO)f;&=ca0aKI;XDRA.e6Ia?e?Y8NOSWAA?#8]0,[c>ZgG5JO8D@I4Z)
E@>?7LaTWcdWDR:Vc&2/b@,V[<=?3M,H+#,?/>;MVM\0AL51T@cJ]9@I^\1AN5P.
1G9HCea^/-1eMAfK074T+/?)U-()#CMaJ.VHF/VA6WP1YY[FW[I.GDW4fbf1&Fad
1D.Y1)=AI>b.^//&0fEDF>S&^SVO_FC+J1_K+QXM@AMc4IJ.\&f_36H?<b.K(_:Q
DFgAQV<Z<XKC#Mc9TY-3Ua,33?)=?ZKPMWO>5N-QBAK@fcdHC:dF[.44<@Z1c.78
.X#MEMUJ#f=5PWdG17F=V=f0gZ8V6QPH<:c]N^9:EYPWYYU-9_&80D>CVX<VM/Ff
QAKUdb#,X\T_B+X.[beObO-BS)_<S2PUB&M6cS#XL4>W,RD6gA&.8)1/YG3a:&.e
BJW&dGX).]/@M?VFL,/6ZE_@cAMI=dd,Oe8098;49>\46R?dEU.>;G4f-M78]/b?
S)da[Ee<96>;.QEL5e/3+Pb8:]U7a64d[US&ENW4S5J?\dK[Ob3F48H[DJL(S</[
9JSKJ_.eC/HNb?+>/f[A=W#,U(\N..bXESdXZ05NT0PdIa^2S)b<_23aY?Sa;@D;
-bR42E-3@\)=3J=KEd[TPGKD.J:KT4U_^^D1.bDId459^K3?5^>3MN5U.52]2<EP
E^,.cP2CE0U&.:_I/1a>Hd6f:[&8S/Z47gD2g9K3U:DQB36HU[1&[e8S9a8ASa7P
a].M1C9VIIR7;\@)+-6J_4-FbbPOdYEPB\bCG,DN3Q\V#B^?<^c7bV/X6S<#F6-b
VZfG=Z/79?MP8NY71L(92B5U+UB?d)Z>6>8_O=RXD[bS0KbH2aAP.[TK,ZZNLQCW
),E?WKRSVK,EcMLVU5dP>ECbY7IHF3Z,Ba;K#-0M4_;.eJMc(N+a;[(TT/F(a/gB
_<0I5gST4N4&d<>K>+5+e5dKDZ_4:RNN,15AQTC8Hg\).EO;K:D];6XBWe1E2[.a
Q]:\F-3d1.5K?J_#/&S:XB7Z17+Rc>fc20:H#aRTRFg:.500XAF(FVP@FT#C^C64
-+cW2)[BN^Y3PTf-@=8aICE93TeCXE8Oe;cF0(7F[I30_M67R1WF1FdaZaM/G^NB
QB-GVT:b3ZEXFISD]\EV&^]5GZ5W#+-Qd/CX[1.EXX[2Y;+>B29+;04c:O^<]QC8
.(?eI6f0?c:-Qd][\G/#Mb/eV8)J8?:OTM^2OBW+1\/9:8^L1<Q@+a;a6(DaNG;N
3fM)6)UD9?<HP^gQWa1MA8]<NFKcfMM]35_6YfF_62WD46FcYI&P3.6FXbKb;AKK
<0QXN;&B\KebWOAcMbUW4X-GVR[C(G:;OI2WJ:YIPY1Q,)S6b__0T:5S+0+A\Kd,
:;c3NHPPO;Y;B&M(P+UB7fQ=CCZK;e29G+^Z=N1+gF.,JJB1PS>EREJ,)Z=&c>.g
I=^fEUF)XX+\f3#&&BJPW/Bg2]Ug_#b]_6P_K8bYF)d;MU-bPAfc+KFCVdH4fTJ>
<C0Y(d1?\fb77@)3(R6;;EPN4?B&A+\R-f6[8-8<-P@W]S5_Uf6IRF5F-+ea7S0F
9FT,Yeb]>&(SFRY-K54=4XYM_G5SFB:/I6?.E):MT_ecNU^Z4A[YP?IOUA:<8BV+
]:Xf537,S9>O1(c&#V.DR=&&MHeZV/.cLGVcgA_O4Ld^);0H@P[7&D8Z=KgfQ:Hf
NDXY5d.V,0B[,;DJ79\:T,5&H01YKaCC6,Ua[FHRU;BK5_(eGLF)\197YV:U#0Gf
FDT]DO@.D]aR-Gb72^&d7?#AUfNT<HS++/;RIbP1=M<NW?),[F_f7dM0F_\0_AQA
U#EF7EM35N4Q=0CS(]K,E/5\cNX.34_00e[M-,4LLQY<0^:T\,_d\;-00BYK<EcN
bRZWb&X+FJ[3G9?.=;9WLSL9][9cAgMI#[G2W4#dPe/Ue.)6^d&f9RO8agTG^I-<
MJ:gK<5g1/W.)cbdbM#B(R=a>.&.+RC=^bQD?OFQB.O4@eOY=Q(7#LW[F,:]<0L@
90<7+<FFN#=)O^,<U7G/cIQ.)^@6VJSbS(O[T63DK;TFdD=\/PP;A,/gCE2e/;Q[
ZLe@(V@)<;bLdW;[[UQYXdfSTFHRZ\bU#[VW[<:PL@O7ALYDb@?9HS-QHRb9<(8(
^X5,G_f<;:a2=66YP1VQ)OP2<#RKZV7Y6ZEW)-JI[V2]Q+/BQ,J^.N]+?A0BRZ]X
e#B300GR)-JcEF>UgOCX56gZW+VPUYb#NL:J#8]2A@a(?eb#&Z<T^1A3JJc&]@N:
&N,2&ONR8&@HbXI@_5&Gc3NZIREDN1\YTATRM77&(IYdX2.6fT.^7O=T(#/AJYTJ
S=>fJXBf90H@.ff+TH2):X70f^(^;1bLP^:0Ia9@JXDNZ47-RE\e+Ufg\IAd7B)W
J=Q?AM4A\;:]TB;dU7OX9c(^LXf6@LKG1Q#DNH)YNXJ#.I&FVJC5HHDO5##PPM.V
/<;FUU7QdET@&9@;RL:.C02b&M9Rg;f00J5/S<9QASg(=K&C9@V>83eKPMV9U;5/
ZPbb\L\eCY&N:?<b?U.c076LS9C7Ze31B\DPe]OWZ5FLe@?,:^e+ES;90P>DZS>V
cF@<-V&aB.afEONPQ8dR,74L>De^TO7Xe+#Xa?5O4\#A;6SA>\0D2W<TQU1:XcUJ
5ggE]I4^,H)\7]fQ,7CDOU:O;K)@XWN:B/+EE+;LXVY/aT#IEaR)/.#6gdD/BL\)
.5VH;:TI8XZ>ILbc4X=_B9Bc-3[fe^.CI<J]g-(>8P?.Ca.1PO4a#U/@UP>g1O5U
<cW73T[R#WOT<TgdI>;J=_(I;LL<)RLf\+d6C60S>/[Q_1&=g6X]ea\77.^^OSO+
>)=CROV.R4YCC,^[E^63@,g@c(+(b]ZXb@Qdc5KP:J(?-#B-;;UPV22ZM#^BcPI8
SBO-Eg&&?F:2T^TE7^SK_4TRB(CXBQ-Ac/c>@^CT?RXL@_@0TW;QSeM?-@JHO,=3
O7-2>d7,b[:1gaWBJaEa,g==#5,5)VW/0K5\W;SfPF8V?GMFJ)12>;+Ce,@2IXT,
.SRQ+Me&LR\K5Q+F4gI(.S^bIN4HfU(]VDMI0876_:b^B]aN00\ZY[.&A_1>6+e>
HBDX#d.[2(eBYcg)/gc7BbK:NFU:EG(=-^_,@4U#Bd&OV@MNZ\?GL)8PT0E-+R#5
8#0ME3U6ZK<@fOD305=H(Z&O(XKB<cSL+EeL8UPT)8=7c>P/c(G2-.0;c@;.B:.&
:Z2D0YgA1ON8HI#LeO2MZcH.4>A.U[,N8L9?DHQ7?25M&PWQ;DVMZY:E>TH671bW
cSG\KfX=GY@W0XGb,]+\V>]=3W0H=Pd6MS>B^&XFW^)UgWCYb@=a@H9]E,_2+#FM
?]4\;1^Q?=a2?fTfVSBTS\b#DS_(5Z,a)#T(0_-]eX@c,9RKR#G5S<9MTIaUdK:4
BCe(Oa+3W2670W.1eB&0Q3)_\7+g_d:&8Z6;C5G#G&gb_#[:6@^c]:QXBe^eAP3T
@e&>c(,<ZHE\+6XgN-Z=g0Q6.\\a7Cc5c2g87#3QT2699DCQR&;HG0.f?.^D012U
)YIgSI^JA7?6SRTbK^Ud[_9[g7dD[Gbee.A0DVVVS8gG,XED2-)&FEZSaM5#[-2_
<\UOfQ:b//5,A?0ZXHQ,JC/2.)H>P7C@B+a.)\A9;g@Y8O:4bGOMf(DK.ITZ^B[P
OdGLK(9P]A[0aSH#53PHFGNG\.I.(+V1Q4GJ37;c/H-<O9R:AQ_+CFa,OE<L&/d?
:R-.+IPD>cYN7eXabM79NFf?5Z2_\JCK]X#<964@[^MN.G)AOAW#20\f[e_3BH:D
TBJ-Je:(]6J+\=6f(V6EW-S0\N9_A5NJJ/MBTg/3W<;==3>GV0503[W85/E&S7V4
W0FFH5:Z(RY?VBR^8)&72BI7F@5g]LO:Y14DJXK,VBeIWY<<\NR(JK^F;UFG0<M0
+7+0]65LY;=c002KC7MKL,CSD]L=/;<QUP@fg(86ZTddK8E3e]P[Z2+R@T>PC2T[
8^bRV?R/;3WR>>=/&H7@g@A#N[[XKXAVGI)II.FGS7+XS0a\/#U:6c3f4d/&D)PH
M&agSI=Fdb59R=4(5?>gD:^85V;EVJPf)7#NLYc_22G0[?<)>]#^2\JaM#P<X8H;
UP&&(NR2EOVcMTWZFEGg@?bPZ4^bT1@-LB-<Y.YL;75E-d)1)3]a1]:fZY;0@?57
LA,1=Z3QGH&H?U#=gg6+2RdI&0E./A7YDe2O[0R\6f0V;5+H>O[NWd9@?+.aC7?:
cFfdF/B>9NA8:6_&<LKFNe2:+DM^EYY<M40QWK7;.6<VD$
`endprotected


`endif

