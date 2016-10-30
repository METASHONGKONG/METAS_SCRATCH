package requests {

import logging.*;

public class ServerRequest {
	private var payload:String;
	private var args:Array;
	public var completeHandler:Function = null;
	public var exceptionHandler:Function = null;
	private var index:int = -99;

	public function ServerRequest(payload:String, ...args) {
		this.payload = payload;
		this.args = new Array();

		for (var i:int = 0; i < args.length; i++) {
			this.args.push(args[i]);
		}
	}

	public function setCompleteHandler(completeHandler:Function):void {
		this.completeHandler = completeHandler;
	}

	public function setExceptionHandler(exceptionHandler:Function):void {
		this.exceptionHandler = exceptionHandler;
	}

	private function setXMLSettings():void {
		XML.ignoreComments = true;
		XML.ignoreProcessingInstructions = true;
		XML.ignoreWhitespace = true;
		XML.prettyIndent = 0;
		XML.prettyPrinting = false;
	}

	public function toXMLString():String {
		setXMLSettings();
		var xml:XML = <{payload}></{payload}>;

		if (index > -99) {
			xml.appendChild(<index>{index}</index>);	
		}

		for (var i:int = 0; i < args.length; i++) {
			xml.appendChild(<arg>{args[i]}</arg>)
		}

		var xmlString:String = xml.toXMLString();
		Scratch.app.logDebug('xmlString: ' + xmlString);	
	
		return xmlString;
	}

	public function setIndex(index:int):void {
		this.index = index;
	}

	public function getArg(index:int):* {
		if (this.args.length <= index) {
			return null;
		}
		return this.args[index];
	}
}}

