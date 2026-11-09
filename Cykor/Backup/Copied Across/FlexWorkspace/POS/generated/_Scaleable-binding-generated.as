
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import Array;
import mx.controls.SWFLoader;
import mx.controls.DataGrid;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property arr (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'arr' moved to '_96865arr'
	 */

    [Bindable(event="propertyChange")]
    public function get arr():Array
    {
        return this._96865arr;
    }

    public function set arr(value:Array):void
    {
    	var oldValue:Object = this._96865arr;
        if (oldValue !== value)
        {
			this._96865arr = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "arr", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property dataGrid (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'dataGrid' moved to '_1788676624dataGrid'
	 */

    [Bindable(event="propertyChange")]
    public function get dataGrid():mx.controls.DataGrid
    {
        return this._1788676624dataGrid;
    }

    public function set dataGrid(value:mx.controls.DataGrid):void
    {
    	var oldValue:Object = this._1788676624dataGrid;
        if (oldValue !== value)
        {
			this._1788676624dataGrid = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "dataGrid", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property swfLoader (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'swfLoader' moved to '_2145423051swfLoader'
	 */

    [Bindable(event="propertyChange")]
    public function get swfLoader():mx.controls.SWFLoader
    {
        return this._2145423051swfLoader;
    }

    public function set swfLoader(value:mx.controls.SWFLoader):void
    {
    	var oldValue:Object = this._2145423051swfLoader;
        if (oldValue !== value)
        {
			this._2145423051swfLoader = value;
            dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "swfLoader", oldValue, value));
        }
    }


}
