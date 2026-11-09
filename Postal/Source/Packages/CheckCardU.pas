unit CheckCardU;

interface

uses
   SysUtils;
   
type
   TCardType = ( ctInvalid,ctUnknown,ctMasterC,ctBarclay,ctDelta,ctVisaPurc,
                 ctElectron,ctMaestro,ctSwitch,ctSolo,ctVisaExcp,ctVisa );
const
   MaxCardRange = 107;
   
   CardTypeRange:Array[0..MaxCardRange,0..2] of Integer = (
      (510000,559999,Integer(ctMasterC )),(492800,492899,Integer(ctBarclay )),
      (413733,413737,Integer(ctDelta   )),(465830,465879,Integer(ctDelta   )),
      (415932,415932,Integer(ctDelta   )),(465901,465950,Integer(ctDelta   )),
      (446200,446299,Integer(ctDelta   )),(490960,490979,Integer(ctDelta   )),
      (453978,453979,Integer(ctDelta   )),(492181,492182,Integer(ctDelta   )),
      (454313,454313,Integer(ctDelta   )),(498824,498824,Integer(ctDelta   )),
      (454432,454435,Integer(ctDelta   )),(454742,454742,Integer(ctDelta   )),
      (456725,456745,Integer(ctDelta   )),(448400,448699,Integer(ctVisaPurc)),
      (471500,471599,Integer(ctVisaPurc)),(450875,450875,Integer(ctElectron)),
      (484406,484455,Integer(ctElectron)),(491730,491759,Integer(ctElectron)),
      (491880,491880,Integer(ctElectron)),(300000,300000,Integer(ctMaestro )),
      (311079,311079,Integer(ctMaestro )),(367000,367000,Integer(ctMaestro )),
      (500000,509999,Integer(ctMaestro )),(560000,569999,Integer(ctMaestro )),
      (570000,579999,Integer(ctMaestro )),(580000,589999,Integer(ctMaestro )),
      (590000,599999,Integer(ctMaestro )),(600000,609999,Integer(ctMaestro )),
      (490302,490309,Integer(ctSwitch  )),(490335,490339,Integer(ctSwitch  )),
      (491101,491102,Integer(ctSwitch  )),(491174,491182,Integer(ctSwitch  )),
      (493600,493699,Integer(ctSwitch  )),(564182,564182,Integer(ctSwitch  )),
      (633300,633300,Integer(ctSwitch  )),(633301,633301,Integer(ctSwitch  )),
      (633302,633349,Integer(ctSwitch  )),(675900,675900,Integer(ctSwitch  )),
      (675901,675901,Integer(ctSwitch  )),(675902,675904,Integer(ctSwitch  )),
      (675905,675905,Integer(ctSwitch  )),(675906,675917,Integer(ctSwitch  )),
      (675918,675918,Integer(ctSwitch  )),(675919,675937,Integer(ctSwitch  )),
      (675938,675940,Integer(ctSwitch  )),(675941,675949,Integer(ctSwitch  )),
      (675950,675962,Integer(ctSwitch  )),(675963,675997,Integer(ctSwitch  )),
      (675998,675998,Integer(ctSwitch  )),(675999,675999,Integer(ctSwitch  )),
      (633450,633453,Integer(ctSolo    )),(633454,633457,Integer(ctSolo    )),
      (633458,633460,Integer(ctSolo    )),(633461,633461,Integer(ctSolo    )),
      (633462,633472,Integer(ctSolo    )),(633473,633473,Integer(ctSolo    )),
      (633474,633475,Integer(ctSolo    )),(633476,633476,Integer(ctSolo    )),
      (633477,633477,Integer(ctSolo    )),(633478,633478,Integer(ctSolo    )),
      (633479,633480,Integer(ctSolo    )),(633481,633481,Integer(ctSolo    )),
      (633482,633489,Integer(ctSolo    )),(633490,633493,Integer(ctSolo    )),
      (633494,633494,Integer(ctSolo    )),(633495,633497,Integer(ctSolo    )),
      (633498,633498,Integer(ctSolo    )),(633499,633499,Integer(ctSolo    )),
      (676700,676700,Integer(ctSolo    )),(676701,676701,Integer(ctSolo    )),
      (676702,676702,Integer(ctSolo    )),(676703,676703,Integer(ctSolo    )),
      (676704,676704,Integer(ctSolo    )),(676705,676705,Integer(ctSolo    )),
      (676706,676707,Integer(ctSolo    )),(676708,676711,Integer(ctSolo    )),
      (676712,676715,Integer(ctSolo    )),(676716,676717,Integer(ctSolo    )),
      (676718,676718,Integer(ctSolo    )),(676719,676739,Integer(ctSolo    )),
      (676740,676740,Integer(ctSolo    )),(676741,676749,Integer(ctSolo    )),
      (676750,676762,Integer(ctSolo    )),(676763,676769,Integer(ctSolo    )),
      (676770,676770,Integer(ctSolo    )),(676771,676773,Integer(ctSolo    )),
      (676774,676774,Integer(ctSolo    )),(676775,676778,Integer(ctSolo    )),
      (676779,676779,Integer(ctSolo    )),(676780,676781,Integer(ctSolo    )),
      (676782,676782,Integer(ctSolo    )),(676783,676794,Integer(ctSolo    )),
      (676795,676795,Integer(ctSolo    )),(676796,676797,Integer(ctSolo    )),
      (676798,676798,Integer(ctSolo    )),(676799,676799,Integer(ctSolo    )),
      (490300,490399,Integer(ctVisaExcp)),(490400,490499,Integer(ctVisaExcp)),
      (490500,490599,Integer(ctVisaExcp)),(491100,491119,Integer(ctVisaExcp)),
      (491120,491199,Integer(ctVisaExcp)),(492183,492183,Integer(ctVisaExcp)),
      (493600,493699,Integer(ctVisaExcp)),(497014,497044,Integer(ctVisaExcp)),
      (498700,498799,Integer(ctVisaExcp)),(400000,499999,Integer(ctVisa    )));
                     
