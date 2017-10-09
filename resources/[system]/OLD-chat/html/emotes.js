var Emote = {
    loadEmotes() {
	    const div = document.createElement('div');

	    $(div).text('Loading chat emotes...');

	    $(div).css({
	        'font-size': '1.5rem',
	        'position': 'absolute',
	        'left': '25px',
	        'top': '20px',
	        'color': '#fff',
	        'text-shadow': '2px 2px 2px rgba(0,0,0,0.75)'
	    });

	    $(div).addClass('loading-emotes');

    	document.body.appendChild(div);

        setTimeout(function() {

            const $loading = $('.loading-emotes');

            if ($loading[0]) {

                $loading.css({
                    'color': '#c0392b'
                });

                $loading.text('Failed loading some chat emotes, will keep trying. (API server currently busy)');
            }

            setTimeout(function() {
                $('.loading-emotes').remove();
            }, 7.5 * 1000);

        }, 30 * 1000);

        Emote.loadTwitchEmotes();
        Emote.loadSubEmotes();
        Emote.loadBTTVEmotes();
        Emote.loadFFZEmotes();

		Emote.waitTillEmotesLoaded();
    },

	waitTillEmotesLoaded()
    {
        if (!Emote.states['twitch'].loaded || !Emote.states['sub'].loaded || !Emote.states['BTTV'].loaded || !Emote.states['FFZ'].loaded) {
            setTimeout(Emote.waitTillEmotesLoaded, 250);
            return;
        }

        $('.loading-emotes').remove();
    },

	emoteCheck($message)
    {
        let msgHTML = $message;

        const words = msgHTML.replace('/\xEF\xBB\xBF/', '').replace('﻿', '').split(' ');
        const uniqueWords = [];
        let emoteCount = 0;

        $.each(words, function (i, el) {
            if ($.inArray(el, uniqueWords) === -1) uniqueWords.push(el);
        });

        for (let i = 0; i < uniqueWords.length; i++) {

            const word = uniqueWords[i];

            if (typeof Emote.emotes[word] === 'undefined') {
                continue;
            }

            emoteCount++;

            const img = document.createElement('img');
            img.src = Emote.emotes[word]['url'];
            img.alt = word;
            img.style.display = 'inline';
            img.style.width = 'auto';
            img.style.overflow = 'hidden';

			msgHTML = msgHTML.replace(new RegExp(word, 'g'), img.outerHTML);
        }

		return msgHTML
    },

	kappaCheck(msg)
    {
        $('img', msg).each(function() {

            const $img = $(this);

            if (/\ud83c\udf1d/g.test($img.attr('alt'))) {
                $img.replaceWith(document.createTextNode('Kappa'));
            }
        });
    },

	loadTwitchEmotes()
    {
        const xhr = new XMLHttpRequest();
        xhr.open('GET', 'https://twitchemotes.com/api_cache/v2/global.json');
        xhr.send();
        const urlTemplate = 'https://static-cdn.jtvnw.net/emoticons/v1/';

        xhr.ontimeout = function() {
            Emote.states['twitch'].loaded = true;
        };

        xhr.onload = function () {

            const emoteDic = JSON.parse(xhr.responseText)['emotes'];

            for (const emote in emoteDic) {

                Emote.emotes[emote] = {
                    url: urlTemplate + emoteDic[emote]['image_id'] + '/' + '1.0'
                };
            }

            Emote.states['twitch'].loaded = true;
        }
    },

	loadSubEmotes()
    {
        const xhr = new XMLHttpRequest();
        xhr.open('GET', 'https://twitchemotes.com/api_cache/v2/subscriber.json');
        xhr.send();
        const urlTemplate = 'https://static-cdn.jtvnw.net/emoticons/v1/';

        xhr.ontimeout = function() {
            Emote.states['sub'].loaded = true;
			alert("K")
        };

        xhr.onload = function () {
            const emoteDic = JSON.parse(xhr.responseText)['channels'];

            for (const channel in emoteDic) {

                for (const i in emoteDic[channel]['emotes']) {

                    const dict = emoteDic[channel]['emotes'][i];
                    const code = dict['code'];

                    if (Emote.isValidEmote(code)) {
                        Emote.emotes[code] = {
                            url: urlTemplate + dict['image_id'] + '/' + '1.0'
                        };
                    }
                }
            }

            Emote.states['sub'].loaded = true;
        };
    },

	loadBTTVEmotes()
    {
        const xhr = new XMLHttpRequest();
        xhr.open('GET', 'https://api.betterttv.net/2/emotes');
        xhr.send();
        const urlTemplate = 'https://cdn.betterttv.net/emote/';

        xhr.ontimeout = function() {
            Emote.states['BTTV'].loaded = true;
        };

        xhr.onload = function () {

            const emoteList = JSON.parse(xhr.responseText)['emotes'];

            for (const i in emoteList) {

                const dict = emoteList[i];

                if (!Emote.containsDisallowedChar(dict['code'])) {
                    Emote.emotes[dict['code']] = {
                        url: urlTemplate + dict['id'] + '/' + '1x'
                    };
                }
            }

            Emote.states['BTTV'].loaded = true;
        }
    },

	loadFFZEmotes(channels)
    {
        const xhr = new XMLHttpRequest();
        xhr.open('GET', 'https://api.frankerfacez.com/v1/room/id/51684790');
        xhr.send();
        const urlTemplate = 'https://cdn.frankerfacez.com/emoticon/';

        xhr.ontimeout = function() {
            Emote.states['FFZ'].loaded = true;
        };

        xhr.onload = function () {

            const emoteList = JSON.parse(xhr.responseText)['sets']['37097']['emoticons'];

            for (const i in emoteList) {

                const dict = emoteList[i];

                if (!Emote.containsDisallowedChar(dict['name'])) {
                    Emote.emotes[dict['name']] = {
                        url: urlTemplate + dict['id'] + '/' + '1'
                    };
                }
            }

            Emote.states['FFZ'].loaded = true;
        }
    },

	isValidEmote(text)
    {
        return !(text[0].match(/[A-Z]/g) ||
            text.match(/^[a-z]+$/g) ||
            text.match(/^\d*$/g)
        );
    },

	containsDisallowedChar(word)
    {
		const DISALLOWED_CHARS = ['\\', ':', '/', '&', "'", '"', '?', '!', '#'];
        for (const c in DISALLOWED_CHARS) {
            if (word.indexOf(c) > -1) {
                return true;
            }
        }

        return false;
    }
};

Emote.states = {
    twitch: {
        loaded: false
    },
    sub: {
        loaded: false
    },
    BTTV: {
        loaded: false
    },
    FFZ: {
        loaded: false
    }
};

Emote.emotes = {};
Emote.messages = {};
