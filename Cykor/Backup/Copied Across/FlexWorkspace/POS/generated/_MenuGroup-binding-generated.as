

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import String;
import mx.containers.VBox;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property image (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'image' moved to '_100313435image'
	 */

    [Bindable(event="propertyChange")]
    public function get image():mx.containers.VBox
    {
        return this._100313435image;
    }

    public function set image(value:mx.containers.VBox):void
    {
    	var oldValue:Object = this._100313435image;
        if (oldValue !== value)
        {
            this._100313435image = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "image", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property picture (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'picture' moved to '_577741570picture'
	 */

    [Bindable(event="propertyChange")]
    public function get picture():String
    {
        return this._577741570picture;
    }

    public function set picture(value:String):void
    {
    	var oldValue:Object = this._577741570picture;
        if (oldValue !== value)
        {
            this._577741570picture = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "picture", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property title (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'title' moved to '_110371416title'
	 */

    [Bindable(event="propertyChange")]
    public function get title():String
    {
        return this._110371416title;
    }

    public function set title(value:String):void
    {
    	var oldValue:Object = this._110371416title;
        if (oldValue !== value)
        {
            this._110371416title = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "title", oldValue, value));
        }
    }



}
