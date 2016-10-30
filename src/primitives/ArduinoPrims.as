/*
 * Arduino Extensions
 * Copyright (C) 2014 Coding101 Hong Kong
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// ArduinoPrims.as
// Jimmy Hui, January 2016
//

package primitives {

	import blocks.Block;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import interpreter.*;
	import scratch.*;
	import sound.*;
	import flash.net.*;
	import flash.events.*;
	import util.*;
	import requests.*;
	import uiwidgets.*;
	import translation.*;

public class ArduinoPrims {

	private var app:Scratch;
	private var interp:Interpreter;

	private var error:Boolean = false;
	private var errorDescription:String = "";

	private var lastSetPWMTime:int = 0;
	private var lastSetDigitalTime:int = 0;
	private var lastMoveServoTime:int = 0;

	private var lastSetDigitalPin:int = -1
	private var lastSetPWMPin:int = -1
	private var lastMoveServoPin:int = -1

	private static const SET_DIGITAL_PIN:String = "set-digital-pin";
	private static const SET_PWM_PIN:String = "set-pwm-pin";
	private static const READ_DIGITAL_PIN:String = "read-digital-pin";
	private static const READ_ANALOG_PIN:String = "read-analog-pin";
	private static const MOVE_SERVO:String = "move-servo";
	private static const DEVICE_FUNCTION:String = "device-function";

	// Testing I2C
	private static const I2C_READ:String = "read-i2c";
	private static const I2C_WRITE:String = "write-i2c";

	// Device Functions
	private static const GET_DHT11_TEMPERATURE:String = "get-temperature";
	private static const GET_DHT11_HUMIDITY:String = "get-humidity";
	private static const MOTOR_FORWARD:String = "motor-forward";
	private static const MOTOR_BACKWARD:String = "motor-backward";
	private static const MOTOR_LEFT:String = "motor-left";
	private static const MOTOR_RIGHT:String = "motor-right";
	private static const MOTOR_STOP:String = "motor-stop";

	public function ArduinoPrims(app:Scratch, interpreter:Interpreter) {
		this.app = app;
		this.interp = interpreter;

		app.serverRequestManager.addListener(dataHandler);
	}
	
	public function addPrimsTo(primTable:Dictionary): void {

		// Output (Green color)
		primTable["digitalOutput:DigitalPin:to"] = primDigitalOuput;
		primTable["analogOutput:PWMPin:to:"] = primAnalogOutput;

		/*
		primTable["setLED:DigitalPin:to:"] = primSetLEDonDigitalPin;
		primTable["setLED:PWMPin:to:"] = primSetLEDonPWMPin;	
		primTable["setRGB:DigitalPin:to:"] = primSetRGBonDigitalPin;
		primTable["setBrightLED:DigitalPin:to:"] = primSetBrightLEDonDigitalPin; 
		primTable["setBrightLED:PWMPin:to:"] = primSetBrightLEDonPWMPin;

		primTable["setMotor:PWMPin:to:"] = primSetMotoronPWMPin;
		primTable["setMotorDirection:DigitalPin:to:"] = primSetMotorDirection;
		primTable["setBuzzer:DigitalPin:to:"] = primSetBuzzer;

		primTable["setBargraph:DigitalPin:to:"] = primSetBargraph;
		primTable["setVibration:DigitalPin:to:"] = primSetVibration;
		primTable["setFan:DigitalPin:to:"] = primSetFan;
		primTable["setFan:PWMPin:to:"] = primSetFanOnPWMPin;
		*/

		primTable["setLED:PWMPin:to:"] = primSetLEDonPWMPin;
		primTable["setBrightLED:PWMPin:to:"] = primSetBrightLEDonPWMPin;
		primTable["setRGB:PWMPin:to:"] = primSetRGBonPWMPin;
		primTable["setDoubleLED:PWMPin:to:"] = primSetDoubleLEDonPWMPin;
		primTable["setQuadroLED:PWMPin:to:"] = primSetQuadroLEDonPWMPin;
		primTable["setBargraph:PWMPin:to:"] = primSetBargraphonPWMPin;
		primTable["setMotor:PWMPin:to:"] = primSetMotoronPWMPin;
		primTable["setControllableMotor:PWMPin:to:"] = primSetControllableMotoronPWMPin;
		primTable["setFan:PWMPin:to:"] = primSetFanonPWMPin;
		primTable["setBuzzer:PWMPin:to:"] = primSetBuzzeronPWMPin;
		primTable["setServo:PWMPin:to:"] = primSetServoonPWMPin;
		primTable["setColorfulLights:PWMPin:to:"] = primSetColorfulLightsonPWMPin;
		primTable["setUSBConverter:PWMPin:to:"] = primSetUSBConverteronPWMPin;
		primTable["setUSBLED:PWMPin:to:"] = primSetUSBLEDonPWMPin;
		primTable["setVoltmeter:PWMPin:to:"] = primSetVoltmeteronPWMPin;

		// Input (Purple Color)
		primTable["digitalInput:DigitalPin"] = primDigitalInput;
		primTable["analogInput:AnalogPin"] = primAnalogInput;

		primTable["pulse:DigitalPin"] = primGetPulse;
		primTable["rollerSwitch:DigitalPin"] = primGetRollerSwitch;
		primTable["motionTrigger:DigitalPin"] = primGetMotionTrigger;
		primTable["pressSwitch:DigitalPin"] = primGetPressSwitch;
		primTable["lightTrigger:DigitalPin"] = primGetLightTrigger;
		primTable["reedSwitch:DigitalPin"] = primGetReedSwitch;
		primTable["touchSwitch:DigitalPin"] = primGetTouchSwitch;
		primTable["thresholdTrigger:DigitalPin"] = primGetThresholdTrigger;

		primTable["pulse:AnalogPin"] = primGetPulseAnalog;
		primTable["rollerSwitch:AnalogPin"] = primGetRollerSwitchAnalog;
		primTable["pressSwitch:AnalogPin"] = primGetMotionTriggerAnalog;
		primTable["motionTrigger:AnalogPin"] = primGetPressSwitchAnalog;
		primTable["lightTrigger:AnalogPin"] = primGetLightTriggerAnalog;
		primTable["reedSwitch:AnalogPin"] = primGetReedSwitchAnalog;
		primTable["touchSwitch:AnalogPin"] = primGetTouchSwitchAnalog;
		primTable["thresholdTrigger:AnalogPin"] = primGetThresholdTriggerAnalog;

		/*
		primTable["button:DigitalPin"] = primGetButton;
		primTable["rollerSwitch:DigitalPin"] = primGetRollerSwitch;
		primTable["pulse:DigitalPin"] = primGetPulse;
		primTable["toggle:DigitalPin"] = primGetToggle;
		primTable["timeout:DigitalPin"] = primGetTimeout;
		primTable["motionTrigger:DigitalPin"] = primGetMotionTigger;
		primTable["lineFollower:DigitalPin"] = primGetLineFollower;
		*/

		primTable["dimmer:AnalogPin"] = primGetDimmer;
		primTable["lightSensor:AnalogPin"] = primGetLightSensor;
		primTable["soundSensor:AnalogPin"] = primGetSoundSensor;
		primTable["pressureSensor:AnalogPin"] = primGetPressureSensor;
		primTable["grayScaleDetector:AnalogPin"] = primGetGrayScale;
		primTable["remoteRT:AnalogPin"] = primGetRemoteRT;

		primTable["ultrasonic:AnalogPin"] = primGetUltrasonic;
		primTable["linearRheostat:AnalogPin"] = primGetLinearRheostat;
		primTable["irreflection:AnalogPin"] = primGetIRReflection;

		/*
		primTable["soundSensor:AnalogPin"] = primGetSoundSensor;
		primTable["lightSensor:AnalogPin"] = primGetLightSensor;
		primTable["slider:AnalogPin"] = primGetSlider;
		primTable["dimmer:AnalogPin"] = primGetDimmer;
		primTable["switch:AnalogPin"] = primGetSwitch;
		primTable["ultrasonicSensor:AnalogPin"] = primGetUltrasonicSensor;
		*/

		// Metas Combo (yellow color)
		primTable["getDHT11Temperature"] = primGetDHT11Temperature;
		primTable["getDHT11Humidity"] = primGetDHT11Humidity;
		primTable["initializeRGBW"] = primInitializeRGBW;
		primTable["setRGB:R:G:B:W"] = primSetRGB;
		primTable["servo:degree:"] = primServo;
		primTable["motorForward"] = primMotorForward;
		primTable["motorBackward"] = primMotorBackward;
		primTable["motorLeft"] = primMotorLeft;
		primTable["motorRight"] = primMotorRight;
		primTable["motorStop"] = primMotorStop;
		primTable["motor:MotorPin:Clockwise:PWM"] = primMotorDrive;

		primTable["moveCockroachForward"] = primMoveCockroachForward;
		primTable["moveCockroachBackward"] = primMoveCockroachBackward;

		// Arduino
		primTable["set:DigitalPin:to:"] = primSetDigitalPin;
		primTable["setPWMPin:to:"] = primSetPWMPin;
		primTable["move:servo:degree:"] = primMoveServo;
		primTable["digitalPin:"] = primGetDigitalPin;
		primTable["analogPin:"] = primGetAnalogPin;
