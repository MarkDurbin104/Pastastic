
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;


class BindableProperty
{
	/**
	 * generated bindable wrapper for property tmpBmp (private)
	 * - generated setter
	 * - generated getter
	 * - original private var 'tmpBmp' moved to '_869918482tmpBmp'
	 */

    [Bindable(event="propertyChange")]
    private function get tmpBmp():Bitmap
    {
        return this._869918482tmpBmp;
    }

    private function set tmpBmp(value:Bitmap):void
    {
    	var oldValue:Object = this._869918482tmpBmp;
        if (oldValue !== value)
        {
			this._869918482tmpBmp = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "tmpBmp", oldValue, value));
        }
    }


}
