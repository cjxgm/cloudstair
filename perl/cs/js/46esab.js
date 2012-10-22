
/**********************************************************************
 * 46esab - the reversed base64
 */

function encode_46esab(what)
{
	return btoa(what).split('').reverse().join('');
}

function decode_46esab(what)
{
	return atob(what.split('').reverse().join(''));
}

