

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import com.tappernimer.components.VerticalReflection;
import mx.controls.Image;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property image1 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'image1' moved to '_1185250762image1'
	 */

    [Bindable(event="propertyChange")]
    public function get image1():mx.controls.Image
    {
        return this._1185250762image1;
    }

    public function set image1(value:mx.controls.Image):void
    {
    	var oldValue:Object = this._1185250762image1;
        if (oldValue !== value)
        {
            this._1185250762image1 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "image1", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property image2 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'image2' moved to '_1185250761image2'
	 */

    [Bindable(event="propertyChange")]
    public function get image2():mx.controls.Image
    {
        return this._1185250761image2;
    }

    public function set image2(value:mx.controls.Image):void
    {
    	var oldValue:Object = this._1185250761image2;
        if (oldValue !== value)
        {
            this._1185250761image2 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "image2", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property reflection1 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'reflection1' moved to '_594385254reflection1'
	 */

    [Bindable(event="propertyChange")]
    public function get reflection1():com.tappernimer.components.VerticalReflection
    {
        return this._594385254reflection1;
    }

    public function set reflection1(value:com.tappernimer.components.VerticalReflection):void
    {
    	var oldValue:Object = this._594385254reflection1;
        if (oldValue !== value)
        {
            this._594385254reflection1 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "reflection1", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property reflection2 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'reflection2' moved to '_594385255reflection2'
	 */

    [Bindable(event="propertyChange")]
    public function get reflection2():com.tappernimer.components.VerticalReflection
    {
        return this._594385255reflection2;
    }

    public function set reflection2(value:com.tappernimer.components.VerticalReflection):void
    {
    	var oldValue:Object = this._594385255reflection2;
        if (oldValue !== value)
        {
            this._594385255reflection2 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "reflection2", oldValue, value));
        }
    }



}
