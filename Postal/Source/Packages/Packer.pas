unit Packer;

interface
//    00000000001111111111222222222233
//    01234567890123456789012345678901
// 0  abcdefghijklmnopqrstuzwxyz ,";12
// 1  ABCDEFGHIJKLMNOPQRSTUVWXYZ ?':02
// 2  0123456789.!*+-=_@(){}[]<> \/301
// 3  £$%~¦|^#&abcdefghijklmnopqrst012
const
   CharBufs:Array[0..3,0..31] of Char = (
     ( 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','z','w','x','y','z',' ',',','"' ,';',#22,#23 ),
     ( 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',' ','?','''',':',#21,#23 ),
     ( '0','1','2','3','4','5','6','7','8','9','.','!','*','+','-','=','_','@','(',')','{','}','[',']','<','>',' ','\','/' ,#24,#21,#22 ),
     ( '£','$','%','~','¦','|','^','#','&', #1, #2, #3, #4, #5, #6, #7, #8, #9,#10,#11,#12,#13,#14,#15,#16,#17,#18,#19,#20 ,#21,#22,#23 ));
   
implementation

function PackString(Value:String):String;
begin
end;
function UnPackString(Value:String):String;
begin
end;

end.
