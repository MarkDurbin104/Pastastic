unit GroupDesFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CompInspector, ExtCtrls;

ResourceString
  BMPRes00 = ',4,P4C=b0$ %5$)-OBP  !(V & H $!+ $ R $ ! $0X& !@  b( @###@   $$!$@!06BX<__\ /P$O 2\!+P$O 2\!+P$O 2\!+P$O 2\!(PY/ 8, ;___ 2\!+P$O 2\!+P$O 2\!+P$O 2\!(PY/ 8, ;P$O 2_@ 0$O 2\!(VY43:*TQH>bA%XV)@$C__  ;P$O'+
             ' 2\!+P$O#D\b3P$O 2\!+P$O 2<Oa9ZG  bVV,O!Q=CBG;?(?7E[8S\QX $!YS// 25;,B):,R-6,2%9-b,##__  2\!(PY/ 8, ;P$O 2\!+P$O 2!L44F]MK@  /?S[O____#W^+_6X9:XRWH  aAZ63HL5#,G4#<O2S8Q23\  $!b.CL[-3D\-SP[.D(V0E8  #5%'+
             '73E3:SI==3]@B%-TD%L_P$9#!+  /P$O#D\b3P$O 2\!*5TV)EPX)@  8#XO94Q 9TQ!8$Q!9E=/7@  6%)H:6EC7V!C55.5I;3=Q@ @N/O[^O?T\?[^_@Z@[_7VP-<  .*,L<5AAYX[6W<R2FTO16P  b]%:2Q&9B]&:b]&:R]);R\  %!S,E=V.%^!1&2-4WN;9(0;'+
             '@)Y=-2Z/5 \<#D\*Z0##83@G7#$@8   .RMC1#9?0S9@1SIC6$]E6P  67%O<VUN=&EK<W%Z@VY_C   <(&2=HRA=Y>K?*&^?J+ =@0 HKYXHL  ,a^FQXVMRaBEPWP  *7%?:7&A:O(K:^Q]_aK[.T (.RDHYNXMZ[CX=T.</O\_._V  #XO-/?BJW&6X*9-%)T,$IO'+
             '   O26XO2V\O3&\Q470T6aHW  !=@#Q?BTAKCU> I%^(K%U8? !7bB, ;P$I#D\!YG%73(21HYbLQ(T  *WaAJS&B*O,A:O,B*O.AZH  ,R)J\R&JLN#J<R(K,V(JLP  (2HRH*GR(&HR(6HRH2GR7X  *?a?J?(?Z?a@:?(?*?&>*8! ,*.K\E]I,8 ,aBDPI2WS]*_';
  BMPRes01 = '  bQ_?S\^?GYS,_(WMW:P<*[ (#(Q;ZZM[#\_!W ^];>W[C.W@  B*O%5WZ9-EQZ,EIX-%I[-@  6W\X7H$Z7X0]88A(:Y!7@0!?IF*,KUU_EELS.9\<##8 DPY/ 8, 8   CI6@C[7/C[3/C+30C[#/B0 $K<^,K]b&KLV+K-b)K ZAA*L  <N&JLV&J\N)J,RbJ,F '+
             'J YQA  .0(6GRH .0GVGQGNGQ7REQH8  *?b=:7b?*;&AZW*I*ZT].T  .;R\O*WLZW2S\C]_?SW]_8  *6DG9>6C:^MI.;CW\K,ROD  /GZZN_RMLW<B*Oa8HBE/V0  (D]8(D_8(L_7XT_88Y):Y  #UF#IV.,KU^(J&!86@JP #\!*0Y/@! !YH2,EH^QSXVST(T.'+
             '0+3/C;  @-b(KLZ(K\Z- 5bMSX2MS(>M  #.AZ[,AZO-@JG*@:C(AZS,2!B)a4bGRAOP?ZCa@JG(#M  PaVGQ08 @ZG!?*0JD1Q0RKBK^_S\]?7U  bBH9K PKS3T<G@W-7KZNGH  aJZ<K(Q9N;D:NIG>CGX_H $(  #J#P\;;,VXFIQ6:(JTAJD40  &6.166/3&V3'+
             '7(6J9XZP98L!^JU<>(U:+QT+1@b? 2 .3P%0 #.%#DbU  #/CK70CK3/CK+/B[#/C;a0! b.L]b,L@[0S(6OSXFNS8JMS@* BZK.@JG)+*b+aCa/AZC-?ZGaB( =<(BKRPY @J?)a.b,K,6bILF(  bLRJ.QNNOAV>WKZ=G6T>#?  #;S<O(M[:NJ:F?P;ZVY^3=0 #^'+
             '+!aXW=O8M;:OOKRVY.a=^0  ]_?JULV[A&>8I;J#H\=@@P  I$QMCU!RE6baK&B/LVJ.KP/P7(:E8$M&bQ, ;P$C#D\!@P!@AY.>CR@ M] JP(\;D+/0CK7/B;+/C;+0 $2-L,^,L\Z)KLP=0(6LS0Z@BZP  ,Z(K,RaK,N&J<J*J<R+J,V! #K@AZ?+AZC+.Bb+J<V)';
  BMPRes02 = 'J,-]I0$ Q92VT,BWJRG0Z>GGIZ:?R<H  ,+3SLCP[NK/T,O!PKK#P[T  +bNI>/@V_SZ^.CHYLG(O\0  ,&Z^OGYTIR O(1CD[a*BJ@ (,Q^HL11<I-0=9=a$&V1M6V01N*Ra+!;=HMS@71%6@b>#D\b1I&@K@Y C6 $MAOP #&)K\R&KL^,L,^+&_bKS@$ B*[-AZW+'+
             'BSI1SHVKSH6LRX@$\*K+AZO+a1b)ISGQ*F  ,#F0A:K*?@  GKQ\IL.+L,VJP]7CZ_a]_   _??V]O/S\JJIH+2UK,OaO@  UM7.\/#OW-W8U-71P\*WWb  V=1E@/CV]O#>U<1]5*>>G9(  +a,C*C-@*3%7X.D4aJ=7HD! ZULD;5OD+(<L%^&IUY;7 MV )_   Y/'+
             ' D:8K+J0N-b.M-b-KMb-K8! *:#,B:_-B*W-BE6!SHJNSHRK%!#/B:Q5M(8.0*O,B:S-&Yb#I<F#! bHR8.GR4@ ?J;&A:S)=)NY>P  I,-YH\* I,:+K\JOR-OEZ@$ \?S\_=_AX1J@J*FAN+6NO[X  +CKZNCL[.JWMK#7U=aY]O0  /OX^->A@\b&9I6OR)bQSHD '+
             ' *K+>J#b9HJN4WJ>88JM:Y$  +1ND+%MCZ]FC*YEAJ)?/3+Pb NF )P.3P(6FJRYDK?0C+,<48RNSSA&C:X;P YPa+#.C:_.#/b#JLD:0#DPC L@K,Z,JE:@RPVP#Db$IV0@RGJEPWD  *;b>:7#D;+.=)B[?*/%>*, (,%TG[UPF[IWG< ZX+#(VN/I  #P^_W^\_/S'+
             'W=S:W=W;MK2L  bWM*OCW]OW]O7^_OWOV\_+  b#6*J>FY.PRX^NSHJGSaB> !# 476947Z?8XFM;0Y D;-MCP \L&J-K6N-K&IG; NF )P.3P(6F:H$ +J0N=&/*La0B*S.B:W.A:W,  &+KLZ+K\^,K-b,J<^#K<L.$(,<a:&LS8NHSP\P #b(J,P.Haa0ab!YI4b ';
  BMPRes03 = 'P@!@DK/-<)BZa%!VH;YVG[UQ  b:NVZ4MFV0Ma.7N8:KQ[a(  #:YNSR^_O\^_G[U];6M[6N  bYN+/BX=[[^?G6Ga[bAF*7  bRR+#aU<a*U8VIQVN1L$AK 0b14WV@88FN*L!NDK1OD+!OCT> KP P:F1IbZ8 G Y/ A:4J;N4N]2/1QbWa(&*J\TVD&/ *Cb-L<YD'+
             '@(FMS(0b0:W*C*S/ABKPK<R H:K*A:G*5,b ( X0@:;(=J+!>*/bC?b2L,MOEP @Na>APa:?OG.>O \ ;Y6V;)$  +1GCK)FCK!QE;:&J\6SR]R   Z@^OO[]?/O]?3T]?/P\-[6  #b>5bGFYF2L,S#R]68J[2F  &YQ8>DN$YTEE-_H5Z(K6H<@ 8\D[-ODK(.$  P'+
             '<76 bZ8 G Y/ A:2IPHDN9*YTU6!LT:bJLV,a+bLRE3PBZT( ,V,KLXZ4(BNS(2JRHFKS8JL4 a-abb&a%bIR(^VS(*JQWBAP@YP  !^I,6,K,9NE[EXHL%VG[]O (b;NVZ:N6V7N YP;9*U:8VP8@  BZU>B:IHCKbbI\2NQ=G=Y   [/7U]O;U]L^;?KFb8I2NR8  '+
             '1Nb=M\^JO--TC[)3<)95?J$b,5BbHV&+KRK ;Y*T#D(<L6IVAPNFX$8 G Y/ A:-I+63NM,JP(^RSPW@-R&M7(C+&Vb,2 (Y\a\@@JI%P8FJS54@AZG+  &$JLFBP-:!J,2?O-*-K\X;P(  #;b%I\%RF[UYHL)VH+]OFKL (&N8N&R6MV^4MFI?TF:-KV&+  bK88BK'+
             '6X2D98FK@:/bK;_7 $#3RLN\=UbDFIH<4(^PSIbNSH  :0!1<9=1=YM7@Z-6A*1AC*\ CVJ0M&V1LF^3a(1SAYL+I@b<#D\b%@ @CZ6VD+C2CK//CF, K<^(JLNX8V]@AF, 4]!48<V)J<PX$&(0@JC(.$!4D   B*G+L,K<DK?,<IR\F[G0=  (GK]TG[ZbI<!SG;]W';
  BMPRes04 = '*[b@PG(  )V\;IJX@Z2_B*C @:6X:HT  *]KD[1FCK%CBZY?B*I<A:8  %5_G6&%IH&AP)VGK8^MS8\@ *_.>>&KSG.2MDUVE56!H5>! 8*C6H.D8(FN#D <@96R;YbO #!Y/ b1J0NF )P.3P(6BZ.UD;?/B[a/BZ$>G bM6[#,AJC+#&bbJ<EO8!P@G b,<(, $*?)'+
             '?J;&?:?&?Z;a#P&GR*&_  #4H+[2D++(>)V\<)B\?*&]  !NG+MRG;UTGKYVGK^2K<5O  *3M6R6MGR@O7*5LV^4MPJP9@  C;!?B:M<B:EDCJAKE*F#H00 LYVRQ)PaX*S-?9[ BJ?&AJ0  +RbG[M^F[M\G+MYFK9_G[@! 7Z?NFV1LV\.0;!OD:]WCZ<+IN!& )P.'+
             '3P(6BZ.TD+?15&b*KLU&((M0B #&I\R!J<A_J,@-L)K@@*;(MP :$:5$ ,( DaZDQS?@>:a#<9V]C;#)I   P=&;N\MJD[-WF;9DCK!NE$  MRL@C:C#:YbQ:9bO:Y>RF;8  ,6*JL&,K<6,K\:,K,2!J,(  (NKQ(.AOW27NG*8NFF4LVH @)6S9I&O;Y:X #!JD;5D'+
             'CK)@ b*+K5^)K%>$I5^*G,bP?9LO0+,1X&^1L1R <HVDbZ8 G Y/ A:.J+B8NP  TY>XT9FVT):USI*RS(^SRP@ C*[(BH<PLLR1MLV+L\J,M<Hb (^TRIFXS2F@F[K1G+K1EK;/  b6M\V5M<V:M\^RQ]G T^bW  #.UWRCM8BMOZ?bT9FTQ9BY  #+K<+6DZ_)=YR]'+
             '=)V[=)R]  !SG+QPG+IRGKMSH+MUG[QU bB?O7.>O7.=O76A6(b^ )!OE[H (&V5N&:/LUZ*K5SC<(JN9(RP (!ID;1LD*YXEXb@L&b!HFZ+HL8 bZ8 G     $L /0Oa96CKYBTR94D8+/2J)&JRS=0?J?&*: <4a^GQGJG2 /%Q=b J!RQ?*3&>*3!>:7#*O  ,   ';
  BMPRes05 = '?J7&>*+#>:3!=:2_>J/!E   K\NYR=>KP]:BO<^#I\%LF0  MF^5MW69NW*;Oa2@O72AO (B>*/ >*+!C$!UG[\M,a&=O/6@? 0 H<-WH, \\a&>NV^:NF^4N6P  )*W9(RQ7X>L5X&H9X^R9Y$  ;1ND;1MCJEIBZE?A*)MB0Y/<  <#,,.3P&#6S >G;_4DK?/C++.'+
             'D0*:@:S,XHb(J,NVH(*HR7ZHQCDPAaaQJ<6A.E -@aRGQ#DP\J!aT#E@Nb!ZIL$!4   >Z7%?Z;%?)VZ;YBZ<YR[@@  J<*6N,Z/M<MTG;YUG[YTH! 0OG2A#Gb^=J+ ?*+##A&<Oa&> #bZ<Zb^>*# >Ja#a1 b$ab;NV\  )>Y:Y*V8XNO786K6(.H8HP  +%HD;1M'+
             'D;)ID*YIB:-KCZX\ &V*#D\.3P$D#D0OaIR^U)&XSXZR<0+/<.bI@aX A*G*#Db%JLJ&I\L,P(,\1*G)#/ -@a\@J;!_I\< ,aRGQ0%0?:8( \9\IL4?@aNFQHbJQG6<N!G@.H  0a&<O&^>NWF?P!LP<9^]=)^_,,%UH1O!a1&@OG*>28$.H9V[<)V]a(  ba>AOWBA'+
             'OW&<NVV5MSDP8(NO !!9AJI4A*5<B:MIDbK L6^2L@%R5WF6=96Q;@Y/+@TDa(\.1I:Z<=#0&.b/L,]B0bE ?ZGa#G.H\$?1J,A^J,<# 8&HR(2HRBP0 5b I\=ZIL-V&_ D *7&#M&EQJLP>*?!B;a)<)BV=P  HL)VG\!OFKUMF[IKF[IPGU# NP#P=P[1Pab?O! A'+
             '*4b?NW2=OW,*$)N^;YDJ +D!@aBAP7AG()F[:Y-  +4Y %V*KE2%JE*$HUBaJ6F/$ >S;9!R 5A\Ga&0JFVaH0NC &\.3XQ_ D0OaI/CTE50BJG.C- ;D(QP?I JP U0#&b120U0?J=C 7VGQAO >QN0IL4.<aRF#D( !*;&>:/#=Z7!CK/*;YF.@,!U 7R>Pa.>OGb=';
  BMPRes06 = '#2b]#5)%PbLAa1  ,&Z;B,P!@76=OAR <)BY2& b09V\aR /D&Z6b :Y9H^TC?!9B*E1@:);B!R #D%N !.0L&b#I6:*JG2,G@ND+AP G Y/DbDb%b\>.-b-L]b-LLZJH(:,0*C*#8#_$bBP#2  D&.0 &!aH $@#M&FQWYR *;(?J5$ ,</DaNFQ \P>J7%?*3$D+a*'+
             ':Q (E[9U*4bAOG*@OG&>O610;YR[@P@-4ab:O&^=5/ .H,!TH+]T$&^<NA(0<9N\GS!QFU< OGb9N1%P<9Z\<@!(F[IME+9GC;%=*L!_HG30:9&S 0=ND+)BA:9J.-b.KW1]C ND#D]5CX $ D)>-260M,^(L<R/K\_^0(6Ha,S*@J<WY#>Pa+&HR3AP#&&FQ [0#Yb '+
             'IB 0QWE%\*7%>:;#>J;$.3&EQ7>D bGbB:K#;9FX<Zb]1*!R#)b=OBC@  =RG+UQG+IPG;MOG;IU 5!( !XP, 2<O0Y 1B!>B+MDCKYNEK])Lab;4 &\1Z!P2,b7N6B/LUR(JU6!HCD  !=JD;-LD;!8?9YND9SQ<@Y/#)(/D&.!  Y/ ;)N3#^JH)R0.0b*K<VaJ<L.'+
             '0,$?1$ I0(:GRH&H@a&$ILH-@&2 &Y !L !@@b J8aFDQaFGPG:EPP_P>:3#>J, B,)_I;YNF[MT;Mb@OW,,P)^_=B /G< +Hab=NVR;NFZ=NAIP*1 ;D!UP  !LE[E@C[I?BKE@C;E7@[A>+ b)O & =72@YYb6N6J1M&b)K5B#  :D7(BJ:YbR;9&Q6GZ?CK#RHa4_'+
             ' (65#/  /P$@#D\!4  P;$Q D+?/D+4-/-b+LLU54-7 AD7b@J:<D#A!8\!5X:?)V $K4bKbQ5215/)]I\5[I,-\I<1[\G  WJ/#@*/ =Zb_&M14P;UC8%80K4bK\a$\ )V[ #!^D Z@ 5!@CKEHDKMJE;QI  *6NF>1O&>3NW.?O76=OP,P;T bFF/PM6&+KE:bI%N(';
  BMPRes07 = 'J6F0.0bQ!aY;?Z%OE!R!>HF9bW  /P$@#D\!4  P:0@)2Tb4N Y!B*_,AZW,C?YPK,MPL /\AJ;*@:?a8P!a<!V@ 2!60 #P 5 <LaFEb #$?*3%<4![I<1UI,!WI<!WI @,P8.FPM:bPa*?OF^?NBG016&?O 4 <IV^=)R,<+PIT&R;N6^:NFZ:  b[7XJ[8XV\8XV['+
             '7(BZ6XBY $!<B;QGD;YTF<&NDa*=NVN2M   88RN5(2C686F:8^R9(>G8##QAJ<<@)S :G:(6B@B &\.3P)#:DM!1T = (^RSX 0*L#4H([ ,*S.CJO/A*S)  *&J\F+JLR-J\V,K,R.K%=@R1^(@*Ca&_ =TbNP@3 .<%50>::_8_b%JL,? GFBP=7 #D%&L3AQ&\&>'+
             'OG6<OW)&()E( +U7D&R9#G%:A[EACKAEC;QDBP  NUN&N5V)NUV*N5J(NW2:PQ  =9Z_1W!CBZ]6A:19AJAKD;,baEN GVZ0LPYbLaJ3J@NC &\.3P)#9P  23^-M=b0L\^RS-O.XNG9YP  [=_J\./N\N?Q\NKS]?+V^0P#]/?X\^S  +#T],;4XXRJS1T0a.b& bN '+
             '?Z;&>RKP5;bEQ7VEQ(NMQ7<,?**_=J*;$2L@=9Z^58!$0!OP5>!4,ab:! b[<)F[<0!B:)2Y6X>W6X6Y7 $bB+=9A;=RFBJ1;)6\9Y*[/#!M  b6MV&,L%F%J%RaJ6J0LEN! 2ZB;YbQ;Y6Q.0!PB[E/a S##D\!@W   E9-CK7/D[?/VN3IRLF^ZV#   b_M\b]MMa.'+
             'R.KHY:JDF;ZZ  2NK:N?O[ZS[^SJR-7DaIb,IT0DS0Y ?JC%+abaJ,N$5YbGQRNPC;!($<>KDa2E#G%VH<%YH,$J8&^:O(#05 !M5;b<?ObZa(!OEKEOEKIME[IK  b4MVb0MF&-ME6bM6b+MU^) 0BX9HZ]9I&\1Z!LF;AI#;b&JV  $(FL:Y*U6H&B;Y.S\G&0La*2';
  BMPRes08 = '#QbN7S@Ib], ; Y/ A-\:&)5@)&VS]P  .?KVM?.Q+^SU,WaKJRCO[L  +3-R\2RK:.^N:_-R\aY]>\  ?WZ^L;3XXRMSHRHS8FHS+J0$#%^I\2?,(2IR8.HR*N0TR!\IL(YP !D>*3b=:a >Z+#5&#S\&^<QO%NG$X N7(P<9L<L*U J8%MD[ALDK90?[( @%VaM&>1'+
             'N66,5/b]:Y.]=I^_( !OF0\ L5^*K%RaJFB,KF2+J\CPG,!a09*P.3!F2#T+TP!L#D\b$WUK98\  +?/D;//VN;NP<bXPKZXO+@  +bDH9/$PKFVM:NDH)FTL:<  +2SI\7$OO?T\,75Y(>IRH@@$*?+9Cb)JLR*J,R*I_40R86GR8&!DAb,K,6aJLN]  #P?Z?%>:7!'+
             '94$ L*3#>Z3b>:/b=a!TU*(/89Z\<)X@ +MQGJb:N6>0N5F$MEZ(MU>b#bbT78:Ua@bZ8aB>P&W&\)*U8(BL $!>A:=MD[5OE+$.09bO;Y*O9CP(3D@+TP!L#D\b$WMI8X^SST= TL_2  b^IIK5OK30LZ/1LZ;8LZ?*  bBC]bFD<J<A,N6@<62?,F5  !]I9J?AZO)'+
             'C:O.C*[.BZ_.@  K@(^MSXBJRX:KRHRRSXRMQ@  C[+.D[7.F[G1FKO5E[O4C2,&L<ZB,(VLSO>P:9!_I<=[HUD0=3#b@ CW(aRDPGNCP7J>P7&8*CbY9X\! +9JD[9MF+8JPa*:N6J/LG2: &bZ9(FK4WJ:;Y1a$  PLF^1L&\a@I&O:5E7b], ; Y/ A-W96*0LAR '+
             'S@  JX%OL6I&M6Q&M&Q%MG!(M   ;TJU<4RR<DRO<5bN<E&L=  ^5ZU[7IN6G8ROS!$0RE!*<)(0 #b/  bUSX^TSY6[U)*US)&XT)J\  #3GK[7G[_6I\3=I,+:E[O3  V3N,^3N-b4M<^.L,]:,bZ @Z_A0 #a+Bb%J,F#IL>$JLB$ILA_I2  PWRYH<!ZHK]TG+IM';
  BMPRes09 = 'D[-TF;Hb8&Z5M%Z$H3BAE+)5@0Y DK!E8&+Q  O3 &P.3P(3=75ZbHb4N,^:KKV=J0  N9:LOIFQP9RVQIRXRY^ZT   GKG0E[3.F;C2F;K0F;K1FP  O-.;O=6<OM::O=68NM*9NP  TY>[TIR]U9^_UZG(WJ*_TPP F[O1F 2P G*APMNJQ^&HQ=^C  #!V:7#VZa!'+
             'V)_!VI_ V9Z_  a6G;[7GKS6G;S5F[O5FKH ,@ (N]6@OM:AP=FDP-JA DbYU)  b++-?J3!?J2_:)&L;SAPD[)O0aB2*ObO;Y.P=aB b], ; Y/ A!<,2  !&M]D).TSYB\U9V^U:((T,+:  bEQ-VIQ]^NRN*RS..US>2W  #.Y;;.Y;?1Y[C0Y;;4Y[C3  #IM]#G'+
             'M]+JN=aFL]+GM=aE  bTTN:WT^:[U>:WT.&WT..Lb #+X:C&!b#=K<KBMMaGO-/GO0 bUNB^U^F_V.F^V.N_V>D ,+T( -GKP-<!4;S5Z;K4ZKG4Z;G1$ +HNM( 8.FSSNBOR^6PR^42 *( #,+;F;G1?Z?!<IJV;PX0 #b4L / ;Y2P:G%[b]  /PY/ D!>-b-YE*(!'+
             ' +#-X+O3Y<(a@-KKO=KLQ-WL  aaXNW,Y.[.Y.[,Y>_/Y>X , @ S>7NR@#PY.[+X^W)X^[)X>P  ,;>Z\7B[<3?[,+>[;_<[KX  -GLN=/ANM7JN=?LM];MM]0! .NVTNJTT^P 8+71ZK30ZKa1  GLL<_JL<_KK\[JKLT ,.FP &   ,OHJ\KGJ<CDI\?BJ,?BI<0('+
             ' MZCP]P@$)V_UYB\TY:ZT2_0CP#!L\^(I\=SF[4<(#D!DZ]SA)(+T.   #\.3P)#:4<XFI:3P=#;P]?CP@(!TNa!UNB[%Q#9ZK_:ZL#9ZA@ Q@ 6L  PNM3J&\ +$+G0ZK#0[++/ZR  L,\+0.VOS^VOSNVOT.NNS^H  +/1Z[//X:7%XJS*Z*W*YJP%0,KFK<KE# bL';
  BMPRes0A = '##aC )a)Y*?&X:8 &,;BJ,;AJ<CCIL;A&M -@*+$WP($HL3>I,/< #bAP=J=OM8P\)N\ 032F+O1E;G0#G2HQW*<M YQDJ\> &=^D0O3 &P.3P(97C0DAa!IJ[bZ 0+ U>>]U.:X#2#4Z[?5Z[88\-8 *>RUU.RUT^RRT>T8PNP-@+#0#;(  ,_MK<[IK<WKKL[LK<OD'+
             'KLL  .BOS.FZTN>CQ-NDQ>&GQ^, ,*K)Y:7&XJ/$X*0-@@b3H\7@H0  Q.bCP]ZDQ>bDQ-^CQ-^APP aW9[ V9V_V)R_UYN_V0!@2J S\((  &&[TY6ZT&W@C[a/AZ?%=)JSCX!CP&J DPO9 ,8.3P&V )EM3D*4DI.S 1+*V+72[+/1 #&RTNP ,+a2&M#N0b2O#;#/'+
             '[Z_/[*[.[AOQSNL-4*[, (#JK\OGK<GDK  PRN>KR^>YT@! Z:GaW:3$X*Ka&_&DQN.CQ>$4(*a$X0!@H !AXI_bW0 PG<a;GL!b -@ 8)_!VYT.0[[5F+S3F;O2F@ <N]&4N=&2N-b4N=  8-&@6^&MS@#XAJ/ <INQ;H35_YSQ#D\-N0#,7S@G Ab$>a2FN<@S\NRP'+
             'SNH-X=#OK\X!4.ZMS.JNS.D ,*LHX><TX*S*YZP $,?@IL+7JL?@JLCC)PbEQ>bG  C%W:_(V)F]TZ# V: ,PIJ_V0,!GL+<H,+<5>(;,-B:OM:9O-0 ,Za\6@b3#5bYT9.Y#5$J bI@#>  8%] F*b0MH ?;A#-D*[,AZ:^>(b(bQP \PY/ 8, ;X   2EO5$J1DYVK'+
             'R-VNR^2OS>J ##9AR>6GQNbBP]VEQ=\*X PPGL  0-J>OM28M\V:O&2 TYZ^U9J\8 #4b9 8,*/ T)NZR96[T)Z_U:   ,#7I</9HL+9FKC.EK#$D;( !,.4LL&:M,.4K;Z9M<4 ,(J= 1*L@I&>@Y*> &b$DI\ 8(.0 ,&bP  !(  PD)V&E9Z#C9)U:65=-23\  I9';
  BMPRes0B = ' ,8.3P&V )\!+&0_,a]R<(J%B7\  a1T@a1S@79S@75S@W5S@a0  a*b=a. <W* =7)_=a!N650  &A336A43&E73FM:3F]52UX  3HL8#DI8T(R8CTN9#TN8P!@!_\^+EXT(P8, /\!+P$O 2\.3P)/ 2\!+P$O 2__  $O 2\!+P$O 2\!+P$I#D @';


