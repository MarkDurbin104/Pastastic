unit PadLines;

interface

uses
  StringUtil,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,GPCSGUID,PackStrListU,GPCSBase_TLB;

type
  TPadMode = (pmPick,pmHelp,pmForm,pmTrans,pmCols,pmInst,pmAcct);
  TPadLines = class(TGraphicControl)
  private
     FRightAnchor:Boolean;
     FCurrSymbol:String;
     CurrentLine:Integer;
     SavedLines:TPackStringList;
     AllLines:TPackStringList;
     FLineCount:Integer;
     FTopOffset:Integer;
     FFormOffset:Integer;
     FLineSpace:Integer;
     FPadMode:TPadMode;
     procedure SetLineCount(Value:Integer);
     procedure SetTopOffset(Value:Integer);
     procedure SetLineSpace(Value:Integer);
     procedure SetFormOffset(Value:Integer);
     procedure SetPadMode  (Value:TPadMode);
     procedure SetRightAnchor(Value:Boolean);
  public
     constructor Create(AOwner:TComponent); override;
     destructor Destroy; override;
     procedure Paint; override;
     function GetLines:String;
     procedure Clear;
     procedure SetLines(Value:String;InForm:Boolean);
     procedure SetLine (Value:String;Index:Integer);
     procedure Highlight(Index:Integer);
     procedure SavePadText;
     procedure RestorePadText;
  published
     property Font;
     property ParentFont;
     property LineCount:Integer  read FLineCount  write SetLineCount ;
     property TopOffset:Integer  read FTopOffset  write SetTopOffset ;
     property LineSpace:Integer  read FLineSpace  write SetLineSpace ;
     property FormOffset:Integer read FFormOffset write SetFormOffset;
     property PadMode  :TPadMode read FPadMode    write SetPadMode   ;
     property RightAnchor :Boolean  read FRightAnchor write SetRightAnchor;
  end;                 

procedure Register;

implementation
{TPadLines}
procedure TPadLines.SetRightAnchor(Value:Boolean);
begin
   if FRightAnchor <> Value then
   begin
      FRightAnchor:=Value;
      Invalidate;
   end;
end;
procedure TPadLines.SetPadMode(Value:TPadMode);
begin
   if FPadMode <> Value then
   begin
      FPadMode:=Value;
      Invalidate;
   end;
end;
procedure TPadLines.SetLineCount(Value:Integer);
begin
   if FLineCount <> Value then
   begin
      FLineCount:=Value;
      Invalidate;
   end;
end;
procedure TPadLines.SetTopOffset(Value:Integer);
begin
   if FTopOffset <> Value then
   begin
      FTopOffset:=Value;
      Invalidate;
   end;
end;
procedure TPadLines.SetFormOffset(Value:Integer);
begin
   if FFormOffset <> Value then
   begin
      FFormOffset:=Value;
      Invalidate;
   end;
end;
procedure TPadLines.SetLineSpace(Value:Integer);
begin
   if FLineSpace <> Value then
   begin
      FLineSpace:=Value;
      Invalidate;
   end;
end;
constructor TPadLines.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   //Tanzania 14/01/99
   FCurrSymbol:=GetGPCSRegString('','MoneySymbol','');
   CurrentLine:=0;           
   Width:=100;
   Height:=100;
   FLineCount:=10;
   FTopOffset:=0;
   FLineSpace:=40;
   SavedLines:=TPackStringList.Create;
   AllLines  :=TPackStringList.Create;
   FPadMode:=pmPick;
   if csDesigning in ComponentState then
   begin
