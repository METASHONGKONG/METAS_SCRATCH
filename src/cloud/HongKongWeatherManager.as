
package cloud {

	import scratch.*;
	import flash.utils.getTimer;
	import util.*;
	import flash.utils.Dictionary;

public class HongKongWeatherManager implements PollObject {

	private var app:Scratch;
	private var lastPollTime:int = -1;
	private static const URL:String = 'http://rss.weather.gov.hk/rss/CurrentWeather.xml';
	private static const POLLWEATHERTIME:int = 6000000; // poll once one hour
	private var dataLoaded:Boolean = false;

	private var locations:Array = ["Hong Kong Observatory", "King\'s Park", "Wong Chuk Hang", "Ta Kwu Ling", 
		"Lau Fau Shan", "Tai Po", "Sha Tin", "Tuen Mun", "Tseung Kwan O", "Sai Kung", "Cheung Chau", 
		"Chek Lap Kok", "Tsing Yi", "Shek Kong", "Tsuen Wan Ho Koon", "Tsuen Wan Shing Mun Valley", 
		"Hong Kong Park", "Shau Kei Wan", "Kowloon City", "Happy Valley", "Wong Tai Sin", "Stanley", 
		"Kwun Tong", "Sham Shui Po", "Kai Tak Runway Park", "Yuen Long Park"];

	private var temperatures:Dictionary;

	public function HongKongWeatherManager(app:Scratch) {
		this.app = app;
		temperatures = new Dictionary();

		app.pollObjectManager.register(this);
	}

	// Required by PollObject
	public function step():void {

		function completeHandler(data:String):void {
			if (data) {
				processResponse(data);
			}
		}

		dataLoaded = false;
		app.server.serverGet(URL, completeHandler);
		lastPollTime = getTimer();
	}

	public function timeToPoll():Boolean {
		var currentTime:int = getTimer();
		return (lastPollTime == -1) || (currentTime - lastPollTime > POLLWEATHERTIME);
	}

	private function processResponse(response:String):void {
		if (response == null) return;

		for each (var location:String in locations) {
			var temperature:int = fetchTemperature(location, response);
			temperatures[location] = temperature;

			app.logDebug('location: ' + location + ' temperature: ' + temperature);
		}

		dataLoaded = true;
	}

	private function fetchTemperature(location:String, response:String):int {
		var pattern:RegExp = new RegExp(location + ".+degrees", "");
		var result:String = pattern.exec(response);

		if (result == null) return -99;

		pattern = /\d+ degrees/;
		var degrees:String = pattern.exec(result);

		var len:int = degrees.length;
		var degree:int = parseInt(degrees.substr(0, len - 8));
		return degree;
	}

	public function getLocations():Array {
		if (dataLoaded == false) {
			return new Array();
		}
		return locations;
	}

	public function getTemperatures():Dictionary {
		return temperatures;
	}

	public function isUp():Boolean {
		return dataLoaded;
	}
}
}
