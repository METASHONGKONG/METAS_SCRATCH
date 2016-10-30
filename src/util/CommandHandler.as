package util {

import interpreter.*;
import blocks.Block;
import requests.*;

public class CommandHandler {

	public function CommandHandler() {
	}

	public static function executeBlockingCommand(b:Block, interp:Interpreter, requestHandler:Function, successHandler:Function = null, failureHandler:Function = null):void {

		/*
		if (b.requestState == 2) { // clean up and revert the state back to 0
			b.requestState = 0;
			return;
		}
		*/

		// Wait until connection is completed
		function completeHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			if (xmlResponse) {
				if (xmlResponse.succeed()) {
					if (successHandler != null) successHandler(originalRequest, xmlResponse);
				}			
				else {
					if (failureHandler != null) failureHandler(xmlResponse.errorNo());
				}
			}
			b.requestState = 2;
			interp.doYield();
		}

		// Exception happens.  Unblock the connection
		function exceptionHandler(response:String):void {
			if (failureHandler != null) failureHandler(401);  // Internal Error
			b.requestState = 2;
			interp.doYield();
		}

		// b.requestState = 0 (no request), 1 (await result), 2 (data ready)
		if (b.requestState == 0) { 
			var request:ServerRequest = requestHandler(b);
			request.completeHandler = completeHandler;
			request.exceptionHandler = exceptionHandler;

			Scratch.app.serverRequestManager.sendRequest(request);

			b.requestState = 1;
			interp.doYield();
		}

		if (b.requestState == 1) {
			interp.doYield();
		}
	}
}
}
