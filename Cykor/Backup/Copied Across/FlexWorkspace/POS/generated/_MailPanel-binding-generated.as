

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import String;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property description (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'description' moved to '_1724546052description'
	 */

    [Bindable(event="propertyChange")]
    public function get description():String
    {
        return this._1724546052description;
    }

    public function set description(value:String):void
    {
    	var oldValue:Object = this._1724546052description;
        if (oldValue !== value)
        {
            this._1724546052description = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "description", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property iconSource (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'iconSource' moved to '_501509644iconSource'
	 */

    [Bindable(event="propertyChange")]
    public function get iconSource():String
    {
        return this._501509644iconSource;
    }

    public function set iconSource(value:String):void
    {
    	var oldValue:Object = this._501509644iconSource;
        if (oldValue !== value)
        {
            this._501509644iconSource = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "iconSource", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property price (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'price' moved to '_106934601price'
	 */

    [Bindable(event="propertyChange")]
    public function get price():String
    {
        return this._106934601price;
    }

    public function set price(value:String):void
    {
    	var oldValue:Object = this._106934601price;
        if (oldValue !== value)
        {
            this._106934601price = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "price", oldValue, value));
        }
    }



}
