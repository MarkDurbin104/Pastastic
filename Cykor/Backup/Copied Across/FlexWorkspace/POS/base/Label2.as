package base
{
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.styles.StyleManager;

	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event(name="dataChange", type="mx.events.FlexEvent")]
	[Event(name="link", type="flash.events.TextEvent")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	include "TextStyles.as"
	
	[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]
	[Style(name="paddingRight", type="Number", format="Length", inherit="no")]
	[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
	[Style(name="paddingTop", type="Number", format="Length", inherit="no")]
	//[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------
	
	[Exclude(name="focusEnabled", kind="property")]
	[Exclude(name="focusPane", kind="property")]
	[Exclude(name="mouseFocusEnabled", kind="property")]
	[Exclude(name="tabEnabled", kind="property")]
	[Exclude(name="focusBlendMode", kind="style")]
	[Exclude(name="focusSkin", kind="style")]
	[Exclude(name="focusThickness", kind="style")]
	[Exclude(name="setFocus", kind="method")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[DefaultBindingProperty(destination="text")]
	
	[IconFile("Label.png")]
	
	public class Label2 extends UIComponent implements IDataRenderer, IDropInListItemRenderer, IListItemRenderer
	{
//MJD	    include "../core/Version.as";
	
	    //--------------------------------------------------------------------------
	    //  Constructor
	    //--------------------------------------------------------------------------
	
	    public function Label2()
	    {
	        super();
	    }
	
	    //--------------------------------------------------------------------------
	    //  Variables
	    //--------------------------------------------------------------------------
	
	    private var textSet:Boolean;
	
	    //--------------------------------------------------------------------------
	    //  Overridden properties
	    //--------------------------------------------------------------------------
	
	    override public function get baselinePosition():Number
	    {
	        if (!textField)
	            return NaN;
	        
	        // Ensure that textField.y is accurate.
	        validateNow();
	
	        var t:String = isHTML ? explicitHTMLText : text; 
	
	        if (t == "")
	            t = " ";
	
	        // Measure the width and height of the text to be displayed.
	        // (This uses another TextField that isn't part of the
	        // DisplayObject hierarchy.)
	        var lineMetrics:TextLineMetrics = isHTML ?
	                                          measureHTMLText(t) :
	                                          measureText(t);
	
	        return textField.y + lineMetrics.ascent;
	    }
	
	    private var enabledChanged:Boolean = false;
	
	    [Inspectable(category="General")]
	    override public function set enabled(value:Boolean):void
	    {
	        if (value == enabled)
	            return;
	
	        super.enabled = value;
	        enabledChanged = true;
	
	        invalidateProperties();
	    }

	    protected var textField:UITextField;

	    private var toolTipSet:Boolean = false;
	    override public function set toolTip(value:String):void
	    {
	        super.toolTip = value;
	
	        toolTipSet = value != null;
	    }
	
	    //--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------
	    private var _condenseWhite:Boolean = false;
	    private var condenseWhiteChanged:Boolean = false;
	
	    [Bindable("condenseWhiteChanged")]
	    [Inspectable(category="General", defaultValue="false")]
	    public function get condenseWhite():Boolean
	    {
	        return _condenseWhite;
	    }
	    public function set condenseWhite(value:Boolean):void
	    {
	        if (value == _condenseWhite)
	            return;
	
	        _condenseWhite = value;
	        condenseWhiteChanged = true;
	        
	        // Changing the condenseWhite property needs to trigger
	        // the same response as changing the htmlText property
	        // if this Label is displaying HTML.
	        
	        if (isHTML)
	            htmlTextChanged = true;
	
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	
	        dispatchEvent(new Event("condenseWhiteChanged"));
	    }
	
	    private var _data:Object;
	    [Bindable("dataChange")]
	    [Inspectable(environment="none")]
	    public function get data():Object
	    {
	        return _data;
	    }
	    public function set data(value:Object):void
	    {
	        var newText:*;
	
	        _data = value;
	
	        if (_listData)
	        {
	            newText = _listData.label;
	        }
	        else if (_data != null)
	        {
	            if (_data is String)
	                newText = String(_data);
	            else
	                newText = _data.toString();
	        }
	
	        if (newText !== undefined && !textSet)
	        {
	            text = newText;
	            textSet = false;
	        }
	
	        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
	    }
	    private var _htmlText:String = "";
	    mx_internal var htmlTextChanged:Boolean = false;
	    private var htmlTextChanged:Boolean = false;
	    private var explicitHTMLText:String = null; 
	
	    [Bindable("htmlTextChanged")]
	    [CollapseWhiteSpace]
	    [Inspectable(category="General", defaultValue="")]
	    public function get htmlText():String
	    {
	        return _htmlText;
	    }
	    public function set htmlText(value:String):void
	    {
	        textSet = true;
	
	        // The htmlText property can't be set to null,
	        // only to the empty string, because if you set the htmlText
	        // of a TextField to null it throws an RTE.
	        // If the getter returns null, it means that 'text' was just set
	        // and the value of 'htmlText' isn't yet known, because the 'text'
	        // hasn't been committed into the textField and the 'htmlText'
	        // hasn't yet been read back out of the textField.
	        if (!value)
	            value = "";
	
	        if (isHTML && value == explicitHTMLText)
	            return;
	
	        _htmlText = value;
	        htmlTextChanged = true;
	
	        // The text property is unknown until commitProperties(),
	        // when we push the htmlText into the TextField and it
	        // calculates the text.
	        // But you can call validateNow() to make this happen right away.
	        _text = null;
	        
	        explicitHTMLText = value;
	
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	
	        // Trigger bindings to htmlText.
	        dispatchEvent(new Event("htmlTextChanged"));
	
	        // commitProperties() will dispatch a "valueCommit" event
	        // after the TextField determines the 'text' based on the
	        // 'htmlText'; this event will trigger any bindings to 'text'.
	    }
	    private function get isHTML():Boolean
	    {
	        return explicitHTMLText != null;
	    }
	    private var _listData:BaseListData;
	
	    [Bindable("dataChange")]
	    [Inspectable(environment="none")]
	    public function get listData():BaseListData
	    {
	        return _listData;
	    }
	    public function set listData(value:BaseListData):void
	    {
	        _listData = value;
	    }
	    private var _selectable:Boolean = false;
	    private var selectableChanged:Boolean;
	    [Inspectable(category="General", defaultValue="true")]
	    public function get selectable():Boolean
	    {
	        return _selectable;
	    }
	    public function set selectable(value:Boolean):void
	    {
	        if (value == selectable)
	            return;
	
	        _selectable = value;
	        selectableChanged = true;
	
	        invalidateProperties();
	    }
	    mx_internal function get styleSheet():StyleSheet
	    {
	        return textField.styleSheet;
	    }
	    mx_internal function set styleSheet(value:StyleSheet):void
	    {
	        textField.styleSheet = value;
	    }
	    private var _tabIndex:int = -1;
	    override public function get tabIndex():int
	    {
	        return _tabIndex;
	    }
	    override public function set tabIndex(value:int):void
	    {
	        _tabIndex = value;
	
	        invalidateProperties();
	    }
	    private var _text:String = "";
	    mx_internal var textChanged:Boolean = false;
	    [Bindable("valueCommit")]
	    [CollapseWhiteSpace]
	    [Inspectable(category="General", defaultValue="")]
	    public function get text():String
	    {
	        return _text;
	    }
	    public function set text(value:String):void
	    {
	        textSet = true;
	
	        // The text property can't be set to null, only to the empty string.
	        // If the getter returns null, it means that 'htmlText' was just set
	        // and the value of 'text' isn't yet known, because the 'htmlText'
	        // hasn't been committed into the textField and the 'text'
	        // hasn't yet been read back out of the textField.
	        if (!value)
	            value = "";
	
	        if (!isHTML && value == _text)
	            return;
	        
	        _text = value;
	        textChanged = true;
	
	        // The htmlText property is unknown until commitProperties(),
	        // when we push the text into the TextField and it
	        // calculates the htmlText.
	        // But you can call validateNow() to make this happen right away.
	        _htmlText = null;
	        
	        explicitHTMLText = null;
	
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	
	        // Trigger bindings to 'text'.
	        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
	
	        // commitProperties() will dispatch an "htmlTextChanged" event
	        // after the TextField determines the 'htmlText' based on the
	        // 'text'; this event will trigger any bindings to 'htmlText'.
	    }
	    private var _textHeight:Number;
	    public function get textHeight():Number
	    {
	        return _textHeight;
	    }
	    private var _textWidth:Number;
	    public function get textWidth():Number
	    {
	        return _textWidth;
	    }
	    public var truncateToFit:Boolean = true;
	
	    //--------------------------------------------------------------------------
	    //  Overridden methods: UIComponent
	    //--------------------------------------------------------------------------
	    override protected function createChildren():void
	    {
	        super.createChildren();
	
	        if (!textField)
	        {
	            textField = new UITextField();
	
	            textField.enabled = enabled;
	            textField.ignorePadding = true;
	            textField.selectable = selectable;
	            textField.styleName = this;
	
	            textField.addEventListener("textFieldStyleChange",
	                                       textField_textFieldStyleChangeHandler)
	            
	            addChild(textField);
	        }
	    }
	    override protected function commitProperties():void
	    {
	        super.commitProperties();
	
	        if (condenseWhiteChanged)
	        {
	            textField.condenseWhite = _condenseWhite;
	            
	            condenseWhiteChanged = false;
	        }
	
	        textField.tabIndex = tabIndex;
	
	        if (enabledChanged)
	        {
	            textField.enabled = enabled;
	           
	            enabledChanged = false;
	        }
	
	        if (selectableChanged)
	        {
	            textField.selectable = _selectable;
	            
	            selectableChanged = false;
	        }
	
	        if (textChanged || htmlTextChanged)
	        {
	            // If the 'text' and 'htmlText' properties have both changed,
	            // the last one set wins.
	            if (isHTML)
	                textField.htmlText = explicitHTMLText;
	            else
	                textField.text = _text;
	            
	            textFieldChanged(false)
	                        
	            textChanged = false;
	            htmlTextChanged = false;
	        }
	    }
	
	    /**
	     *  @private
	     *  Measure min/max/preferred sizes.
	     */
	    override protected function measure():void
	    {
	        super.measure();
	
	        var t:String = isHTML ? explicitHTMLText : text; 
	        
	        t = getMinimumText(t);
	
	        // Determine how large the textField would need to be
	        // to display the entire text.
	        var textFieldBounds:Rectangle = measureTextFieldBounds(t);
	
	        // Add in the padding.
	        measuredMinWidth = measuredWidth = textFieldBounds.width +
	            getStyle("paddingLeft") + getStyle("paddingRight");
	        measuredMinHeight = measuredHeight = textFieldBounds.height +
	            getStyle("paddingTop") + getStyle("paddingBottom");
	    }
	
	    /**
	     *  @private
	     */
	    override protected function updateDisplayList(unscaledWidth:Number,
	                                                  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	                
	        /*
	        var g:Graphics = graphics;
	        g.clear();
	        var backgroundColor:* = getStyle("backgroundColor");
	        if (StyleManager.isValidStyleValue(backgroundColor))
	        {
	            g.beginFill(getStyle("backgroundColor"));
	            g.drawRect(0, 0, unscaledWidth, unscaledHeight);
	            g.endFill();
	        }
	        */
	                
	        // The textField occupies the entire Label bounds minus the padding.
	
	        var paddingLeft:Number = getStyle("paddingLeft");
	        var paddingTop:Number = getStyle("paddingTop");
	        var paddingRight:Number = getStyle("paddingRight");
	        var paddingBottom:Number = getStyle("paddingBottom");
	
	        
	        textField.setActualSize(unscaledWidth - paddingLeft - paddingRight,
	                                unscaledHeight - paddingTop - paddingBottom);
	
	        textField.x = paddingLeft;
	        textField.y = paddingTop;
	
	        // Now handle truncation if the text doesn't fit.
	
	        var t:String = isHTML ? explicitHTMLText : text; 
	
	        // Determine how large the textField would need to be
	        // to display the entire text.
	        var textFieldBounds:Rectangle = measureTextFieldBounds(t);
	        
	        // Plain text gets truncated with a "...".
	        // HTML text simply gets clipped, because it is difficult
	        // to skip over the markup and truncate only the non-markup.
	        // But both plain text and HTML text gets an automatic tooltip
	        // if the full text isn't visible.
	        if (truncateToFit)
	        {
	            var truncated:Boolean;
	            if (isHTML)
	            {
	                truncated = textFieldBounds.width > textField.width;
	            }
	            else
	            {
	                // Reset the text in case it was previously
	                // truncated with a "...".
	                textField.text = _text;
	                
	                // Determine whether the full text needs to be truncated
	                // based on the actual size of the TextField.
	                // Note that the actual size doesn't change;
	                // the text changes to fit within the actual size.
	                truncated = textField.truncateToFit();
	            }
	
	            // If no explicit tooltip has been set,
	            // implicitly set or clear a "truncation tip".
	            if (!toolTipSet)
	                super.toolTip = truncated ? text : null;
	        }
	        
	    }
	
	    //--------------------------------------------------------------------------
	    //
	    //  Methods
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  Returns a TextLineMetrics object with information about the text 
	     *  position and measurements for a line of text in the control.
	     *  The component must be validated to get a correct number.
	     *  If you set <code>text</code> and then immediately call
	     *  <code>getLineMetrics()</code> you may receive an incorrect value.
	     *  You should either wait for the component to validate
	     *  or call <code>validateNow()</code>.
	     *  This is behavior differs from that of the flash.text.TextField class,
	     *  which updates the value immediately.
	     * 
	     *  @param lineIndex The zero-based index of the line for which to get the metrics. 
	     *  For the Label control, which has only a single line, must be 0.
	     *
	     *  @see flash.text.TextField
	     *  @see flash.text.TextLineMetrics
	     */
	    public function getLineMetrics(lineIndex:int):TextLineMetrics
	    {
	        return textField ? textField.getLineMetrics(lineIndex) : null;
	    }
	
	    /**
	     *  @private
	     *  Setting the 'htmlText' of textField changes its 'text',
	     *  and vice versa, so afterwards doing so we call this method
	     *  to update the storage vars for various properties.
	     *  Afterwards, the Label's 'text', 'htmlText', 'textWidth',
	     *  and 'textHeight' are all in sync with each other
	     *  and are identical to the TextField's.
	     */
	    private function textFieldChanged(styleChangeOnly:Boolean):void
	    {
	        var changed:Boolean;
	
	        if (!styleChangeOnly)
	        {
	            changed = _text != textField.text;
	            _text = textField.text;
	            // If the 'text' property changes, dispatch a valueCommit
	            // event, which will trigger bindings to 'text'.
	            if (changed)
	                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
	        }
	        
	        changed = _htmlText != textField.htmlText;
	        _htmlText = textField.htmlText;
	        // If the 'htmlText' property changes, trigger bindings to it.
	        if (changed)
	            dispatchEvent(new Event("htmlTextChanged"));
	
	        _textWidth = textField.textWidth;
	        _textHeight = textField.textHeight;
	    }
	
	    /**
	     *  @private
	     */
	    private function measureTextFieldBounds(s:String):Rectangle
	    {
	        // Measure the text we need to display.
	        var lineMetrics:TextLineMetrics = isHTML ?
	                                          measureHTMLText(s) :
	                                          measureText(s);
	        
	        // In order to display this text completely,
	        // a TextField must be 4-5 pixels larger.
	        return new Rectangle(0, 0,
	                             lineMetrics.width + UITextField.TEXT_WIDTH_PADDING,
	                             lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING);
	    }
	
	    /**
	     *  @private
	     *  Some other components which use a Label as an internal
	     *  subcomponent need access to its UITextField, but can't access the
	     *  textField var because it is protected and therefore available
	     *  only to subclasses.
	     */
	    mx_internal function getTextField():UITextField
	    {
	        return textField;
	    }
	    
	    /**
	     *  @private 
	     */
	    mx_internal function getMinimumText(t:String):String
	    {
	         // If the text is null, empty, or a single character,
	        // make the measured size big enough to hold
	        // a capital and decending character using the current font.
	        if (!t || t.length < 2)
	            t = "Wj";
	            
	        return t;   
	    }
	
	    //--------------------------------------------------------------------------
	    //
	    //  Event handlers
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */
	    private function textField_textFieldStyleChangeHandler(event:Event):void
	    {
	        textFieldChanged(true);
	    }
	}		
}