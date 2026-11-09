package com.cykorsystems.effects
{
   import mx.effects.TweenEffect;
   import mx.effects.EffectInstance;
   import mx.effects.IEffectInstance;
   import mx.effects.Rotate;
   import mx.effects.effectClasses.RotateInstance;

   public class ScaleTween extends TweenEffect
   {
       public var magFrom:Number = 0;
       public var magTo:Number = 0;
  
       public function ScaleTween(targetObj:* = null) {
           super(targetObj);
           instanceClass= ScaleTweenInstance;            
       }

       override public function getAffectedProperties():Array {
           return ["magnitude"];
       }
    
       override protected function initInstance(inst:IEffectInstance):void {
           super.initInstance(inst);
           ScaleTweenInstance(inst).magFrom = magFrom;
           ScaleTweenInstance(inst).magTo = magTo;
       } 
   }
}
