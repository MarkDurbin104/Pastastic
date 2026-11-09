package com.cykorsystems.effects
{
    import mx.effects.effectClasses.TweenEffectInstance;
    import mx.effects.Tween;
    import flash.geom.Rectangle;

    public class ScaleTweenInstance extends TweenEffectInstance
    {
        public var magFrom:Number;
        public var magTo:Number;
  
        public function ScaleTweenInstance(targetObj:*) {
            super(targetObj);
        }
  
        override public function play():void {
            super.play();
            var tween:Tween = 
                createTween(this,magFrom,magTo,duration);  
        }

        override public function onTweenUpdate(val:Object):void {
            target.magnitude=val;
        }
  
        override public function onTweenEnd(val:Object):void {
            super.onTweenEnd(val);
            target.onSetMagnitudeComplete(val);
        }
    }
}