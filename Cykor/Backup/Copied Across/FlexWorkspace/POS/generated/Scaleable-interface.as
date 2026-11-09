package 
{
import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.external.*;
import flash.filters.*;
import flash.geom.*;
import flash.media.*;
import flash.net.*;
import flash.printing.*;
import flash.profiler.*;
import flash.system.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;
import flash.xml.*;
import mx.binding.*;
import mx.controls.DataGrid;
import mx.controls.SWFLoader;
import mx.core.Application;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.mx_internal;
import mx.styles.*;
import mx.containers.HBox;
import mx.controls.Button;
import mx.containers.ApplicationControlBar;
import Object;
import mx.core.Application;

public class Scaleable extends mx.core.Application
{
	public function Scaleable() {}

	[Bindable]
	public var arr : Array;
	[Bindable]
	public var dataGrid : mx.controls.DataGrid;
	[Bindable]
	public var swfLoader : mx.controls.SWFLoader;

	public var _bindingsByDestination : Object;
	public var _bindingsBeginWithWord : Object;

include "C:/FlexWorkspace/POS/Scaleable.mxml:9,18";

}}
