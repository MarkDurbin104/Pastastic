
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.containers.Canvas;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property background (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'background' moved to '_1332194002background'
	 */

    [Bindable(event="propertyChange")]
    public function get background():mx.containers.Canvas
    {
        return this._1332194002background;
    }

    public function set background(value:mx.containers.Canvas):void
    {
    	var oldValue:Object = this._1332194002background;
        if (oldValue !== value)
        {
			this._1332194002background = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "background", oldValue, value));
        }
    }


}
