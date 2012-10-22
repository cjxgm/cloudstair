
/**********************************************************************
 *
 * The Utility Library Like jQuery.
 *
 **** Why not use jQuery?
 * Because it satisfies IE! Fuck IE and Microsoft!
 *
 */

function $(q)
{
	return $.addBase(document.querySelector(q));
}

$.create = function(what)
{
	var obj = document.createElement(what);
	if (!obj) return undefined;
	return $.addBase(obj);
}

$.ready = function(fn)
{
	window.onload = fn;
}

$.get = function(url, success, failed)
{
	try {
		var req = new XMLHttpRequest();
		req.open('GET', url, true);
		req.responseType = "text";
		req.onload = function(e) {
			if (success) success(req.response);
		};
		req.send();
	} catch(e) {
		if (failed) failed('' + e);
	}
}

$.time = function(time, fn)
{
	return window.setTimeout(fn, time);
}

/**********************************************************************
 * base
 */

$.base = {};

$.addBase = function(obj)
{
	obj.attr = $.base.attr;
	obj.addTo = $.base.addTo;
	obj.removeFrom = $.base.removeFrom;
	obj.setText = $.base.setText;
	obj.setHTML = $.base.setHTML;
	return obj;
}

$.base.attr = function(option, value)
{
	if (value !== undefined) {
		this.setAttribute(option, value);
		return this;
	}
	return this.getAttribute(option);
}

$.base.addTo = function(where)
{
	where.appendChild(this);
	return this;
}

$.base.removeFrom = function(where)
{
	where.removeChild(this);
	return this;
}

$.base.setText = function(what)
{
	this.textContent = what;
	return this;
}

$.base.setHTML = function(what)
{
	this.innerHTML = what;
	return this;
}

