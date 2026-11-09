






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
import mx.binding.XMLWatcher;
import mx.binding.Watcher;

[ExcludeClass]
[Mixin]
public class _SVGUI_MailScreenWatcherSetupUtil extends Sprite
    implements mx.binding.IWatcherSetupUtil
{
    public function _SVGUI_MailScreenWatcherSetupUtil()
    {
        super();
    }

    public static function init(fbs:IFlexModuleFactory):void
    {
        import SVGUI.MailScreen;
        (SVGUI.MailScreen).watcherSetupUtil = new _SVGUI_MailScreenWatcherSetupUtil();
    }

    public function setup(target:Object,
                          propertyGetter:Function,
                          bindings:Array,
                          watchers:Array):void
    {
        import flash.events.EventDispatcher;
        import mx.core.DeferredInstanceFromFunction;
        import mx.containers.HBox;
        import SVGUI.OneDayItem;
        import mx.core.IDeferredInstance;
        import mx.core.ClassFactory;
        import mx.core.mx_internal;
        import mx.core.IPropertyChangeNotifier;
        import mx.utils.ObjectProxy;
        import mx.containers.Canvas;
        import SVGUI.CalcSizeBox;
        import mx.utils.UIDUtil;
        import SVGUI.TwoDayItem;
        import SVGUI.FourDayItem;
        import SVGUI.DayButton;
        import SVGUI.LockedOneDayItem;
        import mx.core.UIComponentDescriptor;
        import mx.containers.VBox;
        import mx.controls.Image;
        import mx.events.PropertyChangeEvent;
        import mx.controls.Spacer;
        import flash.events.Event;
        import mx.core.IFactory;
        import SVGUI.ThreeDayItem;
        import mx.core.DeferredInstanceFromClass;
        import mx.binding.BindingManager;
        import SVGUI.SecondaryItem;
        import SVGUI.DaySpacer;
        import flash.events.IEventDispatcher;

        var tempWatcher:mx.binding.Watcher;

        // writeWatcher id=1 shouldWriteSelf=false class=flex2.compiler.as3.binding.PropertyWatcher shouldWriteChildren=true

        // writeWatcher id=2 shouldWriteSelf=false class=flex2.compiler.as3.binding.PropertyWatcher shouldWriteChildren=true


        // writeWatcherBottom id=1 shouldWriteSelf=false class=flex2.compiler.as3.binding.PropertyWatcher

 





        // writeWatcherBottom id=2 shouldWriteSelf=false class=flex2.compiler.as3.binding.PropertyWatcher

 






        bindings[0].uiComponentWatcher = 1;
        bindings[0].execute();
        bindings[1].uiComponentWatcher = 2;
        bindings[1].execute();
        bindings[2].uiComponentWatcher = 1;
        bindings[2].execute();
    }
}

}
