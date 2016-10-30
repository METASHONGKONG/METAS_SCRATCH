package requests {

import flash.concurrent.Mutex;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import util.*;

public class ServerRequestManager implements PollObject {

	private var app:Scratch;
	private var mutex:Mutex;
	private var processQueue:Dictionary;
	private var socketServer:XMLSocketServer;
	private var lastPollTime:int = -1;

	private var listeners:Array;

	private var index:Number = 1;

	private static const POLLPERIOD:int = 2000; // poll once 0.2 seconds
	
	public function ServerRequestManager(app:Scratch) {
		this.app = app;
		mutex = new Mutex();	
		processQueue = new Dictionary();
		listeners = new Array();

		socketServer = new XMLSocketServer();
		socketServer.addListener(dataHandler);
		socketServer.addExceptionListener(exceptionHandler);

		app.pollObjectManager.register(this);
	}

	public function sendRequest(request:ServerRequest):void {
		sendRequestToSocket(request);
	}

	// Send directly to the socket server
	private function sendRequestToSocket(request:ServerRequest):void {

		request.setIndex(index);
		socketServer.writeString(request.toXMLString());

		mutex.lock();
		// Send all the requests to socket
		if (request.completeHandler != null) { 
			Scratch.app.logDebug("ServerRequestManager::sendRequestToSocket - index: " + index);
			processQueue[index] = request;
		}
		index++;
		if (index == int.MAX_VALUE) { // recycle if overflow.  int.MAX_VALUE = 2147483647
			index = 1;
		}
		mutex.unlock();	
	}

	// Required by PollObject
	public function step():void {
		lastPollTime = getTimer();

		// Reconnect to the socketServer if not connected or if connection is not in progress
		if (!socketServer.isConnected()) { 
			if (!socketServer.isConnectInProgress()) {
				Scratch.app.logDebug("ServerRequestManager: connect");
				socketServer.connect(); 
			}
			return;  // return until the socket server is connected
		}
	}

	// Required by PollObject
	public function timeToPoll():Boolean {
		var currentTime:int = getTimer();
		return (lastPollTime == -1) || (currentTime - lastPollTime > POLLPERIOD);
	}

	public function dataHandler(response:String):void {
		//Scratch.app.log(LogLevel.DEBUG, "ServerRequestManager - response: " + response);

		var xmlResponse:XMLResponse = new XMLResponse(response);
		var values:Dictionary = xmlResponse.getValues();

		if (xmlResponse.hasProperty('index')) {
			var index:int = int(xmlResponse.getProperty('index'));

			var request:ServerRequest = null;
			mutex.lock();
			if (index in processQueue) {
				Scratch.app.logDebug("ServerRequestManager::dataHandler - index: " + index);
				request = processQueue[index];
				delete processQueue[index];
			}
			mutex.unlock();

			if (request != null) {
				request.completeHandler(request, xmlResponse);
			}
		}
		else {
			for (var i:int = 0; i < listeners.length; i++) {
				var op:Function = listeners[i];
				op(xmlResponse);
			}	
		}
			
	}

	// Inform all requests that exception happens in network
	public function exceptionHandler(response:String):void {
		mutex.lock();
		var request:ServerRequest;

		for each (request in processQueue) {
			if (request.exceptionHandler != null) {
				request.exceptionHandler(response);
			}
		}

		processQueue = new Dictionary();
		mutex.unlock();
	}

	public function addListener(dataHandler:Function):void {
		listeners.push(dataHandler);
	}

	public function isServerConnected():Boolean {
		return socketServer.isConnected()
	}
}}