function CheckCardNo(CardNo:String):TCardType;

implementation
//------------------------------------------------------------------------------
// Function    | CheckCardNo
// Description | Check the CRC on a Card and try to determine it's type
// Parameters  | CardNo - the Card to check
// Result      | TCardType - 
//             |     ctInvalid = Bad Number
//             |     ctUnknown = Number OK, but unknown type
//             |     ctXxxxxxx = Card type + Good Number
//------------------------------------------------------------------------------
function CheckCardNo(CardNo:String):TCardType;
var                                 
   I:Integer;
   Weight:Integer;
   Total:Integer;
   ItemSum:Integer;
   CheckNumber:Integer;
begin
   Result:=ctInvalid;
   Weight:=1;
   Total:=0;
   CheckNumber:=StrToIntDef(Copy(CardNo,1,6),-1);
   if (CheckNumber > 0) then
   begin
      for I:=Length(CardNo) downto 1 do // Calc Card CRC 
      begin
         ItemSum:=(Ord(CardNo[I])-Ord('0'))*Weight;
         if ItemSum > 9 then Dec(ItemSum,9);
         Inc(Total,ItemSum);
         if Weight = 1 then Weight:=2 else Weight:=1;
      end;
      if (Total mod 10) = 0 then // valid CRC
      begin
         Result:=ctUnknown;
         for I:=0 to MaxCardRange do 
         begin
            if (CheckNumber >= CardTypeRange[I][0]) and (CheckNumber <= CardTypeRange[I][1]) then
            begin
               Result:=TCardType(CardTypeRange[I][2]);
               break;
            end;
         end;
         if Result = ctVisaExcp then
            Result:=ctUnknown;
      end;      
   end;      
end;

end.
