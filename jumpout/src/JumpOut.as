package
{
	import com.jumpout.display.JumpUI;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.ApplicationDomain;
	
	[SWF(width="1000",height="560",backgroundColor="0x52cec4",frameRate="20")]
	public class JumpOut extends Sprite
	{
		public function JumpOut()
		{
			if(stage){
				init();
			}else{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		private function init(event:Event = null):void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			Config.stage = stage;
			var ui:JumpUI = JumpUI.instance();
			this.addChild(ui);
		}
	}
}