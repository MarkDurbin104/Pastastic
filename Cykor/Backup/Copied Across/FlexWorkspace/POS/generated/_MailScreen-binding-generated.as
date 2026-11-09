
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import SVGUI.CalcSizeBox;
import mx.containers.VBox;
import SVGUI.DayButton;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property bgVBox (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'bgVBox' moved to '_1391558822bgVBox'
	 */

    [Bindable(event="propertyChange")]
    public function get bgVBox():mx.containers.VBox
    {
        return this._1391558822bgVBox;
    }

    public function set bgVBox(value:mx.containers.VBox):void
    {
    	var oldValue:Object = this._1391558822bgVBox;
        if (oldValue !== value)
        {
			this._1391558822bgVBox = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "bgVBox", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property calBar0 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'calBar0' moved to '_547382123calBar0'
	 */

    [Bindable(event="propertyChange")]
    public function get calBar0():SVGUI.CalcSizeBox
    {
        return this._547382123calBar0;
    }

    public function set calBar0(value:SVGUI.CalcSizeBox):void
    {
    	var oldValue:Object = this._547382123calBar0;
        if (oldValue !== value)
        {
			this._547382123calBar0 = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "calBar0", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property calBar1 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'calBar1' moved to '_547382124calBar1'
	 */

    [Bindable(event="propertyChange")]
    public function get calBar1():SVGUI.CalcSizeBox
    {
        return this._547382124calBar1;
    }

    public function set calBar1(value:SVGUI.CalcSizeBox):void
    {
    	var oldValue:Object = this._547382124calBar1;
        if (oldValue !== value)
        {
			this._547382124calBar1 = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "calBar1", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property calBar2 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'calBar2' moved to '_547382125calBar2'
	 */

    [Bindable(event="propertyChange")]
    public function get calBar2():SVGUI.CalcSizeBox
    {
        return this._547382125calBar2;
    }

    public function set calBar2(value:SVGUI.CalcSizeBox):void
    {
    	var oldValue:Object = this._547382125calBar2;
        if (oldValue !== value)
        {
			this._547382125calBar2 = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "calBar2", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property calBar3 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'calBar3' moved to '_547382126calBar3'
	 */

    [Bindable(event="propertyChange")]
    public function get calBar3():SVGUI.CalcSizeBox
    {
        return this._547382126calBar3;
    }

    public function set calBar3(value:SVGUI.CalcSizeBox):void
    {
    	var oldValue:Object = this._547382126calBar3;
        if (oldValue !== value)
        {
			this._547382126calBar3 = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "calBar3", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property day7 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'day7' moved to '_3076123day7'
	 */

    [Bindable(event="propertyChange")]
    public function get day7():SVGUI.DayButton
    {
        return this._3076123day7;
    }

    public function set day7(value:SVGUI.DayButton):void
    {
    	var oldValue:Object = this._3076123day7;
        if (oldValue !== value)
        {
			this._3076123day7 = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "day7", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property dayBar (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'dayBar' moved to '_1338799401dayBar'
	 */

    [Bindable(event="propertyChange")]
    public function get dayBar():SVGUI.CalcSizeBox
    {
        return this._1338799401dayBar;
    }

    public function set dayBar(value:SVGUI.CalcSizeBox):void
    {
    	var oldValue:Object = this._1338799401dayBar;
        if (oldValue !== value)
        {
			this._1338799401dayBar = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "dayBar", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property servBar (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'servBar' moved to '_1984115741servBar'
	 */

    [Bindable(event="propertyChange")]
    public function get servBar():SVGUI.CalcSizeBox
    {
        return this._1984115741servBar;
    }

    public function set servBar(value:SVGUI.CalcSizeBox):void
    {
    	var oldValue:Object = this._1984115741servBar;
        if (oldValue !== value)
        {
			this._1984115741servBar = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "servBar", oldValue, value));
        }
    }


}
