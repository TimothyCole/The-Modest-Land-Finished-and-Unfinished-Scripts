resource_type 'gametype' { name = 'The Modest Land' }

dependency 'modest'

client_script 'client.lua'
server_script 'server.lua'

server_exports {
	'serializeTable'
}

client_exports {
	'serializeTable'
}

ui_page "nui/announcement.html"

files {
	"nui/announcement.html",
	"nui/announcement.css",
	"nui/announcement.js",
}
