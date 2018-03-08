function ajaxGet(url, success, error) {
	var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
	xhr.open('GET', url);
	xhr.onreadystatechange = function() {
		if(xhr.readyState > 3) {
			if(xhr.status == 200) {
				success(xhr.responseText);
			}
			else {
				error(xhr.statusText);
			}
		}
	};
	xhr.onerror = function() {
		error("Connection Lost");
	};
	xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
	xhr.send();
}

function ajaxPost(url, data, success, error) {
	var params = typeof data == 'string' ? data : Object.keys(data).map(
		function(k) {
			return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
		}
	).join('&');

	var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
	xhr.open('POST', url);
	// @todo: error handling
	xhr.onreadystatechange = function() {
		if(xhr.readyState > 3) {
			if(xhr.status == 200) {
				success(xhr.responseText);
			}
			else {
				error(xhr.statusText);
			}
		}
	};
	xhr.onerror = function() {
		error("Connection Lost");
	};
	xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
	xhr.setRequestHeader('Content-Type', 'application/json');
	// xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	xhr.send(params);
}