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
	var hasClicked = false;

	window.addEventListener('message', function(event) {
		if (event.data.type == "close") {
			document.body.style.display = "none";
		} else if (event.data.type == "list") {
			hasClicked = false;

			document.body.style.display = "flex";
			$('.create').hide()
			$('.characters').show()
			$('#select').show()
			$('#birth').hide()
			$('a[href="http://themodestland/disconnect"]').show()
			$('a[href="http://themodestland/list"]').hide()
			$('.characters #character').remove()

			event.data.characters = event.data.characters.reverse();

			if (event.data.characters.length == 3) { $('#new').css("display", "none"); }

			for (var i = 0; i < event.data.characters.length; i++) {
				var div = document.createElement("div");
				div.id = "character"
				div.classList.add('character');
				var first_name = document.createElement("h3");
				first_name.innerHTML = "<b>First Name:</b> "+event.data.characters[i].first_name
				div.appendChild(first_name);
				var last_name = document.createElement("h3");
				last_name.innerHTML = "<b>Last Name:</b> "+event.data.characters[i].last_name
				div.appendChild(last_name);
				var cash = document.createElement("h3");
				cash.innerHTML = "<b>Cash:</b> <span>$</span>"+(event.data.characters[i].cash).formatMoney(2, '.', ',');
				cash.style = "padding-top: 25px"
				div.appendChild(cash);
				var bank = document.createElement("h3");
				bank.innerHTML = "<b>Bank:</b> <span>$</span>"+(event.data.characters[i].bank).formatMoney(2, '.', ',');
				div.appendChild(bank);
				var gender = document.createElement("h3");
				gender.innerHTML = "<b>Gender:</b> "+event.data.characters[i].gender.charAt(0).toUpperCase() + event.data.characters[i].gender.slice(1);
				gender.style = "padding-top: 25px"
				div.appendChild(gender);
				$('.characters').prepend(div);
			}

			$('.characters #character').on("click", function() {
				clicked = this
				$(this).addClass("selected")
				$("button#select").removeClass("disabled")
				$('.characters #character').each(function() {
					if (clicked != this) $(this).removeClass("selected")
				})
			})

			var wasSelected = false;
			$("button#select").on('click', function() {
				var i = event.data.characters.length-1, selected;
				$('.characters #character').each(function() {
					if (clicked == this) selected = i
					i--;
				})
				if (!wasSelected) {
					wasSelected = true
					$.post('http://themodestland/selected', JSON.stringify(event.data.characters[selected]), function(data) {});
				}
			})

			$('#new').on('click', function(){
				$('.create').show()
				$('.characters').hide()
				$('#select').hide()
				$('#birth').show()
				$('a[href="http://themodestland/disconnect"]').hide()
				$('a[href="http://themodestland/list"]').show()

				$('.option p').on("click", function() {
					clicked = this
					$('.option p').each(function() {
						if( clicked != this ) $(this).removeClass("selected")
					})
					$(this).addClass("selected")
				})

				$('#birth').on('click', function() {
					var first_name = $('#first_name').val()
					var last_name = $('#last_name').val()
					var gender = $('.option p.selected').attr('id')
					if (first_name.length > 2 && last_name.length > 2 && (gender == "male" || gender == "female" || gender == "other")) {
						if (!hasClicked) {
							hasClicked = true
							$.post('http://themodestland/new', JSON.stringify({
								first_name: first_name,
								last_name: last_name,
								gender: gender,
							}), function(data) {
								$('.notification').hide()
							});
						}
					} else {
						$('.notification').show()
						$('.notification').html("Oh no you didn't supply enough information, please try again.")
					}
				})
			})
		} else if (event.data.type == "error") {
			document.getElementsByClassName('notification')[0].style.display = "block";
		} else if (event.data.type == "click") {
			Click(cursorX - 1, cursorY - 1);
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
