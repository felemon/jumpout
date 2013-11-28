package com.jumpout.display
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	
	public class Loading extends Sprite
	{
		private var nums:int = 10;
		private var m2:Matrix = new Matrix();
		private var m:Matrix =  new Matrix();
		private var Abar:Array = new Array();
		private var segAngle:Number;
		private var seg:Number;
		private var j:Number = 0;
		private var timer:Timer =  new Timer(100);
		public function Loading()
		{
			segAngle = 2 * Math.PI / this.nums;
			seg = 1 / this.nums;
			for (var i:int = 0; i < this.nums; i++)
			{
				var bar:Shape=new Shape();
				Abar[i] = bar;
				bar.graphics.beginFill(0xffffff);
//				bar.graphics.drawRoundRect(0,0,10,3,4,4);
				bar.graphics.drawCircle(4, 4, 4);
				bar.graphics.endFill();
				this.addChild(bar);
				//bar.alpha = seg * i;
				bar.x = bar.y = 0;
				m.identity();
				m.translate(20,-1);
				m.rotate(segAngle*i);
				m.translate(-20,1);
				m2.identity();
				m2.translate(0,0);
				m.concat(m2);
				bar.transform.matrix = m;
			}
			timer.addEventListener(TimerEvent.TIMER,alphaHalder);
			timer.start();
		}
		
		private function alphaHalder(evt:TimerEvent):void
		{
			for (var i:int = 0; i < this.nums; i++)
			{
				var bar:Shape = Abar[i] as Shape;
				bar.alpha = j;
				if(j >= 1)
				{
					j = 0;
				}
				j += seg;
			}
		}
	}
}