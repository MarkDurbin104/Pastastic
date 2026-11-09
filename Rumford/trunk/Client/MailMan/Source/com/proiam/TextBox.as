package com.proiam {

	import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextLineMetrics;
    import flash.text.TextFieldAutoSize;
    import flash.text.AntiAliasType;
    import flash.text.TextFormat;

	public class TextBox extends Sprite {
		public function TextBox() {
		{
            var myTextField:TextField = new TextField();
            var newFormat:TextFormat = new TextFormat(); 

            myTextField.x = 10;
            myTextField.y = 10;
            myTextField.background = true;
            myTextField.wordWrap = false;
            myTextField.autoSize = TextFieldAutoSize.LEFT;
            myTextField.
            myTextField.appendText("A child said What is the grass? fetching it to me with full hands;\n");
            myTextField.appendText("How could I answer the child? I do not know what it is any more than he.\n\n");

            newFormat.size = 14;
            newFormat.font = "Arial";
            newFormat.italic = true;
            myTextField.setTextFormat(newFormat, 67, 139);
               
            var metrics1:TextLineMetrics = myTextField.getLineMetrics(0);
             
            myTextField.appendText("Metrics ascent for the line 1 is: " + metrics1.ascent.toString() + "\n");
            myTextField.appendText("Metrics descent is: " + metrics1.descent.toString() + "\n");
            myTextField.appendText("Metrics height is: " + metrics1.height.toString() + "\n"); 
            myTextField.appendText("Metrics width is: " + metrics1.width.toString() + "\n\n");

            var metrics2:TextLineMetrics = myTextField.getLineMetrics(1);
             
            myTextField.appendText("Metrics ascent for the line 2 is: " + metrics2.ascent.toString() + "\n");
            myTextField.appendText("Metrics descent is: " + metrics2.descent.toString() + "\n");
            myTextField.appendText("Metrics height is: " + metrics2.height.toString() + "\n"); 
            myTextField.appendText("Metrics width is: " + metrics2.width.toString() + "\n");

            addChild(myTextField);
		}
	}
}
