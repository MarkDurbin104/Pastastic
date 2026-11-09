package SVGUI
{
import SVGUI.CalcSizeBox;
import SVGUI.DayButton;
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
import mx.containers.Canvas;
import mx.containers.VBox;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.mx_internal;
import mx.styles.*;
import mx.containers.HBox;
import mx.controls.Image;
import mx.controls.Spacer;
import SVGUI.TwoDayItem;
import SVGUI.FourDayItem;
import SVGUI.ThreeDayItem;
import SVGUI.DayButton;
import SVGUI.OneDayItem;
import SVGUI.SecondaryItem;
import SVGUI.LockedOneDayItem;
import SVGUI.DaySpacer;
import mx.containers.Canvas;

public class MailScreen extends mx.containers.Canvas
{
	public function MailScreen() {}

	[Bindable]
	public var bgVBox : mx.containers.VBox;
	[Bindable]
	public var dayBar : SVGUI.CalcSizeBox;
	[Bindable]
	public var day7 : SVGUI.DayButton;
	[Bindable]
	public var calBar0 : SVGUI.CalcSizeBox;
	[Bindable]
	public var calBar1 : SVGUI.CalcSizeBox;
	[Bindable]
	public var calBar2 : SVGUI.CalcSizeBox;
	[Bindable]
	public var calBar3 : SVGUI.CalcSizeBox;
	[Bindable]
	public var servBar : SVGUI.CalcSizeBox;

	public var _bindingsByDestination : Object;
	public var _bindingsBeginWithWord : Object;

include "C:/FlexWorkspace/POS/SVGUI/MailScreen.mxml:11,14";

}}
