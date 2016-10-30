package util {

import flash.utils.Dictionary;
import requests.*;
import uiwidgets.*;
import translation.*;

public class DeviceManager {

	private static var theInstance:DeviceManager = null;
	private static const SCAN_DEVICES:String = "scan-devices";
	private static const CONNECT_DEVICE:String = "connect-device";
	private static const DISCONNECT_DEVICE:String = "disconnect-device";
	private static const RESET_DEVICE:String = "reset-device";

	private var currentDevices:Array;
	private var isConnected:Boolean = false;
	private var connectedDevice:String;

	private var indicator:IndicatorLight;
	
	private static const INDICATOR_RED:int = 0xff0000;
	private static const INDICATOR_GREEN:int = 0x00C000;
	
	public function DeviceManager() {
		currentDevices = new Array();
		indicator = new IndicatorLight();
		indicator.setColorAndMsg(INDICATOR_RED, Translator.map("Not connected"));

		Scratch.app.serverRequestManager.addListener(dataListener); // listen for device changes
	}

	public static function instance():DeviceManager {
		if (theInstance == null) {
			theInstance = new DeviceManager();
		}
		return theInstance;
	}

	// must run after serverRequestManager is initiated
	public function scanDevices():void {
		// clear the ports
		var request:ServerRequest = new ServerRequest(SCAN_DEVICES);

		request.completeHandler = function (originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			// Scratch.app.logDebug("ArduinoPortScanner - completeHandler: " + response);

			var values:Dictionary = xmlResponse.getValues();
			currentDevices = new Array();

			if (xmlResponse.hasProperty('device')) {
				var value:* = values['device'];
				var tokens:Array;

				if (value is Array) {
					for (var i:int = 0; i < value.length; i++) {
						tokens = value[i].split(',');	
						currentDevices.push(tokens[0]); // device,device_name
					}
				}
				else {
					tokens = value.split(',');	
					currentDevices.push(tokens[0]);
				}
			}
			else {
				Scratch.app.logDebug("DeviceManager - no port found");
			}
		};
		Scratch.app.serverRequestManager.sendRequest(request);
	}

	public function getDevices():Array {

		// check if connectedDevice not in currentDevices (for wireless device)
		if (isConnected == true && currentDevices.indexOf(connectedDevice) == -1) { 
			var deviceList:Array = new Array();
			for each (var device:String in currentDevices) {
				deviceList.push(device);
			}
			deviceList.push(connectedDevice);
			return deviceList;
		}

		return currentDevices;
	}
	
	// TO-DO: Need to disconnect before connect again
	public function connect(device:String):void {
		
		function completeHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			if (xmlResponse) {
				if (xmlResponse.succeed()) {
					connectedDevice = device;
					setConnected();
				}			
				else {
					setDisconnected();
					DialogBox.notify(Translator.map("Attention!"), xmlResponse.errorDescription());
				}
			}
		}

		function exceptionHandler(response:String):void {
			var errorDescription:String = "Unable to connect";
			if (response) {
				Scratch.app.logMessage("response: " + response);
				errorDescription = response;
			}

			setDisconnected();
			DialogBox.notify(Translator.map("Attention!"), errorDescription);
		}

		var request:ServerRequest = new ServerRequest(CONNECT_DEVICE, device);
		request.completeHandler = completeHandler;
		request.exceptionHandler = exceptionHandler;

		Scratch.app.serverRequestManager.sendRequest(request);
	}
	
	// Disconnect and then call whenDone
	public function disconnect(whenDone:Function = null):void {

		var request:ServerRequest = new ServerRequest(DISCONNECT_DEVICE, connectedDevice);
		request.completeHandler = function completeHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			if (xmlResponse) {
				if (xmlResponse.succeed()) {
					connectedDevice = null;
					setDisconnected();

					if (whenDone != null) whenDone();
				}			
			}
		}

		Scratch.app.serverRequestManager.sendRequest(request);
	}

	public function getConnectedDevice():String {
		if (isConnected == false) {
			return null;
		}
		return connectedDevice;
	}

	public function setConnected():void {
		isConnected = true;
		Scratch.app.setTopBarConnectionStatus(true);
		indicator.setColorAndMsg(INDICATOR_GREEN, Translator.map("Connected"));
	}
	
	public function setDisconnected():void {
		isConnected = false;
		Scratch.app.setTopBarConnectionStatus(false);
		indicator.setColorAndMsg(INDICATOR_RED, Translator.map("Disconnected"));
	}

	public function setIndicator():IndicatorLight {
		if (isConnected) {
			indicator.setColorAndMsg(INDICATOR_GREEN, Translator.map("Connected"));
		}
		else {
			indicator.setColorAndMsg(INDICATOR_RED, Translator.map("Not connected"));
		}
		return indicator;
	}
	
	public function connected():Boolean {
		return isConnected;
	}

	public function dataListener(xmlResponse:XMLResponse):void {
		var root:String = xmlResponse.getRoot();
		if (root == 'devices') {
			var values:Dictionary = xmlResponse.getValues();
			currentDevices = new Array(); // TO-DO: didn't check if connected device got unplugged

			if (xmlResponse.hasProperty('device')) {
				var value:* = values['device'];
				var tokens:Array;

				if (value is Array) {
					for (var i:int = 0; i < value.length; i++) {
						tokens = value[i].split(',');	
						currentDevices.push(tokens[0]); // device,device_name
					}
				}
				else {
					tokens = value.split(',');	
					currentDevices.push(tokens[0]);
				}
			}

			if (connected() && currentDevices.indexOf(connectedDevice) == -1) { // connected device unplugged
				setDisconnected();
			}
		}
	}

	// Used to reset the pin mode of the current device when green flag pressed
	public function resetCurrentDevice():void {
		if (isConnected) {
			var request:ServerRequest = new ServerRequest(RESET_DEVICE, connectedDevice);
			Scratch.app.serverRequestManager.sendRequest(request);
		}
	}
}
}
