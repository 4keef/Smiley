local discordia = require 'discordia'  
local client = discordia.Client()

discordia.extensions()

local Pastor = require 'pastor'
local books = require './books'

client:on('ready', function ()
  local username = client.user.username

  if username:lower() ~= 'smiley' then
    print('Please change bot name to smiley!')
  end

  print('Logged in as ' .. username)

  local guilds = client.guilds
end)


local prefix = '!'

local function fix_num_start(name)
  if tonumber(string.sub(name, 1, 1)) then 
    name = string.format("%s %s", string.sub(name, 1, 1), string.sub(name, 2))
  end 

  return name
end

local function find(name)
  name = fix_num_start(name)

  for i, v in ipairs(books) do 
    v = string.lower(v)
    name = string.lower(name)
    print(v) 
    if v == name then
      print(v)
      return true
    end
  end
  return false
end

local commands = {
  [prefix .. 'ping'] = {
    description = 'Pong 🏓',
    exec = function (ctx, args)
      local output = 'Pong 🏓'

      if #args > 0 then 
        print(table.concat(args, " "))
        output = output .. ', ' .. table.concat(args, " ")
      end

      ctx:reply(output)
    end
  },

  [prefix .. 'preach'] = {
    description = 'Get bible verses from the bible\nUsage: `!preach genesis 5 1-5\n!preach genesis 2 1`',
    exec = function (ctx, args)
      local book, chapter, range = table.unpack(args)

      if not book then 
        return ctx:reply("Missing required argument `book`")
      else if not chapter then 
        return ctx:reply("Missing required argument `chapter`")
      else if not range then 
        return ctx:reply("Missing required argument `range`") 
      else if not find(book) then 
        local output = "\"%s\" is not a book in the bible. Check your DMs(Make sure private messages are on)"
        
        ctx:reply(string.format(output, book))

        local auhtor = ctx.author 
        
        return auhtor:send(string.format("Books in the bible: \n%s", table.concat( books, "\n")))
      end
      end
      end
      end 

      book = fix_num_start(book)

      local status, verses = pcall(Pastor.Preach,{ book = string.lower(book),
                                     chapter = chapter,
                                     ranges = {range} })


      if not status then 
        return ctx:reply("Could not retrieve verse")
      end
      
      for k, v in pairs(verses) do 
        ctx:reply(v.text)
      end
    end
  }
}

client:on('messageCreate', function (message)
  local args = message.content:split(' ')

  local command = commands[args[1]]


  if command then 
    args = table.remove(args, 1) and args or {}
    command.exec(message, args)
  end

  if args[1] == "!help" then -- display all the commands
    local output = {}
    for word, tbl in pairs(commands) do
      table.insert(output, "Command: " .. word .. "\nDescription: " .. tbl.description)
    end

    message:reply(table.concat(output, "\n\n"))
  end
end)


return client
