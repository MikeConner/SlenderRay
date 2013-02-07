/* Variables */
var countdown_id = 0;
var seconds_remaining = 0;
var dashboard_id = 0;

$(function() {
	if ("onpagehide" in window) {
		window.addEventListener("pageshow", myLoadHandler, false);
		window.addEventListener("pagehide", myUnloadHandler, false);
	}
	else {
		window.addEventListener("load", myLoadHandler, false);
		window.addEventListener("unload", myUnloadHandler, false);
	}
});

function countdown() {
	var m = Math.floor(seconds_remaining/60);
	var s = seconds_remaining - m*60;
	
	$('#time_remaining').text(m + ':' + (s < 10 ? "0" : "") + s);
	
	if (0 == seconds_remaining) {
		clearInterval(countdown_id);
		// Ajax to expire timer
		running = 'true' == $('#time_remaining').attr('running')
		if (running) {
			// Only call this once! Once it's expired, paused will be true
			jQuery.ajax({url:"/treatment_sessions/" + $('#time_remaining').attr('session') + "/timer_expired",
				         type: "PUT",
			             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
			               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
			             async: false}); 	
		}    		
	}
	
	seconds_remaining = seconds_remaining - 1;
}

function myLoadHandler(evt) {
	var tr_remaining = document.getElementById('time_remaining');
	var tr_dashboard = document.getElementById('dashboard_marker');
	if (evt.persisted) {
		// This is actually a pageshow event and the page is coming out of the page cache
		// Don't do "one-time" work we'd normally do in OnLoad
		if (tr_remaining) {
			window.location.reload();
		}
		
		return;
	}
	
	if (tr_dashboard && 0 == dashboard_id) {
		dashboard_id = setInterval("window.location.reload()", 10000);
	}
	else {
		clearInterval(dashboard_id);
		dashboard_id = 0;
	}
	// Either a load event for older browsers,
	// or a pageshow event for the initial load in supported browsers
	// Do everything a regular load event handler does here
	if (tr_remaining) {
		running = 'true' == $('#time_remaining').attr('running')
		seconds_remaining = parseInt($('#time_remaining').attr('remaining'));
		
		// Count down every second
		if (running && seconds_remaining > 0) {
			countdown_id = setInterval("countdown()", 1000);
		}
		else {
			countdown();
		}
	}
}

function myUnloadHandler(evt) {
	clearInterval(countdown_id);
	
	if (evt.persisted) {
		// This is a pagehide event and the page is going into the page cache
		// Don't do any destructive work, or work that shouldn't be duplicated
		return;
	}
	
	// Either a load event for older browsers,
	// or a pageshow event for the initial load in supported browsers
	// Do everything a regular load event handler does here	
}



function play_tone(freq, secs) {
 
  var samples = [];
//  var samples_length = 44100;            // 1 second (44.1 KHz)
  var samples_length = secs*44100;            // 1 second (44.1 KHz)

  for (var i=0; i<samples_length; i++) { // fills array with samples
    var t = i/samples_length;            // time from 0 to 1
    // Generate samples using sine wave equation (between 0 and 255)
    samples[i] = 128+Math.round(127*Math.sin(freq*2*Math.PI*t));
  }
 
  var wave = new RIFFWAVE();          // Create raw wav file
      wave.header.sampleRate = 44100; // 44.1Khz (1 second)
      wave.header.numChannels = 1;    // 1 channel (mono)
      wave.Make(samples);
 
  var audio = new Audio();    // Create <audio> tag
      audio.src=wave.dataURI;
      audio.play();
 
}
 