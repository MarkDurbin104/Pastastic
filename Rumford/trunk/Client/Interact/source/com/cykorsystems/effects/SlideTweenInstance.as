package com.cykorsystems.effects
{
    import mx.effects.effectClasses.TweenEffectInstance;
    import mx.effects.Tween;

    public class SlideTweenInstance extends TweenEffectInstance
    {
        public var percentFrom:Number;
        public var percentTo:Number;
  
        public function SlideTweenInstance(targetObj:*) {
            super(targetObj);
        }
  
        override public function play():void {
            super.play();
            var tween:Tween = 
                createTween(this, percentFrom,percentTo, duration);  
        }

        override public function onTweenUpdate(val:Object):void {
            target.tweeningPosition=val;
        }
  
        override public function onTweenEnd(val:Object):void {
            super.onTweenEnd(val);
            target.onTweenComplete(val);
        }
    }
}