type
  TIDSGroup = class(TGraphicControl)
    private
       FPenColor:TColor;
       FVerColor:TColor;
       FExpanded   :Boolean;
       FShowDetails:Boolean;
       FName   :String;
       FTitle  :String;
       FPrompt :String;
       FHint   :String;
       FVersion:Integer;
       FChildren:TList;
       FChamferSize:Integer;
       FGroupParent:TIDSGroup;
       FBitmap:TBitMap;
       function GetChildCount:Integer;
       function GetChild(Index:Integer):TIDSGroup;
       procedure SetGroupName(Value:String);
       procedure SetTitle(Value:String);
       procedure SetPrompt(Value:String);
       procedure SetHint(Value:String);
       procedure SetVersion(Value:Integer);
       procedure SetBitmap(Value:TBitMap);
       procedure SetPenColor(Value:TColor);
       procedure SetVerColor(Value:TColor);
       procedure SetExpanded(Value:Boolean);
       procedure SetShowDetails(Value:Boolean);
    public
       procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
       procedure MouseMove(Shift:TShiftState;X,Y:Integer); override;
       procedure MouseUp(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
       constructor Create(Owner:TComponent); override;
       destructor Destroy; override;
       procedure Paint; override;
       function  AddChild(Value:TIDSGroup):Integer;
       function  IndexOf(Value:TIDSGroup):Integer;
       procedure Delete(Index:Integer);
       property ChildCount :Integer read GetChildCount;
       property Child[Index:Integer]:TIDSGroup read GetChild;
       property GroupParent:TIDSGroup read FGroupParent write FGroupParent;
    published
       property Name       :String  read FName        write SetGroupName  ;
       property Title      :String  read FTitle       write SetTitle      ;
       property Prompt     :String  read FPrompt      write SetPrompt     ;
       property Hint       :String  read FHint        write SetHint       ;
       property Version    :Integer read FVersion     write SetVersion    ;
       property Bitmap     :TBitMap read FBitmap      write SetBitmap     ;
       property Expanded   :Boolean read FExpanded    write SetExpanded   ;
       property ShowDetails:Boolean read FShowDetails write SetShowDetails;
       property PenColor   :TColor  read FPenColor    write SetPenColor;
       property VerColor   :TColor  read FVerColor    write SetVerColor;
       property ChamferSize:Integer read FChamferSize write FChamferSize;
       property Color;
       property ParentColor;
       property Font;
       property ParentFont;
  end;              
  TForm1 = class(TForm)
    CompInspector1: TCompInspector;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{TIDSGroup}
constructor TIDSGroup.Create(Owner:TComponent);
begin
   inherited Create(Owner);
   FPenColor   :=clBlack;
   FVerColor   :=clGray;   
   FExpanded   :=False;
   Color:=clWindow;
   FShowDetails:=False;
   FName   :='AGroup';
   FTitle  :='A Group of Products';
   FPrompt :='Prompt for Group of Products';
   FHint   :='Hint For A Group of Products^Placed on two lines in the User Interface';
   FBitmap :=nil;
   FVersion:=1;
   FChildren:=TList.Create;
   FGroupParent:=nil;
   Width:=120;
   Height:=80;
   ChamferSize:=15;
end;
destructor TIDSGroup.Destroy;
var
   I:Integer;
begin
   if FChildren <> nil then
      for I:=0 to ChildCount-1 do Child[I].Free;
   FChildren.Free;
   FChildren:=nil;
   inherited Destroy; 
end;
procedure TIDSGroup.Paint;
var
   DR:TRect;
   S:String;
   W,H:Integer;
   XOfs,YOfs,YStep:Integer;
begin
   Canvas.Brush.Color:=Color;
   Canvas.Pen.Color:=PenColor;
   Canvas.Font:=Font;
   if FShowDetails then
      W:=(Width div 3)-1
   else
      W:=Width-1;
   H:=Height-1;
   with Canvas do
   begin
      if FShowDetails then
      begin
         XOfs:=W+ChamferSize div 2;
         YOfs:=Height div 10;
         YStep:=Height div 5;
         Rectangle(W-ChamferSize,0,Width,Height);
         DR:=Rect(XOfs,YOfs,Width-ChamferSize div 2,YOfs+TextHeight('Wg')); Inc(YOfs,YStep);
         DrawText(Canvas.Handle,PChar(Name),Length(Name),DR,DT_LEFT);
         DR:=Rect(XOfs,YOfs,Width-ChamferSize div 2,YOfs+TextHeight('Wg')); Inc(YOfs,YStep);
         DrawText(Canvas.Handle,PChar(Title),Length(Title),DR,DT_LEFT);
         DR:=Rect(XOfs,YOfs,Width-ChamferSize div 2,YOfs+TextHeight('Wg')); Inc(YOfs,YStep);
         DrawText(Canvas.Handle,PChar(Prompt),Length(Prompt),DR,DT_LEFT);
         DR:=Rect(XOfs,YOfs,Width-ChamferSize div 2,YOfs+TextHeight('Wg'));
         DrawText(Canvas.Handle,PChar(Hint),Length(Hint),DR,DT_LEFT);
      end;
      PolyGon([Point(ChamferSize,0),
               Point(W-ChamferSize,0),
               Point(W,ChamferSize),
               Point(W,H-ChamferSize),
               Point(W-ChamferSize,H),
               Point(ChamferSize,H),
               Point(0,H-ChamferSize),
               Point(0,ChamferSize),
               Point(ChamferSize,0)]);
      PolyLine([Point(0,ChamferSize+1),Point(W,ChamferSize+1)]);
      DR:=Bounds(0,0,W,ChamferSize);
      Font.Style:=[fsBold];
      S:=Name+' '+IntToStr(FVersion);
      DrawText(Canvas.Handle,PChar(S),Length(S),DR,DT_CENTER or DT_CALCRECT);
      DR:=Bounds((((W-ChamferSize*2)-DR.Right) div 2)+ChamferSize,1,DR.Right,ChamferSize);
      DrawText(Canvas.Handle,PChar(S),Length(S),DR,DT_LEFT);
      S:=IntToStr(FVersion);
      Canvas.Font.Color:=FVerColor;
      DrawText(Canvas.Handle,PChar(S),Length(S),DR,DT_RIGHT);
      Canvas.Font.Color:=Self.Font.Color;
      Font.Color:=clBlack;
      DR:=Bounds(1,ChamferSize+2,W-2,(H-ChamferSize)-2);
      Font.Style:=[];
      DrawText(Canvas.Handle,PChar(Title),Length(Title),DR,DT_WORDBREAK or DT_CENTER);
   end;                  
end;
procedure TIDSGroup.SetGroupName(Value:String);
begin
   if FName <> Value then
   begin
      FName:=Value;
      Invalidate;
   end;
end;
procedure TIDSGroup.SetTitle(Value:String);
begin
   if FTitle <> Value then
   begin
      FTitle:=Value;
      Invalidate;
   end;
end;
procedure TIDSGroup.SetPrompt(Value:String);
begin
   if FPrompt <> Value then
   begin
      FPrompt:=Value;
      Invalidate;
   end;
end;
procedure TIDSGroup.SetHint(Value:String);
begin
   if FHint <> Value then
   begin
      FHint:=Value;
      Invalidate;
   end;
end;
procedure TIDSGroup.SetVersion(Value:Integer);
begin
   if FVersion <> Value then
   begin
      FVersion:=Value;
      Invalidate;
   end;
end;
procedure TIDSGroup.SetBitmap(Value:TBitMap);
begin
   if FBitMap <> Value then
   begin
      FBitMap:=Value;
      Invalidate;
   end;
end;
procedure TIDSGroup.SetVerColor(Value:TColor);
begin
   if FVerColor <> Value then
   begin
      FVerColor:=Value;
      Invalidate;
   end;
end;
procedure TIDSGroup.SetPenColor(Value:TColor);
begin
   if FPenColor <> Value then
   begin
      FPenColor:=Value;
      Invalidate;
   end;
end;
procedure TIDSGroup.SetExpanded(Value:Boolean);
begin
   if FExpanded <> Value then
   begin
      FExpanded:=Value;
      Invalidate;
   end;
end;
procedure TIDSGroup.SetShowDetails(Value:Boolean);
begin
   if FShowDetails <> Value then
   begin
      FShowDetails:=Value;
      if FShowDetails then Width:=Width*3 else Width:=Width div 3;
      Invalidate;
   end;
end;
procedure TIDSGroup.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   inherited MouseDown(Button,Shift,X,Y);
   if Button = mbRight then ShowDetails:=not ShowDetails;
end;
procedure TIDSGroup.MouseMove(Shift:TShiftState;X,Y:Integer);
begin
   inherited MouseMove(Shift,X,Y);
end;
procedure TIDSGroup.MouseUp(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   inherited MouseUp(Button,Shift,X,Y);
end;                   
function TIDSGroup.GetChildCount:Integer;
begin
   if FChildren <> nil then
      Result:=FChildren.Count
   else
      Result:=0;
end;
function TIDSGroup.GetChild(Index:Integer):TIDSGroup;
begin
   if (FChildren <> nil) and (Index > 0) and (Index < FChildren.Count) then
      Result:=FChildren[Index]
   else
      Result:=nil;
end;
function TIDSGroup.AddChild(Value:TIDSGroup):Integer;
begin
   if FChildren <> nil then
      Result:=FChildren.Add(Value)
   else
      Result:=-1;
end;
function TIDSGroup.IndexOf(Value:TIDSGroup):Integer;
begin
   if (FChildren <> nil) then
      Result:=FChildren.IndexOf(Value)
   else
      Result:=-1;
end;            
procedure TIDSGroup.Delete(Index:Integer);
begin
   if (FChildren <> nil) and (Index > 0) and (Index < FChildren.Count) then
      FChildren.Delete(Index);
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   Group:TIDSGroup;
begin
   Group:=TIDSGroup.Create(nil);
   Group.Parent:=Self;
   Group.Left:=X;
   Group.Top:=Y;
   Group.Color:=clWindow;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   CompInspector1.Add('Name'    ,itString,'GroupName');
   CompInspector1.Add('Caption' ,itString,'Group Caption');
   CompInspector1.Add('Prompt'  ,itString,'Group Prompt');
   CompInspector1.Add('Hint'    ,itString,'Group Hint');
   CompInspector1.Add('Picture' ,itBitmap,BMPRes00+BMPRes01+BMPRes02+BMPRes03+BMPRes04+BMPRes05+BMPRes06+BMPRes07+BMPRes08+BMPRes09+BMPRes0A+BMPRes0B);
   CompInspector1.Add('Version' ,itInteger,'1');
   CompInspector1.Add('',itString,'');
   CompInspector1.Add('Product 1',itString,'');
   CompInspector1.Add('Product 2',itString,'');
   CompInspector1.Add('Product 3',itString,'');
   CompInspector1.Add('Product 4',itString,'');
   CompInspector1.Add('Product 5',itString,'');
   CompInspector1.Add('Product 6',itString,'');
   CompInspector1.Add('Product 7',itString,'');
   CompInspector1.Add('Product 8',itString,'');
   CompInspector1.Add('Product 9',itString,'');
   CompInspector1.Add('Product 10',itString,'');
//   CompInspector1.AutoSize;
end;

end.
 