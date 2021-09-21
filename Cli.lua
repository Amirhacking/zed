dofile("./Config.lua")
json = dofile("./libs/JSON.lua")
serpent = require("serpent")
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
leader = 935076871
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
leader = 935076871
local getParse = function(parse_mode)
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
  if user == 935076871 then
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

function is_Helper(msg)
  local var = false
  if msg.sender_user_id == BotHelper then
    var = true
  end
  return var
end

function dl_cb(arg, data)
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

function dl_cb(arg, data)
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

local Bot_Api = "https://api.telegram.org/bot" .. token
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

function sleep(time)
  local clock = os.clock
  local t0 = clock()
  while time >= clock() - t0 do
  end
end

local Tr = function()
  local totaldump = io.popen("du -h /var/lib/redis/dump.rdb"):read("*all")
  s = totaldump:match("%d+K") or totaldump:match("%d+M")
  return s
end

local sc = function()
  local totaldump = io.popen("du -h bot/Bot.lua"):read("*all")
  s = totaldump:match("%d+K") or totaldump:match("%d+M")
  return s
end

local scs = function()
  local totaldump = io.popen("du -h bot/Helper.lua"):read("*all")
  s = totaldump:match("%d+K") or totaldump:match("%d+M")
  return s
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

local getChatId = function(chat_id)
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

function Td_boT(chat_id, msg, text, parse)
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

local getMe = function(cb)
  assert(tdbot_function({_ = "getMe"}, cb, nil))
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

function getFile(fileid, cb)
  assert(tdbot_function({_ = "getFile", file_id = fileid}, cb, nil))
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

function changeDes(LeaderCode, TDBot)
  assert(tdbot_function({
    _ = "changeChannelDescription",
    channel_id = getChatId(LeaderCode).id,
    description = TDBot
  }, dl_cb, nil))
end

function changeChatTitle(chat_id, title)
  assert(tdbot_function({
    _ = "changeChatTitle",
    chat_id = chat_id,
    title = title
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

function resolve_username(username, cb)
  tdbot_function({
    _ = "searchPublicChat",
    username = username
  }, cb, nil)
end

function searchPublicChat(username, cb)
  assert(tdbot_function({
    _ = "searchPublicChat",
    username = username
  }, cb, nil))
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

function getChatHistory(chat_id, from_message_id, offset, limit, cb)
  tdbot_function({
    _ = "getChatHistory",
    chat_id = chat_id,
    from_message_id = from_message_id,
    offset = offset,
    limit = limit
  }, cb, nil)
end

function deleteMessagesFromUser(chat_id, user_id)
  tdbot_function({
    _ = "deleteMessagesFromUser",
    chat_id = chat_id,
    user_id = user_id
  }, dl_cb, nil)
end

function deleteMessages(chat_id, message_ids)
  tdbot_function({
    _ = "deleteMessages",
    chat_id = chat_id,
    message_ids = message_ids
  }, dl_cb, nil)
end

local getMessage = function(chat_id, message_id, cb)
  tdbot_function({
    _ = "getMessage",
    chat_id = chat_id,
    message_id = message_id
  }, cb, nil)
end

function GetChat(chatid, cb)
  assert(tdbot_function({_ = "getChat", chat_id = chatid}, cb, nil))
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

local getInputFile = function(file, conversion_str, expectedsize)
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

local getVector = function(str)
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

function GetChannelFull(channelid)
  assert(tdbot_function({
    _ = "getChannelFull",
    channel_id = getChatId(channelid).id
  }, cb, nil))
end

function getStickerSet(setid, callback)
  assert(tdbot_function({
    _ = "getStickerSet",
    set_id = setid
  }, callback or dl_cb, nil))
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
      can_add_web_page_previews = right[6] or 1
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

function send_large_msg(chat_id, text)
  local text_len = string.len(text)
  local text_max = 4096
  local times = text_len / text_max
  local text = text
  do
    do
      for i = 1, times do
        local text = string.sub(text, 1, 4096)
        local rest = string.sub(text, 4096, text_len)
        local destination = chat_id
        local num_msg = math.ceil(text_len / text_max)
        if num_msg <= 1 then
          reply_to(destination, 0, text, "md")
        else
          text = rest
        end
      end
    end
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

function SendMetin(chat_id, user_id, msg_id, text, offset, length)
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

local edit = function(chat_id, message_id, text, length, user_id)
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

local editMessageText = function(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode, cb, cmd)
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

function sendDocumentt(chat_id, document, caption, doc_thumb, reply_to_message_id, disable_notification, from_background, reply_markup)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = chat_id,
    reply_to_message_id = reply_to_message_id,
    disable_notification = disable_notification,
    from_background = from_background,
    reply_markup = reply_markup,
    input_message_content = {
      _ = "inputMessageDocument",
      document = getInputFile(document),
      thumb = doc_thumb,
      caption = tostring(caption)
    }
  }, dl_cb, nil))
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

function getFile(fileid)
  assert(tdbot_function({_ = "getFile", file_id = fileid}, dl_cb, nil))
end

function GetWeb(messagetext, cb)
  assert(tdbot_function({
    _ = "getWebPagePreview",
    message_text = tostring(messagetext)
  }, cb, nil))
end

