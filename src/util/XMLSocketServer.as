package util {

import flash.events.*;
import flash.net.XMLSocket;
import flash.system.Security;
import flash.utils.ByteArray;
import flash.utils.setTimeout;
    
import logging.*;

public class XMLSocketServer {

	private var server:String;
	private var port:int;

	private var connected:Boolean = false;
	private var socket:XMLSocket;
	private var listeners:Array;
	private var exceptionListeners:Array; // for exception handling

	private var connectInProgress:Boolean = false;

	public function XMLSocketServer(server:String = "localhost", port:int = 59049) {
		this.server = server;
		// this.server = '192.168.1.102';
		// this.server = '192.168.1.107';
		this.port = port;	

		listeners = new Array();
		exceptionListeners = new Array();

   	    // Load policy file from remote server. - not required for offline application
        // Security.loadPolicyFile("xmlsocket://" + server + ":" + port);

		socket = new XMLSocket();

		socket.addEventListener(Event.CONNECT, connectHandler);
		socket.addEventListener(Event.CLOSE, closeHandler);
		socket.addEventListener(ErrorEvent.ERROR, errorHandler);
		socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		socket.addEventListener(DataEvent.DATA, dataHandler);
		socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	}

	public function connect():void {
		try {
			connectInProgress = true;
			socket.connect(server, port);
		} catch (error:Error) {
		}
	}

	public function isConnected():Boolean {
		return connected;
	}

	public function isConnectInProgress():Boolean {
		return connectInProgress;
	}

	public function connectHandler(event:Event):void {
		if (socket.connected) {
			Scratch.app.logDebug("SocketServer: " + server + " connected");
			connected = true;
			connectInProgress = false;

			// Scan the ports when Scratch connects to the local server
			DeviceManager.instance().scanDevices();
		} 
		else {
			Scratch.app.logDebug("SocketServer: Unable to connect " + server);
			connected = false;
			connectInProgress = false;
		}
	}

	public function ioErrorHandler(event:Event):void {
		Scratch.app.logDebug("SocketServer: Unable to connect " + server);

		connected = false;
		connectInProgress = false;

		for (var i:int = 0; i < exceptionListeners.length; i++) {
			var op:Function = exceptionListeners[i];
			op("Unable to connect");
		}	
	}
		
	// This method is called when the socket connection is closed by the server.
	private function closeHandler(event:Event):void {
		Scratch.app.logDebug("SocketServer: Connection closed by Server");

		connected = false;
		connectInProgress = false;

		for (var i:int = 0; i < exceptionListeners.length; i++) {
			var op:Function = exceptionListeners[i];
			op("Connection closed by Server");
		}	
	
		DeviceManager.instance().setDisconnected();
	}

	// This method is called if the socket throws an error
	private function errorHandler(event:ErrorEvent):void {
		Scratch.app.logMessage("SocketServer: Socket throws an error " + event.text);

		// TO-DO:  Need to understand what to do with the error.
		connected = false;
		connectInProgress = false;

		for (var i:int = 0; i < exceptionListeners.length; i++) {
			var op:Function = exceptionListeners[i];
			op("Socket throws an error " + event.text);
		}	
	}

	// This method is called if the socket throws an error
	private function securityErrorHandler(event:SecurityErrorEvent):void {
		Scratch.app.logMessage("SocketServer: Socket throws a Security error " + event.text);

		// TO-DO:  Need to understand what to do with the error.
		connected = false;
		connectInProgress = false;

		for (var i:int = 0; i < exceptionListeners.length; i++) {
			var op:Function = exceptionListeners[i];
			op("Socket throws a Security Error " + event.text);
		}	
	}

	// This method is called when socket receives data from the server
	private function dataHandler(event:DataEvent):void {
		// Scratch.app.logDebug("XMLSocketServer: dataHandler entry");
		var data:String = event.data;
		Scratch.app.logDebug("SocketServer: data received " + data);

		for (var i:int = 0; i < listeners.length; i++) {
			var op:Function = listeners[i];
			op(data);
		}	
		// Scratch.app.logDebug("XMLSocketServer: dataHandler exit");
	}
	
	public function writeString(data:String):void {
		if (connected) {
			socket.send(data);
		}
		else {
			for (var i:int = 0; i < exceptionListeners.length; i++) {
				var op:Function = exceptionListeners[i];
				op("Unable to send as server is not connected");
			}	
		}
	}

	public function addListener(dataHandler:Function):void {
		listeners.push(dataHandler);
	}

	public function addExceptionListener(exceptionHandler:Function):void {
		exceptionListeners.push(exceptionHandler);
	}

}}

