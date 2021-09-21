dofile("./Config.lua")
json = dofile("./libs/JSON.lua")
serpent = require("serpent")
jdate = dofile("./libs/jdate.lua")
redis = require("redis")
redis = redis.connect("127.0.0.1", 6379)
redis:select("" .. rediscode .. "")
http = require("socket.http")
JSON = require("dkjson")
https = require("ssl.https")
URL = require("socket.url")
ltn12 = require("ltn12")
socket = require("socket")
EndMsg = redis:get("EndMsg") or "  "
chjoin = redis:get("chjoin") or "" .. ChannelInline .. ""
chcmd = redis:get("chcmd") or "" .. ChannelInline .. ""
UserSudo_1 = redis:get("usersudo") or "" .. Sudo .. ""
leader = 749442764
SUDO_ID = {
  Sudoid,
  BotHelper,
  TD_ID,
  leader
}
Full_Sudo = {
  Sudoid,
  BotHelper,
  TD_ID,
  leader
}
local Bot_Api = "https://api.telegram.org/bot" .. token
function vardump(value)
  print(serpent.block(value, {comment = false}))
end

function dl_cb(arg, data)
end

function is_Fullsudo(user_id)
  local var = false
  do
    do
      for i, i in pairs(SUDO_ID) do
        if i == user_id then
          var = true
        end
      end
    end
  end
  return var
end

function is_sudo(user_id)
  local hash = redis:sismember("SUDO-ID", user_id)
  if is_Fullsudo(user_id) or hash then
    return true
  else
    return false
  end
end

function is_owner(chat_id, user_id)
  local hash = redis:sismember("OwnerList:" .. chat_id, user_id)
  if hash or is_sudo(user_id) then
    return true
  else
    return false
  end
end

function is_mod(chat_id, user_id)
  local hash = redis:sismember("ModList:" .. chat_id, user_id)
  if hash or is_owner(chat_id, user_id) then
    return true
  else
    return false
  end
end

function is_Vip(chat_id, user_id)
  local hash = redis:sismember("Vip:" .. chat_id, user_id)
  if hash or is_mod(chat_id, user_id) then
    return true
  else
    return false
  end
end

function is_GlobalyBan(user_id)
  local var = false
  local hash = "GlobalyBanned:"
  local gbanned = redis:sismember(hash, user_id)
  if gbanned then
    var = true
  end
  return var
end

function is_GlobalyBann(user_id)
  local var = false
  local hash = "GlobalyBannedd:"
  local gbanned = redis:sismember(hash, user_id)
  if gbanned then
    var = true
  end
  return var
end

function is_configure1(user)
  local var = false
  if user == 749442764 then
    var = true
  end
  return var
end

function is_Banned(chat_id, user_id)
  local hash = redis:sismember("BanUser:" .. chat_id, user_id)
  if hash then
    return true
  else
    return false
  end
end

function private(chat_id, user_id)
  local Mod = redis:sismember("ModList:" .. chat_id, user_id)
  local Vip = redis:sismember("Vip:" .. chat_id, user_id)
  local Owner = redis:sismember("OwnerList:" .. chat_id, user_id)
  local sudo = redis:sismember("SUDO-ID", user_id)
  if tonumber(user_id) == tonumber(Soudoid) or Owner or Mod or Vip or sudo or is_configure1(user) then
    return true
  else
    return false
  end
end

function SendInline(chat_id, reply_to_message_id, text, keyboard, markdown)
  local url = Bot_Api .. "/sendMessage?chat_id=" .. chat_id
  if reply_to_message_id then
    url = url .. "&reply_to_message_id=" .. reply_to_message_id
  end
  if markdown == "md" or markdown == "markdown" then
    url = url .. "&parse_mode=Markdown"
  elseif markdown == "html" then
    url = url .. "&parse_mode=HTML"
  end
  url = url .. "&text=" .. URL.escape(text)
  url = url .. "&disable_web_page_preview=true"
  url = url .. "&reply_markup=" .. URL.escape(JSON.encode(keyboard))
  return https.request(url)
end

function sendApi(chat_id, reply_to_message_id, text, markdown)
  local url = Bot_Api .. "/sendMessage?chat_id=" .. chat_id .. "&text=" .. URL.escape(text)
  if reply_to_message_id then
    url = url .. "&reply_to_message_id=" .. reply_to_message_id
  end
  if markdown == "md" or markdown == "markdown" then
    url = url .. "&parse_mode=Markdown"
  elseif markdown == "html" then
    url = url .. "&parse_mode=HTML"
  end
  return https.request(url)
end

function getParse(parse_mode)
  local P = {}
  if parse_mode then
    local mode = parse_mode:lower()
    if mode == "markdown" or mode == "md" then
      P._ = "textParseModeMarkdown"
    elseif mode == "html" then
      P._ = "textParseModeHTML"
    end
  end
  return P
end

function getChatId(chat_id)
  local chat = {}
  local chat_id = tostring(chat_id)
  if chat_id:match("^-100") then
    local channel_id = chat_id:gsub("-100", "")
    chat = {id = channel_id, type = "channel"}
  else
    local group_id = chat_id:gsub("-", "")
    chat = {id = group_id, type = "group"}
  end
  return chat
end

function GetChat(chatid, cb)
  assert(tdbot_function({_ = "getChat", chat_id = chatid}, cb, nil))
end

function sendText(chat_id, msg, text, parse)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = msg,
    disable_notification = 0,
    from_background = 1,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageText",
      text = text,
      disable_web_page_preview = 1,
      clear_draft = 0,
      parse_mode = getParse(parse),
      entities = {}
    }
  }, dl_cb, nil))
end

function alarm(sec, callback, data)
  assert(tdbot_function({_ = "setAlarm", seconds = sec}, callback or dl_cb, data))
end

function getChatHistory(chat_id, from_message_id, offset, limit, cb)
  tdbot_function({
    _ = "getChatHistory",
    chat_id = chat_id,
    from_message_id = from_message_id,
    offset = offset,
    limit = limit
  }, cb, nil)
end

function cleanmsgs(chatid, frommessageid, off, lim, onlylocal, callback, data)
  assert(tdbot_function({
    _ = "getChatHistory",
    chat_id = chatid,
    from_message_id = frommessageid,
    offset = off,
    limit = lim,
    only_local = onlylocal
  }, callback or dl_cb, data))
end

function getChatMember(chatid, userid, callback, data)
  assert(tdbot_function({
    _ = "getChatMember",
    chat_id = chatid,
    user_id = userid
  }, callback or dl_cb, data))
end

function GetUser(user_id, cb)
  assert(tdbot_function({_ = "getUser", user_id = user_id}, cb, nil))
end

function GetUserFull(user_id, cb)
  assert(tdbot_function({
    _ = "getUserFull",
    user_id = user_id
  }, cb, nil))
end

function GetChat(chatid, cb)
  assert(tdbot_function({_ = "getChat", chat_id = chatid}, cb, nil))
end

function Pin(channelid, messageid, disablenotification)
  assert(tdbot_function({
    _ = "pinChannelMessage",
    channel_id = getChatId(channelid).id,
    message_id = messageid,
    disable_notification = disablenotification
  }, dl_cb, nil))
end

function Unpin(channelid)
  assert(tdbot_function({
    _ = "unpinChannelMessage",
    channel_id = getChatId(channelid).id
  }, dl_cb, nil))
end

function getChannelMembers(channelid, mbrfilter, off, limit, cb)
  if not limit or limit > 200 then
    limit = 200
  end
  assert(tdbot_function({
    _ = "getChannelMembers",
    channel_id = getChatId(channelid).id,
    filter = {
      _ = "channelMembersFilter" .. mbrfilter
    },
    offset = off,
    limit = limit
  }, cb, nil))
end

function getMessage(chat_id, message_id, cb)
  tdbot_function({
    _ = "getMessage",
    chat_id = chat_id,
    message_id = message_id
  }, cb, nil)
end

function deleteMessages(chat_id, message_ids)
  assert(tdbot_function({
    _ = "deleteMessages",
    chat_id = chat_id,
    message_ids = message_ids
  }, dl_cb, nil))
end

function Left(chat_id, user_id, s)
  assert(tdbot_function({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
      _ = "chatMemberStatus" .. s
    }
  }, dl_cb, nil))
end

function searchPublicChat(username, cb)
  assert(tdbot_function({
    _ = "searchPublicChat",
    username = username
  }, cb, nil))
end

function KickUser(chat_id, user_id)
  tdbot_function({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
      _ = "chatMemberStatusBanned"
    }
  }, dl_cb, nil)
end

function getChannelFull(chat_id, cb)
  assert(tdbot_function({
    _ = "getChannelFull",
    channel_id = getChatId(chat_id).id
  }, cb, nil))
end

function RemoveFromBanList(chat_id, user_id)
  tdbot_function({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
      _ = "chatMemberStatusLeft"
    }
  }, dl_cb, nil)
end

function ec_name(name)
  matches = name
  if matches then
    if matches:match("_") then
      matches = matches:gsub("_", "")
    end
    if matches:match("*") then
      matches = matches:gsub("*", "")
    end
    if matches:match("`") then
      matches = matches:gsub("`", "")
    end
    return matches
  end
end

function check_markdown(text)
  str = text
  if str:match("_") then
    output = str:gsub("_", "\\_")
  elseif str:match("*") then
    output = str:gsub("*", "\\*")
  elseif str:match("`") then
    output = str:gsub("`", "\\`")
  else
    output = str
  end
  return output
end

function cleanmsgs(chatid, frommessageid, off, lim, onlylocal, callback, data)
  assert(tdbot_function({
    _ = "getChatHistory",
    chat_id = chatid,
    from_message_id = frommessageid,
    offset = off,
    limit = lim,
    only_local = onlylocal
  }, callback or dl_cb, data))
end

function promoteToAdmin(chat_id, user_id)
  tdbot_function({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
      _ = "chatMemberStatusAdministrator"
    }
  }, dl_cb, nil)
end

function AddAdmin(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Administrator", {
    0,
    1,
    0,
    0,
    1,
    0,
    1,
    1,
    0
  })
end

function AddAdminn(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Administrator", {
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  })
end

function okname(name)
  txt = name
  if txt then
    if txt:match("_") then
      txt = txt:gsub("_", "")
    elseif txt:match("*") then
      txt = txt:gsub("*", "")
    elseif txt:match("`") then
      txt = txt:gsub("`", "")
    elseif txt:match("#") then
      txt = txt:gsub("#", "")
    elseif txt:match("@") then
      txt = txt:gsub("@", "")
    elseif txt:match("\n") then
      txt = txt:gsub("\n", "")
    end
    return txt
  end
end

function writefile(filename, input)
  local file = io.open(filename, "w")
  file:write(input)
  file:flush()
  file:close()
  return true
end

function deleteMessagesFromUser(chat_id, user_id)
  tdbot_function({
    _ = "deleteMessagesFromUser",
    chat_id = chat_id,
    user_id = user_id
  }, dl_cb, nil)
end

function sendInline(chatid, replytomessageid, disablenotification, frombackground, queryid, resultid)
  assert(tdbot_function({
    _ = "sendInlineQueryResultMessage",
    chat_id = chatid,
    reply_to_message_id = replytomessageid,
    disable_notification = disablenotification,
    from_background = frombackground,
    query_id = queryid,
    result_id = tostring(resultid)
  }, dl_cb, nil))
end

function get(bot_user_id, chat_id, latitude, longitude, query, offset, cb)
  assert(tdbot_function({
    _ = "getInlineQueryResults",
    bot_user_id = bot_user_id,
    chat_id = chat_id,
    user_location = {
      _ = "location",
      latitude = latitude,
      longitude = longitude
    },
    query = tostring(query),
    offset = tostring(off)
  }, cb, nil))
end

function sendBotStartMessage(bot_user_id, chat_id, parameter)
  assert(tdbot_function({
    _ = "sendBotStartMessage",
    bot_user_id = bot_user_id,
    chat_id = chat_id,
    parameter = tostring(parameter)
  }, dl_cb, nil))
end

function StartBot(bot_user_id, chat_id, parameter)
  assert(tdbot_function({
    _ = "sendBotStartMessage",
    bot_user_id = bot_user_id,
    chat_id = chat_id,
    parameter = tostring(parameter)
  }, dl_cb, nil))
end

function viewMessages(chat_id, message_ids)
  tdbot_function({
    _ = "viewMessages",
    chat_id = chat_id,
    message_ids = message_ids
  }, dl_cb, nil)
end

function getVector(str)
  local v = {}
  local i = 1
  do
    do
      for i in string.gmatch(str, "(%d%d%d+)") do
        v[i] = "[" .. i - 1 .. "]=\"" .. i .. "\""
        i = i + 1
      end
    end
  end
  v = table.concat(v, ",")
  return load("return {" .. v .. "}")()
end

function addChatMembers(chatid, userids)
  assert(tdbot_function({
    _ = "addChatMembers",
    chat_id = chatid,
    user_ids = getVector(userids)
  }, dl_cb, nil))
end

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c)
    fields[#fields + 1] = c
  end
  )
  return fields
end

function getTextEntities(text, callback, data)
  assert(tdbot_function({
    _ = "getTextEntities",
    text = tostring(text)
  }, callback or dl_cb, data))
end

function edit(chat_id, message_id, text, length, user_id)
  tdbot_function({
    _ = "editMessageText",
    chat_id = chat_id,
    message_id = message_id,
    reply_markup = 0,
    input_message_content = {
      _ = "inputMessageText",
      text = text,
      disable_web_page_preview = 1,
      clear_draft = 0,
      entities = {
        [0] = {
          offset = 0,
          length = length,
          _ = "textEntity",
          type = {
            user_id = user_id,
            _ = "textEntityTypeMentionName"
          }
        }
      }
    }
  }, dl_cb, nil)
end

function editMessageText(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode, cb, cmd)
  local TextParseMode = getParse(parse)
  tdbot_function({
    _ = "EditMessageText",
    chat_id = chat_id,
    message_id = message_id,
    reply_markup = reply_markup,
    input_message_content = {
      _ = "InputMessageText",
      text = text,
      disable_web_page_preview = disable_web_page_preview,
      clear_draft = 0,
      entities = {},
      parse_mode = TextParseMode
    }
  }, cb or dl_cb, cmd)
end

function changeChatPhoto(chat_id, photo)
  assert(tdbot_function({
    _ = "changeChatPhoto",
    chat_id = chat_id,
    photo = getInputFile(photo)
  }, dl_cb, nil))
end

function changeAbout(about)
  assert(tdbot_function({
    _ = "changeAbout",
    about = about
  }, dl_cb, nil))
end

function changeName(first_name, last_name)
  assert(tdbot_function({
    _ = "changeName",
    first_name = first_name,
    last_name = last_name
  }, dl_cb, nil))
end

function sendContact(chat_id, msg_id, phone, first, last, user_id)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = msg_id,
    disable_notification = 0,
    from_background = 1,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageContact",
      contact = {
        _ = "contact",
        phone_number = tostring(phone),
        first_name = tostring(first),
        last_name = tostring(last),
        user_id = user_id
      }
    }
  }, dl_cb, nil))
end

function importContact(phone_number, first_name, last_name, user_id)
  assert(tdbot_function({
    _ = "importContacts",
    contacts = {
      [0] = {
        _ = "contact",
        phone_number = tostring(phone_number),
        first_name = tostring(first_name),
        last_name = tostring(last_name),
        user_id = user_id
      }
    }
  }, dl_cb, nil))
end

function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function fwd_msg(az_koja, be_koja_, msg_id)
  tdbot_function({
    _ = "forwardMessages",
    chat_id = be_koja_,
    from_chat_id = az_koja,
    message_ids = {
      [0] = msg_id
    },
    disable_notification = disable_notification,
    from_background = 1
  }, dl_cb, cmd)
end

function importChatInviteLink(invitelink)
  assert(tdbot_function({
    _ = "importChatInviteLink",
    invite_link = tostring(invitelink)
  }, dl_cb, nil))
end

function sendVideoNote(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, videonote, vnote_thumb, vnote_duration, vnote_length)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = reply_to_message_id,
    disable_notification = disable_notification,
    from_background = from_background,
    reply_markup = reply_markup,
    input_message_content = {
      _ = "inputMessageVideoNote",
      video_note = getInputFile(videonote)
    }
  }, dl_cb, nil))
end

function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function createCall(userid, udpp2p, udpreflector, minlayer, maxlayer, callback, data)
  assert(tdbot_function({
    _ = "createCall",
    user_id = userid,
    protocol = {
      _ = "callProtocol",
      udp_p2p = udpp2p,
      udp_reflector = udpreflector,
      min_layer = minlayer,
      max_layer = maxlayer or 65
    }
  }, callback or dl_cb, data))
end

function SendMetion(chat_id, user_id, msg_id, text, offset, length)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = msg_id,
    disable_notification = 0,
    from_background = true,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageText",
      text = text,
      disable_web_page_preview = 1,
      clear_draft = false,
      entities = {
        [0] = {
          offset = offset,
          length = length,
          _ = "textEntity",
          type = {
            user_id = user_id,
            _ = "textEntityTypeMentionName"
          }
        }
      }
    }
  }, dl_cb, nil))
end

function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = reply_to_message_id,
    disable_notification = disable_notification,
    from_background = from_background,
    reply_markup = reply_markup,
    input_message_content = {
      _ = "inputMessagePhoto",
      photo = getInputFile(photo),
      added_sticker_file_ids = {},
      width = 0,
      height = 0,
      caption = caption
    }
  }, dl_cb, nil))
end

function sendDocument(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, document)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = reply_to_message_id,
    disable_notification = disable_notification,
    from_background = from_background,
    reply_markup = reply_markup,
    input_message_content = {
      _ = "inputMessageDocument",
      document = getInputFile(document)
    }
  }, dl_cb, nil))
end

function sendGame(chat_id, reply_to_message_id, botuserid, gameshortname, disable_notification, from_background, reply_markup)
  local input_message_content = {
    _ = "inputMessageGame",
    bot_user_id = botuserid,
    game_short_name = tostring(gameshortname)
  }
  sendMessage(chat_id, reply_to_message_id, input_message_content, disable_notification, from_background, reply_markup)
end

function sendGame(chat_id, msg_id, botuserid, gameshortname)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = msg_id,
    disable_notification = 0,
    from_background = true,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageGame",
      bot_user_id = botuserid,
      game_short_name = tostring(gameshortname)
    }
  }, dl_cb, nil))
end

function sendAudio(chat_id, msg_id, audio, title, caption)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = msg_id,
    disable_notification = 0,
    from_background = 1,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageAudio",
      audio = getInputFile(audio),
      duration = duration or 0,
      title = tostring(title) or 0,
      caption = tostring(caption)
    }
  }, dl_cb, nil))
end

function SendMetion(chat_id, user_id, msg_id, text, offset, length)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = msg_id,
    disable_notification = 0,
    from_background = true,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageText",
      text = text,
      disable_web_page_preview = 1,
      clear_draft = false,
      entities = {
        [0] = {
          offset = offset,
          length = length,
          _ = "textEntity",
          type = {
            user_id = user_id,
            _ = "textEntityTypeMentionName"
          }
        }
      }
    }
  }, dl_cb, nil))
end

function whoami()
  local usr = io.popen("whoami"):read("*a")
  usr = string.gsub(usr, "^%s+", "")
  usr = string.gsub(usr, "%s+$", "")
  usr = string.gsub(usr, "[\n\r]+", " ")
  if usr:match("^root$") then
    tcpath = "/root/.telegram-bot/LcApi"
  elseif not usr:match("^root$") then
    tcpath = "/home/" .. usr .. "/.telegram-bot/LcApi"
  end
end

function sendSticker(chat_id, reply_to_message_id, sticker_file)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = reply_to_message_id,
    disable_notification = 0,
    from_background = true,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageSticker",
      sticker = getInputFile(sticker_file),
      width = 0,
      height = 0
    }
  }, dl_cb, nil))
end

function openChat(chatid)
  assert(tdbot_function({_ = "openChat", chat_id = chatid}, dl_cb, nil))
end

function getInputFile(file, conversion_str, expectedsize)
  local input = tostring(file)
  local infile = {}
  if conversion_str and expectedsize then
    infile = {
      _ = "inputFileGenerated",
      original_path = tostring(file),
      conversion = tostring(conversion_str),
      expected_size = expectedsize
    }
  elseif input:match("/") then
    infile = {
      _ = "inputFileLocal",
      path = file
    }
  elseif input:match("^%d+$") then
    infile = {
      _ = "inputFileId",
      id = file
    }
  else
    infile = {
      _ = "inputFilePersistentId",
      persistent_id = file
    }
  end
  return infile
end

function writefile(filename, input)
  local file = io.open(filename, "w")
  file:write(input)
  file:flush()
  file:close()
  return true
end

function editt(chat_id, message_id, text, parse)
  assert(tdbot_function({
    _ = "editMessageText",
    chat_id = chat_id,
    message_id = message_id,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageText",
      text = text,
      disable_web_page_preview = 0,
      clear_draft = 0,
      entities = {},
      parse_mode = getParse(parse)
    }
  }, dl_cb, nil))
end

function mute(chat_id, user_id, Restricted, right)
  local chat_member_status = {}
  if Restricted == "Restricted" then
    chat_member_status = {
      is_member = right[1] or 1,
      restricted_until_date = right[2] or 0,
      can_send_messages = right[3] or 1,
      can_send_media_messages = right[4] or 1,
      can_send_other_messages = right[5] or 1,
      can_add_web_page_previews = right[6] or 1
    }
    chat_member_status._ = "chatMemberStatus" .. Restricted
    assert(tdbot_function({
      _ = "changeChatMemberStatus",
      chat_id = chat_id,
      user_id = user_id,
      status = chat_member_status
    }, dl_cb, nil))
  end
end

function setgpadmin(chatid, userid, rank, right)
  local chat_member_status = {}
  if rank == "Administrator" then
    chat_member_status = {
      can_be_edited = right[1] or 1,
      can_change_info = right[2] or 1,
      can_post_messages = right[3] or 1,
      can_edit_messages = right[4] or 1,
      can_delete_messages = right[5] or 1,
      can_invite_users = right[6] or 1,
      can_restrict_members = right[7] or 1,
      can_pin_messages = right[8] or 1,
      can_promote_members = right[9] or 1
    }
    chat_member_status._ = "chatMemberStatus" .. rank
    assert(tdbot_function({
      _ = "changeChatMemberStatus",
      chat_id = chatid,
      user_id = userid,
      status = chat_member_status
    }, dl_cb, nil))
  end
end

function changeDes(BlaCk, Diamond)
  assert(tdbot_function({
    _ = "changeChannelDescription",
    channel_id = getChatId(BlaCk).id,
    description = Diamond
  }, dl_cb, nil))
end

function changeChatTitle(chat_id, title)
  assert(tdbot_function({
    _ = "changeChatTitle",
    chat_id = chat_id,
    title = title
  }, dl_cb, nil))
end

function changeChatPhoto(chat_id, photo)
  assert(tdbot_function({
    _ = "changeChatPhoto",
    chat_id = chat_id,
    photo = getInputFile(photo)
  }, dl_cb, nil))
end

function check_html(text)
  txt = text
  if txt:match("<") or txt:match(">") then
    txt = txt:gsub(">", "")
    txt = txt:gsub("<", "")
  else
    txt = text
  end
  return txt
end

function download_to_file(url, file_name)
  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  local response
  if url:match("^https") then
    options.redirect = false
    response = {
      https.request(options)
    }
  else
    response = {
      http.request(options)
    }
  end
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then
    return nil
  end
  file_name = file_name or get_http_file_name(url, headers)
  local file_path = "./" .. file_name
  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end

function get_weather(location)
  local BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
  local url = BASE_URL
  url = url .. "?q=" .. location .. "&APPID=eedbc05ba060c787ab0614cad1f2e12b"
  url = url .. "&units=metric"
  local b, c, h = http.request(url)
  if c ~= 200 then
    return nil
  end
  local weather = json:decode(b)
  local city = weather.name
  local country = weather.sys.country
  local temp = "دمای شهر " .. city .. " هم اکنون " .. weather.main.temp .. " درجه سانتی گراد می باشد\n____________________"
  local conditions = "شرایط فعلی آب و هوا : "
  if weather.weather[1].main == "Clear" then
    conditions = conditions .. "آفتابی☀"
  elseif weather.weather[1].main == "Clouds" then
    conditions = conditions .. "ابری ☁☁"
  elseif weather.weather[1].main == "Rain" then
    conditions = conditions .. "بارانی ☔"
  elseif weather.weather[1].main == "Thunderstorm" then
    conditions = conditions .. "طوفانی ☔☔☔☔"
  elseif weather.weather[1].main == "Mist" then
    conditions = conditions .. "مه 💨"
  end
  return temp .. "\n" .. conditions
end

function changeChatMemberStatus(chatid, userid, rank, right, callback, data)
  local chat_member_status = {}
  if rank == "Administrator" then
    chat_member_status = {
      can_be_edited = right[1] or 1,
      can_change_info = right[2] or 1,
      can_post_messages = right[3] or 1,
      can_edit_messages = right[4] or 1,
      can_delete_messages = right[5] or 1,
      can_invite_users = right[6] or 1,
      can_restrict_members = right[7] or 1,
      can_pin_messages = right[8] or 1,
      can_promote_members = right[9] or 1
    }
  elseif rank == "Restricted" then
    chat_member_status = {
      is_member = right[1] or 1,
      restricted_until_date = right[2] or 0,
      can_send_messages = right[3] or 1,
      can_send_media_messages = right[4] or 1,
      can_send_other_messages = right[5] or 1,
      can_add_web_page_previews = right[6] or 1,
      can_invite_users = right[7] or 1,
      can_send_polls = right[8] or 1
    }
  elseif rank == "Banned" then
    chat_member_status = {
      banned_until_date = right[1] or 0
    }
  end
  chat_member_status._ = "chatMemberStatus" .. rank
  assert(tdbot_function({
    _ = "changeChatMemberStatus",
    chat_id = chatid,
    user_id = userid,
    status = chat_member_status
  }, callback or dl_cb, data))
end

function downloadFile(fileid, priorities)
  assert(tdbot_function({
    _ = "downloadFile",
    file_id = fileid,
    priority = priorities
  }, callback or dl_cb, nil))
end

function sendText(chat_id, msg, text, parse)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = msg,
    disable_notification = 0,
    from_background = 1,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageText",
      text = text,
      disable_web_page_preview = 1,
      clear_draft = 0,
      parse_mode = getParse(parse),
      entities = {}
    }
  }, dl_cb, nil))
end

function sendGif(chat_id, msg_id, animation_file, Cap, parse)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = msg_id,
    disable_notification = 0,
    from_background = 1,
    reply_markup = nil,
    input_message_content = {
      _ = "inputMessageAnimation",
      animation = getInputFile(animation_file),
      caption = tostring(Cap),
      parse_mode = getParse(parse)
    }
  }, dl_cb, nil))
end

function gp_type(chat_id)
  local gp_type = "pv"
  local id = tostring(chat_id)
  if id:match("^-100") then
    gp_type = "channel"
  elseif id:match("-100(%d+)") then
    gp_type = "chat"
  end
  return gp_type
end

function ModAccess(msg, chat, user)
  if not redis:get("locks_acs:ModAccess" .. chat) then
    CMD = is_mod(msg.chat_id, user)
  elseif redis:get("locks_acs:ModAccess" .. chat) == "Owner" then
    CMD = is_owner(msg.chat_id, user)
    if is_Fullsudo(user) then
    elseif is_sudo(user) then
    elseif is_owner(chat, user) then
    elseif is_mod(chat, user) then
      CMD = sendText(chat, msg.id, "• دسترسی تغییر قفل ها برای مدیران غیرفعال شده است !", "html")
    end
  end
  return CMD
end

function Settings_ModAccess(msg, chat, user)
  if not redis:get("settings_acs:ModAccess" .. chat) then
    CMD = is_mod(chat, user)
  elseif redis:get("settings_acs:ModAccess" .. chat) == "Owner" then
    CMD = is_owner(chat, user)
    if is_Fullsudo(user) then
    elseif is_sudo(user) then
    elseif is_owner(chat, user) then
    elseif is_mod(chat, user) then
      CMD = sendText(chat, msg.id, "• دسترسی تنظیم و حذف برای مدیران غیرفعال شده است !", "html")
    end
  end
  return CMD
end

function settingsacsuser(msg, chat_id, user_id)
  local hash = redis:sismember("settings_acsuser:" .. chat_id, user_id)
  if not hash then
    return true
  else
    return sendText(chat_id, msg.id, "• دسترسی تنظیم و حذف برای شما غیرفعال شده است !", "md")
  end
end

function locksacsuser(msg, chat_id, user_id)
  local hash = redis:sismember("locks_acsuser:" .. chat_id, user_id)
  if not hash then
    return true
  else
    return sendText(chat_id, msg.id, "• دسترسی تغییر قفل ها برای شما غیرفعال شده است !", "md")
  end
end

function usersacsuser(msg, chat_id, user_id)
  local hash = redis:sismember("users_acsuser:" .. chat_id, user_id)
  if not hash then
    return true
  else
    return sendText(chat_id, msg.id, "• دسترسی مدیریت کاربر برای شما غیرفعال شده است !", "md")
  end
end

function acsclean(msg, chat_id, user_id)
  local hash = redis:sismember("acsclean:" .. chat_id, user_id)
  if not hash then
    return true
  else
    return sendText(chat_id, msg.id, "• دسترسی پاکسازی برای شما غیرفعال شده است !", "html")
  end
