ui_page 'ui.html'

server_scripts {
	'config.lua',
	'server/util.lua',
	'server/main.lua',
	'server/db.lua',
	'server/classes/player.lua',
	'server/classes/groups.lua',
	'server/player/login.lua'
}

client_scripts {
	'client/main.lua'
}

files {
	'ui.html',
	'pdown.ttf'
}

server_exports {
	'getPlayerFromId',
	'addAdminCommand',
	'addCommand',
	'addGroupCommand'
}
