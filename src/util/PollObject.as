package util {

// Interface to specify the step period and step function
public interface PollObject
{
	function step():void;
	function timeToPoll():Boolean;
}}


