$.ready(function() {
	// bind events
	$('.btn-add').onmouseover = function()
	{
		$('#proj').focus();
	}
	$('.btn-add').onmouseout = function()
	{
		$('#proj').blur();
	}
	$('#proj').onkeypress = $('#addr').onkeypress = function(evt)
	{
		if (evt.keyCode == 13) {
			var proj = $('#proj').value;
			var addr = $('#addr').value;
			if (proj === "" || addr === "") return;
			add_project(proj, addr);
			$('#proj').value = '';
			$('#addr').value = '';
		}
	}

	// init
	show_progress("Loading...");
	$.time(500, function() {
		query_project(hide_progress);
	});
});

function show_progress(text)
{
	$('#loading-text').setText(text);
	$('#loading').attr('class', 'modal modal-show');
}

function hide_progress()
{
	$('#loading').attr('class', 'modal modal-hide');
}

function query_project(done)
{
	$.get('?query&', function(text) {
		$('#content').setHTML(decode_46esab(text));
		done();
		enable_auto_refresh();
	}, function(err) {
		$('#content').setHTML('<h1>Failed to query projects.</h1>');
		done();
		enable_auto_refresh();
	});
}

function add_project(proj, addr)
{
	disable_auto_refresh();

	show_progress("Adding project...");
	$.time(200, function() {
		$.get('?add&proj=' + encode_46esab(proj) +
				'&addr=' + encode_46esab(addr), function() {
			show_progress("Loading...");
			query_project(hide_progress);
		}, function(err) {
			hide_progress();
			$('#content').setHTML('<h1>Failed to add project.</h1>');
		});
	});
}

function start_project(proj)
{
	disable_auto_refresh();

	show_progress("Starting project...");
	$.time(200, function() {
		$.get('?start&proj=' + proj, function() {
			show_progress("Loading...");
			query_project(hide_progress);
		}, function(err) {
			hide_progress();
			$('#content').setHTML('<h1>Failed to start project.</h1>');
		});
	});
}

function stop_project(proj)
{
	disable_auto_refresh();

	show_progress("Stoping project...");
	$.time(200, function() {
		$.get('?stop&proj=' + proj, function() {
			show_progress("Loading...");
			query_project(hide_progress);
		}, function(err) {
			hide_progress();
			$('#content').setHTML('<h1>Failed to stop project.</h1>');
		});
	});
}

function delete_project(proj)
{
	disable_auto_refresh();

	show_progress("Deleting project...");
	$.time(200, function() {
		$.get('?delete&proj=' + proj, function() {
			show_progress("Loading...");
			query_project(hide_progress);
		}, function(err) {
			hide_progress();
			$('#content').setHTML('<h1>Failed to delete project.</h1>');
		});
	});
}

function get_project(proj)
{
	location.href = "?get&proj=" + proj;
}

var auto_refresh_timer;

function enable_auto_refresh()
{
	disable_auto_refresh();
	auto_refresh_timer = $.time(1000, function fn() {
		query_project(function() {
			auto_refresh_timer = $.time(1000, fn);
		});
	});
}

function disable_auto_refresh()
{
	if (auto_refresh_timer !== undefined)
		clearTimeout(auto_refresh_timer);
}

