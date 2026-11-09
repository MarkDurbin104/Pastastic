package 
{

import flash.display.Sprite;
import mx.core.IFlexModuleFactory;
import mx.core.mx_internal;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.skins.halo.RadioButtonIcon;

[ExcludeClass]

public class _RadioButtonStyle
{

    public static function init(fbs:IFlexModuleFactory):void
    {
        var style:CSSStyleDeclaration = StyleManager.getStyleDeclaration("RadioButton");
    
        if (!style)
        {
            style = new CSSStyleDeclaration();
            StyleManager.setStyleDeclaration("RadioButton", style, false);
        }
    
        if (style.defaultFactory == null)
        {
            style.defaultFactory = function():void
            {
                this.selectedDisabledIcon = mx.skins.halo.RadioButtonIcon;
                this.fontWeight = "normal";
                this.selectedOverIcon = mx.skins.halo.RadioButtonIcon;
                this.upSkin = null;
                this.overIcon = mx.skins.halo.RadioButtonIcon;
                this.overSkin = null;
                this.selectedDisabledSkin = null;
                this.selectedDownIcon = mx.skins.halo.RadioButtonIcon;
                this.disabledIcon = mx.skins.halo.RadioButtonIcon;
                this.textAlign = "left";
                this.cornerRadius = 7;
                this.selectedDownSkin = null;
                this.selectedUpSkin = null;
                this.selectedOverSkin = null;
                this.upIcon = mx.skins.halo.RadioButtonIcon;
                this.downSkin = null;
                this.selectedUpIcon = mx.skins.halo.RadioButtonIcon;
                this.disabledSkin = null;
                this.downIcon = mx.skins.halo.RadioButtonIcon;
            };
        }
    }
}

}