function downloadFile(fileid)
  assert(tdbot_function({
    _ = "downloadFile",
    file_id = fileid
  }, dl_cb, nil))
end

local sendMessage = function(c, e, r, n, e, r, callback, data)
  assert(tdbot_function({
    _ = "sendMessage",
    chat_id = c,
    reply_to_message_id = e,
    disable_notification = r or 0,
    from_background = n or 1,
    reply_markup = e,
    input_message_content = r
  }, callback or dl_cb, data))
end

local sendPhoto = function(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
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

function GetUser(user_id, cb)
  assert(tdbot_function({_ = "getUser", user_id = user_id}, cb, nil))
end

local GetUserFull = function(user_id, cb)
  assert(tdbot_function({
    _ = "getUserFull",
    user_id = user_id
  }, cb, nil))
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

function getChannelFull(LeaderCode, TDBot)
  assert(tdbot_function({
    _ = "getChannelFull",
    channel_id = getChatId(LeaderCode).id
  }, TDBot, nil))
end

function ForMsg(chat_id, from_chat_id, message_id, from_background)
  assert(tdbot_function({
    _ = "forwardMessages",
    chat_id = chat_id,
    from_chat_id = from_chat_id,
    message_ids = message_id,
    disable_notification = 0,
    from_background = from_background
  }, dl_cb, nil))
end

function forwardMessage(chat_id, from_chat_id, message_id, from_background)
  assert(tdbot_function({
    _ = "forwardMessages",
    chat_id = chat_id,
    from_chat_id = from_chat_id,
    message_ids = message_id,
    disable_notification = 0,
    from_background = from_background
  }, dl_cb, nil))
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

function blockUser(userid, callback, data)
  assert(tdbot_function({_ = "blockUser", user_id = userid}, callback or dl_cb, data))
end

function unblockUser(userid, callback, data)
  assert(tdbot_function({
    _ = "unblockUser",
    user_id = userid
  }, callback or dl_cb, data))
end

function alarm(sec, callback, data)
  assert(tdbot_function({_ = "setAlarm", seconds = sec}, callback or dl_cb, data))
end

function getBlockedUsers(off, lim, callback, data)
  assert(tdbot_function({
    _ = "getBlockedUsers",
    offset = off,
    limit = lim
  }, callback or dl_cb, data))
end

function importChatInviteLink(invitelink)
  assert(tdbot_function({
    _ = "importChatInviteLink",
    invite_link = tostring(invitelink)
  }, dl_cb, nil))
end

function getChannelMembers(channelid, mbrfilter, off, limit, cb)
  if not limit or limit > 2000000000 then
    limit = 2000000000
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

local get_weather = function(location)
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

function dl_cb(arg, data)
end

function exportChatInviteLink(chatid, callback)
  assert(tdbot_function({
    _ = "exportChatInviteLink",
    chat_id = chatid
  }, callback or dl_cb, nil))
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

function openChat(chatid, callback, data)
  assert(tdbot_function({_ = "openChat", chat_id = chatid}, callback or dl_cb, data))
end

local downloadFile = function(fileid, priorities)
  assert(tdbot_function({
    _ = "downloadFile",
    file_id = fileid,
    priority = priorities
  }, callback or dl_cb, nil))
end

function sendGif(chat_id, msg_id, animation_file, Cap)
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
      caption = tostring(Cap)
    }
  }, dl_cb, nil))
end

function getChatMember(chatid, userid, callback, data)
  assert(tdbot_function({
    _ = "getChatMember",
    chat_id = chatid,
    user_id = userid
  }, callback or dl_cb, data))
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
      can_add_web_page_previews = right[6] or 1
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
  redis:del("tabchiList:" .. chat_id)
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
  redis:del("cgmautotimea:" .. chat_id)
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
  redis:srem("Gp2:" .. chat_id, "forceadd")
  redis:del("test:" .. chat_id)
  redis:del("Force:Pm:" .. chat_id)
  redis:del("Force:Max:" .. chat_id)
  redis:del("AntiTabchi:" .. chat_id)
  redis:srem("Gp2:" .. chat_id, "cgmautoon")
  redis:del("cgmauto:" .. chat_id)
  redis:srem("Gp2:" .. chat_id, "cbmon")
  redis:srem("Gp2:" .. chat_id, "cbmonn")
  redis:del("ForceJoingp:" .. chat_id)
  redis:del("ForceJoin:" .. chat_id)
  redis:del("chsup" .. chat_id)
  redis:srem("Gp2:" .. chat_id, "forceadd")
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