/*
		["i2c config read address %m.i2cAddress bytes %n",	" ", 19, "i2cConfig:address:bytes:"],
		["i2c address %m.i2cAddress data available",		"b", 19, "i2c:dataAvailable:"],
		["i2c read address %m.i2cAddress byte %n",			"r", 19, "i2cRead:address:"],
*/
		primTable["map:fromLow:high:toLow:high:"] = primMapLowHigh;

		// i2C for testing
		primTable["readI2C:address:register:bytes:"] = primI2CRead;
		primTable["writeI2C:address:register:data:"] = primI2CWrite;
	}

	public function primNoop(b:Block):void {}

	// Digital Pins
	public function primSetLEDonDigitalPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'on')? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}

	public function primDigitalOuput(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'on')? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}

	public function primSetRGBonDigitalPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'on')? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}

	public function primSetBrightLEDonDigitalPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'on')? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}

	public function primSetBuzzer(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'on')? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}

	public function primSetMotorDirection(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'clockwise')? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}

	public function primSetBargraph(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'on')? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}

	public function primSetVibration(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'on')? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}

	public function primSetFan(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'on')? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}

	// PWM Pins
	public function primAnalogOutput(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}
	
	public function primSetLEDonPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetBrightLEDonPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetRGBonPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetDoubleLEDonPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetControllableMotoronPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetBargraphonPWMPin(b:Block):void {

		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetQuadroLEDonPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetMotoronPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));

		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}
	
	public function primSetFanonPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetBuzzeronPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetServoonPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetColorfulLightsonPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetUSBConverteronPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetUSBLEDonPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}

	public function primSetVoltmeteronPWMPin(b:Block):void {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var percentage:Number = parseInt(interp.arg(b, 1));
		if (isNaN(percentage)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}
	
		var maxValue:int = (BoardSelector.instance().getSelectedBoard() == BoardSelector.METAS_WIRELESS)? 1023:255;

		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		setPWMPin(pin, value, b);
	}


	// Digital Read
	public function primDigitalInput(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetButton(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetRollerSwitch(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetPulse(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetToggle(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetTimeout(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetMotionTrigger(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetLineFollower(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetPressSwitch(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetLightTrigger(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}


	public function primGetReedSwitch(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetTouchSwitch(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}

	public function primGetThresholdTrigger(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return (b.response == 0) ? 'off' : 'on';
		}

		getDigitalPin(pin, b);
	}


	// Analog Read
	public function primAnalogInput(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(int(pin), b);
	}

	public function primGetSoundSensor(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(int(pin), b);
	}

	public function primGetLightSensor(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetSlider(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetDimmer(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetSwitch(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetUltrasonicSensor(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetPressureSensor(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetGrayScale(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetRemoteRT(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetUltrasonic(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetLinearRheostat(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetIRReflection(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			if (!isNaN(percentage)) {
				percentage = (percentage / 1023 * 100); // It hardly goes to 1024
			}
			else {
				percentage = 0;
			}

			return percentage;
		}

		getAnalogPin(pin, b);
	}

	public function primGetPulseAnalog(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			var percentage:int = Number(b.response);
			var onoff:String = 'off';
			if (!isNaN(percentage)) {
				onoff = (percentage < 512) ? 'off' : 'on';
			}
			else {
				onoff = 'off';
			}

			return onoff;
		}

		getAnalogPin(pin, b);
	}

	public function primGetRollerSwitchAnalog(b:Block):* {
		return primGetPulseAnalog(b);
	}

	public function primGetMotionTriggerAnalog(b:Block):* {
		return primGetPulseAnalog(b);
	}

	public function primGetPressSwitchAnalog(b:Block):* {
		return primGetPulseAnalog(b);
	}

	public function primGetLightTriggerAnalog(b:Block):* {
		return primGetPulseAnalog(b);
	}

	public function primGetReedSwitchAnalog(b:Block):* {
		return primGetPulseAnalog(b);
	}

	public function primGetTouchSwitchAnalog(b:Block):* {
		return primGetPulseAnalog(b);
	}

	public function primGetThresholdTriggerAnalog(b:Block):* {
		return primGetPulseAnalog(b);
	}

	public function primSetDigitalPin(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		var value:String = interp.arg(b, 1);
		var onoff:int = (value.toLowerCase() == 'high') ? 1 : 0;

		setDigitalPin(pin, onoff, b);
	}
	
	public function primSetPWMPin(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var value:Number = parseInt(interp.arg(b, 1));
		if (isNaN(value)) { 
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		setPWMPin(pin, value, b);
	}

	public function primMoveServo(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var degree:Number = parseInt(interp.arg(b, 1));
		if (isNaN(degree)) {
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		moveServo(pin, degree, b);
	}

	public function primGetDigitalPin(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and fetch the result
			return b.response;
		}

		getDigitalPin(pin, b);
	}

	public function primGetAnalogPin(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			b.response = 0; // set the response to 0 by default
			return;
		}

		if (b.requestState == 2) {
			b.requestState = 0;
			return b.response;
		}

		getAnalogPin(pin, b);
	}

	public function primMapLowHigh(b:Block):* {
		var fromValue:int = interp.numarg(b, 0);
		var fromLow:int = interp.numarg(b, 1);
		var fromHigh:int = interp.numarg(b, 2);
		var toLow:int = interp.numarg(b, 3);
		var toHigh:int = interp.numarg(b, 4);

		if (fromValue < fromLow) {
			fromValue = fromLow;
		}
		else if (fromValue > fromHigh) {
			fromValue = fromHigh;
		}

		return Math.round((fromValue * ((toHigh - toLow) / (fromHigh - fromLow))) + toLow);
	}

	public function primI2CRead(b:Block):* {
		var address:int = interp.numarg(b, 0);
		var register:int = interp.numarg(b, 1);
		var numBytes:int = interp.numarg(b, 2);

		if (b.requestState == 2) {
			b.requestState = 0;
			return b.response;
		}

		i2cRead(address, register, numBytes, b);
	}

	public function primI2CWrite(b:Block):* {
		var address:int = interp.numarg(b, 0);
		var register:int = interp.numarg(b, 1);
		var data:String = interp.arg(b, 2);

		if (b.requestState == 2) {
			b.requestState = 0;
			return; 
		}

		i2cWrite(address, register, data, b);
	}

	public function primServo(b:Block):* {
		var pin:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin)) { 
			b.requestState = 2;
			return;
		}

		var degree:Number = parseInt(interp.arg(b, 1));
		if (isNaN(degree)) {
			b.requestState = 2;
			return;
		}

		if (b.requestState == 2) {  // Result ready 
			b.requestState = 0; // Reset to zero and move on
			return;
		}

		moveServo(pin, degree, b);
	}

	// Get temperature in Celsius from DHT11
	public function primGetDHT11Temperature(b:Block):* {
		if (b.requestState == 2) {
			b.requestState = 0;
			return b.response;
		}	

		getAnalogValuesFromDeviceFunction(GET_DHT11_TEMPERATURE, b);
	}

	public function primGetDHT11Humidity(b:Block):* {
		if (b.requestState == 2) {
			b.requestState = 0;
			return b.response;
		}	

		getAnalogValuesFromDeviceFunction(GET_DHT11_HUMIDITY, b);
	}

	private function computeRegisterValue(value:Number):String {
		var correctedValue:Number = Math.round(Math.pow(value, 2.2) * 0.020791);
		var registerValue:String = "";

		if (correctedValue > 4095) {
			registerValue = "0x00 0x10 0x00 0x00";
		}
		else if (correctedValue < 1) {
			registerValue = "0x00 0x00 0x00 0x10";
		}
		else {
			registerValue = "0x00 0x00 0x";

			var hexint:int = Math.round((correctedValue % 256) / 16 - 0.5);
			var hexString:String = hexint.toString(16).toUpperCase();
			registerValue = registerValue + hexString;

			hexint = correctedValue % 16;
			hexString = hexint.toString(16).toUpperCase();
			registerValue = registerValue + hexString + " 0x0";

			hexint = Math.round((correctedValue / 256) - 0.5);
			hexString = hexint.toString(16).toUpperCase();
			registerValue = registerValue + hexString;
		}

		return registerValue;
	}

	public function primInitializeRGBW(block:Block):* {
		var address:int = 64;

		nbI2CWrite(address, 0, "0xA0", processResponse);

		var rData:String = computeRegisterValue(0);
		var gData:String = computeRegisterValue(0);
		var bData:String = computeRegisterValue(0);
		var wData:String = computeRegisterValue(0);

		var data:String = rData + " " + gData + " " + bData + " " + wData;

		var register:int = 6;

		nbI2CWrite(address, register, data, processResponse);
	}

	public function primSetRGB(block:Block):* {
		var r:Number = parseInt(interp.arg(block, 0));
		var g:Number = parseInt(interp.arg(block, 1));
		var b:Number = parseInt(interp.arg(block, 2));
		var w:Number = parseInt(interp.arg(block, 3));

		if (isNaN(r) || isNaN(g) || isNaN(b) || isNaN(w)) {
			block.requestState = 2;
			return;
		}

		if (block.requestState == 2) {  // Result ready 
			block.requestState = 0; // Reset to zero and move on
			return;
		}

		var rData:String = computeRegisterValue(r);
		var gData:String = computeRegisterValue(g);
		var bData:String = computeRegisterValue(b);
		var wData:String = computeRegisterValue(w);

		var data:String = rData + " " + gData + " " + bData + " " + wData;
		app.logDebug("data: " + data);
	
		var address:int = 64;
		var register:int = 6;

		i2cWrite(address, register, data, block);
	}

	public function primMotorForward(b:Block):* {
		setAnalogValuesToDeviceFunction(MOTOR_FORWARD, processResponse);
	}

	public function primMotorBackward(b:Block):* {
		setAnalogValuesToDeviceFunction(MOTOR_BACKWARD, processResponse);
	}

	public function primMotorLeft(b:Block):* {
		setAnalogValuesToDeviceFunction(MOTOR_LEFT, processResponse);
	}

	public function primMotorRight(b:Block):* {
		setAnalogValuesToDeviceFunction(MOTOR_RIGHT, processResponse);
	}

	public function primMotorStop(b:Block):* {
		setAnalogValuesToDeviceFunction(MOTOR_STOP, processResponse);
	}

	// Non-blocking call
	public function primMotorDrive(block:Block):* {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			return;
		}

		var pin:int = interp.arg(block, 0);
		var clockwise:String = interp.arg(block, 1);
		var percentage:int = interp.arg(block, 2);

		// Control the clockwise / counterclockwise
		// if the motor pin is 3, the direction pin is 4
		var request:ServerRequest = new ServerRequest(SET_DIGITAL_PIN, connection, (pin == 3)? 4 : 0, (clockwise == 'clockwise')? 1 : 0);
		app.serverRequestManager.sendRequest(request);

		// Control the speed
		var maxValue:int = 1023;
		var value:int = Math.min(Math.max(0, (percentage / 100) * maxValue), maxValue); // make sure between 0 and maxValue

		request = new ServerRequest(SET_PWM_PIN, connection, pin, value);
		app.serverRequestManager.sendRequest(request);		
	}

	// TO-DO: the current wait is a blocking call - blocks the whole CPU.  Need to figure out
	// another way to do.
	public function primMoveCockroachForward(b:Block):* {
		var pin1:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin1)) { 
			return;
		}

		var pin2:Number = parseInt(interp.arg(b, 1));
		if (isNaN(pin2)) { 
			return;
		}

		// const PWM1_PIN:int = 8;
		// const PWM2_PIN:int = 2;

		const PWM_SERVO_MIN:int = 100;
		const PWM_SERVO_MAX:int = 140;	

		const WAIT_SEC:Number = 0.2;

		nbMoveServo(pin1, PWM_SERVO_MAX);
		wait(WAIT_SEC);
		nbMoveServo(pin2, PWM_SERVO_MAX);
		wait(WAIT_SEC);
		nbMoveServo(pin1, PWM_SERVO_MIN);
		wait(WAIT_SEC);
		nbMoveServo(pin2, PWM_SERVO_MIN);
		wait(WAIT_SEC);
	}

	private function wait(secs:Number):void {
		var init:int = getTimer();
		while (true) {
			if (getTimer() - init >= secs * 1000) {
				break;
			}
		}
	}

	public function primMoveCockroachBackward(b:Block):* {
		var pin1:Number = parseInt(interp.arg(b, 0));
		if (isNaN(pin1)) { 
			return;
		}

		var pin2:Number = parseInt(interp.arg(b, 1));
		if (isNaN(pin2)) { 
			return;
		}

		// const PWM1_PIN:int = 8;
		// const PWM2_PIN:int = 2;
		const PWM_SERVO_MIN:int = 100;
		const PWM_SERVO_MAX:int = 140;	

		const WAIT_SEC:Number = 0.2;

		nbMoveServo(pin2, PWM_SERVO_MIN);
		wait(WAIT_SEC);
		nbMoveServo(pin1, PWM_SERVO_MIN);
		wait(WAIT_SEC);
		nbMoveServo(pin2, PWM_SERVO_MAX);
		wait(WAIT_SEC);
		nbMoveServo(pin1, PWM_SERVO_MAX);
		wait(WAIT_SEC);
	}

	// Generic Functions
	
	// Function to call Digital Pin and invoke whenDone() when it's completed
	// private function setDigitalPin(pin:int, value:int, whenDone:Function = null):void {
	private function setDigitalPin(pin:int, value:int, block:Block):void {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			block.requestState = 2; 
			return;
		}

		function requestHandler():ServerRequest {
			return new ServerRequest(SET_DIGITAL_PIN, connection, pin, value);
		}
	
		function successHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			error = false;
			errorDescription = "";
		}

		function failureHandler(errorNo:int):void {
			handleError(errorNo);
		}

		CommandHandler.executeBlockingCommand(block, interp, requestHandler, successHandler, failureHandler);

	}

	// Function to call PWM Pin and invoke whenDone() when it's completed
	// private function setPWMPin(pin:int, value:int, whenDone:Function = null):void {
	private function setPWMPin(pin:int, value:int, block:Block):void {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			block.requestState = 2; 
			return;
		}

		function requestHandler():ServerRequest {
			return new ServerRequest(SET_PWM_PIN, connection, pin, value);
		}
	
		function successHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			error = false;
			errorDescription = "";
		}

		function failureHandler(errorNo:int):void {
			handleError(errorNo);
		}

		CommandHandler.executeBlockingCommand(block, interp, requestHandler, successHandler, failureHandler);
	}

	private function processResponse(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
		if (xmlResponse.succeed()) {
			error = false;
			errorDescription = "";
		}
		else {
			handleError(xmlResponse.errorNo());
			// error = true;
			// errorDescription = xmlResponse.errorDescription();
		}
	}

	// private function moveServo(pin:int, degree:int, whenDone:Function = null):void {
	private function moveServo(pin:int, degree:int, block:Block):void {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			block.requestState = 2; 
			return;
		}

		function requestHandler():ServerRequest {
			return new ServerRequest(MOVE_SERVO, connection, pin, degree);
		}
	
		function successHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			error = false;
			errorDescription = "";
		}

		function failureHandler(errorNo:int):void {
			handleError(errorNo);
		}

		CommandHandler.executeBlockingCommand(block, interp, requestHandler, successHandler, failureHandler);
	}

	private function nbMoveServo(pin:int, degree:int, whenDone:Function = null):void {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			return;
		}

		var request:ServerRequest = new ServerRequest(MOVE_SERVO, connection, pin, degree);
		if (whenDone != null) request.completeHandler = whenDone;
		app.serverRequestManager.sendRequest(request);
	}

	private function getDigitalPin(pin:int, block:Block):void {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			block.requestState = 2; 
			block.response = 0; 
			return;
		}
			
		function requestHandler():ServerRequest {
			return new ServerRequest(READ_DIGITAL_PIN, connection, pin);
		}
	
		function successHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			error = false;
			errorDescription = "";

			if (xmlResponse.hasProperty('value')) {
				var value:String = xmlResponse.getProperty('value');
				// Scratch.app.logDebug('value ' + value);
				block.response = value;
			}
		}

		function failureHandler(errorNo:int):void {
			handleError(errorNo);
		}

		CommandHandler.executeBlockingCommand(block, interp, requestHandler, successHandler, failureHandler);
	}

	// TO-DO: Bug: when there're a set and read in a forever loop without any wait, the application will hang
	// Message was not received (either not sent or not received) - and thus the block hanged at state = 1
	// Need to further investigate.  -  Update: Seem to be okay with the C# driver.  Keep an eye.
	private function getAnalogPin(pin:int, block:Block):void {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			block.requestState = 2; 
			block.response = 0; 
			return;
		}
			
		function requestHandler():ServerRequest {
			return new ServerRequest(READ_ANALOG_PIN, connection, pin);
		}
	
		function successHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			error = false;
			errorDescription = "";

			if (xmlResponse.hasProperty('value')) {
				var value:String = xmlResponse.getProperty('value');

				block.response = value;
			}
		}

		function failureHandler(errorNo:int):void {
			handleError(errorNo);
		}

		CommandHandler.executeBlockingCommand(block, interp, requestHandler, successHandler, failureHandler);
	}

	// Get Analog Values from specified device function
	private function getAnalogValuesFromDeviceFunction(functionName:String, block:Block):void {
		
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) {
			block.requestState = 2; 
			block.response = 0; 
			return;
		}

		function requestHandler():ServerRequest {
			return new ServerRequest(DEVICE_FUNCTION, connection, functionName);
		}

		function successHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			error = false;
			errorDescription = "";

			if (xmlResponse.hasProperty('value')) {
				var value:String = xmlResponse.getProperty('value');
				block.response = value;
			}
		}

		function failureHandler(errorNo:int):void {
			handleError(errorNo);
		}

		CommandHandler.executeBlockingCommand(block, interp, requestHandler, successHandler, failureHandler);
	}

	// To Analog Values to specified device function 
	private function setAnalogValuesToDeviceFunction(functionName:String, whenDone:Function = null):void {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			return;
		}

		var request:ServerRequest = new ServerRequest(DEVICE_FUNCTION, connection, functionName);
		if (whenDone != null) request.completeHandler = whenDone;
		app.serverRequestManager.sendRequest(request);
	}

	// I2C Function - for testing purposes
	private function i2cRead(address:int, register:int, numOfBytes:int, block:Block):void {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			block.requestState = 2; 
			block.response = 0; 
			return;
		}
			
		function requestHandler():ServerRequest {
			return new ServerRequest(I2C_READ, connection, address, register, numOfBytes);
		}
	
		function successHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			error = false;
			errorDescription = "";

			if (xmlResponse.hasProperty('value')) {
				var value:String = xmlResponse.getProperty('value');
				block.response = value;
			}
		}

		function failureHandler(errorNo:int):void {
			handleError(errorNo);
		}

		CommandHandler.executeBlockingCommand(block, interp, requestHandler, successHandler, failureHandler);
	}

	private function i2cWrite(address:int, register:int, data:String, block:Block):void {
		/*
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			return;
		}

		var request:ServerRequest = new ServerRequest(I2C_WRITE, connection, address, register, data);
		if (whenDone != null) request.completeHandler = whenDone;
		app.serverRequestManager.sendRequest(request);
		*/

		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			block.requestState = 2; 
			return;
		}

		function requestHandler():ServerRequest {
			return new ServerRequest(I2C_WRITE, connection, address, register, data);
		}
	
		function successHandler(originalRequest:ServerRequest, xmlResponse:XMLResponse):void {
			error = false;
			errorDescription = "";
		}

		function failureHandler(errorNo:int):void {
			handleError(errorNo);
		}

		CommandHandler.executeBlockingCommand(block, interp, requestHandler, successHandler, failureHandler);
	}

	private function nbI2CWrite(address:int, register:int, data:String, whenDone:Function = null):void {
		var connection:String = DeviceManager.instance().getConnectedDevice();
		if (connection == null) { // return if not connected
			return;
		}

		var request:ServerRequest = new ServerRequest(I2C_WRITE, connection, address, register, data);
		if (whenDone != null) request.completeHandler = whenDone;
		app.serverRequestManager.sendRequest(request);
	}

	// error handling
	private function handleError(errorNo:int):void {
		error = true;
		errorDescription = XMLResponse.errorDesc(errorNo);

		app.runtime.stopAll(); // Stop all program
		DialogBox.notify(Translator.map("Attention!"), errorDescription);
	}

	private function dataHandler(xmlResponse:XMLResponse):void {
		if (xmlResponse.fail()) {
			app.logDebug('dataHandler errorNo ' + xmlResponse.errorNo());
			handleError(xmlResponse.errorNo());
		}
	}
}}

