package com.jumpout.display
{
	import caurina.transitions.Tweener;
	
	import com.jumpout.event.JumpEvent;
	import com.jumpout.tools.HitTest;
	
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ArrowLine extends Sprite
	{
		private var _base:JumpCircle;
		private var _new:JumpCircle;
		private var bevel:Number;//斜边
		private var x1:Number;
		private var y1:Number;
		private var x2:Number;
		private var y2:Number;
		
		public function ArrowLine(baseCircle:JumpCircle, newCircle:JumpCircle)
		{
			this._base = baseCircle;
			this._new = newCircle;
			
			bevel = Math.sqrt(Math.pow(_new.x - _base.x, 2) + Math.pow(_new.y - _base.y, 2)); //斜边
			x1 = _base.x;
			y1 = _base.y;
			x2 = (_new.x - _base.x)*(bevel - _new.centerRadius)/bevel + _base.x;
			y2 = (_new.y - _base.y)*(bevel - _new.centerRadius)/bevel +  + _base.y;
			_base.addEventListener(JumpEvent.DRAG, baseCircleDragHandler);
			_new.addEventListener(JumpEvent.DRAG, newCircleDragHandler);
			this.drawArrowWithVector(this.graphics, x1, y1, x2, y2);
			this.addEventListener(Event.ENTER_FRAME, testBaseHandler);
			
		}

		protected function testBaseHandler(event:Event):void
		{
//			this.removeNew();
			if(_base.parent == null){
				removeNew(true);
			}
		}
		
		protected function newCircleDragHandler(event:Event):void
		{
			bevel = Math.sqrt(Math.pow(_new.x - _base.x, 2) + Math.pow(_new.y - _base.y, 2));
			x2 = (_new.x - _base.x)*(bevel - _new.centerRadius)/bevel + _base.x;
			y2 = (_new.y - _base.y)*(bevel - _new.centerRadius)/bevel +  + _base.y;
			this.drawArrowWithVector(this.graphics, x1, y1, x2, y2);
			removeNew();
		}
		
		protected function baseCircleDragHandler(event:Event):void
		{
			bevel = Math.sqrt(Math.pow(_new.x - _base.x, 2) + Math.pow(_new.y - _base.y, 2));
			x1 = _base.x;
			y1 = _base.y;
			this.drawArrowWithVector(this.graphics, x1, y1, x2, y2);
			removeNew();
		}
		
		private function drawArrowWithVector(g:Graphics, x1:int,y1:int,x2:int,y2:int):void {
			//箭头长度
			var len:int = 10;
			//箭头与直线的夹角
			var _a:int = 30;
			var angle:int = Math.atan2((y1-y2), (x1-x2))*(180/Math.PI);
			g.clear();
			g.lineStyle(6, Config.textColor);
			g.moveTo(x2,y2);
			g.lineTo(x2+len*Math.cos((angle-_a)*(Math.PI/180)), y2+len*Math.sin((angle-_a)*(Math.PI/180)));
			g.moveTo(x2,y2);
			g.lineTo(x2+len*Math.cos((angle+_a)*(Math.PI/180)), y2+len*Math.sin((angle+_a)*(Math.PI/180)));
			g.moveTo(x1,y1);
			g.lineTo(x2,y2);   	
		}
		
		private function removeNew(baseRemoved:Boolean = false):void{
			if(HitTest.complexHitTestObject(_base,_new)|| baseRemoved){
				//移除newCircle及连线
				if(_new.parent && this.parent){
					_new.dispose();
					_new.parent.removeChild(_new);
					this.parent.removeChild(this);
					var e:JumpEvent = new JumpEvent(JumpEvent.CircleBack);
					e.text = _new.word;
					_base.dispatchEvent(e);
				}
			}
		}
	}
}