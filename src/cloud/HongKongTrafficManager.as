
package cloud {

	import scratch.*;
	import flash.utils.getTimer;
	import util.*;
	import flash.utils.Dictionary;

public class HongKongTrafficManager implements PollObject {
	
	private var app:Scratch;
	private var lastPollTime:int = -1;
	private static const URL:String = 'http://resource.data.one.gov.hk/td/journeytime.xml';
	//private static const URL:String = 'http://localhost/journeytime.xml';
	private static const POLLTRAFFICTIME:int = 6000000; // poll once one hour

	private var locations:Dictionary; 
	private var destinations:Dictionary;
	private var colorCodes:Dictionary;

	private var paths:Dictionary;
	private var trafficConditions:Dictionary;
	private var dataLoaded:Boolean = false;

	public function HongKongTrafficManager(app:Scratch) {
		this.app = app;
		initLocations();
		initDestinations();
		initColorCodes();

		paths = new Dictionary();
		trafficConditions = new Dictionary();

		app.pollObjectManager.register(this);
	}

	private function initLocations():void {
		locations = new Dictionary();

		locations['H1'] = 'Gloucester Road';
		locations['H2'] = 'Canal Road Flyover';
		locations['H3'] = 'Island Eastern Corridor';
		locations['H11'] = 'Island Easter Corridor';
		locations['K01'] = 'Ferry Street';
		locations['K02'] = 'Gascoigne Road';
		locations['K03'] = 'Waterloo Road';
		locations['K04'] = 'Princess Margaret Road';
		locations['K05'] = 'Kai Fuk Road';
		locations['K06'] = 'Chatham Road';
		locations['SJ1'] = 'Tai Po Road';
		locations['SJ2'] = 'Tate\'s Cairn Highway';
		locations['SJ3'] = 'Tolo Highway';
		locations['SJ4'] = 'San Tin Highway';
		locations['SJ5'] = 'Tuen Mun Road'; 
	}

	private function initDestinations():void {
		destinations = new Dictionary();

		destinations['CH'] = 'Cross Harbour Tunnel';
		destinations['EH'] = 'Eastern Harbour Crossing';
		destinations['WH'] = 'Western Harbour Crossing';
		destinations['LRT'] = 'Lion Rock Tunnel';
		destinations['SMT'] = 'Shing Mun Tunnel';
		destinations['TCT'] = 'Tate\'s Cairn Tunnel';
		destinations['TKTL'] = 'Ting Kau, Tai Lam Tunnel';
		destinations['TKTM'] = 'Ting Kau, Tuen Mun Road';
		destinations['TSCA'] = 'Tsing Sha Control Area';
		destinations['TWCP'] = 'Tsuen Wan via Castle Peak';
		destinations['TWTM'] = 'Tsuen Wan via Tuen Mun';
	}

	private function initColorCodes():void {
		colorCodes = new Dictionary();
		
		colorCodes[1] = 'Red';
		colorCodes[2] = 'Yellow';
		colorCodes[3] = 'Green';
		colorCodes[-1] = 'Not applicable';
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
		return (lastPollTime == -1) || (currentTime - lastPollTime > POLLTRAFFICTIME);
	}

	private function processResponse(response:String):void {
		
		// Need to remove the namespace declarations
		var nsRegEx:RegExp = new RegExp(" (xmlns|xsi)(?:.*?)?=\".*?\"", "gim");
    		var xml:XML = new XML(response.replace(nsRegEx, "")); 

		var children:XMLList = xml.children();
		for each (var child:XML in children) {
			var locationID:String = child.LOCATION_ID;
			var location:String = locations[locationID];

			var destinationID:String = child.DESTINATION_ID;
			var destination:String = destinations[destinationID];

			var id:String = locationID + "-" + destinationID;
			var path:String = location + " to " + destination;
			paths[id] = path;

			var colorID:int = child.COLOUR_ID;
			var colorCode:String = colorCodes[colorID];
			trafficConditions[path] = colorCode;

			app.logDebug(path + ": " + colorCode);		
		}

		dataLoaded = true;
	}	

	public function getRoads():Array {
		var roads:Array = new Array();
		for each (var path:String in paths) {
			roads.push(path);
		}
		return roads;
	}

	public function getTrafficCondition(path:String):String {
		return trafficConditions[path];
	}

	public function isUp():Boolean {
		return dataLoaded;
	}
}
}
