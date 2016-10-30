
package primitives {

	import blocks.Block;
	import flash.utils.Dictionary;
	import interpreter.*;
	import scratch.*;

public class CloudServerPrims {

	private var app:Scratch;
	private var interp:Interpreter;

	public function CloudServerPrims(app:Scratch, interpreter:Interpreter) {
		this.app = app;
		this.interp = interpreter;
	}

	public function addPrimsTo(primTable:Dictionary): void {
		primTable["getTemperatureInCity:"] = primGetTemperatureInCity;
		primTable["convertCtoF:"] = primConvertCtoF;
		primTable["getTrafficCondition:"] = primGetTrafficCondition;
	}

	public function primNoop(b:Block):void {}

	public function primGetTemperatureInCity(b:Block):* {
		var city:String = interp.arg(b, 0);
		var temperatures:Dictionary = app.cloudServer.getHongKongWeatherManager().getTemperatures();	
		return temperatures[city];
	}

	public function primConvertCtoF(b:Block):* {
		var celsius:int = interp.arg(b, 0);
		var fahrenheit:int = celsius * 1.8 + 32;

		return fahrenheit;
	}

	public function primGetTrafficCondition(b:Block):* {
		var path:String = interp.arg(b, 0);
		var colorCodes:String = app.cloudServer.getHongKongTrafficManager().getTrafficCondition(path);
		return colorCodes;
	}

}}
