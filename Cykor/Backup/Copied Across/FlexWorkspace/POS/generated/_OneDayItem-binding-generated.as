
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import String;
import mx.controls.Text;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property _Text1 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var '_Text1' moved to '_1494494331_Text1'
	 */

    [Bindable(event="propertyChange")]
    public function get _Text1():mx.controls.Text
    {
        return this._1494494331_Text1;
    }

    public function set _Text1(value:mx.controls.Text):void
    {
    	var oldValue:Object = this._1494494331_Text1;
        if (oldValue !== value)
        {
			this._1494494331_Text1 = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "_Text1", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property caption (public)
	 * - generated setter
	 * - original getter left as-is
	 * - original public setter 'caption' moved to '_552573414caption'
	 */

    [Bindable(event="propertyChange")]
    public function set caption(value:String):void
    {
    	var oldValue:Object = this.caption;
        if (oldValue !== value)
        {
			this._552573414caption = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "caption", oldValue, value));
        }
    }


}
