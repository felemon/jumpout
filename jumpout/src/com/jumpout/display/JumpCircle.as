package com.jumpout.display
{
	import caurina.transitions.Tweener;
	
	import com.jumpout.event.JumpEvent;
	
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.engine.TextElement;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.tlf_internal;
	
	public class JumpCircle extends Sprite
	{
		private var _word:String;
		private var _center:Sprite;
		private var _childWords:Sprite;
	
		private var _textFormat:TextFormat = new TextFormat();
		private var _centerRadius:Number = 54;
		private var _centerTextSize:Number = 48;
		private var _childRadius:Number = 27;
		private var _childTextSize:Number = 16;
		private var _radius:Number = 108;
		private var _oldX:Number = 0;
		private var _oldY:Number = 0;
		private var _offset:Point;
		private var _isClick:Boolean = true;
		private var _showState:Boolean = false;
		private var _map:Dictionary = new Dictionary();
		private var _removedMap:Object = {};
		
		private var _loader:URLLoader;
		private var _arr:Array;
		private var _tweenerComplete:Boolean = false; //动画是否完成
		private var _loading:Loading;
		public function JumpCircle(word:String, showState:Boolean = false)
		{	
			this._word = word;
			_loader = new URLLoader();
			_loader.addEventListener(IOErrorEvent.IO_ERROR, error);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
			_loader.addEventListener(Event.COMPLETE, completeHandler);
			try {
				_loader.load(new URLRequest('http://115.28.161.188/index.php/Search/index/search_field/' + encodeURI(word)));
//				_loader.load(new URLRequest(Config.SEARCH_URL + encodeURI(word)));
			} catch (error:Error) {
				trace("加载词语时出错");
			}
			
			if(word.length > 5 ){
				_centerTextSize = 18;
			}else if(word.length > 3){
				_centerTextSize = 24;
			}else if(word.length > 2){
				_centerTextSize = 36;
			}
			
			/**
			 * loading的位置待完善
			 */
			_loading = new Loading();
			_loading.x = 20;
			_loading.y = 1;
			this.addChild(_loading);
			
			_center = createCircle(word, this._centerTextSize, this._centerRadius, 3);	
			_center.addEventListener(MouseEvent.MOUSE_DOWN, centerDragHandler);
			_center.addEventListener(MouseEvent.MOUSE_UP, centerDragHandler);
			this.addChildAt(_center, 0);
			
		}
	
		private function error(event:Event):void
		{
			trace(event);	
		}
		
		private function inputHandler(event:TextEvent):void
		{
			var tf:TextField = event.target as TextField;
			var format:TextFormat = tf.defaultTextFormat;
			var _ba:ByteArray =new ByteArray;
			_ba.writeMultiByte(tf.text,"");
			if(_ba.length > 8){
				event.preventDefault();
				format.size = 12;
			}else{
				format.size = 14;
			}
			tf.defaultTextFormat = format;
			tf.setTextFormat(format);
			tf.x = 0 - tf.width/2;
			tf.y = 0 - tf.height/2;
		}
		
		private function completeHandler(event:Event):void
		{
			_loader.removeEventListener(Event.COMPLETE, completeHandler);
			if(this._loading) this.removeChild(_loading);
			try{
				var obj:Object = JSON.parse(event.target.data);
				if(obj.status != 1) return;
				_arr = obj.data;
				_childWords = createChildWords();
				this.addChildAt(_childWords, 0);			
				this.addEventListener(JumpEvent.CircleBack, addCircleHandlder);
				_center.addEventListener(MouseEvent.CLICK, centerDragHandler);
				
				Tweener.removeTweens(this);
				Tweener.addTween(this, {
					scaleX : 1.5,
					scaleY : 1.5,
					time : 0.5,
					transition : "easeInOutQuint"
				});
				
				Tweener.addTween(this, {
					scaleX : 1,
					scaleY : 1,
					transition: "easeOutQuint",
					time : 1,
					delay : 1
				});	
				
			}catch(error:Error){
				trace("解析出错了");
			}
		}
		
		protected function addCircleHandlder(event:JumpEvent):void
		{
			var obj:Object = _removedMap[event.text];
			if(obj){
				_childWords.addChild(obj.line);
				_childWords.addChild(obj.word);
				this.redraw();
			}
		}
		
		private function createChildWords():Sprite
		{
			var childWords:Sprite = new Sprite();
			var lineRadius:Number = this._radius - this._childRadius;
			var radian:Number = 2 * Math.PI / _arr.length;
			for(var i:int = _arr.length - 1; i >= 0; i--){
				var word:Sprite = createCircle(_arr[i], this._childTextSize, this._childRadius, 1);
				var self:JumpCircle = this;
				
				word.addEventListener(MouseEvent.MOUSE_DOWN, dragHandler);
				word.addEventListener(MouseEvent.MOUSE_UP, dragHandler);	
				var line:Shape = new Shape();
				
				(function(_i:int, _line:Shape):void{
					var posX:Number =  self._radius * Math.sin(Math.PI - radian * _i), posY:Number = self._radius * Math.cos(Math.PI - radian * _i);
					Tweener.addTween(word, {
						x : posX,
						y : posY,
						transition: "easeInBounce",
						time : 0.4 + 0.1*_i,
						alpha : 1,
						onComplete : function():void{
							_line.graphics.lineStyle(1, Config.textColor);
							_line.graphics.moveTo(0, 0);
							_line.graphics.lineTo(posX, posY);
							_map[this] = {"line":_line};
							if(_i == _arr.length - 1) self._tweenerComplete = true; //最后一个动画执行完
						}
					});					
				})(i, line);	
				childWords.addChild(line);
				childWords.addChild(word);
			}
			return childWords;
		}
		
		private function centerDragHandler(event:MouseEvent):void
		{
			switch(event.type){
				case MouseEvent.MOUSE_DOWN:
					this._isClick = true;
					this._oldX = event.stageX;
					this._oldY = event.stageY;
					Config.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageHandler);
					Config.stage.addEventListener(MouseEvent.MOUSE_UP, stageHandler);
					this._offset = new Point(-event.stageX, -event.stageY);
					break;
				case MouseEvent.MOUSE_UP:
					if(event.stageX != this._oldX || event.stageY != this._oldY){
						this._isClick = false;
					}
					break;
				case MouseEvent.CLICK:	
					if(this._isClick){						
						_childWords.visible = this._showState;
						this._showState = !this._showState;
					}
					break;
				
			}		
		}
		
		private function stageHandler(event:MouseEvent):void
		{
			switch(event.type){
				case MouseEvent.MOUSE_MOVE:
					Tweener.addTween(this, {
						x : Math.min(Math.max(135, event.stageX), Config.stage.stageWidth - 135),
						y : Math.min(Math.max(135, event.stageY), Config.stage.stageHeight - 185),
						time: 0.5
					});
					this.dispatchEvent(new JumpEvent(JumpEvent.DRAG));
					break;
				case MouseEvent.MOUSE_UP:
					Config.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageHandler);
					Config.stage.removeEventListener(MouseEvent.MOUSE_UP, stageHandler);
					break;
			}
		}
				
		private function redraw():void
		{
			var len:int = _childWords.numChildren/2;
			var radian:Number = 2 * Math.PI / len;
			for(var i:int = 0; i < len; i++){
				var word:Sprite = Sprite(_childWords.getChildAt(i*2 + 1)), line:Shape = _map[word].line;
				word.x = this._radius * Math.sin(radian * i);
				word.y = this._radius * Math.cos(radian * i);

				line.graphics.clear();
				line.graphics.lineStyle(1, Config.textColor);
				line.graphics.moveTo(0, 0);
				line.graphics.lineTo(word.x, word.y);
				
				_map[word] = {"line":line};
			}
		}
		private function dragHandler(event:MouseEvent):void
		{
			if(!this._tweenerComplete) return;
			
			var word:Sprite;
			if(event.target as TextField){
				word = Sprite(event.target.parent);
			}else{
				word = Sprite(event.target);
			}
			var line:Shape = _map[word].line, text:String = TextField(word.getChildByName("tf")).text;
			switch(event.type){
				case MouseEvent.MOUSE_DOWN:
					word.addEventListener(MouseEvent.MOUSE_MOVE, dragHandler);
					if(text!="输入" && text!="") word.startDrag();
					break;
				case MouseEvent.MOUSE_UP:
					word.removeEventListener(MouseEvent.MOUSE_MOVE, dragHandler);
					word.stopDrag();
					if(Math.sqrt(Math.pow(word.x, 2) + Math.pow(word.y, 2)) > Config.distance){
						var e:JumpEvent = new JumpEvent(JumpEvent.NewCircle, event.stageX, event.stageY);
						e.text = text;
						e.base = this;
						Config.stage.dispatchEvent(e);		
						word.parent.removeChild(line);
						word.parent.removeChild(word);
						_removedMap[text] = {"word":word, "line":line};
						this.redraw();
					}
					break;
				case MouseEvent.MOUSE_MOVE:
					line.graphics.clear();
					line.graphics.lineStyle(1, Config.textColor);
					line.graphics.moveTo(0, 0);
					line.graphics.lineTo(word.x, word.y);
					
					break;
			}		
		}

		
		private function createCircle(word:String, fontSize:uint, radius:Number, thickness:Number):Sprite //圆心为(0, 0)
		{
			var sp:Sprite = new Sprite();
			sp.graphics.lineStyle(thickness, Config.textColor);
			sp.graphics.beginFill(Config.background, 1);
			sp.graphics.drawCircle(0, 0, radius);
			sp.graphics.endFill();
			var tf:TextField = createTextField(word, fontSize);
			tf.x = 0 - tf.width/2;
			tf.y = 0 - tf.height/2;
			tf.name = "tf";
			sp.addChild(tf);
			sp.buttonMode = true;
			return sp;
		}

		private function createTextField(text:String, size:uint, color:uint = Config.textColor, font:String = Config.FONT):TextField
		{
			_textFormat.size = size;
			_textFormat.color = color;
			_textFormat.font = Config.FONT;
			if(text.length > 3 && text.charCodeAt(0) > 255){
				_textFormat.size = Number(_textFormat.size) - 4;
			}
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = _textFormat;
			tf.setTextFormat(_textFormat);
			tf.text = text;	
			tf.height = tf.textHeight + 5;
		
			if(tf.text == "输入"){
				tf.width = this._childRadius;
				tf.type = TextFieldType.INPUT;
				tf.autoSize = TextFieldAutoSize.CENTER;
				tf.addEventListener(TextEvent.TEXT_INPUT, inputHandler);
				tf.addEventListener(FocusEvent.FOCUS_IN, inputFocusHandler);
				tf.addEventListener(FocusEvent.FOCUS_OUT, inputFocusHandler);
			}else{
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.selectable = false;
				tf.mouseEnabled = false;
			}		
			return tf;
		}
		
		private function inputFocusHandler(event:FocusEvent):void
		{
			event.stopPropagation();
			var tf:TextField = event.target as TextField;
			switch(event.type){
				case FocusEvent.FOCUS_IN:
					if(tf.text == "输入") tf.text = "";
					break;
				case FocusEvent.FOCUS_OUT:
					if(tf.text == "") {
						tf.text = "输入"
					}else{
						tf.removeEventListener(TextEvent.TEXT_INPUT, inputHandler);
						tf.type = TextFieldType.DYNAMIC;
						tf.selectable = false;
						tf.mouseEnabled = false;
					}	
					break;
			}
		}
		public function get centerRadius():Number
		{
			return this._centerRadius;
		}
		public function get word():String
		{
			return this._word;
		}
		
		public function get center():Sprite
		{
			return this._center;
		}
		public function dispose():void
		{
			Tweener.removeTweens(this);
			if(_loader){				
				_loader.removeEventListener(IOErrorEvent.IO_ERROR, error);
				_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
				_loader.removeEventListener(Event.COMPLETE, completeHandler);
			}
			_center.removeEventListener(MouseEvent.MOUSE_DOWN, centerDragHandler);
			_center.removeEventListener(MouseEvent.MOUSE_UP, centerDragHandler);
			_center.removeEventListener(MouseEvent.CLICK, centerDragHandler);
		}
	}
}