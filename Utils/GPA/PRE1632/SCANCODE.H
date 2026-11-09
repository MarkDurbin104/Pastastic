// PUBLIC SYMBOLS S
#define LSHIFT      0x01
#define RSHIFT      0x02
#define CTRL        0x04
#define ALT         0x08
#define CAPSL       0x10
#define NUML        0x20
#define SCROLLL     0x40
#define INSL        0x80

#define EXTENDED    0xE0
// PUBLIC SYMBOLS E
/*

INT scanmap[]= {
// NORM   SHFT   CTRL   ALT   CAPS/NUM
  0    , 0    , 0    , 0    , 0 ,       //   00  
  ESC  , SESC , CESC , AESC , 0 ,       //   01  
  '1'  , '!'  , '1'  , ALT1 , 0 ,       //   02  
  '2'  , '@'  , '2'  , ALT2 , 0 ,       //   03  
  '3'  , '#'  , '3'  , ALT3 , 0 ,       //   04  
  '4'  , '$'  , '4'  , ALT4 , 0 ,       //   05  
  '5'  , '%'  , '5'  , ALT5 , 0 ,       //   06  
  '6'  , '^'  , '6'  , ALT6 , 0 ,       //   07  
  '7'  , '&'  , '7'  , ALT7 , 0 ,       //   08  
  '8'  , '*'  , '8'  , ALT8 , 0 ,       //   09  
  '9'  , '('  , '9'  , ALT9 , 0 ,       //   0A  
  '0'  , ')'  , '0'  , ALT0 , 0 ,       //   0B  
  '-'  , '_'  , '-'  , '-'  , 0 ,       //   0C  
  '='  , '+'  , '='  , '='  , 0 ,       //   0D  
  BKSP , SBKSP, BKSP , BKSP , 0 ,       //   0E  
  TAB  , STAB , CTAB , ATAB , 0 ,       //   0F  
  'q'  , 'Q'  , CTRLQ, ALTQ , 1 ,       //   10  
  'w'  , 'W'  , CTRLW, ALTW , 1 ,       //   11  
  'e'  , 'E'  , CTRLE, ALTE , 1 ,       //   12  
  'r'  , 'R'  , CTRLR, ALTR , 1 ,       //   13  
  't'  , 'T'  , CTRLT, ALTT , 1 ,       //   14  
  'y'  , 'Y'  , CTRLY, ALTY , 1 ,       //   15  
  'u'  , 'U'  , CTRLU, ALTU , 1 ,       //   16  
  'i'  , 'I'  , CTRLI, ALTI , 1 ,       //   17  
  'o'  , 'O'  , CTRLO, ALTO , 1 ,       //   18  
  'p'  , 'P'  , CTRLP, ALTP , 1 ,       //   19  
  '['  , '{'  , '['  , '['  , 0 ,       //   1A  
  ']'  , '}'  , ']'  , ']'  , 0 ,       //   1B  
  CR   , SCR  , CCR  , ACR  , 0 ,       //   1C  
  KCTRL, KCTRL, KCTRL, KCTRL, 0 ,       //   1D
  'a'  , 'A'  , CTRLA, ALTA , 1 ,       //   1E  
  's'  , 'S'  , CTRLS, ALTS , 1 ,       //   1F  
  'd'  , 'D'  , CTRLD, ALTD , 1 ,       //   20  
  'f'  , 'F'  , CTRLF, ALTF , 1 ,       //   21  
  'g'  , 'G'  , CTRLG, ALTG , 1 ,       //   22  
  'h'  , 'H'  , CTRLH, ALTH , 1 ,       //   23  
  'j'  , 'J'  , CTRLJ, ALTJ , 1 ,       //   24  
  'k'  , 'K'  , CTRLK, ALTK , 1 ,       //   25  
  'l'  , 'L'  , CTRLL, ALTL , 1 ,       //   26  
  ';'  , ':'  , ';'  , ';'  , 0 ,       //   27  
  '\'' , '\"' , '\'' , '\'' , 0 ,       //   28  
  '`'  , '~'  , '`'  , '`'  , 0 ,       //   29  
  KLSFT, KLSFT, KLSFT, KLSFT, 0 ,       //   2A
  '\\' , '|'  , '\\' , '\\' , 0 ,       //   2B  
  'z'  , 'Z'  , CTRLZ, ALTZ , 1 ,       //   2C  
  'x'  , 'X'  , CTRLX, ALTX , 1 ,       //   2D  
  'c'  , 'C'  , CTRLC, ALTC , 1 ,       //   2E  
  'v'  , 'V'  , CTRLV, ALTV , 1 ,       //   2F  
  'b'  , 'B'  , CTRLB, ALTB , 1 ,       //   30  
  'n'  , 'N'  , CTRLN, ALTN , 1 ,       //   31  
  'm'  , 'M'  , CTRLM, ALTM , 1 ,       //   32  
  ','  , '<'  , ','  , ','  , 0 ,       //   33  
  '.'  , '>'  , '.'  , '.'  , 0 ,       //   34  
  '/'  , '?'  , '/'  , '/'  , 0 ,       //   35  
  KRSFT, KRSFT, KRSFT, KRSFT, 0 ,       //   36
  '*'  , '*'  , '*'  , '*'  , 0 ,       //   37  
  KALT , KALT , KALT , KALT , 0 ,       //   38
  ' '  , ' '  , ' '  , ' '  , 0 ,       //   39  
  KCAPL, KCAPL, KCAPL, KCAPL, 0 ,       //   3A
  F01  , SF01 , CF01 , AF01 , 0 ,       //   3B  
  F02  , SF02 , CF02 , AF02 , 0 ,       //   3C  
  F03  , SF03 , CF03 , AF03 , 0 ,       //   3D  
  F04  , SF04 , CF04 , AF04 , 0 ,       //   3E  
  F05  , SF05 , CF05 , AF05 , 0 ,       //   3F  
  F06  , SF06 , CF06 , AF06 , 0 ,       //   40  
  F07  , SF07 , CF07 , AF07 , 0 ,       //   41  
  F08  , SF08 , CF08 , AF08 , 0 ,       //   42  
  F09  , SF09 , CF09 , AF09 , 0 ,       //   43  
  F10  , SF10 , CF10 , AF10 , 0 ,       //   44  
  KNUML, KNUML, KNUML, KNUML, 0 ,       //   45
  KSCRL, KSCRL, KSCRL, KSCRL, 0 ,       //   46
  HOME , '7'  , CHOME, AHOME, 2 ,       //   47  
  UP   , '8'  , CUP  , AUP  , 2 ,       //   48  
  PGUP , '9'  , CPGUP, APGUP, 2 ,       //   49  
  '-'  , '-'  , '-'  , '-'  , 2 ,       //   4A  
  LEFT , '4'  , CLEFT, ALEFT, 2 ,       //   4B  
  0    , '5'  , 0    , 0    , 2 ,       //   4C  
  RGT  , '6'  , CRGT , ARGT , 2 ,       //   4D  
  '+'  , '+'  , '+'  , '+'  , 2 ,       //   4E  
  END  , '1'  , CEND , AEND , 2 ,       //   4F  
  DOWN , '2'  , CDOWN, ADOWN, 2 ,       //   50  
  PGDN , '3'  , CPGDN, APGDN, 2 ,       //   51  
  INS  , '0'  , CINS , AINS , 2 ,       //   52  
  DEL  , '.'  , CDEL , ADEL , 2 ,       //   53  
  0    , 0    , 0    , 0    , 0 ,       //   54  
  0    , 0    , 0    , 0    , 0 ,       //   55  
  '\\' , '|'  , '\\' , '\\' , 0 ,       //   56  
  F11  , SF11 , CF11 , AF11 , 0 ,       //   57  
  F12  , SF12 , CF12 , AF12 , 0 ,       //   58  
  0    , 0    , 0    , 0    , 0 ,       //   59  
  0    , 0    , 0    , 0    , 0 ,       //   5A  
  0    , 0    , 0    , 0    , 0 ,       //   5B  
  0    , 0    , 0    , 0    , 0 ,       //   5C  
  0    , 0    , 0    , 0    , 0 ,       //   5D  
  0    , 0    , 0    , 0    , 0 ,       //   5E  
  0    , 0    , 0    , 0    , 0 ,       //   5F  
  0    , 0    , 0    , 0    , 0 ,       //   60  
  0    , 0    , 0    , 0    , 0 ,       //   61  
  0    , 0    , 0    , 0    , 0 ,       //   62  
  0    , 0    , 0    , 0    , 0 ,       //   63  
  0    , 0    , 0    , 0    , 0 ,       //   64  
  0    , 0    , 0    , 0    , 0 ,       //   65  
  0    , 0    , 0    , 0    , 0 ,       //   66  
  0    , 0    , 0    , 0    , 0 ,       //   67  
  0    , 0    , 0    , 0    , 0 ,       //   68  
  0    , 0    , 0    , 0    , 0 ,       //   69  
  0    , 0    , 0    , 0    , 0 ,       //   6A  
  0    , 0    , 0    , 0    , 0 ,       //   6B  
  0    , 0    , 0    , 0    , 0 ,       //   6C  
  0    , 0    , 0    , 0    , 0 ,       //   6D  
  0    , 0    , 0    , 0    , 0 ,       //   6E  
  0    , 0    , 0    , 0    , 0 ,       //   6F  
  0    , 0    , 0    , 0    , 0 ,       //   70  
  0    , 0    , 0    , 0    , 0 ,       //   71  
  0    , 0    , 0    , 0    , 0 ,       //   72  
  0    , 0    , 0    , 0    , 0 ,       //   73  
  0    , 0    , 0    , 0    , 0 ,       //   74  
  0    , 0    , 0    , 0    , 0 ,       //   75  
  0    , 0    , 0    , 0    , 0 ,       //   76  
  0    , 0    , 0    , 0    , 0 ,       //   77  
  0    , 0    , 0    , 0    , 0 ,       //   78  
  0    , 0    , 0    , 0    , 0 ,       //   79  
  0    , 0    , 0    , 0    , 0 ,       //   7A  
  0    , 0    , 0    , 0    , 0 ,       //   7B  
  0    , 0    , 0    , 0    , 0 ,       //   7C  
  0    , 0    , 0    , 0    , 0 ,       //   7D  
  0    , 0    , 0    , 0    , 0 ,       //   7E  
  0    , 0    , 0    , 0    , 0 ,       //   7F  
};
*/