//      AllLines.Add('0,0,"Line 01","g/$Q","SP 1","Data 1"');
//      AllLines.Add('0,0,"Line 02","g/$Q","Long Prompt 2","12345678901234567890123456789012345678901234567890"');
//      AllLines.Add('0,0,"Line 03","g/$Q","Prompt 3","Data 3"');
//      AllLines.Add('0,0,"Line 04","g/$Q","Prompt 4","Data 4"');
//      AllLines.Add('0,0,"Line 05","g/$Q","Prompt 5","Data 5"');
//      AllLines.Add('0,0,"Line 06","g/$Q","Prompt 6","Data 6"');
//      AllLines.Add('0,0,"Line 07","g/$Q","Prompt 7","Data 7"');
//      AllLines.Add('0,0,"Line 08","g/$Q","Prompt 8","Data 8"');
//      AllLines.Add('0,0,"Line 09","g/$Q","Prompt 9","Data 9"');
//      AllLines.Add('0,0,"Line 10","g/$Q","Prompt 10","Data 10"');
//      AllLines.Add('0,0,"Line 11","g/$Q","Prompt 11","Data 11"');
//      AllLines.Add('0,0,"Line 12","g/$Q","Prompt 12","Data 12"');
//      AllLines.Add('0,0,"Line 13","g/$Q","Prompt 13","Data 13"');
   end;
end;
destructor TPadLines.Destroy;
begin
   SavedLines.Free;
   AllLines  .Free;
   inherited Destroy;
end;
function StrToCurrDef(S:String;Default:Currency):Currency;
var
   I:Integer;
   V:String;
begin
   V:='';
   for I:=1 to Length(S) do if S[I] <> ',' then V:=V+S[I];
   try
      Result:=StrToCurr(V);
   except
      Result:=Default;
   end;
end;
function PadOut(Value:Integer):String;
begin
   Result:=IntToStr(Value+1);
   while Length(Result) < 3 do Result:=' '+Result;
   Result:=Result+' ';
end;
procedure OutputTabbedLine(Canvas:TCanvas;Width,Height,TOfs:Integer;Value:String);
var
   SL:TPackStringList;
   R:TRect;
   I:Integer;
   RXOfs,XOfs:Integer;
   Justify:Integer;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Value;
   Justify:=0;
   with Canvas do
   begin
      I:=0;
      XOfs:=0;
      while I < SL.Count do
      begin
         if (I and 1) = 0 then
         begin
            XOfs:=StrToIntDef(SL[I],0);
            if XOfs < 0 then
            begin
               Justify:=DT_RIGHT;
               XOfs:=0-XOfs;
            end
            else
            begin
               Justify:=0;
            end;
         end                
         else
         begin
            if I < SL.Count-1 then
               RXOfs:=Abs(StrToIntDef(SL[I+1],0))
            else
               RXOfs:=Width;
            R:=Bounds(XOfs,TOfs,RXOfs-XOfs,Height);
            DrawText(Handle,PChar(SL[I]),Length(SL[I]),R,Justify);
         end;
         Inc(I);
      end;
   end;
   SL.Free;
end;
procedure TPadLines.Paint;
var
   I,Ofs,ROfs:Integer;
   ControlRect : TRect;  //rectangle of control
   TempRect    : TRect;
   SL:TPackStringList;
   TxtRect:TRect;
   ControlText : String;
   Total,Value:Currency;
   DrawTextFormat : Integer;
   Locale:String;
   //Translator : ITranslate;
