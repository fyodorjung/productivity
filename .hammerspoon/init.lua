---- All of the keys, from here:
---- https://github.com/Hammerspoon/hammerspoon/blob/f3446073f3e58bba0539ff8b2017a65b446954f7/extensions/keycodes/internal.m
---- except with ' instead of " (not sure why but it didn't work otherwise)
---- and the function keys greater than F12 removed.
local keys = {
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z",
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "`",
  "=",
  "-",
  "]",
  "[",
  "\'",
  ";",
  "\\",
  ",",
  "/",
  ".",
  "§",
  "f1",
  "f2",
  "f3",
  "f4",
  "f5",
  "f6",
  "f7",
  "f8",
  "f9",
  "f10",
  "f11",
  "f12",
  "pad.",
  "pad*",
  "pad+",
  "pad/",
  "pad-",
  "pad=",
  "pad0",
  "pad1",
  "pad2",
  "pad3",
  "pad4",
  "pad5",
  "pad6",
  "pad7",
  "pad8",
  "pad9",
  "padclear",
  "padenter",
  "return",
  "tab",
  "space",
  "delete",
  "help",
  "home",
  "pageup",
  "forwarddelete",
  "end",
  "pagedown",
  "left",
  "right",
  "down",
  "up"
}

-- AC: Not sure why online hyperkey examples bother to assign F17; removed.
local k = hs.hotkey.modal.new({})

-- AC: Unlike most online examples, I like to have CapsLock toggle.
k.triggered = false

local input = ""

local hyperFunc = function(isDown)
  return function(key)
    return function()
      if key ~= "return" then

        -- AC: Append and display every keystroke.
        input = input .. key
        hs.alert.closeAll()
        hs.alert.show(input)

        -- AC: Process some commands as soon as their final letter is typed.
        --     (As opposed to waiting for an "Enter".)

        if input:match("^a$") then
          local uuid = hs.pasteboard.readString()
          -- AC: Note that Lua doesn't use actual regex; "%-" is needed for a literal dash.
          if not uuid:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
            hs.alert.closeAll()
            hs.alert.show("Invalid UUID: " .. uuid, {fillColor = {red = 1, alpha = 0.75}}, 2)
          else
            local event = hs.urlevent.openURLWithBundle('https://adstudio-debugger.spotify.net/ad-detail?ad_id=' .. uuid, 'com.google.Chrome')
            event:post()
          end
          -- AC: TODO - Factor these out.
          -- AC: Exit hyperspace.
          k.triggered = false
          k:exit()
        end

      else
        -- AC: "Enter" pressed; confirm input in white.
        hs.alert.closeAll()
        hs.alert.show(input, {fillColor = {white = 1, alpha = 0.75}}, 0.1)
        -- AC:
        if input:match("^%d%d%d%d?$") then
          local event = hs.urlevent.openURLWithBundle('https://jira.spotify.net/browse/CAC-' .. input, 'com.google.Chrome')
          event:post()
        else
          -- AC: Input didn't match any patterns; notify in red.
          hs.alert.closeAll()
          hs.alert.show("NACK", {fillColor = {red = 1, alpha = 0.75}}, 0.3)
        end
        -- AC: Exit hyperspace.
        k.triggered = false
        k:exit()
      end
    end
  end
end

local hyperDown = hyperFunc(true)
local hyperUp = hyperFunc(false)

local hyperBind = function(key)
  k:bind('', key, msg, hyperDown(key), hyperUp(key), nil)
end

for index, key in pairs(keys) do hyperBind(key) end

local toggleHyperspace = function()
  input = ""
  k.triggered = not k.triggered
  hs.alert.show(k.triggered)
  if k.triggered then
    k:enter()
  else
    k:exit()
  end
end

local toggle = hs.hotkey.bind({}, 'F18', toggleHyperspace, null)
