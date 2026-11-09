
package 
{
import base.Clock;
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
import mx.containers.HBox;
import mx.containers.Panel;
import mx.containers.ViewStack;
import mx.controls.Button;
import mx.controls.Label;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.core.Application;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.mx_internal;
import mx.effects.Fade;
import mx.effects.Parallel;
import mx.effects.WipeLeft;
import mx.effects.WipeRight;
import mx.styles.*;
import mx.effects.WipeLeft;
import mx.containers.HBox;
import mx.effects.WipeDown;
import mx.controls.Button;
import mx.core.Application;
import mx.effects.WipeRight;
import mx.containers.VBox;
import mx.controls.Image;
import mx.controls.Spacer;
import mx.effects.WipeUp;
import mx.controls.Label;
import base.MailPanel;
import mx.containers.Canvas;

public class index extends mx.core.Application
{
	public function index() {}

	[Bindable]
	public var fadeIn : mx.effects.Fade;
	[Bindable]
	public var fadeOut : mx.effects.Fade;
	[Bindable]
	public var wipeRight : mx.effects.WipeRight;
	[Bindable]
	public var wipeLeft : mx.effects.WipeLeft;
	[Bindable]
	public var wipeIn : mx.effects.Parallel;
	[Bindable]
	public var wipeOut : mx.effects.Parallel;
	[Bindable]
	public var appFrames : mx.containers.ViewStack;
	[Bindable]
	public var login : mx.containers.Canvas;
	[Bindable]
	public var userName : mx.controls.TextInput;
	[Bindable]
	public var password : mx.controls.TextInput;
	[Bindable]
	public var titleBarBG : mx.containers.HBox;
	[Bindable]
	public var homeButton : mx.controls.Button;
	[Bindable]
	public var prevButton : mx.controls.Button;
	[Bindable]
	public var formState : mx.containers.ViewStack;
	[Bindable]
	public var mainCanvas : mx.containers.Canvas;
	[Bindable]
	public var stockUnitDisplay : mx.controls.Label;
	[Bindable]
	public var userNameDisplay : mx.controls.Label;
	[Bindable]
	public var clock : base.Clock;
	[Bindable]
	public var dateDisplay : mx.controls.Label;
	[Bindable]
	public var day0 : mx.containers.Panel;
	[Bindable]
	public var day1 : mx.containers.Panel;
	[Bindable]
	public var day2 : mx.containers.Panel;
	[Bindable]
	public var day3 : mx.containers.Panel;
	[Bindable]
	public var day4 : mx.containers.Panel;
	[Bindable]
	public var day5 : mx.containers.Panel;
	[Bindable]
	public var day6 : mx.containers.Panel;
	[Bindable]
	public var weightPounds : mx.controls.TextInput;
	[Bindable]
	public var weightOunces : mx.controls.TextInput;
	[Bindable]
	public var sourceZip : mx.controls.TextInput;
	[Bindable]
	public var destZip : mx.controls.TextInput;
	[Bindable]
	public var zone : mx.controls.TextArea;

	mx_internal var _bindings : Array;
	mx_internal var _watchers : Array;
	mx_internal var _bindingsByDestination : Object;
	mx_internal var _bindingsBeginWithWord : Object;

include "C:/FlexWorkspace/POS/index.mxml:17,246";

}}