begin
   Canvas.Font:=Font;
   with Canvas do
   begin
      if csDesigning in ComponentState then
      begin
         Brush.Style:=bsClear;
         Rectangle(0,0,Width,Height);
      end;
      if not (FPadMode in [pmHelp, pmForm]) then
      begin
         Brush.Style:=bsSolid;
         Brush.Color:=clBlack;
         FillRect(Bounds(0,((CurrentLine-FTopOffset)*FLineSpace),Width,FLineSpace-3));
      end;
      Brush.Style:=bsClear;
      Locale:=IntToHex(GetThreadLocale,8);//GetCurrentLocale;
      case FPadMode of
         pmPick :
            begin
               //Only PickList can be align either right o left, dependeing on the language
               if (Locale='00000401') and FRightAnchor then SetTextAlign(Canvas.Handle,TA_RTLREADING or TA_RIGHT) ;

               for I:=0 to FLineCount-1 do
               begin
                  if CurrentLine = I+FTopOffset then Font.Color:=clWhite else Font.Color:=clBlack;
                  if AllLines.Count > (I+FTopOffset) then
                  begin
                     if Copy(AllLines[I+FTopOffset],1,1) = #1 then
                     begin
                        OutputTabbedLine(Canvas,Width,FLineSpace,I*FLineSpace,AllLines[I+FTopOffset]);
                     end
                     else if Copy(AllLines[I+FTopOffset],1,1) = '_' then
                     begin
                        if (Locale='00000401') and FRightAnchor  then
                           TextOut(Width,I*FLineSpace,Copy(AllLines[I+FTopOffset],2,9999))
                        else
                           TextOut(0,I*FLineSpace,PadOut(I+FTopOffset)+Copy(AllLines[I+FTopOffset],2,9999));
                     end
                     else
                     begin
                        if (Locale='00000401') and FRightAnchor  then
                           TextOut(Width,I*FLineSpace,AllLines[I+FTopOffset])
                        else
                           TextOut(0,I*FLineSpace,PadOut(I+FTopOffset)+AllLines[I+FTopOffset]);
                     end;
                  end;
               end;
            end;
         pmHelp :
            begin
               if FRightAnchor then SetTextAlign(Canvas.Handle,TA_RTLREADING or TA_LEFT);
               Font.Color:=clWhite;
               for I:=0 to FLineCount-1 do
               begin
                  if AllLines.Count > (I+FTopOffset) then
                  begin
                     TextOut((Width-TextWidth(AllLines[I+FTopOffset])) div 2,I*FLineSpace,AllLines[I+FTopOffset]);
                  end;
               end;
            end;
         pmCols :
            begin
               if FRightAnchor then SetTextAlign(Canvas.Handle,TA_RTLREADING or TA_RIGHT);
               SL:=TPackStringList.Create;
               for I:=0 to FLineCount-1 do
               begin
                  if AllLines.Count > (I+FTopOffset) then
                  begin
                     if CurrentLine = I+FTopOffset then Font.Color:=clWhite else Font.Color:=clBlack;
                     SL.PackText:=AllLines[I+FTopOffset];
                     if SL.Count > 3 then
                     begin
                        Ofs:=I*FLineSpace;
                        TextOut(0  ,Ofs,SL[0]);
                        TextOut(340,Ofs,SL[1]);
                        TextOut(390,Ofs,SL[2]);
                        TextOut(584,Ofs,SL[3]);
                     end
                     else
                     begin
                        if FRightAnchor then
                           TextOut(Width-TextWidth(AllLines[I+FTopOffset]),I*FLineSpace,AllLines[I+FTopOffset])
                        else
                           TextOut(0,I*FLineSpace,AllLines[I+FTopOffset]);
                     end;
                  end;
               end;
               SL.Free;
            end;
         pmForm :
            begin
               if (Locale='00000401') and FRightAnchor then SetTextAlign(Canvas.Handle,TA_RTLREADING or TA_RIGHT)
               else
                  if FRightAnchor then SetTextAlign(Canvas.Handle, TA_RIGHT);
               SL:=TPackStringList.Create;
               ControlRect := Bounds(0,0,Width,0);
               for I:=0 to FLineCount+1 do
               begin
                  //have a control to display
                  if AllLines.Count > (I+FTopOffset) then
                  begin
                     SL.PackText:=AllLines[I+FTopOffset];
                     DrawTextFormat := 0;
                          If SL[2] = 'L' then ControlRect.Bottom := ControlRect.Top + FLineSpace * 1  //combo
                     else if SL[2] = 'M' then ControlRect.Bottom := ControlRect.Top + FLineSpace * 1  //mask edit
                     else if SL[2] = 'E' then
                     begin
                      ControlRect.Bottom := ControlRect.Top + FLineSpace * 3; //memo
                      DrawTextFormat := DT_WORDBREAK;
                     end;
                    //brush for selection or dividing line
                    Brush.Style:=bsSolid;
                    Brush.Color:=clBlack;

                    //line selected
                    if CurrentLine = I+FTopOffset then
                    begin
                      Font.Color:=clWhite;
                      if FPadMode <> pmHelp then
                      begin
                         //FillRect(Bounds(0,((CurrentLine-FTopOffset)*FLineSpace),Width,FLineSpace-3));
                         FillRect(ControlRect);
                      end;
                    end
                    else
                    begin
                      Font.Color:=clBlack;
                      //dividing line
                      FillRect(Rect(ControlRect.Left, ControlRect.Bottom-3, ControlRect.Right, ControlRect.Bottom));
                    end;
                    Brush.Style:=bsClear;

                     if SL[0] = '0' then  //read only control
                     begin
                        Font.Color:=clBlack;
                        Brush.Style:=bsSolid;
                        Brush.Color:=RGB(240,224,174);
                                                //FillRect(Bounds(            0,    I*FLineSpace,         FFormOffset+1, FLineSpace-3));
                        FillRect(Bounds(              0, ControlRect.Top,         FFormOffset+1, ControlRect.Bottom - ControlRect.Top-3));
                        //FillRect(Bounds(FFormOffset+4,    I*FLineSpace, Width-(FFormOffset+4), FLineSpace-3));
                        FillRect(Bounds(  FFormOffset+4, ControlRect.Top, Width-(FFormOffset+4), ControlRect.Bottom - ControlRect.Top-3));
                        Brush.Style:=bsClear;
                     end;
                     //handle password domains
                     if (SL.Count>8) and (LeftOf(SL[8],'Password')) then
                       SL[5] := LeftPad('', Length(SL[5]), '*');

                     if FRightAnchor then
                     begin
                        TextOut(FFormOffset-10,ControlRect.Top,SL[5]);
                        TextOut((FFormOffset+TextWidth(SL[4]))+10,ControlRect.Top,SL[4]);
                     end
                     else
                     begin
                        {TextOut((FFormOffset-TextWidth(SL[4]))-10,ControlRect.Top,SL[4]);
                        TextOut(FFormOffset+10,ControlRect.Top,SL[5]);
                        }
                        ControlText := SL[4]; //prompt label
                        TempRect := Rect(ControlRect.Left, ControlRect.Top, FFormOffset-10,ControlRect.Bottom);
                        DrawText( Canvas.Handle, PChar(ControlText), -1,
                                  TempRect,
                                  DT_RIGHT	);
                        ControlText := SL[5];
                        TempRect := Rect(FFormOffset + 10, ControlRect.Top, ControlRect.Right+10,ControlRect.Bottom);
                        DrawText( Canvas.Handle, PChar(ControlText), -1,
                        TempRect,
                        DrawTextFormat	);

                     end;
                     ControlRect.Top := ControlRect.Bottom;
                  end;
               end;
               SL.Free;
               //Translator:=nil;
            end;
         pmAcct :
            begin
               if FRightAnchor then SetTextAlign(Canvas.Handle,TA_RTLREADING or TA_RIGHT);
               Font.Name:='Courier New';
               SL:=TPackStringList.Create;
               for I:=0 to FLineCount-1 do
               begin
                  if AllLines.Count > (I+FTopOffset) then
                  begin
                     SL.CommaText:=AllLines[I+FTopOffset];
                     if CurrentLine = I+FTopOffset then
                     begin
                        Font.Color:=clWhite;
                        Brush.Color:=clBlack;
                     end
                     else
                     begin
                        Brush.Color:=clWhite;
                        Font.Color:=clNavy;
                     end;

                     ROfs:=468;
                     Ofs:=I*FLineSpace;
                     if FRightAnchor then
                     begin
                        FillRect(Bounds(0,I*FLineSpace,Width-(ROfs+4),FLineSpace-3));
                        FillRect(Bounds(Width-(ROfs),I*FLineSpace,ROfs,FLineSpace-3));
                        TextOut(Width,Ofs,SL[0]);
                        TextOut(Width-(ROfs+4),Ofs,SL[1]);
                     end
                     else
                     begin
                        FillRect(Bounds(0,I*FLineSpace,ROfs,FLineSpace-3));
                        FillRect(Bounds(ROfs+4,I*FLineSpace,Width-(ROfs+4),FLineSpace-3));
                        ROfs:=Width-TextWidth(SL[1]);
                        TextOut(ROfs,Ofs,SL[1]);
                        TextOut(0,Ofs,SL[0]);
                     end;

                  end;
               end;
               Font.Name:='Arial';
               SL.Free;
            end;
         pmTrans :
            begin
               SL:=TPackStringList.Create;
               Total:=0;
               for I:=0 to AllLines.Count-1 do
               begin
                  SL.PackText:=AllLines[I];
                  if SL.Count > 4 then
                  begin
                     Value:=StrToCurrDef(SL[4],0);
                     Total:=Total+Value;
                  end;
               end;
               Total:=ApplyRounding(Total);
               for I:=0 to FLineCount-1 do
               begin
