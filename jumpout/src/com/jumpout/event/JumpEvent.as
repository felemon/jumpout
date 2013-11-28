package com.jumpout.event
{
	import com.jumpout.display.JumpCircle;
	
	import flash.events.Event;
	
	public class JumpEvent extends Event
	{
		public static const NewCircle:String = "newCircle";
		public static const CircleBack:String = "circleBack";
		public static const UpdatePos:String = "updatePos";
		public static const DRAG:String = "drag";
		public var text:String = "";
		public var base:JumpCircle = null;
		public var stageX:Number = 0;
		public var stageY:Number = 0;
		public function JumpEvent(type:String, stageX:Number = 0, stageY:Number = 0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.stageX = stageX;
			this.stageY = stageY;
		}
	}
}