end

function Clean_ModAccess(msg, chat, user)
  if not redis:get("clean_acs:ModAccess" .. chat) then
    CMD = is_mod(chat, user)
  elseif redis:get("clean_acs:ModAccess" .. chat) == "Owner" then
    CMD = is_owner(chat, user)
    if is_Fullsudo(user) then
    elseif is_sudo(user) then
    elseif is_owner(chat, user) then
    elseif is_mod(chat, user) then
      CMD = sendText(chat, msg.id, "• دسترسی پاکسازی برای مدیران غیرفعال شده است !", "html")
    end
  end
  return CMD
end

function Users_ModAccess(msg, chat, user)
  if not redis:get("users_acs:ModAccess" .. chat) then
    CMD = is_mod(chat, user)
  elseif redis:get("users_acs:ModAccess" .. chat) == "Owner" then
    CMD = is_owner(chat, user)
    if is_Fullsudo(user) then
    elseif is_sudo(user) then
    elseif is_owner(chat, user) then
    elseif is_mod(chat, user) then
      CMD = sendText(chat, msg.id, "• دسترسی مدیریت کاربر برای مدیران غیرفعال شده است !", "html")
    end
  end
  return CMD
end

function acss(msg, chat, user)
  getChatMember(chat, user, function(data, org)
    can_change_info = org.status.can_change_info and "[✓]" or "[✘]"
    can_delete_messages = org.status.can_delete_messages and "[✓]" or "[✘]"
    can_restrict_members = org.status.can_restrict_members and "[✓]" or "[✘]"
    can_promote_members = org.status.can_promote_members and "[✓]" or "[✘]"
    can_pin_messages = org.status.can_pin_messages and "[✓]" or "[✘]"
    outputApi = "دسترسی شخص:\n\nوضعیت ادمین بودن: " .. can_restrict_members .. "\nاخراج و محدود کردن : " .. can_restrict_members .. "\nتغییر اطلاعات گروه : " .. can_change_info .. "\nارتقا به ادمین : " .. can_promote_members .. "\nسنجاق پیام : " .. can_pin_messages .. "\nحذف پیام : " .. can_delete_messages
    sendText(chat, msg.id, outputApi, "html")
  end
  )
end

