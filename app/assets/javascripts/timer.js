/* Variables */
var countdown_id = 0;
var seconds_remaining = 0;
var scheduled_pause = -1;
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
	
	// If -1, there is no pause, and it will never trigger this
	if (scheduled_pause == seconds_remaining) {
		clearInterval(countdown_id);
		// Ajax to pause timer
		running = 'true' == $('#time_remaining').attr('running')
		if (running) {
			// Only call this once! Once it's expired, paused will be true
			turn_machine_off();
			jQuery.ajax({url:"/treatment_sessions/" + $('#time_remaining').attr('session') + "/treatment_expired",
			             data: "time=" + scheduled_pause,
				         type: "PUT",
			             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
			               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
			             async: false}); 	
		}    				
	}
	else if (0 == seconds_remaining) {
		clearInterval(countdown_id);
		// Ajax to expire timer
		running = 'true' == $('#time_remaining').attr('running')
		if (running) {
			// Only call this once! Once it's expired, paused will be true
			turn_machine_off();
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
		// 20s update interval on the dashboard
		// Users can override treatment area timers. The update clears the form, so we don't want it too fast.
		dashboard_id = setInterval("window.location.reload()", 20000);
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
		scheduled_pause = parseInt($('#time_remaining').attr('scheduled_pause'));
		
		// Count down every second
		if (running && seconds_remaining > 0) {
			// Could get called multiple times; assuming the server tolerates this
			turn_machine_on();
			countdown_id = setInterval("countdown()", 1000);
		}
		else {
			countdown();
		}
	}
}

function turn_machine_on() {
	issue_command('slenderon');
	// If we had to get the protocol id here, do it this way. As it is, the server is computing it.
	// You can only change the protocol through interaction with the server anyway (start/pause/resume)
  	//var e = document.getElementById("treatment_session_protocol_id");
    //var idx = e.options[e.selectedIndex].value;
    var music = $('#jplayer').attr('src');
	$('#jplayer').html('<audio id="music" src="' + music + '" autoplay loop>');
}

function turn_machine_off() {
	issue_command('slenderoff');
	$('#music').remove();
}

function issue_command(value) {
	var machine = $('#machine_config');
	if (machine.length > 0) {
		machine_url = "http://webiopi:raspberry@" + machine.attr('hostname') + "/GPIO/" + machine.attr('api_port') + "/" + value;
		$('#machinestat').prop('src', machine_url);
 
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


