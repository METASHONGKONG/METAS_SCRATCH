package requests {
	
	import flash.utils.Dictionary;

public class XMLResponse {

	private var data:String;
	private var root:String;
	private var values:Dictionary;

	private static var errorDescriptions:Dictionary = null;

	public function XMLResponse(data:String) {
		this.data = data;

		var xml:XML = new XML(data);
		root = xml.localName();
		values = parse(xml);	
	}

	public function getValues():Dictionary {
		return values;
	}

	public function getRoot():String {
		return root;
	}
			
	public function hasProperty(key:String):Boolean {
		return (key in values); //  TO-DO: need to work on for further dictionary
	}

	public function getProperty(key:String):* {
		if (hasProperty(key)) {
			return values[key];
		}

		return null;
	}	

	public function succeed():Boolean {
		if (root == 'succeed') {
			return true;
		}
		return false;
	}

	public function fail():Boolean {
		if (root == 'fail') {
			return true;
		}
		return false;
	}

	public function errorDescription():String {
		/*
		if ('description' in values) {
			return values['description'];
		}
		return "";
		*/
		var errorNo:int = ('error_no' in values) ? values['error_no'] : 9999;
		return errorDesc(errorNo);
	}

	public function errorNo():int {
		var errorNo:int = ('error_no' in values) ? values['error_no'] : 9999;
		return errorNo;
	}

	private function parse(xml:XML):Dictionary {

		var dictionary:Dictionary = new Dictionary();
		
	 	var children:XMLList = xml.children();
		for each (var child:XML in children) {
			var name:String = child.localName();

			if (child.hasSimpleContent()) {
				var value:String = child.text();

				if (name in dictionary) {
					if (dictionary[name] is Array) {
						dictionary[name].push(value);
					}
					else {
						var tmpValue:* = dictionary[name];
						dictionary[name] = new Array();
						dictionary[name].push(tmpValue);
						dictionary[name].push(value);
					}
				}
				else {
					dictionary[name] = value;
				}
			}
			else {
				dictionary[name] = parse(child);
			}				
		}

		return dictionary;
	}

	public static function errorDesc(errorNo:int):String {
		if (errorDescriptions == null) {
			errorDescriptions = new Dictionary();
			initErrorDescriptions();
		}
	
		if (errorNo in errorDescriptions) {
			return errorDescriptions[errorNo];
		}
		return "Unknown Error";
	}

	private static function initErrorDescriptions():void {
		errorDescriptions = new Dictionary();
		errorDescriptions[0] = 'Unknown Error';
		errorDescriptions[101] = 'Device Not Found';
		errorDescriptions[102] = 'Packet Index Missing';
		errorDescriptions[103] = 'Numeric Value Format Invalid';
		errorDescriptions[104] = 'Packet Tag Invalid';
		errorDescriptions[111] = 'Pin Type Mismatch (For example, Arduino Pin 13 does not support PWM)';
		errorDescriptions[112] = 'Function Name Mismatch';
		errorDescriptions[113] = 'I2C Not Supported (Some board does not support I2C)';
		errorDescriptions[121] = 'Device ID Not Found (Device may be disconnected)';
		errorDescriptions[201] = 'TCP Send Failed (Connection Reset / Closed)';
		errorDescriptions[221] = 'Serial Port Disconnected';
		errorDescriptions[301] = 'Firmata Firmware Not Found';
		errorDescriptions[302] = 'Firmata firmware update is required (at least v2.3)';
		errorDescriptions[303] = 'Firmata I2C Error (Bytes Number Mismatch / Timeout / Firmata hangs)';
		errorDescriptions[304] = 'Firmata Read Timeout';
		errorDescriptions[311] = 'ARest Temperature / Humidity Request Error';
		errorDescriptions[312] = 'Connection Lost';
		errorDescriptions[313] = 'ADC Error';
		errorDescriptions[401] = 'Internal Error';
		errorDescriptions[501] = 'Device Reset Detected';
		errorDescriptions[601] = 'System Subnet Not Found';
		errorDescriptions[602] = 'System Aborted';
		errorDescriptions[901] = '[Compile Time Mistake] Pin Type is not supported or not implemented';
		errorDescriptions[902] = '[Compile Time Mistake] Code is not implemented';
		errorDescriptions[903] = '[Compile Time Mistake] Function is not implemented';
		errorDescriptions[9999] = 'Unknown';
	}
	
}}