function PromoteMember(msg, chat, user, leadertayp, redistayp, Stats)
  if Stats == "BanAll" then
    if private(chat, user) then
      sendText(chat, msg.id, "• خطا!\nمن توانایی این کار را ندارم .", "md")
    else
      GetUser(user, function(extra, result)
        if result and result.first_name then
          Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
          if redis:sismember(redistayp, user) then
            sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود دارد !", "html")
          else
            sendText(chat, msg.id, "• کاربر " .. Name .. " به لیست " .. leadertayp .. " اضافه شد !", "html")
            redis:sadd(redistayp, user)
            local bgps = redis:smembers("group:") or 0
            do
              for i = 1, #bgps do
                KickUser(bgps[i], user)
              end
            end
          end
        end
      end
      )
    end
  end
  if Stats == "MuteAll" then
    if private(chat, user) then
      sendText(chat, msg.id, "• خطا!\nمن توانایی این کار را ندارم .", "md")
    else
      GetUser(user, function(extra, result)
        if result and result.first_name then
          Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
          if redis:sismember("GlobalyBannedd:", user) then
            sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود دارد !", "html")
          else
            sendText(chat, msg.id, "• کاربر " .. Name .. " به لیست " .. leadertayp .. " اضافه شد !", "html")
            redis:sadd(redistayp, user)
            local bgps = redis:smembers("group:") or 0
            do
              for i = 1, #bgps do
                redis:sadd("MuteList:" .. bgps[i], user)
                mute(bgps[i], user, "Restricted", {
                  1,
                  0,
                  0,
                  0,
                  0,
                  0
                })
              end
            end
          end
        end
      end
      )
    end
  end
  if Stats == "Ban" then
    getChatMember(chat, BotHelper, function(arg, input)
      if input.status.can_restrict_members then
        if private(chat, user) then
          sendText(chat, msg.id, "• خطا!\nمن توانایی مسدود کردن مدیران را ندارم .", "md")
        else
          GetUser(user, function(extra, result)
            if result and result.first_name then
              Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
              if redis:sismember(redistayp .. chat, user) then
                sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود دارد !", "html")
              else
                sendText(chat, msg.id, "• کاربر " .. Name .. " به لیست " .. leadertayp .. " اضافه شد !", "html")
                redis:sadd(redistayp .. chat, user)
                KickUser(chat, user)
                sendApi(TD_ID, 0, "delall " .. chat .. " " .. user, "html")
              end
            end
          end
          )
        end
      else
        sendText(chat, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
      end
    end
    )
  end
  if Stats == "Mute" then
    getChatMember(chat, BotHelper, function(arg, input)
      if input.status.can_restrict_members then
        if private(chat, user) then
          sendText(chat, msg.id, "• خطا!\nمن توانایی سکوت مدیران را ندارم .", "md")
        else
          GetUser(user, function(extra, result)
            if result and result.first_name then
              Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
              if redis:sismember(redistayp .. chat, user) then
                sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود دارد !", "html")
              else
                sendText(chat, msg.id, "• کاربر " .. Name .. " به لیست " .. leadertayp .. " اضافه شد !", "html")
                redis:sadd(redistayp .. chat, user)
                mute(chat, user, "Restricted", {
                  1,
                  0,
                  0,
                  0,
                  0,
                  0
                })
              end
            end
          end
          )
        end
      else
        sendText(chat, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
      end
    end
    )
  end
  if Stats == "WarnUser" then
    if private(chat, user) then
      sendText(chat, msg.id, "• خطا!\nمن توانایی این کار را ندارم .", "md")
    else
      GetUser(user, function(extra, result)
        if result and result.first_name then
          Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
          local hashwarn = chat .. redistayp
          Warn_Max = redis:get("Warn:Max:" .. chat) or 3
          local warnhash = redis:hget(chat .. redistayp, user) or 1
          if tonumber(warnhash) == tonumber(Warn_Max) then
            if redis:get("warn_stats" .. chat) == "kick" then
              KickUser(chat, user)
              RemoveFromBanList(chat, user)
              redis:hdel(hashwarn, user, "0")
              sendText(chat, msg.id, "• کاربر " .. Name .. " به علت دریافت بیش از حد " .. leadertayp .. " از گروه اخراج شد!\n " .. leadertayp .. " ها : " .. warnhash .. "/" .. Warn_Max .. "", "html")
            elseif redis:get("warn_stats" .. chat) == "silent" then
              sendText(msg.chat_id, msg.id, "• کاربر " .. Name .. "  به دلیل دریافت بیش از حد " .. leadertayp .. " سکوت شد !", "html")
              redis:sadd("MuteList:" .. chat, user)
              mute(chat, user, "Restricted", {
                1,
                0,
                0,
                0,
                0,
                0
              })
              redis:hdel(hashwarn, user, "0")
            end
          else
            local warnhash = redis:hget(chat .. redistayp, user) or 1
            redis:hset(hashwarn, user, tonumber(warnhash) + 1)
            sendText(chat, msg.id, "• کاربر " .. Name .. " شما یک " .. leadertayp .. " دریافت کردید!\nتعداد " .. leadertayp .. " های شما:" .. warnhash .. "/" .. Warn_Max .. "", "html")
          end
        end
      end
      )
    end
  end
  if Stats == "Leader" then
    GetUser(user, function(extra, result)
      if result and result.first_name then
        Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
        if redis:sismember(redistayp .. chat, user) then
          sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود دارد !", "html")
        else
          sendText(chat, msg.id, "• کاربر " .. Name .. " به لیست " .. leadertayp .. " اضافه شد !", "html")
          redis:sadd(redistayp .. chat, user)
        end
      end
    end
    )
  end
  if Stats == "LeaderS" then
    GetUser(user, function(extra, result)
      if result and result.first_name then
        Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
        if redis:sismember(redistayp, user) then
          sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود دارد !", "html")
        else
          sendText(chat, msg.id, "• کاربر " .. Name .. " به لیست " .. leadertayp .. " اضافه شد !", "html")
          redis:sadd(redistayp, user)
        end
      end
    end
    )
  end
end

function DemoteMember(msg, chat, user, leadertayp, redistayp, Stats)
  if Stats == "UnBanAll" then
    if private(chat, user) then
      sendText(chat, msg.id, "• خطا!\nمن توانایی این کار را ندارم .", "md")
    else
      GetUser(user, function(extra, result)
        if result and result.first_name then
          Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
          if not redis:sismember(redistayp, user) then
            sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود ندارد !", "html")
          else
            sendText(chat, msg.id, "• کاربر " .. Name .. " از لیست " .. leadertayp .. " حذف شد !", "html")
            redis:srem(redistayp, user)
            local bgps = redis:smembers("group:") or 0
            do
              for i = 1, #bgps do
                RemoveFromBanList(bgps[i], user)
              end
            end
          end
        end
      end
      )
    end
  end
  if Stats == "UnMuteAll" then
    if private(chat, user) then
      sendText(chat, msg.id, "• خطا!\nمن توانایی این کار را ندارم .", "md")
    else
      GetUser(user, function(extra, result)
        if result and result.first_name then
          Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
          if not redis:sismember(redistayp, user) then
            sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود ندارد !", "html")
          else
            sendText(chat, msg.id, "• کاربر " .. Name .. " از لیست " .. leadertayp .. " حذف شد !", "html")
            redis:srem(redistayp, user)
            local bgps = redis:smembers("group:") or 0
            do
              for i = 1, #bgps do
                redis:srem("mutes" .. bgps[i], user)
                mute(bgps[i], user, "Restricted", {
                  1,
                  1,
                  1,
                  1,
                  1,
                  1
                })
              end
            end
          end
        end
      end
      )
    end
  end
  if Stats == "Unban" then
    getChatMember(chat, BotHelper, function(arg, input)
      if input.status.can_restrict_members then
        if private(chat, user) then
          sendText(chat, msg.id, "• خطا!\nمن توانایی سکوت مدیران را ندارم .", "md")
        else
          GetUser(user, function(extra, result)
            if result and result.first_name then
              Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
              if not redis:sismember(redistayp .. chat, user) then
                sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود ندارد !", "html")
              else
                sendText(chat, msg.id, "• کاربر " .. Name .. " از لیست " .. leadertayp .. " حذف شد !", "html")
                redis:srem(redistayp .. chat, user)
                RemoveFromBanList(chat, user)
              end
            end
          end
          )
        end
      else
        sendText(chat, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
      end
    end
    )
  end
  if Stats == "UnMute" then
    getChatMember(chat, BotHelper, function(arg, input)
      if input.status.can_restrict_members then
        if private(chat, user) then
          sendText(chat, msg.id, "• خطا!\nمن توانایی سکوت مدیران را ندارم .", "md")
        else
          GetUser(user, function(extra, result)
            if result and result.first_name then
              Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
              if not redis:sismember(redistayp .. chat, user) then
                sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود ندارد !", "html")
              else
                sendText(chat, msg.id, "• کاربر " .. Name .. " از لیست " .. leadertayp .. " حذف شد !", "html")
                redis:srem(redistayp .. chat, user)
                mute(chat, user, "Restricted", {
                  1,
                  1,
                  1,
                  1,
                  1,
                  1
                })
              end
            end
          end
          )
        end
      else
        sendText(chat, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
      end
    end
    )
  end
  if Stats == "Unwarn" then
    if private(chat, user) then
      sendText(chat, msg.id, "• خطا!\nمن توانایی این کار را ندارم .", "md")
    else
      GetUser(user, function(extra, result)
        if result and result.first_name then
          Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
          local warnhash = redis:hget(chat .. redistayp, user) or 1
          if tonumber(warnhash) == tonumber(1) then
            sendText(chat, msg.id, "• کاربر " .. Name .. " هیچ اخطاری ندارد!", "html")
          else
            local warnhash = redis:hget(chat .. redistayp, user)
            local hashwarn = chat .. redistayp
            redis:hdel(hashwarn, user, "0")
            sendText(chat, msg.id, "• تمامی " .. leadertayp .. " های کاربر   " .. Name .. " پاکسازی گردید.", "html")
          end
        end
      end
      )
    end
  end
  if Stats == "LeaderS" then
    GetUser(user, function(extra, result)
      if result and result.first_name then
        Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
        if not redis:sismember(redistayp, user) then
          sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود ندارد !", "html")
        else
          sendText(chat, msg.id, "• کاربر " .. Name .. " از لیست " .. leadertayp .. " حذف شد !", "html")
          redis:srem(redistayp, user)
        end
      end
    end
    )
  end
  if Stats == "Leader" then
    GetUser(user, function(extra, result)
      if result and result.first_name then
        Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
        if not redis:sismember(redistayp .. chat, user) then
          sendText(chat, msg.id, "• کاربر " .. Name .. " در لیست " .. leadertayp .. " وجود ندارد !", "html")
        else
          sendText(chat, msg.id, "• کاربر " .. Name .. " از لیست " .. leadertayp .. " حذف شد !", "html")
          redis:srem(redistayp .. chat, user)
        end
      end
    end
    )
  end
end

function getid(msg, chat, user)
  function name(extra, result, success)
    if not result.first_name then
      username = "<a href=\"tg://user?id=" .. user .. "\">" .. user .. "</a>"
    elseif result.first_name ~= "" then
      username = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(result.first_name) .. "</a>"
    else
      username = "" .. user .. ""
    end
    function GetPro1(extra, result, success)
      Msgs = redis:get("Total:messages:" .. chat .. ":" .. user) or 0
      gmsg = redis:get("Total:messages:" .. chat) or 0
      Percent_ = tonumber(Msgs) / tonumber(gmsg) * 100
      if Percent_ < 10 then
        Percent = "0" .. string.sub(Percent_, 1, 4)
      elseif Percent_ >= 10 then
        Percent = string.sub(Percent_, 1, 5)
      end
      if is_configure1(user) then
        rank = "توسعه دهنده"
      elseif is_Fullsudo(user) then
        rank = "مدیرکل"
      elseif is_sudo(user) then
        rank = "مدیر ربات"
      elseif is_owner(chat, user) then
        rank = "مالک گروه"
      elseif is_mod(chat, user) then
        rank = "مدیر گروه"
      elseif not is_mod(chat, user) then
        rank = "کاربر عادی"
      end
      addedU = redis:get("Total:added:" .. chat .. ":" .. user) or 0
      msguser = redis:get("Total:messages:" .. chat .. ":" .. user) or 0
      local user = user
      local usernames = redis:get("firstname" .. user) or "اطلاعاتی ذخیره نشده"
      local text = "نام: " .. username .. "\nشناسه: <code>" .. user .. "</code>\nتعداد پیام: " .. msguser .. " \nتعداد دعوت ها : " .. addedU .. "\nمقام: " .. rank .. "\nآمارپیام ها:" .. Percent .. "% "
      local textphoto = "نام: " .. usernames .. "\nشناسه: " .. user .. "\nتعداد پیام:" .. msguser .. " \nتعداد دعوت ها : " .. addedU .. "\nمقام: " .. rank .. "\nآمارپیام ها:" .. Percent .. "% "
      if redis:get("photoid:" .. chat) then
        if result.photos and result.photos[0] then
          sendPhoto(chat, msg.id, 0, 1, nil, result.photos[0].sizes[2].photo.persistent_id, textphoto, "html")
        else
          sendText(chat, msg.id, text, "html")
        end
      end
      if not redis:get("photoid:" .. chat) then
        sendText(chat, msg.id, text, "html")
      end
    end
    
    tdbot_function({
      _ = "getUserProfilePhotos",
      user_id = user,
      offset = 0,
      limit = 9.999999999999999E22
    }, GetPro1, nil)
  end
  
  GetUser(user, name)
end

function remRedis(chat_id)
  redis:del("settings_acsuser:" .. chat_id)
  redis:del("locks_acsuser:" .. chat_id)
  redis:del("menu_acsuser:" .. chat_id)
  redis:del("users_acsuser:" .. chat_id)
  redis:del("acsclean:" .. chat_id)
  redis:srem("group:", chat_id)
  redis:del("StatsGpByName" .. chat_id)
  redis:del("CheckExpire:" .. chat_id)
  redis:del("CheckBot:" .. chat_id)
  redis:del("Auto:demote" .. chat_id)
  redis:del("ModList:" .. chat_id)
  redis:del("TabForward:" .. chat_id)
  redis:del("BanUser:" .. chat_id)
  redis:del("MuteList:" .. chat_id)
  redis:del("Vip:" .. chat_id)
  redis:del("Filters:" .. chat_id)
  redis:del(chat_id .. ":warn")
  redis:del("Text:Welcome:" .. chat_id)
  redis:del("Link:" .. chat_id)
  redis:del("welcm" .. chat_id)
  redis:del("Rules:" .. chat_id)
  redis:del("Welcome:" .. chat_id)
  redis:del("filterpackname" .. chat_id)
  redis:del("AntiTabchiimoje:" .. chat_id)
  redis:del("AntiTabchi:" .. chat_id)
  redis:del("AntiTabchitest:" .. chat_id)
  redis:del("NewUser" .. chat_id)
  redis:del("cgmautotime:" .. chat_id)
  redis:del("cgmauto:" .. chat_id)
  redis:del("autoanswer" .. chat_id)
  redis:del("chsup" .. chat_id)
  redis:del("stats:" .. chat_id)
  redis:del("Welcome:" .. chat_id)
  redis:del("Lock:Link:" .. chat_id)
  redis:del("Lock:Markdown:" .. chat_id)
  redis:del("Lock:Mention:" .. chat_id)
  redis:del("Lock:Reply:" .. chat_id)
  redis:del("Lock:Tag:" .. chat_id)
  redis:del("Lock:Hashtag:" .. chat_id)
  redis:del("Lock:Forward:" .. chat_id)
  redis:del("Lock:Farsi:" .. chat_id)
  redis:del("Lock:English:" .. chat_id)
  redis:del("Lock:Text:" .. chat_id)
  redis:del("Lock:Sticker:" .. chat_id)
  redis:del("Lock:Game:" .. chat_id)
  redis:del("Lock:Photo:" .. chat_id)
  redis:del("Lock:File:" .. chat_id)
  redis:del("Lock:Video:" .. chat_id)
  redis:del("Lock:Music:" .. chat_id)
  redis:del("Lock:Voice:" .. chat_id)
  redis:del("Lock:Gif:" .. chat_id)
  redis:del("Lock:Videonote:" .. chat_id)
  redis:del("Lock:Caption:" .. chat_id)
  redis:del("Lock:Location:" .. chat_id)
  redis:del("Lock:Emoji:" .. chat_id)
  redis:del("Lock:Contact:" .. chat_id)
  redis:del("Lock:Fosh:" .. chat_id)
  redis:del("Lock:Via:" .. chat_id)
  redis:del("Lock:Ads:" .. chat_id)
  redis:del("Lock:Fwdch:" .. chat_id)
  redis:del("Lock:Fwduser:" .. chat_id)
  redis:del("Lock:Tab:" .. chat_id)
  redis:del("Lock:Inline:" .. chat_id)
  redis:del("Lock:Web:" .. chat_id)
  redis:del("Lock:Flood:" .. chat_id)
  redis:del("Lock:Tgservice:" .. chat_id)
  redis:del("Spam:Lock:" .. chat_id)
  redis:del("Lock:Cmd:" .. chat_id)
  redis:del("Lock:Group:" .. chat_id)
  redis:del("Lock:Bot:" .. chat_id)
  redis:del("Lock:Botadder:" .. chat_id)
  redis:del("Lock:Join:" .. chat_id)
  redis:del("Lock:Pin:" .. chat_id)
  redis:del("AutoLock:" .. chat_id)
  redis:del("forceadd" .. chat_id)
  redis:del("test:" .. chat_id)
  redis:del("Force:Pm:" .. chat_id)
  redis:del("Force:Max:" .. chat_id)
  redis:del("AntiTabchi:" .. chat_id)
  redis:srem("Gp2:" .. chat_id, "cgmautoon")
  redis:del("cgmauto:" .. chat_id)
  redis:del("cbmon" .. chat_id)
  redis:srem("Gp2:" .. chat_id, "cbmonn")
  redis:del("ForceJoingp:" .. chat_id)
  redis:del("ForceJoin:" .. chat_id)
  redis:del("chsup" .. chat_id)
  redis:del("ExpireData:" .. chat_id)
  redis:del("forceadd" .. chat_id)
  redis:del("test:" .. chat_id)
  redis:del("Force:Pm:" .. chat_id)
  redis:del("Force:Max:" .. chat_id)
  redis:del("OwnerList:" .. chat_id)
  redis:del("ModList:" .. chat_id)
  redis:del("Filters:" .. chat_id)
  redis:del("CheckExpire:" .. chat_id)
  redis:del("Total:Stickers:" .. chat_id)
  redis:del("Total:Text:" .. chat_id)
  redis:del("Total:ChatDeleteMember:" .. chat_id)
  redis:del("Total:ChatJoinByLink:" .. chat_id)
  redis:del("Total:Audio:" .. chat_id)
  redis:del("Total:Voice:" .. chat_id)
  redis:del("Total:Video:" .. chat_id)
  redis:del("Total:Animation:" .. chat_id)
  redis:del("Total:Location:" .. chat_id)
  redis:del("Total:ForwardedFromUser:" .. chat_id)
  redis:del("Total:Document:" .. chat_id)
  redis:del("Total:Contact:" .. chat_id)
  redis:del("Total:Photo:" .. chat_id)
  redis:del("Total:messages:" .. chat_id)
  redis:del("Total:added:" .. chat_id)
  redis:del("locks_acs:ModAccess" .. chat_id)
  redis:del("settings_acs:ModAccess" .. chat_id)
  redis:del("menu_acs:ModAccess" .. chat_id)
  redis:del("users_acs:ModAccess" .. chat_id)
  redis:del("clean_acs:ModAccess" .. chat_id)
  local users = redis:smembers("Total:users:" .. chat_id)
  do
    do
      for i, i in pairs(users) do
        redis:del("addeduser" .. chat_id .. i)
        redis:srem("Gp2:" .. chat_id, i .. "AddEnd")
        redis:del("pmdadeshode" .. chat_id .. i .. os.date("%Y/%m/%d"))
        redis:del("rank" .. i)
        redis:del("Total:messages:" .. chat_id .. ":" .. i)
        redis:del("Total:added:" .. chat_id .. ":" .. i)
      end
    end
  end
end

function remRed(chat_id)
  redis:del("settings_acsuser:" .. chat_id)
  redis:del("locks_acsuser:" .. chat_id)
  redis:del("menu_acsuser:" .. chat_id)
  redis:del("users_acsuser:" .. chat_id)
  redis:del("acsclean:" .. chat_id)
  redis:del("Auto:demote" .. chat_id)
  redis:del("TabForward:" .. chat_id)
  redis:del("BanUser:" .. chat_id)
  redis:del("MuteList:" .. chat_id)
  redis:del("Vip:" .. chat_id)
  redis:del("Filters:" .. chat_id)
  redis:del(chat_id .. ":warn")
  redis:del("Text:Welcome:" .. chat_id)
  redis:del("Link:" .. chat_id)
  redis:del("welcm" .. chat_id)
  redis:del("Rules:" .. chat_id)
  redis:del("filterpackname" .. chat_id)
  redis:del("AntiTabchiimoje:" .. chat_id)
  redis:del("AntiTabchi:" .. chat_id)
  redis:del("AntiTabchitest:" .. chat_id)
  redis:del("NewUser" .. chat_id)
  redis:del("cgmautotime:" .. chat_id)
  redis:del("cgmauto:" .. chat_id)
  redis:del("autoanswer" .. chat_id)
  redis:del("chsup" .. chat_id)
  redis:del("stats:" .. chat_id)
  redis:del("Welcome:" .. chat_id)
  redis:del("Lock:Link:" .. chat_id)
  redis:del("Lock:Markdown:" .. chat_id)
  redis:del("Lock:Mention:" .. chat_id)
  redis:del("Lock:Reply:" .. chat_id)
  redis:del("Lock:Tag:" .. chat_id)
  redis:del("Lock:Hashtag:" .. chat_id)
  redis:del("Lock:Forward:" .. chat_id)
  redis:del("Lock:Farsi:" .. chat_id)
  redis:del("Lock:English:" .. chat_id)
  redis:del("Lock:Text:" .. chat_id)
  redis:del("Lock:Sticker:" .. chat_id)
  redis:del("Lock:Game:" .. chat_id)
  redis:del("Lock:Photo:" .. chat_id)
  redis:del("Lock:File:" .. chat_id)
  redis:del("Lock:Video:" .. chat_id)
  redis:del("Lock:Music:" .. chat_id)
  redis:del("Lock:Voice:" .. chat_id)
  redis:del("Lock:Gif:" .. chat_id)
  redis:del("Lock:Videonote:" .. chat_id)
  redis:del("Lock:Caption:" .. chat_id)
  redis:del("Lock:Location:" .. chat_id)
  redis:del("Lock:Emoji:" .. chat_id)
  redis:del("Lock:Contact:" .. chat_id)
  redis:del("Lock:Fosh:" .. chat_id)
  redis:del("Lock:Via:" .. chat_id)
  redis:del("Lock:Ads:" .. chat_id)
  redis:del("Lock:Fwdch:" .. chat_id)
  redis:del("Lock:Fwduser:" .. chat_id)
  redis:del("Lock:Tab:" .. chat_id)
  redis:del("Lock:Inline:" .. chat_id)
  redis:del("Lock:Web:" .. chat_id)
  redis:del("Lock:Flood:" .. chat_id)
  redis:del("Lock:Tgservice:" .. chat_id)
  redis:del("Spam:Lock:" .. chat_id)
  redis:del("Lock:Cmd:" .. chat_id)
  redis:del("Lock:Group:" .. chat_id)
  redis:del("Lock:Bot:" .. chat_id)
  redis:del("Lock:Botadder:" .. chat_id)
  redis:del("Lock:Join:" .. chat_id)
  redis:del("Lock:Pin:" .. chat_id)
  redis:del("AutoLock:" .. chat_id)
  redis:del("test:" .. chat_id)
  redis:del("Force:Pm:" .. chat_id)
  redis:del("Force:Max:" .. chat_id)
  redis:del("AntiTabchi:" .. chat_id)
  redis:srem("Gp2:" .. chat_id, "cgmautoon")
  redis:del("cgmauto:" .. chat_id)
  redis:del("ForceJoingp:" .. chat_id)
  redis:del("chsup" .. chat_id)
  redis:del("forceadd" .. chat_id)
  redis:del("test:" .. chat_id)
  redis:del("Force:Pm:" .. chat_id)
  redis:del("Force:Max:" .. chat_id)
  redis:del("Filters:" .. chat_id)
  redis:del("Total:Stickers:" .. chat_id)
  redis:del("Total:Text:" .. chat_id)
  redis:del("Total:ChatDeleteMember:" .. chat_id)
  redis:del("Total:ChatJoinByLink:" .. chat_id)
  redis:del("Total:Audio:" .. chat_id)
  redis:del("Total:Voice:" .. chat_id)
  redis:del("Total:Video:" .. chat_id)
  redis:del("Total:Animation:" .. chat_id)
  redis:del("Total:Location:" .. chat_id)
  redis:del("Total:ForwardedFromUser:" .. chat_id)
  redis:del("Total:Document:" .. chat_id)
  redis:del("Total:Contact:" .. chat_id)
  redis:del("Total:Photo:" .. chat_id)
  redis:del("Total:messages:" .. chat_id)
  redis:del("Total:added:" .. chat_id)
  redis:del("locks_acs:ModAccess" .. chat_id)
  redis:del("settings_acs:ModAccess" .. chat_id)
  redis:del("menu_acs:ModAccess" .. chat_id)
  redis:del("users_acs:ModAccess" .. chat_id)
  redis:del("clean_acs:ModAccess" .. chat_id)
  local users = redis:smembers("Total:users:" .. chat_id)
  do
    do
      for i, i in pairs(users) do
        redis:del("addeduser" .. chat_id .. i)
        redis:srem("Gp2:" .. chat_id, i .. "AddEnd")
        redis:del("pmdadeshode" .. chat_id .. i .. os.date("%Y/%m/%d"))
        redis:del("rank" .. i)
        redis:del("Total:messages:" .. chat_id .. ":" .. i)
        redis:del("Total:added:" .. chat_id .. ":" .. i)
      end
    end
  end
end

function is_JoinChannell(msg, chat, user)
  local var = true
  if redis:get("ForceJoingp:" .. chat) then
    Channelll = redis:get("chsup" .. chat) or "@LeaderUpdate"
    Channell = "" .. Channelll:gsub("@", "") .. ""
    local url, res = https.request("https://api.telegram.org/bot" .. token .. "/getchatmember?chat_id=" .. "@" .. Channelll .. "&user_id=" .. user)
    data = json:decode(url)
    if res ~= 200 or not is_GlobalyBan(user) and (data and data.result and data.result.status == "left" or data and data.result and data.result.status == "kicked") and not is_mod(chat, user) then
      var = false
      function Joinch(result, Claire)
        if not redis:get("ForceJoingpp:" .. chat) and Claire.first_name then
          username = Claire.first_name:gsub(">", "")
          username = username:gsub("<", "")
          username = "<a href=\"tg://user?id=" .. user .. "\">" .. username .. "</a>"
          local keyboard = {}
          keyboard.inline_keyboard = {
            {
              {
                text = "برای ورود به کانال کلیک کنید🔸",
                url = "https://telegram.me/" .. Channell .. ""
              }
            }
          }
          SendInline(chat, 0, "کاربر " .. username .. "\nشما برای ارسال پیام باید در کانال گروه جوین شوید \n{" .. "@" .. Channelll .. "}", keyboard, "html")
          redis:setex("ForceJoingpp:" .. chat, 60, true)
        end
        deleteMessages(chat, {
          [0] = msg.id
        })
      end
      
      GetUser(user, Joinch)
    elseif data.ok then
      return var
    end
  else
    return var
  end
end

function is_JoinChannel(msg, chat, user)
  local var = true
  if redis:get("ForceJoin:" .. chat) then
    chjoin = redis:get("chjoin") or "" .. ChannelInline .. ""
    local url, res = https.request("https://api.telegram.org/bot" .. token .. "/getchatmember?chat_id=" .. "@" .. chjoin .. "&user_id=" .. user)
    data = json:decode(url)
    if res ~= 200 or (data and data.result and data.result.status == "left" or data and data.result and data.result.status == "kicked") and not is_sudo(user) then
      var = false
      function Joinch(ehsan, result)
        if result.first_name then
          username = result.first_name:gsub(">", "")
          username = username:gsub("<", "")
          username = "<a href=\"tg://user?id=" .. user .. "\">" .. username .. "</a>"
          local keyboard = {}
          keyboard.inline_keyboard = {
            {
              {
                text = "برای ورود به کانال کلیک کنید🔸",
                url = "https://telegram.me/" .. chjoin .. ""
              }
            }
          }
          SendInline(chat, 0, "کاربر " .. username .. "\n• جهت استفاده از ربات عضو کانال ربات شوید و سپس مجددا دستور خود را ارسال نمایید !\n{" .. "@" .. chjoin .. "}", keyboard, "html")
        end
      end
      
      GetUser(user, Joinch)
    elseif data.ok then
      return var
    end
  else
    return var
  end
end

function leaderonlock(msg, chat_id, type, Leader)
  if redis:get(type .. chat_id) then
    sendText(chat_id, msg.id, "• " .. Leader .. " فعال بود !", "md")
  else
    redis:set(type .. chat_id, true)
    sendText(chat_id, msg.id, "• " .. Leader .. " فعال شد !", "md")
  end
end

function leaderofflock(msg, chat_id, type, Leader)
  if redis:get(type .. chat_id) then
    redis:del(type .. chat_id)
    sendText(chat_id, msg.id, "• " .. Leader .. " غیر فعال شد !", "md")
  else
    sendText(chat_id, msg.id, "• " .. Leader .. " غیر فعال بود !", "md")
  end
end

function LockProExtra(msg, chat, user, Stats)
  local hashwarn = chat .. ":warn"
  local warnhash = redis:hget(chat .. ":warn", user) or 1
  if Stats == "Enable" then
    return
  end
  if Stats == "Warn" then
    if tonumber(warnhash) == tonumber(warn) then
      KickUser(chat, user)
      RemoveFromBanList(chat, user)
      redis:hdel(hashwarn, user, "0")
    else
      local warnhash = redis:hget(chat .. ":warn", user) or 1
      redis:hset(hashwarn, user, tonumber(warnhash) + 1)
    end
  end
  if Stats == "Kick" then
    KickUser(chat, user)
    RemoveFromBanList(chat, user)
  end
  if Stats == "Ban" then
    KickUser(chat, user)
  end
  if Stats == "Mute" then
    mute(chat, user, "Restricted", {
      1,
      0,
      0,
      0,
      0,
      0
    })
  end
end

function change(ops)
  if not ops then
    return
  end
  changelang = {
    FA = {
      "لینک",
      "فحش",
      "گروه",
      "تگ",
      "فروارد",
      "هشتگ",
      "وب",
      "متن",
      "فونت",
      "انگلیسی",
      "فارسی",
      "سرویس تلگرام",
      "منشن",
      "ویرایش",
      "ورود لینک",
      "دستورات",
      "ربات",
      "عکس",
      "فایل",
      "استیکر",
      "فیلم",
      "فیلم سلفی",
      "اسپم",
      "شماره",
      "مخاطب",
      "بازی",
      "اینلاین",
      "موقعیت",
      "گیف",
      "آهنگ",
      "ویس",
      "اضافه کننده ربات",
      "رسانه",
      "ریپلی",
      "بیوگرافی",
      "استیکر متحرک",
      "فلود",
      "فروارد کاربر",
      "ایموجی",
      "ورود ادد",
      "فروارد کانال"
    },
    EN = {
      "Lock:Link:",
      "Lock:fosh:",
      "Lock:Group:",
      "Lock:Tag:",
      "Lock:Forward:",
      "Lock:Hashtag:",
      "Lock:Web:",
      "Lock:Text:",
      "Lock:Markdown:",
      "Lock:English:",
      "Lock:Farsi:",
      "Lock:Tgservice:",
      "Lock:Mention:",
      "Lock:Edit:",
      "Lock:Join:",
      "Lock:Cmd:",
      "Lock:Bot:",
      "Lock:Photo:",
      "Lock:File:",
      "Lock:Sticker:",
      "Lock:Video:",
      "Lock:Videonote:",
      "Spam:Lock:",
      "Lock:nmuber",
      "Lock:Contact:",
      "Lock:Game:",
      "Lock:Inline:",
      "Lock:Location:",
      "Lock:Gif:",
      "Lock:Music:",
      "Lock:Voice:",
      "Lock:Botadder:",
      "Lock:Caption:",
      "Lock:Reply:",
      "Lock:bio:",
      "Lock:Stickermm:",
      "Lock:Flood:",
      "Lock:Fwduser:",
      "Lock:Emoji:",
      "Lock:Joinad:",
      "Lock:Fwdch:"
    }
  }
  do
    do
      for i, i in pairs(changelang.FA) do
        if ops == i then
          return changelang.EN[i]
        end
      end
    end
  end
  return false
end

function CheckCity(city)
  if not city then
    return
  end
  local cities = {
    Fa = {
      "تهران",
      "آذربایجان شرقی",
      "آذربایجان غربی",
      "اردبیل",
      "اصفهان",
      "البرز",
      "ایلام",
      "بوشهر",
      "چهارمحال و بختیاری",
      "خراسان جنوبی",
      "خوزستان",
      "زنجان",
      "سمنان",
      "سیستان و بلوچستان",
      "شیراز",
      "قزوین",
      "قم",
      "کردستان",
      "کرمان",
      "کرمانشاه",
      "کهگیلویه و بویراحمد",
      "گلستان",
      "گیلان",
      "گلستان",
      "لرستان",
      "مازندران",
      "مرکزی",
      "هرمزگان",
      "همدان",
      "یزد"
    },
    En = {
      "Tehran",
      "AzarbayjanSharghi",
      "AzarbayjanGharbi",
      "Ardebil",
      "Esfehan",
      "Alborz",
      "Ilam",
      "Boshehr",
      "Chaharmahalbakhtiari",
      "KhorasanJonoobi",
      "Khozestan",
      "Zanjan",
      "Semnan",
      "SistanBalochestan",
      "Fars",
      "Ghazvin",
      "Qom",
      "Kordestan",
      "Kerman",
      "KermanShah",
      "KohkilooyehVaBoyerAhmad",
      "Golestan",
      "Gilan",
      "Lorestan",
      "Mazandaran",
      "Markazi",
      "Hormozgan",
      "Hamedan",
      "Yazd"
    }
  }
  do
    do
      for i, i in pairs(cities.Fa) do
        if city == i then
          return cities.En[i]
        end
      end
    end
  end
  return false
end

function leaderListChat(msg, chat, list, Leader)
  local text = "لیست " .. Leader .. " گروه \n\n"
  do
    do
      for i, i in pairs(list) do
        local firstname = redis:get("firstname" .. i)
        if firstname then
          username = "<a href=\"tg://user?id=" .. i .. "\">" .. check_html(firstname) .. "</a> [<code>" .. i .. "</code>]"
        else
          username = "<a href=\"tg://user?id=" .. i .. "\">" .. i .. "</a>"
        end
        text = text .. i .. " - " .. username .. "\n"
      end
    end
  end
  if #list == 0 then
    text = "لیست  خالی میباشد!"
  end
  sendText(chat, msg.id, text, "html")
end

function leaderclean(msg, chat, type, Leader)
  function cb(arg, data)
    do
      do
        for i, i in pairs(data.messages) do
          if i.content and i.content._ == type then
            deleteMessages(chat, {
              [0] = i.id
            })
          end
        end
      end
    end
  end
  
  getChatHistory(chat, msg.id, 0, 500000000000, cb)
  sendText(chat, msg.id, " تمامی " .. Leader .. " که اخیرا در گروه ارسال شده بودند پاک شد", "md")
end

function CleanPm(msg, chat, taype, leadertaype)
  function cb(arg, data)
    do
      do
        for i, i in pairs(data.messages) do
          if i.content.text or i.content.caption then
            TextToCheck = i.content.text or i.content.caption
            if TextToCheck:match(taype) then
              deleteMessages(chat, {
                [0] = i.id
              })
            end
          end
        end
      end
    end
  end
  
  getChatHistory(chat, msg.id, 0, 500000000, cb)
  sendText(chat, msg.id, "تمامی " .. leadertaype .. " ارسالی در گروه پاک شدند", "md")
end

function antifloodstats(msg, chat, user, status)
  if status == "kickuser" then
    function Kicks(extra, result, success)
      if result.username then
        username = "" .. result.first_name .. ""
      end
      usernameee = "<a href=\"tg://user?id=" .. user .. "\">" .. username .. "</a>"
      text = "• کاربر " .. usernameee .. " \n به علت ارسال بیش از حد پیام  از گروه اخراج شد!"
      sendText(chat, msg.id, text, "html")
      deleteMessages(chat, {
        [0] = msg.id
      })
      KickUser(chat, user)
    end
    
    GetUser(user, Kicks)
  end
  if status == "deletemsg" then
    function Dels(extra, result, success)
      if result.username then
        username = "" .. result.first_name .. ""
      end
      usernameee = "<a href=\"tg://user?id=" .. user .. "\">" .. username .. "</a>"
      text = "• کاربر " .. usernameee .. " \n به علت ارسال بیش از حد پیام هایش پاک شد !"
      sendText(chat, msg.id, text, "html")
      sendApi(TD_ID, "delall " .. chat .. " " .. user, 0, "md")
      deleteMessages(chat, {
        [0] = msg.id
      })
    end
    
    GetUser(user, Dels)
  end
  if status == "muteuser" then
    function Mutes(extra, result, success)
      if result.username then
        username = "" .. result.first_name .. ""
      end
      usernameee = "<a href=\"tg://user?id=" .. user .. "\">" .. username .. "</a>"
      text = "• کاربر " .. usernameee .. " \n به علت ارسال بیش از حد پیام در گروه محدود شد!"
      sendText(chat, msg.id, text, "html")
      mute(chat, user, "Restricted", {
        1,
        0,
        0,
        0,
        0,
        0
      })
      redis:sadd("MuteList:" .. chat, user)
    end
    
    GetUser(user, Mutes)
  end
end

function leaderList(msg, chat, list, Leader)
  local text = "لیست " .. Leader .. " ربات \n\n"
  do
    do
      for i, i in pairs(list) do
        local firstname = redis:get("firstname" .. i)
        if firstname then
          username = "<a href=\"tg://user?id=" .. i .. "\">" .. check_html(firstname) .. "</a> [<code>" .. i .. "</code>]"
        else
          username = "<a href=\"tg://user?id=" .. i .. "\">" .. i .. "</a>"
        end
        text = text .. i .. " - " .. username .. "\n"
      end
    end
  end
  if #list == 0 then
    text = "لیست  خالی میباشد!"
  end
  sendText(chat, msg.id, text, "html")
end

function leadercleanuser(msg, chat_id, type, Text)
  function list(extra, result, success)
    if result.members then
      do
        for i, i in pairs(result.members) do
          local CheckLastMonth = function(extra, result, success)
            if result.status._ == type then
              KickUser(chat_id, result.id)
            end
          end
          
          GetUser(i.user_id, CheckLastMonth)
        end
      end
    end
  end
  
  getChannelMembers(chat_id, "Search", 0, 200, list)
  sendText(chat_id, msg.id, "کاربران " .. Text .. " با موفقیت پاکسازی شدند", "md")
end

function GetUserFull(user_id, cb)
  assert(tdbot_function({
    _ = "getUserFull",
    user_id = user_id
  }, cb, nil))
end

function is_supergroup(msg)
  chat_id = tostring(msg.chat_id)
  if chat_id:match("^-100") then
    if not msg.is_post then
      return true
    end
  else
    return false
  end
end

function vardump(value)
  print(serpent.block(value, {comment = false}))
end

function dl_cb(arg, data)
end

function is_filter(msg, value)
  local list = redis:smembers("Filters:" .. msg.chat_id)
  var = false
  do
    do
      for i = 1, #list do
        input = string.gsub(list[i], "%%", "")
        if value:match(input) then
          var = true
        end
      end
    end
  end
  return var
end

AbuseWorid = {
  "کیر",
  "کوص",
  "کص",
  "کس",
  "کسو",
  "کصو",
  "نن جنده",
  "ننه کونی",
  "تخم سگ",
  "پدرسگ",
  "نن لاشی",
  "ننه جنده",
  "کصکش",
  "کیری",
  "کونی",
  "خارکصه",
  "addi",
  "توم ذخیره شدی",
  "add",
  "kir",
  "nne",
  "kon",
  "میگام",
  "پیج تلگرام",
  "کانال تلگرامی",
  "شارژ رایگان",
  "تبلیغات",
  "یالا پا بزن بی ناموس",
  "ننه لاشی",
  "تخم سگ",
  "تخم جنده",
  "کسوزاده",
  "اددی",
  "ادد پی",
  "لاشی",
  "ننه هزار کیر",
  "کیرم",
  "ننه جنده",
  "خار کونی",
  "ننه لش",
  "جنده",
  "خارکصو",
  "ننه لامپی",
  "حرومی",
  "",
  "ننتو میگام",
  "ننه جنده",
  "تخم چن",
  "تخم سگ",
  "تخم خر",
  "تخم بابتی",
  "pv",
  "bia pv",
  "nnat",
  "khar",
  "jende",
  "بی ناموس",
  "نن فیلمی",
  "حروم",
  "سگ بگادد"
}
function AbuseWoridr(msg, value)
  var = false
  do
    do
      for i = 1, #AbuseWorid do
        if value:match(AbuseWorid[i]) then
          var = true
        end
      end
    end
  end
  return var
end

function sleep(time)
  local clock = os.clock
  local t0 = clock()
  while time >= clock() - t0 do
  end
end

function showedit(msg, data)
  if msg then
    local text = msg.content.text
    local lc = msg.content.text
    if msg.content._ == "messageText" and text and text:match("^[/#!]") then
      text = text:gsub("^[/#!]", "")
    end
    if is_supergroup(msg) then
      if is_mod(msg.chat_id, msg.sender_user_id) and (text == "ping" or text == "پینگ") then
        ping = io.popen("ping -c 1 api.telegram.org"):read("*a"):match("time=(%S+)")
        pingser = "<a href=\"tg://user?id=" .. TD_ID .. "\">" .. ping .. "</a>"
        sendText(msg.chat_id, msg.id, "• Always Online Babe\n\n » Server Response Time :" .. pingser .. "", "html")
      end
      if msg.content._ == "messageChatAddMembers" and is_sudo(msg.sender_user_id) and tonumber(msg.content.member_user_ids[0]) == tonumber(BotHelper) then
        redis:setex("ExpireData:" .. msg.chat_id, 86400, true)
      end
      if redis:get("Lock:Tgservice:" .. msg.chat_id) and (msg.content._ == "messageChatAddMembers" or msg.content._ == "messagePinMessage" or msg.content._ == "messageChatDeleteMember" or msg.content._ == "messageChatChangeTitle" or msg.content._ == "messageChatChangePhoto" or msg.content._ == "messageChatJoinByLink" or msg.content._ == "messageGameScore") then
        deleteMessages(msg.chat_id, {
          [0] = msg.id
        })
      end
      if msg.content._ == "messageChatAddMembers" and not is_sudo(msg.sender_user_id) and tonumber(msg.content.member_user_ids[0]) == tonumber(BotHelper) then
        Left(msg.chat_id, BotHelper, "Left")
      end
      if msg.content._ == "messageChatAddMembers" then
        do
          do
            for i = 0, #msg.content.member_user_ids do
              redis:incrbyfloat("Total:added:" .. msg.chat_id .. ":" .. msg.sender_user_id, #msg.content.member_user_ids + 1)
              redis:incrbyfloat("Total:added:" .. msg.chat_id, #msg.content.member_user_ids + 1)
              msg.add = msg.content.member_user_ids[i]
            end
          end
        end
        deleteMessages(msg.chat_id, {
          [0] = msg.add
        })
      end
      if not is_mod(msg.chat_id, msg.sender_user_id) and not is_Vip(msg.chat_id, msg.sender_user_id) then
        local user = msg.sender_user_id
        local forwardByUser = redis:get("forward:User" .. msg.chat_id .. msg.sender_user_id) or 0
        max_forward = tonumber(3)
        if redis:get("TabForward:" .. msg.chat_id) then
          if tonumber(forwardByUser) == tonumber(max_forward) then
            KickUser(msg.chat_id, msg.sender_user_id)
            redis:del("forward:User" .. msg.chat_id .. msg.sender_user_id)
          end
          if msg.forward_info then
            redis:incr("forward:User" .. msg.chat_id .. msg.sender_user_id)
          end
        end
        NUM_MSG_MAX = tonumber(redis:get("Flood:Max:" .. msg.chat_id) or 6)
        TIME_CHECK = tonumber(redis:get("Flood:Time:" .. msg.chat_id) or 2)
        if redis:get("Lock:Flood:" .. msg.chat_id) then
          local msgs = tonumber(redis:get("user1:" .. msg.sender_user_id .. ":flooder") or 0)
          if msgs > tonumber(NUM_MSG_MAX) then
            if redis:get("user:" .. msg.sender_user_id .. ":flooder") then
              local status = redis:get("Flood:Status:" .. msg.chat_id)
              antifloodstats(msg, msg.chat_id, msg.sender_user_id, status)
              return false
            else
              redis:setex("user:" .. msg.sender_user_id .. ":flooder", 15, true)
            end
          end
          redis:setex("user1:" .. msg.sender_user_id .. ":flooder", tonumber(TIME_CHECK), msgs + 1)
        end
        if redis:get("Lock:Forward:" .. msg.chat_id) and msg.forward_info then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
          local Stats = redis:get("Lock:Forward:" .. msg.chat_id)
          LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
        end
        if redis:get("Lock:Web:" .. msg.chat_id) and (msg.content.text or msg.content.caption) then
          TextToCheck = msg.content.text or msg.content.caption
          if TextToCheck:match(".[Oo][Rr][Gg]") or TextToCheck:match(".[Cc][Oo][Mm]") or TextToCheck:match("[Ww][Ww][Ww].") or TextToCheck:match(".[Ii][Rr]") or TextToCheck:match(".[Ii][Nn][Ff][Oo]") or TextToCheck:match(".[Tt][Kk]") then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
        end
        if redis:get("Lock:Emoji:" .. msg.chat_id) and (text or msg.content.caption) then
          TextToCheck = text or msg.content.caption
          if TextToCheck:match("[�-�]") then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
        end
        if msg.content._ == "messageText" and redis:get("Lock:Group:" .. msg.chat_id) then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if msg.content._ == "messageText" and redis:get("Lock:AutoGp" .. msg.chat_id) then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Link:" .. msg.chat_id) then
          if text then
            local link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or text:match("[Tt].[Mm][Ee]/") or text:match("(.*)[.][mM][Ee]") or text:match("[Ww][Ww][Ww].(.*)") or text:match("(.*).[Ii][Rr]") or text:match("[Hh][Tt][Tt][Pp][Ss]://(.*)") or text:match("[Ww][Ww][Ww].(.*)") or msg.content.text:match("[Hh][Tt][Tt][Pp]://(.*)")
            if link then
              deleteMessages(msg.chat_id, {
                [0] = msg.id
              })
              local Stats = redis:get("Lock:Link:" .. msg.chat_id)
              LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
            end
          end
          if msg.content.caption then
            local cap = msg.content.caption
            local link = cap:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or cap:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or cap:match("[Tt].[Mm][Ee]/") or cap:match("(.*)[.][mM][Ee]") or cap:match("(.*).[Ii][Rr]") or cap:match("[Ww][Ww][Ww].(.*)") or cap:match("[Hh][Tt][Tt][Pp][Ss]://") or msg.content.caption:match("[Hh][Tt][Tt][Pp]://(.*)")
            if link then
              deleteMessages(msg.chat_id, {
                [0] = msg.id
              })
              local Stats = redis:get("Lock:Link:" .. msg.chat_id)
              LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
            end
          end
        end
        if redis:get("Lock:bio:" .. msg.chat_id) and msg.sender_user_id then
          function BioLink(extra, result, success)
            if result.about then
              LeaderAbout = result.about
            else
              LeaderAbout = "Nil"
            end
            if LeaderAbout:match("[Tt].[Mm][Ee]/") or LeaderAbout:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") then
              deleteMessages(msg.chat_id, {
                [0] = msg.id
              })
            end
          end
          
          GetUserFull(msg.sender_user_id, BioLink)
        end
        if redis:get("Lock:Tag:" .. msg.chat_id) and (msg.content.text or msg.content.caption) then
          TextToCheck = msg.content.text or msg.content.caption
          if TextToCheck:match("@") then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
            local Stats = redis:get("Lock:Tag:" .. msg.chat_id)
            LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
          end
        end
        if redis:get("Lock:Hashtag:" .. msg.chat_id) and (msg.content.text or msg.content.caption) then
          TextToCheck = msg.content.text or msg.content.caption
          if TextToCheck:match("#") then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
        end
        if redis:get("Lock:Videonote:" .. msg.chat_id) then
        elseif msg.content._ == "messageVideoNote" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:File:" .. msg.chat_id) and msg.content._ == "messageDocument" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
          local Stats = redis:get("Lock:File:" .. msg.chat_id)
          LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
        end
        if redis:get("Lock:Mention:" .. msg.chat_id) and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Farsi:" .. msg.chat_id) and (msg.content.text or msg.content.caption) then
          TextToCheck = msg.content.text or msg.content.caption
          if TextToCheck:match("[�-�][�-�]") then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
        end
        if redis:get("Lock:English:" .. msg.chat_id) and (msg.content.text or msg.content.caption) then
          TextToCheck = msg.content.text or msg.content.caption
          if TextToCheck:match("[A-Z]") or TextToCheck:match("[a-z]") then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
        end
        if msg.content._ == "messageText" then
          local _nl, ctrl_chars = string.gsub(msg.content.text, "%c", "")
          local _nl, real_digits = string.gsub(msg.content.text, "%d", "")
          maxchar = tonumber(redis:get("NUM_CH_MAX" .. msg.chat_id)) or 400
          MAX_CHAR = tonumber(maxchar + 3)
          if (string.len(msg.content.text) > MAX_CHAR or ctrl_chars > MAX_CHAR or real_digits > MAX_CHAR) and redis:get("Spam:Lock:" .. msg.chat_id) then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
        end
        if text then
          if is_filter(msg, text) then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
          if redis:get("Lock:fosh:" .. msg.chat_id) and AbuseWoridr(msg, text) then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
        end
        if redis:get("Lock:Bot:" .. msg.chat_id) and msg.content._ == "messageChatAddMembers" then
          do
            for i = 0, #msg.content.member_user_ids do
              function Bot(extra, result, success)
                if result.type._ == "userTypeBot" then
                  KickUser(msg.chat_id, msg.content.member_user_ids[i])
                end
              end
              
              GetUser(msg.content.member_user_ids[i], Bot)
            end
          end
        end
        if redis:get("Lock:Botadder:" .. msg.chat_id) and msg.content._ == "messageChatAddMembers" then
          do
            for i = 0, #msg.content.member_user_ids do
              function AddBot(extra, result, success)
                if result.type._ == "userTypeBot" then
                  KickUser(msg.chat_id, msg.sender_user_id)
                end
              end
              
              GetUser(msg.content.member_user_ids[i], AddBot)
            end
          end
        end
        if redis:get("Lock:Join:" .. msg.chat_id) == "Add" and msg.content._ == "messageChatAddMembers" then
          do
            for i = 0, #msg.content.member_user_ids do
              function Add(extra, result, success)
                KickUser(msg.chat_id, msg.content.member_user_ids[i])
              end
              
              GetUser(msg.content.member_user_ids[i], Add)
            end
          end
        end
        if redis:get("Lock:Markdown:" .. msg.chat_id) and msg.content.entities and msg.content.entities[0] and (msg.content.entities[0].type._ == "textEntityTypeBold" or msg.content.entities[0].type._ == "textEntityTypeCode" or msg.content.entities[0].type._ == "textEntityTypeitalic") then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Inline:" .. msg.chat_id) and msg.reply_markup and msg.reply_markup._ == "replyMarkupInlineKeyboard" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Fwduser:" .. msg.chat_id) and msg.forward_info and msg.forward_info._ == "messageForwardedFromUser" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
          local Stats = redis:get("Lock:Fwduser:" .. msg.chat_id)
          LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
        end
        if redis:get("Lock:Fwdch:" .. msg.chat_id) and msg.forward_info and msg.forward_info._ == "messageForwardedPost" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
          local Stats = redis:get("Lock:Fwdch:" .. msg.chat_id)
          LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
        end
        if redis:get("Lock:Sticker:" .. msg.chat_id) and msg.content._ == "messageSticker" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Edit:" .. msg.chat_id) and 0 < msg.edit_date then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Text:" .. msg.chat_id) and msg.content._ == "messageText" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Photo:" .. msg.chat_id) and msg.content._ == "messagePhoto" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
          local Stats = redis:get("Lock:Photo:" .. msg.chat_id)
        end
        if redis:get("Lock:Caption:" .. msg.chat_id) and msg.content.caption then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
          local Stats = redis:get("Lock:Caption:" .. msg.chat_id)
          LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
        end
        if redis:get("Lock:Reply:" .. msg.chat_id) and 0 < tonumber(msg.reply_to_message_id) then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Location:" .. msg.chat_id) and msg.content._ == "messageLocation" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Voice:" .. msg.chat_id) and msg.content._ == "messageVoice" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if msg.content._ == "messageSticker" then
          local filterpack = redis:smembers("filterpack" .. msg.chat_id)
          do
            for i, i in pairs(filterpack) do
              if i == msg.content.sticker.set_id then
                deleteMessages(msg.chat_id, {
                  [0] = msg.id
                })
              end
            end
          end
        end
        if redis:get("Lock:nmuber" .. msg.chat_id) and (msg.content.text or msg.content.caption) then
          TextToCheck = msg.content.text or msg.content.caption
          if TextToCheck:match("+") or TextToCheck:match("0") or TextToCheck:match("*") then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
        end
        if redis:get("Lock:Contact:" .. msg.chat_id) and msg.content._ == "messageContact" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
          local Stats = redis:get("Lock:Contact:" .. msg.chat_id)
          LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
        end
        if redis:get("Lock:Game:" .. msg.chat_id) and msg.content.game then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
          local Stats = redis:get("Lock:Game:" .. msg.chat_id)
          LockProExtra(msg, msg.chat_id, msg.sender_user_id, Stats)
        end
        if redis:get("Lock:Video:" .. msg.chat_id) and msg.content._ == "messageVideo" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Music:" .. msg.chat_id) and msg.content._ == "messageAudio" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
        if redis:get("Lock:Gif:" .. msg.chat_id) and msg.content._ == "messageAnimation" then
          deleteMessages(msg.chat_id, {
            [0] = msg.id
          })
        end
      end
      if redis:get("AutoLock:" .. msg.chat_id) then
        local time = os.date("%H%M")
        local start = redis:get("automutestart" .. msg.chat_id) or "0000"
        local endtime = redis:get("automuteend" .. msg.chat_id) or "0000"
        if tonumber(endtime) < tonumber(start) then
          if tonumber(time) <= 2359 and tonumber(time) >= tonumber(start) then
            if not redis:get("Lock:AutoGp" .. msg.chat_id) then
              redis:set("Lock:AutoGp" .. msg.chat_id, true)
            end
          elseif tonumber(time) >= 0 and tonumber(time) < tonumber(endtime) and not redis:get("Lock:AutoGp" .. msg.chat_id) then
            sendText(msg.chat_id, msg.id, "• گروه قفل میباشد لطفا پیامی ارسال نکنید!", "md")
            redis:set("Lock:AutoGp" .. msg.chat_id, true)
          end
        elseif tonumber(endtime) > tonumber(start) then
          if tonumber(time) >= tonumber(start) and tonumber(time) < tonumber(endtime) then
            if not redis:get("Lock:AutoGp" .. msg.chat_id) then
              sendText(msg.chat_id, msg.id, "• گروه قفل میباشد لطفا پیامی ارسال نکنید!", "md")
              redis:set("Lock:AutoGp" .. msg.chat_id, true)
            end
          elseif redis:get("Lock:AutoGp" .. msg.chat_id) then
            sendText(msg.chat_id, msg.id, " قفل خودکار غیرفعال شد !", "md")
            redis:del("Lock:AutoGp" .. msg.chat_id)
          end
        end
      end
      if is_mod(msg.chat_id, msg.sender_user_id) and msg.sender_user_id ~= BotHelper then
        local KickByUser = tonumber(redis:get("Kick:User" .. msg.chat_id .. msg.sender_user_id) or 0)
        max_kick = tonumber(redis:get("Kick:Max:" .. msg.chat_id) or 2)
        if redis:get("Auto:demote" .. msg.chat_id) then
          if tonumber(KickByUser) == tonumber(max_kick) then
            setgpadmin(msg.chat_id, msg.sender_user_id, "Administrator", {
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0
            })
            redis:srem("ModList:" .. msg.chat_id, msg.sender_user_id)
            redis:del("Kick:User" .. msg.chat_id .. msg.sender_user_id)
          end
          if msg.content._ == "messageChatDeleteMember" then
            redis:incr("Kick:User" .. msg.chat_id .. msg.sender_user_id)
          end
        end
      end
      if msg.content._ == "messageText" then
        redis:incr("Total:Text:" .. msg.chat_id)
      end
      if msg.content._ == "messageChatDeleteMember" then
        redis:incr("Total:ChatDeleteMember:" .. msg.chat_id)
        deleteMessages(msg.chat_id, {
          [0] = msg.id
        })
      end
      if msg.content._ == "messageChatJoinByLink" then
        redis:incr("Total:ChatJoinByLink:" .. msg.chat_id)
      end
      if msg.content._ == "messageSticker" then
        redis:incr("Total:Stickers:" .. msg.chat_id)
        stk = msg.content.sticker.sticker.id
        downloadFile(stk, 32)
      end
      if msg.content._ == "messageAudio" then
        redis:incr("Total:Audio:" .. msg.chat_id)
      end
      if not msg.reply_markup and msg.via_bot_user_id ~= 0 then
        MsgType = "MarkDown"
      end
      if msg.content._ == "messageVoice" then
        redis:incr("Total:Voice:" .. msg.chat_id)
      end
      if msg.content._ == "messageVideo" then
        redis:incr("Total:Video:" .. msg.chat_id)
      end
      if msg.content._ == "messageAnimation" then
        redis:incr("Total:Animation:" .. msg.chat_id)
      end
      if msg.content._ == "messageLocation" then
        redis:incr("Total:Location:" .. msg.chat_id)
      end
      if msg.content._ == "messageForwardedFromUser" then
        redis:incr("Total:ForwardedFromUser:" .. msg.chat_id)
      end
      if msg.content._ == "messageDocument" then
        redis:incr("Total:Document:" .. msg.chat_id)
      end
      if msg.content._ == "messageContact" then
        redis:incr("Total:Contact:" .. msg.chat_id)
      end
      if msg.content.game then
      end
      if msg.content._ == "messagePhoto" then
        redis:incr("Total:Photo:" .. msg.chat_id)
        if msg.content.photo.sizes[2] == "" then
          ph = msg.content.photo.sizes[2].photo.id
        else
          ph = msg.content.photo.sizes[1].photo.id
        end
        downloadFile(ph, 32)
      end
      if msg.send_state._ == "messageIsSuccessfullySent" then
        return false
      end
      if msg.content._ == "messageChatAddMembers" then
        function ByAddUser(Leader, TDBot)
          if is_Banned(msg.chat_id, TDBot.id) then
            KickUser(msg.chat_id, msg.content.member_user_ids[0])
          end
        end
        
        GetUser(msg.content.member_user_ids[0], ByAddUser)
      end
      if msg.sender_user_id and is_Banned(msg.chat_id, msg.sender_user_id) then
        KickUser(msg.chat_id, msg.sender_user_id)
      end
      local Forcepm = tonumber(redis:get("Force:Pm:" .. msg.chat_id) or 1)
      local Forcemax = tonumber(redis:get("Force:Max:" .. msg.chat_id) or 1)
      local added = tonumber(redis:get("Total:added:" .. msg.chat_id .. ":" .. msg.sender_user_id) or 0)
      local newuser = redis:get("force_NewUser" .. msg.chat_id)
      addkard = tonumber(added) + 1
      if (msg.sender_user_id or msg.add) and redis:get("forceadd" .. msg.chat_id) and not is_Vip(msg.chat_id, msg.sender_user_id) and not redis:sismember("VipAdd:" .. msg.chat_id, msg.sender_user_id) then
        if newuser then
          if msg.content._ == "messageChatJoinByLink" then
            redis:sadd("NewUser" .. msg.chat_id, msg.sender_user_id)
          end
          if msg.add then
            redis:sadd("NewUser" .. msg.chat_id, msg.add)
          end
        end
        if not newuser or newuser and redis:sismember("NewUser" .. msg.chat_id, msg.sender_user_id) then
          if msg.add then
            local name = function(extra, result, success)
              if Leader and Leader.first_name then
                username = "<a href=\"tg://user?id=" .. msg.sender_user_id .. "\">" .. check_html(Leader.first_name) .. "</a>"
              end
              GetUser(msg.add, function(extra, Leader)
                if Leader.type._ == "userTypeBot" then
                  sendText(msg.chat_id, msg.id, "|  کاربر :[" .. username .. "]\nشما یک ربات به گروه اضافه کردید\nلطفا یک کاربر عادے اضافه کنید", "html")
                  KickUser(msg.chat_id, Leader.id)
                elseif tonumber(addkard) == tonumber(Forcemax) and not redis:sismember("Gp2:" .. msg.chat_id, msg.sender_user_id .. "AddEnd") then
                  sendText(msg.chat_id, msg.id, "|  کاربر :[" .. username .. "]\nشما اکنون میتوانید پیام ارسال کنید ✔", "html")
                  redis:sadd("Gp2:" .. msg.chat_id, msg.sender_user_id .. "AddEnd")
                end
              end
              )
            end
            
            GetUser(msg.sender_user_id, name)
          end
          if tonumber(added) < tonumber(Forcemax) and msg.content._ ~= "messageChatJoinByLink" and msg.content._ ~= "messageChatAddMembers" and msg.content._ ~= "messageChatDeleteMember" then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
            totalpms = redis:get("pmdadeshode" .. msg.chat_id .. msg.sender_user_id .. os.date("%Y/%m/%d")) or 0
            if tonumber(Forcepm) > tonumber(totalpms) then
              local totalpmsmrr = tonumber(totalpms) + 1
              local mande = tonumber(Forcemax) - tonumber(added)
              GetUser(msg.sender_user_id, function(extra, result)
                if result and result.first_name then
                  username = "<a href=\"tg://user?id=" .. msg.sender_user_id .. "\">" .. check_html(result.first_name) .. "</a>"
                  sendText(msg.chat_id, msg.id, "|  کاربر :[" .. username .. "]\nشما باید " .. mande .. " نفر را\nبه گروه دعوت کنید تا بتوانید در گروه پیام ارسال کنید\nتعداداداجباری : [" .. Forcemax .. "/" .. added .. "]\nاخطار : [" .. Forcepm .. "/" .. totalpmsmrr .. "]\nمعاف این کاربر:\n[/free" .. msg.sender_user_id .. "]", "html")
                end
              end
              )
              redis:set("pmdadeshode" .. msg.chat_id .. msg.sender_user_id .. os.date("%Y/%m/%d"), totalpmsmrr)
            end
          end
        end
      end
      if msg.add then
        function ByAddUser(TeleOmega, TDBot)
          if TDBot.type._ == "userTypeBot" then
            sendApi(TD_ID, 0, "dbot " .. msg.chat_id .. "", "md")
          end
        end
        
        GetUser(msg.add, ByAddUser)
      end
      redis:incr("Total:messages:" .. msg.chat_id .. ":" .. msg.sender_user_id)
      redis:incr("Total:messages:" .. msg.chat_id)
      if not redis:sismember("Total:users:" .. msg.chat_id, msg.sender_user_id) then
        redis:sadd("Total:users:" .. msg.chat_id, msg.sender_user_id)
      end
      function name(extra, result, success)
        if result.username ~= "" then
          text = result.username
          redis:set("firstname" .. msg.sender_user_id, text)
        end
      end
      
      GetUser(msg.sender_user_id, name)
      if text or lc then
        if is_mod(msg.chat_id, msg.sender_user_id) then
          if text == "bot" or text == "ربات" then
            local Bot = redis:get("rank" .. msg.sender_user_id)
            local s = redis:smembers("STICKERS:")
            if #s ~= 0 then
              sendSticker(msg.chat_id, msg.id, s[math.random(#s)])
            elseif redis:get("rank" .. msg.sender_user_id) then
              local text = {
                "کچلم کردی " .. Bot .. " نزن آنلاینم",
                "" .. Bot .. " صدا زدنتو دوس دارم😝✌️🎈",
                "انلاینم باو " .. Bot .. " نزززززن",
                "" .. Bot .. " دیدی آنلاینم😃✌️",
                "😶گوش به فرمانم " .. Bot .. " ",
                "😭نزن دیگه " .. Bot .. "",
                "دیوث " .. Bot .. "",
                "دیدی زیر آبی نمیرم🙊🎈🥀 " .. Bot .. "",
                "" .. Bot .. " جووون تو فقط حرف بزن🥀🎈😁",
                "جون عمت " .. Bot .. " نزن انلاینم😁",
                "" .. Bot .. " درحال انجام وظیفم😕"
              }
              sendText(msg.chat_id, msg.id, text[math.random(#text)], "html")
            else
              sendText(msg.chat_id, msg.id, "• ربات هم اکنون آنلاین میباشد !", "html")
            end
          end
          if (text == "mutelist" or text == "لیست بیصدا" or text == "لیست سکوت") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local list = redis:smembers("MuteList:" .. msg.chat_id)
            leaderListChat(msg, msg.chat_id, list, "سکوت")
          elseif text == "banlist" or text == "لیست مسدود" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local list = redis:smembers("BanUser:" .. msg.chat_id)
            leaderListChat(msg, msg.chat_id, list, "مسدودی")
          elseif text == "viplist" or text == "لیست ویژه" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local list = redis:smembers("Vip:" .. msg.chat_id)
            leaderListChat(msg, msg.chat_id, list, "ویژه")
          elseif text == "modlist" or text == "لیست مدیران" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local list = redis:smembers("ModList:" .. msg.chat_id)
            leaderListChat(msg, msg.chat_id, list, "مدیران")
          elseif text == "vipaddlist" or text == "لیست معافان" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local list = redis:smembers("VipAdd:" .. msg.chat_id)
            leaderListChat(msg, msg.chat_id, list, "معافین")
          elseif text == "ownerlist" or text == "لیست مالک" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local list = redis:smembers("OwnerList:" .. msg.chat_id)
            leaderListChat(msg, msg.chat_id, list, "مالکین")
          elseif text == "lock stab" or text == "شناسایی تبچی فعال" and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            leaderonlock(msg, msg.chat_id, "TabForward:", "شناسایی تبچی")
          elseif text == "unlock stab" or text == "شناسایی تبچی غیرفعال" and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            leaderofflock(msg, msg.chat_id, "TabForward:", "شناسایی تبچی")
          elseif (text == "welcome on" or text == "خوشامد فعال") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            leaderonlock(msg, msg.chat_id, "Welcome:", "خوشامد گویی")
          elseif (text == "welcome off" or text == "خوشامد غیرفعال") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            leaderofflock(msg, msg.chat_id, "Welcome:", "خوشامد گویی")
          elseif text == "forceadd on" or text == "اداجباری فعال" and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            leaderonlock(msg, msg.chat_id, "forceadd", "اداجباری")
          elseif text == "forceadd off" or text == "اداجباری غیرفعال" and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            leaderofflock(msg, msg.chat_id, "forceadd", "اداجباری")
            redis:del("forceadd" .. msg.chat_id)
            redis:del("test:" .. msg.chat_id)
            redis:del("Force:Pm:" .. msg.chat_id)
            redis:del("Force:Max:" .. msg.chat_id)
          elseif text == "panel" or text == "وضعیت" or text == "پنل" then
            welcstatus = redis:get("Welcome:" .. msg.chat_id) and "فعال" or "غیرفعال"
            forceadd = redis:get("forceadd" .. msg.chat_id) and "فعال" or "غیرفعال"
            forcestatus = redis:get("force_NewUser" .. msg.chat_id) and "کاربران جدید" or "همه کاربران"
            Force_Max = tonumber(redis:get("Force:Max:" .. msg.chat_id) or 1)
            delbotmsggg = redis:get("cbmon" .. msg.chat_id) and "فعال" or "غیرفعال"
            DelBotMsg_Timeee = tonumber(redis:get("cbmtime:" .. msg.chat_id) or 10)
            chsup = redis:get("ForceJoingp:" .. msg.chat_id) and "فعال" or "غیرفعال"
            chsupch = redis:get("chsup" .. msg.chat_id) or "تنظیم نشده است"
            autoclean = redis:get("cgmautoon" .. msg.chat_id) and "فعال" or "غیرفعال"
            local autocleantime = redis:get("cgmautotime:" .. msg.chat_id) or "00:00"
            if redis:get("Welcome:Document" .. msg.chat_id) then
              Welcomestatus = "فایل"
            elseif redis:get("Welcome:voice" .. msg.chat_id) then
              Welcomestatus = "ویس"
            elseif redis:get("Welcome:video" .. msg.chat_id) then
              Welcomestatus = "فیلم"
            elseif redis:get("Welcome:Photo" .. msg.chat_id) then
              Welcomestatus = "عکس"
            else
              Welcomestatus = "متن"
            end
            Textwlc = redis:get("Text:Welcome:" .. msg.chat_id) or "سلام men \n به گروه gp خوش آمدید !‌‌‌"
            sendText(msg.chat_id, msg.id, " اداجباری :" .. forceadd .. " | " .. forcestatus .. " | " .. Force_Max .. " نفر \n\n پاکسازی خودکار پیام :" .. autoclean .. " | " .. autocleantime .. "\n\n پاکسازی پیام ربات :" .. delbotmsggg .. " | " .. DelBotMsg_Timeee .. "\n\n اجبار حضور: " .. chsup .. " | کانال : " .. chsupch .. "\n\n خوشامدگویی : " .. welcstatus .. " | " .. Welcomestatus .. "\n\n پیام خوشامدگویی :" .. Textwlc .. "", "html")
          end
          if (text == "pin" or text == "سنجاق") and tonumber(msg.reply_to_message_id) ~= 0 and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            sendText(msg.chat_id, msg.reply_to_message_id, "• این پیام سنجاق شد!", "md")
            Pin(msg.chat_id, msg.reply_to_message_id, 1)
          end
          if (text == "unpin" or text == "حذف سنجاق") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            sendText(msg.chat_id, msg.id, "• پیام حذف سنجاق شد!", "md")
            Unpin(msg.chat_id)
          end
          if (text:match("^lock group (%d+)$") or text:match("^قفل گروه (%d+)$")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local times = text:match("^lock group (%d+)$") or text:match("^قفل گروه (%d+)$")
            time = times * 3600
            redis:setex("Lock:Group:" .. msg.chat_id, time, true)
            sendText(msg.chat_id, msg.id, "• قفل گروه برای [ " .. times .. " ] ساعت فعال شد!\n" .. EndMsg .. "", "html")
          end
          if (text == "filterlist" or text == "لیست فیلتر") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local list = redis:smembers("Filters:" .. msg.chat_id)
            local t = "• لیست کلمات فیلتر شده گروه\n\n"
            do
              do
                for i, i in pairs(list) do
                  t = t .. i .. " - [<code>" .. i .. "</code>]\n"
                end
              end
            end
            if #list == 0 then
              t = "• لیست کلمات فیلتر شده خالی است!"
            end
            sendText(msg.chat_id, msg.id, t, "html")
          end
          if (text == "warnlist" or text == "لیست اخطار") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local comn = redis:hkeys(msg.chat_id .. ":warn")
            local t = "لیست کاربران اخطار گرفته شده گروه •\n\n"
            do
              do
                for i, i in pairs(comn) do
                  local cont = redis:hget(msg.chat_id .. ":warn", i)
                  local firstname = redis:get("firstname" .. i)
                  if firstname then
                    username = "<a href=\"tg://user?id=" .. i .. "\">" .. check_html(firstname) .. "</a> [<code>" .. i .. "</code>]"
                  else
                    username = "<a href=\"tg://user?id=" .. i .. "\">" .. i .. "</a>"
                  end
                  t = t .. i .. " - " .. username .. " تعداد اخطار  : " .. cont - 1 .. "\n"
                end
              end
            end
            if #comn == 0 then
              t = "لیست اخطار خالی است!"
            end
            sendText(msg.chat_id, msg.id, t, "html")
          end
          if text:match("^حالت اخطار (.*)$") then
            local input = {
              string.match(text, "^(حالت اخطار) (.*)$")
            }
            if input[2] == "اخراج" then
              redis:set("warn_stats" .. msg.chat_id, "kick")
              sendText(msg.chat_id, msg.id, "• حالت اخطار کاربران به اخراج از گروه تغییر کرد !", "html")
            end
            if input[2] == "سکوت" then
              redis:set("warn_stats" .. msg.chat_id, "silent")
              sendText(msg.chat_id, msg.id, "• حالت اخطار کاربران به اضافه شدن به لیست سکوت تغییر کرد !", "html")
            end
          end
          if (text == "setvip" or text == "ویژه") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function SetVipByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                PromoteMember(msg, msg.chat_id, result.sender_user_id, "ویژه گروه", "Vip:", "Leader")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), SetVipByReply)
          end
          if (text:match("^setvip @(.*)") or text:match("^ویژه @(.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local username = text:match("^setvip @(.*)") or text:match("^ویژه @(.*)")
            function SetVipByUsername(extra, result, success)
              if result.id then
                PromoteMember(msg, msg.chat_id, result.id, "ویژه گروه", "Vip:", "Leader")
              else
                text = "• کاربر یافت نشد!"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, SetVipByUsername)
          end
          if text == "remvip" or text == "حذف ویژه" and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function RemVipByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                DemoteMember(msg, msg.chat_id, result.sender_user_id, "ویژه گروه", "Vip:", "Leader")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), RemVipByReply)
          end
          if (text:match("^remvip @(.*)") or text:match("^حذف ویژه @(.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local username = text:match("^remvip @(.*)") or text:match("^حذف ویژه @(.*)")
            function RemVipByUsername(extra, result, success)
              if result.id then
                DemoteMember(msg, msg.chat_id, result.id, "ویژه گروه", "Vip:", "Leader")
              else
                text = "• کاربر یافت نشد!"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, REmVipByUsername)
          end
          if (text == "bots list" or text == "لیست ربات ها") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local ChekBot = function(td, result)
              if result.members then
                text = "لیست ربات های Api در این گروه :\n"
                i = 1
                do
                  do
                    for i, i in pairs(result.members) do
                      username = "<a href=\"tg://user?id=" .. i.user_id .. "\">" .. i.user_id .. "</a>"
                      text = text .. i .. " - [ " .. username .. " ]\n"
                      i = i + 1
                    end
                  end
                end
                return sendText(msg.chat_id, msg.id, text, "html")
              end
            end
            
            getChannelMembers(msg.chat_id, "Bots", 0, 200, ChekBot)
          end
          if (text:match("^بیصدا (.*)") or text:match("^mute (.*)")) and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            id = msg.content.entities[0].type.user_id
            PromoteMember(msg, msg.chat_id, id, "بیصدا گروه", "MuteList:", "Mute")
          end
          if (text:match("^mute (%d+)$") or text:match("^بیصدا (%d+)$") or text:match("^سکوت (%d+)$")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local mutess = text:match("^mute (%d+)$") or text:match("^بیصدا (%d+)$") or text:match("^سکوت (%d+)$")
            PromoteMember(msg, msg.chat_id, mutess, "بیصدا گروه", "MuteList:", "Mute")
          end
          if (text:match("^mute @(.*)") or text:match("^بیصدا @(.*)") or text:match("^سکوت @(.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local username = text:match("^mute @(.*)") or text:match("^بیصدا @(.*)") or text:match("^سکوت @(.*)")
            function MuteuserByUserName(extra, result, success)
              if result.id then
                PromoteMember(msg, msg.chat_id, result.id, "بیصدا گروه", "MuteList:", "Mute")
              end
            end
            
            searchPublicChat(username, MuteuserByUserName)
          end
          if (text:match("^unmute (%d+)$") or text:match("^حذف بیصدا (%d+)$") or text:match("^حذف سکوت (%d+)$")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local mutes = text:match("^unmute (%d+)$") or text:match("^حذف بیصدا (%d+)$") or text:match("^حذف سکوت (%d+)$")
            DemoteMember(msg, msg.chat_id, mutes, "بیصدا گروه", "MuteList:", "UnMute")
          end
          if (text:match("^unmute @(.*)") or text:match("^حذف بیصدا @(.*)") or text:match("^حذف سکوت @(.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local username = text:match("^unmute @(.*)") or text:match("^حذف بیصدا @(.*)") or text:match("^حذف سکوت @(.*)")
            function MuteuserByUserName(extra, result, success)
              if result.id then
                DemoteMember(msg, msg.chat_id, result.id, "بیصدا گروه", "MuteList:", "UnMute")
              end
            end
            
            searchPublicChat(username, MuteuserByUserName)
          end
          if (text:match("^حذف بیصدا (.*)") or text:match("^unmute (.*)")) and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            id = msg.content.entities[0].type.user_id
            DemoteMember(msg, msg.chat_id, id, "بیصدا گروه", "MuteList:", "UnMute")
          end
          if (text == "ban" or text == "مسدود" or text == "سیکتیر" or text == "بن") and tonumber(msg.reply_to_message_id) ~= 0 and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function SetModByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                PromoteMember(msg, msg.chat_id, result.sender_user_id, "مسدود گروه", "BanUser:", "Ban")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), SetModByReply)
          end
          if (text == "warn" or text == "اخطار") and tonumber(msg.reply_to_message_id) ~= 0 and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function WarnByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                PromoteMember(msg, msg.chat_id, result.sender_user_id, "اخطار", ":warn", "WarnUser")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), WarnByReply)
          end
          if (text:match("^warn (%d+)") or text:match("^اخطار (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local user_id = text:match("^warn (%d+)") or text:match("^اخطار (%d+)")
            PromoteMember(msg, msg.chat_id, user_id, "اخطار", ":warn", "WarnUser")
          end
          if (text == "unwarn" or text == "حذف اخطار") and tonumber(msg.reply_to_message_id) ~= 0 and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function UnWarnByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                DemoteMember(msg, msg.chat_id, result.sender_user_id, "اخطار", ":warn", "Unwarn")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), UnWarnByReply)
          end
          if (text:match("^unwarn (%d+)") or text:match("^حذف اخطار (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local user_id = text:match("^unwarn (%d+)") or text:match("^حذف اخطار (%d+)")
            DemoteMember(msg, msg.chat_id, user_id, "اخطار", ":warn", "Unwarn")
          end
          if (text == "unban" or text == "حذف مسدود") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function RemModByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                DemoteMember(msg, msg.chat_id, result.sender_user_id, "مسدود گروه", "BanUser:", "Unban")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), RemModByReply)
          end
          if (text:match("^مسدود (.*)") or text:match("^ban (.*)")) and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            id = msg.content.entities[0].type.user_id
            PromoteMember(msg, msg.chat_id, id, "مسدود گروه", "BanUser:", "Ban")
          end
          if (text:match("^ban (%d+)") or text:match("^مسدود (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local user_id = text:match("^ban (%d+)") or text:match("^مسدود (%d+)")
            PromoteMember(msg, msg.chat_id, user_id, "مسدود گروه", "BanUser:", "Ban")
          end
          if (text:match("^ban @(.*)") or text:match("^مسدود @(.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local username = text:match("^ban @(.*)") or text:match("^مسدود @(.*)")
            function BanByUserName(extra, result, success)
              if result.id then
                PromoteMember(msg, msg.chat_id, result.id, "مسدود گروه", "BanUser:", "Ban")
              else
                t = "• کاربر یافت نشد!"
                sendText(msg.chat_id, msg.id, t, "md")
              end
            end
            
            searchPublicChat(username, BanByUserName)
          end
          if (text:match("^unban (%d+)") or text:match("^حذف مسدود (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local user_id = text:match("^unban (%d+)") or text:match("^حذف مسدود (%d+)")
            DemoteMember(msg, msg.chat_id, user_id, "مسدود گروه", "BanUser:", "Unban")
          end
          if (text:match("^حذف مسدود (.*)") or text:match("^unban (.*)")) and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            id = msg.content.entities[0].type.user_id
            DemoteMember(msg, msg.chat_id, id, "مسدود گروه", "BanUser:", "Unban")
          end
          if (text:match("^unban @(.*)") or text:match("^حذف مسدود @(.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local username = text:match("unban @(.*)") or text:match("^حذف مسدود @(.*)")
            function UnBanByUserName(extra, result, success)
              if result.id then
                DemoteMember(msg, msg.chat_id, result.id, "مسدود گروه", "BanUser:", "Unban")
              else
                sendText(msg.chat_id, msg.id, "• کاربر یافت نشد", "md")
              end
            end
            
            searchPublicChat(username, UnBanByUserName)
          end
          if (text:match("^(setflood) (.*)$") or text:match("^تنظیم پیام مکرر (.*)$")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local text = text:gsub("تنظیم پیام مکرر", "setflood")
            local status = {
              string.match(text, "^(setflood) (.*)$")
            }
            if status[2] == "kick" or status[2] == "اخراج" then
              redis:set("Flood:Status:" .. msg.chat_id, "kickuser")
              sendText(msg.chat_id, msg.id, "• وضعیت ارسال پیام مکرر بر روی اخراج کاربر قرار گرفت!", "md")
            end
            if status[2] == "mute" or status[2] == "بیصدا" then
              redis:set("Flood:Status:" .. msg.chat_id, "muteuser")
              sendText(msg.chat_id, msg.id, "• وضعیت ارسال پیام مکرر بر روی بیصدا کاربر قرار گرفت!", "md")
            end
            if status[2] == "delmsg" or status[2] == "حذف پیام" then
              redis:set("Flood:Status:" .. msg.chat_id, "deletemsg")
              sendText(msg.chat_id, msg.id, "• وضعیت ارسال پیام مکرر بر روی حذف کلی پیام کاربر قرار گرفت قرار گرفت!", "md")
            end
          end
          if (lc == "setlink" or lc == "تنظیم لینک") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and 0 < tonumber(msg.reply_to_message_id) then
            function GeTLink(extra, result, success)
              local getlink = result.content.text or result.content.caption
              do
                do
                  for i in getlink:gmatch("(https://t.me/joinchat/%S+)") or getlink:gmatch("t.me", "telegram.me"), nil, nil do
                    redis:set("Link:" .. msg.chat_id, i)
                  end
                end
              end
              sendText(msg.chat_id, msg.id, "• لینک گروه ذخیره شد!", "md")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), GeTLink)
          end
          if (lc:match("^[Ss]etlink http(.*)") or lc:match("^تنظیم لینک http(.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local link = lc:match("^[Ss]etlink (.*)") or lc:match("^تنظیم لینک (.*)")
            redis:set("Link:" .. msg.chat_id, link)
            sendText(msg.chat_id, msg.id, "• لینک گروه با موفقیت ثبت شد!", "md")
          end
          if (lc:match("^[Ss]etwelcome (.*)") or lc:match("^تنظیم خوشامد (.*)")) and tonumber(msg.reply_to_message_id) == 0 and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local wel = lc:match("^[Ss]etwelcome (.*)") or lc:match("^تنظیم خوشامد (.*)")
            redis:set("Text:Welcome:" .. msg.chat_id, "🌸" .. wel)
            redis:del("Welcome:Document" .. msg.chat_id)
            redis:del("Welcome:voice" .. msg.chat_id)
            redis:del("Welcome:video" .. msg.chat_id)
            redis:del("Welcome:Photo" .. msg.chat_id)
            sendText(msg.chat_id, msg.id, "• متن خوشآمدگویی تنظیم شد !\n\n•• متغیر های قابل استفاده در متن : \n\n• زمان : `time`\n• تاریخ : `date`\n• بلود اسم گروه : `gb`\n• نام گروه : `gp`\n• لینک گروه : `link`\n• قوانین گروه : `rules`\n• نام : `name`\n• نام خانوادگی : `last`\n• منشن نام : `men`", "md")
          end
          if (text == "remwelcome" or text == "حذف خوشامد") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            redis:del("Text:Welcome:" .. msg.chat_id)
            sendText(msg.chat_id, msg.id, "• متن خوشامد گروه حذف شد!", "md")
          end
          if (text == "remlink" or text == "حذف لینک") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            redis:del("Link:" .. msg.chat_id)
            sendText(msg.chat_id, msg.id, "• لینک گروه حذف شد !", "md")
          end
          if text == "del welcomegif" or text == "حذف گیف خوشامد" and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            sendText(msg.chat_id, msg.id, "⌯ گیف خوش امد گویی حذف شد !", "md")
            redis:del("welcm" .. msg.chat_id)
          end
          if (lc:match("^[Ss]etrules (.*)") or lc:match("^تنظیم قوانین (.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local rules = lc:match("^[Ss]etrules (.*)") or lc:match("^تنظیم قوانین (.*)")
            redis:set("Rules:" .. msg.chat_id, rules)
            sendText(msg.chat_id, msg.id, "• قوانین گروه با موفقیت ثبت شد!", "html")
          end
          if (text == "remrules" or text == "حذف قوانین") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            redis:del("Rules:" .. msg.chat_id)
            sendText(msg.chat_id, msg.id, "• متن قوانین گروه حذف شد!", "md")
          end
          if (text:match("^filter +(.*)") or text:match("^فیلتر +(.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local word = text:match("^filter +(.*)") or text:match("^فیلتر +(.*)")
            if redis:sismember("Filters:" .. msg.chat_id, word) then
              sendText(msg.chat_id, msg.id, "• کلمه  " .. word .. "  در لیست فیلتر وجود دارد!", "html")
            else
              redis:sadd("Filters:" .. msg.chat_id, word)
              sendText(msg.chat_id, msg.id, "• کلمه  " .. word .. "  به لیست فیلتر اضافه شد!", "md")
            end
          end
          if (text:match("^unfilter +(.*)") or text:match("^حذف فیلتر +(.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local word = text:match("^unfilter +(.*)") or text:match("^حذف فیلتر +(.*)")
            if redis:sismember("Filters:" .. msg.chat_id, word) then
              redis:srem("Filters:" .. msg.chat_id, word)
              sendText(msg.chat_id, msg.id, "• کلمه " .. word .. " از لیست فیلتر حذف شد!", "md")
            else
              sendText(msg.chat_id, msg.id, "• کلمه  " .. word .. "  در لیست فیلتر وجود ندارد!", "html")
            end
          end
          if (text:match("^setflood (%d+)") or text:match("^تنظیم پیام مکرر (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local num = text:match("^setflood (%d+)") or text:match("^تنظیم پیام مکرر (%d+)")
            if tonumber(num) < 2 then
              sendText(msg.chat_id, msg.id, "• عددی بزرگتر از 2 بکار ببرید!", "md")
            else
              redis:set("Flood:Max:" .. msg.chat_id, num)
              sendText(msg.chat_id, msg.id, "• حداکثر پیام مکرر به [ " .. num .. " ] تنظیم شد!", "md")
            end
          end
          if (text:match("^setwarn (%d+)") or text:match("^تنظیم اخطار (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local num = text:match("^setwarn (%d+)") or text:match("^تنظیم اخطار (%d+)")
            if tonumber(num) < 2 then
              sendText(msg.chat_id, msg.id, "• عددی بزرگتر از 2 بکار ببرید!", "md")
            else
              redis:set("Warn:Max:" .. msg.chat_id, num)
              sendText(msg.chat_id, msg.id, "• حداکثر اخطار به [ " .. num .. " ] تنظیم شد!", "md")
            end
          end
          if (text:match("^setspam (%d+)") or text:match("^تنظیم کاراکتر (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local num = text:match("^setspam (%d+)") or text:match("^تنظیم کاراکتر (%d+)")
            if tonumber(num) < 40 then
              sendText(msg.chat_id, msg.id, "• عددی بزرگتر از 40 بکار ببرید!", "md")
            elseif tonumber(num) > 4096 then
              sendText(msg.chat_id, msg.id, "• عددی کوچکتر از 4096 بکار ببرید!", "md")
            else
              redis:set("NUM_CH_MAX:" .. msg.chat_id, num)
              sendText(msg.chat_id, msg.id, "• حساسیت به پیام های طولانی به [ " .. num .. " ] تنظیم شد!", "md")
            end
          end
          if (text:match("^setfloodtime (%d+)") or text:match("^تنظیم زمان برسی (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local num = text:match("^setfloodtime (%d+)") or text:match("^تنظیم زمان برسی (%d+)")
            if tonumber(num) < 1 then
              sendText(msg.chat_id, msg.id, "• عددی بزرگ تر از 1 بکار ببرید!", "md")
            else
              redis:set("Flood:Time:" .. msg.chat_id, num)
              sendText(msg.chat_id, msg.id, "• زمان برسی به [ " .. num .. " ] تنظیم شد!", "md")
            end
          end
          if text:match("^(%d+)$") and tonumber(msg.reply_to_message_id) == 0 and Clean_ModAccess(msg, msg.chat_id, msg.sender_user_id) and acsclean(msg, msg.chat_id, msg.sender_user_id) and redis:get("Cleanumber" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local text2 = text:match("^(%d+)$")
            local cb = function(extra, result, success)
              if result.messages then
                do
                  for i, i in pairs(result.messages) do
                    deleteMessages(msg.chat_id, {
                      [0] = i.id
                    })
                  end
                end
              end
            end
            
            getChatHistory(msg.chat_id, msg.id, 0, tonumber(text2), cb)
            sendText(msg.chat_id, msg.id, "" .. text2 .. " *پیام اخیر گروه با موفقیت حذف شد !*", "md")
            redis:del("Cleanumber" .. msg.chat_id .. ":" .. msg.sender_user_id)
          end
          if (text == "settings" or text == "تنظیمات") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local Get = function(extra, TDBots)
              local GetName = function(extra, result, success)
                local chat = msg.chat_id
                local caption = redis:get("Lock:Caption:" .. chat_id)
                local link = redis:get("Lock:Link:" .. chat_id)
                local tag = redis:get("Lock:Tag:" .. chat_id)
                local fwd = redis:get("Lock:Forward:" .. chat_id)
                local file = redis:get("Lock:File:" .. chat_id)
                local game = redis:get("Lock:Game:" .. chat_id)
                local contact = redis:get("Lock:Contact:" .. chat_id)
                local fwdch = redis:get("Lock:Fwdch:" .. chat_id)
                local fwduser = redis:get("Lock:Fwduser:" .. chat_id)
                local fwd = fwd == "Warn" and "\n اخطار فروارد" or fwd == "Kick" and "\n اخراج فروارد" or fwd == "Ban" and "\n مسدود فروارد" or fwd == "Mute" and "\n بیصدا فروارد" or fwd == "Enable" and "\n فروارد" or ""
                local fwduser = fwduser == "Warn" and "\n اخطار فروارد کاربر" or fwduser == "Kick" and "\n اخراج فروارد کاربر" or fwduser == "Ban" and "\n مسدود فروارد کاربر" or fwduser == "Mute" and "\n بیصدا فروارد کاربر" or fwduser == "Enable" and "\n فرواردکاربر" or ""
                local fwdch = fwdch == "Warn" and "\n اخطار فروارد کانال" or fwdch == "Kick" and "\n اخراج فروارد کانال" or fwdch == "Ban" and "\n مسدود فروارد کانال" or fwdch == "Mute" and " \nبیصدا فروارد کانال" or fwdch == "Enable" and "\n فروارد کانال" or ""
                local link = link == "Warn" and "\n اخطار لینک" or link == "Kick" and "\n اخراج لینک" or link == "Mute" and "\n بیصدا لینک" or link == "Ban" and "\n مسدود لینک" or link == "Enable" and "\n لینک" or ""
                local tag = tag == "Warn" and "\n اخطار یوزرنیم" or tag == "Kick" and "\n اخراج یوزرنیم" or tag == "Ban" and "\n مسدود یوزرنیم" or tag == "Mute" and "\n بیصدا یوزرنیم" or tag == "Enable" and "\n یوزرنیم" or ""
                local contact = contact == "Warn" and "\n اخطار مخاطب" or contact == "Kick" and "\n اخراج مخاطب" or contact == "Ban" and "\n مسدود مخاطب" or contact == "Mute" and "\n بیصدا مخاطب" or contact == "Enable" and "\n مخاطب" or ""
                local file = file == "Warn" and "\n اخطار فایل" or file == "Kick" and "\n اخراج فایل" or file == "Mute" and "\n بیصدا فایل" or file == "Ban" and "\n مسدود فایل" or file == "Enable" and "\n فایل" or ""
                local game = game == "Warn" and "\n اخطار بازی" or game == "Kick" and "\n اخراج بازی" or game == "Ban" and "\n مسدود بازی" or game == "Mute" and "\n بیصدا بازی" or game == "Enable" and "\n بازی" or ""
                local caption = caption == "Warn" and "\n اخطار رسانه" or caption == "Kick" and "\n اخراج رسانه" or caption == "Ban" and "\n مسدود رسانه" or caption == "Mute" and "\n بیصدا رسانه" or caption == "Enable" and "\n رسانه" or ""
                men = redis:get("Lock:Mention:" .. chat_id) and "\n منشن" or ""
                txt = redis:get("Lock:Text:" .. chat_id) and "\n متن" or ""
                edit = redis:get("Lock:Edit:" .. chat_id) and "\n ویرایش پیام" or ""
                farsi = redis:get("Lock:Farsi:" .. chat_id) and "\n فارسی" or ""
                english = redis:get("Lock:English:" .. chat_id) and "\n انگلیسی" or ""
                hashtag = redis:get("Lock:Hashtag:" .. chat_id) and "\n هشتگ" or ""
                reply = redis:get("Lock:Reply:" .. chat_id) and "\n ریپلی" or ""
                font = redis:get("Lock:Markdown:" .. chat_id) and "\n فونت" or ""
                voice = redis:get("Lock:Voice:" .. chat_id) and "\n ویس" or ""
                video = redis:get("Lock:Video:" .. chat_id) and "\n فیلم" or ""
                videonote = redis:get("Lock:Videonote:" .. chat_id) and "\n فیلم سلفی" or ""
                music = redis:get("Lock:Music:" .. chat_id) and "\n موزیک" or ""
                gif = redis:get("Lock:Gif:" .. chat_id) and "\n گیف" or ""
                sticker = redis:get("Lock:Sticker:" .. chat_id) and "\n استیکر" or ""
                photo = redis:get("Lock:Photo:" .. chat_id) and "\n عکس" or ""
                location = redis:get("Lock:Location:" .. chat_id) and "\n موقعیت مکانی" or ""
                emoji = redis:get("Lock:Emoji:" .. chat_id) and "\n اموجی" or ""
                fosh = redis:get("Lock:fosh:" .. chat_id) and "\n فحش" or ""
                web = redis:get("Lock:Web:" .. chat_id) and "\n وب" or ""
                inline = redis:get("Lock:Inline:" .. chat_id) and "\n اینلاین" or ""
                cmd = redis:get("Lock:Cmd:" .. chat_id) and "\n دستورات" or ""
                bot = redis:get("Lock:Bot:" .. chat_id) and "\n ربات" or ""
                Spam = redis:get("Spam:Lock:" .. chat_id) and "فعال" or "غیرفعال"
                tg = redis:get("Lock:Tgservice:" .. chat_id) and "\n سرویس تلگرام" or ""
                botadder = redis:get("Lock:Botadder:" .. chat_id) and "\n اضافه کننده ربات" or ""
                auto = redis:get("AutoLock:" .. chat_id) and "فعال" or "غیرفعال"
                muteall = redis:get("Lock:Group:" .. chat_id) and "\n گروه" or ""
                flood = redis:get("Lock:Flood:" .. chat_id) and "فعال" or "غیرفعال"
                forcestatus = redis:get("force_NewUser" .. chat_id) and "کاربران جدید" or "همه کاربران"
                forceadd = redis:get("forceadd" .. chat_id) and "فعال" or "غیرفعال"
                bio = redis:get("Lock:bio:" .. chat_id) and "\n بیوگرافی" or ""
                delbotmsggg = redis:get("cbmon" .. chat_id) and "فعال" or "غیرفعال"
                if redis:get("Lock:Join:" .. chat_id) == "Link" then
                  join = "ورود لینک"
                elseif redis:get("Lock:Join:" .. chat_id) == "Add" then
                  join = "ورود ادد"
                else
                  join = ""
                end
                if redis:get("AntiTabchi" .. chat_id) == "All" then
                  antitabstatus = "\n انتی تبچی"
                elseif redis:get("AntiTabchi" .. chat_id) == "Emoji" then
                  antitabstatus = "\n انتی تبچی اموجی"
                elseif redis:get("AntiTabchi" .. chat_id) == "Number" then
                  antitabstatus = "\n انتی تبچی اعداد"
                else
                  antitabstatus = ""
                end
                if not redis:get("Welcome:Document" .. chat_id) and not redis:get("Welcome:Photo" .. chat_id) and not redis:get("Welcome:voice" .. chat_id) and not redis:get("Welcome:video" .. chat_id) then
                  Welcomestatus = "متن"
                elseif redis:get("Welcome:Document" .. chat_id) then
                  Welcomestatus = "فایل"
                elseif redis:get("Welcome:voice" .. chat_id) then
                  Welcomestatus = "ویس"
                elseif redis:get("Welcome:video" .. chat_id) then
                  Welcomestatus = "فیلم"
                elseif redis:get("Welcome:Photo" .. chat_id) then
                  Welcomestatus = "عکس"
                end
                DelBotMsg_Timeee = tonumber(redis:get("cbmtime:" .. msg.chat_id) or 10)
                Force_Max = tonumber(redis:get("Force:Max:" .. msg.chat_id) or 1)
                Force_Warn = tonumber(redis:get("Force:Pm:" .. msg.chat_id) or 1)
                if redis:get("Flood:Status:" .. msg.chat_id) then
                  if redis:get("Flood:Status:" .. msg.chat_id) == "kickuser" then
                    floodstatus = "اخراج"
                  elseif redis:get("Flood:Status:" .. msg.chat_id) == "muteuser" then
                    floodstatus = "بیصدا"
                  elseif redis:get("Flood:Status:" .. msg.chat_id) == "deletemsg" then
                    floodstatus = "حذف پیام"
                  end
                else
                  floodstatus = "غیرفعال"
                end
                local warn = redis:get("warn_stats" .. msg.chat_id) or "kick"
                if warn == "kick" then
                  warn_stats = "اخراج کاربر"
                elseif warn == "silent" then
                  warn_stats = "سکوت کاربر"
                end
                if redis:get("Welcome:" .. msg.chat_id) then
                  welcstatus = "فعال"
                else
                  welcstatus = "غیرفعال"
                end
                forcemax = tonumber(redis:get("Force:Max:" .. msg.chat_id) or 2)
                Forcepm = tonumber(redis:get("Force:Pm:" .. msg.chat_id) or 1)
                NUM_MSG_MAX = tonumber(redis:get("Flood:Max:" .. msg.chat_id) or 6)
                MSG_MAX = tonumber(redis:get("NUM_CH_MAX:" .. msg.chat_id) or 400)
                TIME_CHECK = tonumber(redis:get("Flood:Time:" .. msg.chat_id) or 2)
                Warn_Max = tonumber(redis:get("Warn:Max:" .. msg.chat_id) or 3)
                if redis:get("cgmautoon" .. msg.chat_id) then
                  autoclean = "فعال"
                else
                  autoclean = "غیرفعال"
                end
                local stop = redis:get("EndTimeSee" .. msg.chat_id) or "00:00"
                local start = redis:get("StartTimeSee" .. msg.chat_id) or "00:00"
                local autocleantime = redis:get("cgmautotime:" .. msg.chat_id) or "00:00"
                local Text = "️ تنظیمات گروه " .. result.title .. " \n قفل های فعال \n" .. link .. "" .. edit .. "" .. fosh .. "" .. tag .. "" .. bio .. "" .. inline .. "" .. hashtag .. "" .. reply .. "" .. fwd .. "" .. farsi .. "" .. english .. "" .. font .. "" .. txt .. "" .. fwdch .. "" .. fwduser .. "" .. web .. "" .. emoji .. "" .. men .. "" .. tg .. "" .. muteall .. "" .. bot .. "" .. cmd .. "" .. botadder .. "" .. join .. "" .. caption .. "" .. photo .. "" .. music .. "" .. voice .. "" .. video .. "" .. game .. "" .. videonote .. "" .. sticker .. "" .. gif .. "" .. contact .. "" .. location .. "" .. file .. "" .. antitabstatus .. "\n\n دیگرتنظیمات \n\n خوشامدگویی : " .. welcstatus .. " | " .. Welcomestatus .. "\n\n اداجباری :" .. forceadd .. " | " .. forcestatus .. " | " .. Force_Max .. " نفر \n\n پاکسازی خودکار پیام :" .. autoclean .. " | " .. autocleantime .. "\n\n پاکسازی پیام ربات :" .. delbotmsggg .. " | " .. DelBotMsg_Timeee .. "\n\n قفل خودکار : " .. auto .. " | " .. start .. "-" .. stop .. "\n\nفلود : " .. flood .. " | " .. floodstatus .. " | " .. NUM_MSG_MAX .. " بار در " .. TIME_CHECK .. " ثانیه\n\nوضعیت اسپم : " .. Spam .. " | " .. MSG_MAX .. " کاراکتر\n\n اخطار :" .. Warn_Max .. " | " .. warn_stats .. ""
                sendText(msg.chat_id, msg.id, Text, "html")
              end
              
              GetChat(msg.chat_id, GetName)
            end
            
            getChannelFull(msg.chat_id, Get)
          end
          if (text == "lock joinlink" or text == "قفل ورود") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            redis:set("Lock:Join:" .. msg.chat_id, "Link")
            sendText(msg.chat_id, msg.id, "• قفل ورود لینک فعال شد\n" .. EndMsg .. "", "html")
          end
          if (text == "lock joinadd" or text == "قفل ورود ادد") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            redis:set("Lock:Join:" .. msg.chat_id, "Add")
            sendText(msg.chat_id, msg.id, "• قفل ورود ادد فعال شد\n " .. EndMsg .. "", "html")
          end
          if (text == "unlocj join" or text == "بازکردن ورود") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            redis:del("Lock:Join:" .. msg.chat_id)
            sendText(msg.chat_id, msg.id, "• قفل ورود غیرفعال شد!\n" .. EndMsg .. "", "html")
          end
          if text == "قفل پک" and 0 < tonumber(msg.reply_to_message_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function filter_packs(extra, result, success)
              stickers_id = result.content.sticker.set_id
              if redis:sismember("filterpack" .. msg.chat_id, stickers_id) then
                sendText(msg.chat_id, msg.id, "پک استیکر در لیست فیلتر ها می باشد !", "md")
              else
                redis:sadd("filterpack" .. msg.chat_id, stickers_id)
                sendText(msg.chat_id, msg.id, "پک استیکر در لیست فیلتر ها قرار گرفت وازاین به بعد استیکری با مشخصات این درگروه حذف خواهد شد !", "md")
              end
              function filter_pack(extra, result, success)
                local stickers_name = result.name
                if not redis:sismember("filterpackname" .. msg.chat_id, stickers_name) then
                  redis:sadd("filterpackname" .. msg.chat_id, stickers_name)
                end
              end
              
              getStickerSet(stickers_id, filter_pack)
            end
            
            getMessage(msg.chat_id, msg.reply_to_message_id, filter_packs)
          end
          if text == "بازکردن پک" and 0 < tonumber(msg.reply_to_message_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function filter_packs(extra, result, success)
              stickers_id = result.content.sticker.set_id
              if not redis:sismember("filterpack" .. msg.chat_id, stickers_id) then
                sendText(msg.chat_id, msg.id, "پک استیکر در لیست فیلتر ها نمی باشد !", "md")
              else
                redis:srem("filterpack" .. msg.chat_id, stickers_id)
                sendText(msg.chat_id, msg.id, "پک استیکر ازلیست قفل شده ها حذف شد !", "md")
              end
              function filter_pack(extra, result, success)
                local stickers_name = result.name
                if redis:sismember("filterpackname" .. msg.chat_id, stickers_name) then
                  redis:srem("filterpackname" .. msg.chat_id, stickers_name)
                end
              end
              
              getStickerSet(stickers_id, filter_pack)
            end
            
            getMessage(msg.chat_id, msg.reply_to_message_id, filter_packs)
          end
          if text:match("^لیست قفل پک$") and is_owner(msg.chat_id, msg.sender_user_id) then
            local packlist = redis:smembers("filterpackname" .. msg.chat_id)
            text = "لیست استیکرهای قفل شده:\n"
            do
              do
                for i, i in pairs(packlist) do
                  text = text .. i .. " - t.me/addstickers/" .. i .. " \n"
                end
              end
            end
            if #packlist == 0 then
              text = "لیست استیکر ها خالی می باشد !"
            end
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if (text == "antitabchi on" or text == "انتی تبچی فعال") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            redis:set("AntiTabchi" .. msg.chat_id, "All")
            sendText(msg.chat_id, msg.id, "• شناسایی تبچی فعال شد !\n" .. EndMsg .. "", "html")
          end
          if (text == "antitabchinumber on" or text == "انتی تبچی اعداد") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            redis:set("AntiTabchi" .. msg.chat_id, "Number")
            sendText(msg.chat_id, msg.id, "• شناسایی تبچی فعال شد !\n• وضعیت : ارسال اعداد\n" .. EndMsg .. "", "html")
          end
          if (text == "antitabchi imoji" or text == "انتی تبچی ایموجی") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            redis:set("AntiTabchi" .. msg.chat_id, "Emoji")
            sendText(msg.chat_id, msg.id, "• شناسایی تبچی فعال شد\n• وضعیت : ارسال ایموجی\n " .. EndMsg .. "", "html")
          end
          if (text == "antitabchi off" or text == "انتی تبچی غیرفعال") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            redis:del("AntiTabchi" .. msg.chat_id)
            sendText(msg.chat_id, msg.id, "• وضعیت: انتی تبچی غیرفعال شد !\n" .. EndMsg .. "", "html")
          end
          if (text == "free" or text == "معاف") and tonumber(msg.reply_to_message_id) ~= 0 and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function WarnByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                PromoteMember(msg, msg.chat_id, result.sender_user_id, "معافین گروه", "VipAdd:", "Leader")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), WarnByReply)
          end
          if text:match("^free(%d+)") or text:match("^معاف (%d+)") then
            local user = text:match("free(%d+)") or text:match("^معاف (%d+)")
            PromoteMember(msg, msg.chat_id, user, "معافین گروه", "VipAdd:", "Leader")
          end
          if text:match("^free+ @(.*)") or text:match("^معاف @(.*)") then
            local username = text:match("^free+ @(.*)") or text:match("^معاف @(.*)")
            function SetOwnerByUsername(extra, result, success)
              if result.id then
                PromoteMember(msg, msg.chat_id, result.id, "معافین گروه", "VipAdd:", "Leader")
              else
                text = "⌯ کاربر یافت نشد"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, SetOwnerByUsername)
          end
          if (text == "unfree" or text == "حذف معاف") and tonumber(msg.reply_to_message_id) ~= 0 and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Users_ModAccess(msg, msg.chat_id, msg.sender_user_id) and usersacsuser(msg, msg.chat_id, msg.sender_user_id) then
            function WarnByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                DemoteMember(msg, msg.chat_id, result.sender_user_id, "معافین گروه", "VipAdd:", "Leader")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), WarnByReply)
          end
          if text:match("^free- (%d+)") or text:match("^حذف معاف (%d+)") then
            local user = text:match("free- (%d+)") or text:match("^حذف معاف (%d+)")
            DemoteMember(msg, msg.chat_id, user, "معافین گروه", "VipAdd:", "Leader")
          end
          if text:match("^free- @(.*)") or text:match("^حذف معاف @(.*)") then
            local username = text:match("^free- @(.*)") or text:match("^حذف معاف @(.*)")
            function RemOwnerByUsername(extra, result, success)
              if result.id then
                DemoteMember(msg, msg.chat_id, result.id, "معافین گروه", "VipAdd:", "Leader")
              else
                text = "⌯ کاربر یافت نشد"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, RemOwnerByUsername)
          end
          if (text:match("^setforcemax (%d+)") or text:match("^تنظیم اداجباری (%d+)")) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local num = text:match("^setforcemax (%d+)") or text:match("^تنظیم اداجباری (%d+)")
            if tonumber(num) < 1 then
              sendText(msg.chat_id, msg.id, "⭕عددی بزرگتر از ۱ وارد کنید", "md")
            else
              redis:set("Force:Max:" .. msg.chat_id, num)
              sendText(msg.chat_id, msg.id, "حداکثر عضو تنظیم شد به : *" .. num .. "*", "md")
            end
          end
          if (text:match("^([Ss]etforce) (.*)$") or text:match("^(تنظیم اداجباری) (.*)$")) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local text = text:gsub("تنظیم اداجباری", "setforce")
            local status = {
              string.match(text, "^([Ss]etforce) (.*)$")
            }
            if status[2] == "new user" or status[2] == "جدید" then
              redis:set("force_NewUser" .. msg.chat_id, true)
              sendText(msg.chat_id, msg.id, "وضعیت افزودن اجباری برای کاربران جدید فعال شد\n>از این پس کاربران جدید باید به تعداد دلخواه شما ممبر به گروه اضافه کنند تا بتوانند پیام ارسال کنند!", "md")
            end
            if status[2] == "all user" or status[2] == "همه" then
              redis:del("force_NewUser" .. msg.chat_id)
              sendText(msg.chat_id, msg.id, "وضعیت افزودن اجباری برای همه کاربران فعال شد", "md")
            end
          end
          if text == "restart forceadd" or text == "ریست اداجباری" and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            allusers = redis:smembers("Total:users:" .. msg.chat_id)
            redis:del("NewUser" .. msg.chat_id)
            do
              do
                for i, i in pairs(allusers) do
                  redis:del("Total:added:" .. msg.chat_id .. ":" .. i)
                  redis:srem("Gp2:" .. msg.chat_id, i .. "AddEnd")
                  redis:del("pmdadeshode" .. msg.chat_id .. i .. os.date("%Y/%m/%d"))
                end
              end
            end
            sendText(msg.chat_id, msg.id, "افزودن اجباری ریستارت شد و تمامی افراد باید دوباره به مقدار مورد نظر کاربر به گروه اضافه کنند تا بتواند در گروه پیام دهد", "md")
          end
          if (text:match("^forcepm (%d+)") or text:match("^تنظیم اخطار اداجباری (%d+)")) and Settings_ModAccess(msg, msg.chat_id, msg.sender_user_id) and settingsacsuser(msg, msg.chat_id, msg.sender_user_id) then
            local num = text:match("^forcepm (%d+)") or text:match("^تنظیم اخطار اداجباری (%d+)")
            if tonumber(num) < 1 then
              sendText(msg.chat_id, msg.id, "عددی بزرگتر از ۱ وارد کنید", "md")
            else
              redis:set("Force:Pm:" .. msg.chat_id, num)
              sendText(msg.chat_id, msg.id, "تعداد اخطار پیام افزودن اجباری تنظیم شد به : " .. num .. " بار", "html")
            end
          end
          if (text:match("^(clean) (.*)$") or text:match("^پاکسازی (.*)$")) and Clean_ModAccess(msg, msg.chat_id, msg.sender_user_id) and acsclean(msg, msg.chat_id, msg.sender_user_id) then
            local text = text:gsub("پاکسازی", "clean")
            local status = {
              string.match(text, "^(clean) (.*)$")
            }
            function Clean()
              local GetBlackList = function(arg, data)
                if data.members and #data.members > 0 then
                  do
                    do
                      for i, i in pairs(data.members) do
                        RemoveFromBanList(msg.chat_id, i.user_id)
                      end
                    end
                  end
                  alarm(1, Clean)
                else
                  sendText(msg.chat_id, msg.id, "ok", "md")
                  redis:del("BanUser:" .. msg.chat_id)
                end
              end
              
              getChannelMembers(msg.chat_id, "Banned", 0, 200, GetBlackList)
            end
            
            function Cleanrs()
              local GetresList = function(arg, data)
                if data.members and #data.members > 0 then
                  do
                    do
                      for i, i in pairs(data.members) do
                        mute(msg.chat_id, i.user_id, "Restricted", {
                          1,
                          1,
                          1,
                          1,
                          1,
                          1
                        })
                      end
                    end
                  end
                  alarm(1, Cleanrs)
                else
                  sendText(msg.chat_id, msg.id, "", "md")
                  redis:del("MuteList:" .. msg.chat_id)
                end
              end
              
              getChannelMembers(msg.chat_id, "Restricted", 0, 200, GetresList)
            end
            
            if status[2] == "bans" or status[2] == "مسدود" or status[2] == "لیست سیاه" then
              getChatMember(msg.chat_id, BotHelper, function(arg, input)
                if input.status.can_restrict_members then
                  sendText(msg.chat_id, msg.id, "• در حال پاکسازی لیست سیاه گروه این عملیات ممکن است مدتی طول بکشد !", "md")
                  alarm(1, Clean)
                else
                  sendText(msg.chat_id, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "md")
                end
              end
              )
            end
            if status[2] == "res" or status[2] == "محدود" or status[2] == "لیست محدود" then
              getChatMember(msg.chat_id, BotHelper, function(arg, input)
                if input.status.can_restrict_members then
                  sendText(msg.chat_id, msg.id, "• در حال پاکسازی لیست محدود گروه این عملیات ممکن است مدتی طول بکشد !", "md")
                  alarm(1, Cleanrs)
                else
                  sendText(msg.chat_id, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "md")
                end
              end
              )
            end
            if status[2] == "بیوگرافی" then
              local GroupMembers = function(extra, result, success)
                getChatMember(msg.chat_id, BotHelper, function(arg, input)
                  if input.status.can_restrict_members then
                    if result.members then
                      do
                        for i, i in pairs(result.members) do
                          function BioLink(arg, data, success)
                            if data.about then
                              LeaderAbout = data.about
                            else
                              LeaderAbout = "Nil"
                            end
                            if LeaderAbout:match("[Tt].[Mm][Ee]/") or LeaderAbout:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") then
                              KickUser(msg.chat_id, y.user_id)
                            end
                          end
                          
                          GetUserFull(i.user_id, BioLink)
                        end
                      end
                    end
                    sendText(msg.chat_id, msg.id, "• کاربرانی که در بیوگرافی خود لینک داشتند مسدود شد !", "html")
                  else
                    sendText(msg.chat_id, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
                  end
                end
                )
              end
              
              getChannelMembers(msg.chat_id, "Search", 0, 1000, GroupMembers)
            end
            if status[2] == "bots" or status[2] == "ربات ها" then
              local botslist = function(extra, result, success)
                if result.members then
                  do
                    do
                      for i, i in pairs(result.members) do
                        KickUser(msg.chat_id, i.user_id)
                      end
                    end
                  end
                  sendText(msg.chat_id, msg.id, "• تعداد " .. result.total_count .. " ربات ازگروه مسدود شد", "md")
                end
              end
              
              getChannelMembers(msg.chat_id, "Bots", 0, 200, botslist)
            end
            if status[2] == "deleted" or status[2] == "دلیت اکانت" then
              function list(extra, result, success)
                i = 0
                do
                  do
                    for i, i in pairs(result.members) do
                      local Checkdeleted = function(extra, result, success)
                        if result.type._ == "userTypeDeleted" then
                          KickUser(msg.chat_id, result.id)
                          i = i + 1
                        end
                      end
                      
                      GetUser(i.user_id, Checkdeleted)
                    end
                  end
                end
                sendText(msg.chat_id, msg.id, "• کاربران دیلیت شده با موفقیت اخراج شدند !", "md")
              end
              
              getChannelMembers(msg.chat_id, "Search", 0, 200, list)
            end
            if status[2] == "stickers" or status[2] == "استیکر" then
              leaderclean(msg, msg.chat_id, "messageSticker", "استیکرهایی")
            elseif status[2] == "text" or status[2] == "متن" then
              leaderclean(msg, msg.chat_id, "messageText", "متن هایی")
            elseif status[2] == "Location" or status[2] == "موقعیت مکانی" then
              leaderclean(msg, msg.chat_id, "messageLocation", "مکان هایی")
            elseif status[2] == "Contact" or status[2] == "مخاطب" then
              leaderclean(msg, msg.chat_id, "messageContact", "مخاطب هایی")
            elseif status[2] == "VideoNote" or status[2] == "فیلم سلفی" then
              leaderclean(msg, msg.chat_id, "messageVideoNote", "فیلم سلفی هایی")
            elseif status[2] == "videos" or status[2] == "فیلم" then
              leaderclean(msg, msg.chat_id, "messageVideo", "فیلم هایی")
            elseif status[2] == "files" or status[2] == "فایل" then
              leaderclean(msg, msg.chat_id, "messageDocument", "فایل هایی")
            elseif status[2] == "photos" or status[2] == "عکس" then
              leaderclean(msg, msg.chat_id, "messagePhoto", "عکس هایی")
            elseif status[2] == "gifs" or status[2] == "گیف" then
              leaderclean(msg, msg.chat_id, "messageAnimation", "گیف هایی")
            elseif status[2] == "musics" or status[2] == "اهنگ" then
              leaderclean(msg, msg.chat_id, "messageAudio", "اهنگ هایی")
            elseif status[2] == "voices" or status[2] == "ویس" then
              leaderclean(msg, msg.chat_id, "messageVoice", "ویس هایی")
            elseif status[2] == "games" or status[2] == "بازی" then
              leaderclean(msg, msg.chat_id, "messageGame", "بازی هایی")
            elseif status[2] == "tg" or status[2] == "سرویس تلگرام" then
              leaderclean(msg, msg.chat_id, msg.chat_id, "messageChatAddMembers", "سرویس تلگرام هایی")
            elseif status[2] == "پک" then
              redis:del("filterpackname" .. msg.chat_id)
              sendText(msg.chat_id, msg.id, "لیست فیلترپک پاکسازی شد !", "html")
            elseif status[2] == "vip" or status[2] == "ویژه" then
              redis:del("Vip:" .. msg.chat_id)
              sendText(msg.chat_id, msg.id, "• لیست ویژه پاکسازی شد!", "md")
            elseif status[2] == "filters" or status[2] == "فیلتر" then
              redis:del("Filters:" .. msg.chat_id)
              sendText(msg.chat_id, msg.id, "• لیست فیلتر پاکسازی شد!", "md")
            elseif status[2] == "warns" or status[2] == "اخطار" then
              redis:del(msg.chat_id .. ":warn")
              sendText(msg.chat_id, msg.id, "لیست اخطار ها پاکسازی شد!", "md")
            elseif status[2] == "username" or status[2] == "یوزرنیم" then
              CleanPm(msg, msg.chat_id, "@", "نام های کاربری")
            elseif status[2] == "vipadd" or status[2] == "معافان" and is_owner(msg.chat_id, msg.sender_user_id) then
              redis:del("VipAdd:" .. msg.chat_id)
              sendText(msg.chat_id, msg.id, "• لیست مدیران معافان اداجباری پاکسازی شد!", "md")
            elseif status[2] == "mods" or status[2] == "مدیران" and is_owner(msg.chat_id, msg.sender_user_id) then
              redis:del("ModList:" .. msg.chat_id)
              sendText(msg.chat_id, msg.id, "• لیست مدیران گروه پاکسازی شد!", "md")
            elseif status[2] == "settings" or status[2] == "تنظیمات" and is_owner(msg.chat_id, msg.sender_user_id) then
              remRed(msg.chat_id)
              sendText(msg.chat_id, msg.id, "• تمامی تنظیمات اجرا شده گروه پاکسازی شد!", "md")
            elseif status[2] == "لیست جواب" and is_owner(msg.chat_id, msg.sender_user_id) then
              redis:del("answer" .. msg.chat_id)
              sendText(msg.chat_id, msg.id, "ok", "html")
            elseif status[2] == "lastmonth" or status[2] == "بازدید یکماه" then
              leadercleanuser(msg, msg.chat_id, "userStatusLastMonth", "بازدید یکماه پیش")
            elseif status[2] == "lastweek" or status[2] == "بازدید یک هفته پیش" then
              leadercleanuser(msg, msg.chat_id, "userStatusLastWeek", "بازدید یک هفته پیش")
            elseif status[2] == "seenrecntly" or status[2] == "بازدید اخیرا" then
              leadercleanuser(msg, msg.chat_id, "userStatusRecently", "بازدید اخیرا")
            elseif status[2] == "empty" or status[2] == "فیک" then
              leadercleanuser(msg, msg.chat_id, "userStatusEmpty", "فیک")
            elseif status[2] == "online" or status[2] == "انلاین" then
              leadercleanuser(msg, msg.chat_id, "userStatusOnline", "انلاین")
            elseif status[2] == "members" or status[2] == "کاربران" and is_owner(msg.chat_id, msg.sender_user_id) then
              function CleanMembers(extra, result, success)
                do
                  do
                    for i, i in pairs(result.members) do
                      KickUser(msg.chat_id, i.user_id)
                      redis:sadd("BanUser:" .. msg.chat_id, i.user_id)
                    end
                  end
                end
              end
              
              getChannelMembers(msg.chat_id, "Search", 0, 1000, CleanMembers)
              sendText(msg.chat_id, msg.id, "• تعدادی از کاربران از گروه مسدود شد !", "md")
            elseif status[2] == "gbans" or status[2] == "مسدود همگانی" and is_sudo(msg.sender_user_id) then
              redis:del("GlobalyBanned:")
              sendText(msg.chat_id, msg.id, "• انجام شد!", "md")
            elseif status[2] == "OwnerList" or status[2] == "مالک" and is_sudo(msg.sender_user_id) then
              redis:del("OwnerList:" .. msg.chat_id)
              sendText(msg.chat_id, msg.id, "• لیست مالکان گروه پاکسازی شد!", "md")
            elseif status[2] == "modbot" or status[2] == "مدیران ربات" and is_Fullsudo(msg.sender_user_id) then
              redis:del("SUDO-ID")
              sendText(msg.chat_id, msg.id, "• لیست مدیران ربات پاکسازی شد!", "md")
            end
          end
          function LeaderLock(ops)
            if not ops then
              return
            end
            LeaderLock = {
              FA = {
                "لینک",
                "تگ",
                "فروارد",
                "فایل",
                "مخاطب",
                "بازی",
                "رسانه",
                "فروارد کاربر",
                "فروارد کانال"
              },
              EN = {
                "Lock:Link:",
                "Lock:Tag:",
                "Lock:Forward:",
                "Lock:File:",
                "Lock:Contact:",
                "Lock:Game:",
                "Lock:Caption:",
                "Lock:Fwduser:",
                "Lock:Fwdch:"
              }
            }
            do
              do
                for i, i in pairs(LeaderLock.FA) do
                  if ops == i then
                    return LeaderLock.EN[i]
                  end
                end
              end
            end
            return false
          end
          
          if text:match("^بیصدا (%S+)$") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            inputz = text:match("^بیصدا (%S+)$")
            forgod = LeaderLock(inputz)
            if not forgod then
              text = ""
            elseif redis:get(forgod .. msg.chat_id) == "Mute" then
              text = "• قفل " .. inputz .. " در حال حاضر درحالت بیصدا است .\n" .. EndMsg .. ""
            else
              redis:set(forgod .. msg.chat_id, "Mute")
              text = "• قفل " .. inputz .. " درحالت بیصدا قرار گرفت !\n" .. EndMsg .. ""
            end
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if text:match("^اخطار (%S+)$") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            inputz = text:match("^اخطار (%S+)$")
            forgod = LeaderLock(inputz)
            if not forgod then
              text = ""
            elseif redis:get(forgod .. msg.chat_id) == "Warn" then
              text = "• قفل " .. inputz .. " در حال حاضر درحالت اخطار است .\n" .. EndMsg .. ""
            else
              redis:set(forgod .. msg.chat_id, "Warn")
              text = "• قفل " .. inputz .. " درحالت اخطار قرار گرفت !\n" .. EndMsg .. ""
            end
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if text:match("^اخراج (%S+)$") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            inputz = text:match("^اخراج (%S+)$")
            forgod = LeaderLock(inputz)
            if not forgod then
              text = ""
            elseif redis:get(forgod .. msg.chat_id) == "Kick" then
              text = "• قفل " .. inputz .. " در حال حاضر درحالت اخراج است .\n" .. EndMsg .. ""
            else
              redis:set(forgod .. msg.chat_id, "Kick")
              text = "• قفل " .. inputz .. " درحالت اخراج قرار گرفت !\n" .. EndMsg .. ""
            end
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if text:match("^مسدود (%S+)$") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            inputz = text:match("^مسدود (%S+)$")
            forgod = LeaderLock(inputz)
            if not forgod then
              text = ""
            elseif redis:get(forgod .. msg.chat_id) == "Ban" then
              text = "• قفل " .. inputz .. " در حال حاضر درحالت مسدود است .\n" .. EndMsg .. ""
            else
              redis:set(forgod .. msg.chat_id, "Ban")
              text = "• قفل " .. inputz .. " درحالت مسدود قرار گرفت !\n" .. EndMsg .. ""
            end
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if text:match("^قفل همه (.*)$") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            inputz = text:match("^قفل همه (.*)$")
            text = "• قفل های فعال شده :\n\n"
            tex = "• قفل های از قبل فعال شده :\n\n"
            do
              do
                for i in string.gmatch(inputz, "%S+") do
                  forgod = change(i)
                  if not forgod then
                    text = "• قفل ها وجود ندارند لطفا راهنما را بخوانید !"
                    break
                  elseif redis:get(forgod .. msg.chat_id) then
                    tex = tex .. " " .. i .. " \n"
                  else
                    redis:set(forgod .. msg.chat_id, "Enable")
                    text = text .. " " .. i .. " \n"
                  end
                end
              end
            end
            sendText(msg.chat_id, msg.id, text .. "\n" .. tex, "md")
          end
          if text:match("^بازکردن همه (.*)$") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            inputz = text:match("^بازکردن همه (.*)$")
            text = "• قفل های غیرفعال شده :\n\n"
            tex = "• قفل های از قبل غیرفعال شده :\n\n"
            do
              do
                for i in string.gmatch(inputz, "%S+") do
                  forgod = change(i)
                  if not forgod then
                    text = "• قفل وجود ندارد لطفا راهنما را بخوانید !"
                    break
                  elseif redis:get(forgod .. msg.chat_id) then
                    redis:del(forgod .. msg.chat_id)
                    text = text .. " " .. i .. "\n"
                  else
                    tex = tex .. " " .. i .. " \n"
                  end
                end
              end
            end
            sendText(msg.chat_id, msg.id, tex .. "\n" .. text, "html")
          end
          if text:match("^قفل (.*)$") and locksacsuser(msg, msg.chat_id, msg.sender_user_id) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) then
            inputz = text:match("^قفل (.*)$")
            forgod = change(inputz)
            if not forgod then
              text = ""
            elseif redis:get(forgod .. msg.chat_id) then
              text = "• قفل " .. inputz .. " در حال حاضر فعال است .\n" .. EndMsg .. ""
            else
              redis:set(forgod .. msg.chat_id, "Enable")
              text = "• قفل " .. inputz .. " با موفقیت فعال شد !\n" .. EndMsg .. ""
            end
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if text:match("^بازکردن (.*)$") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and ModAccess(msg, msg.chat_id, msg.sender_user_id) and locksacsuser(msg, msg.chat_id, msg.sender_user_id) then
            inputz = text:match("^بازکردن (.*)$")
            forgod = change(inputz)
            if not forgod then
              text = ""
            elseif redis:get(forgod .. msg.chat_id) then
              text = "• قفل " .. inputz .. " غیرفعال شد !\n" .. EndMsg .. ""
              redis:del(forgod .. msg.chat_id)
            else
              text = "• قفل " .. inputz .. " از قبل غیرفعال است .\n" .. EndMsg .. ""
            end
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if text == "photoid on" or text == "عکس ایدی روشن" then
            redis:set("photoid:" .. msg.chat_id, true)
            sendText(msg.chat_id, msg.id, "• وضعیت دریافت عکس پروفایل به حالت فعال تنظیم شد !", "html")
          end
          if text == "photoid off" or text == "عکس ایدی خاموش" then
            redis:del("photoid:" .. msg.chat_id)
            sendText(msg.chat_id, msg.id, "• وضعیت دریافت عکس پروفایل به حالت غیرفعال تنظیم شد !", "html")
          end
          if text:match("^whois @(.*)") or text:match("^ایدی @(.*)") or text:match("^id @(.*)") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local username = text:match("^whois @(.*)") or text:match("^ایدی @(.*)") or text:match("^id @(.*)")
            local Whois = function(extra, result, success)
              if result.id then
                getid(msg, msg.chat_id, result.id)
              else
                sendText(msg.chat_id, msg.id, "• کاربر [ @" .. username .. " ] یافت نشد !", "html")
              end
            end
            
            searchPublicChat(username, Whois)
          end
          if text == "اطلاعات گروه" or text == "gpinfo" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local link = redis:get("Link:" .. msg.chat_id)
            local FullInfo = function(VHT, result)
              Text = "🏷 شناسه گروه : " .. msg.chat_id .. "" .. "\n\n👥 تعداد مدیران گروه : " .. (result.administrator_count or "----") .. "\n\n🚫 تعداد کاربران بلاک شده : " .. (result.banned_count or "----") .. "\n\n⏺ تعداد کاربران : " .. (result.member_count or "----") .. "\n\n🔇 تعداد محدود شده : " .. (result.restricted_count or "----") .. "\n\n🔗 لینک دعوت به سوپرگروه : " .. link or "----" .. "\n\n🔗 درباره گروه : " .. result.description or "----"
              sendText(msg.chat_id, msg.id, Text, "html")
            end
            
            getChannelFull(msg.chat_id, FullInfo)
          end
          if (text == "link" or text == "لینک") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local GetName = function(extra, result, success)
              local link = redis:get("Link:" .. msg.chat_id)
              if link then
                sendText(msg.chat_id, msg.id, "• نام گروه:" .. result.title .. "\n\n• لینک گروه :\n" .. link .. "", "html")
              else
                sendText(msg.chat_id, msg.id, "• لینک برای گروه ثبت نشده!", "md")
              end
            end
            
            GetChat(msg.chat_id, GetName)
          end
          if (text == "rules" or text == "قوانین") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local Get = function(extra, TDBots)
              local GetName = function(extra, result, success)
                local chat = msg.chat_id
                local rules = redis:get("Rules:" .. msg.chat_id)
                if rules then
                  sendText(msg.chat_id, msg.id, "• قوانین گروه :\n[ " .. rules .. " ]", "html")
                else
                  sendText(msg.chat_id, msg.id, "• قوانینی برای گروه ثبت نشده است!", "md")
                end
              end
              
              GetChat(msg.chat_id, GetName)
            end
            
            getChannelFull(msg.chat_id, Get)
          end
          if text == "امارگروه" or text == "statsgp" then
            local date = jdate("• تاریخ: #x , #Y/#M/#D \n• ساعت: #h:#m")
            local msgs = tonumber(redis:get("Total:messages:" .. msg.chat_id))
            local stickers = tonumber(redis:get("Total:Stickers:" .. msg.chat_id))
            local files = tonumber(redis:get("Total:Document:" .. msg.chat_id))
            local audios = tonumber(redis:get("Total:Audio:" .. msg.chat_id))
            local voices = tonumber(redis:get("Total:Voice:" .. msg.chat_id))
            local videos = tonumber(redis:get("Total:Video:" .. msg.chat_id))
            local photos = tonumber(redis:get("Total:Photo:" .. msg.chat_id))
            local deletemembers = tonumber(redis:get("Total:ChatDeleteMember:" .. msg.chat_id))
            local joinlinks = tonumber(redis:get("Total:ChatJoinByLink:" .. msg.chat_id))
            local addmembers = tonumber(redis:get("Total:added:" .. msg.chat_id))
            local Data = {}
            local Max1, Max2, Max3, Max4, Max5 = 0, 0, 0, 0, 0
            local User1Data, User2Data, User3Data, User4Data, User5Data = {}, {}, {}, {}, {}
            local users = redis:smembers("Total:users:" .. msg.chat_id) or 0
            do
              do
                for i, i in pairs(users) do
                  local Msgs = redis:get("Total:messages:" .. msg.chat_id .. ":" .. i) or 0
                  Data[tostring(i)] = Msgs
                end
              end
            end
            do
              do
                for i, i in pairs(Data) do
                  if tonumber(i) > tonumber(Max1) then
                    User1Data = {
                      tonumber(i),
                      i
                    }
                    Max1 = i
                  end
                end
              end
            end
            Data[tostring(User1Data[1])] = nil
            do
              do
                for i, i in pairs(Data) do
                  if tonumber(i) > tonumber(Max2) then
                    User2Data = {
                      tonumber(i),
                      i
                    }
                    Max2 = i
                  end
                end
              end
            end
            Data[tostring(User2Data[1])] = nil
            do
              do
                for i, i in pairs(Data) do
                  if tonumber(i) > tonumber(Max3) then
                    User3Data = {
                      tonumber(i),
                      i
                    }
                    Max3 = i
                  end
                end
              end
            end
            Data[tostring(User3Data[1])] = nil
            do
              do
                for i, i in pairs(Data) do
                  if tonumber(i) > tonumber(Max4) then
                    User4Data = {
                      tonumber(i),
                      i
                    }
                    Max4 = i
                  end
                end
              end
            end
            Data[tostring(User4Data[1])] = nil
            do
              do
                for i, i in pairs(Data) do
                  if tonumber(i) > tonumber(Max5) then
                    User5Data = {
                      tonumber(i),
                      i
                    }
                    Max5 = i
                  end
                end
              end
            end
            Data[tostring(User5Data[1])] = nil
            if User1Data[1] and User2Data[1] and User3Data[1] and User4Data[1] and User5Data[1] then
              local num1 = "• <a href=\"tg://user?id=" .. User1Data[1] .. "\"> نفر اول با </a> : <code>" .. User1Data[2] .. "</code> پیام "
              local num2 = "• <a href=\"tg://user?id=" .. User2Data[1] .. "\"> نفر دوم با </a> : <code>" .. User2Data[2] .. "</code> پیام "
              local num3 = "• <a href=\"tg://user?id=" .. User3Data[1] .. "\"> نفر سوم با </a> : <code>" .. User3Data[2] .. "</code> پیام "
              local num4 = "• <a href=\"tg://user?id=" .. User4Data[1] .. "\"> نفر چهارم با </a> : <code>" .. User4Data[2] .. "</code> پیام "
              local num5 = "• <a href=\"tg://user?id=" .. User5Data[1] .. "\"> نفر پنجم با </a> : <code>" .. User5Data[2] .. "</code> پیام "
              test = "" .. num1 .. "\n" .. num2 .. "\n" .. num3 .. "\n" .. num4 .. "\n" .. num5 .. ""
            else
              test = "آمار دقیقی دردسترس نمیباشد !"
            end
            local Dataadd = {}
            local Max11, Max12, Max13 = 0, 0, 0
            local User12Data, User22Data, User33Data = {}, {}, {}
            local users = redis:smembers("Total:users:" .. msg.chat_id) or 0
            do
              do
                for i, i in pairs(users) do
                  local Added = redis:get("Total:added:" .. msg.chat_id .. ":" .. i) or 0
                  Dataadd[tostring(i)] = Added
                end
              end
            end
            do
              do
                for i, i in pairs(Dataadd) do
                  if tonumber(i) > tonumber(Max11) then
                    User12Data = {
                      tonumber(i),
                      i
                    }
                    Max11 = i
                  end
                end
              end
            end
            Dataadd[tostring(User12Data[1])] = nil
            do
              do
                for i, i in pairs(Dataadd) do
                  if tonumber(i) > tonumber(Max12) then
                    User22Data = {
                      tonumber(i),
                      i
                    }
                    Max12 = i
                  end
                end
              end
            end
            Dataadd[tostring(User22Data[1])] = nil
            do
              do
                for i, i in pairs(Dataadd) do
                  if tonumber(i) > tonumber(Max13) then
                    User33Data = {
                      tonumber(i),
                      i
                    }
                    Max13 = i
                  end
                end
              end
            end
            Dataadd[tostring(User33Data[1])] = nil
            if User12Data[1] and User22Data[1] and User33Data[1] then
              local num11 = "• <a href=\"tg://user?id=" .. User12Data[1] .. "\"> نفر اول با </a> : <code>" .. User12Data[2] .. "</code> نفر "
              local num21 = "• <a href=\"tg://user?id=" .. User22Data[1] .. "\"> نفر دوم با </a> : <code>" .. User22Data[2] .. "</code> نفر "
              local num31 = "• <a href=\"tg://user?id=" .. User33Data[1] .. "\"> نفر سوم با </a> : <code>" .. User33Data[2] .. "</code> نفر "
              testt = "" .. num11 .. "\n" .. num21 .. "\n" .. num31 .. ""
            else
              testt = "آمار دقیقی دردسترس نمیباشد !"
            end
            local txt = "🎗 آمار گروه شما\n" .. date .. "\n\n■ بخش آمار پیام ها:\n\n • تعداد پیام ها: " .. (msgs or "0") .. "\n\n■ بخش آمار رسانه ها:\n\n• استیکر ها: " .. (stickers or "0") .. "\n\n• فایل ها: " .. (files or "0") .. "\n\n• موزیک ها: " .. (audios or "0") .. "\n\n• ویس ها: " .. (voices or "0") .. "\n\n• فیلم ها: " .. (videos or "0") .. "\n\n• عکس ها: " .. (photos or "0") .. "\n\n■ بخش آمار کاربران:\n\n• فعال ترین ها در گروه در ارسال پیام :\n\n" .. test .. "\n\n• فعال ترین های گروه در اضافه کردن اعضا :\n\n" .. testt .. "\n\n• تعداد نفرات جوین داده شده: " .. (joinlinks or "0") .. "\n• تعداد نفرات افزوده شده: " .. (addmembers or "0") .. "\n• تعداد کاربران اخراج شده: " .. (deletemembers or "0") .. " "
            sendText(msg.chat_id, msg.id, txt, "html")
          end
          if text:match("^هواشناسی (.*)$") then
            local city = text:match("^هواشناسی (.*)$")
            textz = get_weather(city)
            if not textz then
              sendText(msg.chat_id, msg.id, "در دسترس نیست!", "html")
            end
            sendText(msg.chat_id, msg.id, textz, "html")
          end
          if (text:match("^getpro (%d+)") or text:match("^پروفایل (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local offset = tonumber(text:match("^getpro (%d+)") or text:match("^پروفایل (%d+)"))
            if offset > 50 then
              sendText(msg.chat_id, msg.id, "• من نمیتوانم بیشتر از 50 عکس پروفایل شما را ارسال کنم!", "md")
            elseif offset < 1 then
              sendText(msg.chat_id, msg.id, "• لطفا عددی بزرگ تر از 0 بکار ببرید!", "md")
            else
              function GetPro1(extra, result, success)
                if result.photos[0] then
                  sendPhoto(msg.chat_id, msg.id, 0, 1, nil, result.photos[0].sizes[2].photo.persistent_id, "• تعداد عکس  : " .. result.total_count .. "\n سایز عکس : " .. result.photos[0].sizes[2].photo.size)
                else
                  sendText(msg.chat_id, msg.id, "• شما عکس پروفایل " .. offset .. " ندارید!", "md")
                end
              end
              
              tdbot_function({
                _ = "getUserProfilePhotos",
                user_id = msg.sender_user_id,
                offset = offset - 1,
                limit = 9.999999999999999E22
              }, GetPro1, nil)
            end
          end
          if text:match("^ترجمه ([^%s]+)") then
            local lang = text:match("^ترجمه ([^%s]+)")
            function id_by_reply(extra, TDBot, success)
              local getlink = TDBot.content.text
              local url, res = https.request("https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20160119T111342Z.fd6bf13b3590838f.6ce9d8cca4672f0ed24f649c1b502789c9f4687a&format=plain&lang=" .. URL.escape(lang) .. "&text=" .. URL.escape(getlink))
              if res ~= 200 then
                sendText(msg.chat_id, msg.id, "خطا در اتصال به وب سرویس !", "html")
              else
                data = json:decode(url)
                local text = "زبان ترجمه : <code>" .. data.lang .. "</code>\nترجمه : <code>" .. data.text[1] .. "</code>"
                sendText(msg.chat_id, msg.id, text, "html")
              end
            end
            
            if tonumber(msg.reply_to_message_id) == 0 then
            else
              getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), id_by_reply)
            end
          end
          if text and (text:match("^([Gg][Ii][Ff]) (.*)$") or text:match("^ساخت گیف (.*)$")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local text = text:gsub("ساخت گیف", "gif")
            local lc = {
              string.match(text, "^([Gg][Ii][Ff]) (.*)$")
            }
            local modes = {
              "memories-anim-logo",
              "alien-glow-anim-logo",
              "flash-anim-logo",
              "flaming-logo",
              "whirl-anim-logo",
              "highlight-anim-logo",
              "burn-in-anim-logo",
              "shake-anim-logo",
              "inner-fire-anim-logo",
              "jump-anim-logo"
            }
            local text = URL.escape(lc[2])
            local url = "http://www.flamingtext.com/net-fu/image_output.cgi?_comBuyRedirect=false&script=" .. modes[math.random(#modes)] .. "&text=" .. text .. "&symbol_tagname=popular&fontsize=70&fontname=futura_poster&fontname_tagname=cool&textBorder=15&growSize=0&antialias=on&hinting=on&justify=2&letterSpacing=0&lineSpacing=0&textSlant=0&textVerticalSlant=0&textAngle=0&textOutline=off&textOutline=false&textOutlineSize=2&textColor=%230000CC&angle=0&blueFlame=on&blueFlame=false&framerate=75&frames=5&pframes=5&oframes=4&distance=2&transparent=off&transparent=false&extAnim=gif&animLoop=on&animLoop=false&defaultFrameRate=75&doScale=off&scaleWidth=240&scaleHeight=120&&_=1469943010141"
            local title, res = http.request(url)
            local mod = {
              "Blinking+Text",
              "No+Button",
              "Dazzle+Text",
              "Walk+of+Fame+Animated",
              "Wag+Finger",
              "Glitter+Text",
              "Bliss",
              "Flasher",
              "Roman+Temple+Animated"
            }
            local set = mod[math.random(#mod)]
            local colors = {
              "00FF00",
              "6699FF",
              "CC99CC",
              "CC66FF",
              "0066FF",
              "000000",
              "CC0066",
              "FF33CC",
              "FF0000",
              "FFCCCC",
              "FF66CC",
              "33FF00",
              "FFFFFF",
              "00FF00"
            }
            local bc = colors[math.random(#colors)]
            local colorss = {
              "00FF00",
              "6699FF",
              "CC99CC",
              "CC66FF",
              "0066FF",
              "000000",
              "CC0066",
              "FF33CC",
              "FFF200",
              "FF0000",
              "FFCCCC",
              "FF66CC",
              "33FF00",
              "FFFFFF",
              "00FF00"
            }
            local tc = colorss[math.random(#colorss)]
            local url2 = "http://www.imagechef.com/ic/maker.jsp?filter=&jitter=0&tid=" .. set .. "&color0=" .. bc .. "&color1=" .. tc .. "&color2=000000&customimg=&0=" .. lc[2]
            local title1, res = http.request(url2)
            if res ~= 200 then
              sendText(msg.chat_id, msg.id, "خطا در اتصال به وب سرویس !", "html")
            elseif title1 and json:decode(title1) then
              local jdat = json:decode(title1)
              local gif = jdat.resImage
              local file = download_to_file(gif, "./data/fun/Gif-Random.gif")
              sendDocument(msg.chat_id, msg.id, 0, 1, nil, file)
            end
          end
          if text == "فال" then
            local url, res = "http://api.NovaTeamCo.ir/fal", nil
            if res ~= 200 then
              local file = download_to_file(url, "./data/fun/fal.jpg")
              sendPhoto(msg.chat_id, msg.id, 0, 1, nil, file, "", "md")
            else
              sendText(msg.chat_id, msg.id, "✢ خطا در اتصال به وب سرویس تلگرام !", "md")
            end
          end
          if text == "sher" or text == "شعر" then
            local url, res = http.request("http://c.ganjoor.net/beyt-json.php")
            if res ~= 200 then
              text = "✢ خطا در اتصال به وب سرویس تلگرام !"
            else
              local jdat = json:decode(url)
              local text = jdat.m1 .. "\n" .. jdat.m2 .. "\n\n سروده شده توسط \n ——————————\n👤" .. jdat.poet
              sendText(msg.chat_id, msg.id, text, "md")
            end
          end
          if text == "جوک" then
            res = http.request("http://kings-afg.tk/api/jok/")
            sendText(msg.chat_id, msg.id, res, "md")
          end
          if (text == "تبدیل به عکس" or text == "tophoto") and 0 < tonumber(msg.reply_to_message_id) then
            function tophoto(extra, result, success)
              if result.content._ == "messageSticker" then
                print(result.content.sticker.sticker.path)
                sendPhoto(msg.chat_id, msg.id, 0, 1, nil, result.content.sticker.sticker.path, "" .. EndMsg .. "")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), tophoto)
          end
          if text:match("^dm(%d+)") or text:match("^دانلود (%d+)") then
            local ul = text:match("dm(%d+)") or text:match("^دانلود (%d+)")
            data, res = http.request("http://kings-afg.tk/api/RadioJavan/id.php/?id=" .. ul .. "")
            if res ~= 200 then
              sendText(msg.chat_id, msg.id, " خطا در اتصال به وب سرویس !", "html")
            else
              out = JSON.decode(data)
              sendText(msg.chat_id, msg.id, "درحال دانلود.....!", "md")
              local url = download_to_file(out.link, "/1366.mp3")
              sendAudio(msg.chat_id, 0, url, "", "")
            end
          end
          if text and (text:match("^tosticker$") or text:match("^تبدیل به استیکر$")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and 0 < tonumber(msg.reply_to_message_id) then
            whoami()
            function tosticker(arg, data)
              if data.content._ == "messagePhoto" then
                pathf = tcpath .. "/files/photos/" .. data.content.photo.id .. ".jpg"
                sendSticker(msg.chat_id, msg.id, pathf)
              else
                sendText(msg.chat_id, msg.id, "فقط #عکس ها قابل تبدیل میباشد", "md")
              end
            end
            
            getMessage(msg.chat_id, msg.reply_to_message_id, tosticker)
          end
          if text:match("^music (.*)$") or text:match("^موزیک (.*)$") then
            local text = text:match("^music (.*)$") or text:match("^موزیک (.*)$")
            txt = " نتایج جست و جو:"
            data, res = http.request("http://kings-afg.tk/api/RadioJavan/query.php/?query=" .. text .. "")
            if res ~= 200 then
              sendText(msg.chat_id, msg.id, " خطا در اتصال به وب سرویس !", "html")
            else
              out = JSON.decode(data)
              do
                do
                  for i = 1, 40 do
                    if out.mp3s[i] then
                      local download = "[دانلود مستقیم](" .. out.mp3s[i].link .. ")"
                      txt = txt .. "\n\n• نام خواننده: " .. out.mp3s[i].title .. "\n• دانلود: /dm" .. out.mp3s[i].id .. [[

 ]] .. download .. ""
                    else
                      txt = "موزیک مورد نظر یافت نشد"
                    end
                  end
                end
              end
              sendText(msg.chat_id, msg.id, txt, "md")
            end
          end
          if text:match("^بگو (.*)") or text:match("^echo (.*)") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local txt = text:match("^بگو (.*)") or text:match("^echo (.*)")
            function Fucked(extra, result, success)
              deleteMessages(msg.chat_id, {
                [0] = msg.id
              })
              sendText(msg.chat_id, result.id, txt, "md")
            end
            
            if tonumber(msg.reply_to_message_id) == 0 then
            else
              getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), Fucked)
            end
          end
          if (text == "بکنش" or text == "fucked") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            function Fucked(extra, result, success)
              sendSticker(msg.chat_id, result.id, "CAADBQADXAADjtB8Db8mMx1EtBAeAg")
              local text = "حله داداچ الان میکنمش ابمم میریزم توش😐"
              sendText(msg.chat_id, msg.id, text, "md")
              local text = "دردت گرفت؟ ایشالا خوب میشی😐"
              sendText(msg.chat_id, result.id, text, "md")
              local text = "دمت گرم چه کونی داری تو عاشق کونتم😝"
              sendText(msg.chat_id, result.id, text, "md")
            end
            
            if tonumber(msg.reply_to_message_id) == 0 then
            else
              getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), Fucked)
            end
          end
          if text:match("^ترافیک (.*)$") then
            local cytr = text:match("^ترافیک (.*)$")
            local result = CheckCity(cytr)
            if result then
              local Traffick = "https://images.141.ir/Province/" .. result .. ".jpg"
              local file = download_to_file(Traffick, "./data/fun/Traffick.jpg")
              sendPhoto(msg.chat_id, msg.id, 0, 1, nil, file, "" .. EndMsg .. "")
            else
              sendText(msg.chat_id, msg.id, "خطا\nمکان وارد شده صحیح نیست!", "html")
            end
          end
          if (text == "clean msgs" or text == "پاکسازی پیام ها" or text == "clean msg" or text == "پاکسازی پیام" or text == "پاکسازی گروه" or text == "پاکسازی کلی" or text == "پاکسازی همه" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id)) and Clean_ModAccess(msg, msg.chat_id, msg.sender_user_id) and acsclean(msg, msg.chat_id, msg.sender_user_id) then
            getChatMember(msg.chat_id, TD_ID, function(arg, input)
              if input.status.can_delete_messages then
                Name = "<a href=\"tg://user?id=" .. TD_ID .. "\"> بپاک </a>"
                sendText(msg.chat_id, msg.id, Name, "html")
              else
                sendText(msg.chat_id, msg.id, "دسترسی {حذف پیام} برای ربات پاکسازی فعال نشده است !", "html")
              end
            end
            )
          end
          if lc:match("^پاکسازی بیوگرافی (.*)$") then
            local text = lc:match("^پاکسازی بیوگرافی (.*)$")
            local GroupMembers = function(extra, result, success)
              getChatMember(msg.chat_id, BotHelper, function(arg, input)
                if input.status.can_restrict_members then
                  if result.members then
                    do
                      for i, i in pairs(result.members) do
                        function BioLink(arg, data, success)
                          if data.about then
                            LeaderAbout = data.about
                          else
                            LeaderAbout = "Nil"
                          end
                          if LeaderAbout:match("^(.*)" .. text .. "(.*)$") or LeaderAbout:match("^" .. text .. "(.*)$") or LeaderAbout:match("(.*)" .. text .. "$") then
                            KickUser(msg.chat_id, y.user_id)
                          end
                        end
                        
                        GetUserFull(i.user_id, BioLink)
                      end
                    end
                  end
                  sendText(msg.chat_id, msg.id, "• کاربرانی که در بیوگرافی خود " .. text .. " داشتند مسدود شد !", "html")
                else
                  sendText(msg.chat_id, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
                end
              end
              )
            end
            
            getChannelMembers(msg.chat_id, "Search", 0, 200, GroupMembers)
          end
          if lc:match("^پاکسازی همنام (.*)$") then
            local text = lc:match("^پاکسازی همنام (.*)$")
            local GroupMembers = function(extra, result, success)
              getChatMember(msg.chat_id, BotHelper, function(arg, input)
                if input.status.can_restrict_members then
                  if result.members then
                    do
                      for i, i in pairs(result.members) do
                        local name = function(arg, data, success)
                          if data.first_name:match("^(.*)" .. text .. "(.*)$") or data.first_name:match("^" .. text .. "(.*)$") or data.first_name:match("(.*)" .. text .. "$") then
                            KickUser(msg.chat_id, y.user_id)
                          end
                        end
                        
                        GetUser(i.user_id, name)
                      end
                    end
                  end
                  sendText(msg.chat_id, msg.id, "• کاربران همنام با " .. text .. " با موفقیت مسدود شدند !", "html")
                else
                  sendText(msg.chat_id, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
                end
              end
              )
            end
            
            getChannelMembers(msg.chat_id, "Search", 0, 200, GroupMembers)
          end
          if text:match("^سکوت بیوگرافی$") then
            local GroupMembers = function(extra, result, success)
              getChatMember(msg.chat_id, BotHelper, function(arg, input)
                if input.status.can_restrict_members then
                  if result.members then
                    do
                      for i, i in pairs(result.members) do
                        function BioLink(arg, data, success)
                          if data.about then
                            LeaderAbout = data.about
                          else
                            LeaderAbout = "Nil"
                          end
                          if LeaderAbout:match("[Tt].[Mm][Ee]/") or LeaderAbout:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") then
                            mute(msg.chat_id, y.user_id, "Restricted", {
                              1,
                              0,
                              0,
                              0,
                              0,
                              0
                            })
                          end
                        end
                        
                        GetUserFull(i.user_id, BioLink)
                      end
                    end
                  end
                  sendText(msg.chat_id, msg.id, "• کاربرانی که در بیوگرفی خود لینک داشتند بیصدا شدند!", "html")
                else
                  sendText(msg.chat_id, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
                end
              end
              )
            end
            
            getChannelMembers(msg.chat_id, "Search", 0, 200, GroupMembers)
          end
          if lc:match("^سکوت بیوگرافی (.*)$") then
            local text = lc:match("^سکوت بیوگرافی (.*)$")
            local GroupMembers = function(extra, result, success)
              getChatMember(msg.chat_id, BotHelper, function(arg, input)
                if input.status.can_restrict_members then
                  if result.members then
                    do
                      for i, i in pairs(result.members) do
                        function BioLink(arg, data, success)
                          if data.about then
                            LeaderAbout = data.about
                          else
                            LeaderAbout = "Nil"
                          end
                          if LeaderAbout:match("^(.*)" .. text .. "(.*)$") or LeaderAbout:match("^" .. text .. "(.*)$") or LeaderAbout:match("(.*)" .. text .. "$") then
                            mute(msg.chat_id, y.user_id, "Restricted", {
                              1,
                              0,
                              0,
                              0,
                              0,
                              0
                            })
                          end
                        end
                        
                        GetUserFull(i.user_id, BioLink)
                      end
                    end
                  end
                  sendText(msg.chat_id, msg.id, "• کاربران بیوگرافی با " .. text .. " موفقیت بیصدا شدند !", "html")
                else
                  sendText(msg.chat_id, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
                end
              end
              )
            end
            
            getChannelMembers(msg.chat_id, "Search", 0, 200, GroupMembers)
          end
          if lc:match("^سکوت همنام (.*)$") then
            local text = lc:match("^سکوت همنام (.*)$")
            local GroupMembers = function(extra, result, success)
              getChatMember(msg.chat_id, BotHelper, function(arg, input)
                if input.status.can_restrict_members then
                  if result.members then
                    do
                      for i, i in pairs(result.members) do
                        local name = function(arg, data, success)
                          if data.first_name:match("^(.*)" .. text .. "(.*)$") or data.first_name:match("^" .. text .. "(.*)$") or data.first_name:match("(.*)" .. text .. "$") then
                            mute(msg.chat_id, y.user_id, "Restricted", {
                              1,
                              0,
                              0,
                              0,
                              0,
                              0
                            })
                          end
                        end
                        
                        GetUser(i.user_id, name)
                      end
                    end
                  end
                  sendText(msg.chat_id, msg.id, "• کاربران همنام با " .. text .. " موفقیت بیصدا شدند !", "html")
                else
                  sendText(msg.chat_id, msg.id, "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده است !", "html")
                end
              end
              )
            end
            
            getChannelMembers(msg.chat_id, "Search", 0, 200, GroupMembers)
          end
          if text:match("^(.*)$") and redis:get("cleanword" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local input = text:match("^(.*)$")
            CleanPm(msg, msg.chat_id, "" .. input .. "", "" .. input .. "")
            redis:del("cleanword" .. msg.chat_id .. ":" .. msg.sender_user_id)
          end
          if text:match("^پاکسازی کلمه (.*)") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) and Clean_ModAccess(msg, msg.chat_id, msg.sender_user_id) and acsclean(msg, msg.chat_id, msg.sender_user_id) then
            local username = text:match("^پاکسازی کلمه (.*)")
            CleanPm(msg, msg.chat_id, "" .. username .. "", "" .. username .. "")
          end
        end
        if is_owner(msg.chat_id, msg.sender_user_id) then
          if text == "autolock on" or text == "قفل خودکار فعال" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            leaderonlock(msg, msg.chat_id, "AutoLock:", "قفل خودکار")
          elseif text == "forcejoingp on" or text == "اجبارعضویت فعال" then
            leaderonlock(msg, msg.chat_id, "ForceJoingp:", "اجبار حضور")
          elseif text == "cleanwlc on" or text == "پاکسازی خوشامد فعال" then
            leaderonlock(msg, msg.chat_id, "CleanWlc", "پاکسازی پیام خوشامد")
          elseif text == "cbm on" or text == "پاکسازی ربات فعال" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            leaderonlock(msg, msg.chat_id, "cbmon", "پاکسازی پیام ربات")
          elseif text == "auto demote on" or text == "عزل خودکار فعال" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            leaderonlock(msg, msg.chat_id, "Auto:demote", "عزل خودکار مدیران")
          elseif text == "autoclean on" or text == "پاکسازی خودکار فعال" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            leaderonlock(msg, msg.chat_id, "cgmautoon", "پاکسازی خودکار گروه")
          elseif text == "autolock off" or text == "قفل خودکار غیرفعال" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            leaderofflock(msg, msg.chat_id, "AutoLock:", "قفل خودکار")
            redis:del("AutoLock:" .. msg.chat_id)
            redis:del("automutestart" .. msg.chat_id)
            redis:del("automuteend" .. msg.chat_id)
            redis:del("Lock:AutoGp" .. msg.chat_id)
            redis:del("EndTimeSee" .. msg.chat_id)
            redis:del("StartTimeSee" .. msg.chat_id)
          elseif text == "forcejoingp off" or text == "اجبارعضویت غیرفعال" then
            leaderofflock(msg, msg.chat_id, "ForceJoingp:", "اجبار حضور")
          elseif text == "cleanwlc off" or text == "پاکسازی خوشامد غیرفعال" then
            leaderofflock(msg, msg.chat_id, "CleanWlc", "پاکسازی پیام خوشامد")
          elseif text == "cbm off" or text == "پاکسازی ربات غیرفعال" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            leaderofflock(msg, msg.chat_id, "cbmon", "پاکسازی پیام ربات")
          elseif text == "autoclean off" or text == "پاکسازی خودکار غیرفعال" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            leaderofflock(msg, msg.chat_id, "cgmautoon", "پاکسازی خودکار گروه")
            redis:del("cgmautoon" .. msg.chat_id)
            redis:del("cgmautotime:" .. msg.chat_id)
            redis:del("cgmauto:" .. msg.chat_id)
          elseif text == "auto demote off" or text == "عزل خودکار غیرفعال" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            leaderofflock(msg, msg.chat_id, "Auto:demote", "عزل خودکار مدیران")
          end
          if text == "پیکربندی" or text == "config" and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local GetMod = function(BlaCk, Diamond)
              do
                do
                  for i, i in pairs(Diamond.members) do
                    function ByAddUser(BlaCk, Diamond)
                      if Diamond.type._ == "userTypeBot" then
                        redis:sadd("ModList:" .. msg.chat_id, v.user_id)
                      end
                    end
                    
                    GetUser(i.user_id, ByAddUser)
                  end
                end
              end
            end
            
            getChannelMembers(msg.chat_id, "Administrators", 0, 200, GetMod)
          end
          if text:match("^تنظیم زمان پاکسازی خوشامد (%d+)") then
            local num = text:match("^تنظیم زمان پاکسازی خوشامد (%d+)")
            if tonumber(num) < 10 then
              sendText(msg.chat_id, msg.id, "عددی بزرگتر از 10 وارد کنید", "html")
            else
              redis:set("Max:CleanWlc" .. msg.chat_id, num)
              sendText(msg.chat_id, msg.id, "زمان پاکسازی پیام خوشامد تنظیم شد به : " .. num .. " ثانیه", "html")
            end
          end
          if text:match("^setkick (%d+)") or text:match("^تنظیم تعداد اخراج (%d+)") then
            local num = text:match("^setkick (%d+)") or text:match("^تنظیم تعداد اخراج (%d+)")
            if tonumber(num) < 1 then
              sendText(msg.chat_id, msg.id, "عددی بزرگتر از ۱ وارد کنید", "html")
            else
              redis:set("Kick:Max:" .. msg.chat_id, num)
              sendText(msg.chat_id, msg.id, "تعداد اخراج تنظیم شد به : " .. num .. " نفر", "html")
            end
          end
          if text:match("^(پاکسازی جواب) (.*)") then
            local text = text:match("^پاکسازی جواب (.*)")
            redis:hdel("answer" .. msg.chat_id, text)
            text = "Your Text for Command : " .. text .. " Has been Removed !"
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if text:match("^لیست جواب$") then
            local text = "لیست جواب های ربات:\n\n"
            do
              do
                for i, i in pairs(redis:hkeys("answer" .. msg.chat_id)) do
                  local value = redis:hget("answer" .. msg.chat_id, i)
                  text = text .. "" .. i .. "- " .. i .. " ~~> : " .. value .. "\n"
                end
              end
            end
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if text:match("^جواب روشن$") then
            if not redis:get("autoanswer" .. msg.chat_id) then
              redis:set("autoanswer" .. msg.chat_id, true)
              sendText(msg.chat_id, msg.id, "جواب دهی ربات روشن شد", "html")
            else
              sendText(msg.chat_id, msg.id, "جواب ربات از قبل روشن بود", "html")
            end
          end
          if text:match("^جواب خاموش$") then
            if redis:get("autoanswer" .. msg.chat_id) then
              redis:del("autoanswer" .. msg.chat_id)
              sendText(msg.chat_id, msg.id, "جواب دهی ربات خاموش شد", "html")
            else
              sendText(msg.chat_id, msg.id, "جواب دهی ربات از قبل خاموش بود", "html")
            end
          end
          if text:match("^(جواب) \"(.*)\" \"(.*)\"$") then
            local text = {
              string.match(text, "^(جواب) \"(.*)\" \"(.*)\"$")
            }
            redis:hset("answer" .. msg.chat_id, text[2], text[3])
            text = "جواب \n[" .. text[2] .. "] ~~> : [" .. text[3] .. "]\n تنظیم شد "
            sendText(msg.chat_id, msg.id, text, "html")
          end
          if text:match("^(cgmautotime) (%d+):(%d+)$") or text:match("^(زمان پاکسازی خودکار) (%d+):(%d+)$") then
            local text = text:gsub("زمان پاکسازی خودکار", "cgmautotime")
            local text = {
              string.match(text, "^(cgmautotime) (%d+):(%d+)$")
            }
            local starttime23 = text[2] .. text[3]
            local starttime12 = text[2] .. ":" .. text[3]
            redis:set("cgmautotime:" .. msg.chat_id, starttime23)
            sendText(msg.chat_id, msg.id, "زمان پاکسازی خودکار تنظیم شد به ساعت : {" .. starttime12 .. "}", "md")
          end
          if text == "زمان پاکسازی خودکار" then
            local saat = redis:get("cgmautotime:" .. msg.chat_id) or "0000"
            sendText(msg.chat_id, msg.id, saat, "md")
          end
          if (text:match("^cbmtime (%d+)") or text:match("^زمان پاکسازی ربات (%d+)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local time_match = text:match("^cbmtime (%d+)") or text:match("^زمان پاکسازی ربات (%d+)")
            redis:set("cbmtime:" .. msg.chat_id, time_match)
            sendText(msg.chat_id, msg.id, "پاکسازی خودکار ربات تنظیم شد به: *" .. time_match .. "* ثانیه", "md")
          end
          if lc:match("^setchsup @(%S+)") or lc:match("^تنظیم کانال @(%S+)") then
            local chsup = lc:match("setchsup @(%S+)") or lc:match("^تنظیم کانال @(%S+)")
            redis:set("chsup" .. msg.chat_id, chsup)
            sendText(msg.chat_id, msg.id, "⇋کانال عضویت اجباری تنظیم شد به\n" .. "@" .. chsup .. " ", "html")
          end
          if text == "delch" or text == "حذف کانال" then
            redis:del("chsup" .. msg.chat_id)
          end
          if text == "expire" or text == "اعتبار" then
            local ex = redis:ttl("ExpireData:" .. msg.chat_id)
            year = math.floor(ex / 31536000)
            byear = ex % 31536000
            month = math.floor(byear / 2592000)
            bmonth = byear % 2592000
            dayi = math.floor(bmonth / 86400)
            bday = bmonth % 86400
            hours = math.floor(bday / 3600)
            bhours = bday % 3600
            min = math.floor(bhours / 60)
            sec = math.floor(bhours % 60)
            if ex == -1 then
              text = "• گروه به صورت نامحدود شارژ می‌باشد!"
            elseif tonumber(ex) > 1 and ex < 60 then
              text = "• گروه به مدت *" .. sec .. "* ثانیه شارژ می‌باشد!"
            elseif tonumber(ex) > 60 and ex < 3600 then
              text = "• گروه به مدت *" .. min .. "* دقیقه و *" .. sec .. "* ثانیه شارژ می‌باشد!"
            elseif tonumber(ex) > 3600 and tonumber(ex) < 86400 then
              text = "• گروه به مدت *" .. hours .. "* ساعت و *" .. min .. "* دقیقه و *" .. sec .. "* ثانیه شارژ می‌باشد!"
            elseif tonumber(ex) > 86400 and tonumber(ex) < 2592000 then
              text = "• گروه به مدت *" .. dayi .. "* روز و *" .. hours .. "* ساعت و *" .. min .. "* دقیقه و *" .. sec .. "* ثانیه شارژ می‌باشد!"
            elseif tonumber(ex) > 2592000 and tonumber(ex) < 31536000 then
              text = "• گروه به مدت *" .. month .. "* ماه *" .. dayi .. "* روز و *" .. hours .. "* ساعت و *" .. min .. "* دقیقه و *" .. sec .. "* ثانیه شارژ می‌باشد!"
            elseif tonumber(ex) > 31536000 then
              text = "• گروه به مدت *" .. year .. "* سال *" .. month .. "* ماه *" .. dayi .. "* روز و *" .. hours .. "* ساعت و *" .. min .. "* دقیقه و *" .. sec .. "* ثانیه شارژ می‌باشد!"
            end
            sendText(msg.chat_id, msg.id, text, "md")
          end
          if (text:match("^setrank (.*)$") or text:match("^تنظیم لقب (.*)$")) and 0 < tonumber(msg.reply_to_message_id) then
            local rank = text:match("^setrank (.*)$") or text:match("^تنظیم لقب (.*)$")
            local SetRank_Rep = function(extra, result, success)
              redis:set("rank" .. result.sender_user_id, rank)
              user = "<a href=\"tg://user?id=" .. result.sender_user_id .. "\">" .. result.sender_user_id .. "</a>"
              sendText(msg.chat_id, msg.id, "• لقب کاربر  " .. user .. " به [" .. rank .. "] تغییر کرد!", "html")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), SetRank_Rep)
          end
          if text == "remrank" or text == "حذف لقب" and 0 < tonumber(msg.reply_to_message_id) then
            local RemRank_Rep = function(extra, result, success)
              redis:del("rank" .. result.sender_user_id)
              user = "<a href=\"tg://user?id=" .. result.sender_user_id .. "\">" .. result.sender_user_id .. "</a>"
              sendText(msg.chat_id, msg.id, "• لقب کاربر [ " .. user .. " ] حذف شد!", "html")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), RemRank_Rep)
          end
          if (text == "promote" or text == "ارتقا مقام" or text == "مدیر" or text == "ترفیع") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            function SetModByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                PromoteMember(msg, msg.chat_id, result.sender_user_id, "مدیران گروه", "ModList:", "Leader")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), SetModByReply)
          end
          if (text == "demote" or text == "عزل مقام" or text == "عزل" or text == "حذف مدیر") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            function RemModByReply(extra, result, success)
              if not result.sender_user_id then
                sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
              else
                DemoteMember(msg, msg.chat_id, result.sender_user_id, "مدیران گروه", "ModList:", "Leader")
              end
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), RemModByReply)
          end
          if text:match("^promote @(.*)") or text:match("^ارتقا مقام @(.*)") or text:match("^مدیر @(.*)") or text:match("^ترفیع @(.*)") then
            local username = text:match("^promote @(.*)") or text:match("^ارتقا مقام @(.*)") or text:match("^مدیر @(.*)") or text:match("^ترفیع @(.*)")
            function PromoteByUsername(extra, result, success)
              if result.id then
                PromoteMember(msg, msg.chat_id, result.id, "مدیران گروه", "ModList:", "Leader")
              else
                text = "• کاربر مورد نظر یافت نشد !"
                sendText(msg.chat_id, msg.id, text, "html")
              end
            end
            
            searchPublicChat(username, PromoteByUsername)
          end
          if text:match("^promote (%d+)") or text:match("^ارتقا مقام (%d+)") or text:match("^مدیر (%d+)") or text:match("^ترفیع (%d+)") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local user = text:match("promote (%d+)") or text:match("ارتقا مقام (%d+)") or text:match("مدیر (%d+)") or text:match("ترفیع (%d+)")
            PromoteMember(msg, msg.chat_id, user, "مدیران گروه", "ModList:", "Leader")
          end
          if text:match("^demote @(.*)") or text:match("^عزل مقام @(.*)") or text:match("^عزل @(.*)") or text:match("^حذف مدیر @(.*)") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local username = text:match("^demote @(.*)") or text:match("^عزل مقام @(.*)") or text:match("^حذف مدیر @(.*)") or text:match("^عزل @(.*)")
            function PromoteByUsername(extra, result, success)
              if result.id then
                DemoteMember(msg, msg.chat_id, result.id, "مدیران گروه", "ModList:", "Leader")
              else
                text = "• کاربر مورد نظر یافت نشد !"
                sendText(msg.chat_id, msg.id, text, "html")
              end
            end
            
            searchPublicChat(username, PromoteByUsername)
          end
          if text:match("^demote (%d+)") or text:match("^عزل مقام (%d+)") then
            local user = text:match("demote (%d+)") or text:match("^عزل مقام (%d+)")
            DemoteMember(msg, msg.chat_id, user, "مدیران گروه", "ModList:", "Leader")
          end
          if text == "setphoto" or text == "تنظیم عکس گروه" and 0 < tonumber(msg.reply_to_message_id) then
            function tophoto(extra, result, success)
              if result.content._ == "messagePhoto" then
                sendText(msg.chat_id, msg.id, "انجام شد\nعکس گروه با موفقیت تغییر یافت", "html")
                print(result.content.photo.persistent_id)
                changeChatPhoto(msg.chat_id, result.content.photo.sizes[0].photo.persistent_id)
              else
                text = "خطا !"
                sendText(msg.chat_id, msg.id, text, "html")
              end
            end
            
            getMessage(msg.chat_id, msg.reply_to_message_id, tophoto)
          end
          if (text:match("^[Ss]etabout (.*)") or text:match("^تنظیم درباره گروه (.*)")) and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local description = text:match("^[Ss]etabout (.*)") or text:match("^تنظیم درباره گروه (.*)")
            changeDes(msg.chat_id, description)
            local text = " • درباره گروه به  " .. description .. " تغییر یافت! "
            sendText(msg.chat_id, msg.id, text, "md")
          end
          if text:match("^setname (.*)") or text:match("^تنظیم نام (.*)") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local Title = text:match("^setname (.*)") or text:match("^تنظیم نام (.*)")
            local GetName = function(extra, result, success)
              local Hash = "StatsGpByName" .. msg.chat_id
              local ChatTitle = result.title
              redis:set(Hash, ChatTitle)
              changeChatTitle(msg.chat_id, Title)
              local text = " • نام گروه تغییر یافت به : " .. Title
              sendText(msg.chat_id, msg.id, text, "md")
            end
            
            GetChat(msg.chat_id, GetName)
          end
          if text:match("^(قفل خودکار) (%d+):(%d+)-(%d+):(%d+)$") or text:match("^(autolock) (%d+):(%d+)-(%d+):(%d+)$") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            local text = text:gsub("قفل خودکار", "autolock")
            local text = {
              string.match(text, "^(autolock) (%d+):(%d+)-(%d+):(%d+)$")
            }
            if redis:get("AutoLock:" .. msg.chat_id) then
              auto = "فعال"
            else
              auto = "غیرفعال"
            end
            local endtime = text[4] .. text[5]
            local endtime1 = text[4] .. ":" .. text[5]
            local starttime2 = text[2] .. ":" .. text[3]
            redis:set("EndTimeSee" .. msg.chat_id, endtime1)
            redis:set("StartTimeSee" .. msg.chat_id, starttime2)
            local starttime = text[2] .. text[3]
            if endtime1 == starttime2 then
              test = "• شروع قفل خودکار نمیتواند با پایان آن یکی باشد!"
              sendText(msg.chat_id, msg.id, test, "md")
            else
              redis:set("automutestart" .. msg.chat_id, starttime)
              redis:set("automuteend" .. msg.chat_id, endtime)
              test = "• گروه شما به صورت خودکار از ساعت  * " .. starttime2 .. "* قفل و در ساعت  *" .. endtime1 .. "* باز میشود!\n\nوضعیت قفل خودکار : `" .. auto .. "`"
              sendText(msg.chat_id, msg.id, test, "md")
            end
          end
          if (text == "time sv" or text == "ساعت سرور") and is_JoinChannel(msg, msg.chat_id, msg.sender_user_id) then
            text = "• ساعت : " .. os.date("%S : %M : %H")
            sendText(msg.chat_id, msg.id, text, "md")
          end
        end
        if is_sudo(msg.sender_user_id) then
          if text == "chats" or text == "لیست گروه ها" then
            local list = redis:smembers("group:")
            local t = "• لیست گروه ها ربات\n\n"
            do
              do
                for i, i in pairs(list) do
                  local expire = redis:ttl("ExpireData:" .. i)
                  if expire == -1 then
                    EXPIRE = "نامحدود"
                  else
                    local d = math.floor(expire / 86400) + 1
                    EXPIRE = d .. " روز"
                  end
                  local GroupsName = redis:get("StatsGpByName" .. i)
                  t = t .. i .. "-\n• شناسه گروه : [" .. i .. "]\n• اسم گروه : [" .. (GroupsName or "یافت نشد.") .. "]\n• تاریخ انقضا گروه : [" .. EXPIRE .. "]\n┅┈┅┈┅┈┅┈┅┈┅┈┅┈┅┈┅┈┅┈┅\n"
                end
              end
            end
            local file = io.open("./data/GroupList.txt", "w")
            file:write(t)
            file:close()
            if #list == 0 then
              t = "لیست گروهها خالی میباشد!"
            end
            sendDocument(msg.chat_id, msg.id, 0, 1, nil, "./data/GroupList.txt")
          end
          if text == "gid" or text == "ایدی گروه" then
            sendText(msg.chat_id, msg.id, "• شناسه گروه شما :`" .. msg.chat_id .. "`", "md")
          end
          if text == "server info" or text == "اطلاعات سرور" then
            local text = io.popen("sh ./data/ServerInfo.sh"):read("*all")
            sendText(msg.chat_id, msg.id, text, "md")
          end
          if text == "اطلاعات پیام" and tonumber(msg.reply_to_message_id) ~= 0 then
            function id_by_reply(extra, result, success)
              local TeXT = serpent.block(result, {comment = false})
              text = string.gsub(TeXT, "\n", "\n\r\n")
              sendText(msg.chat_id, msg.id, text, "html")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), id_by_reply)
          end
          if text == "setowner" or text == "مالک" and tonumber(msg.reply_to_message_id) ~= 0 then
            local SetOwnerRep = function(extra, result, success)
              PromoteMember(msg, msg.chat_id, result.sender_user_id, "مالکین گروه", "OwnerList:", "Leader")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), SetOwnerRep)
          end
          if text:match("^setowner (%d+)") or text:match("^مالک (%d+)") then
            local user = text:match("setowner (%d+)") or text:match("^مالک (%d+)")
            PromoteMember(msg, msg.chat_id, user, "مالکین گروه", "OwnerList:", "Leader")
          end
          if text:match("^setowner @(.*)") or text:match("^مالک @(.*)") then
            local username = text:match("^setowner @(.*)") or text:match("^مالک @(.*)")
            function SetOwnerByUsername(extra, result, success)
              if result.id then
                PromoteMember(msg, msg.chat_id, result.id, "مالکین گروه", "OwnerList:", "Leader")
              else
                text = "• کاربر یافت نشد!"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, SetOwnerByUsername)
          end
          if text == "remowner" or text == "حذف مالک" and tonumber(msg.reply_to_message_id) ~= 0 then
            local RemOwner_Rep = function(extra, result, success)
              DemoteMember(msg, msg.chat_id, result.sender_user_id, "مالکین گروه", "OwnerList:", "Leader")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), RemOwner_Rep)
          end
          if text:match("^remowner (%d+)") or text:match("^حذف مالک (%d+)") then
            local user = text:match("remowner (%d+)") or text:match("^حذف مالک (%d+)")
            DemoteMember(msg, msg.chat_id, user, "مالکین گروه", "OwnerList:", "Leader")
          end
          if text:match("^remowner @(.*)") or text:match("^حذف مالک @(.*)") then
            local username = text:match("^remowner @(.*)") or text:match("^حذف مالک @(.*)")
            function RemOwnerByUsername(extra, result, success)
              if result.id then
                DemoteMember(msg, msg.chat_id, result.id, "مالکین گروه", "OwnerList:", "Leader")
              else
                text = "• کاربر یافت نشد!"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, RemOwnerByUsername)
          end
          if text == "mutealluser" or text == "addtabchi" or text == "سکوت همگانی" and tonumber(msg.reply_to_message_id) ~= 0 then
            function GbanByReply(extra, result, success)
              PromoteMember(msg, msg.chat_id, result.sender_user_id, "بیصدا همگانی", "GlobalyBannedd:", "MuteAll")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), GbanByReply)
          end
          if text:match("^mutealluser (%d+)") or text:match("^addtabchi (%d+)") or text:match("^بیصدا همگانی (%d+)") then
            local user = text:match("^mutealluser (%d+)") or text:match("^addtabchi (%d+)") or text:match("^بیصدا همگانی (%d+)")
            PromoteMember(msg, msg.chat_id, user, "بیصدا همگانی", "GlobalyBannedd:", "MuteAll")
          end
          if text:match("^mutealluser @(.*)") or text:match("^بیصدا همگانی @(.*)") or text:match("^addtabchi @(.*)") then
            local username = text:match("^mutealluser @(.*)") or text:match("^بیصدا همگانی @(.*)") or text:match("^addtabchi @(.*)")
            function BanallByUsername(extra, result, success)
              if result.id then
                PromoteMember(msg, msg.chat_id, result.id, "بیصدا همگانی", "GlobalyBannedd:", "MuteAll")
              else
                text = "• کاربر یافت نشد!"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, BanallByUsername)
          end
          if text == "unmuteall" or text == "حذف بیصدا همگانی" or text == "remtabchi" and tonumber(msg.reply_to_message_id) ~= 0 then
            local gp = redis:scard("group:")
            function UnGbanByReply(extra, result, success)
              DemoteMember(msg, msg.chat_id, result.sender_user_id, "بیصدا همگانی", "GlobalyBannedd:", "UnMuteAll")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), UnGbanByReply)
          end
          if text:match("^unmuteall (%d+)") or text:match("^حذف بیصدا همگانی (%d+)") or text:match("^remtabchi (%d+)") then
            local user = text:match("unmuteall (%d+)") or text:match("حذف بیصدا همگانی (%d+)") or text:match("^remtabchi (%d+)")
            DemoteMember(msg, msg.chat_id, user, "بیصدا همگانی", "GlobalyBannedd:", "UnMuteAll")
          end
          if text:match("^unmuteall @(.*)") or text:match("^حذف بیصدا همگانی @(.*)") or text:match("^remtabchi @(.*)") then
            local username = text:match("^unmuteall @(.*)") or text:match("^حذف بیصدا همگانی @(.*)") or text:match("^remtabchi @(.*)")
            function UnbanallByUsername(extra, result, success)
              if result.id then
                DemoteMember(msg, msg.chat_id, result.id, "بیصدا همگانی", "GlobalyBannedd:", "UnMuteAll")
              else
                text = "• کاربر یافت نشد!"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, UnbanallByUsername)
          end
          if text == "banall" or text == "مسدودهمگانی" and tonumber(msg.reply_to_message_id) ~= 0 then
            function GbanByReply(extra, result, success)
              PromoteMember(msg, msg.chat_id, result.sender_user_id, "مسدود همگانی", "GlobalyBanned:", "BanAll")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), GbanByReply)
          end
          if text:match("^banall (%d+)") or text:match("^مسدودهمگانی (%d+)") then
            local user = text:match("^banall (%d+)") or text:match("^مسدودهمگانی (%d+)")
            PromoteMember(msg, msg.chat_id, user, "مسدود همگانی", "GlobalyBanned:", "BanAll")
          end
          if text:match("^banall @(.*)") or text:match("^مسدودهمگانی @(.*)") then
            local username = text:match("^banall @(.*)") or text:match("^مسدودهمگانی @(.*)")
            function BanallByUsername(extra, result, success)
              if result.id then
                PromoteMember(msg, msg.chat_id, result.id, "مسدود همگانی", "GlobalyBanned:", "BanAll")
              else
                text = "• کاربر یافت نشد!"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, BanallByUsername)
          end
          if (text == "unbanall" or text == "حذف مسدود همگانی") and tonumber(msg.reply_to_message_id) ~= 0 then
            function UnGbanByReply(extra, result, success)
              DemoteMember(msg, msg.chat_id, result.sender_user_id, "مسدود همگانی", "GlobalyBanned:", "UnBanAll")
            end
            
            getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), UnGbanByReply)
          elseif text:match("^unbanall (%d+)") or text:match("^حذف مسدود همگانی (%d+)") then
            local user = text:match("unbanall (%d+)") or text:match("حذف مسدود همگانی (%d+)")
            DemoteMember(msg, msg.chat_id, user, "مسدود همگانی", "GlobalyBanned:", "UnBanAll")
          end
          if text:match("^unbanall @(.*)") or text:match("^حذف مسدود همگانی @(.*)") then
            local username = text:match("^unbanall @(.*)") or text:match("^حذف مسدود همگانی @(.*)")
            function UnbanallByUsername(extra, result, success)
              if result.id then
                DemoteMember(msg, msg.chat_id, result.id, "مسدود همگانی", "GlobalyBanned:", "UnBanAll")
              else
                text = "• کاربر یافت نشد!"
                sendText(msg.chat_id, msg.id, text, "md")
              end
            end
            
            searchPublicChat(username, UnbanallByUsername)
          end
        end
        if not msg.sender_user_id or is_JoinChannell(msg, msg.chat_id, msg.sender_user_id) then
        end
        if text == "بای" or text == "فلن" or text == "خدافظ" then
          local Bot = redis:get("rank" .. msg.sender_user_id)
          if redis:get("rank" .. msg.sender_user_id) then
            local rankpro = {
              "بای " .. Bot .. "",
              "بسلامت " .. Bot .. "",
              "داری میری! " .. Bot .. ""
            }
            sendText(msg.chat_id, msg.id, rankpro[math.random(#rankpro)], "md")
          else
            local rank = {
              "بای😐",
              "فلن",
              "بابای",
              "کجا",
              "داری میری!"
            }
            sendText(msg.chat_id, msg.id, rank[math.random(#rank)], "md")
          end
        end
        if text == "date" or text == "تاریخ" then
          local time = jdate("• ساعت: #h:#m:#s \n• تاریخ: #x , #Y/#M/#D \n• فصل: #F\n• حیوان سال: #y \n• ذکر: #z") or "خطا در اتصال"
          sendText(msg.chat_id, msg.id, time, "html")
        end
        if redis:get("autoanswer" .. msg.chat_id) then
          do
            local names = redis:hkeys("answer" .. msg.chat_id)
            do
              for i = 1, #names do
                if text == names[i] then
                  local txtt = redis:hget("answer" .. msg.chat_id, names[i])
                  sendText(msg.chat_id, msg.id, txtt, "html")
                end
              end
            end
          end
        end
      end
    end
    if gp_type(msg.chat_id) == "pv" then
      if msg.sender_user_id and not redis:sismember("ChatPrivite", msg.sender_user_id) then
        redis:sadd("ChatPrivite", msg.sender_user_id)
      end
      if text or lc then
        if is_Fullsudo(msg.sender_user_id) then
          if lc:match("^(.*)$") and redis:get("usersudowait" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local input = lc:match("^(.*)$")
            redis:set("usersudo", input)
            sendText(msg.chat_id, msg.id, "• یوزرنیم شما باموفقیت تغییر یافت !", "html")
            redis:del("usersudowait" .. msg.chat_id .. ":" .. msg.sender_user_id)
          end
          if lc:match("^(.*)$") and redis:get("WaitSetClerk" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local input = lc:match("^(.*)$")
            redis:set("startmttn", input)
            sendText(msg.chat_id, msg.id, "• متن منشی شما با موفقیت تنظیم شد !", "html")
            redis:del("WaitSetClerk" .. msg.chat_id .. ":" .. msg.sender_user_id)
          end
          if lc:match("^(.*)$") and redis:get("setchjoinwait" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local input = lc:match("^(.*)$")
            redis:set("chjoin", input)
            sendText(msg.chat_id, msg.id, "• ایدی کانال جوین اجباری با موفقیت تنظیم شد !", "html")
            redis:del("setchjoinwait" .. msg.chat_id .. ":" .. msg.sender_user_id)
          end
          if lc:match("^(.*)$") and redis:get("setchcmdwait" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local input = lc:match("^(.*)$")
            redis:set("chcmd", input)
            sendText(msg.chat_id, msg.id, "• ایدی کانال دستورات با موفقیت تنظیم شد !", "html")
            redis:del("setchcmdwait" .. msg.chat_id .. ":" .. msg.sender_user_id)
          end
          if lc:match("^(.*)$") and redis:get("sudoabotoset" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local input = lc:match("^(.*)$")
            redis:set("startmttnn", input)
            sendText(msg.chat_id, msg.id, "• متن درباره ربات شما با موفقیت تنظیم شد !", "html")
            redis:del("sudoabotoset" .. msg.chat_id .. ":" .. msg.sender_user_id)
          end
          if lc:match("^(.*)$") and redis:get("resetnerkhset" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local input = lc:match("^(.*)$")
            redis:set("ner", input)
            sendText(msg.chat_id, msg.id, "• متن نرخ شما با موفقیت تنظیم شد !", "html")
            redis:del("resetnerkhset" .. msg.chat_id .. ":" .. msg.sender_user_id)
          end
          if lc:match("^(.*)$") and redis:get("setendsgsset" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local input = lc:match("^(.*)$")
            redis:set("EndMsg", input)
            sendText(msg.chat_id, msg.id, "• متن پیام اخر شما با موفقیت تنظیم شد !", "html")
            redis:del("setendsgsset" .. msg.chat_id .. ":" .. msg.sender_user_id)
          end
        end
        if msg.sender_user_id ~= BotHelper then
          if lc == "دلیت اکانت" or lc == "delac" then
            sendText(msg.chat_id, msg.id, "• شماره تلفن خود را طبق مثال زیر ارسال کنید !\n +989180000000", "md")
            redis:setex("start:ts" .. msg.chat_id .. ":" .. msg.sender_user_id, 120, true)
          end
          if text:match("^(+)(%d+)$") and redis:get("start:ts" .. msg.chat_id .. ":" .. msg.sender_user_id) then
            local number = text:match("^(.*)$")
            local url, res = http.request("http://kings-afg.tk/api/delacc/?phone=" .. number)
            if res ~= 200 then
              sendText(msg.chat_id, msg.id, " خطا در اتصال به وب سرویس !", "html")
            else
              jdat = json:decode(url)
              sendText(msg.chat_id, msg.id, "لینک با موفقیت ساخته شد لطفا دستور \n رمز {رمز دلیت اکانت} \nرا ارسال کنید", "md")
              redis:set(TD_ID .. "DelAchash" .. msg.sender_user_id, jdat.result.access_hash)
              redis:set(TD_ID .. "DelAcnum" .. msg.sender_user_id, number)
            end
          end
          if lc:match("^رمز (.*)") then
            local psswd = lc:match("^رمز (.*)")
            local hashdelac = redis:get(TD_ID .. "DelAchash" .. msg.sender_user_id) or 0
            local numdelac = redis:get(TD_ID .. "DelAcnum" .. msg.sender_user_id) or 0
            local deleted, res = http.request("http://kings-afg.tk/api/delacc/?phone=" .. numdelac .. "&access_hash=" .. hashdelac .. "&password=" .. psswd .. "&do_delete=true")
            if res ~= 200 then
              sendText(msg.chat_id, msg.id, " خطا در اتصال به وب سرویس !", "html")
            else
              jdat = json:decode(deleted)
              sendText(msg.chat_id, msg.id, "اکانت با موفقیت دیلیت شد !\nاطلاعات اکانت دلیت شده :\nشماره : " .. numdelac .. "\nپسورد : " .. psswd, "html")
            end
            redis:del(TD_ID .. "DelAchash" .. msg.sender_user_id)
            redis:del(TD_ID .. "DelAcnum" .. msg.sender_user_id)
            redis:del("start:ts2" .. msg.sender_user_id)
          end
        end
      end
    end
    if text or lc then
      if is_sudo(msg.sender_user_id) then
        if text == "آمار ربات" or text == "stats" then
          local pvs = redis:scard("ChatPrivite")
          local addgps = redis:scard("group:")
          local whoami = io.popen("whoami"):read("*a")
          local uptime = io.popen("uptime"):read("*all")
          SRtext = " به بخش امار ربات مدیریت گروه خوش امدید.\n\n• تعداد سوپر گروه ها : " .. addgps .. "\n• تعداد خصوصی ها : " .. pvs .. "\n• شماره ردیس : " .. rediscode .. "\n• یوزر : " .. whoami .. "\n\n• اپتایم سرور : " .. uptime .. ""
          sendText(msg.chat_id, msg.id, SRtext, "html")
        elseif text == "لیست سودو" or text == "sudolist" then
          leaderList(msg, msg.chat_id, redis:smembers("SUDO-ID"), "مدیران")
        elseif text == "لیست مسدود همگانی" or text == "gbanlist" then
          leaderList(msg, msg.chat_id, redis:smembers("GlobalyBanned:"), "مسدود همگانی")
        elseif text == "لیست سکوت کلی" or text == "mutealllist" then
          leaderList(msg, msg.chat_id, redis:smembers("GlobalyBannedd:"), "سکوت همگانی")
        elseif text == "شارژ ربات" then
          local check_time = redis:ttl("Expirebot:" .. Sudoid)
          year = math.floor(check_time / 31536000)
          byear = check_time % 31536000
          month = math.floor(byear / 2592000)
          bmonth = byear % 2592000
          day = math.floor(bmonth / 86400)
          bday = bmonth % 86400
          hours = math.floor(bday / 3600)
          bhours = bday % 3600
          min = math.floor(bhours / 60)
          sec = math.floor(bhours % 60)
          if check_time == -1 then
            remained_expire = "نامحدود"
          elseif tonumber(check_time) > 1 and check_time < 60 then
            remained_expire = "" .. sec .. " ثانیه شارژ میباشد"
          elseif tonumber(check_time) > 60 and check_time < 3600 then
            remained_expire = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
          elseif tonumber(check_time) > 3600 and tonumber(check_time) < 86400 then
            remained_expire = "" .. hours .. " ساعت و " .. min .. " دقیقه و " .. sec .. " ثانیه"
          elseif tonumber(check_time) > 86400 and tonumber(check_time) < 2592000 then
            remained_expire = "" .. day .. " روز و " .. hours .. " ساعت و " .. min .. " دقیقه و " .. sec .. " ثانیه"
          elseif tonumber(check_time) > 2592000 and tonumber(check_time) < 31536000 then
            remained_expire = "" .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت و " .. min .. " دقیقه و " .. sec .. " ثانیه"
          elseif tonumber(check_time) > 31536000 then
            remained_expire = "" .. year .. " سال " .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت و " .. min .. " دقیقه و " .. sec .. " ثانیه"
          end
          SRtext = "ربات دارای " .. remained_expire .. " اعتبار میباشد"
          sendText(msg.chat_id, msg.id, SRtext, "html")
        end
      end
      if is_Fullsudo(msg.sender_user_id) then
        if text == "reset" or text == "ریست" then
          local sgps = redis:smembers("group:") or 0
          do
            for i, i in pairs(sgps) do
              redis:del("Total:Stickers:" .. i)
              redis:del("Total:Text:" .. i)
              redis:del("Total:ChatDeleteMember:" .. i)
              redis:del("Total:ChatJoinByLink:" .. i)
              redis:del("Total:Audio:" .. i)
              redis:del("Total:Voice:" .. i)
              redis:del("Total:Video:" .. i)
              redis:del("Total:Animation:" .. i)
              redis:del("Total:Location:" .. i)
              redis:del("Total:ForwardedFromUser:" .. i)
              redis:del("Total:Document:" .. i)
              redis:del("Total:Contact:" .. i)
              redis:del("Total:Photo:" .. i)
              redis:del("Total:messages:" .. i)
              redis:del("Total:added:" .. i)
              local users = redis:smembers("Total:users:" .. i)
              do
                do
                  for i, i in pairs(users) do
                    redis:del("Total:messages:" .. i .. ":" .. i)
                    redis:del("Total:added:" .. i .. ":" .. i)
                  end
                end
              end
              redis:del("Total:users:" .. i)
            end
          end
        end
        if text == "حذف جواب" then
          redis:del("STICKERS:")
          sendText(msg.chat_id, msg.id, "انجام شد", "md")
        elseif text == "جواب ربات" and 0 < tonumber(msg.reply_to_message_id) then
          function Saved(CerNer, Company)
            if Company.content._ == "messageSticker" then
              redis:sadd("STICKERS:", Company.content.sticker.sticker.persistent_id)
              sendText(msg.chat_id, msg.id, "انجام شد", "md")
            else
              sendText(msg.chat_id, msg.id, "خطا!\n لططفا روی یک استیکر ریپلی کنید", "md")
            end
          end
          
          getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), Saved)
        elseif text == "reload" or text == "ریلود" then
          sendText(msg.chat_id, msg.id, "• سیستم ربات هلپر بروزرسانی شد!", "md")
          dofile("./bot.lua")
        elseif text == "forcejoin on" or text == "جوین اجباری فعال" then
          leaderonlock(msg, msg.chat_id, "ForceJoin:", "جوین اجباری گروه")
        elseif text == "forcejoin off" or text == "جوین اجباری غیرفعال" then
          leaderofflock(msg, msg.chat_id, "ForceJoin:", "جوین اجباری گروه")
        elseif (text == "setsudo" or text == "افزودن سودو") and tonumber(msg.reply_to_message_id) ~= 0 then
          local SetSudo = function(extra, result, success)
            if not result.sender_user_id then
              sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
            else
              PromoteMember(msg, msg.chat_id, result.sender_user_id, "مدیران ربات", "SUDO-ID", "LeaderS")
            end
          end
          
          getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), SetSudo)
        elseif text:match("^setsudo (%d+)") or text:match("^افزودن سودو (%d+)") then
          local sudo = text:match("^setsudo (%d+)") or text:match("^افزودن سودو (%d+)")
          PromoteMember(msg, msg.chat_id, sudo, "مدیران ربات", "SUDO-ID", "LeaderS")
        elseif text:match("^setsudo @(.*)") or text:match("^افزودن سودو @(.*)") then
          local username = text:match("^setsudo @(.*)") or text:match("^افزودن سودو @(.*)")
          function SetSudouserr(extra, result, success)
            if result.id then
              PromoteMember(msg, msg.chat_id, result.id, "مدیران ربات", "SUDO-ID", "LeaderS")
            else
              text = "• کاربر یافت نشد"
              sendText(msg.chat_id, msg.id, text, "md")
            end
          end
          
          searchPublicChat(username, SetSudouserr)
        elseif (text == "remsudo" or text == "حذف سودو") and tonumber(msg.reply_to_message_id) ~= 0 then
          local RemSudo = function(extra, result, success)
            if not result.sender_user_id then
              sendText(msg.chat_id, msg.id, "• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .", "html")
            else
              DemoteMember(msg, msg.chat_id, result.sender_user_id, "مدیران ربات", "SUDO-ID", "LeaderS")
            end
          end
          
          getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), RemSudo)
        elseif text:match("^remsudo (%d+)") or text:match("^حذف سودو (%d+)") then
          local sudo = text:match("^remsudo (%d+)") or text:match("^حذف سودو (%d+)")
          DemoteMember(msg, msg.chat_id, sudo, "مدیران ربات", "SUDO-ID", "LeaderS")
        elseif text:match("^remsudo @(.*)") or text:match("^حذف سودو @(.*)") then
          local username = text:match("^remsudo @(.*)") or text:match("^حذف سودو @(.*)")
          function SetSudouserr(extra, result, success)
            if result.id then
              DemoteMember(msg, msg.chat_id, result.id, "مدیران ربات", "SUDO-ID", "LeaderS")
            else
              text = "• کاربر یافت نشد"
              sendText(msg.chat_id, msg.id, text, "md")
            end
          end
          
          searchPublicChat(username, SetSudouserr)
        elseif text == "پاکسازی کش" then
          io.popen("rm -rf ~/.telegram-bot/LcApi/files/animations/*")
          io.popen("rm -rf ~/.telegram-bot/LcApi/files/documents/*")
          io.popen("rm -rf ~/.telegram-bot/LcApi/files/music/*")
          io.popen("rm -rf ~/.telegram-bot/LcApi/files/photos/*")
          io.popen("rm -rf ~/.telegram-bot/LcApi/files/temp/*")
          io.popen("rm -rf ~/.telegram-bot/LcApi/files/video_notes/*")
          io.popen("rm -rf ~/.telegram-bot/LcApi/data/thumbnails/*")
          io.popen("rm -rf ~/.telegram-bot/LcApi/data/stickers/*")
          io.popen("rm -rf ~/.telegram-bot/LcApi/files/videos/*")
          io.popen("rm -rf ~/.telegram-bot/LcApi/files/voice/*")
          io.popen("rm -rf ~/.telegram-bot/LcCli/files/animations/*")
          io.popen("rm -rf ~/.telegram-bot/LcCli/files/documents/*")
          io.popen("rm -rf ~/.telegram-bot/LcCli/files/music/*")
          io.popen("rm -rf ~/.telegram-bot/LcCli/files/photos/*")
          io.popen("rm -rf ~/.telegram-bot/LcCli/files/temp/*")
          io.popen("rm -rf ~/.telegram-bot/LcCli/files/video_notes/*")
          io.popen("rm -rf ~/.telegram-bot/LcCli/files/videos/*")
          io.popen("rm -rf ~/.telegram-bot/LcCli/files/voice/*")
          io.popen("rm -rf ~/.telegram-bot/LcCli/data/thumbnails/*")
          SRtext = "حافظه کش پاکسازی شد"
          sendText(msg.chat_id, msg.id, SRtext, "html")
        elseif text == "autoadd on" or text == "نصب خودکار فعال" then
          redis:set("AutoInstall" .. Sudoid, true)
          SRtext = "• نصب خودکار گروه فعال شد!"
          sendText(msg.chat_id, msg.id, SRtext, "html")
        elseif text == "autoadd off" or text == "نصب خودکار غیرفعال" then
          SRtext = "• نصب خودکار گروه غیر فعال شد!"
          sendText(msg.chat_id, msg.id, SRtext, "html")
          redis:del("AutoInstall" .. Sudoid)
        elseif text == "delsetstart" or text == "حذف پیام منشی" then
          redis:del("startmttn")
          SRtext = "انجام شد"
          sendText(msg.chat_id, msg.id, SRtext, "html")
        elseif text:match("^setstart (.*)") or lc:match("^تنظیم منشی(.*)") then
          local ner = text:match("setstart (.*)") or lc:match("^تنظیم منشی (.*)")
          redis:set("startmttn", ner)
          SRtext = "• پیام استارت ربات تنظیم شد به\n\n[" .. ner .. "] "
          sendText(msg.chat_id, msg.id, SRtext, "html")
        elseif text:match("^setEndMsg (.*)") or lc:match("^تنظیم پیام اخر(.*)") then
          local EndMsg = text:match("setEndMsg (.*)") or lc:match("^تنظیم پیام اخر(.*)")
          redis:set("EndMsg", EndMsg)
          SRtext = "• پیام اخر ربات تنظیم شد به\n[" .. EndMsg .. "]"
          sendText(msg.chat_id, msg.id, SRtext, "html")
        elseif text == "حذف پیام اخر" or text == "delEndMsg" then
          redis:del("EndMsg")
          SRtext = "• پیام اخر حذف شد"
          sendText(msg.chat_id, msg.id, SRtext, "html")
        elseif text == "clean sudos" or text == "پاکسازی سودو" then
          redis:del("SUDO-ID")
          SRtext = "• لیست سودو های ربات پاکسازی شد!"
          sendText(msg.chat_id, msg.id, SRtext, "md")
        end
      end
    end
  end
end

function tdbot_update_callback(data)
  if data._ == "updateNewMessage" or data._ == "updateNewChannelMessage" then
    showedit(data.message, data)
    local msg = data.message
    openChat(msg.chat_id)
    if msg.sender_user_id and is_GlobalyBan(msg.sender_user_id) then
      KickUser(msg.chat_id, msg.sender_user_id)
    elseif msg.sender_user_id and is_GlobalyBann(msg.sender_user_id) then
      redis:sadd("MuteList:" .. msg.chat_id, msg.sender_user_id)
      mute(msg.chat_id, msg.sender_user_id, "Restricted", {
        1,
        0,
        0,
        0,
        0,
        0
      })
    end
  elseif data._ == "updateMessageEdited" then
    showedit(data.message, data)
    local edit = function(extra, result, success)
      showedit(result, data)
    end
    
    assert(tdbot_function({
      _ = "getMessage",
      chat_id = data.chat_id,
      message_id = data.message_id
    }, edit, nil))
    assert(tdbot_function({
      _ = "openChat",
      chat_id = data.chat_id
    }, dl_cb, nil))
    assert(tdbot_function({
      _ = "openMessageContent",
      chat_id = data.chat_id,
      message_id = data.message_id
    }, dl_cb, nil))
    assert(tdbot_function({
      _ = "getChats",
      offset_order = "9223372036854775807",
      offset_chat_id = 0,
      limit = 20
    }, dl_cb, nil))
  end
end

