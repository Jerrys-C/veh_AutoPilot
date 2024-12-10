-- fxmanifest.lua

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Jerry'
description 'Vehicle AutoPilot Script'
version '1.0.0'

client_scripts {
    'client.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/*.mp3',
}

shared_script '@ox_lib/init.lua'