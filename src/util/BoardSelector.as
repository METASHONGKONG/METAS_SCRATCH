package util {

import flash.utils.Dictionary;

public class BoardSelector {

	private var selectedBoard:String = METAS_8_PORT;

	private static var theInstance:BoardSelector = null;

	public static const METAS_3_PORT:String = "Metas 3-Port";
	public static const METAS_8_PORT:String = "Metas 8-Port";
	public static const METAS_WIRELESS:String = "Metas Wireless";
	public static const ARDUINO_UNO:String = "Arduino Uno";

	private var digitalInPins:Dictionary;
	private var digitalOutPins:Dictionary;
	private var pwmPins:Dictionary;
	private var analogPins:Dictionary;
	private var servoPins:Dictionary; // for ESP8266 only

	public function BoardSelector() {
		initDigitalInPins();
		initDigitalOutPins();
		initPWMPins();
		initAnalogPins();
		initServoPins();
	}

	private function initDigitalInPins():void {
		digitalInPins = new Dictionary();
		digitalInPins[METAS_3_PORT] = [];
		digitalInPins[METAS_8_PORT] = [2];
		digitalInPins[METAS_WIRELESS] = [0];
		digitalInPins[ARDUINO_UNO] = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
	}

	private function initDigitalOutPins():void {
		digitalOutPins = new Dictionary();
		digitalOutPins[METAS_3_PORT] = [13];
		digitalOutPins[METAS_8_PORT] = [5, 8, 9, 10];
		digitalOutPins[METAS_WIRELESS] = [1, 2];
		digitalOutPins[ARDUINO_UNO] = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
	}
	
	// Analog In
	private function initAnalogPins():void {
		analogPins = new Dictionary();
		analogPins[METAS_3_PORT] = [0];
		analogPins[METAS_8_PORT] = [0, 1, 2];
		analogPins[METAS_WIRELESS] = [0, 1];
		analogPins[ARDUINO_UNO] = [0, 1, 2, 3, 4, 5];
	}

	// Analog Out
	private function initPWMPins():void {
		pwmPins = new Dictionary();
		pwmPins[METAS_3_PORT] = [9];
		pwmPins[METAS_8_PORT] = [5, 9, 10];
		pwmPins[METAS_WIRELESS] = [1, 2];
		pwmPins[ARDUINO_UNO] = [3, 5, 6, 9, 10, 11];
	}

	// Servo Pins
	private function initServoPins():void {
		servoPins = new Dictionary();
		servoPins[METAS_3_PORT] = [];
		servoPins[METAS_8_PORT] = [];
		servoPins[METAS_WIRELESS] = [1, 2, 4, 8];
		servoPins[ARDUINO_UNO] = [];
	}

	public static function instance():BoardSelector {
		if (theInstance == null) {
			theInstance = new BoardSelector();
		}
		return theInstance;
	}

	public function selectBoard(board:String):void {
		selectedBoard = board;	
	}

	public function getSelectedBoard():String {
		return selectedBoard;
	}

	public function getDigitalInPins(board:String):Array {
		return digitalInPins[board];
	}

	public function getDigitalOutPins(board:String):Array {
		return digitalOutPins[board];
	}

	public function getPWMPins(board:String):Array {
		return pwmPins[board];
	}

	public function getAnalogPins(board:String):Array {
		return analogPins[board];
	}

	public function getServoPins(board:String):Array {
		return servoPins[board];
	}

}}
