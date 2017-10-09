$(function() {
	var documentWidth = document.documentElement.clientWidth;
	var documentHeight = document.documentElement.clientHeight;

	function UpdateCursorPos() {
		cursor.style.left = cursorX;
		cursor.style.top = cursorY;
	}

	function Click(x, y) {
		var element = $(document.elementFromPoint(x, y));
		element.focus().click();
	}

	var cursor = document.getElementById("cursor");
	var cursorX = documentWidth / 2;
	var cursorY = documentHeight / 2;

	window.onkeydown = (e) => {
		if (e.keyCode == 27 || e.keyCode == 112) $.post('http://interaction/close', JSON.stringify({}), function(data) {});
	}

	window.addEventListener('message', function(event) {
		if (event.data.type == "close") {
			cursor.style.display = "none";
			document.body.style.display = "none";
			$('ul').empty()
		} else if (event.data.type == "list") {
			document.body.style.display = "flex";
			cursor.style.display = "block";

			$('#close').on("click", function() {
				$.post('http://interaction/close', JSON.stringify({}), function(data) {});
			})
		} else if (event.data.type == "click") {
			Click(cursorX - 1, cursorY - 1);
		} else if (event.data.type == "add") {
			if(typeof $('li#'+event.data.id).html() == 'undefined') {
				var add = document.createElement("li");
				add.innerText = event.data.name
				add.id = event.data.id
				$('ul').append(add);

				$(add).on("click", function() {
					$.post('http://interaction/'+event.data.id, JSON.stringify({}), function(data) {});
				});
			}
		}
	});

	$(document).mousemove(function(event) {
		cursorX = event.pageX;
		cursorY = event.pageY;
		UpdateCursorPos();
	});

	Number.prototype.formatMoney = function(c, d, t) {
		var n = this,
		c = isNaN(c = Math.abs(c)) ? 2 : c,
		d = d == undefined ? "." : d,
		t = t == undefined ? "," : t,
		s = n < 0 ? "-" : "",
		i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))),
		j = (j = i.length) > 3 ? j % 3 : 0;
		return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
	};
});
