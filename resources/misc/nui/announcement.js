'use static';

(function() {
	window.addEventListener('message', function(event) {
		var message = event.data.message;
		var announcement = document.getElementsByTagName("h2")[0];

		announcement.innerText = message;
		$(document.body).fadeIn(250);

		setTimeout(hideAnnouncement, 10000);
	});

	var hideAnnouncement = function() {
		$(document.body).fadeOut(250);
	};
})()
