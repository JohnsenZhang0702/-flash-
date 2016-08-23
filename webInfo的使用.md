## 示例代码
```
package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	
	import webinfoutils.WebInfo;
	import webinfoutils.events.WebInfoUtilEvent;
	import flash.net.URLRequest;
	
	public class TestLocation extends Sprite
	{	
		private var webInfo:WebInfo = WebInfo.getInstance();
		
		private var m_gotoGameBtn:Sprite = new Sprite();
		
		public function TestLocation()
		{
			/**初始化webInfo类库的使用**/
			webInfo.initParam("000001","http://www.v1h5.com","123456");
			
			webInfo.addEventListener(WebInfoUtilEvent.DATA_SENDED,webInfoDataSendedHandler);
			
			webInfo.sendShowData();
			/****************************/
			m_gotoGameBtn.addEventListener(MouseEvent.CLICK,gotoGameBtnClickHandler);
		}
		
		protected function gotoGameBtnClickHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			/**点击按钮跳转后向后台发送消息**/
			webInfo.sendClickData();
			/******************************/
		}		
		
		protected function webInfoDataSendedHandler(evt:WebInfoUtilEvent):void{
			if(evt.gotoTagUrl){
				navigateToURL(new URLRequest(evt.gotoTagUrl), '_blank');
			}
		}

	}
}
```