//                  Font.Color:=clBlack;
                  if AllLines.Count > (I+FTopOffset) then
                  begin
                     SL.PackText:=AllLines[I+FTopOffset];
                     if SL.Count > 5 then
                     begin
                        if SL[0] = '0' then
                        begin
                           if CurrentLine = I+FTopOffset then
                           begin
                              Font.Color:=clWhite;
                              Brush.Color:=clBlack;
                           end
                           else if SL[5] = '0' then
                           begin
                              Font.Color:=clBlack;
                              Brush.Color:=RGB(255,239,189);
                           end
                           else
                           begin
                              Font.Color:=clBlack;
                              Brush.Color:=RGB(240,224,174);
                           end;
                        end;
                        FillRect(Bounds(3,I*FLineSpace,Width,FLineSpace));
//                        Value:=StrToIntDef(SL[4],0);
//                        if Value < 0 then SL[4]:=IntToStr(0-Value);
                        Ofs:=I*FLineSpace;
                        if StrToCurrDef(Trim(SL[4]),0) <> 0 then // has Value
                        begin
                          if FRightAnchor then
                          begin
                            SetTextAlign(Canvas.Handle,TA_RTLREADING or TA_RIGHT);
                            ROfs:=20+TextWidth('=99999999999');
                            TextOut(ROfs,Ofs,SL[4]);
                          end
                          else
                          begin
                            ROfs:=620-TextWidth(SL[4]);
                            TextOut(ROfs,Ofs,SL[4]);
                          end;
                        end;  //if value <> 0
                        if StrToIntDef(Trim(SL[2]),0) > 1 then // has Qty
                        begin
                          if FRightAnchor then
                          begin
                             ROfs:=20+TextWidth('=99999999999');
                             if StrToCurrDef(Trim(SL[3]),0) <> 0 then // has Price
                             begin
                               TextOut(ROfs,Ofs,'=');
                               ROfs:=20+TextWidth(SL[3]+'=99999999999');
                               TextOut(ROfs,Ofs,SL[3]);
                             end;
                             ROfs:=20+TextWidth('x99999999=99999999999');
                             TextOut(ROfs,Ofs,'x');
                             Dec(ROfs,TextWidth(SL[2]));
                             TextOut(ROfs,Ofs,SL[2]);
                          end
                          else
                          begin
                             ROfs:=620-TextWidth('=99999999999');
                             if StrToCurrDef(Trim(SL[3]),0) <> 0 then // has Price
                             begin
                               TextOut(ROfs,Ofs,'=');
                               ROfs:=620-TextWidth(SL[3]+'=99999999999');
                               TextOut(ROfs,Ofs,SL[3]);
                             end;
                             ROfs:=620-TextWidth('x99999999=99999999999');
                             TextOut(ROfs,Ofs,'x');
                             Dec(ROfs,TextWidth(SL[2]));
                             TextOut(ROfs,Ofs,SL[2]);
                          end;
                        end;  //if qty > 1
                        if FRightAnchor then
                        begin
                           SetTextAlign(Canvas.Handle,TA_RTLREADING or TA_RIGHT);
                           if SL.Count > 6 then
                              TextOut(Width-30,Ofs,SL[1]+' '+SL[6])
                           else
                              TextOut(Width-30,Ofs,SL[1]);
                        end
                        else
                        begin
                           if SL.Count > 6 then
                              TextOut(30  ,Ofs,SL[1]+' '+SL[6])
                           else
                              TextOut(30  ,Ofs,SL[1]);
                        end;
                     end; //line formed correctly
                  end
                  else  //
                  begin
                     if CurrentLine = I+FTopOffset then
                     begin
                        Brush.Color:=clBlack;
                        FillRect(Bounds(3,I*FLineSpace,Width,FLineSpace));
                     end;
                  end;
               end; //for all lines
               Font.Color:=clBlack;
               Brush.Color:=RGB(255,239,189);
               Ofs:=Height-TextHeight('Wg');
               if FRightAnchor then
               begin
                  SetTextAlign(Canvas.Handle,TA_RTLREADING or TA_RIGHT);
                  ROfs:=20+TextWidth('=99999999999')+(TextWidth(CurrToStrF(0,ffCurrency,2))-TextWidth(CurrToStrF(0,ffNumber,2)));
