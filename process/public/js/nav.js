handle = function(event) {
	key = event.keyCode;
	if (key == 37 || key == 39)
		location.href = location.pathname.split('/')[1] * 1 + (key == 39 ? 1 : -1);
	if (key == 38 || key == 40) {
		confirmed = key == 38 ? true : confirm('Delete?');
		if (!confirmed)
			return;

		document.getElementById('op').value = key == 38 ? 'update' : 'delete';
		document.forms[0].submit();
	}
}

document.onkeydown = handle;
document.getElementById('lang').focus();
