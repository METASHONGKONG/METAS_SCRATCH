
package util {

import flash.utils.getTimer;
import logging.*;

public class PollObjectManager {

	private var app:Scratch;
	private var objectsArray:Array;

	public function PollObjectManager(app:Scratch) {
		this.app = app;
		objectsArray = new Array();
	}

	public function register(pollObject:PollObject):void {
		if (objectsArray.indexOf(pollObject) == -1) {
			objectsArray.push(pollObject);
		}
	}

	public function step():void {
		var i:int = 0;
		for (i = 0; i < objectsArray.length; i++) {
			var pollObject:PollObject = objectsArray[i];
			if (pollObject.timeToPoll()) {
				pollObject.step();
			}
		}
	}

}}

