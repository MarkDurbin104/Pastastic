

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.effects.WipeLeft;
import mx.containers.HBox;
import mx.controls.TextArea;
import mx.controls.Button;
import mx.effects.Parallel;
import Class;
import mx.effects.WipeRight;
import mx.containers.ViewStack;
import mx.effects.Fade;
import base.Clock;
import mx.controls.TextInput;
import mx.containers.Panel;
import mx.controls.Label;
import mx.containers.Canvas;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property appFrames (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'appFrames' moved to '_1125322279appFrames'
	 */

    [Bindable(event="propertyChange")]
    public function get appFrames():mx.containers.ViewStack
    {
        return this._1125322279appFrames;
    }

    public function set appFrames(value:mx.containers.ViewStack):void
    {
    	var oldValue:Object = this._1125322279appFrames;
        if (oldValue !== value)
        {
            this._1125322279appFrames = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "appFrames", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property clock (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'clock' moved to '_94755854clock'
	 */

    [Bindable(event="propertyChange")]
    public function get clock():base.Clock
    {
        return this._94755854clock;
    }

    public function set clock(value:base.Clock):void
    {
    	var oldValue:Object = this._94755854clock;
        if (oldValue !== value)
        {
            this._94755854clock = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "clock", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property dateDisplay (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'dateDisplay' moved to '_1428135628dateDisplay'
	 */

    [Bindable(event="propertyChange")]
    public function get dateDisplay():mx.controls.Label
    {
        return this._1428135628dateDisplay;
    }

    public function set dateDisplay(value:mx.controls.Label):void
    {
    	var oldValue:Object = this._1428135628dateDisplay;
        if (oldValue !== value)
        {
            this._1428135628dateDisplay = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "dateDisplay", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property day0 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'day0' moved to '_3076116day0'
	 */

    [Bindable(event="propertyChange")]
    public function get day0():mx.containers.Panel
    {
        return this._3076116day0;
    }

    public function set day0(value:mx.containers.Panel):void
    {
    	var oldValue:Object = this._3076116day0;
        if (oldValue !== value)
        {
            this._3076116day0 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "day0", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property day1 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'day1' moved to '_3076117day1'
	 */

    [Bindable(event="propertyChange")]
    public function get day1():mx.containers.Panel
    {
        return this._3076117day1;
    }

    public function set day1(value:mx.containers.Panel):void
    {
    	var oldValue:Object = this._3076117day1;
        if (oldValue !== value)
        {
            this._3076117day1 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "day1", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property day2 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'day2' moved to '_3076118day2'
	 */

    [Bindable(event="propertyChange")]
    public function get day2():mx.containers.Panel
    {
        return this._3076118day2;
    }

    public function set day2(value:mx.containers.Panel):void
    {
    	var oldValue:Object = this._3076118day2;
        if (oldValue !== value)
        {
            this._3076118day2 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "day2", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property day3 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'day3' moved to '_3076119day3'
	 */

    [Bindable(event="propertyChange")]
    public function get day3():mx.containers.Panel
    {
        return this._3076119day3;
    }

    public function set day3(value:mx.containers.Panel):void
    {
    	var oldValue:Object = this._3076119day3;
        if (oldValue !== value)
        {
            this._3076119day3 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "day3", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property day4 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'day4' moved to '_3076120day4'
	 */

    [Bindable(event="propertyChange")]
    public function get day4():mx.containers.Panel
    {
        return this._3076120day4;
    }

    public function set day4(value:mx.containers.Panel):void
    {
    	var oldValue:Object = this._3076120day4;
        if (oldValue !== value)
        {
            this._3076120day4 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "day4", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property day5 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'day5' moved to '_3076121day5'
	 */

    [Bindable(event="propertyChange")]
    public function get day5():mx.containers.Panel
    {
        return this._3076121day5;
    }

    public function set day5(value:mx.containers.Panel):void
    {
    	var oldValue:Object = this._3076121day5;
        if (oldValue !== value)
        {
            this._3076121day5 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "day5", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property day6 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'day6' moved to '_3076122day6'
	 */

    [Bindable(event="propertyChange")]
    public function get day6():mx.containers.Panel
    {
        return this._3076122day6;
    }

    public function set day6(value:mx.containers.Panel):void
    {
    	var oldValue:Object = this._3076122day6;
        if (oldValue !== value)
        {
            this._3076122day6 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "day6", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property destZip (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'destZip' moved to '_1557349663destZip'
	 */

    [Bindable(event="propertyChange")]
    public function get destZip():mx.controls.TextInput
    {
        return this._1557349663destZip;
    }

    public function set destZip(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._1557349663destZip;
        if (oldValue !== value)
        {
            this._1557349663destZip = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "destZip", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property fadeIn (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'fadeIn' moved to '_1282133823fadeIn'
	 */

    [Bindable(event="propertyChange")]
    public function get fadeIn():mx.effects.Fade
    {
        return this._1282133823fadeIn;
    }

    public function set fadeIn(value:mx.effects.Fade):void
    {
    	var oldValue:Object = this._1282133823fadeIn;
        if (oldValue !== value)
        {
            this._1282133823fadeIn = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "fadeIn", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property fadeOut (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'fadeOut' moved to '_1091436750fadeOut'
	 */

    [Bindable(event="propertyChange")]
    public function get fadeOut():mx.effects.Fade
    {
        return this._1091436750fadeOut;
    }

    public function set fadeOut(value:mx.effects.Fade):void
    {
    	var oldValue:Object = this._1091436750fadeOut;
        if (oldValue !== value)
        {
            this._1091436750fadeOut = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "fadeOut", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property formState (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'formState' moved to '_1798644269formState'
	 */

    [Bindable(event="propertyChange")]
    public function get formState():mx.containers.ViewStack
    {
        return this._1798644269formState;
    }

    public function set formState(value:mx.containers.ViewStack):void
    {
    	var oldValue:Object = this._1798644269formState;
        if (oldValue !== value)
        {
            this._1798644269formState = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "formState", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property homeButton (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'homeButton' moved to '_410952945homeButton'
	 */

    [Bindable(event="propertyChange")]
    public function get homeButton():mx.controls.Button
    {
        return this._410952945homeButton;
    }

    public function set homeButton(value:mx.controls.Button):void
    {
    	var oldValue:Object = this._410952945homeButton;
        if (oldValue !== value)
        {
            this._410952945homeButton = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "homeButton", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property login (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'login' moved to '_103149417login'
	 */

    [Bindable(event="propertyChange")]
    public function get login():mx.containers.Canvas
    {
        return this._103149417login;
    }

    public function set login(value:mx.containers.Canvas):void
    {
    	var oldValue:Object = this._103149417login;
        if (oldValue !== value)
        {
            this._103149417login = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "login", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property mainCanvas (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'mainCanvas' moved to '_10782607mainCanvas'
	 */

    [Bindable(event="propertyChange")]
    public function get mainCanvas():mx.containers.Canvas
    {
        return this._10782607mainCanvas;
    }

    public function set mainCanvas(value:mx.containers.Canvas):void
    {
    	var oldValue:Object = this._10782607mainCanvas;
        if (oldValue !== value)
        {
            this._10782607mainCanvas = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "mainCanvas", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property password (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'password' moved to '_1216985755password'
	 */

    [Bindable(event="propertyChange")]
    public function get password():mx.controls.TextInput
    {
        return this._1216985755password;
    }

    public function set password(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._1216985755password;
        if (oldValue !== value)
        {
            this._1216985755password = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "password", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property prevButton (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'prevButton' moved to '_1143471291prevButton'
	 */

    [Bindable(event="propertyChange")]
    public function get prevButton():mx.controls.Button
    {
        return this._1143471291prevButton;
    }

    public function set prevButton(value:mx.controls.Button):void
    {
    	var oldValue:Object = this._1143471291prevButton;
        if (oldValue !== value)
        {
            this._1143471291prevButton = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "prevButton", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property sourceZip (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'sourceZip' moved to '_1698415354sourceZip'
	 */

    [Bindable(event="propertyChange")]
    public function get sourceZip():mx.controls.TextInput
    {
        return this._1698415354sourceZip;
    }

    public function set sourceZip(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._1698415354sourceZip;
        if (oldValue !== value)
        {
            this._1698415354sourceZip = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "sourceZip", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property stockUnitDisplay (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'stockUnitDisplay' moved to '_2138988968stockUnitDisplay'
	 */

    [Bindable(event="propertyChange")]
    public function get stockUnitDisplay():mx.controls.Label
    {
        return this._2138988968stockUnitDisplay;
    }

    public function set stockUnitDisplay(value:mx.controls.Label):void
    {
    	var oldValue:Object = this._2138988968stockUnitDisplay;
        if (oldValue !== value)
        {
            this._2138988968stockUnitDisplay = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "stockUnitDisplay", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property titleBarBG (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'titleBarBG' moved to '_1800703968titleBarBG'
	 */

    [Bindable(event="propertyChange")]
    public function get titleBarBG():mx.containers.HBox
    {
        return this._1800703968titleBarBG;
    }

    public function set titleBarBG(value:mx.containers.HBox):void
    {
    	var oldValue:Object = this._1800703968titleBarBG;
        if (oldValue !== value)
        {
            this._1800703968titleBarBG = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "titleBarBG", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property userName (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'userName' moved to '_266666762userName'
	 */

    [Bindable(event="propertyChange")]
    public function get userName():mx.controls.TextInput
    {
        return this._266666762userName;
    }

    public function set userName(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._266666762userName;
        if (oldValue !== value)
        {
            this._266666762userName = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "userName", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property userNameDisplay (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'userNameDisplay' moved to '_535801108userNameDisplay'
	 */

    [Bindable(event="propertyChange")]
    public function get userNameDisplay():mx.controls.Label
    {
        return this._535801108userNameDisplay;
    }

    public function set userNameDisplay(value:mx.controls.Label):void
    {
    	var oldValue:Object = this._535801108userNameDisplay;
        if (oldValue !== value)
        {
            this._535801108userNameDisplay = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "userNameDisplay", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property weightOunces (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'weightOunces' moved to '_457793375weightOunces'
	 */

    [Bindable(event="propertyChange")]
    public function get weightOunces():mx.controls.TextInput
    {
        return this._457793375weightOunces;
    }

    public function set weightOunces(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._457793375weightOunces;
        if (oldValue !== value)
        {
            this._457793375weightOunces = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "weightOunces", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property weightPounds (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'weightPounds' moved to '_434486273weightPounds'
	 */

    [Bindable(event="propertyChange")]
    public function get weightPounds():mx.controls.TextInput
    {
        return this._434486273weightPounds;
    }

    public function set weightPounds(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._434486273weightPounds;
        if (oldValue !== value)
        {
            this._434486273weightPounds = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "weightPounds", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property wipeIn (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'wipeIn' moved to '_787692596wipeIn'
	 */

    [Bindable(event="propertyChange")]
    public function get wipeIn():mx.effects.Parallel
    {
        return this._787692596wipeIn;
    }

    public function set wipeIn(value:mx.effects.Parallel):void
    {
    	var oldValue:Object = this._787692596wipeIn;
        if (oldValue !== value)
        {
            this._787692596wipeIn = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "wipeIn", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property wipeLeft (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'wipeLeft' moved to '_1058256658wipeLeft'
	 */

    [Bindable(event="propertyChange")]
    public function get wipeLeft():mx.effects.WipeLeft
    {
        return this._1058256658wipeLeft;
    }

    public function set wipeLeft(value:mx.effects.WipeLeft):void
    {
    	var oldValue:Object = this._1058256658wipeLeft;
        if (oldValue !== value)
        {
            this._1058256658wipeLeft = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "wipeLeft", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property wipeOut (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'wipeOut' moved to '_1351339399wipeOut'
	 */

    [Bindable(event="propertyChange")]
    public function get wipeOut():mx.effects.Parallel
    {
        return this._1351339399wipeOut;
    }

    public function set wipeOut(value:mx.effects.Parallel):void
    {
    	var oldValue:Object = this._1351339399wipeOut;
        if (oldValue !== value)
        {
            this._1351339399wipeOut = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "wipeOut", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property wipeRight (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'wipeRight' moved to '_1559442965wipeRight'
	 */

    [Bindable(event="propertyChange")]
    public function get wipeRight():mx.effects.WipeRight
    {
        return this._1559442965wipeRight;
    }

    public function set wipeRight(value:mx.effects.WipeRight):void
    {
    	var oldValue:Object = this._1559442965wipeRight;
        if (oldValue !== value)
        {
            this._1559442965wipeRight = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "wipeRight", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property zone (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'zone' moved to '_3744684zone'
	 */

    [Bindable(event="propertyChange")]
    public function get zone():mx.controls.TextArea
    {
        return this._3744684zone;
    }

    public function set zone(value:mx.controls.TextArea):void
    {
    	var oldValue:Object = this._3744684zone;
        if (oldValue !== value)
        {
            this._3744684zone = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "zone", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property bgImage (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'bgImage' moved to '_199389162bgImage'
	 */

    [Bindable(event="propertyChange")]
    public function get bgImage():Class
    {
        return this._199389162bgImage;
    }

    public function set bgImage(value:Class):void
    {
    	var oldValue:Object = this._199389162bgImage;
        if (oldValue !== value)
        {
            this._199389162bgImage = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "bgImage", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property startBGImage (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'startBGImage' moved to '_1249968780startBGImage'
	 */

    [Bindable(event="propertyChange")]
    public function get startBGImage():Class
    {
        return this._1249968780startBGImage;
    }

    public function set startBGImage(value:Class):void
    {
    	var oldValue:Object = this._1249968780startBGImage;
        if (oldValue !== value)
        {
            this._1249968780startBGImage = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "startBGImage", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property tmpBGImage (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'tmpBGImage' moved to '_1705589535tmpBGImage'
	 */

    [Bindable(event="propertyChange")]
    public function get tmpBGImage():Class
    {
        return this._1705589535tmpBGImage;
    }

    public function set tmpBGImage(value:Class):void
    {
    	var oldValue:Object = this._1705589535tmpBGImage;
        if (oldValue !== value)
        {
            this._1705589535tmpBGImage = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "tmpBGImage", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property MailsScreen (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'MailsScreen' moved to '_1382375688MailsScreen'
	 */

    [Bindable(event="propertyChange")]
    public function get MailsScreen():Class
    {
        return this._1382375688MailsScreen;
    }

    public function set MailsScreen(value:Class):void
    {
    	var oldValue:Object = this._1382375688MailsScreen;
        if (oldValue !== value)
        {
            this._1382375688MailsScreen = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "MailsScreen", oldValue, value));
        }
    }



}
