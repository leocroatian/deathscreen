fx_version 'cerulean'
game 'gta5'

lua54 'yes'

ui_page 'html/index.html'
files {
  'html/index.html',
  'html/style.css',
  'html/script.js',
}

client_script 'client.lua'
server_script 'server.lua'
shared_scripts { '@ox_lib/init.lua', 'config.lua' }