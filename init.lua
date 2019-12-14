-- kana <--> eisuu binds
local prevKeyCode
local leftCommand = 0x37
local rightCommand = 0x36
local eisuu = 0x66
local kana = 0x68

local function keyStroke(modifiers, character)
   hs.eventtap.keyStroke(modifiers, character)
end

local function jp()
   keyStroke({}, kana)
end

local function eng()
   keyStroke({}, eisuu)
end

local function handleEvent(e)
   local keyCode = e:getKeyCode()

   local isCmdKeyUp = not(e:getFlags()['cmd']) and e:getType() == hs.eventtap.event.types.flagsChanged
   if isCmdKeyUp and prevKeyCode == leftCommand then
      eng()
   elseif isCmdKeyUp and prevKeyCode == rightCommand then
      jp()
   end

   prevKeyCode = keyCode
end

eventtap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, handleEvent)
eventtap:start()


-- other binds
local function keyCode(key, modifiers)
   modifiers = modifiers or {}
   return function()
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
      hs.timer.usleep(1000)
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()
   end
end

local function remapKey(modifiers, key, keyCode)
   hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
end

local function hotkeys(application)
  if application ~= 'vscode' then
    remapKey({'ctrl'}, 'f', keyCode('right'))
    remapKey({'ctrl'}, 'b', keyCode('left'))
    remapKey({'ctrl'}, 'n', keyCode('down'))
    remapKey({'ctrl'}, 'p', keyCode('up'))
    remapKey({'ctrl'}, 'h', keyCode('delete'))
  end
  remapKey({'ctrl'}, 'e', keyCode('right', {'cmd'}))
  remapKey({'ctrl'}, 'a', keyCode('left', {'cmd'}))

  remapKey({'ctrl'}, 'w', keyCode('x', {'cmd'}))
  remapKey({'ctrl'}, 'y', keyCode('v', {'cmd'}))

  remapKey({'ctrl'}, 'i', keyCode('tab'))
  remapKey({'ctrl'}, 'm', keyCode('return'))
  remapKey({'ctrl'}, 's', keyCode('f', {'cmd'}))
  remapKey({'ctrl'}, '/', keyCode('z', {'cmd'}))
  remapKey({'ctrl'}, '-', keyCode('z', {'cmd'}))
  remapKey({'ctrl'}, '[', keyCode('escape'))

  remapKey({'ctrl'}, 'v', keyCode('pagedown'))
  remapKey({'alt'}, 'v', keyCode('pageup'))
  remapKey({'cmd', 'shift'}, ',', keyCode('home'))
  remapKey({'cmd', 'shift'}, '.', keyCode('end'))
end

local function disableAllHotkeys()
   for k, v in pairs(hs.hotkey.getHotkeys()) do
      v['_hk']:disable()
   end
end

local function enableAllHotkeys()
   hotkeys('general')
end

local function enableHotkeysForVSCode()
   hotkeys('vscode')
end

local function handleGlobalAppEvent(name, event, app)
   if event == hs.application.watcher.activated then
      -- hs.alert.show(name)
      if name == "iTerm2" or name == "ターミナル" or name == "Emacs" then
         disableAllHotkeys()
      elseif name == "Code" then
         enableHotkeysForVSCode()
      else
         enableAllHotkeys()
      end
   end
end

appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
appsWatcher:start()
