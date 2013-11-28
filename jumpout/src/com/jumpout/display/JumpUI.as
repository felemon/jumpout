package com.jumpout.display
{
	import caurina.transitions.Tweener;
	
	import com.jumpout.event.JumpEvent;
	import com.jumpout.tools.Base64;
	import com.jumpout.tools.HitTest;
	import com.jumpout.tools.JPGEncoder;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	import mx.core.TextFieldAsset;
	
	public class JumpUI extends Sprite
	{
		private var loader:Loader;
		[Embed(source="source/logo.swf", symbol="com.jumpout.head")]
		private var Logo:Class;
		[Embed(source="source/logo.swf", symbol="com.jumpout.descBtn")]
		private var descBtn:Class;
		private var descUI:Sprite;
		private var descText:TextField;
		private var textFormat:TextFormat = new TextFormat();
		private var logo:Sprite;
		private var inputText:TextField;
		private var inputUI:Sprite; //输入区域
		private var inputBtn:Sprite;//输入按钮
		private var tipUI:Sprite; //提示词
		private var contrlUI:Sprite; //控制区域：发布，返回
		private var childSp:Sprite;
		private var homeUI:Sprite;
		private var releaseUI:Sprite;//发布：公开，隐藏
		private var maxInputChars:uint = 10;
		private static var _instance:JumpUI;
		private var _descStr:String = "";
		private var postObj:Object = {};
		public static function instance():JumpUI
		{
			if(_instance){
				return _instance;
			}else{
				return new JumpUI();
			}
		}
		public function JumpUI()
		{
			this.graphics.beginFill(Config.background);
			this.graphics.drawRect(0, 0, Config.stage.stageWidth, Config.stage.stageHeight);
			this.graphics.endFill();
			
			logo = new Sprite();
			logo.addChild(new Logo());
			logo.buttonMode = true;
//			logo.addEventListener(MouseEvent.CLICK, logoClickHandler);
			this.addChild(logo);
			
			/*
			 * 输入区域
			 */
			inputUI = new Sprite(); 
			this.addChild(inputUI);
			
			inputBtn = new Sprite();
			inputBtn.buttonMode = true;
			inputBtn.graphics.beginFill(0x42DED4);
			inputBtn.graphics.drawRoundRect(38, 97, 162, 38, 20, 20);
			inputBtn.graphics.endFill();
			inputBtn.graphics.beginFill(0x42DED4, 0);
			inputBtn.graphics.lineStyle(1.5, Config.textColor);
			inputBtn.graphics.drawCircle(114, 114, 114);
			inputBtn.graphics.endFill();
			
			inputText = createTextField("输入", 20);
			inputText.selectable = true;
			inputText.mouseEnabled = true;
			inputText.type = TextFieldType.INPUT;
			inputText.width = 162;
			inputText.x = (inputBtn.width - inputText.width)/2;
			inputText.y = (inputBtn.height - inputText.height)/2;
			inputText.addEventListener(TextEvent.TEXT_INPUT, inputHandler);
			inputText.addEventListener(FocusEvent.FOCUS_IN, inputFocusHandler);
			inputText.addEventListener(FocusEvent.FOCUS_OUT, inputFocusHandler);
			inputBtn.addChild(inputText);
			
			inputBtn.addEventListener(MouseEvent.CLICK, inputBtnHandler);
			inputBtn.addEventListener(MouseEvent.ROLL_OVER, inputBtnHandler);
			inputBtn.addEventListener(MouseEvent.ROLL_OUT, inputBtnHandler);
			inputUI.addChild(inputBtn);
		
			//提示词
			tipUI = new Sprite();
			tipUI.graphics.beginFill(Config.textColor);
			tipUI.graphics.drawRoundRect(0, 0, 288, 40, 20, 20);
			tipUI.graphics.drawRoundRectComplex(99, 40, 90, 45, 0, 0, 45, 45);//绘制半圆
			tipUI.graphics.endFill();
			tipUI.alpha = 0;
			tipUI.visible = false;
			inputUI.addChild(tipUI);
			
			var tipText:TextField = new TextField();
			tipText = createTextField("输入一个词语，跳出你的想法", 20, Config.background);
			tipText.width = inputUI.width;
			tipText.y = 8;
			tipUI.addChild(tipText);
			
			homeUI = new Sprite();
			homeUI.graphics.beginFill(Config.textColor);
			homeUI.graphics.drawRoundRectComplex(0, 0, 60, 30, 30, 30, 0, 0);
			homeUI.graphics.endFill();
			homeUI.buttonMode = true;
			homeUI.addEventListener(MouseEvent.CLICK, homeClickHandler);
			this.addChild(homeUI);
			
			var homeBtn:TextField = createTextField("主页", 16, Config.background);
			homeBtn.x = 12;
			homeBtn.y = 8;
			homeUI.addChild(homeBtn);
			
			/*
			 * 控制区域：发布 + 返回
			 */
			contrlUI = new Sprite();
			contrlUI.graphics.beginFill(Config.textColor);
			contrlUI.graphics.drawRoundRectComplex(0, 0, 94, 47, 47, 47, 0, 0);
			contrlUI.graphics.endFill();
			contrlUI.graphics.lineStyle(1, Config.background);
			contrlUI.graphics.moveTo(47, 17);
			contrlUI.graphics.lineTo(47, 42);
			this.addChild(contrlUI);
			contrlUI.visible = false;
			
			releaseUI = new Sprite();
			contrlUI.addChild(releaseUI);
			var pubBtn:Sprite = createReleBtn("公开");
			pubBtn.x = -25;
			pubBtn.addEventListener(MouseEvent.CLICK, pubBtnClickHanlder);
			releaseUI.addChild(pubBtn);
			var priBtn:Sprite = createReleBtn("隐私");
			priBtn.x = 75;
			priBtn.addEventListener(MouseEvent.CLICK, priBtnClickHanlder);
			releaseUI.addChild(priBtn);
			releaseUI.x = (contrlUI.width - releaseUI.width)/2;
			releaseUI.y = contrlUI.height - releaseUI.height - 40;
			releaseUI.visible = false;
			
			var releaseBtn:Sprite = new Sprite();
			releaseBtn.buttonMode = true;
			releaseBtn.addChild(createTextField("发布", 16, Config.background));
			releaseBtn.x = 6;
			releaseBtn.y = 20;
			releaseBtn.addEventListener(MouseEvent.CLICK, releaseHandler);
			contrlUI.addChild(releaseBtn);
			var returnBtn:Sprite = new Sprite();
			returnBtn.buttonMode = true;
			returnBtn.addChild(createTextField("返回", 16, Config.background));
			returnBtn.addEventListener(MouseEvent.CLICK, returnHandler);
			returnBtn.x = 53;
			returnBtn.y = 20;
			contrlUI.addChild(returnBtn);
			
			/*
			 *  文字描述
			 */
			descUI = new Sprite();
			descUI.visible = false;
			descUI.graphics.beginFill(Config.textColor);
			descUI.graphics.drawRoundRect(0, 0, 580, 240, 30, 30);
			descUI.graphics.endFill();
			descText = createTextField("说点什么来描述一下你的想法......", 20, Config.descColor);
			var format:TextFormat = descText.defaultTextFormat;
			format.align = TextFormatAlign.LEFT;
			descText.setTextFormat(format);
			descText.defaultTextFormat = format;
			descText.selectable = true;
			descText.mouseEnabled = true;
			descText.type = TextFieldType.INPUT;
			descText.maxChars = 200;
			descText.wordWrap = true;
			descText.multiline = true;
			descText.x = 10;
			descText.y = 10;
			descText.width = 560;
			descText.height = 220;
			descText.addEventListener(FocusEvent.FOCUS_IN, descFocusHandler);
			descText.addEventListener(FocusEvent.FOCUS_OUT, descFocusHandler);
			descUI.addChild(descText);
			var descBtn:SimpleButton = new descBtn();
			descBtn.x = descUI.width - descBtn.width - 20;
			descBtn.y = descUI.height - descBtn.height - 10;
			descBtn.addEventListener(MouseEvent.CLICK, descBtnClickHandler);
			descUI.addChild(descBtn);
			this.addChild(descUI);
	
			/*
			 * 存放圈圈的位置 
			 */
			childSp = new Sprite();
			this.addChildAt(childSp, 0);
			
			this.updatePos();
			
			Config.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			Config.stage.addEventListener(JumpEvent.NewCircle, createJumpCircle);	
			Config.stage.addEventListener(Event.RESIZE, updatePos);
		}
		
		protected function homeClickHandler(event:MouseEvent):void
		{
			navigateToURL(new URLRequest(Config.HOME_URL), '_self');
		}
		
		protected function updatePos(event:Event = null):void
		{
			logo.x = (Config.stage.stageWidth - logo.width)/2;
			logo.y = 40;
			
			inputBtn.x = (Config.stage.stageWidth - inputBtn.width)/2;
			inputBtn.y = (Config.stage.stageHeight - inputBtn.height)/2  + (logo.y + logo.height)/2;
			
			tipUI.x = (Config.stage.stageWidth - tipUI.width)/2;
			tipUI.y =  inputBtn.y - tipUI.height + 30;
			
			contrlUI.x = (Config.stage.stageWidth - 98)/2;
			contrlUI.y = Config.stage.stageHeight - 47;
			
			homeUI.x = (Config.stage.stageWidth - homeUI.width)/2;
			homeUI.y = Config.stage.stageHeight - homeUI.height;
			
			descUI.x = (Config.stage.stageWidth - descUI.width)/2;
			descUI.y = (Config.stage.stageHeight - descUI.height)/2;
		}
		
		protected function descBtnClickHandler(event:MouseEvent):void
		{
			this.postObj.text = descText.text;
			this.descUI.visible = false;
			this.releaseUI.visible = false;
			
			var _encoder:JPGEncoder = new JPGEncoder(100);//用于编码位图
			var bitmapData:BitmapData = new BitmapData(Config.stage.stageWidth, Config.stage.stageHeight - 50);
			bitmapData.draw(this);//得到位图
			var bytes:ByteArray = _encoder.encode(bitmapData);//编码成JPG图片，质量为100
			var jpgString:String = Base64.encodeByteArray(bytes);
			
			
			var variables:URLVariables = new URLVariables(); 
			variables.img = String(jpgString);
			variables.text = String(this.postObj.text);
			variables.type = String(this.postObj.type);

			var req:URLRequest = new URLRequest(Config.UPLOAD_URL);
			req.data = variables;
			req.method = URLRequestMethod.POST;
			req.contentType = 'application/x-www-form-urlencoded';
			
			var loader:URLLoader = new URLLoader();
//			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.addEventListener(Event.COMPLETE, uploadCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.load(req);
		}
		
		private function descFocusHandler(event:FocusEvent):void
		{
			var tf:TextField = event.target as TextField;
			switch(event.type){
				case FocusEvent.FOCUS_IN:
					if(tf.text == "说点什么来描述一下你的想法......") tf.text = "";
					break;
				case FocusEvent.FOCUS_OUT:
					if(tf.text == "") tf.text = "说点什么来描述一下你的想法......"
					break;
			}
		}
		
		private function inputHandler(event:TextEvent):void
		{
			var _ba:ByteArray = new ByteArray;
			_ba.writeMultiByte(inputText.text,"");
			if(_ba.length > this.maxInputChars){
				event.preventDefault();
			}
		}
		
//		protected function logoClickHandler(event:MouseEvent):void
//		{
//			var request:URLRequest = new URLRequest(Config.website);
//			navigateToURL(request);
//		}
		
		protected function keyHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.ENTER:
				{
					jumpout();
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		private function inputBtnHandler(event:MouseEvent):void
		{
			switch(event.type){
				case MouseEvent.CLICK:
					jumpout();
					break;
				case MouseEvent.ROLL_OVER:
					tipUI.visible = true;
					Tweener.removeTweens(tipUI);
					Tweener.addTween(tipUI, {
						alpha : 1,
						transition: "easeInQuint",
						time : 0.5
					});
					break;
				case MouseEvent.ROLL_OUT:
					Tweener.removeTweens(tipUI);
					Tweener.addTween(tipUI, {
						alpha : 0,
						transition: "easeOutQuint",
						time : 0.5,
						onComplete : function():void{
							tipUI.visible = false;
						}
					});
					break;
			}
		}
		
		private function jumpout():void
		{
			if(inputText.text != "" && inputText.text != "输入"){		
				Config.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
				inputUI.visible = false;	
				logo.visible = false;
				homeUI.visible = false;
				var circle:JumpCircle = new JumpCircle(inputText.text);
				circle.x = (Config.stage.stageWidth - circle.centerRadius)/2;
				circle.y = Config.stage.stageHeight/2 - circle.centerRadius + (logo.y + logo.height)/2;
				childSp.addChild(circle);
				contrlUI.visible = true;
			}
		}
		
		private function returnHandler(event:MouseEvent):void
		{
			childSp.removeChildren();
			contrlUI.visible = false;
			descUI.visible = false;
			descText.text = "说点什么来描述一下你的想法......";
			inputUI.visible = true;
			logo.visible = true;
			homeUI.visible = true;
			inputText.text = "输入";
			Config.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		}
		
		private function priBtnClickHanlder(event:MouseEvent):void
		{
			this.descUI.visible = true;
			this.postObj.type = "private";
		}
		
		private function pubBtnClickHanlder(event:MouseEvent):void
		{
			this.descUI.visible = true;
			this.postObj.type = "public";
		}
		
		protected function errorHandler(event:IOErrorEvent):void
		{
			trace(event);
		}
		
		protected function uploadCompleteHandler(event:Event):void
		{
			trace("上传成功了");
			try{
				var obj:Object = JSON.parse(event.target.data);
				if(obj && obj.is_login == 0){
					if(ExternalInterface.available){
						ExternalInterface.call("gam.register");
					}
				}else{
					navigateToURL(new URLRequest(Config.HOME_URL), "_self");
				}
			}catch(e:Error){
				trace("make_img返回数据解析错误");
			}
			
		}
		private function createReleBtn(text:String):Sprite
		{
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(Config.textColor);
			sp.graphics.drawCircle(20, 20, 20);
			sp.graphics.endFill();
			sp.buttonMode = true;
			var tf:TextField = createTextField(text, 18, Config.background);
			tf.y = 10;
			sp.addChild(tf);
			return sp;
		}
		private function releaseHandler(event:MouseEvent):void
		{
			this.releaseUI.visible = !this.releaseUI.visible;
		}
		private function inputFocusHandler(event:FocusEvent):void
		{
			switch(event.type){
				case FocusEvent.FOCUS_IN:
					if(inputText.text == "输入") inputText.text = "";
					break;
				case FocusEvent.FOCUS_OUT:
					if(inputText.text == "")inputText.text = "输入";
					break;
			}
		}
		private function createJumpCircle(event:JumpEvent):void
		{
			var baseCircle:JumpCircle = event.base;
			var newCircle:JumpCircle = new JumpCircle(event.text);
			newCircle.x = Math.min(Math.max(135, event.stageX), Config.stage.stageWidth - 135);
			newCircle.y = Math.min(Math.max(135, event.stageY), Config.stage.stageHeight - 185);
			childSp.addChild(newCircle);
			childSp.addChildAt(new ArrowLine(baseCircle, newCircle), 0);
		}
	
		private function createTextField(text:String, size:uint, color:uint = Config.textColor, font:String = Config.FONT):TextField
		{
			textFormat.font = font;
			textFormat.size = size;
			textFormat.color = color;
			textFormat.align = TextFormatAlign.CENTER;
		
			var tf:TextField = new TextField();
			tf.defaultTextFormat = textFormat;
			tf.setTextFormat(textFormat);
			tf.text = text;
			tf.width = tf.textWidth + 5;
			tf.height = tf.textHeight + 5;
			tf.selectable = false;
			tf.mouseEnabled = false;
			return tf;
		}
	}
}