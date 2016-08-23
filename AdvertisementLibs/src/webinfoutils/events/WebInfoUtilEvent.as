package webinfoutils.events
{
	import flash.events.Event;
	
	public class WebInfoUtilEvent extends Event
	{
		
		public static const DATA_SENDED:String = "dataSended";
		
		public var sendResultMsg:String = "";
		
		public var gotoTagUrl:String = null;
		
		public function WebInfoUtilEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var evt:WebInfoUtilEvent = new WebInfoUtilEvent(type,bubbles,cancelable);
			evt.sendResultMsg = this.sendResultMsg;
			evt.gotoTagUrl = this.gotoTagUrl;
			return evt;
		}
	}
}