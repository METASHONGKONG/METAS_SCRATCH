package cloud {

import uiwidgets.*;
import translation.*;

public class CloudServer {

	private var app:Scratch;

	private var hongkongWeatherManager:HongKongWeatherManager;
	private var hongkongTrafficManager:HongKongTrafficManager;

	private var indicator:IndicatorLight;

	private static const INDICATOR_RED:int = 0xff0000;
	private static const INDICATOR_YELLOW:int = 0xffff01;
	private static const INDICATOR_GREEN:int = 0x00C000;

	public function CloudServer(app:Scratch) {
		this.app = app;

		hongkongWeatherManager = new HongKongWeatherManager(app);
		hongkongTrafficManager = new HongKongTrafficManager(app);

		indicator = new IndicatorLight();
		indicator.setColorAndMsg(INDICATOR_RED, Translator.map("Not connected"));
	}

	public function setIndicator():IndicatorLight {
		var isWeatherUp:Boolean = hongkongWeatherManager.isUp();
		var isTrafficUp:Boolean = hongkongTrafficManager.isUp();

		if (isWeatherUp && isTrafficUp) {
			indicator.setColorAndMsg(INDICATOR_GREEN, Translator.map("Connected"));
		}
		else if (isWeatherUp && !isTrafficUp) { // Weather is up, but Traffic is not
			indicator.setColorAndMsg(INDICATOR_YELLOW, Translator.map("Weather is Ready"));
		}
		else if (!isWeatherUp && isTrafficUp) { // Traffic is up, but Weather is not
			indicator.setColorAndMsg(INDICATOR_YELLOW, Translator.map("Traffic is Ready"));
		}
		else { // Both Weather and Traffic are down
			indicator.setColorAndMsg(INDICATOR_RED, Translator.map("Not connected"));
		}
		return indicator;
	}

	public function getHongKongWeatherManager():HongKongWeatherManager {
		return hongkongWeatherManager;
	}
	
	public function getHongKongTrafficManager():HongKongTrafficManager {
		return hongkongTrafficManager;
	}
}
}
