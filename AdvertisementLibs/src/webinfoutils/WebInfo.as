package webinfoutils
{	
	import com.adobe.crypto.MD5;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;
	
	import webinfoutils.events.WebInfoUtilEvent;

	public class WebInfo extends EventDispatcher
	{
		private static var m_instance:WebInfo;
		
		private const PAGE_POS_VALUES:Object = {
			"T":"top",
			"R":"right",
			"B":"bottom",
			"L":"left",
			"RT":"rightAndTop",
			"LT":"leftAndTop",
			"RB":"rightAndBottom",
			"LB":"leftAndBottom"
		};
		
		private const SECRET_KEY:String = "gameadkey";
		
		private const DOMAIN:String = "http://pay.v1h5.com/adstat/";
		
		private const SERVICES:Object = {
			"showAndClick":"showAndClick",
			"crossDomain":"crossdomain.xml"
		};
		
		private const OPTION_TYPES:Object = {
			"show":"show",
			"click":"click"
		}
			
		private var m_getUrlJSStr:String = ['function(){' +
				'var url = null;' +
				'try{' +
					'url = top.location.href;' +
				'}catch(e){' +
					'url = document.referrer;' +
				'}' +
				'return url;' +
			'}'].join('');
		
		private var m_gameId:String = "";
		
		private var m_posInPage:String = "noPos";
		
		private var m_pageLocation:String = "";
		
		private var m_sendLoader:URLLoader = null;
		
		private var m_isInit:Boolean = false;
		
		private var m_url:String = "";
		
		private var m_macCode:String = "";
		
		private var m_webInfoSendedEvent:WebInfoUtilEvent = new WebInfoUtilEvent(WebInfoUtilEvent.DATA_SENDED);
		
		public function WebInfo(single:Single)
		{	
			if(m_instance)
			{
				throw new Error("please use getInstance function",9999);
			}
			Security.loadPolicyFile(DOMAIN + SERVICES.crossDomain);
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
		}
		
		public static function getInstance():WebInfo
		{
			if(m_instance == null){
				m_instance = new WebInfo(new Single());
				m_instance.m_sendLoader = new URLLoader();
			}
			
			return m_instance;
		}
		
		public function initParam(gid:String,targetUrl:String,macCode:String):void
		{
			this.m_gameId = gid;
			this.m_macCode = macCode;
			this.m_pageLocation =  encodeURI (getPageUrl());
			this.m_url = targetUrl;
			this.m_isInit = true;
		}
		
		public function sendShowData():void
		{
			sendWebInfoService(OPTION_TYPES.show);
		}
		
		public function sendClickData():void
		{
			sendWebInfoService(OPTION_TYPES.click);
		}
		
		protected function getPageUrl():String
		{
			var pageUrl:String = "noUrl";
			if(ExternalInterface.available){
				pageUrl = ExternalInterface.call(m_getUrlJSStr);
				if(pageUrl == null){
					pageUrl = "noUrl";
				}
			}
			pageUrl = pageUrl.split("?")[0];
			return pageUrl;
		}
		
		protected function sendWebInfoService(optionType:String):void
		{
			if(m_isInit)
			{
				if(this.m_sendLoader == null){
					this.m_sendLoader = new URLLoader();
				}
				
				var veriables:URLVariables = new URLVariables();
				
				veriables.gameid = this.m_gameId;
				veriables.position = this.m_posInPage;
				veriables.source = this.m_pageLocation;
				veriables.macCode = this.m_macCode;
				veriables.time = (new Date().time * 0.001).toFixed();
				veriables.sign = MD5.hash(veriables.gameid+veriables.macCode+veriables.position+veriables.source+veriables.time+SECRET_KEY);
				veriables.type = optionType;
				
				
				var urlReq:URLRequest = new URLRequest(DOMAIN + SERVICES.showAndClick);
				urlReq.method = URLRequestMethod.POST;
				urlReq.data = veriables;
				
				this.m_sendLoader.addEventListener(Event.COMPLETE,sendWebInfoCompleteHandler);
				this.m_sendLoader.addEventListener(IOErrorEvent.IO_ERROR,sendWebInfoIOErrorHandler);
				this.m_sendLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,sendWebInfoSecurityErrorHandler);
				this.m_sendLoader.load(urlReq);
			}
			else
			{
				throw new Error("please exec initParam(gid:String) function",10000);	
			}
		}
		
		protected function removeSendLoaderEvents():void
		{
			if(this.m_sendLoader){
				this.m_sendLoader.removeEventListener(Event.COMPLETE,sendWebInfoCompleteHandler);
				this.m_sendLoader.removeEventListener(IOErrorEvent.IO_ERROR,sendWebInfoIOErrorHandler);
				this.m_sendLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,sendWebInfoSecurityErrorHandler);
			}
		}
		
		protected function sendWebInfoSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			// TODO Auto-generated method stub
			removeSendLoaderEvents();
			m_webInfoSendedEvent.sendResultMsg = "SecurityError";
			dispatchEvent(m_webInfoSendedEvent);
		}
		
		protected function sendWebInfoIOErrorHandler(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			removeSendLoaderEvents();
			m_webInfoSendedEvent.sendResultMsg = "IOError";
			dispatchEvent(m_webInfoSendedEvent);
		}
		
		protected function sendWebInfoCompleteHandler(event:Event):void
		{
			// TODO Auto-generated method stub
			removeSendLoaderEvents();
			var successMsg:String = "sendGameId = " + this.m_gameId + " \nsendUrl = " + this.m_pageLocation;
			m_webInfoSendedEvent.sendResultMsg = "Success  : " + successMsg;
			if(isNaN(m_sendLoader.data)){
				m_webInfoSendedEvent.gotoTagUrl = null;
			}else{
				m_webInfoSendedEvent.gotoTagUrl = m_url + "&gacId="+m_sendLoader.data;
			}
			dispatchEvent(m_webInfoSendedEvent);
		}
	}
}

class Single{
	
}