local dotnev = require 'Dotenv'
local client = require './src/client'

dotnev.load_env()

client:run( 'Bot ' .. dotnev.get_value 'TOKEN' )