//                  ROfs:=20+TextWidth(CurrToStrF(Total,ffCurrency,2));
                  TextOut(ROfs,Ofs,CurrToStrF(Total,ffCurrency,CurrencyDecimals));
               end
               else
               begin
                  TextOut(630,Ofs,FCurrSymbol);
                  ROfs:=620-TextWidth(CurrToStrF(Total,ffNumber,CurrencyDecimals));
                  TextOut(ROfs,Ofs,CurrToStrF(Total,ffNumber,CurrencyDecimals));
                  ROfs:=620-TextWidth('Total  '+CurrToStrF(Total,ffNumber,CurrencyDecimals)+FCurrSymbol);
                  TextOut(ROfs,Ofs,'Total');
               end;
               SL.Free;
            end;
          pmInst :
            begin
               if FRightAnchor then SetTextAlign(Canvas.Handle,TA_RTLREADING or TA_LEFT);
               Font.Color:=clWhite;
               Font.Size:=Font.Size-2;
               TxtRect:=Bounds(Width-170,0,170,Height);
               DrawText(Handle,PChar(AllLines[0]),Length(AllLines[0]),TxtRect,DT_WORDBREAK or DT_CENTER);
               Font.Size:=Font.Size+2;
            end;
      end;
      Brush.Style:=bsSolid;
   end;
end;
function TPadLines.GetLines:String;
begin
   while (AllLines.Count > 0) and (AllLines[AllLines.Count-1] = '')  do AllLines.Delete(AllLines.Count-1);
   Result:=AllLines.PackText;
end;
procedure TPadLines.Clear;
begin
   AllLines.Clear;
   Invalidate;
end;             
procedure TPadLines.SetLines(Value:String;InForm:Boolean);
begin
   AllLines.PackText:=Value;
   Invalidate;
end;
procedure TPadLines.SetLine (Value:String;Index:Integer);
begin
   while AllLines.Count <= Index do AllLines.Add('');
   AllLines[Index]:=Value;
   Invalidate;
end;
procedure TPadLines.Highlight(Index:Integer);
begin
   CurrentLine:=Index;
   if CurrentLine > 10 then FTopOffset:=CurrentLine-10 else FTopOffset:=0;
   Invalidate;
end;
procedure TPadLines.SavePadText;
begin
   SavedLines.Assign(AllLines);
end;
procedure TPadLines.RestorePadText;
begin
   AllLines.Assign(SavedLines);
   Invalidate;
end;

procedure Register;
begin
  RegisterComponents('CorvusVCL', [TPadLines]);
end;

end.
