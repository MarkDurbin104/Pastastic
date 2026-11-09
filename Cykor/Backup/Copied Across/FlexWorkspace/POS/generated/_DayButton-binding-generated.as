
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import String;
import int;
import mx.controls.Label;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property _Label1 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var '_Label1' moved to '_681920764_Label1'
	 */

    [Bindable(event="propertyChange")]
    public function get _Label1():mx.controls.Label
    {
        return this._681920764_Label1;
    }

    public function set _Label1(value:mx.controls.Label):void
    {
    	var oldValue:Object = this._681920764_Label1;
        if (oldValue !== value)
        {
			this._681920764_Label1 = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "_Label1", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property offset (public)
	 * - generated setter
	 * - original getter left as-is
	 * - original public setter 'offset' moved to '_1019779949offset'
	 */

    [Bindable(event="propertyChange")]
    public function set offset(value:int):void
    {
    	var oldValue:Object = this.offset;
        if (oldValue !== value)
        {
			this._1019779949offset = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "offset", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property day (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'day' moved to '_99228day'
	 */

    [Bindable(event="propertyChange")]
    public function get day():String
    {
        return this._99228day;
    }

    public function set day(value:String):void
    {
    	var oldValue:Object = this._99228day;
        if (oldValue !== value)
        {
			this._99228day = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "day", oldValue, value));
        }
    }


}
