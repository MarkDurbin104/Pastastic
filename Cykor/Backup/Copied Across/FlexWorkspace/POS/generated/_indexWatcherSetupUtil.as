






package
{
import flash.display.Sprite;
import mx.core.IFlexModuleFactory;
import mx.binding.ArrayElementWatcher;
import mx.binding.FunctionReturnWatcher;
import mx.binding.IWatcherSetupUtil;
import mx.binding.PropertyWatcher;
import mx.binding.RepeaterComponentWatcher;
import mx.binding.RepeaterItemWatcher;
import mx.binding.StaticPropertyWatcher;
import mx.binding.XMLWatcher;
import mx.binding.Watcher;

[ExcludeClass]
[Mixin]
public class _indexWatcherSetupUtil extends Sprite
    implements mx.binding.IWatcherSetupUtil
{
    public function _indexWatcherSetupUtil()
    {
        super();
    }

    public static function init(fbs:IFlexModuleFactory):void
    {
        import index;
        (index).watcherSetupUtil = new _indexWatcherSetupUtil();
    }

    public function setup(target:Object,
                          propertyGetter:Function,
                          bindings:Array,
                          watchers:Array):void
    {
        import mx.core.DeferredInstanceFromFunction;
        import mx.containers.HBox;
        import mails.Weight;
        import flash.events.FocusEvent;
        import base.StageDetection;
        import mx.core.Application;
        import mx.core.ClassFactory;
        import mx.containers.ViewStack;
        import mx.controls.TextInput;
        import mx.core.IPropertyChangeNotifier;
        import mx.containers.Panel;
        import mx.effects.WipeUp;
        import mx.controls.Label;
        import mx.containers.Canvas;
        import mx.controls.TextArea;
        import mx.effects.WipeDown;
        import mx.effects.Parallel;
        import flash.events.MouseEvent;
        import base.Menus;
        import mails.WeightType;
        import mx.events.FlexEvent;
        import mx.effects.WipeRight;
        import crypto.MD5;
        import mails.MailService;
        import mx.core.UIComponentDescriptor;
        import mx.containers.VBox;
        import base.Clock;
        import mx.controls.Spacer;
        import flash.events.Event;
        import mx.core.DeferredInstanceFromClass;
        import mx.binding.BindingManager;
        import base.MailPanel;
        import flash.net.SharedObject;
        import flash.events.EventDispatcher;
        import mx.charts.chartClasses.DataDescription;
        import base.GradientRoundBaseSkin;
        import mx.controls.HRule;
        import mx.core.IDeferredInstance;
        import mx.core.mx_internal;
        import mx.effects.Fade;
        import mx.controls.Menu;
        import base.GradientRectangleSkin;
        import mx.utils.ObjectProxy;
        import mx.effects.WipeLeft;
        import mx.controls.Button;
        import mx.utils.UIDUtil;
        import mx.binding.IBindingClient;
        import mx.rpc.events.ResultEvent;
        import mx.controls.Image;
        import mx.events.PropertyChangeEvent;
        import mx.managers.ToolTipManager;
        import mx.core.IFactory;
        import flash.ui.Keyboard;
        import crypto.Hex;
        import mx.styles.StyleManager;
        import flash.events.IEventDispatcher;

        // writeWatcher id=1 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher shouldWriteChildren=true
        watchers[1] = new mx.binding.PropertyWatcher("tmpBGImage",
            {
                propertyChange: true
            }
,         // writeWatcherListeners id=1 size=1
        [
        bindings[1]
        ]
,
                                                                 propertyGetter
);

        // writeWatcher id=0 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher shouldWriteChildren=true
        watchers[0] = new mx.binding.PropertyWatcher("startBGImage",
            {
                propertyChange: true
            }
,         // writeWatcherListeners id=0 size=1
        [
        bindings[0]
        ]
,
                                                                 propertyGetter
);


        // writeWatcherBottom id=1 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher
        watchers[1].updateParent(target);

 





        // writeWatcherBottom id=0 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher
        watchers[0].updateParent(target);

 





    }
}

}