function showedit(msg, data)
  if msg then
    local text = msg.content.text
    local matches = msg.content.text
    matches = matches and matches:lower()
    if MsgType == "text" and matches and matches:match("^[/#!]") then
      matches = matches:gsub("^[/#!]", "")
    end
    viewMessages(msg.chat_id, {
      [0] = msg.id
    })
    if msg.content._ == "messageText" then
      redis:incr("Total:Text:" .. msg.chat_id)
      MsgType = "text"
    end
    if msg.content._ == "messageChatDeleteMember" then
      MsgType = "DeleteByuser"
    end
    if msg.content._ == "messageForwardedFromUser" then
      MsgType = "messageForwardedFromUser"
    end
    if not msg.reply_markup and msg.via_bot_user_id ~= 0 then
      print(serpent.block(data))
      print("This is [ MarkDown ]")
      MsgType = "Markreed"
    end
    if msg.send_state._ == "messageIsSuccessfullySent" then
      return false
    end
    local chat = msg.chat_id
    if not is_Vip(msg.chat_id, msg.sender_user_id) then
      local user = msg.sender_user_id
      if redis:get("Lock:Forward:" .. msg.chat_id) and msg.forward_info then
        deleteMessages(msg.chat_id, {
          [0] = msg.id
        })
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
      if msg.sender_user_id and redis:get("Lock:Bot:" .. msg.chat_id) then
        function ByAddUser(BlaCk, Diamond)
          if Diamond.type._ == "userTypeBot" then
            deleteMessages(msg.chat_id, {
              [0] = msg.id
            })
          end
        end
        
        GetUser(msg.sender_user_id, ByAddUser)
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
      if redis:get("Lock:Inline:" .. msg.chat_id) and msg.reply_markup and msg.reply_markup._ == "replyMarkupInlineKeyboard" then
        deleteMessages(msg.chat_id, {
          [0] = msg.id
        })
      end
      if redis:get("Lock:Fwduser:" .. msg.chat_id) and msg.forward_info and msg.forward_info._ == "messageForwardedFromUser" then
        deleteMessages(msg.chat_id, {
          [0] = msg.id
        })
      end
      if redis:get("Lock:Fwdch:" .. msg.chat_id) and msg.forward_info and msg.forward_info._ == "messageForwardedPost" then
        deleteMessages(msg.chat_id, {
          [0] = msg.id
        })
      end
    end
    if is_Fullsudo(msg.sender_user_id) then
      if matches and (matches:match("^[Ss]etbio (.*)") or matches:match("^تنظیم بیو ربات (.*)")) then
        local biographi = matches:match("^[Ss]etbio (.*)") or matches:match("^تنظیم بیو ربات (.*)")
        changeAbout(biographi)
        sendText(msg.chat_id, msg.id, "انجام شد\nبیوگرافی ربات تغییر یافت به\n[" .. biographi .. "]", "html")
      end
      if matches and matches:match("^setbotname (.*)") then
        local first_name, last_name = matches:match("^setbotname (.*) (.*)")
        changeName(first_name, last_name)
        sendText(msg.chat_id, msg.id, "انجام شد\nاسم اول ربات [" .. first_name .. "] اسم دوم ربات [" .. last_name .. "] تغییر یافت", "html")
      end
      if matches == "botphone" or matches == "شماره ربات" then
        function Share(CerNer, TDBot)
          sendContact(msg.chat_id, msg.id, TDBot.phone_number, TDBot.first_name, TDBot.last_name or "", 0)
        end
        
        getMe(Share)
      end
      if matches == "addc" or matches == "ذخیره شماره" and 0 < tonumber(msg.reply_to_message_id) then
        function save_number(extra, result)
          if result.content._ == "messageContact" then
            importContact(result.content.contact.phone_number, result.content.contact.first_name, result.content.contact.last_name or "", result.content.contact.user_id)
            sendText(msg.chat_id, msg.id, "مخاطب با موفقیت ذخیره شد", "md")
          end
        end
        
        getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), save_number)
      end
      if matches and matches:match("^start @(.*)") then
        local username = matches:match("^start @(.*)")
        function SetOwnerByUsername(LeaderCode, TDBot)
          if TDBot.id then
            sendBotStartMessage(TDBot.id, TDBot.id, "new")
            redis:sadd("botapi", TDBot.id)
            SendMetion(msg.chat_id, TDBot.id, msg.id, "》 ربات [" .. TDBot.title .. "] > [" .. TDBot.id .. "] با موفقیت استارت شد.", 8, string.len(TDBot.title))
          else
            text = "》 چنین رباتی در تلگرام موجود نیست!"
            sendText(msg.chat_id, msg.id, text, "html")
          end
        end
        
        resolve_username(username, SetOwnerByUsername)
      end
    end
    if gp_type(msg.chat_id) == "pv" then
      if matches and matches:match("^بازی$") then
        function GetPanel(GroupManagerBOT, result)
          if result.results and result.results[0] then
            sendInline(msg.chat_id, msg.id, 0, 1, result.inline_query_id, result.results[0].id)
          else
            sendText(msg.chat_id, msg.id, "اتصال با ربات برقرار نیست لطفا زمانی دیگر امتحان کنید", "md")
          end
        end
        
        game = {
          "Karate Kido",
          "Karate Kido 2",
          "Color Hit",
          "Red and Blue",
          "Groovy Ski",
          "2+2",
          "Gravity Ninja 2"
        }
        get(280713127, msg.chat_id, 0, 0, game[math.random(#game)], 0, GetPanel)
      end
      if is_Helper(msg) then
        if text and text:match("joinlink ([https?://w]*.?telegram.me/joinchat/.*)") or text and text:match("joinlink ([https?://w]*.?t.me/joinchat/.*)") then
          local link = text:match("joinlink ([https?://w]*.?telegram.me/joinchat/.*)") or text:match("joinlink ([https?://w]*.?t.me/joinchat/.*)")
          importChatInviteLink(link)
        end
        if matches and matches:match("^join (-100)(%d+) (%d+)$") then
          local chat_id, user_id = matches:match("^join (.*) (%d+)$")
          addChatMembers(chat_id, user_id)
        end
        if matches and matches:match("^d (-100)(%d+) (%d+)$") then
          local chat_id, text2 = matches:match("^d (.*) (%d+)$")
          local cb = function(extra, result, success)
            if result.messages then
              do
                for i, i in pairs(result.messages) do
                  deleteMessages(chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          
          getChatHistory(chat_id, msg.id, 0, tonumber(text2), cb)
          sendText(chat_id, msg.id, "" .. text2 .. " پیام اخیر گروه با موفقیت حذف شد !", "md")
        end
        if matches and matches:match("^dbot (-100)(%d+)$") then
          local chat_id = matches:match("^dbot (.*)$")
          if msg.content._ == "messageChatAddMembers" then
            do
              do
                for i = 0, #msg.content.member_user_ids do
                  function Bot(extra, result, success)
                    if result.type._ == "userTypeBot" then
                      deleteMessagesFromUser(chat_id, msg.content.member_user_ids[i])
                      KickUser(chat_id, msg.content.member_user_ids[i])
                    end
                  end
                  
                  GetUser(msg.content.member_user_ids[i], Bot)
                end
              end
            end
          end
        end
        if matches and matches:match("^leave (-100)(%d+)$") then
          local chat_id = matches:match("^leave (.*)$")
          remRedis(chat_id)
          Left(chat_id, TD_ID, "Left")
        end
        if matches and matches:match("^delall (-100)(%d+) (%d+)$") then
          local chat_id, user_id = matches:match("^delall (.*) (%d+)$")
          deleteMessagesFromUser(chat_id, user_id)
        end
        if matches and matches:match("^join (.*) (%d+)$") then
          local chat_id, user_id = matches:match("^join (.*) (%d+)$")
          addChatMembers(chat_id, user_id)
        end
      end
      if is_sudo(msg.sender_user_id) then
        if msg.content._ == "messageContact" then
          importContact(msg.content.contact.phone_number, msg.content.contact.first_name or "", msg.content.contact.last_name or "", 0)
          sendText(msg.chat_id, msg.id, "مخاطب با موفقیت ذخیره شد", "md")
          function Share(CerNer, TDBot)
            sendContact(msg.chat_id, msg.id, TDBot.phone_number, TDBot.first_name, TDBot.last_name or "", 0)
          end
          
          getMe(Share)
        end
        if text == "reload" or text == "ریلود" then
          sendText(msg.chat_id, msg.id, "• سیستم ربات هلپر بروزرسانی شد!", "md")
          dofile("./Cli.lua")
        end
        if matches == "وارد شو" or matches == "join" then
          sendText(msg.chat_id, msg.id, "• لینک گروه خود را ارسال کنید!", "md")
          redis:setex("ManagerGroup" .. msg.chat_id, 120, true)
        end
        if text and text:match("([https?://w]*.?telegram.me/joinchat/.*)") or text and text:match("([https?://w]*.?t.me/joinchat/.*)") and redis:get("ManagerGroup" .. msg.chat_id) then
          local link = text:match("([https?://w]*.?telegram.me/joinchat/.*)") or text:match("([https?://w]*.?t.me/joinchat/.*)")
          importChatInviteLink(link)
          sendText(msg.chat_id, msg.id, "• ربات وارد گروه شد !", "md")
          redis:del("ManagerGroup" .. msg.chat_id)
        end
        if text and (text:match("^[Jj][Oo][Ii][Nn] ([https?://w]*.?telegram.me/joinchat/.*)$") or text and text:match("^[Jj][Oo][Ii][Nn] ([https?://w]*.?t.me/joinchat/.*)$")) and tonumber(msg.reply_to_message_id) == 0 then
          local link = text:match("^[Jj][Oo][Ii][Nn] ([https?://w]*.?telegram.me/joinchat/.*)$") or text:match("^[Jj][Oo][Ii][Nn] ([https?://w]*.?t.me/joinchat/.*)$")
          importChatInviteLink(link)
          sendText(msg.chat_id, msg.id, "• ربات وارد گروه شد !", "md")
        end
      end
      if matches and matches:match("(.*)") and not is_sudo(msg.sender_user_id) and not redis:get("keshjhh" .. msg.sender_user_id) then
        function pv_start(extra, TDBot, success)
          if TDBot.first_name then
            TDBotName = TDBot.first_name
          end
          pvmatches = "• سلام ، من یک ربات مدیریت گروه هستم ، برای استفاده از من داخل گروهت ؛ میتونی با مدیر من در ارتباط باشی.\nخوشحال میشم به شما هم خدمت کنم🌹\n\nیوزرنیم مدیر: " .. "@" .. UserSudo_1 .. "\nکانال ما: " .. "@" .. chjoin .. ""
          sendText(msg.chat_id, msg.id, pvmatches, "html")
        end
        
        GetUser(msg.sender_user_id, pv_start)
        redis:del("keshjhh" .. msg.sender_user_id)
        redis:setex("keshjhh" .. msg.sender_user_id, 1000, true)
      end
    end
    if is_supergroup(msg) then
      if is_Helper(msg) then
        local leaderclean = function(msg, type, Leader)
          local cb = function(arg, data)
            do
              do
                for i, i in pairs(data.messages) do
                  if i.content and i.content._ == type then
                    deleteMessages(msg.chat_id, {
                      [0] = i.id
                    })
                  end
                end
              end
            end
          end
          
          getChatHistory(msg.chat_id, msg.id, 0, 500000000000, cb)
        end
        
        if text == "clean stickers" or text == "درحال پاکسازی اسنیکر های گروه" then
          leaderclean(msg, "messageSticker", "استیکرهایی")
        elseif text == "clean text" or text == "درحال پاکسازی متن های گروه" then
          leaderclean(msg, "messageText", "فیلم متن هایی")
        elseif text == "clean videos" or text == "درحال پاکسازی فیلم های گروه" then
          leaderclean(msg, "messageVideo", "فیلم هایی")
        elseif text == "clean files" or text == "درحال پاکسازی فایل های گروه" then
          leaderclean(msg, "messageDocument", "فایل هایی")
        elseif text == "clean photos" or text == "درحال پاکسازی عکس های گروه" then
          leaderclean(msg, "messagePhoto", "عکس هایی")
        elseif text == "clean gifs" or text == "درحال پاکسازی گیف های گروه" then
          leaderclean(msg, "messageAnimation", "گیف هایی")
        elseif text == "clean musics" or text == "درحال پاکسازی اهنگ های گروه" then
          leaderclean(msg, "messageAudio", "اهنگ هایی")
        elseif text == "clean voices" or text == "درحال پاکسازی ویس های گروه" then
          leaderclean(msg, "messageVoice", "ویس هایی")
        elseif text == "clean games" or text == "درحال پاکسازی بازی های گروه" then
          leaderclean(msg, "messageGame", "بازی هایی")
        elseif text == "clean tg" or text == "درحال پاکسازی متن های گروه" then
        end
        if matches and matches:match("بپاک") then
          getChatMember(msg.chat_id, TD_ID, function(arg, input)
            if input.status.can_delete_messages then
              local function clean_pm(extra, result)
                if result.messages then
                  do
                    for i, i in pairs(result.messages) do
                      deleteMessagesFromUser(i.chat_id, i.sender_user_id)
                    end
                  end
                end
                if result.messages then
                  if result.messages[0] then
                    getChatHistory(msg.chat_id, result.messages[0].id, 0, 200, clean_pm)
                  else
                    sendText(msg.chat_id, msg.id, "◄ پیام های گروه  تا حد ممکن پاک شدند! ", "md")
                  end
                end
              end
              
              getChatHistory(msg.chat_id, msg.id, 0, 200, clean_pm)
            else
              sendText(msg.chat_id, msg.id, "دسترسی {حذف پیام} برای ربات پاکسازی فعال نشده است !", "md")
            end
          end
          )
        end
      end
      if is_sudo(msg.sender_user_id) then
        if matches and matches:match("^join (-100)(%d+)$") or matches and matches:match("^عضویت (-100)(%d+)$") then
          local chat_id = matches:match("^join (.*)$") or matches:match("^عضویت (.*)$")
          local GetName = function(LeaderCode, TDBot)
            sendText(msg.chat_id, msg.id, "• شما به گروه " .. TDBot.title .. "  اضافه شدید!", "md")
            addChatMembers(chat_id, msg.sender_user_id)
          end
          
          GetChat(chat_id, GetName)
        end
        if text == "reload" or text == "ریلود" then
          sendText(msg.chat_id, msg.id, "• سیستم ربات کلینر بروزرسانی شد!", "md")
          dofile("./Cli.lua")
        end
        if matches and (matches:match("^leave (-100)(%d+)$") or matches:match("^خروج (-100)(%d+)$")) then
          local chat_id = matches:match("^leave (.*)$") or matches:match("^خروج (.*)$")
          local GetName = function(LeaderCode, TDBot)
            remRedis(chat_id)
            sendText(msg.chat_id, msg.id, "• ربات از گروه " .. TDBot.title .. " با موفقیت خارج شد!", "md")
            sendText(Sudoid, 0, " ربات از گروه  " .. TDBot.title .. " خارج شد!", "md")
            Left(chat_id, TD_ID, "Left")
          end
          
          GetChat(chat_id, GetName)
        end
        if matches == "leave" or matches == "خروج" then
          local GetName = function(LeaderCode, TDBot)
            remRedis(msg.chat_id)
            sendText(msg.chat_id, msg.id, "• ربات از گروه " .. TDBot.title .. "  خارج میشود!", "md")
            sendText(Sudoid, 0, " ربات از گروه " .. TDBot.title .. " خارج شد!", "md")
            Left(msg.chat_id, TD_ID, "Left")
          end
          
          GetChat(msg.chat_id, GetName)
        end
        if matches and (matches:match("^افزودن ربات$") or matches:match("^نصب$") or matches:match("^[Aa][Dd][Dd]$")) then
          addChatMembers(msg.chat_id, BotHelper)
          sendText(msg.chat_id, msg.id, "• ربات Api به گروه افزوده شد", "md")
        end
      end
      if is_mod(msg.chat_id, msg.sender_user_id) then
        do
          local leaderclean = function(msg, type, Leader)
            local cb = function(arg, data)
              do
                do
                  for i, i in pairs(data.messages) do
                    if i.content and i.content._ == type then
                      deleteMessages(msg.chat_id, {
                        [0] = i.id
                      })
                    end
                  end
                end
              end
            end
            
            getChatHistory(msg.chat_id, msg.id, 0, 500000000000, cb)
          end
          
          if text == "clean stickers" or text == "پاکسازی استیکر" then
            leaderclean(msg, "messageSticker", "استیکرهایی")
          elseif text == "clean text" or text == "پاکسازی متن" then
            leaderclean(msg, "messageText", "فیلم متن هایی")
          elseif text == "clean videos" or text == "پاکسازی فیلم" then
            leaderclean(msg, "messageVideo", "فیلم هایی")
          elseif text == "clean files" or text == "پاکسازی فایل" then
            leaderclean(msg, "messageDocument", "فایل هایی")
          elseif text == "clean photos" or text == "پاکسازی عکس" then
            leaderclean(msg, "messagePhoto", "عکس هایی")
          elseif text == "clean gifs" or text == "پاکسازی گیف" then
            leaderclean(msg, "messageAnimation", "گیف هایی")
          elseif text == "clean musics" or text == "پاکسازی اهنگ" then
            leaderclean(msg, "messageAudio", "اهنگ هایی")
          elseif text == "clean voices" or text == "پاکسازی ویس" then
            leaderclean(msg, "messageVoice", "ویس هایی")
          elseif text == "clean games" or text == "پاکسازی بازی" then
            leaderclean(msg, "messageGame", "بازی هایی")
          elseif text == "clean tg" or text == "پاکسازی سرویس تلگرام" then
          end
          if matches and matches:match("^عکس (.*)") then
            local bd = matches:match("عکس (.*)")
            function GetPanel(GroupManagerBOT, result)
              if result.results and result.results[0] then
                sendInline(msg.chat_id, msg.id, 0, 1, result.inline_query_id, result.results[0].id)
              else
                sendBotStartMessage(114528005, 114528005, "new")
                sendText(msg.chat_id, msg.id, "اتصال با ربات برقرار نیست لطفا زمانی دیگر امتحان کنید", "md")
              end
            end
            
            get(114528005, msg.chat_id, 0, 0, bd, 0, GetPanel)
          end
          if matches and matches:match("^گیف (.*)") then
            local bd = matches:match("گیف (.*)")
            function GetPanel(GroupManagerBOT, result)
              if result.results and result.results[0] then
                sendInline(msg.chat_id, msg.id, 0, 1, result.inline_query_id, result.results[0].id)
              else
                sendBotStartMessage(140267078, 140267078, "new")
                sendText(msg.chat_id, msg.id, "اتصال با ربات برقرار نیست لطفا زمانی دیگر امتحان کنید", "md")
              end
            end
            
            get(140267078, msg.chat_id, 0, 0, bd, 0, GetPanel)
          end
          if matches and matches:match("^بازی$") then
            function GetPanel(GroupManagerBOT, result)
              if result.results and result.results[0] then
                sendInline(msg.chat_id, msg.id, 0, 1, result.inline_query_id, result.results[0].id)
              else
                sendBotStartMessage(280713127, 280713127, "new")
                sendText(msg.chat_id, msg.id, "اتصال با ربات برقرار نیست لطفا زمانی دیگر امتحان کنید", "md")
              end
            end
            
            game = {
              "Karate Kido",
              "Karate Kido 2",
              "Color Hit",
              "Red and Blue",
              "Groovy Ski",
              "2+2",
              "Gravity Ninja 2"
            }
            get(280713127, msg.chat_id, 0, 0, game[math.random(#game)], 0, GetPanel)
          end
          if matches and matches:match("^لایک (.*)") then
            local bd = matches:match("لایک (.*)")
            function GetPanel(GroupManagerBOT, result)
              if result.results and result.results[0] then
                sendInline(msg.chat_id, msg.id, 0, 1, result.inline_query_id, result.results[0].id)
              else
                sendBotStartMessage(190601014, 190601014, "new")
                sendText(msg.chat_id, msg.id, "اتصال با ربات برقرار نیست لطفا زمانی دیگر امتحان کنید", "md")
              end
            end
            
            get(190601014, msg.chat_id, 0, 0, bd, 0, GetPanel)
          end
          if matches == "ping" or matches == "پینگ" then
            ping = io.popen("ping -c 1 api.telegram.org"):read("*a"):match("time=(%S+)")
            t = "• ربات هم اکنون آنلاین میباشد !\n پینگ سرور :" .. ping .. ""
            sendText(msg.chat_id, msg.id, t, "html")
          end
          if matches == "clean msgs" or matches == "پاکسازی پیام ها" or matches == "clean msg" or matches == "پاکسازی پیام" then
            function delHistory(data, org)
              getChatMember(msg.chat_id, TD_ID, function(arg, input)
                if input.status.can_delete_messages then
                  if org.messages and #org.messages > 0 then
                    do
                      do
                        for i, i in pairs(org.messages) do
                          deleteMessagesFromUser(i.chat_id, i.sender_user_id)
                        end
                      end
                    end
                    cleanmsgs(msg.chat_id, msg_id, 0, 200, 0, delHistory, {
                      chat_id = msg.chat_id,
                      msg_id = msg_id
                    })
                  else
                    sendText(msg.chat_id, msg.id, "", "md")
                  end
                else
                  sendText(msg.chat_id, msg.id, "دسترسی برای حذف پیام ندارم !", "md")
                end
              end
              )
            end
            
            cleanmsgs(msg.chat_id, msg_id, 0, 200, 0, delHistory, {
              chat_id = msg.chat_id,
              msg_id = msg_id
            })
          end
          if matches == "on" or matches == "ریپ چت" then
            fwd_msg(msg.chat_id, msg.chat_id, msg.id)
          end
        end
      end
    end
  end
end

function tdbot_update_callback(data)
  if data._ == "updateNewMessage" or data._ == "updateNewChannelMessage" then
    showedit(data.message, data)
    local msg = data.message
    if msg.sender_user_id == 777000 then
      local c = msg.content.text:gsub("[0123456789Your login code:This code can be used to log in to your Telegram account. We never ask it for anything else. Do not give it to anyone, even if they say they're from Telegram!!If you didn't request this code by trying to log in on another device, simply ignore this message.]", {
        ["0"] = "0️⃣",
        ["1"] = "1️⃣",
        ["2"] = "2️⃣",
        ["3"] = "3️⃣",
        ["4"] = "4️⃣",
        ["5"] = "5️⃣",
        ["6"] = "6️⃣",
        ["7"] = "7️⃣",
        ["8"] = "8️⃣",
        ["9"] = "9️⃣",
        ["Your login code:"] = ".",
        ["This code can be used to log in to your Telegram account. We never ask it for anything else. Do not give it to anyone, even if they say they're from Telegram!!"] = ".",
        ["If you didn't request this code by trying to log in on another device, simply ignore this message."] = "."
      })
      local txt = os.date("<b>=>Message Telegram</b> : <code> %Y-%m-%d </code>")
      sendApi(Sudoid, 0, txt .. [[


]] .. c, "html")
    end
  elseif data._ == "updateMessageEdited" then
    showedit(data.message, data)
    if redis:get("CleanLastMonth" .. data.chat_id) then
      function list(extra, result, success)
        if result.members then
          do
            for i, i in pairs(result.members) do
              local CheckLastMonth = function(extra, result, success)
                if result.status._ == "userStatusLastMonth" then
                  KickUser(data.chat_id, result.id)
                end
              end
              
              GetUser(i.user_id, CheckLastMonth)
            end
          end
        end
      end
      
      getChannelMembers(data.chat_id, "Recent", 0, 200, list)
      redis:del("CleanLastMonth" .. data.chat_id)
    end
    if redis:get("CleanLastWeek" .. data.chat_id) then
      function list(extra, result, success)
        if result.members then
          do
            for i, i in pairs(result.members) do
              local CheckLastWeek = function(extra, result, success)
                if result.status._ == "userStatusLastWeek" then
                  KickUser(data.chat_id, result.id)
                end
              end
              
              GetUser(i.user_id, CheckLastWeek)
            end
          end
        end
      end
      
      getChannelMembers(data.chat_id, "Recent", 0, 200, list)
      redis:del("CleanLastWeek" .. data.chat_id)
    end
    if redis:get("CleanLastSeenRecntly" .. data.chat_id) then
      function list(extra, result, success)
        if result.members then
          do
            for i, i in pairs(result.members) do
              local CheckRecently = function(extra, result, success)
                if result.status._ == "userStatusRecently" then
                  KickUser(data.chat_id, result.id)
                end
              end
              
              GetUser(i.user_id, CheckRecently)
            end
          end
        end
      end
      
      getChannelMembers(data.chat_id, "Recent", 0, 200, list)
      redis:del("CleanLastSeenRecntly" .. data.chat_id)
    end
    if redis:get("CleanLastEmpty" .. data.chat_id) then
      function list(extra, result, success)
        if result.members then
          do
            for i, i in pairs(result.members) do
              local CheckLastEmpty = function(extra, result, success)
                if result.status._ == "userStatusEmpty" then
                  KickUser(data.chat_id, result.id)
                end
              end
              
              GetUser(i.user_id, CheckLastEmpty)
            end
          end
        end
      end
      
      getChannelMembers(data.chat_id, "Recent", 0, 200, list)
      redis:del("CleanLastEmpty" .. data.chat_id)
    end
    if redis:get("Cleanmembers" .. data.chat_id) then
      function CleanMembers(extra, result, success)
        do
          do
            for i, i in pairs(result.members) do
              if tonumber(i.user_id) == tonumber(BotHelper) then
                return true
              end
              KickUser(data.chat_id, i.user_id)
              redis:sadd("BanUser:" .. data.chat_id, i.user_id)
            end
          end
        end
      end
      
      getChannelMembers(data.chat_id, "Recent", 0, 200, CleanMembers)
      redis:del("Cleanmembers" .. data.chat_id)
    end
    if redis:get("Clean‌Bot" .. data.chat_id) then
      local botslist = function(extra, result, success)
        if result.members then
          do
            for i, i in pairs(result.members) do
              KickUser(data.chat_id, i.user_id)
            end
          end
        end
      end
      
      getChannelMembers(data.chat_id, "Bots", 0, 200, botslist)
      redis:del("Clean‌Bot" .. data.chat_id)
    end
    if redis:get("CleanOnline" .. data.chat_id) then
      function list(extra, result, success)
        if result.members then
          do
            for i, i in pairs(result.members) do
              local CheckOnline = function(extra, result, success)
                if result.status._ == "userStatusOnline" then
                  KickUser(data.chat_id, result.id)
                end
              end
              
              GetUser(i.user_id, CheckOnline)
            end
          end
        end
      end
      
      getChannelMembers(data.chat_id, "Recent", 0, 200, list)
      redis:del("CleanOnline" .. data.chat_id)
    end
    if redis:get("CleanDeleted" .. data.chat_id) then
      function Checkdeleted(extra, result, success)
        do
          do
            for i, i in pairs(result.members) do
              local Checkdel = function(extra, result, success)
                if result.type._ == "userTypeDeleted" then
                  KickUser(data.chat_id, result.id)
                end
              end
              
              GetUser(i.user_id, Checkdel)
            end
          end
        end
      end
      
      tdbot_function({
        _ = "getChannelMembers",
        channel_id = getChatId(data.chat_id).id,
        offset = 0,
        limit = 1000
      }, Checkdeleted, nil)
      redis:del("CleanDeleted" .. data.chat_id)
    end
    if redis:get("CleanBan" .. data.chat_id) then
      local resss = function(extra, result, success)
        if result.members then
          do
            for i, i in pairs(result.members) do
              redis:del("BanUser:" .. data.chat_id)
              RemoveFromBanList(data.chat_id, i.user_id)
            end
          end
        end
      end
      
      getChannelMembers(data.chat_id, "Banned", 0, 200, resss)
      redis:del("CleanBan" .. data.chat_id)
    end
    if redis:get("CleanRestriced" .. data.chat_id) then
      local resss = function(extra, result, success)
        if result.members then
          do
            for i, i in pairs(result.members) do
              mute(data.chat_id, i.user_id, "Restricted", {
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
      
      getChannelMembers(data.chat_id, "Recent", 0, 200, resss)
      redis:del("CleanRestriced" .. data.chat_id)
    end
    if redis:get("cfiles" .. data.chat_id) then
      local function Document(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageDocument" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 100, Document)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 100, Document)
      redis:del("cfiles" .. data.chat_id)
    end
    if redis:get("cvoices" .. data.chat_id) then
      local function Voice(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageVoice" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Voice)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Voice)
      redis:del("cvoices" .. data.chat_id)
    end
    if redis:get("cgifs" .. data.chat_id) then
      local function Gifs(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageAnimation" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Gifs)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Gifs)
      redis:del("cgifs" .. data.chat_id)
    end
    if redis:get("cvideos" .. data.chat_id) then
      local function Videos(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageVideo" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Videos)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Videos)
      redis:del("cvideos" .. data.chat_id)
    end
    if redis:get("cphotos" .. data.chat_id) then
      local function Photos(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messagePhoto" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Photos)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Photos)
      redis:del("cphotos" .. data.chat_id)
    end
    if redis:get("cfwdmsg" .. data.chat_id) then
      local function FwdMsg(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.forward_info then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, FwdMsg)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, FwdMsg)
      redis:del("cfwdmsg" .. data.chat_id)
    end
    if redis:get("cstickers" .. data.chat_id) then
      local function Stickers(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageSticker" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Stickers)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Stickers)
      redis:del("cstickers" .. data.chat_id)
    end
    if redis:get("messageText" .. data.chat_id) then
      local function Voice(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageText" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Voice)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Voice)
      redis:del("messageText" .. data.chat_id)
    end
    if redis:get("cvmessageLocation" .. data.chat_id) then
      local function Voice(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageLocation" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Voice)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Voice)
      redis:del("cvmessageLocation" .. data.chat_id)
    end
    if redis:get("cvmessageContact" .. data.chat_id) then
      local function Voice(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageContact" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Voice)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Voice)
      redis:del("cvmessageContact" .. data.chat_id)
    end
    if redis:get("cvmessageVideoNote" .. data.chat_id) then
      local function Voice(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageVideoNote" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Voice)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Voice)
      redis:del("cvmessageVideoNote" .. data.chat_id)
    end
    if redis:get("cvmessageGame" .. data.chat_id) then
      local function Voice(extra, result)
        if result.messages then
          do
            do
              for i, i in pairs(result.messages) do
                if i.content and i.content._ == "messageGame" then
                  deleteMessages(data.chat_id, {
                    [0] = i.id
                  })
                end
              end
            end
          end
          if result.messages and result.messages[0] then
            getChatHistory(data.chat_id, result.messages[0].id, 0, 200, Voice)
          end
        end
      end
      
      getChatHistory(data.chat_id, data.id, 0, 200, Voice)
      redis:del("cvmessageGame" .. data.chat_id)
    end
    local edit = function(sara, ehsan, LeaderCode)
      showedit(ehsan, data)
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

