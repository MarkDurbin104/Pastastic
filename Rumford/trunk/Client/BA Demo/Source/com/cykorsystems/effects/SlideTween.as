package com.cykorsystems.effects
{
   import mx.effects.TweenEffect;
   import mx.effects.EffectInstance;
   import mx.effects.IEffectInstance;
   import mx.effects.Rotate;
   import mx.effects.effectClasses.RotateInstance;

   public class SlideTween extends TweenEffect
   {
       public var percentFrom:Number = 0;
       public var percentTo:Number = 0;
  
       public function SlideTween(targetObj:* = null) {
           super(targetObj);
           instanceClass= SlideTweenInstance;            
       }

       override public function getAffectedProperties():Array {
           return ["tweeningPosition"];
       }
    
       override protected function initInstance(inst:IEffectInstance):void {
           super.initInstance(inst);
           SlideTweenInstance(inst).percentFrom = percentFrom;
           SlideTweenInstance(inst).percentTo = percentTo;
       } 
   }
}
