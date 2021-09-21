dofile("./Config.lua")
json = dofile("./libs/JSON.lua")
local serpent = require("serpent")
lgi = require("lgi")
notify = lgi.require("Notify")
notify.init("Telegram updates")
jdate = dofile("./libs/jdate.lua")
local redis = require("redis")
local redis = redis.connect("127.0.0.1", 6379)
redis:select("" .. rediscode .. "")
http = require("socket.http")
JSON = require("dkjson")
https = require("ssl.https")
URL = require("socket.url")
ltn12 = require("ltn12")
socket = require("socket")
curl = require("cURL")
curl_context = curl.easy({verbose = false})
EndMsg = redis:get("EndMsg") or "  "
chjoi = redis:get("chjoin") or ChannelInline
chcmd = redis:get("chcmd") or "LeaderCodeCmd"
UserSudo_1 = redis:get("usersudo") or Sudo
local Bot_Api = "https://api.telegram.org/bot" .. token
local offset = -1
MsgTime = os.time() - 5
cconfigerid = {935076871}
leader = 935076871
SUDO_ID = {
  Sudoid,
  TD_ID,
  leader,
  BotHelper
}
Full_Sudo = {
  Sudoid,
  BotHelper,
  TD_ID,
  leader
}
local week = 604800
local day = 86400
local hour = 3600
local minute = 60
function is_leader(user_id)
  if user_id == tonumber(935076871) then
    return true
  else
    return false
  end
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
  if is_leader(user_id) or is_Fullsudo(user_id) or hash then
    return true
  else
    return false
  end
end

function is_owner(chat, user_id)
  local hash = redis:sismember("OwnerList:" .. chat, user_id)
  if hash or is_sudo(user_id) then
    return true
  else
    return false
  end
end

function is_mod(chat, user_id)
  local hash = redis:sismember("ModList:" .. chat, user_id)
  if hash or is_sudo(user_id) or is_owner(chat, user_id) then
    return true
  else
    return false
  end
end

function private(chat_id, user_id)
  if tonumber(user_id) == tonumber(BotHelper) or is_Fullsudo(user_id) or is_owner(chat_id, user_id) or is_mod(chat_id, user_id) or is_sudo(user_id) or is_leader(user_id) then
    return true
  else
    return false
  end
end

local vardump = function(value)
  print(serpent.block(value, {comment = false}))
end

local getUpdates = function()
  local response = {}
  local success, code, headers, status = https.request({
    url = Bot_Api .. "/getUpdates?timeout=10&offset=" .. offset,
    method = "POST",
    sink = ltn12.sink.table(response)
  })
  local body = table.concat(response or {
    "no response"
  })
  if success == 1 then
    return json:decode(body)
  else
    return nil, "Request Error"
  end
end

function fwd_msg(chat_id, from_chat_id, message_id)
  local url = Bot_Api .. "/forwardMessage?chat_id=" .. chat_id .. "&from_chat_id=" .. from_chat_id .. "&message_id=" .. message_id
  return https.request(url)
end

function send_keyb(chat_id, msg_id, text, keyboard, resize, mark)
  local response = {}
  response.keyboard = keyboard
  response.resize_keyboard = resize
  response.one_time_keyboard = false
  response.selective = false
  local responseString = JSON.encode(response)
  if mark then
    url = Bot_Api .. "/sendMessage?chat_id=" .. chat_id .. "&text=" .. URL.escape(text) .. "&disable_web_page_preview=true&reply_markup=" .. URL.escape(responseString) .. "&reply_to_message_id=" .. (msg_id or 0)
  else
    url = Bot_Api .. "/sendMessage?chat_id=" .. chat_id .. "&text=" .. URL.escape(text) .. "&parse_mode=Markdown&disable_web_page_preview=true&reply_markup=" .. URL.escape(responseString) .. "&reply_to_message_id=" .. (msg_id or 0)
  end
  return https.request(url)
end

function Send(chat_id, reply_to_message_id, text, keyboard, markdown)
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

function sendText(chat_id, reply_to_message_id, text, markdown)
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

function getUserProfilePhotos(user_id, offset, limit)
  local Rep = Bot_Api .. "/getUserProfilePhotos?user_id=" .. user_id
  if offset then
    Rep = Rep .. "&offset=" .. offset
  end
  if limit then
    if tonumber(limit) > 100 then
      limit = 100
    end
    Rep = Rep .. "&limit=" .. limit
  end
  return json:decode(https.request(Rep))
end

function sendVideonote(chat_id, file_id, reply_to_message_id, caption, markdown)
  url = Bot_Api .. "/sendVideoNote?chat_id=" .. chat_id .. "&reply_to_message_id=" .. reply_to_message_id .. "&video=" .. file_id
  if caption then
    url = url .. "&caption=" .. URL.escape(caption)
  end
  if markdown == "md" or markdown == "markdown" then
    url = url .. "&parse_mode=Markdown"
  elseif markdown == "html" then
    url = url .. "&parse_mode=HTML"
  end
  return json:decode(https.request(url))
end

function sendVideo(chat_id, file_id, reply_to_message_id, caption, markdown)
  url = Bot_Api .. "/sendVideo?chat_id=" .. chat_id .. "&reply_to_message_id=" .. reply_to_message_id .. "&video=" .. file_id
  if caption then
    url = url .. "&caption=" .. URL.escape(caption)
  end
  if markdown == "md" or markdown == "markdown" then
    url = url .. "&parse_mode=Markdown"
  elseif markdown == "html" then
    url = url .. "&parse_mode=HTML"
  end
  return json:decode(https.request(url))
end

function sendVoice(chat_id, file_id, reply_to_message_id, caption, markdown)
  url = Bot_Api .. "/sendVoice?chat_id=" .. chat_id .. "&reply_to_message_id=" .. reply_to_message_id .. "&voice=" .. file_id
  if caption then
    url = url .. "&caption=" .. URL.escape(caption)
  end
  if markdown == "md" or markdown == "markdown" then
    url = url .. "&parse_mode=Markdown"
  elseif markdown == "html" then
    url = url .. "&parse_mode=HTML"
  end
  return json:decode(https.request(url))
end

function sendPhoto(chat_id, file_id, reply_to_message_id, caption, markdown)
  url = Bot_Api .. "/sendPhoto?chat_id=" .. chat_id .. "&reply_to_message_id=" .. reply_to_message_id .. "&photo=" .. file_id
  if caption then
    url = url .. "&caption=" .. URL.escape(caption)
  end
  if markdown == "md" or markdown == "markdown" then
    url = url .. "&parse_mode=Markdown"
  elseif markdown == "html" then
    url = url .. "&parse_mode=HTML"
  end
  return json:decode(https.request(url))
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

function Leave(chat_id)
  local Rep = Bot_Api .. "/leaveChat?chat_id=" .. chat_id
  return https.request(Rep)
end

function Mute(chat_id, user_id, right, time)
  if right == 1 then
    https.request(Bot_Api .. "/restrictChatMember?chat_id=" .. chat_id .. "&user_id=" .. user_id .. "&can_send_messages=false&can_send_messages=false&can_send_media_messages=false&can_send_polls=false&can_send_other_messages=false&can_add_web_page_previews=false&can_change_info=false&can_invite_users=false&can_pin_messages=false&until_date=" .. time)
  elseif right == 2 then
    https.request(Bot_Api .. "/restrictChatMember?chat_id=" .. chat_id .. "&user_id=" .. user_id .. "&can_send_messages=true&can_send_messages=true&can_send_media_messages=true&can_send_polls=true&can_send_other_messages=true&can_add_web_page_previews=true&can_change_info=true&can_invite_users=true&can_pin_messages=true")
  elseif right == 3 then
    https.request(Bot_Api .. "/restrictChatMember?chat_id=" .. chat_id .. "&user_id=" .. user_id .. "&can_send_messages=true&can_send_media_messages=false&can_send_other_messages=false&can_add_web_page_previews=false")
  end
end

function dlmsg(chat_id, message_id)
  local Rep = Bot_Api .. "/deletemessage?chat_id=" .. chat_id .. "&message_id=" .. message_id
  return https.request(Rep)
end

function getChatMembersCount(chat_id)
  local Rep = Bot_Api .. "/getChatMembersCount?chat_id=" .. chat_id
  return json:decode(https.request(Rep))
end

function getChatAdministrators(chat_id)
  local Rep = Bot_Api .. "/getChatAdministrators?chat_id=" .. chat_id
  return json:decode(https.request(Rep))
end

function UnBan(chat_id, user_id)
  local Rep = Bot_Api .. "/unbanChatMember?chat_id=" .. chat_id .. "&user_id=" .. user_id
  return https.request(Rep)
end

function Ban(chat_id, user_id)
  local Rep = Bot_Api .. "/kickChatMember?chat_id=" .. chat_id .. "&user_id=" .. user_id
  return https.request(Rep)
end

function Edit(chat_id, message_id, text, keyboard, markdown)
  local url = Bot_Api .. "/editMessageText?chat_id=" .. chat_id .. "&message_id=" .. message_id .. "&text=" .. URL.escape(text)
  if markdown == "md" or markdown == "markdown" then
    url = url .. "&parse_mode=Markdown"
  elseif markdown == "html" then
    url = url .. "&parse_mode=HTML"
  end
  url = url .. "&disable_web_page_preview=false"
  if keyboard then
    url = url .. "&reply_markup=" .. JSON.encode(keyboard)
  end
  return https.request(url)
end

function sendDocument(chat_id, file_id, reply_to_message_id, caption, markdown)
  url = Bot_Api .. "/sendDocument?chat_id=" .. chat_id .. "&reply_to_message_id=" .. reply_to_message_id .. "&document=" .. file_id
  if caption then
    url = url .. "&caption=" .. URL.escape(caption)
  end
  if markdown == "md" or markdown == "markdown" then
    url = url .. "&parse_mode=Markdown"
  elseif markdown == "html" then
    url = url .. "&parse_mode=HTML"
  end
  return json:decode(https.request(url))
end

function setChatPermissions(chat_id, test)
  url = Bot_Api .. "/setChatPermissions?chat_id=" .. chat_id .. "&permissions=" .. json:encode(test)
  return https.request(url)
end

function promoteChatMember(chat_id, user_id, can_changeinfo, can_postmessages, can_editmessages, can_deletemessages, can_inviteusers, can_restrictmembers, can_pin_messages, can_promotemembers)
  url = Bot_Api .. "/promoteChatMember?chat_id=" .. chat_id .. "&user_id=" .. user_id .. "&can_change_info=" .. can_changeinfo .. "&can_post_messages=" .. can_postmessages .. "&can_edit_messages=" .. can_editmessages .. "&can_delete_messages=" .. can_deletemessages .. "&can_invite_users=" .. can_inviteusers .. "&can_restrict_members=" .. can_restrictmembers .. "&can_pin_messages=" .. can_pin_messages .. "&can_promote_members=" .. can_promotemembers
  return https.request(url)
end

function getChatMember(chatid, userid)
  local Rep = Bot_Api .. "/getchatmember?chat_id=" .. chatid .. "&user_id=" .. userid
  return json:decode(https.request(Rep))
end

function setChatAdministratorCustomTitle(chatid, userid, CustomTitle)
  local Rep = Bot_Api .. "/setchatadministratorcustomtitle?chat_id=" .. chatid .. "&user_id=" .. userid .. "&custom_title=" .. CustomTitle
  return json:decode(https.request(Rep))
end

function exportChatInviteLink(chat_id)
  local url = Bot_Api .. "/exportChatInviteLink?chat_id=" .. chat_id
  return json:decode(https.request(url))
end

function getChat(chat_id)
  local Rep = Bot_Api .. "/getChat?chat_id=" .. chat_id
  return json:decode(https.request(Rep))
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

function Alert(callback_query_id, text, show_alert)
  local Rep = Bot_Api .. "/answerCallbackQuery?callback_query_id=" .. callback_query_id .. "&text=" .. URL.escape(text)
  if show_alert then
    Rep = Rep .. "&show_alert=true"
  end
  https.request(Rep)
end

function GetIdUser(chat_id, msg_id, user, name, username)
  Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(name) .. "</a>"
  username = username and "@" .. username
  if is_leader(user) then
    rank = "توسعه دهنده"
  elseif is_Fullsudo(user) then
    rank = "مدیرکل"
  elseif is_sudo(user) then
    rank = "مدیر ربات"
  elseif is_owner(chat_id, user) then
    rank = "مالک گروه"
  elseif is_mod(chat_id, user) then
    rank = "مدیر گروه"
  elseif not is_mod(chat_id, user) then
    rank = "کاربر عادی"
  end
  addedU = redis:get("Total:added:" .. chat_id .. ":" .. user) or 0
  PText = "• نام: " .. Name .. "\n• شناسه: <code>" .. user .. "</code>\n• یوزرنیم: " .. (username or "---") .. "\n• تعداد دعوت ها : " .. addedU .. "\n• مقام: " .. rank .. ""
  if redis:get("photoid:" .. chat_id) then
    if 0 < getUserProfilePhotos(user).result.total_count then
      sendPhoto(chat_id, getUserProfilePhotos(user).result.photos[1][1].file_id, msg_id, PText, "html")
    else
      sendText(chat_id, msg_id, PText, "html")
    end
  else
    sendText(chat_id, msg_id, PText, "html")
  end
end

function SetMuteUser(msg, chat_id, msg_id, user, name, time)
  local aa = getChatMember(chat_id, BotHelper).result
  if aa.can_restrict_members then
    Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(name) .. "</a>"
    if private(chat_id, user) then
      sendText(chat_id, msg_id, "من نمیتوانم مدیران را سکوت کنم", "html")
    elseif redis:sismember("MuteList:" .. chat_id, user) then
      PText = "• کاربر " .. Name .. " سکوت میباشد !"
      sendText(chat_id, msg_id, PText, "html")
    elseif not time then
      PText = "• کاربر " .. Name .. " سکوت شد !"
      sendText(TD_ID, 0, "delall " .. chat_id .. " " .. msg.reply_to_message.from.id, "html")
      redis:sadd("MuteList:" .. chat_id, user)
      Mute(chat_id, user, 1, 1)
      sendText(chat_id, msg_id, PText, "html")
    else
      local check_time = tonumber(time)
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
      elseif tonumber(check_time) > 60 and check_time < 3600 then
        remained_expire = "" .. min .. " دقیقه"
      elseif tonumber(check_time) > 3600 and tonumber(check_time) < 86400 then
        remained_expire = "" .. hours .. " ساعت و " .. min .. " دقیقه"
      elseif tonumber(check_time) > 86400 and tonumber(check_time) < 2592000 then
        remained_expire = "" .. day .. " روز و " .. hours .. " ساعت و " .. min .. " دقیق"
      elseif tonumber(check_time) > 2592000 and tonumber(check_time) < 31536000 then
        remained_expire = "" .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت و " .. min .. " دقیقه"
      elseif tonumber(check_time) > 31536000 then
        remained_expire = "" .. year .. " سال " .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت و " .. min .. " دقیقه"
      end
      PText = "• کاربر " .. Name .. " به مدت " .. remained_expire .. " سکوت شد !"
      redis:sadd("MuteList:" .. chat_id, user)
      redis:setex("MuteTimeList" .. user, tonumber(time), true)
      Mute(chat_id, user, 1, msg.date + tonumber(time))
      sendText(chat_id, msg_id, PText, "html")
    end
  else
    sendText(chat_id, msg_id, " • لطفا دسترسی \"اخراج و محدود کردن\" را به ربات بدهید !", "html")
  end
end

function RemMuteUser(chat_id, msg_id, user, name)
  local aa = getChatMember(chat_id, BotHelper).result
  if aa.can_restrict_members then
    Name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(name) .. "</a>"
    if private(chat_id, user) then
      sendText(chat_id, msg_id, "• خطا!\n شما نمیتوانید این کار را روی مدیران انجام دهید .", "html")
    elseif not redis:sismember("MuteList:" .. chat_id, user) then
      DText = "• کاربر " .. Name .. " سکوت نمیباشد !"
      sendText(chat_id, msg_id, DText, "html")
    else
      Mute(chat_id, user, 2, 0)
      redis:srem("MuteList:" .. chat_id, user)
      DText = "• کاربر " .. Name .. " از حالت سکوت خارج شد !"
      sendText(chat_id, msg_id, DText, "html")
    end
  else
    sendText(chat_id, msg_id, " • لطفا دسترسی \"اخراج و محدود کردن\" را به ربات بدهید !", "html")
  end
end

function acsgpsetting(msg_id, chat_id)
  if redis:get("CheckBot:" .. chat_id) then
    local GroupsName = redis:get("StatsGpByName" .. chat_id) or "اطلاعاتی موجود نیست"
    local check_time = redis:ttl("ExpireData:" .. chat_id)
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
      EXPIRE = "نامحدود"
    elseif tonumber(check_time) > 1 and check_time < 60 then
      EXPIRE = "" .. sec .. " ثانیه شارژ میباشد"
    elseif 60 < tonumber(check_time) and check_time < 3600 then
      EXPIRE = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
    elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
      EXPIRE = "" .. hours .. " ساعت و " .. min .. " دقیقه"
    elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
      EXPIRE = "" .. day .. " روز و " .. hours .. " ساعت "
    elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
      EXPIRE = "" .. month .. " ماه " .. day .. " روز"
    elseif 31536000 < tonumber(check_time) then
      EXPIRE = "" .. year .. " سال " .. month .. " ماه " .. day .. ""
    end
    local keyboard = {}
    keyboard.inline_keyboard = {
      {
        {
          text = "• تنظیمات",
          callback_data = "ehsanleader:" .. chat_id
        }
      },
      {
        {
          text = "• بخش پاکسازی",
          callback_data = "cclliif:" .. chat_id
        },
        {
          text = "• اطلاعات گروه",
          callback_data = "groupinfo:" .. chat_id
        }
      },
      {
        {
          text = "• واردشدن",
          callback_data = "AddToGp:" .. chat_id
        }
      },
      {
        {
          text = "• خروج ربات",
          callback_data = "LeaveToGp:" .. chat_id
        },
        {
          text = "• شارژ گروه",
          callback_data = "ChargeGp:" .. chat_id
        }
      },
      {
        {
          text = "• پنل گروه ها",
          callback_data = "ChatsPage:0"
        }
      },
      {
        {
          text = "• بستن",
          callback_data = "Exit:" .. chat_id
        }
      }
    }
    Send(chat_id, msg_id, "نام گروه:" .. GroupsName .. "\nشارژ گروه :" .. EXPIRE .. "\n بخش مورد نظر خود را انتخاب کنید", keyboard, "html")
  else
    local keyboard = {}
    keyboard.inline_keyboard = {
      {
        {
          text = "پشتیبانی",
          url = "https://telegram.me/" .. chjoi .. ""
        }
      }
    }
    Send(chat_id, msg_id, "ربات در این گروه نصب نشده است", keyboard, "Markdown")
  end
end

function GetMenu(msg_id, chat_id)
  if redis:get("CheckBot:" .. chat_id) then
    local GroupsName = redis:get("StatsGpByName" .. chat_id) or "" .. chat_id .. ""
    local check_time = redis:ttl("ExpireData:" .. chat_id)
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
      EXPIRE = "نامحدود"
    elseif tonumber(check_time) > 1 and check_time < 60 then
      EXPIRE = "" .. sec .. " ثانیه شارژ میباشد"
    elseif 60 < tonumber(check_time) and check_time < 3600 then
      EXPIRE = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
    elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
      EXPIRE = "" .. hours .. " ساعت و " .. min .. " دقیقه"
    elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
      EXPIRE = "" .. day .. " روز و " .. hours .. " ساعت "
    elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
      EXPIRE = "" .. month .. " ماه " .. day .. " روز"
    elseif 31536000 < tonumber(check_time) then
      EXPIRE = "" .. year .. " سال " .. month .. " ماه " .. day .. ""
    end
    local keyboard = {}
    keyboard.inline_keyboard = {
      {
        {
          text = "• تنظیمات",
          callback_data = "ehsanleader:" .. chat_id
        },
        {
          text = "• اطلاعات گروه",
          callback_data = "groupinfo:" .. chat_id
        }
      },
      {
        {
          text = "• راهنمای ربات",
          callback_data = "help:" .. chat_id
        },
        {
          text = "• بخش پاکسازی",
          callback_data = "cclliif:" .. chat_id
        }
      },
      {
        {
          text = "• بستن فهرست",
          callback_data = "Exit:" .. chat_id
        }
      }
    }
    Send(chat_id, msg_id, "نام گروه شما:" .. GroupsName .. "\nمیزان اعتبار گروه شما:" .. EXPIRE .. "\nبخش مورد نظر خود را انتخاب کنید", keyboard, "Markdown")
  else
    local keyboard = {}
    keyboard.inline_keyboard = {
      {
        {
          text = "پشتیبانی",
          url = "https://telegram.me/" .. chjoi .. ""
        }
      }
    }
    Send(chat_id, msg_id, "ربات در این گروه نصب نشده است", keyboard, "Markdown")
  end
end

function ModAccess(msg, chat_id)
  if redis:get("settings_acs:ModAccess" .. chat_id) == "Owner" then
    settings_acs = "|✗|"
  elseif not redis:get("settings_acs:ModAccess" .. chat_id) then
    settings_acs = "|✅|"
  end
  if redis:get("locks_acs:ModAccess" .. chat_id) == "Owner" then
    locks_acs = "|✗|"
  elseif not redis:get("locks_acs:ModAccess" .. chat_id) then
    locks_acs = "|✅|"
  end
  if redis:get("menu_acs:ModAccess" .. chat_id) == "Owner" then
    menu_acs = "|✗|"
  elseif not redis:get("menu_acs:ModAccess" .. chat_id) then
    menu_acs = "|✅|"
  end
  if redis:get("users_acs:ModAccess" .. chat_id) == "Owner" then
    users_acs = "|✗|"
  elseif not redis:get("users_acs:ModAccess" .. chat_id) then
    users_acs = "|✅|"
  end
  if redis:get("clean_acs:ModAccess" .. chat_id) == "Owner" then
    clean_acs = "|✗|"
  elseif not redis:get("clean_acs:ModAccess" .. chat_id) then
    clean_acs = "|✅|"
  end
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• به تنظیمات عددی: " .. settings_acs,
        callback_data = "/settings_acs" .. chat_id
      }
    },
    {
      {
        text = "• به اعمال عملیات روی قفل ها: " .. locks_acs,
        callback_data = "/locks_acs" .. chat_id
      }
    },
    {
      {
        text = "• به درخواست فهرست: " .. menu_acs,
        callback_data = "/menu_acs" .. chat_id
      }
    },
    {
      {
        text = "• به اعمال عملیات روی کاربر: " .. users_acs,
        callback_data = "/users_acs" .. chat_id
      }
    },
    {
      {
        text = "• به بخش پاکسازی: " .. clean_acs,
        callback_data = "/clean_acs" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄ ",
        callback_data = "panel:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "به بخش تنظیم دسترسی مدیران خوش امدید :", keyboard, "html")
end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
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
    elseif txt:match("@") then
      txt = txt:gsub("@", "")
    elseif txt:match("&") then
      txt = txt:gsub("&", "")
    elseif txt:match("#") then
      txt = txt:gsub("#", "")
    elseif txt:match("$") then
      txt = txt:gsub("$", "")
    elseif txt:match("?") or txt:match("؟") then
      txt = txt:gsub("؟", "")
      txt = txt:gsub("?", "")
    elseif txt:match("<") or txt:match(">") then
      txt = txt:gsub(">", "")
      txt = txt:gsub("<", "")
    elseif txt:match("\n") then
      txt = txt:gsub("\n", "")
    end
    return txt
  end
end

function settingsacsuser(Leader, chat_id, user_id)
  local hash = redis:sismember("settings_acsuser:" .. chat_id, user_id)
  if not hash then
    return true
  else
    return Alert(Leader.id, "⚜️دسترسی تنظیم و حذف برای شما غیرفعال شده است !", true)
  end
end

function locksacsuser(Leader, chat_id, user_id)
  local hash = redis:sismember("locks_acsuser:" .. chat_id, user_id)
  if not hash then
    return true
  else
    return Alert(Leader.id, "• دسترسی تغییر قفل ها برای شما غیرفعال شده است !", true)
  end
end

function menuacsuser(msg, chat_id, user_id)
  local hash = redis:sismember("menu_acsuser:" .. chat_id, user_id)
  if hash then
    sendText(chat_id, msg_id, "⚜️دسترسی به فهرست برای شما غیرفعال شده است !", "md")
  else
    return true
  end
end

function usersacsuser(msg, chat_id, user_id)
  local hash = redis:sismember("users_acsuser:" .. chat_id, user_id)
  if hash then
    return sendText(chat_id, msg_id, "• دسترسی مدیریت کاربر برای شما غیرفعال شده است !", "md")
  else
    return true
  end
end

function acsclean(Leader, chat_id, user_id)
  local hash = redis:sismember("acsclean:" .. chat_id, user_id)
  if not hash then
    return true
  else
    return Alert(Leader.id, "• دسترسی پاکسازی برای شما غیرفعال شده است !", true)
  end
end

function ModAccess1(Leader, chat_id, user_id)
  if not redis:get("locks_acs:ModAccess" .. chat_id) then
    CMD = is_mod(chat_id, user_id)
  elseif redis:get("locks_acs:ModAccess" .. chat_id) == "Owner" then
    CMD = is_owner(chat_id, user_id)
    if is_Fullsudo(user_id) then
    elseif is_sudo(user_id) then
    elseif is_owner(chat_id, user_id) then
    elseif is_mod(chat_id, user_id) then
      CMD = Alert(Leader.id, "• دسترسی تغییر قفل ها برای مدیران غیرفعال شده است !", true)
    end
  end
  if CMD == is_mod(chat_id, user_id) then
    return true
  else
    return false
  end
end

function ModAccess2(Leader, chat_id, user_id)
  if not redis:get("settings_acs:ModAccess" .. chat_id) then
    CMD = is_mod(chat_id, user_id)
  elseif redis:get("settings_acs:ModAccess" .. chat_id) == "Owner" then
    CMD = is_owner(chat_id, user_id)
    if is_Fullsudo(user_id) then
    elseif is_sudo(user_id) then
    elseif is_owner(chat_id, user_id) then
    elseif is_mod(chat_id, user_id) then
      CMD = Alert(Leader.id, "⚜️دسترسی تنظیم و حذف برای مدیران غیرفعال شده است !", true)
    end
  end
  if CMD == is_mod(chat_id, user_id) then
    return true
  else
    return false
  end
end

function ModAccess3(msg, chat_id, user_id)
  if not redis:get("menu_acs:ModAccess" .. chat_id) then
    CMD = is_mod(chat_id, user_id)
  elseif redis:get("menu_acs:ModAccess" .. chat_id) == "Owner" then
    CMD = is_owner(chat_id, user_id)
    if is_Fullsudo(user_id) then
    elseif is_sudo(user_id) then
    elseif is_owner(chat_id, user_id) then
    elseif is_mod(chat_id, user_id) then
      CMD = sendText(chat_id, msg_id, "⚜️دسترسی به فهرست برای مدیران غیرفعال شده است !", "md")
    end
  end
  if CMD == is_mod(chat_id, user_id) then
    return true
  else
    return false
  end
end

function ModAccess4(msg, chat_id, user_id)
  if not redis:get("users_acs:ModAccess" .. chat_id) then
    CMD = is_mod(chat_id, user_id)
  elseif redis:get("users_acs:ModAccess" .. chat_id) == "Owner" then
    CMD = is_owner(chat_id, user_id)
    if is_Fullsudo(user_id) then
    elseif is_sudo(user_id) then
    elseif is_owner(chat_id, user_id) then
    elseif is_mod(chat_id, user_id) then
      CMD = sendText(chat_id, msg_id, "• دسترسی مدیریت کاربر برای مدیران غیرفعال شده است !", "md")
    end
  end
  if CMD == is_mod(chat_id, user_id) then
    return true
  else
    return false
  end
end

function ModAccess5(Leader, chat_id, user_id)
  if not redis:get("clean_acs:ModAccess" .. chat_id) then
    CMD = is_mod(chat_id, user_id)
  elseif redis:get("clean_acs:ModAccess" .. chat_id) == "Owner" then
    CMD = is_owner(chat_id, user_id)
    if is_Fullsudo(user_id) then
    elseif is_sudo(user_id) then
    elseif is_owner(chat_id, user_id) then
    elseif is_mod(chat_id, user_id) then
      CMD = Alert(Leader.id, "• دسترسی پاکسازی برای مدیران غیرفعال شده است !", true)
    end
  end
  if CMD == is_mod(chat_id, user_id) then
    return true
  else
    return false
  end
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
  redis:srem("Gp2:" .. chat_id, "cbmon")
  redis:srem("Gp2:" .. chat_id, "cbmonn")
  redis:del("ForceJoingp:" .. chat_id)
  redis:del("chsup" .. chat_id)
  redis:del("ExpireData:" .. chat_id)
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
        redis:del("Total:messages:" .. chat_id .. ":" .. i)
        redis:del("Total:added:" .. chat_id .. ":" .. i)
      end
    end
  end
end

function HalGhe(chat_id)
  if tonumber(0) == tonumber(os.date("%H%M")) and not redis:get("resetstats" .. chat_id) then
    redis:setex("resetstats" .. chat_id, 60, true)
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
    local users = redis:smembers("Total:users:" .. chat_id)
    do
      do
        for i, i in pairs(users) do
          redis:del("firstname" .. i)
          redis:del("Total:messages:" .. chat_id .. ":" .. i)
          redis:del("Total:added:" .. chat_id .. ":" .. i)
        end
      end
    end
    sendText(chat_id, 0, "امارگروه بازنشانی شد", "html")
  end
  local timecgmtd = redis:get("cgmautotime:" .. chat_id) or "0000"
  if tonumber(timecgmtd) == tonumber(os.date("%H%M ")) and redis:get("cgmautoon" .. chat_id) and not redis:get("cgmauto:" .. chat_id) then
    redis:setex("cgmauto:" .. chat_id, 60, true)
    usernamee = "<a href=\"tg://user?id=" .. TD_ID .. "\"> بپاک </a>"
    sendText(chat_id, 0, usernamee, "html")
  end
end

function remote(chat_id, msg, user_id)
  sudo = redis:sismember("SUDO-ID", user_id) and "|✅|" or "|✗|"
  owner = redis:sismember("OwnerList:" .. chat_id, user_id) and "|✅|" or "|✗|"
  mod = redis:sismember("ModList:" .. chat_id, user_id) and "|✅|" or "|✗|"
  vip = redis:sismember("Vip:" .. chat_id, user_id) and "|✅|" or "|✗|"
  mute = redis:sismember("MuteList:" .. chat_id, user_id) and "|✅|" or "|✗|"
  free = redis:sismember("VipAdd:" .. chat_id, user_id) and "|✅|" or "|✗|"
  ban = redis:sismember("BanUser:" .. chat_id, user_id) and "|✅|" or "|✗|"
  if getChat(user_id).result.username then
    Username = "<a href=\"tg://user?id=" .. user_id .. "\">" .. getChat(user_id).result.username .. "</a>"
  else
    Username = "<a href=\"tg://user?id=" .. user_id .. "\">" .. getChat(user_id).result.first_name .. "</a>"
  end
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• سودو " .. sudo .. "",
        callback_data = "addsudo:" .. user_id
      }
    },
    {
      {
        text = "• مدیر " .. mod .. "",
        callback_data = "promotee:" .. user_id
      },
      {
        text = "• مالک " .. owner .. "",
        callback_data = "ownerr:" .. user_id
      }
    },
    {
      {
        text = "• بیصدا " .. mute .. "",
        callback_data = "mytee:" .. user_id
      }
    },
    {
      {
        text = "• عضو ویژه " .. vip .. "",
        callback_data = "addvip:" .. user_id
      },
      {
        text = "• معاف  " .. free .. "",
        callback_data = "addmof:" .. user_id
      }
    },
    {
      {
        text = "• مسدود " .. ban .. "",
        callback_data = "bannnd:" .. user_id
      }
    },
    {
      {
        text = "• بستن",
        callback_data = "Exitacs:" .. user_id
      }
    }
  }
  Edit(chat_id, msg, "• فهرست دسترسی کاربر : " .. Username .. "\n• یکی از گزینه های زیر را انتخاب کنید :", keyboard, "html")
end

function setting1(msg, chat_id)
  if redis:get("force_NewUser" .. chat_id) then
    forcestatus = "کاربران جدید"
  else
    forcestatus = "همه کاربران"
  end
  DelBotMsg_Timeee = tonumber(redis:get("cbmtime:" .. chat_id) or 10)
  Force_Max = tonumber(redis:get("Force:Max:" .. chat_id) or 1)
  Force_Warn = tonumber(redis:get("Force:Pm:" .. chat_id) or 1)
  if redis:get("forceadd" .. chat_id) then
    forceadd = "فعال"
  else
    forceadd = "غیرفعال"
  end
  if redis:get("AutoLock:" .. chat_id) then
    autolock = "فعال"
  else
    autolock = "غیرفعال"
  end
  if redis:get("DelBotMsg:" .. chat_id) then
    delbotmsg = "فعال"
  else
    delbotmsg = "غیرفعال"
  end
  if redis:get("cbmon" .. chat_id) then
    delbotmsggg = "فعال"
  else
    delbotmsggg = "غیرفعال"
  end
  if redis:get("AntiTabchi" .. chat_id) == "All" then
    AntiTabchi = "تایید کردن"
  elseif redis:get("AntiTabchi" .. chat_id) == "Emoji" then
    AntiTabchi = "ارسال اموجی"
  elseif redis:get("AntiTabchi" .. chat_id) == "Number" then
    AntiTabchi = "ارسال اعداد"
  else
    AntiTabchi = "غیرفعال"
  end
  local stop = redis:get("EndTimeSee" .. chat_id) or "00"
  local start = redis:get("StartTimeSee" .. chat_id) or "00"
  local text = "به بخش تنظیمات عددی و حالت ها خوش امدید"
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• اداجباری : " .. forceadd .. "",
        callback_data = "forceadd:" .. chat_id
      }
    },
    {
      {
        text = "• تعداد اداجباری",
        callback_data = "LeaderCode" .. chat_id
      }
    },
    {
      {
        text = "⪻",
        callback_data = "forcemaxdown:" .. chat_id
      },
      {
        text = "" .. tostring(Force_Max) .. "",
        callback_data = "LeaderCode" .. chat_id
      },
      {
        text = "⪼",
        callback_data = "forcemaxup:" .. chat_id
      }
    },
    {
      {
        text = "• تعداداخطار اداجباری",
        callback_data = "LeaderCode" .. chat_id
      }
    },
    {
      {
        text = "⪻",
        callback_data = "forcemaxdwarn:" .. chat_id
      },
      {
        text = "" .. tostring(Force_Warn) .. "",
        callback_data = "LeaderCode" .. chat_id
      },
      {
        text = "⪼",
        callback_data = "forcemaxwarn:" .. chat_id
      }
    },
    {
      {
        text = "• وضعیت پاکسازی پیام ربات : " .. delbotmsggg .. "",
        callback_data = "delbotmsggg:" .. chat_id
      }
    },
    {
      {
        text = "• زمان پاکسازی پیام ربات",
        callback_data = "LeaderCode" .. chat_id
      }
    },
    {
      {
        text = "⪻",
        callback_data = "delbotmsgdownnn:" .. chat_id
      },
      {
        text = "" .. tostring(DelBotMsg_Timeee) .. "",
        callback_data = "LeaderCode" .. chat_id
      },
      {
        text = "⪼",
        callback_data = "delbotmsguppp:" .. chat_id
      }
    },
    {
      {
        text = "• قفل خودکار : " .. autolock .. "",
        callback_data = "autolock:" .. chat_id
      }
    },
    {
      {
        text = "• زمان پایان : " .. stop .. "",
        callback_data = "startauto:" .. chat_id
      },
      {
        text = "• زمان شروع : " .. start .. "",
        callback_data = "endauto:" .. chat_id
      }
    },
    {
      {
        text = "• نوع شناسایی تبچی : " .. AntiTabchi .. "",
        callback_data = "/tabchi_Identify" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄",
        callback_data = "ehsanleader:" .. chat_id
      },
      {
        text = "► صفحه بعد",
        callback_data = "page_b:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
end

function setting2(msg, chat_id)
  if redis:get("Flood:Status:" .. chat_id) then
    if redis:get("Flood:Status:" .. chat_id) == "kickuser" then
      floodstatus = "اخراج"
    elseif redis:get("Flood:Status:" .. chat_id) == "muteuser" then
      floodstatus = "بیصدا"
    elseif redis:get("Flood:Status:" .. chat_id) == "deletemsg" then
      floodstatus = "حذف پیام"
    end
  else
    floodstatus = "غیرفعال"
  end
  welcstatus = redis:get("Welcome:" .. chat_id) and "فعال" or "غیرفعال"
  Clean_Wlc = redis:get("CleanWlc" .. chat_id) and "فعال" or "غیرفعال"
  Spam = redis:get("Spam:Lock:" .. chat_id) and "فعال" or "غیرفعال"
  MSG_MAX = redis:get("Flood:Max:" .. chat_id) or 6
  CH_MAX = tonumber(redis:get("NUM_CH_MAX:" .. chat_id) or 400)
  TIME_CHECK = redis:get("Flood:Time:" .. chat_id) or 2
  Warn_Max = redis:get("Warn:Max:" .. chat_id) or 3
  Max_Clean_Wlc = redis:get("Max:CleanWlc" .. chat_id) or 30
  local text = "به بخش تنظیمات عددی و حالت ها خوش امدید\nصفحه دوم"
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• وضعیت فلود : " .. floodstatus .. "",
        callback_data = "floodstatus:" .. chat_id
      }
    },
    {
      {
        text = "• زمان برسی فلود",
        callback_data = "LeaderCode" .. chat_id
      }
    },
    {
      {
        text = "⪻",
        callback_data = "timemaxdown:" .. chat_id
      },
      {
        text = "" .. tostring(TIME_CHECK) .. "",
        callback_data = "LeaderCode" .. chat_id
      },
      {
        text = "⪼",
        callback_data = "timemaxup:" .. chat_id
      }
    },
    {
      {
        text = "• تعداد فلود",
        callback_data = "LeaderCode" .. chat_id
      }
    },
    {
      {
        text = "⪻",
        callback_data = "msgmaxdown:" .. chat_id
      },
      {
        text = "" .. tostring(MSG_MAX) .. "",
        callback_data = "LeaderCode" .. chat_id
      },
      {
        text = "⪼",
        callback_data = "msgmaxup:" .. chat_id
      }
    },
    {
      {
        text = "• وضعیت اسپم : " .. Spam .. "",
        callback_data = "lock spam:" .. chat_id
      }
    },
    {
      {
        text = "• تعداد اسپم",
        callback_data = "LeaderCode" .. chat_id
      }
    },
    {
      {
        text = "⪻",
        callback_data = "chmaxdown:" .. chat_id
      },
      {
        text = "" .. tostring(CH_MAX) .. "",
        callback_data = "LeaderCode" .. chat_id
      },
      {
        text = "⪼",
        callback_data = "chmaxup:" .. chat_id
      }
    },
    {
      {
        text = "• حداکثر اخطار",
        callback_data = "LeaderCode" .. chat_id
      }
    },
    {
      {
        text = "⪻",
        callback_data = "warnmaxdown:" .. chat_id
      },
      {
        text = "" .. tostring(Warn_Max) .. "",
        callback_data = "LeaderCode" .. chat_id
      },
      {
        text = "⪼",
        callback_data = "warnmaxup:" .. chat_id
      }
    },
    {
      {
        text = "• خوشامد : " .. welcstatus .. "",
        callback_data = "welcstatuse:" .. chat_id
      }
    },
    {
      {
        text = "• وضعیت پاکسازی خوشامدگویی : " .. Clean_Wlc .. "",
        callback_data = "/CleanWlc_status" .. chat_id
      }
    },
    {
      {
        text = "• زمان پاکسازی",
        callback_data = "/Show" .. chat_id
      }
    },
    {
      {
        text = "≪",
        callback_data = "/Low_Clean_Wlc" .. chat_id
      },
      {
        text = "" .. tostring(Max_Clean_Wlc) .. "",
        callback_data = "LeaderCode" .. chat_id
      },
      {
        text = "≫",
        callback_data = "/High_Clean_Wlc" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄",
        callback_data = "page_a:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
end

function Page1(msg, chat_id)
  local caption = redis:get("Lock:Caption:" .. chat_id)
  local link = redis:get("Lock:Link:" .. chat_id)
  local tag = redis:get("Lock:Tag:" .. chat_id)
  local fwd = redis:get("Lock:Forward:" .. chat_id)
  local file = redis:get("Lock:File:" .. chat_id)
  local game = redis:get("Lock:Game:" .. chat_id)
  local contact = redis:get("Lock:Contact:" .. chat_id)
  local fwdch = redis:get("Lock:Fwdch:" .. chat_id)
  local fwduser = redis:get("Lock:Fwduser:" .. chat_id)
  local caption = redis:get("Lock:Caption:" .. chat_id)
  local contact = contact == "Warn" and "اخطار❗️" or contact == "Kick" and "اخراج 👞" or contact == "Ban" and "مسدود 🚫" or contact == "Mute" and "بیصدا 🔇" or contact == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local fwduser = fwduser == "Warn" and "اخطار❗️" or fwduser == "Kick" and "اخراج 👞" or fwduser == "Ban" and "مسدود 🚫" or fwduser == "Mute" and "بیصدا 🔇" or fwduser == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local fwdch = fwdch == "Warn" and "اخطار❗️" or fwdch == "Kick" and "اخراج 👞" or fwdch == "Ban" and "مسدود 🚫" or fwdch == "Mute" and " بیصدا 🔇" or fwdch == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local game = game == "Warn" and "اخطار❗️" or game == "Kick" and "اخراج 👞" or game == "Ban" and "مسدود 🚫" or game == "Mute" and "بیصدا 🔇" or game == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local caption = caption == "Warn" and "اخطار❗️" or caption == "Kick" and "اخراج 👞" or caption == "Ban" and "مسدود 🚫" or caption == "Mute" and "بیصدا 🔇" or caption == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local file = file == "Warn" and " اخطار❗️" or file == "Kick" and "اخراج 👞" or file == "Mute" and "بیصدا 🔇" or file == "Ban" and "مسدود 🚫" or file == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local link = link == "Warn" and "اخطار❗️" or link == "Kick" and "اخراج 👞" or link == "Mute" and "بیصدا 🔇" or link == "Ban" and "مسدود 🚫" or link == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local fwd = fwd == "Warn" and "اخطار❗️" or fwd == "Kick" and "اخراج 👞" or fwd == "Ban" and "مسدود 🚫" or fwd == "Mute" and "بیصدا 🔇" or fwd == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• لینک : " .. link .. "",
        callback_data = "locklink:" .. chat_id
      }
    },
    {
      {
        text = "• فوروارد : " .. fwd .. "",
        callback_data = "lockfwd:" .. chat_id
      }
    },
    {
      {
        text = "• فوروارد کانال : " .. fwdch .. "",
        callback_data = "lockfwdch:" .. chat_id
      }
    },
    {
      {
        text = "• بازی : " .. game .. "",
        callback_data = "lockgame:" .. chat_id
      }
    },
    {
      {
        text = "• فایل : " .. file .. "",
        callback_data = "lockfile:" .. chat_id
      }
    },
    {
      {
        text = "• فوروارد کاربر : " .. fwduser .. "",
        callback_data = "lockfwduser:" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄",
        callback_data = "ehsanleader:" .. chat_id
      },
      {
        text = "► صفحه بعد",
        callback_data = "Pagetow:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "• وضعیت قفل های اصلی :\n[ صفحه اول ]", keyboard, "html")
end

function Page2(msg, chat_id)
  local bio = redis:get("Lock:bio:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local arabic = redis:get("Lock:Farsi:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local english = redis:get("Lock:English:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local contacttt = redis:get("Lock:Bot:" .. chat_id) and "فعال✅" or "غیرفعال ✖️"
  local botadder = redis:get("Lock:Botadder:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local tag = tag == "Warn" and "اخطار❗️" or tag == "Kick" and "اخراج 👞" or tag == "Ban" and "مسدود 🚫" or tag == "Mute" and "بیصدا 🔇" or tag == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• تگ : " .. tag .. "",
        callback_data = "locktag:" .. chat_id
      }
    },
    {
      {
        text = "• بیوگرافی :" .. bio .. "",
        callback_data = "lock bio:" .. chat_id
      }
    },
    {
      {
        text = "• فارسی :" .. arabic .. "",
        callback_data = "lockarabic:" .. chat_id
      }
    },
    {
      {
        text = "• انگلیسی :" .. english .. "",
        callback_data = "lockenglish:" .. chat_id
      }
    },
    {
      {
        text = "• ربات :" .. contacttt .. "",
        callback_data = "lockbot:" .. chat_id
      }
    },
    {
      {
        text = "• اضافه کننده ربات : " .. botadder .. "",
        callback_data = "lock botadder:" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄",
        callback_data = "Pageone:" .. chat_id
      },
      {
        text = "► صفحه بعد",
        callback_data = "Pagetree:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "• وضعیت قفل های اصلی :\n[ صفحه دوم ]", keyboard, "html")
end

function Page3(msg, chat_id)
  local editt = redis:get("Lock:Edit:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local markdown = redis:get("Lock:Markdown:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local hashtag = redis:get("Lock:Hashtag:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local men = redis:get("Lock:Mention:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local txts = redis:get("Lock:Text:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  if redis:get("Lock:Join:" .. chat_id) == "Link" then
    join = "ورود لینک"
  elseif redis:get("Lock:Join:" .. chat_id) == "Add" then
    join = "ورود ادد"
  else
    join = "غیرفعال ✖️"
  end
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• ویرایش پیام :" .. editt .. "",
        callback_data = "lockeditt:" .. chat_id
      }
    },
    {
      {
        text = "• فونت :" .. markdown .. "",
        callback_data = "lockmarkdown:" .. chat_id
      }
    },
    {
      {
        text = "• هشتگ : " .. hashtag .. "",
        callback_data = "lockhashtag:" .. chat_id
      }
    },
    {
      {
        text = "• ورود : " .. join .. "",
        callback_data = "lockjoin:" .. chat_id
      }
    },
    {
      {
        text = "• منشن :" .. men .. "",
        callback_data = "lockmen:" .. chat_id
      }
    },
    {
      {
        text = "• متن :" .. txts .. "",
        callback_data = "mutetext:" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄",
        callback_data = "Pagetow:" .. chat_id
      },
      {
        text = "► صفحه بعد",
        callback_data = "Pagefour:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "• وضعیت قفل های اصلی :\n[ صفحه سوم ]", keyboard, "html")
end

function Page4(msg, chat_id)
  local cmd = redis:get("Lock:Cmd:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local tgservisee = redis:get("Lock:Tgservice:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local hashtag = redis:get("Lock:Web:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local Group = redis:get("Lock:Group:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• دستورات : " .. cmd .. "",
        callback_data = "lockcmd:" .. chat_id
      }
    },
    {
      {
        text = "• سرویس تلگرام :" .. tgservisee .. "",
        callback_data = "locktgservise:" .. chat_id
      }
    },
    {
      {
        text = "• وب : " .. hashtag .. "",
        callback_data = "lockweb:" .. chat_id
      }
    },
    {
      {
        text = "• گروه : " .. Group .. "",
        callback_data = "lockgroup:" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄",
        callback_data = "Pagetree:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "• وضعیت قفل های اصلی :\n[ صفحه چهار ]", keyboard, "html")
end

function Page5(msg, chat_id)
  local contact = redis:get("Lock:Contact:" .. chat_id)
  local caption = redis:get("Lock:Caption:" .. chat_id)
  local sticker = redis:get("Lock:Sticker:" .. chat_id) and "فعال" or "غیرفعال ✖️"
  local stickerm = redis:get("Lock:Stickermm:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local video = redis:get("Lock:Video:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local music = redis:get("Lock:Music:" .. chat_id) and "فعال ✅" or "غیرفعال ✖️"
  local contact = contact == "Warn" and "اخطار❗️" or contact == "Kick" and "اخراج 👞" or contact == "Ban" and "مسدود 🚫" or contact == "Mute" and "بیصدا 🔇" or contact == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local caption = caption == "Warn" and "اخطار❗️" or caption == "Kick" and "اخراج 👞" or caption == "Ban" and "مسدود 🚫" or caption == "Mute" and "بیصدا 🔇" or caption == "Enable" and "فعال ✅" or "غیرفعال ✖️"
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• رسانه : " .. caption .. "",
        callback_data = "lockcaption:" .. chat_id
      }
    },
    {
      {
        text = "• مخاطب : " .. contact .. "",
        callback_data = "lockcontact:" .. chat_id
      }
    },
    {
      {
        text = "• استیکر :" .. sticker .. "",
        callback_data = "locksticker:" .. chat_id
      }
    },
    {
      {
        text = "• استیکر متحرک :" .. stickerm .. "",
        callback_data = "lockstickerm:" .. chat_id
      }
    },
    {
      {
        text = "• فیلم :" .. video .. "",
        callback_data = "mutevideo:" .. chat_id
      }
    },
    {
      {
        text = "• آهنگ :" .. music .. "",
        callback_data = "mutemusic:" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄",
        callback_data = "ehsanleader:" .. chat_id
      },
      {
        text = "► صفحه بعد",
        callback_data = "PageCAPTOW:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "• وضعیت قفل های رسانه :\n[ صفحه اول ]", keyboard, "html")
end

function Page6(msg, chat_id)
  local gif = redis:get("Lock:Gif:" .. chat_id) and "فعال" or "غیرفعال"
  local inlinee = redis:get("Lock:Inline:" .. chat_id) and "فعال" or "غیرفعال"
  local emoji = redis:get("Lock:Emoji:" .. chat_id) and "فعال" or "غیرفعال"
  local voice = redis:get("Lock:Voice:" .. chat_id) and "فعال" or "غیرفعال"
  local photo = redis:get("Lock:Photo:" .. chat_id) and "فعال" or "غیرفعال"
  local document = redis:get("Lock:File:" .. chat_id) and "فعال" or "غیرفعال"
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• گیف :" .. gif .. "",
        callback_data = "mutegif:" .. chat_id
      }
    },
    {
      {
        text = " • دکمه شیشه ای :" .. inlinee .. "",
        callback_data = "lockinline:" .. chat_id
      }
    },
    {
      {
        text = " • اموجی :" .. emoji .. "",
        callback_data = "lockemoji:" .. chat_id
      }
    },
    {
      {
        text = "• ویس :" .. voice .. "",
        callback_data = "mutevoice:" .. chat_id
      }
    },
    {
      {
        text = "• عکس :" .. photo .. "",
        callback_data = "mutephoto:" .. chat_id
      }
    },
    {
      {
        text = "• فایل :" .. document .. "",
        callback_data = "mutedocument:" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄",
        callback_data = "settings_a:" .. chat_id
      },
      {
        text = "► صفحه بعد",
        callback_data = "PageCAPTREE:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "• وضعیت قفل های رسانه :\n[ صفحه دوم ]", keyboard, "html")
end

function Page7(msg, chat_id)
  local video_note = redis:get("Lock:Videonote:" .. chat_id) and "فعال" or "غیرفعال"
  local reply = redis:get("Lock:Reply:" .. chat_id) and "فعال" or "غیرفعال"
  local location = redis:get("Lock:Location:" .. chat_id) and "فعال" or "غیرفعال"
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = " • فیلم سلفی :" .. video_note .. "",
        callback_data = "lockvideo_note:" .. chat_id
      }
    },
    {
      {
        text = "• ریپلای :" .. reply .. "",
        callback_data = "mutereply:" .. chat_id
      }
    },
    {
      {
        text = "• موقعیت مکانی :" .. location .. "",
        callback_data = "mutelocation:" .. chat_id
      }
    },
    {
      {
        text = "برگشت ◄",
        callback_data = "PageCAPTOW:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "• وضعیت قفل های رسانه :\n[ صفحه سوم ]", keyboard, "html")
end

function charge(msg, chat_id)
  local check_time = redis:ttl("ExpireData:" .. chat_id)
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
  elseif 60 < tonumber(check_time) and check_time < 3600 then
    remained_expire = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
  elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
    remained_expire = "" .. hours .. " ساعت و " .. min .. " دقیقه و " .. sec .. " ثانیه"
  elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
    remained_expire = "" .. day .. " روز و " .. hours .. " ساعت و " .. min .. " دقیقه و " .. sec .. " ثانیه"
  elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
    remained_expire = "" .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت و " .. min .. " دقیقه و " .. sec .. " ثانیه"
  elseif 31536000 < tonumber(check_time) then
    remained_expire = "" .. year .. " سال " .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت و " .. min .. " دقیقه و " .. sec .. " ثانیه"
  end
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• پانزده روز",
        callback_data = "Charge:FiDay:" .. chat_id
      },
      {
        text = "• ده روز",
        callback_data = "Charge:TenDay:" .. chat_id
      }
    },
    {
      {
        text = "• بیست روز",
        callback_data = "Charge:TeDay:" .. chat_id
      },
      {
        text = "• یک ماه",
        callback_data = "Charge:OneM:" .. chat_id
      }
    },
    {
      {
        text = "• سه ماه",
        callback_data = "Charge:treeM:" .. chat_id
      },
      {
        text = "• دو ماه",
        callback_data = "Charge:towM:" .. chat_id
      }
    },
    {
      {
        text = "• یک سال",
        callback_data = "Charge:Year:" .. chat_id
      },
      {
        text = "• شش ماه",
        callback_data = "Charge:sexM:" .. chat_id
      }
    },
    {
      {
        text = "◄ بستن",
        callback_data = "Exit:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "نوع شارژ گروه را انتخاب کنید !\n\n• اعتبار گروه: " .. remained_expire .. "", keyboard, "html")
end

function ModAccessuser(Leader, msg, chat_id, user)
  local user = Leader.message.entities[1].user.id
  local name = Leader.message.entities[1].user.frist_name
  getuser = "[" .. user .. "](tg://user?id=" .. user .. ")"
  if redis:sismember("settings_acsuser:" .. chat_id, user) then
    settings_acsuser = "|✗|"
  else
    settings_acsuser = "|✅|"
  end
  if redis:sismember("locks_acsuser:" .. chat_id, user) then
    locks_acsuser = "|✗|"
  else
    locks_acsuser = "|✅|"
  end
  if redis:sismember("menu_acsuser:" .. chat_id, user) then
    menu_acsuser = "|✗|"
  else
    menu_acsuser = "|✅|"
  end
  if redis:sismember("users_acsuser:" .. chat_id, user) then
    users_acsuser = "|✗|"
  else
    users_acsuser = "|✅|"
  end
  if redis:sismember("acsclean:" .. chat_id, user) then
    clean_acsuser = "|✗|"
  else
    clean_acsuser = "|✅|"
  end
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• به تنظیمات عددی: " .. settings_acsuser,
        callback_data = "/settings_acsuser" .. chat_id
      }
    },
    {
      {
        text = "• به اعمال عملیات روی قفل ها: " .. locks_acsuser,
        callback_data = "/locks_acsuser" .. chat_id
      }
    },
    {
      {
        text = "• به درخواست فهرست: " .. menu_acsuser,
        callback_data = "/menu_acsuser" .. chat_id
      }
    },
    {
      {
        text = "• به اعمال عملیات روی کاربر: " .. users_acsuser,
        callback_data = "/users_acsuser" .. chat_id
      }
    },
    {
      {
        text = "• به بخش پاکسازی: " .. clean_acsuser,
        callback_data = "/clean_acsuser" .. chat_id
      }
    },
    {
      {
        text = "بستن ",
        callback_data = "Exitacs:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "درحال تنظیم دسترسی های کاربر:" .. getuser .. "", keyboard, "md")
end

function ChatPermissions(msg, chat_id)
  can_add_web_page_previews = getChat(chat_id).result and getChat(chat_id).result.permissions.can_add_web_page_previews and "باز است" or "بسته است"
  can_change_info = getChat(chat_id).result and getChat(chat_id).result and getChat(chat_id).result.permissions.can_change_info and "باز است" or "بسته است"
  can_invite_users = getChat(chat_id).result and getChat(chat_id).result.permissions.can_invite_users and "باز است" or "بسته است"
  can_pin_messages = getChat(chat_id).result and getChat(chat_id).result.permissions.can_pin_messages and "باز است" or "بسته است"
  can_send_media_messages = getChat(chat_id).result and getChat(chat_id).result.permissions.can_send_media_messages and "باز است" or "بسته است"
  can_send_messages = getChat(chat_id).result and getChat(chat_id).result.permissions.can_send_messages and "باز است" or "بسته است"
  can_send_other_messages = getChat(chat_id).result and getChat(chat_id).result.permissions.can_send_other_messages and "باز است" or "بسته است"
  can_send_polls = getChat(chat_id).result and getChat(chat_id).result.permissions.can_send_polls and "باز است" or "بسته است"
  local keyboard = {}
  keyboard.inline_keyboard = {
    {
      {
        text = "• قرار دادن لینک : " .. can_add_web_page_previews .. "",
        callback_data = "AccessGp:AccessWeb" .. chat_id
      }
    },
    {
      {
        text = "• تغییر اطلاعات گروه : " .. can_change_info .. "",
        callback_data = "AccessGp:AccessChangeInfo" .. chat_id
      }
    },
    {
      {
        text = "• دعوت کاربر : " .. can_invite_users .. "",
        callback_data = "AccessGp:AccessInviteUsers" .. chat_id
      }
    },
    {
      {
        text = "• سنجاق پیام : " .. can_pin_messages .. "",
        callback_data = "AccessGp:AccessPinMessage" .. chat_id
      }
    },
    {
      {
        text = "• ارسال رسانه : " .. can_send_media_messages .. "",
        callback_data = "AccessGp:AccessMedia" .. chat_id
      }
    },
    {
      {
        text = "• ارسال پیام : " .. can_send_messages .. "",
        callback_data = "AccessGp:AccessSendMessage" .. chat_id
      }
    },
    {
      {
        text = "• ارسال استیکر و گیف : " .. can_send_other_messages .. "",
        callback_data = "AccessGp:AccessOther" .. chat_id
      }
    },
    {
      {
        text = "• ارسال نظرسنجی : " .. can_send_polls .. "",
        callback_data = "AccessGp:AccessPolls" .. chat_id
      }
    },
    {
      {
        text = "• برگشت",
        callback_data = "groupinfo_b:" .. chat_id
      }
    }
  }
  Edit(msg.chat_id, msg.inline_id, "دسترسی های گروه برای تغییر هر کدام روی ان کلیک کنید", keyboard, "md")
end

local LeaderCodeHelper = function()
  while true do
    local updates = getUpdates()
    vardump(updates)
    if updates and updates.result then
      do
        for i = 1, #updates.result do
          local msg = updates.result[i]
          offset = msg.update_id + 1
          if msg.message then
            local msg = msg.message
            local msg_id = msg.message_id
            local chat_id = msg.chat.id
            local user_id = msg.from.id
            local gp = msg.chat.title
            local getM = "<a href=\"tg://user?id=" .. user_id .. "\">" .. check_html(msg.from.first_name) .. "</a>"
            if msg.chat.type == "private" and msg.text then
              local text = msg.text
              if text:match("^[/#!]") and text then
                text = text:gsub("^[/#!]", "")
              end
              if is_Fullsudo(user_id) then
                if text and text:match("^acsgp (-100)(%d+)$") or text:match("^مدیریت گروه (-100)(%d+)$") then
                  local chat = text:match("^acsgp (.*)$") or text:match("^مدیریت گروه (.*)$")
                  if redis:get("CheckBot:" .. chat) then
                    local GroupsName = redis:get("StatsGpByName" .. chat) or "اطلاعاتی موجود نیست"
                    local check_time = redis:ttl("ExpireData:" .. chat)
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
                      EXPIRE = "نامحدود"
                    elseif 1 < tonumber(check_time) and check_time < 60 then
                      EXPIRE = "" .. sec .. " ثانیه شارژ میباشد"
                    elseif 60 < tonumber(check_time) and check_time < 3600 then
                      EXPIRE = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
                    elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
                      EXPIRE = "" .. hours .. " ساعت و " .. min .. " دقیقه"
                    elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
                      EXPIRE = "" .. day .. " روز و " .. hours .. " ساعت "
                    elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
                      EXPIRE = "" .. month .. " ماه " .. day .. " روز"
                    elseif 31536000 < tonumber(check_time) then
                      EXPIRE = "" .. year .. " سال " .. month .. " ماه " .. day .. ""
                    end
                    local keyboard = {}
                    keyboard.inline_keyboard = {
                      {
                        {
                          text = "• تنظیمات",
                          callback_data = "ehsanleader:" .. chat
                        }
                      },
                      {
                        {
                          text = "• بخش پاکسازی",
                          callback_data = "cclliif:" .. chat
                        },
                        {
                          text = "• اطلاعات گروه",
                          callback_data = "groupinfo:" .. chat
                        }
                      },
                      {
                        {
                          text = "• واردشدن",
                          callback_data = "AddToGp:" .. chat
                        }
                      },
                      {
                        {
                          text = "• خروج ربات",
                          callback_data = "LeaveToGp:" .. chat
                        },
                        {
                          text = "• شارژ گروه",
                          callback_data = "ChargeGp:" .. chat
                        }
                      },
                      {
                        {
                          text = "• پنل گروه ها",
                          callback_data = "ChatsPage:0"
                        }
                      },
                      {
                        {
                          text = "• بستن",
                          callback_data = "Exit:" .. chat
                        }
                      }
                    }
                    Send(user_id, msg_id, "نام گروه:" .. GroupsName .. "\nشارژ گروه :" .. EXPIRE .. "\n بخش مورد نظر خود را انتخاب کنید", keyboard, "html")
                  else
                    local keyboard = {}
                    keyboard.inline_keyboard = {
                      {
                        {
                          text = "پشتیبانی",
                          url = "https://telegram.me/" .. chjoi .. ""
                        }
                      }
                    }
                    Send(user_id, msg_id, "ربات در این گروه نصب نشده است", keyboard, "Markdown")
                  end
                end
                if string.lower(text) == "تنظیمات ربات" then
                  if redis:get("AutoInstall" .. Sudoid) then
                    AutoInstall = "فعال"
                  else
                    AutoInstall = "غیرفعال"
                  end
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• نصب خودکار: " .. AutoInstall .. "",
                        callback_data = "AutoInstall:" .. user_id
                      }
                    },
                    {
                      {
                        text = "• کانال جوین اجباری",
                        callback_data = "setchjoin:" .. user_id
                      },
                      {
                        text = "• یوزرنیم سودو",
                        callback_data = "usersudo:" .. user_id
                      }
                    },
                    {
                      {
                        text = "• درباره",
                        callback_data = "sudoaboto:" .. user_id
                      }
                    },
                    {
                      {
                        text = "• کانال دستورات",
                        callback_data = "setchcmd:" .. user_id
                      }
                    },
                    {
                      {
                        text = "• پیام اخر",
                        callback_data = "setendsgs:" .. user_id
                      },
                      {
                        text = "• منشی",
                        callback_data = "SetClerkAns:" .. user_id
                      }
                    },
                    {
                      {
                        text = "• نرخ",
                        callback_data = "resetnerkh:" .. user_id
                      }
                    }
                  }
                  Send(chat_id, msg_id, "به تنظیمات ربات ربات خوش امدید\nکانال جوین : " .. chjoi .. "\n پیام اخر :" .. EndMsg .. "\nیوزرنیم سودو : " .. UserSudo_1 .. "", keyboard, "html")
                end
                if (string.lower(text) == "ساخت کد هدیه" or text == "create giftcode") and not msg.reply_to_message then
                  Stext = "• لطفا تعداد کد هارا مشخص کنید :"
                  sendText(chat_id, msg_id, Stext, "html")
                  redis:setex("CreateGift:Time" .. chat_id, 180, true)
                end
                if text:match("^(%d+)$") and not msg.reply_to_message then
                  NumberCode = text:match("^(%d+)$")
                  if redis:get("CreateGift:Time" .. chat_id) then
                    redis:setex("CreateGift:Bouns" .. chat_id, 180, NumberCode)
                    Stext = "• لطفاً مقدار اعتبار جایزه کد ها را بر واحد روز ارسال نمایید :"
                    sendText(chat_id, msg_id, Stext, "html")
                    redis:del("CreateGift:Time" .. chat_id)
                  elseif redis:get("CreateGift:Bouns" .. chat_id) then
                    Stext = "• کد های ساخته شده : \n\n"
                    do
                      do
                        for i = 1, tonumber(redis:get("CreateGift:Bouns" .. chat_id)) do
                          CreateRandomCode = io.popen("hexdump -vn \"4\" -e ' /1 \"%02x\"' /dev/urandom"):read("*all")
                          redis:hset("GiftCode", CreateRandomCode, NumberCode)
                          Stext = Stext .. i .. " - <code>" .. CreateRandomCode .. "</code>\n"
                        end
                      end
                    end
                    redis:del("CreateGift:Bouns" .. chat_id)
                    sendText(chat_id, msg_id, Stext, "html")
                  end
                end
                if text == "پنل گروه ها" then
                  local page = 0
                  local keyboard = {}
                  keyboard.inline_keyboard = {}
                  local list = redis:smembers("group:")
                  if #list == 0 then
                    tt = "لیست گروهها مدیریت  خالی میباشد"
                  else
                    tt = "به بخش مدیریت گروه ها خوش امدید"
                    do
                      do
                        for i, i in pairs(list) do
                          local GroupsName = redis:get("StatsGpByName" .. i)
                          if GroupsName then
                            temp = {
                              {
                                {
                                  text = GroupsName,
                                  callback_data = "panel:" .. i
                                }
                              }
                            }
                          else
                            temp = {
                              {
                                {
                                  text = i,
                                  callback_data = "panel:" .. i
                                },
                                {
                                  text = "خروج",
                                  callback_data = "LeaveToGp:" .. i
                                }
                              }
                            }
                          end
                          if i < 10 then
                            do
                              for i, i in pairs(temp) do
                                table.insert(keyboard.inline_keyboard, i)
                              end
                            end
                          else
                            temp = {
                              {
                                {
                                  text = "► صفحه بعد",
                                  callback_data = "ChatsPage:1"
                                }
                              }
                            }
                            do
                              do
                                for i, i in pairs(temp) do
                                  table.insert(keyboard.inline_keyboard, i)
                                end
                              end
                            end
                            break
                          end
                        end
                      end
                    end
                    temp = {
                      {
                        {
                          text = "↫ بستن لیست گروه ها",
                          callback_data = "Exit:-1"
                        }
                      }
                    }
                    do
                      for i, i in pairs(temp) do
                        table.insert(keyboard.inline_keyboard, i)
                      end
                    end
                  end
                  Send(chat_id, msg_id, tt, keyboard, "html")
                end
              end
              if is_sudo(user_id) then
                if string.lower(text) == "start" then
                  local keyboard = {
                    {
                      "لیست سودو",
                      "لیست مسدود همگانی",
                      "لیست سکوت کلی"
                    },
                    {
                      "پنل گروه ها",
                      "لیست گروه",
                      "لیست گروه های تمدید"
                    },
                    {
                      "ساخت کد هدیه",
                      "لیست کد های هدیه"
                    },
                    {
                      "آمار ربات",
                      "شارژ ربات",
                      "پینگ"
                    },
                    {
                      "تنظیمات ربات"
                    }
                  }
                  text = "✼ لطفاً بخش مورد نظر خود را انتخاب کنید :"
                  send_keyb(chat_id, msg_id, text, keyboard, true, nil)
                end
                if string.lower(text) == "grouplist" or text == "لیست گروه" then
                  List = redis:smembers("group:")
                  if #List == 0 then
                    Stext = "• لیست گروه های مدیریتی خالی است !"
                    sendText(chat_id, msg_id, Stext, "html")
                  elseif #List > 15 then
                    local Stext = "• لیست گروه های مدیریتی :\n\n"
                    do
                      do
                        for i = 1, 15 do
                          local check_time = redis:ttl("ExpireData:" .. List[i])
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
                          if 1 < tonumber(check_time) and check_time < 60 then
                            remained_expire = "" .. sec .. " ثانیه"
                          elseif 60 < tonumber(check_time) and check_time < 3600 then
                            remained_expire = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
                          elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
                            remained_expire = "" .. hours .. " ساعت و " .. min .. " دقیقه"
                          elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
                            remained_expire = "" .. day .. " روز و " .. hours .. " ساعت"
                          elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
                            remained_expire = "" .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                          elseif 31536000 < tonumber(check_time) then
                            remained_expire = "" .. year .. " سال " .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                          end
                          if not redis:get("ExpireData:" .. List[i]) then
                            expire = "فاقد اعتبار !"
                          elseif check_time == -1 then
                            expire = "نامحدود !"
                          elseif check_time then
                            expire = "" .. remained_expire .. ""
                          end
                          local GpName = redis:get("StatsGpByName" .. List[i])
                          if GpName then
                            Gp = "" .. GpName .. ""
                          else
                            Gp = "یافت نشد !"
                          end
                          Stext = Stext .. i .. " - " .. Gp .. "\n• شناسه گروه : <code>" .. List[i] .. "</code>\n• اعتبار : " .. expire .. "\n <code>مدیریت گروه " .. List[i] .. "</code> \n➖➖➖➖➖➖➖\n"
                        end
                      end
                    end
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "► صفحه بعد",
                          callback_data = "Chatp:1"
                        }
                      }
                    }
                    Send(chat_id, msg_id, Stext, Keyboard, "html")
                  elseif #List <= 15 then
                    local List = redis:smembers("group:")
                    local Stext = "• لیست گروه های مدیریتی :\n\n"
                    do
                      do
                        for i = 1, #List do
                          local check_time = redis:ttl("ExpireData:" .. List[i])
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
                          if 1 < tonumber(check_time) and check_time < 60 then
                            remained_expire = "" .. sec .. " ثانیه"
                          elseif 60 < tonumber(check_time) and check_time < 3600 then
                            remained_expire = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
                          elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
                            remained_expire = "" .. hours .. " ساعت و " .. min .. " دقیقه"
                          elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
                            remained_expire = "" .. day .. " روز و " .. hours .. " ساعت"
                          elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
                            remained_expire = "" .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                          elseif 31536000 < tonumber(check_time) then
                            remained_expire = "" .. year .. " سال " .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                          end
                          if not redis:get("ExpireData:" .. List[i]) then
                            expire = "فاقد اعتبار !"
                          elseif check_time == -1 then
                            expire = "نامحدود !"
                          elseif check_time then
                            expire = "" .. remained_expire .. ""
                          end
                          local GpName = redis:get("StatsGpByName" .. List[i])
                          if GpName then
                            Gp = "" .. GpName .. ""
                          else
                            Gp = "یافت نشد !"
                          end
                          Stext = Stext .. i .. " - " .. Gp .. "\n• شناسه گروه : <code>" .. List[i] .. "</code>\n• اعتبار : " .. expire .. "\n <code>مدیریت گروه " .. List[i] .. "</code> \n➖➖➖➖➖➖➖\n"
                        end
                      end
                    end
                    sendText(chat_id, msg_id, Stext, "html")
                  end
                end
                if string.lower(text) == "پینگ" then
                  sendText(chat_id, msg_id, "pong", "html")
                end
                if string.lower(text) == "exgrouplist" or text == "لیست گروه های تمدید" then
                  local list = redis:smembers("group:")
                  text = ""
                  if #list == 0 then
                    sendText(chat_id, msg_id, "• لیست گروه های مدیریتی ربات خالی میباشد!", "html")
                  else
                    i = 1
                    do
                      do
                        for i, i in pairs(list) do
                          local check_time = redis:ttl("ExpireData:" .. i)
                          local Expire = ""
                          if check_time ~= -1 then
                            local day = math.floor(check_time / 86400) + 1
                            if day <= 5 then
                              Expire = day .. " روز"
                              GroupName = redis:get("StatsGpByName" .. i) or "------"
                              if getChatMember(i, BotHelper).result and getChatMember(i, BotHelper).result.can_invite_users then
                                exportChatInviteLink(i)
                                if getChat(i).result.invite_link then
                                  GpLink = "[ورود به گروه](" .. getChat(i).result.invite_link .. ")"
                                else
                                  GpLink = "---"
                                end
                              else
                                GpLink = "دسترسی دریافت لینک را ندارم !"
                              end
                              text = text .. i .. "- " .. GroupName .. "\n• شناسه گروه : " .. i .. "\n• اعتبار : " .. Expire .. "\n• لینک : " .. GpLink .. "\n┅┈┅┈┅┈┅┈┅┅\n"
                              i = i + 1
                            end
                          end
                        end
                      end
                    end
                    if text and text ~= "" then
                      sendText(chat_id, msg_id, "• لیست گروه هایی که کمتر ۵ روز اعتبار دارند:\n\n" .. text, "md")
                    else
                      sendText(chat_id, msg_id, "• لیست خالی میباشد.", "html")
                    end
                  end
                end
              end
              if not is_sudo(user_id) then
                local botcmd = msg.text == "/start" or msg.text == "(+)(%d+)" or msg.text == "دلیت اکانت" or msg.text == "ربات"
                if not botcmd then
                  if not msg.forward_from and not msg.forward_from_chat then
                    fwd_msg(Sudoid, chat_id, msg.message_id)
                  elseif msg.forward_from or msg.forward_from_chat then
                    fwd_msg(Sudoid, chat_id, msg.message_id)
                  end
                  if msg.reply_to_message and msg.reply_to_message.forward_from and msg.reply_to_message.from.id == BotHelper and msg.text then
                    sendText(msg.reply_to_message.forward_from.id, 0, msg.text, "md")
                    sendText(Sudoid, msg_id, "پیغام به کاربر ارسال شد", "md")
                  end
                end
                if string.lower(text) == "start" then
                  local nerkh = redis:get("ner") or "نرخی برای ربات تنظیم نشده است"
                  local textstart = redis:get("startmttn") or "، من یک ربات مدیریت گروه هستم ، برای استفاده از من داخل گروهت ؛ میتونی با مدیر من در ارتباط باشی.\nخوشحال میشم به شما هم خدمت کنم🌹\n\nیوزرنیم مدیر: " .. "@" .. UserSudo_1 .. "\nکانال ما: " .. "@" .. chjoi .. ""
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• کانال دستورات",
                        url = "https://t.me/" .. chcmd
                      }
                    },
                    {
                      {
                        text = "• خرید ربات",
                        url = "https://t.me/" .. UserSudo_1
                      }
                    },
                    {
                      {
                        text = "• کانال ربات",
                        url = "https://t.me/" .. chjoi
                      }
                    },
                    {
                      {
                        text = "• درباره ربات",
                        callback_data = "statsbott:" .. user_id
                      }
                    }
                  }
                  Send(chat_id, msg_id, "• سلام " .. getM .. [[

 ]] .. textstart .. "\n نرخ ربات:\n " .. nerkh .. "", keyboard, "html")
                end
              end
            end
            if msg.chat.type == "supergroup" then
              if not redis:get("Expirebot:" .. Sudoid) then
                redis:set("Expirebot:" .. Sudoid, true)
              end
              if not is_mod(chat_id, user_id) then
                if redis:get("Lock:Stickermm:" .. chat_id) and msg.sticker and msg.sticker.is_animated == true then
                  dlmsg(chat_id, msg_id)
                end
                if msg.new_chat_member and redis:get("Welcome:" .. chat_id) then
                  txtt = redis:get("Text:Welcome:" .. chat_id) or "🌸 سلام men \nبه گروه gp خوش آمدید !‌‌‌"
                  local Rules = redis:get("Rules:" .. chat_id) or ""
                  if getChatMember(chat_id, BotHelper).result.can_invite_users then
                    exportChatInviteLink(chat_id)
                    Link = getChat(chat_id).result.invite_link
                  end
                  local mm = "<a href=\"tg://user?id=" .. msg.new_chat_member.id .. "\">" .. check_html(msg.new_chat_member.first_name) .. "</a>"
                  local time = jdate("#h:#m:#s")
                  local date = jdate("#x , #Y/#M/#D")
                  local txtt = txtt:gsub("time", time)
                  local txtt = txtt:gsub("date", date)
                  local txtt = txtt:gsub("men", mm)
                  local txtt = txtt:gsub("name", msg.new_chat_member.first_name or "")
                  local txtt = txtt:gsub("rules", Rules)
                  local txtt = txtt:gsub("link", Link or "خطا 404 !")
                  local txtt = txtt:gsub("last", msg.new_chat_member.last_name or "")
                  local txtt = txtt:gsub("gp", msg.chat.title or "---")
                  local txtt = txtt:gsub("gb", "<b>" .. msg.chat.title .. "</b>" or "---")
                  if not redis:get("Welcome:Document" .. chat_id) and not redis:get("Welcome:Photo" .. chat_id) and not redis:get("Welcome:voice" .. chat_id) and not redis:get("Welcome:video" .. chat_id) then
                    sendText(chat_id, 0, txtt, "html")
                  elseif redis:get("Welcome:Document" .. chat_id) then
                    sendDocument(chat_id, redis:get("Welcome:Document" .. chat_id), 0, txtt, "html")
                  elseif redis:get("Welcome:voice" .. chat_id) then
                    sendVoice(chat_id, redis:get("Welcome:voice" .. chat_id), 0, txtt, "html")
                  elseif redis:get("Welcome:video" .. chat_id) then
                    sendVideo(chat_id, redis:get("Welcome:video" .. chat_id), 0, txtt, "html")
                  elseif redis:get("Welcome:Photo" .. chat_id) then
                    sendPhoto(chat_id, redis:get("Welcome:Photo" .. chat_id), 0, txtt, "html")
                  elseif redis:get("Welcome:videonote" .. chat_id) then
                    sendPhoto(chat_id, redis:get("Welcome:videonote" .. chat_id), 0, txtt, "html")
                  end
                end
                if msg.new_chat_member and redis:get("AntiTabchi" .. chat_id) == "All" then
                  Mute(chat_id, msg.new_chat_member.id, 1, 1)
                  local User = msg.new_chat_member.id
                  local getN = "<a href=\"tg://user?id=" .. msg.new_chat_member.id .. "\">" .. check_html(msg.new_chat_member.first_name) .. "</a>"
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• ربات نیستم",
                        callback_data = "tabchin:" .. User
                      }
                    }
                  }
                  Send(chat_id, 0, "کاربر " .. getN .. " شما به عنوان ربات تبلیغاتی شناخته شدی \nلطفا روی دکمه ربات نیستم کلیک کنید:", keyboard, "html")
                end
                if msg.new_chat_member and redis:get("AntiTabchi" .. chat_id) == "Emoji" then
                  Mute(chat_id, msg.new_chat_member.id, 1, 1)
                  local User = msg.new_chat_member.id
                  local getN = "<a href=\"tg://user?id=" .. msg.new_chat_member.id .. "\">" .. check_html(msg.new_chat_member.first_name) .. "</a>"
                  local Number1 = {
                    "😐",
                    "😂",
                    "💙",
                    "😑",
                    "🤣",
                    "😭",
                    "😊",
                    "✅",
                    "🙈",
                    "🇮🇷",
                    "⚽️",
                    "🍎",
                    "🍌",
                    "🐠",
                    "🤡",
                    "😎",
                    "🤠",
                    "🤖",
                    "🎃",
                    "🙌"
                  }
                  local Number2 = {
                    "🦄",
                    "🐬",
                    "🐓",
                    "🌈",
                    "🔥",
                    "⭐️",
                    "🌍",
                    "🌹",
                    "🍄",
                    "🍁",
                    "🍀",
                    "🐇",
                    "🐆",
                    "🐪",
                    "💄",
                    "👄",
                    "👩",
                    "🤦‍♂️",
                    "👑"
                  }
                  local Number3 = {
                    "❄️",
                    "🌪",
                    "☃️",
                    "☔️",
                    "🍕",
                    "🍔",
                    "🍇",
                    "🍓",
                    "🍦",
                    "🏈",
                    "🏀",
                    "🏓",
                    "🥊",
                    "🥇",
                    "🏆",
                    "🎺",
                    "🎲",
                    "✈️",
                    "🚦",
                    "🎡"
                  }
                  local Number4 = {
                    "🕋",
                    "🏞",
                    "⌚️",
                    "💻",
                    "☎️",
                    "⏰",
                    "💰",
                    "💎",
                    "🔫",
                    "⚙️",
                    "💣",
                    "💊",
                    "🎈",
                    "✂️",
                    "🔐",
                    "💞",
                    "☢️",
                    "♻️",
                    "🔰",
                    "🆘"
                  }
                  local WowEmoji = {
                    "" .. Number1[math.random(#Number1)] .. "",
                    "" .. Number2[math.random(#Number2)] .. "",
                    "" .. Number3[math.random(#Number3)] .. "",
                    "" .. Number4[math.random(#Number4)] .. ""
                  }
                  local OKNumber = Number2[math.random(#Number2)]
                  local OKNumber3 = Number3[math.random(#Number3)]
                  local OKNumber4 = Number4[math.random(#Number4)]
                  local OKNumber2 = WowEmoji[math.random(#WowEmoji)]
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "" .. OKNumber2 .. "",
                        callback_data = "tabchin:" .. User
                      },
                      {
                        text = "" .. OKNumber .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber3 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber4 .. "",
                        callback_data = "Bantabchi:" .. User
                      }
                    }
                  }
                  local keyboard2 = {}
                  keyboard2.inline_keyboard = {
                    {
                      {
                        text = "" .. OKNumber .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber2 .. "",
                        callback_data = "tabchin:" .. User
                      },
                      {
                        text = "" .. OKNumber3 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber4 .. "",
                        callback_data = "Bantabchi:" .. User
                      }
                    }
                  }
                  local keyboard3 = {}
                  keyboard3.inline_keyboard = {
                    {
                      {
                        text = "" .. OKNumber3 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber4 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber2 .. "",
                        callback_data = "tabchin:" .. User
                      },
                      {
                        text = "" .. OKNumber .. "",
                        callback_data = "Bantabchi:" .. User
                      }
                    }
                  }
                  local keyboard4 = {}
                  keyboard4.inline_keyboard = {
                    {
                      {
                        text = "" .. OKNumber4 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber3 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber2 .. "",
                        callback_data = "tabchin:" .. User
                      }
                    }
                  }
                  local InKeybord = {
                    "keyboard",
                    "keyboard2",
                    "keyboard3",
                    "keyboard4"
                  }
                  local RanKeybord = InKeybord[math.random(#InKeybord)]
                  if RanKeybord == "keyboard" then
                    MyKey = keyboard
                  elseif RanKeybord == "keyboard2" then
                    MyKey = keyboard2
                  elseif RanKeybord == "keyboard3" then
                    MyKey = keyboard3
                  elseif RanKeybord == "keyboard4" then
                    MyKey = keyboard4
                  end
                  Send(chat_id, 0, "کاربر " .. getN .. " شما به عنوان ربات تبلیغاتی شناخته شدی \n لطفا اموجی " .. OKNumber2 .. " را از بین گزینه های زیر انتخاب کنید :", MyKey, "html")
                end
                if msg.new_chat_member and redis:get("AntiTabchi" .. chat_id) == "Number" then
                  Mute(chat_id, msg.new_chat_member.id, 1, 1)
                  local User = msg.new_chat_member.id
                  local getN = "<a href=\"tg://user?id=" .. msg.new_chat_member.id .. "\">" .. check_html(msg.new_chat_member.first_name) .. "</a>"
                  local Number1 = {
                    "1",
                    "2",
                    "3",
                    "4",
                    "5",
                    "6",
                    "7",
                    "8",
                    "9",
                    "10"
                  }
                  local Number2 = {
                    "11",
                    "12",
                    "13",
                    "14",
                    "15",
                    "16",
                    "17",
                    "18",
                    "19",
                    "20"
                  }
                  local Number3 = {
                    "21",
                    "22",
                    "23",
                    "24",
                    "25",
                    "26",
                    "27",
                    "28",
                    "29",
                    "30"
                  }
                  local Number4 = {
                    "1",
                    "2",
                    "3",
                    "4",
                    "5",
                    "6",
                    "7"
                  }
                  local OKNumber1 = Number1[math.random(#Number1)]
                  local OKNumber2 = Number2[math.random(#Number2)]
                  local OKNumber3 = Number3[math.random(#Number3)]
                  local OKNumber4 = Number4[math.random(#Number4)]
                  local OKNumber5 = Number4[math.random(#Number4)]
                  local OKBy = OKNumber4 + OKNumber5
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "" .. OKBy .. "",
                        callback_data = "tabchin:" .. User
                      },
                      {
                        text = "" .. OKNumber1 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber2 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber3 .. "",
                        callback_data = "Bantabchi:" .. User
                      }
                    }
                  }
                  local keyboard2 = {}
                  keyboard2.inline_keyboard = {
                    {
                      {
                        text = "" .. OKNumber1 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKBy .. "",
                        callback_data = "tabchin:" .. User
                      },
                      {
                        text = "" .. OKNumber2 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber3 .. "",
                        callback_data = "Bantabchi:" .. User
                      }
                    }
                  }
                  local keyboard3 = {}
                  keyboard3.inline_keyboard = {
                    {
                      {
                        text = "" .. OKNumber2 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber1 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKBy .. "",
                        callback_data = "tabchin:" .. User
                      },
                      {
                        text = "" .. OKNumber3 .. "",
                        callback_data = "Bantabchi:" .. User
                      }
                    }
                  }
                  local keyboard4 = {}
                  keyboard4.inline_keyboard = {
                    {
                      {
                        text = "" .. OKNumber3 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber1 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKNumber2 .. "",
                        callback_data = "Bantabchi:" .. User
                      },
                      {
                        text = "" .. OKBy .. "",
                        callback_data = "tabchin:" .. User
                      }
                    }
                  }
                  local InKeybord = {
                    "keyboard",
                    "keyboard2",
                    "keyboard3",
                    "keyboard4"
                  }
                  local RanKeybord = InKeybord[math.random(#InKeybord)]
                  if RanKeybord == "keyboard" then
                    MyKey = keyboard
                  elseif RanKeybord == "keyboard2" then
                    MyKey = keyboard2
                  elseif RanKeybord == "keyboard3" then
                    MyKey = keyboard3
                  elseif RanKeybord == "keyboard4" then
                    MyKey = keyboard4
                  end
                  Send(chat_id, 0, "کاربر " .. getN .. " شما به عنوان ربات تبلیغاتی شناخته شدی \n با استفاده از محاسبه زیر  از حالت محدود خارج شوید\n\n" .. OKNumber4 .. " + " .. OKNumber5 .. " = ?", MyKey, "html")
                end
              end
              if msg.new_chat_member and msg.new_chat_member.id == BotHelper and is_sudo(user_id) then
                local free = 86400
                redis:setex("ExpireData:" .. chat_id, free, true)
                if redis:get("AutoInstall" .. Sudoid) then
                  if redis:get("CheckBot:" .. chat_id) then
                    local Lc = "⌯ گروه " .. gp .. " ازقبل درلیست گروه های مدیریتی وجود داشت"
                    sendText(chat_id, msg_id, Lc, "md")
                  else
                    local date = jdate("• تاریخ : #x , #Y/#M/#D \n• ساعت :#h:#m:#s")
                    redis:sadd("group:", chat_id)
                    local Lc = "⌯ گروه " .. gp .. " باموفقیت به لیست گروه های مدیریتی ربات افزوده شد"
                    local Hash = "StatsGpByName" .. chat_id
                    local ChatTitle = msg.chat.title
                    redis:set(Hash, ChatTitle)
                    redis:set("CheckBot:" .. chat_id, true)
                    redis:set("ForceJoin:" .. chat_id, true)
                    redis:set("Lock:Link:" .. chat_id, "Enable")
                    redis:set("Lock:Forward:" .. chat_id, "Enable")
                    redis:set("Lock:Web:" .. chat_id, "Enable")
                    redis:set("Lock:Tgservice:" .. chat_id, "Enable")
                    redis:set("Lock:Botadder:" .. chat_id, "Enable")
                    redis:set("Lock:Bot:" .. chat_id, "Enable")
                    redis:set("Lock:Fwduser:" .. chat_id, "Enable")
                    redis:set("Lock:Inline:" .. chat_id, "Enable")
                    redis:set("Lock:Fwdch:" .. chat_id, "Enable")
                    redis:set("Lock:File:" .. chat_id, "Enable")
                    redis:set("Lock:Contact:" .. chat_id, "Enable")
                    redis:set("Lock:Location:" .. chat_id, "Enable")
                    local textlogs = "• گروه جدیدی به لیست مدیریت اضافه شد !\n\n" .. date .. "\n\n• مشخصات همکار اضافه کننده:\n • ایدی همکار : <code>" .. msg.from.id .. "</code>\n• نام همکار : " .. getM .. "\n\n• مشخصات گروه:\n• نام گروه : <code>" .. gp .. "</code>\n• آیدی گروه : <code>" .. chat_id .. "</code>\n\n• برای مدیریت گروه :\n<code>acsgp " .. chat_id .. "</code>\n<code>مدیریت گروه " .. chat_id .. "</code>"
                    local SText = "▪️سازنده و مدیران گروه ارتقا مقام یافتند !\n\n• سازنده گروه :\n"
                    local status = getChatAdministrators(chat_id).result
                    if status then
                      do
                        for i, i in pairs(status) do
                          if i.status == "creator" and i.user.id then
                            if i.user.username then
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.username .. "</a>"
                            elseif i.user.first_name then
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. check_html(i.user.first_name) .. "</a>"
                            else
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.id .. "</a>"
                            end
                            SText = SText .. "" .. username .. "\n"
                            redis:sadd("OwnerList:" .. chat_id, i.user.id)
                          end
                        end
                      end
                    end
                    SText = SText .. "• مدیران گروه :\n"
                    local status = getChatAdministrators(chat_id).result
                    if status then
                      do
                        for i, i in pairs(status) do
                          if i.status == "administrator" and i.user.id then
                            if i.user.username then
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.username .. "</a>"
                            elseif i.user.first_name then
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. check_html(i.user.first_name) .. "</a>"
                            else
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.id .. "</a>"
                            end
                            SText = SText .. i .. "- " .. username .. "\n"
                            redis:sadd("ModList:" .. chat_id, i.user.id)
                          end
                        end
                      end
                    end
                    bc = Lc .. [[
 
 ]] .. SText
                    local keyboards = {}
                    keyboards.inline_keyboard = {
                      {
                        {
                          text = " تنظیم پنل",
                          callback_data = "setpanel:" .. chat_id
                        },
                        {
                          text = " تنظیم شارژ",
                          callback_data = "ChargeGp:" .. chat_id
                        }
                      }
                    }
                    Send(chat_id, 0, bc, keyboards, "html")
                    local keyboard = {}
                    keyboard.inline_keyboard = {
                      {
                        {
                          text = "• واردشدن",
                          callback_data = "AddToGp:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• خروج ربات",
                          callback_data = "LeaveToGp:" .. chat_id
                        },
                        {
                          text = "• شارژ گروه",
                          callback_data = "ChargeGp:" .. chat_id
                        }
                      }
                    }
                    Send(Sudoid, 0, textlogs, keyboard, "html")
                  end
                end
              end
              if msg.new_chat_member and msg.new_chat_member.id == BotHelper and not is_sudo(user_id) then
                local nerkh = redis:get("ner") or "تنظیم نشده"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "پشتیبانی",
                      url = "https://telegram.me/" .. UserSudo_1 .. ""
                    }
                  }
                }
                Send(chat_id, 0, " گروه شما در دیتابیس ربات نصب نشده وربات خارج میشود\n نرخ ربات:\n\n " .. nerkh .. "", keyboard, "Markdown")
                Leave(chat_id)
              end
              if msg.text then
                local text = msg.text
                if text:match("^[/#!]") and text then
                  text = text:gsub("^[/#!]", "")
                end
                if 100 >= tonumber(redis:ttl("ExpireData:" .. chat_id)) and not redis:get("Mel" .. chat_id) then
                  redis:setex("Mel" .. chat_id, 100, true)
                  if getChatMember(chat_id, BotHelper).result and getChatMember(chat_id, BotHelper).result.can_invite_users then
                    exportChatInviteLink(chat_id)
                    if getChat(chat_id).result.invite_link then
                      GpLink = "[ورود به گروه](" .. getChat(chat_id).result.invite_link .. ")"
                    else
                      GpLink = "---"
                    end
                  else
                    GpLink = "دسترسی دریافت لینک را ندارم !"
                  end
                  sendText(Sudoid, 0, "• شارژ گروهی رو به پایان است!\n• اطلاعات گروه \n• شناسه گروه : " .. chat_id .. "\n• نام گروه: " .. gp .. "\n• لینک گروه : " .. GpLink .. " ", "html")
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "تمدید ربات",
                        url = "https://t.me/" .. UserSudo_1
                      }
                    }
                  }
                  local owners = redis:smembers("OwnerList:" .. chat_id)
                  if #owners ~= 0 then
                    text = "• مدیر گرامی: "
                    do
                      do
                        for i, i in pairs(owners) do
                          local firstname = redis:get("firstname" .. i)
                          if firstname then
                            username = "<a href=\"tg://user?id=" .. i .. "\">" .. check_html(firstname) .. "</a>"
                          else
                            username = "<a href=\"tg://user?id=" .. i .. "\">" .. i .. "</a>"
                          end
                          txt = text .. " " .. username .. "\n"
                        end
                      end
                    end
                    Send(chat_id, 0, "" .. txt .. "\n\nاعتبار گروه شما متاسفانه به پایان رسیده است ، با استفاده از گزینه زیر لطفا هرچه سریع تر اقدام به تمدید نمایید.", keyboard, "html")
                  else
                    Send(chat_id, 0, "مدیران گرامی !\n\nاعتبار گروه شما متاسفانه به پایان رسیده است ، با استفاده از گزینه زیر لطفا هرچه سریع تر اقدام به تمدید نمایید.", keyboard, "html")
                  end
                  remRedis(chat_id)
                  sendText(TD_ID, 0, "leave " .. chat_id .. "", "html")
                  Leave(chat_id)
                  redis:del("Mel" .. chat_id)
                end
                if is_leader(user_id) then
                  if string.lower(text) == "dump" or text == "var" then
                    local TeXT = serpent.block(msg, {comment = false})
                    TXT = string.gsub(TeXT, "\n", "\n\r\n")
                    sendText(chat_id, msg_id, TXT, "html")
                  end
                  if text and (text:match("^chargebot (%d+)$") or text:match("^شارژربات (%d+)$")) then
                    local chargee = text:match("^chargebot (%d+)$") or text:match("^شارژربات (%d+)$") * 86400
                    redis:setex("Expirebot:" .. Sudoid, chargee, true)
                    local ti = math.floor(chargee / 86400)
                    local text = "• ربات  به مدت  [" .. ti .. "] روز شارژ شد!"
                    sendText(chat_id, msg_id, text, "md")
                  end
                end
                if is_Fullsudo(user_id) then
                  if text and (text:match("^شارژ هدیه (%d+)$") or text:match("^addcharge (%d+)$")) then
                    local gps = text:match("شارژ هدیه (%d+)$") or text:match("addcharge(%d+)$")
                    do
                      do
                        for i, i in pairs(redis:smembers("group:")) do
                          local ex = redis:ttl("ExpireData:" .. i)
                          if ex and ex >= 0 then
                            local b = math.floor(ex / day) + 1
                            local t = tonumber(gps)
                            local time = b + t
                            local time = time * day
                            redis:setex("ExpireData:" .. i, time, true)
                          end
                          XD = i
                        end
                      end
                    end
                    sendText(chat_id, msg_id, "• دستور شارژ هدیه به تمام گروه ها\n• تعداد گروه:[" .. XD .. "]\n• تعداد روز شارژ هدیه:[" .. gps .. "]\n• باموفقیت انجام شد", "md")
                    local gp = redis:smembers("group:") or 0
                    do
                      for i = 1, #gp do
                        sendText(gp[i], 0, "تبریک گروه شما توسط مالک ربات به مدت[" .. gps .. "] روز شارژ هدیه شد", "md")
                      end
                    end
                  end
                  if string.lower(text) == "gplist" or text == "پنل گروه ها" then
                    local page = 0
                    local keyboard = {}
                    keyboard.inline_keyboard = {}
                    local list = redis:smembers("group:")
                    if #list == 0 then
                      tt = "لیست گروهها مدیریت  خالی میباشد"
                    else
                      tt = "به بخش مدیریت گروه ها خوش امدید"
                      do
                        do
                          for i, i in pairs(list) do
                            local GroupsName = redis:get("StatsGpByName" .. i)
                            if GroupsName then
                              temp = {
                                {
                                  {
                                    text = GroupsName,
                                    callback_data = "panel:" .. i
                                  }
                                }
                              }
                            else
                              temp = {
                                {
                                  {
                                    text = i,
                                    callback_data = "panel:" .. i
                                  },
                                  {
                                    text = "خروج",
                                    callback_data = "LeaveToGp:" .. i
                                  }
                                }
                              }
                            end
                            if i < 10 then
                              do
                                for i, i in pairs(temp) do
                                  table.insert(keyboard.inline_keyboard, i)
                                end
                              end
                            else
                              temp = {
                                {
                                  {
                                    text = "► صفحه بعد",
                                    callback_data = "ChatsPage:1"
                                  }
                                }
                              }
                              do
                                do
                                  for i, i in pairs(temp) do
                                    table.insert(keyboard.inline_keyboard, i)
                                  end
                                end
                              end
                              break
                            end
                          end
                        end
                      end
                      temp = {
                        {
                          {
                            text = "↫ بستن لیست گروه ها",
                            callback_data = "Exit:-1"
                          }
                        }
                      }
                      do
                        for i, i in pairs(temp) do
                          table.insert(keyboard.inline_keyboard, i)
                        end
                      end
                    end
                    Send(chat_id, msg_id, tt, keyboard, "html")
                  end
                  if string.lower(text) and string.lower(text):match("^fwd (.*)$") and msg.reply_to_message then
                    local action = string.lower(text):match("^fwd (.*)$")
                    if not msg.reply_to_message then
                    elseif action == "sgps" then
                      local gp = redis:smembers("group:") or 0
                      local gps = redis:scard("group:") or 0
                      do
                        do
                          for i = 1, #gp do
                            fwd_msg(gp[i], chat_id, msg.reply_to_message.message_id)
                          end
                        end
                      end
                      sendText(chat_id, msg_id, "• پیام شما با موفقیت به [ " .. gps .. " ] سوپرگروه فوروارد شد !", "html")
                    elseif action == "pv" then
                      local pv = redis:smembers("ChatPrivite") or 0
                      local pvs = redis:scard("ChatPrivite") or 0
                      do
                        do
                          for i = 1, #pv do
                            fwd_msg(pv[i], chat_id, msg.reply_to_message.message_id)
                          end
                        end
                      end
                      sendText(chat_id, msg_id, "• پیام شما با موفقیت به [ " .. pvs .. " ] کاربر فوروارد شد !", "html")
                    elseif action == "all" then
                      local pv = redis:smembers("ChatPrivite") or 0
                      local pvv = redis:scard("ChatPrivite") or 0
                      do
                        do
                          for i = 1, #pv do
                            fwd_msg(pv[i], chat_id, msg.reply_to_message.message_id)
                          end
                        end
                      end
                      local sgp = redis:smembers("group:") or 0
                      local sgps = redis:scard("group:") or 0
                      do
                        do
                          for i = 1, #sgp do
                            fwd_msg(sgp[i], chat_id, msg.reply_to_message.message_id)
                          end
                        end
                      end
                      sendText(chat_id, msg_id, "• پیام شما با موفقیت به [ " .. sgps .. " ] سوپر گروه [ " .. pvv .. " ] کاربر فوروارد شد !", "html")
                    end
                  end
                end
                if is_sudo(user_id) then
                  if string.lower(text) == "exgrouplist" or text == "لیست گروه های تمدید" then
                    local list = redis:smembers("group:")
                    text = ""
                    if #list == 0 then
                      sendText(chat_id, msg_id, "• لیست گروه های مدیریتی ربات خالی میباشد!", "html")
                    else
                      i = 1
                      do
                        do
                          for i, i in pairs(list) do
                            local check_time = redis:ttl("ExpireData:" .. i)
                            local Expire = ""
                            if check_time ~= -1 then
                              local day = math.floor(check_time / 86400) + 1
                              if day <= 5 then
                                Expire = day .. " روز"
                                GroupName = redis:get("StatsGpByName" .. i) or "------"
                                if getChatMember(i, BotHelper).result and getChatMember(i, BotHelper).result.can_invite_users then
                                  exportChatInviteLink(i)
                                  if getChat(i).result.invite_link then
                                    GpLink = "[ورود به گروه](" .. getChat(i).result.invite_link .. ")"
                                  else
                                    GpLink = "---"
                                  end
                                else
                                  GpLink = "دسترسی دریافت لینک را ندارم !"
                                end
                                text = text .. i .. "- " .. GroupName .. "\n• شناسه گروه : " .. i .. "\n• اعتبار : " .. Expire .. "\n• لینک : " .. GpLink .. "\n┅┈┅┈┅┈┅┈┅┅\n"
                                i = i + 1
                              end
                            end
                          end
                        end
                      end
                      if text and text ~= "" then
                        sendText(chat_id, msg_id, "• لیست گروه هایی که کمتر ۵ روز اعتبار دارند:\n\n" .. text, "md")
                      else
                        sendText(chat_id, msg_id, "• لیست خالی میباشد.", "html")
                      end
                    end
                  end
                  if (string.lower(text) == "ruadmin" or text == "دسترسی های ربات") and not msg.reply_to_message then
                    if getChatMember(chat_id, BotHelper).result.status == "administrator" then
                      local Leader = getChatMember(chat_id, BotHelper).result
                      can_change_info = Leader.can_change_info and "[✓]" or "[✘]"
                      can_delete_messages = Leader.can_delete_messages and "[✓]" or "[✘]"
                      can_restrict_members = Leader.can_restrict_members and "[✓]" or "[✘]"
                      can_invite_users = Leader.can_invite_users and "[✓]" or "[✘]"
                      can_pin_messages = Leader.can_pin_messages and "[✓]" or "[✘]"
                      can_promote_members = Leader.can_promote_members and "[✓]" or "[✘]"
                      outputApi = "◄ وضعیت ربات Api : ادمین میباشد !\n\n•• دسترسی ها :\n\n• تغییر اطلاعات گروه : " .. can_change_info .. "\n• حذف پیام : " .. can_delete_messages .. "\n• اخراج و محدود کردن : " .. can_restrict_members .. "\n• دریافت لینک دعوت : " .. can_invite_users .. "\n• سنجاق پیام : " .. can_pin_messages .. "\n• اضافه کردن ادمین : " .. can_promote_members .. ""
                    else
                      outputApi = "◄ وضعیت ربات Api : ادمین نمیباشد !"
                    end
                    if getChatMember(chat_id, TD_ID).result.status == "administrator" then
                      local Leader = getChatMember(chat_id, TD_ID).result
                      can_change_info = Leader.can_change_info and "[✓]" or "[✘]"
                      can_delete_messages = Leader.can_delete_messages and "[✓]" or "[✘]"
                      can_restrict_members = Leader.can_restrict_members and "[✓]" or "[✘]"
                      can_invite_users = Leader.can_invite_users and "[✓]" or "[✘]"
                      can_pin_messages = Leader.can_pin_messages and "[✓]" or "[✘]"
                      can_promote_members = Leader.can_promote_members and "[✓]" or "[✘]"
                      outputCli = "◄ وضعیت ربات Cli : ادمین میباشد !\n\n•• دسترسی ها :\n\n• تغییر اطلاعات گروه : " .. can_change_info .. "\n• حذف پیام : " .. can_delete_messages .. "\n• اخراج و محدود کردن : " .. can_restrict_members .. "\n• دریافت لینک دعوت : " .. can_invite_users .. "\n• سنجاق پیام : " .. can_pin_messages .. "\n• اضافه کردن ادمین : " .. can_promote_members .. ""
                    else
                      outputCli = "◄ وضعیت ربات Cli : ادمین نمیباشد !"
                    end
                    Stext = outputApi .. [[


]] .. outputCli
                    sendText(chat_id, msg_id, Stext, "html")
                  end
                  if string.lower(text) == "menu sudo" or text == "فهرست سودو" then
                    local keyboard = {}
                    keyboard.inline_keyboard = {
                      {
                        {
                          text = "• امار ربات",
                          callback_data = "stats:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• لیست سودو",
                          callback_data = "sudolist:" .. chat_id
                        },
                        {
                          text = "• راهنما سودو",
                          callback_data = "helpsudo:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• لیست مسدود همگانی",
                          callback_data = "PageBamAllsudo:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• بستن فهرست سودو",
                          callback_data = "Exit:" .. chat_id
                        }
                      }
                    }
                    Send(chat_id, msg_id, "بخش مورد نظر خود را انتخاب کنید:", keyboard, "html")
                  end
                  if text == "add" or text == "نصب" then
                    local free = 86400
                    redis:setex("ExpireData:" .. chat_id, free, true)
                    if redis:get("CheckBot:" .. chat_id) then
                      local Lc = "⌯ گروه " .. gp .. " ازقبل درلیست گروه های مدیریتی وجود داشت"
                      sendText(chat_id, msg_id, Lc, "md")
                    else
                      local date = jdate("• تاریخ : #x , #Y/#M/#D \n• ساعت :#h:#m:#s")
                      redis:sadd("group:", chat_id)
                      local Lc = "⌯ گروه " .. gp .. " باموفقیت به لیست گروه های مدیریتی ربات افزوده شد"
                      local Hash = "StatsGpByName" .. chat_id
                      local ChatTitle = msg.chat.title
                      redis:set(Hash, ChatTitle)
                      redis:set("CheckBot:" .. chat_id, true)
                      redis:set("ForceJoin:" .. chat_id, true)
                      redis:set("Lock:Link:" .. chat_id, "Enable")
                      redis:set("Lock:Forward:" .. chat_id, "Enable")
                      redis:set("Lock:Web:" .. chat_id, "Enable")
                      redis:set("Lock:Tgservice:" .. chat_id, "Enable")
                      redis:set("Lock:Botadder:" .. chat_id, "Enable")
                      redis:set("Lock:Bot:" .. chat_id, "Enable")
                      redis:set("Lock:Fwduser:" .. chat_id, "Enable")
                      redis:set("Lock:Inline:" .. chat_id, "Enable")
                      redis:set("Lock:Fwdch:" .. chat_id, "Enable")
                      redis:set("Lock:File:" .. chat_id, "Enable")
                      redis:set("Lock:Contact:" .. chat_id, "Enable")
                      redis:set("Lock:Location:" .. chat_id, "Enable")
                      local textlogs = "• گروه جدیدی به لیست مدیریت اضافه شد !\n\n" .. date .. "\n\n• مشخصات همکار اضافه کننده:\n • ایدی همکار : <code>" .. msg.from.id .. "</code>\n• نام همکار : " .. getM .. "\n\n• مشخصات گروه:\n• نام گروه : <code>" .. gp .. "</code>\n• آیدی گروه : <code>" .. chat_id .. "</code>\n\n• برای مدیریت گروه :\n<code>acsgp " .. chat_id .. "</code>\n<code>مدیریت گروه " .. chat_id .. "</code>"
                      local SText = "▪️سازنده و مدیران گروه ارتقا مقام یافتند !\n\n• سازنده گروه :\n"
                      local status = getChatAdministrators(chat_id).result
                      if status then
                        do
                          for i, i in pairs(status) do
                            if i.status == "creator" and i.user.id then
                              if i.user.username then
                                username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.username .. "</a>"
                              elseif i.user.first_name then
                                username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. check_html(i.user.first_name) .. "</a>"
                              else
                                username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.id .. "</a>"
                              end
                              SText = SText .. "" .. username .. "\n"
                              redis:sadd("OwnerList:" .. chat_id, i.user.id)
                            end
                          end
                        end
                      end
                      SText = SText .. "• مدیران گروه :\n"
                      local status = getChatAdministrators(chat_id).result
                      if status then
                        do
                          for i, i in pairs(status) do
                            if i.status == "administrator" and i.user.id then
                              if i.user.username then
                                username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.username .. "</a>"
                              elseif i.user.first_name then
                                username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. check_html(i.user.first_name) .. "</a>"
                              else
                                username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.id .. "</a>"
                              end
                              SText = SText .. i .. "- " .. username .. "\n"
                              redis:sadd("ModList:" .. chat_id, i.user.id)
                            end
                          end
                        end
                      end
                      bc = Lc .. [[
 
 ]] .. SText
                      local keyboards = {}
                      keyboards.inline_keyboard = {
                        {
                          {
                            text = " تنظیم پنل",
                            callback_data = "setpanel:" .. chat_id
                          },
                          {
                            text = " تنظیم شارژ",
                            callback_data = "ChargeGp:" .. chat_id
                          }
                        }
                      }
                      Send(chat_id, 0, bc, keyboards, "html")
                      local keyboard = {}
                      keyboard.inline_keyboard = {
                        {
                          {
                            text = "• واردشدن",
                            callback_data = "AddToGp:" .. chat_id
                          }
                        },
                        {
                          {
                            text = "• خروج ربات",
                            callback_data = "LeaveToGp:" .. chat_id
                          },
                          {
                            text = "• شارژ گروه",
                            callback_data = "ChargeGp:" .. chat_id
                          }
                        }
                      }
                      Send(Sudoid, 0, textlogs, keyboard, "html")
                    end
                  end
                  if text == "rem" or text == "حذف گروه" then
                    local date = jdate("• تاریخ: #x , #Y/#M/#D \n• ساعت: #h:#m:#s")
                    if not redis:get("CheckBot:" .. chat_id) then
                      local text = "• گروه " .. msg.chat.title .. " در لیست گروه های مدیریتی ربات موجود نیست."
                      sendText(chat_id, msg_id, text, "md")
                    else
                      local text = "• گروه " .. msg.chat.title .. "  با موفقیت از لیست گروه های مدیریتی ربات حذف گردید. "
                      redis:del("CheckBot:" .. chat_id)
                      getuser = "<a href=\"tg://user?id=" .. msg.from.id .. "\">" .. check_html(msg.from.first_name) .. "</a>"
                      sendText(chat_id, msg_id, text, "md")
                      sendText(Sudoid, 0, "• گروهی از لیست مدیریت ربات حذف شد !\n" .. date .. "\n\n• اطلاعات گروه\n\n• نام گروه : " .. msg.chat.title .. "\n• آیدی گروه : " .. chat_id .. "\n\n• مشخصات همکار:\n\n• ایدی همکار : " .. msg.from.id .. "\n• نام همکار : " .. getuser .. "", "html")
                    end
                  end
                  if text == "leave" or text == "خروج" then
                    remRedis(chat_id)
                    sendText(TD_ID, 0, "leave " .. chat_id .. "", "html")
                    Leave(chat_id)
                    local text = "• ربات از گروه " .. msg.chat.title .. "  خارج شد"
                    getuser = "<a href=\"tg://user?id=" .. msg.from.id .. "\">" .. check_html(msg.from.first_name) .. "</a>"
                    sendText(chat_id, msg_id, text, "md")
                    sendText(Sudoid, 0, "• گروهی از لیست مدیریت ربات خروج شد !\n" .. date .. "\n\n• اطلاعات گروه\n\n• نام گروه : " .. msg.chat.title .. "\n• آیدی گروه : " .. chat_id .. "\n\n• مشخصات همکار:\n\n• ایدی همکار : " .. msg.from.id .. "\n• نام همکار : " .. getuser .. "", "html")
                  end
                  if text == "full" or text == "نامحدود" then
                    local date = jdate("• تاریخ: #x , #Y/#M/#D \n• ساعت: #h:#m:#s")
                    redis:set("ExpireData:" .. chat_id, true)
                    redis:set("Mel" .. chat_id, true)
                    sendText(chat_id, msg_id, "گروه به صورت نامحدود شارژ شد!", "md")
                    getuser = "<a href=\"tg://user?id=" .. msg.from.id .. "\">" .. check_html(msg.from.first_name) .. "</a>"
                    local textlogs = "• گروه جدیدی به مدت نامحدود شارژ شد !\n\n" .. date .. "\n\n• مشخصات همکار اضافه کننده:\n • ایدی همکار : " .. msg.from.id .. "\n• نام همکار : " .. getuser .. "\n\n• مشخصات گروه:\n• نام گروه : " .. msg.chat.title .. "\n• آیدی گروه : " .. chat_id .. "\n\n• برای مدیریت گروه :\n<code>acsgp " .. chat_id .. "</code>\n<code>مدیریت گروه " .. chat_id .. "</code>"
                    sendText(Sudoid, 0, textlogs, "html")
                  end
                  if text and (text:match("^charge (%d+)$") or text:match("^شارژ (%d+)$")) then
                    local chargee = text:match("^charge (%d+)$") or text:match("^شارژ (%d+)$") * 86400
                    redis:setex("ExpireData:" .. chat_id, chargee, true)
                    redis:del("Mel" .. chat_id)
                    local ti = math.floor(chargee / 86400)
                    local date = jdate("تاریخ: #x , #Y/#M/#D \n ساعت: #h:#m:#s")
                    local text = "• گروه  " .. msg.chat.title .. "  به مدت  [" .. ti .. "] روز شارژ شد!"
                    getuser = "<a href=\"tg://user?id=" .. msg.from.id .. "\">" .. check_html(msg.from.first_name) .. "</a>"
                    local textlogs = "• گروه جدیدی به مدت " .. ti .. " شارژ شد !\n\n" .. date .. "\n\n• مشخصات همکار اضافه کننده:\n • ایدی همکار : " .. msg.from.id .. "\n• نام همکار : " .. getuser .. "\n\n• مشخصات گروه:\n• نام گروه : " .. msg.chat.title .. "\n• آیدی گروه : " .. chat_id .. "\n\n• برای مدیریت گروه :\n<code>acsgp " .. chat_id .. "</code>\n<code>مدیریت گروه " .. chat_id .. "</code>"
                    sendText(chat_id, msg_id, text, "md")
                    sendText(Sudoid, 0, textlogs, "html")
                  end
                end
                if is_owner(chat_id, user_id) then
                  if (text == "setgpadmin" or text == "تنظیم ادمین") and msg.reply_to_message then
                    local aa = getChatMember(chat_id, BotHelper).result
                    if aa.can_promote_members then
                      if not msg.reply_to_message then
                      else
                        local user = msg.reply_to_message.from.id
                        local name = msg.reply_to_message.from.first_name
                        getuser = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(name) .. "</a>"
                        if redis:get("changgo:" .. chat_id .. user) then
                          infogp = "|✅|"
                        else
                          infogp = "|✗|"
                        end
                        if redis:get("resmm:" .. chat_id .. user) then
                          resmember = "|✅|"
                        else
                          resmember = "|✗|"
                        end
                        if redis:get("pinmm:" .. chat_id .. user) then
                          pinmsage = "|✅|"
                        else
                          pinmsage = "|✗|"
                        end
                        if redis:get("delmsgg:" .. chat_id .. user) then
                          delmsgsgp = "|✅|"
                        else
                          delmsgsgp = "|✗|"
                        end
                        if redis:get("invblink:" .. chat_id .. user) then
                          invbylink = "|✅|"
                        else
                          invbylink = "|✗|"
                        end
                        if redis:get("adadmin:" .. chat_id .. user) then
                          addadmin = "|✅|"
                        else
                          addadmin = "|✗|"
                        end
                        local BD = "تنظیم ادمین کاربر:【" .. getuser .. "】\nدر گروه : " .. redis:get("StatsGpByName" .. chat_id) .. "\n برای ادمین کردن شخص روی دسترسی های زیر کلیک کرده و سپس {تایید تغییرات } را بزنید"
                        local keyboard = {}
                        keyboard.inline_keyboard = {
                          {
                            {
                              text = "• تغییر اطلاعات گروه " .. infogp .. "",
                              callback_data = "etal:" .. chat_id
                            }
                          },
                          {
                            {
                              text = "• اخراج و محدود کردن کاربر " .. resmember .. "",
                              callback_data = "mah:" .. chat_id
                            }
                          },
                          {
                            {
                              text = "• سنجاق کردن پیام ها " .. pinmsage .. "",
                              callback_data = "sanj:" .. chat_id
                            }
                          },
                          {
                            {
                              text = "• حذف پیام ها " .. delmsgsgp .. "",
                              callback_data = "delmsggg:" .. chat_id
                            }
                          },
                          {
                            {
                              text = "• دعوت با لینک " .. invbylink .. "",
                              callback_data = "invblinkk:" .. chat_id
                            }
                          },
                          {
                            {
                              text = "• ارتقا به ادمین" .. addadmin .. "",
                              callback_data = "adadminn:" .. chat_id
                            }
                          },
                          {
                            {
                              text = "• تایید تغییرات",
                              callback_data = "setetla:" .. chat_id
                            }
                          }
                        }
                        Send(chat_id, msg_id, BD, keyboard, "html")
                      end
                    else
                      sendText(chat_id, msg_id, "دسترسی ارتقا به ادمین برای ربات فعال نشده است", "html")
                    end
                  end
                  if (text == "دسترسی مدیر" or text == "acsm") and msg.reply_to_message then
                    local user = "" .. msg.reply_to_message.from.id .. ""
                    local name = msg.reply_to_message.from.first_name
                    getuser = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(name) .. "</a>"
                    if not is_mod(chat_id, user) then
                      sendText(chat_id, msg_id, "• کاربر " .. getuser .. " مدیر گروه نمیباشد", "html")
                    elseif not msg.reply_to_message then
                    elseif tonumber(user) == tonumber(BotHelper) then
                      sendText(chat_id, msg_id, "• شما نمیتوانید به ربات مقام دهید", "html")
                    elseif tonumber(user) == tonumber(Sudoid) then
                      sendText(chat_id, msg_id, "• شما نمیتوانید به صاحب ربات مقام دهید.", "html")
                    else
                      if redis:sismember("settings_acsuser:" .. chat_id, user) then
                        settings_acsuser = "|✗|"
                      else
                        settings_acsuser = "|✅|"
                      end
                      if redis:sismember("locks_acsuser:" .. chat_id, user) then
                        locks_acsuser = "|✗|"
                      else
                        locks_acsuser = "|✅|"
                      end
                      if redis:sismember("menu_acsuser:" .. chat_id, user) then
                        menu_acsuser = "|✗|"
                      else
                        menu_acsuser = "|✅|"
                      end
                      if redis:sismember("users_acsuser:" .. chat_id, user) then
                        users_acsuser = "|✗|"
                      else
                        users_acsuser = "|✅|"
                      end
                      if redis:sismember("acsclean:" .. chat_id, user) then
                        clean_acsuser = "|✗|"
                      else
                        clean_acsuser = "|✅|"
                      end
                      local keyboard = {}
                      keyboard.inline_keyboard = {
                        {
                          {
                            text = "• به تنظیمات عددی: " .. settings_acsuser,
                            callback_data = "/settings_acsuser" .. chat_id
                          }
                        },
                        {
                          {
                            text = "• به اعمال عملیات روی قفل ها: " .. locks_acsuser,
                            callback_data = "/locks_acsuser" .. chat_id
                          }
                        },
                        {
                          {
                            text = "• به درخواست فهرست: " .. menu_acsuser,
                            callback_data = "/menu_acsuser" .. chat_id
                          }
                        },
                        {
                          {
                            text = "• به اعمال عملیات روی کاربر: " .. users_acsuser,
                            callback_data = "/users_acsuser" .. chat_id
                          }
                        },
                        {
                          {
                            text = "• به بخش پاکسازی: " .. clean_acsuser,
                            callback_data = "/clean_acsuser" .. chat_id
                          }
                        },
                        {
                          {
                            text = "بستن ",
                            callback_data = "Exitacs:" .. chat_id
                          }
                        }
                      }
                      Send(chat_id, msg_id, "درحال تنظیم دسترسی های کاربر:" .. getuser .. "", keyboard, "html")
                    end
                  end
                  if (string.lower(text) == "config" or text == "پیکربندی") and not msg.reply_to_message then
                    local SText = "▪️سازنده و مدیران گروه ارتقا مقام یافتند !\n\n• سازنده گروه :\n"
                    local status = getChatAdministrators(chat_id) and getChatAdministrators(chat_id).result
                    if status then
                      do
                        for i, i in pairs(status) do
                          if i.status == "creator" and i.user.id then
                            if i.user.username then
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.username .. "</a>"
                            elseif i.user.first_name then
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. check_html(i.user.first_name) .. "</a>"
                            else
                              username = "" .. i.user.id .. ""
                            end
                            SText = SText .. "" .. username .. "\n"
                            redis:sadd("OwnerList:" .. chat_id, i.user.id)
                          end
                        end
                      end
                    end
                    SText = SText .. "• مدیران گروه :\n"
                    local status = getChatAdministrators(chat_id) and getChatAdministrators(chat_id).result
                    if status then
                      do
                        for i, i in pairs(status) do
                          if i.status == "administrator" and i.user.id then
                            if i.user.username then
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. i.user.username .. "</a>"
                            elseif i.user.first_name then
                              username = "<a href=\"tg://user?id=" .. i.user.id .. "\">" .. check_html(i.user.first_name) .. "</a>"
                            else
                              username = "" .. i.user.id .. ""
                            end
                            SText = SText .. i .. "- " .. username .. "\n"
                            redis:sadd("ModList:" .. chat_id, i.user.id)
                          end
                        end
                      end
                    end
                    sendText(chat_id, msg_id, SText, "html")
                  end
                end
                if is_mod(chat_id, user_id) then
                  if (string.lower(text) == "کد هدیه" or text == "giftcode") and not msg.reply_to_message then
                    Stext = "• لطفا کد هدیه را ارسال کنید :"
                    sendText(chat_id, msg_id, Stext, "html")
                    redis:setex("CreateGift:Gp" .. chat_id, 180, true)
                  end
                  if text:match("^(%S+)$") and redis:get("CreateGift:Gp" .. chat_id) and not msg.reply_to_message then
                    Code = text:match("^(%S+)$")
                    if redis:ttl("ExpireData:" .. chat_id) == -1 then
                      Stext = "• به دلیل نامحدود بودن اعتبار گروه ، شما نمیتوانید از کد هدیه استفاده کنید !"
                    elseif redis:hget("GiftCode", Code) then
                      DayCharge = redis:hget("GiftCode", Code)
                      CodeCharge = redis:hget("GiftCode", Code) * 86400
                      AfterCharge = redis:ttl("ExpireData:" .. chat_id)
                      redis:setex("ExpireData:" .. chat_id, CodeCharge + AfterCharge, true)
                      local vv = CodeCharge + AfterCharge
                      local ti = math.floor(vv / 86400)
                      Stext = "• کد صحیح میباشد !\n• " .. DayCharge .. " روز به اعتبار گروه شما افزوده شد !\nاعتبار جدید گروه " .. ti .. ""
                      text = " کدهدیه : \n" .. Code .. "\n استفاده شد توسط :\n نام کاربر :" .. getM .. "\n مشخصات گروه :" .. chat_id .. " | " .. gp .. "\nاعتبار جدید گروه " .. ti .. ""
                      redis:hdel("GiftCode", Code)
                      redis:del("CreateGift:Gp" .. chat_id)
                    else
                      Stext = "• کد وارد شده اشتباه ، یا قبلا استفاده شده است !"
                      redis:del("CreateGift:Gp" .. chat_id)
                    end
                    sendText(Sudoid, 0, text, "html")
                    sendText(chat_id, msg_id, Stext, "html")
                  end
                  if string.lower(text) == "delall" or text == "پاکسازی" and msg.reply_to_message then
                    local getR = "<a href=\"tg://user?id=" .. msg.reply_to_message.from.id .. "\">" .. check_html(msg.reply_to_message.from.first_name) .. "</a>"
                    if not msg.reply_to_message then
                    else
                      local aa = getChatMember(chat_id, TD_ID).result
                      if aa.can_delete_messages then
                        sendText(chat_id, msg_id, "• تمام پیام های کاربر " .. getR .. " پاکسازی شد !", "html")
                        sendText(TD_ID, 0, "delall " .. chat_id .. " " .. msg.reply_to_message.from.id, "html")
                      else
                        sendText(chat_id, msg_id, "دسترسی {حذف پیام} برای ربات فعال نشده است !", "html")
                      end
                    end
                  end
                  if (string.lower(text) == "idfwd" or text == "ایدی فرواردی") and msg.reply_to_message.forward_from then
                    if msg.reply_to_message.forward_from.forward_sender_name then
                      sendText(chat_id, msg_id, "• پیام دارای مشکلات زیر میباشد \n ۱- پیام فرواردی از کانال میباشد\n ۲- فروارد کابر بسته است ", "html")
                    else
                      GetIdUser(chat_id, msg_id, msg.reply_to_message.forward_from.id, msg.reply_to_message.forward_from.first_name, nil)
                    end
                  end
                  if (string.lower(text) == "id" or text == "ایدی") and msg.reply_to_message then
                    if msg.reply_to_message.from.username then
                      GetIdUser(chat_id, msg_id, msg.reply_to_message.from.id, msg.reply_to_message.from.first_name, msg.reply_to_message.from.username)
                    else
                      GetIdUser(chat_id, msg_id, msg.reply_to_message.from.id, msg.reply_to_message.from.first_name, nil)
                    end
                  end
                  if (string.lower(text) == "id" or text == "ایدی") and not msg.reply_to_message then
                    if msg.from.username then
                      GetIdUser(chat_id, msg_id, msg.from.id, msg.from.first_name, msg.from.username)
                    else
                      GetIdUser(chat_id, msg_id, msg.from.id, msg.from.first_name, nil)
                    end
                  end
                  if (string.lower(text):match("^id (%d+)$") or text:match("^ایدی (%d+)$")) and not msg.reply_to_message then
                    UseriD = string.lower(text):match("^id (%d+)$") or text:match("^ایدی (%d+)$")
                    if getChat(UseriD).error_code == 400 then
                      Ptext = "• خطا!"
                      sendText(chat_id, msg_id, Ptext, "html")
                    elseif getChat(UseriD).result.username then
                      GetIdUser(chat_id, msg_id, UseriD, getChat(UseriD).result.first_name, getChat(UseriD).result.username)
                    else
                      GetIdUser(chat_id, msg_id, UseriD, getChat(UseriD).result.first_name, nil)
                    end
                  end
                  if (string.lower(text):match("^id (.*)$") or text:match("^ایدی (.*)$")) and msg.entities and msg.entities[1] and msg.entities[1].type == "text_mention" then
                    UseriD = msg.entities[1].user.id
                    FName = msg.entities[1].user.first_name
                    if msg.entities[1].user.username then
                      GetIdUser(chat_id, msg_id, UseriD, FName, msg.entities[1].user.username)
                    else
                      GetIdUser(chat_id, msg_id, UseriD, FName, nil)
                    end
                  end
                  if text and (text:match("^[Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee] (.*)$") or text:match("^تنظیم خوشامد (.*)$")) and msg.reply_to_message then
                    WelcomeText = text:match("^[Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee] (.*)$") or text:match("^تنظیم خوشامد (.*)$")
                    redis:set("Text:Welcome:" .. chat_id, "🌸" .. WelcomeText)
                    if msg.reply_to_message.audio then
                      redis:del("Welcome:Photo" .. chat_id)
                      redis:del("Welcome:voice" .. chat_id)
                      redis:del("Welcome:video" .. chat_id)
                      redis:set("Welcome:Document" .. chat_id, msg.reply_to_message.audio.file_id)
                      Stext = "• متن خوشآمدگویی با آهنگ تنظیم شد !"
                      sendText(chat_id, msg_id, Stext, "html")
                    elseif msg.reply_to_message.voice then
                      redis:del("Welcome:Photo" .. chat_id)
                      redis:del("Welcome:Document" .. chat_id)
                      redis:set("Welcome:voice" .. chat_id, msg.reply_to_message.voice.file_id)
                      Stext = "• متن خوشآمدگویی با ویس تنظیم شد !"
                      sendText(chat_id, msg_id, Stext, "html")
                    elseif msg.reply_to_message.video then
                      redis:del("Welcome:Photo" .. chat_id)
                      redis:del("Welcome:Document" .. chat_id)
                      redis:del("Welcome:voice" .. chat_id)
                      redis:set("Welcome:video" .. chat_id, msg.reply_to_message.video.file_id)
                      Stext = "• متن خوشآمدگویی با فیلم تنظیم شد !"
                      sendText(chat_id, msg_id, Stext, "html")
                    elseif msg.reply_to_message.document then
                      redis:del("Welcome:Photo" .. chat_id)
                      redis:del("Welcome:voice" .. chat_id)
                      redis:del("Welcome:video" .. chat_id)
                      redis:set("Welcome:Document" .. chat_id, msg.reply_to_message.document.file_id)
                      Stext = "• متن خوشآمدگویی با فایل تنظیم شد !"
                      sendText(chat_id, msg_id, Stext, "html")
                    elseif msg.reply_to_message.animation then
                      redis:del("Welcome:Photo" .. chat_id)
                      redis:del("Welcome:voice" .. chat_id)
                      redis:del("Welcome:video" .. chat_id)
                      redis:set("Welcome:Document" .. chat_id, msg.reply_to_message.animation.file_id)
                      Stext = "• متن خوشآمدگویی با گیف تنظیم شد "
                      sendText(chat_id, msg_id, Stext, "html")
                      sendText(chat_id, msg_id, Stext, "html")
                    elseif msg.reply_to_message.photo then
                      redis:del("Welcome:Document" .. chat_id)
                      redis:del("Welcome:voice" .. chat_id)
                      redis:del("Welcome:video" .. chat_id)
                      redis:set("Welcome:Photo" .. chat_id, msg.reply_to_message.photo[1].file_id)
                      Stext = "• متن خوشآمدگویی با عکس تنظیم شد !"
                      sendText(chat_id, msg_id, Stext, "html")
                    elseif msg.reply_to_message.video_note then
                      redis:del("Welcome:Document" .. chat_id)
                      redis:del("Welcome:voice" .. chat_id)
                      redis:del("Welcome:video" .. chat_id)
                      redis:del("Welcome:Photo" .. chat_id)
                      redis:set("Welcome:videonote" .. chat_id, msg.reply_to_message.video_note.file_id)
                      Stext = "• متن خوشآمدگویی با فیلم سلفی تنظیم شد !"
                      sendText(chat_id, msg_id, Stext, "html")
                    end
                  end
                  if (string.lower(text):match("^mute (%d+) (%d+)$") or text:match("^سکوت (%d+) (%d+)$")) and msg.reply_to_message then
                    local CmdEn = {
                      string.match(string.lower(text), "^mute (%d+) (%d+)$")
                    }
                    local CmdFa = {
                      string.match(text, "سکوت (%d+) (%d+)$")
                    }
                    local H = CmdEn[1] or CmdFa[1]
                    local M = CmdEn[2] or CmdFa[2]
                    local H = H * 3600
                    local M = M * 60
                    local HaselJam = tonumber(H) + tonumber(M)
                    SetMuteUser(msg, chat_id, msg_id, msg.reply_to_message.from.id, msg.reply_to_message.from.first_name, tonumber(HaselJam))
                  elseif (text:match("^mute (%d+)") or text:match("^سکوت (%d+)")) and msg.reply_to_message then
                    local CmdEn = {
                      string.match(text, "^(mute) (%d+)$")
                    }
                    local CmdFa = {
                      string.match(text, "^(سکوت) (%d+)$")
                    }
                    local Matches1 = CmdEn[2] or CmdFa[2]
                    local Hours = (Matches1 or 0) * 3600
                    if tonumber(Hours) == 0 then
                      sendText(chat_id, msg_id, "• زمان وارد شده اشتباه میباشد !", "html")
                    else
                      SetMuteUser(msg, chat_id, msg_id, msg.reply_to_message.from.id, msg.reply_to_message.from.first_name, tonumber(Hours))
                    end
                  end
                  if (string.lower(text) == "mute" or text == "سکوت" or text == "بیصدا" or text == "خفه") and msg.reply_to_message then
                    SetMuteUser(msg, chat_id, msg_id, msg.reply_to_message.from.id, msg.reply_to_message.from.first_name, nil)
                  elseif (string.lower(text) == "unmute" or text == "حذف سکوت" or text == "حذف بیصدا" or text == "باصدا") and msg.reply_to_message then
                    RemMuteUser(chat_id, msg_id, msg.reply_to_message.from.id, msg.reply_to_message.from.first_name)
                  end
                  if (string.lower(text) == "mutefwd" or text == "سکوت فرواردی" or text == "بیصدا فرواردی" or text == "خفه فرواردی") and msg.reply_to_message.forward_from then
                    if msg.reply_to_message.forward_from.id then
                      SetMuteUser(msg, chat_id, msg_id, msg.reply_to_message.forward_from.id, msg.reply_to_message.forward_from.first_name, nil)
                    else
                      sendText(chat_id, msg_id, "• پیام دارای مشکلات زیر میباشد \n ۱- پیام فرواردی از کانال میباشد\n ۲- فروارد کابر بسته است ", "html")
                    end
                  elseif (string.lower(text) == "unmutefwd" or text == "حذف سکوت فرواردی" or text == "حذف بیصدا فرواردی" or text == "باصدا فرواردی") and msg.reply_to_message.forward_from then
                    RemMuteUser(chat_id, msg_id, msg.reply_to_message.forward_from.id, msg.reply_to_message.forward_from.first_name)
                  end
                  if string.lower(text) == "lock poll" or text == "قفل نظرسنجی" then
                    test = {
                      can_send_messages = true,
                      can_send_media_messages = true,
                      can_send_polls = false,
                      can_send_other_messages = true,
                      can_add_web_page_previews = true,
                      can_change_info = false,
                      can_invite_users = true,
                      can_pin_messages = false
                    }
                    setChatPermissions(chat_id, test)
                    sendText(chat_id, msg_id, "• قفل ارسال نطرسنجی فعال شد", "html")
                  end
                  if string.lower(text) == "unlock poll" or text == "بازکردن نظرسنجی" then
                    test = {
                      can_send_messages = true,
                      can_send_media_messages = true,
                      can_send_polls = true,
                      can_send_other_messages = true,
                      can_add_web_page_previews = true,
                      can_change_info = false,
                      can_invite_users = true,
                      can_pin_messages = false
                    }
                    setChatPermissions(chat_id, test)
                    sendText(chat_id, msg_id, "• قفل ارسال نطرسنجی غیرفعال شد", "html")
                  end
                  if string.lower(text) == "invite cr" or text == "دعوت سازنده" then
                    local text = "• کاربر: " .. getM .. "\n⌯ گروه " .. gp .. " درخواست شما به پی وی مدیر ربات ارسال شد لطفا تا رسیدگی صبور باشید"
                    sendText(chat_id, msg_id, text, "html")
                    if getChatMember(chat_id, BotHelper).result and getChatMember(chat_id, BotHelper).result.can_invite_users then
                      exportChatInviteLink(chat_id)
                      if getChat(chat_id).result.invite_link then
                        GpLink = getChat(chat_id).result.invite_link
                      else
                        GpLink = "---"
                      end
                    else
                      GpLink = "دسترسی دریافت لینک را ندارم !"
                    end
                    sendText(Sudoid, 0, "• فردی از گروهی درخواست پشتیبانی دارد !\n• نام گروه : " .. gp .. "\n• آیدی گروه : " .. chat_id .. "\n• نام شخص: " .. getM .. "\n لینک گروه :" .. GpLink .. "", "html")
                  end
                  if string.lower(text) == "gplink" or text == "لینک گروه" then
                    if getChatMember(chat_id, BotHelper).result and getChatMember(chat_id, BotHelper).result.can_invite_users then
                      exportChatInviteLink(chat_id)
                      if getChat(chat_id).result.invite_link then
                        GpLink = getChat(chat_id).result.invite_link
                      else
                        GpLink = "---"
                      end
                      local keyboard = {}
                      keyboard.inline_keyboard = {
                        {
                          {
                            text = "• اشتراک لینک",
                            url = "https://t.me/share/url?url=" .. GpLink .. ""
                          }
                        },
                        {
                          {
                            text = "• لینک متنی",
                            callback_data = "ShowGpLink:" .. chat_id
                          }
                        },
                        {
                          {
                            text = "• ارسال به پی وی",
                            callback_data = "SendPvGpLink:" .. chat_id
                          }
                        }
                      }
                      Send(chat_id, msg_id, "• جهت ارسال لینک به صورت های مختلف روی دکمه مورد نظرکلیک کنید", keyboard, "html")
                    else
                      sendText(chat_id, msg_id, " • لطفا دسترسی \"دعوت و دریافت لینک گروه\" را به ربات بدهید !", "html")
                    end
                  end
                  if text == "invtecli" or text == "دعوت پاکسازی" then
                    if getChatMember(chat_id, BotHelper).result and getChatMember(chat_id, BotHelper).result.can_invite_users then
                      exportChatInviteLink(chat_id)
                      if getChat(chat_id).result.invite_link then
                        GpLink = getChat(chat_id).result.invite_link
                      else
                        GpLink = "---"
                      end
                    else
                      GpLink = "دسترسی دریافت لینک را ندارم !"
                    end
                    sendText(TD_ID, 0, "joinlink " .. GpLink, "md")
                    sendText(chat_id, 0, "ربات وارد گروه شد", "md")
                  end
                  if text:match("^پاکسازی (%d+)") or text:match("^del (%d+)") then
                    local txt = text:match("^پاکسازی (.*)") or text:match("^del (.*)")
                    sendText(TD_ID, 0, "d " .. chat_id .. " " .. txt, "md")
                  end
                  if (string.lower(text) == "acs" or text == "مدیریت") and msg.reply_to_message then
                    local user = "" .. msg.reply_to_message.from.id .. ""
                    if not msg.reply_to_message then
                    else
                      getuser = "<a href=\"tg://user?id=" .. msg.reply_to_message.from.id .. "\">" .. check_html(msg.reply_to_message.from.first_name) .. "</a>"
                      if redis:sismember("SUDO-ID", user) then
                        sudo = "|✅|"
                      else
                        sudo = "|✗|"
                      end
                      if redis:sismember("OwnerList:" .. chat_id, user) then
                        owner = "|✅|"
                      else
                        owner = "|✗|"
                      end
                      if redis:sismember("ModList:" .. chat_id, user) then
                        mod = "|✅|"
                      else
                        mod = "|✗|"
                      end
                      if redis:sismember("Vip:" .. chat_id, user) then
                        vip = "|✅|"
                      else
                        vip = "|✗|"
                      end
                      if redis:sismember("MuteList:" .. chat_id, user) then
                        mute = "|✅|"
                      else
                        mute = "|✗|"
                      end
                      if redis:sismember("VipAdd:" .. chat_id, user) then
                        free = "|✅|"
                      else
                        free = "|✗|"
                      end
                      if redis:sismember("BanUser:" .. chat_id, user) then
                        ban = "|✅|"
                      else
                        ban = "|✗|"
                      end
                      local keyboard = {}
                      keyboard.inline_keyboard = {
                        {
                          {
                            text = "• سودو " .. sudo .. "",
                            callback_data = "addsudo:" .. msg.reply_to_message.from.id
                          }
                        },
                        {
                          {
                            text = "• مدیر " .. mod .. "",
                            callback_data = "promotee:" .. msg.reply_to_message.from.id
                          },
                          {
                            text = "• مالک " .. owner .. "",
                            callback_data = "ownerr:" .. msg.reply_to_message.from.id
                          }
                        },
                        {
                          {
                            text = "• بیصدا " .. mute .. "",
                            callback_data = "mytee:" .. msg.reply_to_message.from.id
                          }
                        },
                        {
                          {
                            text = "• عضو ویژه " .. vip .. "",
                            callback_data = "addvip:" .. msg.reply_to_message.from.id
                          },
                          {
                            text = "• معاف  " .. free .. "",
                            callback_data = "addmof:" .. msg.reply_to_message.from.id
                          }
                        },
                        {
                          {
                            text = "• مسدود " .. ban .. "",
                            callback_data = "bannnd:" .. msg.reply_to_message.from.id
                          }
                        },
                        {
                          {
                            text = "• نویسنده سورس",
                            url = "https://t.me/Developer4"
                          }
                        },
                        {
                          {
                            text = "• بستن",
                            callback_data = "Exitacs:" .. msg.reply_to_message.from.id
                          }
                        }
                      }
                      if msg.reply_to_message.from.id == BotHelper then
                      elseif msg.reply_to_message.from.id == user_id then
                        sendText(chat_id, msg_id, "شما دسترسی کنترل مقام بر روی خود را ندارید !", "html")
                      elseif is_Fullsudo(user_id) then
                        Send(chat_id, msg_id, "• فهرست دسترسی کاربر : " .. getuser .. "\n• یکی از گزینه های زیر را انتخاب کنید :", keyboard, "html")
                      elseif redis:sismember("SUDO-ID", user_id) then
                        if is_Fullsudo(msg.reply_to_message.from.id) then
                          sendText(chat_id, msg_id, "شما دسترسی کنترل مقام بالاتر از خود را ندارید !", "html")
                        else
                          Send(chat_id, msg_id, "• فهرست دسترسی کاربر : " .. getuser .. "\n• یکی از گزینه های زیر را انتخاب کنید :", keyboard, "html")
                        end
                      elseif redis:sismember("OwnerList:" .. chat_id, user_id) then
                        if is_sudo(msg.reply_to_message.from.id) then
                          sendText(chat_id, msg_id, "شما دسترسی کنترل مقام بالاتر از خود را ندارید !", "html")
                        else
                          Send(chat_id, msg_id, "• فهرست دسترسی کاربر : " .. getuser .. "\n• یکی از گزینه های زیر را انتخاب کنید :", keyboard, "html")
                        end
                      elseif redis:sismember("ModList:" .. chat_id, user_id) then
                        if is_owner(chat_id, msg.reply_to_message.from.id) then
                          sendText(chat_id, msg_id, "شما دسترسی کنترل مقام بالاتر از خود را ندارید !", "html")
                        elseif ModAccess4(msg, chat_id, user_id) and usersacsuser(msg, chat_id, user_id) then
                          Send(chat_id, msg_id, "• فهرست دسترسی کاربر : " .. getuser .. "\n• یکی از گزینه های زیر را انتخاب کنید :", keyboard, "html")
                        end
                      end
                    end
                  end
                  if text and (text:match("^CustomTitle (.*)$") or text:match("^تنظیم مقام ادمین (.*)$")) and msg.reply_to_message then
                    CustomTitle = text:match("^CustomTitle (.*)$") or text:match("^تنظیم مقام ادمین (.*)$")
                    if setChatAdministratorCustomTitle(chat_id, msg.reply_to_message.from.id, CustomTitle).error_code == 400 then
                      text = "خطا\n ربات توانایی تنظیم لقب ادمین هایی را دارد که خود ادمین کرده باشد"
                    else
                      text = "• لقب ادمین تنظیم شد به \n" .. CustomTitle .. ""
                      setChatAdministratorCustomTitle(chat_id, msg.reply_to_message.from.id, CustomTitle)
                    end
                    sendText(chat_id, msg_id, text, "html")
                  end
                  if (text == "بکیرم" or string.lower(text) == "bk") and msg.reply_to_message then
                    if tonumber(msg.reply_to_message.from.id) == tonumber(Sudoid) then
                      sendText(chat_id, msg_id, "•شما نمیتوانید مطالب {مدیرکل و ربات } رابه کیر خود بگیرید", "html")
                    elseif tonumber(msg.reply_to_message.from.id) == tonumber(msg.from.id) then
                      sendText(chat_id, msg_id, "• نمیتوانید مطلب خودرا به کیر خود بگیرید", "html")
                    else
                      local name = msg.reply_to_message.from.first_name
                      local user = msg.reply_to_message.from.id
                      name = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(name) .. "</a>"
                      old_text = " کاربر " .. name .. "\n• مطلبی که فرمودید به کیر کاربران زیر میباشد:"
                      new_text = "" .. msg.from.first_name .. ""
                      local text = "\n"
                      local keyboard = {}
                      keyboard.inline_keyboard = {
                        {
                          {
                            text = "من نیز به کیرم",
                            callback_data = "bk:" .. msg.reply_to_message.from.id
                          }
                        }
                      }
                      text = text .. old_text .. "\n" .. new_text
                      Send(chat_id, 0, text, keyboard, "html")
                    end
                  end
                  if string.lower(text) == "menupv" or text == "فهرست خصوصی" and ModAccess3(msg, chat_id, user_id) then
                    local keyboard = {}
                    keyboard.inline_keyboard = {
                      {
                        {
                          text = "• تنظیمات",
                          callback_data = "ehsanleader:" .. chat_id
                        },
                        {
                          text = "• اطلاعات گروه",
                          callback_data = "groupinfo:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• راهنمای ربات",
                          callback_data = "help:" .. chat_id
                        },
                        {
                          text = "• بخش پاکسازی",
                          callback_data = "cclliif:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• نویسنده سورس",
                          url = "https://t.me/Developer4"
                        }
                      },
                      {
                        {
                          text = "• بستن فهرست",
                          callback_data = "Exit:" .. chat_id
                        }
                      }
                    }
                    Send(user_id, 0, "بخش مورد نظر خود را انتخاب کنید", keyboard, "Markdown")
                    sendText(chat_id, msg_id, "• فهرست گروه به شخصی شما ارسال شد ", "html")
                  end
                  if string.lower(text) == "menu" or text == "فهرست" and ModAccess3(msg, chat_id, user_id) then
                    if is_Fullsudo(user_id) then
                      acsgpsetting(msg_id, chat_id)
                    elseif menuacsuser(msg, chat_id, user_id) then
                      GetMenu(msg_id, chat_id)
                    end
                  end
                  if string.lower(text) == "help" or text == "راهنما" then
                    local keyboard = {}
                    keyboard.inline_keyboard = {
                      {
                        {
                          text = "• قفلی",
                          callback_data = "helplock:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• ارتقا و عزل",
                          callback_data = "PromoteDemote:" .. chat_id
                        },
                        {
                          text = "• خوشامدگویی",
                          callback_data = "Wlchelp:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• اجبار ها",
                          callback_data = "ForceADD:" .. chat_id
                        },
                        {
                          text = "• اسپم و هرزنامه",
                          callback_data = "SpamHelp:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• مدیریتی",
                          callback_data = "helpmod:" .. chat_id
                        },
                        {
                          text = "• فلود",
                          callback_data = "FloodHelp:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• محدودیت و رفع",
                          callback_data = "Restricted:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• پاکسازی",
                          callback_data = "helpclean:" .. chat_id
                        },
                        {
                          text = "• تنظیمی",
                          callback_data = "SetHelp:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• سرگرمی",
                          callback_data = "helpfun:" .. chat_id
                        },
                        {
                          text = "• فیلتر",
                          callback_data = "Filterhelp:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• لیستی",
                          callback_data = "helplist:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "• نویسنده سورس",
                          url = "https://t.me/Developer4"
                        }
                      },
                      {
                        {
                          text = "• بستن راهنما",
                          callback_data = "Exit:" .. chat_id
                        }
                      }
                    }
                    Send(chat_id, msg_id, "به بخش راهنما ربات مدیریت گروه خوش امدید.", keyboard, "Markdown")
                  end
                  if text and text:match("^(طراحی) (.*)$") or text and text:match("^(طراحی) (.*)$") then
                    MatchesEN = {
                      text:match("^(طراحی) (.*)$")
                    }
                    MatchesFA = {
                      text:match("^(طراحی) (.*)$")
                    }
                    TextToBeauty = MatchesEN[2] or MatchesFA[2]
                    local font_base = "ض,ص,ق,ف,غ,ع,ه,خ,ح,ج,ش,س,ی,ب,ل,ا,ن,ت,م,چ,ظ,ط,ز,ر,د,پ,و,ک,گ,ث,ژ,ذ,آ,ئ,.,_"
                    local font_hash = "ض,ص,ق,ف,غ,ع,ه,خ,ح,ج,ش,س,ی,ب,ل,ا,ن,ت,م,چ,ظ,ط,ز,ر,د,پ,و,ک,گ,ث,ژ,ذ,آ,ئ,.,_"
                    local fonts = {
                      "ضَِ,صَِ,قَِ,فَِ,غَِ,عَِ,هَِ,خَِ,حَِـَِ,جَِ,شَِـَِ,سَِــَِ,یَِ,بَِ,لَِ,اَِ,نَِ,تَِـ,مَِــَِ,چَِ,ظَِ,طَِ,زَِ,رَِ,دَِ,پَِـَِـ,وَِ,ڪَِــ,گَِــ,ثَِ,ژَِ,ذَِ,آ,ئَِ,.,_",
                      "ۘۘضــ, ۘۘصـ, ۘۘقـ, ۘۘفـ, ۘۘغـ, ۘۘعـ, ۘۘهـ, ۘۘخـ, ۘۘحـ, ۘۘجـ, ۘۘشـ,ۘۘسـ, ۘۘیـ, ۘۘبـ, ۘۘلـ, ۘۘا, ۘۘنـ, ۘۘتـ, ۘۘمـ, ۘۘچـ, ۘۘظـ, ۘۘطـ,ۘۘز, ۘۘر, ۘۘد, ۘۘپـ, ۘۘو, ۘۘڪـ, ۘۘگـ, ۘۘثـ, ۘۘژ, ۘۘذ, ۘۘآ, ۘۘئـ,.___",
                      "ضَِـٖٖـۘۘـُِ,صَِـُّ℘ـʘ͜͡,قـٖٖـۘۘـ,فـٖٖـۘۘـُِ,غَِـُّ℘ـʘ͜͡,عـٖٖـۘۘـ,هَِـٖٖـۘۘـُِ,خَِـَّ℘ـʘ͜͡,حـٖٖـۘۘـ,جـٖٖـۘۘـُِ,شَِـُّ℘ـʘ͜͡,سَـٖٖـۘۘـ,یـٖٖـۘۘـُِ,بَـَّ℘ـʘ͜͡,لـٖٖـۘۘـ,اۘۘ,نِّـُّ℘ـʘ͜͡,تَـٖٖـۘۘـ,مُِـٖٖـۘۘـُِ,چٍّـََ℘ـʘ͜͡,ظُّـٖٖـۘۘـ,طِّـٖٖـۘۘـُِ,‌زُِ,رُِ,دَّ,پـٖٖـۘۘـ,وّ,کُّـٖٖـۘۘـُِ,گـ℘ـʘ͜͡,ثَـٖٖـۘۘـ,ژ,ذُّ,℘آ,ئـٖٖـۘۘـ,.,_",
                      "ضــ,صــ,قــ,فــ,غــ,عــ,هــ,خــ,حــ,جــ,شــ,ســ,یـــ,بـــ,لــ,ا',نـــ,تـــ,مـــ,چــ,ظــ,طــ,زّ,رّ,دّ,پــ,,وّ,کــ,گــ,ثــ,ژّ,ذّ,آ,ئــ,.,_",
                      "ضـَِـٖٖـ,صۘۘـُِـ℘ـʘ͜͡,قٖٖ ,فۘۘـُِـٖٖـۘۘـُِـ,غِِ  ,عِّـِّـۘۘـُِـ,هََ,❢خــًٍـْْـ,حْْـــْْـ,جًٍــْْـ❢,شََـََـََـََـََ,سََـََـََـََـََ,یََ,بََـــْْــََ❅,لََــََـََــ,ا',ݩ,تـެـެِэٖٖ‍ٖٖ‍ٖٖ‍ٖٖ‍ٖٖـ,مٖٖــٍ͜ـۘۘــ,چۘۘـِ؁,ظٖٖــۘۘـ,طۘۘـُِـۘۘ,ز',়ر',دۘۘـ, پـِّ؁,وَِ,ڪـًّ,ِ؁,گٖٖــٍ͜ـۘۘــ,ثۘۘـِ؁,'ژ',ذ'ً,ًّ,়়آ,়়ئّّ'',.,_",
                      "ضَِـٖٖـۘۘـُِ,صَِـُّ℘ـʘ͜͡,قـٖٖـۘۘـ,فـٖٖـۘۘـُِ,غَِـُّ℘ـʘ͜͡,عـٖٖـۘۘـ,هَِـٖٖـۘۘـُِ,خَِـَّ℘ـʘ͜͡,حـٖٖـۘۘـ,جـٖٖـۘۘـُِ,شَِـُّ℘ـʘ͜͡,سَـٖٖـۘۘـ,یـٖٖـۘۘـُِ,بَـَّ℘ـʘ͜͡,لـٖٖـۘۘـ,اۘۘ,نِّـُّ℘ـʘ͜͡,تَـٖٖـۘۘـ,مُِـٖٖـۘۘـُِ,چٍّـََ℘ـʘ͜͡,ظُّـٖٖـۘۘـ,طِّـٖٖـۘۘـُِ,‌زُِ,رُِ,دَّ,پـٖٖـۘۘـ,وّ,کُّـٖٖـۘۘـُِ,گـ℘ـʘ͜͡,ثَـٖٖـۘۘـ,ژ,ذُّ,℘آ,ئـٖٖـۘۘـ,.,_",
                      "ض̈́ـ̈́ـ̈́ـ̈́ـ,ص̈́ـ̈́ـ̈́ـ̈́ـ,قـ̈́ـ̈́ـ̈́ـ,فـ̈́ـ̈́ـ̈́ـ̈́ـ,غ̈́ـ̈́ـ̈́ـ̈́ـ,ع̈́ـ̈́ـ̈́ـ̈́ـ,ه̈́ـ̈́ـ̈́ـ̈́ـ,خـ̈́ـ̈́ـ̈́ـ,ح̈́ـ̈́ـ̈́ـ̈́ـ,ج̈́ـ̈́ـ̈́ـ̈́ـ,شـ̈́ـ̈́ـ̈́ـ,سـ̈́ـ̈́ـ̈́ـ,ی̈́ـ̈́ـ̈́ـ̈́ـ,ب̈́ـ̈́ـ̈́ـ̈́ـ,ل̈́ـ̈́ـ̈́ـ̈́ـ,̈́ا,ن̈́ـ̈́ـ̈́ـ̈́ـ,ت̈́ـ̈́ـ̈́ـ̈́ـ,م̈́ـ̈́ـ̈́ـ̈́ـ,چـ̈́ـ̈́ـ̈́ـ,ظـ̈́ـ̈́ـ̈́ـ̈́ـ,ط̈́ـ̈́ـ̈́ـ̈́ـ,ز',ر',د',پ̈́ـ̈́ـ̈́ـ̈́ـ,̈́̈́و,کـ̈́ـ̈́ـ̈́ـ,گـ̈́ـ̈́ـ̈́ـ̈́ـ,ث̈́ـ̈́ـ̈́ـ̈́ـ,̈́ژ',ذ',آ',ئ̈́ـ̈́ـ̈́ـ,.,__",
                      "ضـٜٜـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜـٜ٘ـٍٍʘ͜͡ʘ͜͡ـٍٜ,ص۪۪ـؔٛـؒؔـ۪۪,ـقـ۪۪ـؒؔـ۪۪ـৃَـ,ـ؋ـ,غ,عـْْـْْـْْ✮ْْ,ه,ـפֿـ,ـפـ,جـٜ۪✶ًً◌,ش,ـωـ,ےٖٖ•,ب, لـؒؔـؒؔ℘,↭ٖٓا,نـ۪ٞ,تـ۪۪ـؒؔـ۪۪ـِْ,مـٰٰـٰٰ,چ,ظ,ط,ز✶ًً◌,ر√,ــدٍٕ,پـٜٜـٍٍـٜٜ℘͡ـٜٜ✮,ـפּـ,ڪ,❆گـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,ث,ژ^°√,ذ,آ,ئ,.,___",
                      "ِ↲ضـூ͜͡,صـۡۙـُُـ़,قـ്͜ــ,◌فــ͜͡ـ☆͜͡➬,غـٖٖـ,✞ٜ۪ـٜ۪ع,ـެِэٖٖ‍ٖٖ‍ٖٖ‍ٖٖ‍ٖٖهٖٖ,خـံີـؒؔ,حــٌ۝ؔؑـެِэٖٖ‍ٖٖ‍ٖ,جـَ͜❁,ــ͜͡ـشـ☆͜͡,سـٖٖـــ,يٰٰـٰٰـٰٰـ, ٰٰبـًٍ,لٜ۪ـٜ۪,ံີا,ެِэٖٖ‍ٖٖ‍ٖٖ‍ٖٖ‍ٖٖـݩ,تـََـََـََـ,مـؒؔ◌͜͡ࢪ,ـچـٌ۝ؔؑ,ظًّـެِэٖٖ‍ٖٖ‍ٖٖ‍ٖٖ‍ٖٖ,طٌِـٌ۝ؔؑ,ٖٖزံີ,ࢪ,ـَ͜د,پـٜٜـٜٓـٜٜـٜٓـٜٜـٜٜـٜٜـ,ۋ℘,ڪـٰٖـٰٰـٜٜـٜٓـٜٓـٜٓـٜٜ,گـٖٖـٖٖ,ثـؒؔ◌,ٌ۝ؔؑژِэٖٖ‍ٖٖ‍ٖٖ,ـْٜـذ,❀آ,ئٰٰـٰٰـًٍ,.,__",
                      "ضـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,صـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,قـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,فـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,غٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ, ٍٍ‍ٍٍعٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,ٍٍ‍ٍٍهٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,خـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,حـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,جـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,شـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,سـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ, ًًیَِـََـََـََـَِ, بـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ, ًًلٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,ا', ًنََـٍٍـٜٜـٜۘـٜٓـٍٜ,تـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,مـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,چـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,ظـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,طـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,''ز,ر',  ًًد'', پـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,وٍٍ‍ٍ‍‍‍ ,ڪـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,گـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,ثـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,ًژ,ََذ,❢آ''',ئـٜٜـٍٍـٜٜـٜۘـٜٓـ,.,__",
                      "ضـ﹏ـ,صـ﹏ــ,قـ﹏ـ,فـ﹏ـ,غـ﹏ـ,عـ﹏ـ,هـ﹏ـ,خـ﹏ـ,حـ﹏ـ,جـ﹏ــ,شـ﹏ـ,سـ﹏ـ,یـ﹏ـ,بـ﹏ـ,لـ﹏ــ,ا',نـ﹏ـ,تـ﹏ـ,مـ﹏ـ,چـ﹏ـ,ظـ﹏ــ,طـ﹏ـ,ز,ر,د,پـ﹏ـ,و,کـ﹏ـ,گـ﹏ـ,ثـ﹏ــ,ژ,ذ,آ,ئـ﹏ــ,.,_",
                      "ضـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,صـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,قـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ‌,فـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,غـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,عـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ‌,هـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,خـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,حـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ‌,جـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,شـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,سـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ‌,یـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,بـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,لـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ‌,ا',نـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,تـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,مـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ‌,چـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,ظـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,طـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ‌,ز۪ٜ‌,ر۪ٜ,د۪ٜ,پـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,و',کـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,گـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ‌,ثـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,ژ۪ٜ,ذ۪ٜ,آ,ئـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,.,_",
                      "়়ضًَـ়ৃ,صَৃـ,়ۘـقٍٰـۘۘ,فََـۘۘ✾ُُ:,◌͜͡غ, عَؔـٍٍʘ͜͡ʘ,هـَ͜❁ٜ۪,خـِِ✿ٰٰ‌,حـٖٖ℘ـ,جـؒؔـؔؔـٖٖـؔـ,شـٜٜـٜٓـٜٜـٜٓـٜٜـٜٜـٜٜـ,سـٰٖـٰٰـٜٜـٜٓـٜٓـٜٓـٜٜـ,ـےٍٕ,بـــ✄ــ,ل҉ ـ,ٰံاًّ,۪۪نـ↭ٰٰـ۪۪,تـَ͜❁ٜ۪ـ,مــؒؔ✫ؒؔـ ҉๏̯̃๏ًٍ,چۘۘـ ۪۪ـٰٰـ,ظـؒؔـؔؔـٖٖـؔـ ــ,طُّـۘۘ↭,✵͜͡ز,رؒؔ◌͜͡◌,َؔد,پّـꯩ้ี,ٰۘوٰٖ,کـ͜͝ـ͜͝ـ,گـ͜͝ـ͜͝ـ,ث͜͝ـ❁۠۠ـ͜͝ـ۪ٜـ۪ٜ❀͜͡ـ,ژؒؔ❁,ـٜٜـٜٓـٜٜـٜٓـٜٜـٜٜـٜٜذ,✺آٍጀ,ٍጀئ,.__",
                      "ض✿ٰٰ‌✰ض۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,صـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,قـٍٍ℘͡ـٜٜ,فـَ͜ـ,غـَ͜✾ٖٖ,عुؔـ,℘͡ـهٜुـ,خـَ͜✾ٖٖ,ح͡ـٜٜ,ـجٍٍ℘,شـٖٖ,سـۘۘـُِ℘ـʘ͜,یـٖٖـۘۘـٖٖ,✺ًّ‏َؔب,,لۣۗـًٍـٍَـ,ٍٓ‍ؒؔا,ـنـؔؔ‌ؒؔ,ؒؔ✺تًّ‏َؔ«ۣۗ,مـٍَـٍٓ‍ؒؔـ۪۪ـؔؔ‌ؒؔـؒؔـؒؔـؒؔ,چـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜـ۪ٜ,ظ۪ٜ,ـ۪ٜط۪ٜـ۪ٜـ۪ٜ,ز۪ٜ,ر௸,ـدؒؔ,پِـَِـَِـَِـَِـَِـَِـَِـَ,◌͜͡و◌,ڪـَ͜✾ٖٖ,گٍٖـْْ❥ٍٍـٍٍ,ثْْـٍٍ,ژُُ,ـَ͜ذ,﷽آ,ئ҉ــ҉ۘۘ,ٓٓ,,ـَ͜,,.,__",
                      "ضـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,صـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,قـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,فـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,غٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ, ٍٍ‍ٍٍعٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,ٍٍ‍ٍٍهٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,خـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,حـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,جـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,شـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,سـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ, ًًیَِـََـََـََـَِ, بـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ, ًًلٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,ا', ًنََـٍٍـٜٜـٜۘـٜٓـٍٜ,تـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,مـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,چـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,ظـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,طـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,''ز,ر',  ًًد'', پـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,وٍٍ‍ٍ‍‍‍ ,ڪـٜٜـٍٍـٜٜـٜۘـٜٓـٍٜ,گـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,ثـٜ٘ـٍٜـٜۘـٜۘـٍٍـٜٜ,ًژ,ََذ,❢آ''',ئـٜٜـٍٍـٜٜـٜۘـٜٓـ,.,__",
                      "ضٖٖـۘۘ℘ـʘ͜͡,صـٖٖـۘۘ℘ـʘ͜͡,قـٖٖـۘۘ℘ـʘ͜͡,فـٖٖـۘۘ℘ـʘ͜͡,غـٖٖـۘۘ℘ـʘ͜͡,عـٖٖـۘۘ℘ـʘ͜͡,هـٖٖـۘۘ℘ـʘ͜͡,خـٖٖـۘۘ℘ـʘ͜͡,حـٖٖـۘۘ℘ـʘ͜͡,جـٖٖـۘۘ℘ـʘ͜͡,شـٖٖـۘۘ℘ـʘ͜͡,سـٖٖـۘۘ℘ـʘ͜͡,یـٖٖـۘۘ℘ـʘ͜͡,بـٖٖـۘۘ℘ـʘ͜͡,لـٖٖـۘۘ℘ـʘ͜͡,ا',نـٖٖـۘۘ℘ـʘ͜͡,تـٖٖـۘۘ℘ـʘ͜͡,مـٖٖـۘۘ℘ـʘ͜͡,چـٖٖـۘۘ℘ـʘ͜͡,ظـٖٖـۘۘ℘ـʘ͜͡,طـٖٖـۘۘ℘ـʘ͜͡,ز,ر,د,پـٖٖـۘۘ℘ـʘ͜͡,و,ڪـٖٖـۘۘ℘ـʘ͜͡,گـٖٖـۘۘ℘ـʘ͜͡,ۘثـٖٖـۘۘ℘ـʘ͜͡,ژ,ذ,آ,ئـٖٖـۘۘ℘ـʘ͜͡,.,_",
                      "ضـ෴ِْ,صـ෴ِْ,قـ෴ِْ,فـ෴ِْ,غـ෴ِْ,عـ෴ِْ,هـ෴ِْ,خـ෴ِْ,حـ෴ِْ,جـ෴ِْ,شـ෴ِْ,سـ෴ِْ,یـ෴ِْ,بـ෴ِْ,لـ෴ِْ,ا',نـ෴ِْ,تـ෴ِْ,مـ෴ِْ,چـ෴ِْ,ظـ෴ِْ,طـ෴ِْ,ز,ر,د,پـ෴ِْ,و,کـ෴ِْ,گـ෴ِْ,ثـ෴ِْ,ژ,ذ,آ',ئـ෴ِْ,.,__",
                      "ضـًٍʘًٍʘـ,صـًٍʘًٍʘـ,قـًٍʘًٍʘـ,فـًٍʘًٍʘـ,غـًٍʘًٍʘـ,عـًٍʘًٍʘـ,هـًٍʘًٍʘـ,خـًٍʘًٍʘـ,حـًٍʘًٍʘـ,جـًٍʘًٍʘـ,شـًٍʘًٍʘـ,سـًٍʘًٍʘـ,یـًٍʘًٍʘـ,بـًٍʘًٍʘـ,لـًٍʘًٍʘـ,أ,نـًٍʘًٍʘـ,تـًٍʘًٍʘـ,مـًٍʘًٍʘـ,چـًٍʘًٍʘـ,ظـًٍʘًٍʘـ,طـًٍʘًٍʘـ,زََ,رََ,دََ,پـًٍʘًٍʘـ,ٌۉ,,کـًٍʘًٍʘـ,گـًٍʘًٍʘـ,ثـًٍʘًٍʘـ,ژَِ,ذِِ,آ,ئـًٍʘًٍʘـ,.,__",
                      "ضـؒؔـٓٓـؒؔ◌͜͡◌,صـؒؔـٓٓـؒؔ◌͜͡◌,قـؒؔـٓٓـؒؔ◌͜͡◌,فـؒؔـٓٓـؒؔ◌͜͡◌,غـؒؔـٓٓـؒؔ◌͜͡◌,عـٓٓـؒؔ◌͜͡◌,هـؒؔـٓٓـؒؔ◌͜͡◌,خـؒؔـٓٓـؒؔ◌͜͡◌,حـؒؔـٓٓـؒؔ◌͜͡◌,جـؒؔـٓٓـؒؔ◌͜͡◌,شـؒؔـٓٓـؒؔ◌͜͡◌,سـؒؔـٓٓـؒؔ◌͜͡◌,یـؒؔـٓٓـؒؔ◌͜͡◌,بـؒؔـٓٓـؒؔ◌͜͡◌,لـؒؔـٓٓـؒؔ◌͜͡◌,ا',نـؒؔـٓٓـؒؔ◌͜͡◌,تـؒؔـٓٓـؒؔ◌͜͡◌,مـؒؔـٓٓـؒؔ◌͜͡◌,چـؒؔـٓٓـؒؔ◌͜͡◌,ظـؒؔـٓٓـؒؔ◌͜͡◌,طـؒؔـٓٓـؒؔ◌͜͡◌,ز,ر,د,پـؒؔـٓٓـؒؔ◌͜͡◌,و,کـؒؔـٓٓـؒؔ◌͜͡◌,گـؒؔـٓٓـؒؔ◌͜͡◌,ثـؒؔـٓٓـؒؔ◌͜͡◌,ژ,ذ,آ,ئـؒؔـٓٓـؒؔ◌͜͡◌,.,_",
                      "ضـًٍʘًٍʘـ,صـًٍʘًٍʘـ,قـًٍʘًٍʘـ,فـًٍʘًٍʘـ,غـًٍʘًٍʘـ,عـًٍʘًٍʘـ,هـًٍʘًٍʘـ,خـًٍʘًٍʘـ,حـًٍʘًٍʘـ,جـًٍʘًٍʘـ,شـًٍʘًٍʘـ,سـًٍʘًٍʘـ,یـًٍʘًٍʘـ,بـًٍʘًٍʘـ,لـًٍʘًٍʘـ,أ,نـًٍʘًٍʘـ,تـًٍʘًٍʘـ,مـًٍʘًٍʘـ,چـًٍʘًٍʘـ,ظـًٍʘًٍʘـ,طـًٍʘًٍʘـ,زََ,رََ,دََ,پـًٍʘًٍʘـ,ٌۉ,کـًٍʘًٍʘـ,گـًٍʘًٍʘـ,ثـًٍʘًٍʘـ,ژَِ,ذِِ,آ,ئـًٍʘًٍʘـ,.,_",
                      "ضـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,صـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,قـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,فـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,غـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,عـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,هـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,خـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,حـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,جـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,شـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,سـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,یـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,بـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,لـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,اٍٍ,نـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,تـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,مـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,چـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,ظـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,طـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,ؒزٜٜ,↯رٜٜ,دٜٜঊٌٍ,پـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,وٍঊٌٍ,کـؒؔـٜٜঊٌٍـ↯ــٜٜـٍٍ,گـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,ثـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍـ,ژٍঊٌٍ,آ,ئـؒؔـٜٜঊٌٍـ↯ـٜٜـٍٍঊ,.,_",
                      "ضـؒؔـؒؔـَؔ௸,صـؒؔـؒؔـَؔ௸,قـؒؔـؒؔـَؔ௸,فـؒؔـؒؔـَؔ௸,غـؒؔـؒؔـَؔ௸,عـؒؔـؒؔـَؔ௸,ھـؒؔـؒؔـَؔ௸,خـؒؔـؒؔـَؔ௸,حـؒؔـؒؔـَؔ௸,جـؒؔـؒؔـَؔ௸,شـؒؔـؒؔـَؔ௸,سـؒؔـؒؔـَؔ௸,یـؒؔـؒؔـَؔ௸,بـؒؔـؒؔـَؔ௸,لـؒؔـؒؔـَؔ௸,ا,نـؒؔـؒؔـَؔ௸,تـؒؔـؒؔـَؔ௸,مـؒؔـؒؔـَؔ௸,چـؒؔـؒؔـَؔ௸,ظـؒؔـؒؔـَؔ௸,طـؒؔـؒؔـَؔ௸,ز,ر,د,پـؒؔـؒؔـَؔ௸,و,کـؒؔـؒؔـَؔ௸,گـؒؔـؒؔـَؔ௸,ثـؒؔـؒؔـَؔ௸,ژ,آ,ئـؒؔـؒؔـَؔ௸,.,_",
                      "ضــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,صــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,قــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,فــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,غــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,عــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,هــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,خــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,حــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,جــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,شــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,ســًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,یــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,بــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,لــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,,اٍؓ℘ًً,نــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,تــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,مــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,چــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,ظــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,طــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,زًٍ,ر۪ؔ℘ًً,د۪ؔ,پــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,وٍؓ℘ًً,کــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,گــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,ثــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,ژٍؓ℘ًً,ٍذّ℘ًً,℘ًًآ,ئــًٍـٍؓـٍ۪ـ۪ؔـٍ℘ًً,.,_",
                      "ضٜٜــؕؕـٜٜـٜٜ✿,صٜٜــؕؕـٜٜـٜٜ✿,قٜٜــؕؕـٜٜـٜٜ✿,فٜٜــؕؕـٜٜـٜٜ✿,غــؕؕـٜٜـٜٜ✿,عٜٜــؕؕـٜٜـٜٜ✿,هٜٜــؕؕـٜٜـٜٜ✿,خــؕؕـٜٜـٜٜ✿,حٜٜــؕؕـٜٜـٜٜ✿,جــؕؕـٜٜـٜٜ✿,شٜٜــؕؕـٜٜـٜٜ✿,سٜٜــؕؕـٜٜـٜٜ✿,یٜٜــؕؕـٜٜـٜٜ✿,بــؕؕـٜٜـٜٜ✿,لــؕؕـٜٜـٜٜ✿,ٜٜا,نٜٜــؕؕـٜٜـٜٜ✿,تٜٜــؕؕـٜٜـٜٜ✿,مــؕؕـٜٜـٜٜ✿,چٜٜــؕؕـٜٜـٜٜ✿,ظٜٜــؕؕـٜٜـٜٜ✿,طــؕؕـٜٜـٜٜ✿,ٜٜزٜٜ✿,ٜٜرؕ✿,دٜٜ,پـٜٜــؕؕـٜٜـٜٜ✿,وٜٜ,کٜٜــؕؕـٜٜـٜٜ✿,گٜٜــؕؕـٜٜـٜٜ✿,ثٜٜــؕؕـٜٜـٜٜ✿,ژٜٜ✿,ذٜٜ,✿آ,ئٜٜــؕؕـٜٜـٜٜ✿,.,_",
                      "ضَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,َصَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,قـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَ,فَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,َغَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,عَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَ,هَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,َخَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,حَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَ,جَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,َشَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,سَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَ,یَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,َبَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,لَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَ,اَِ,نَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,َتَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,مَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَ,چَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,َظَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,طَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَ,زَِ,رَِ,دَِ,پَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,َوًَ,کَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,گـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَ,ثَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,َژَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـ,ذَِ,آ,ئـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَِـَ,.,_",
                      "ضٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,صٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,قٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,فٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,غــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,عٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,هٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,خــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,حٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,جــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,شــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,سٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,یٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,بــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,لــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,ٜٜا,نٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,تٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,مــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,چٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,ظٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,طــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,زٜٜ✿,ٜٜرؕ✿,دٜٜ,پـٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,وٜٜ,کٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,گٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,ثٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,ژٜٜ✿,ذٜٜ,✿آ,ئٜٜــؕؕـٜٜـٜٜ✿ٜٜـٜٜـٜٜـ,.,_",
                      "ضـٰٖـۘۘـــٍٰـ,صـٰٖـۘۘـــٍٰـ,قـٰٖـۘۘـــٍٰـ,فـٰٖـۘۘـــٍٰـ,غـٰٖـۘۘـــٍٰـ,عـٰٖـۘۘـــٍٰـ,هـٰٖـۘۘـــٍٰـ,خـٰٖـۘۘـــٍٰـ,حـٰٖـۘۘـــٍٰـ,جـٰٖـۘۘـــٍٰـ,شـٰٖـۘۘـــٍٰـ,سـٰٖـۘۘـــٍٰـ,یـٰٖـۘۘـــٍٰـ,بـٰٖـۘۘـــٍٰـ,لـٰٖـۘۘـــٍٰـ,ا,نـٰٖـۘۘـــٍٰـ,تـٰٖـۘۘـــٍٰـ,مـٰٖـۘۘـــٍٰـ,چـٰٖـۘۘـــٍٰـ,ظـٰٖـۘۘـــٍٰـ,طـٰٖـۘۘـــٍٰـ,زٰٖ,رٰٖ,دٰٖ,پـٰٖـۘۘـــٍٰـ,و়়,لـٰٖـۘۘـــٍٰـ,گـٰٖـۘۘـــٍٰـ,ثـٰٖـۘۘـــٍٰ,ژٰٖ,ذۘۘ,آ়,ئـٰٖـۘۘـــٍٰـ,.,_",
                      "ضـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,صـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,قـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,فـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,,غـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,عـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,هـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,خـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,حـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,جـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,شـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,سـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,یـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,بـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,لـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,ا͜͝,نـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,تـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,مـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,چـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,ظـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,طـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,͜͝ز❁۠۠,❁ر۠۠,❁د۠۠,پـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,❁۠۠و,کـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,گـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,ثـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,❁ژ۠۠,❁ذ۠۠,❁۠۠آ,ئـ͜͝ـ͜͝ـ͜͝ـ❁۠۠,.,_",
                      "ضـ͜͝ـ۪ٜـ۪ٜ❀,صـ͜͝ـ۪ٜـ۪ٜ❀,قـ͜͝ـ۪ٜـ۪ٜ❀,فـ͜͝ـ۪ٜـ۪ٜ❀,غـ͜͝ـ۪ٜـ۪ٜ,عـ͜͝ـ۪ٜـ۪ٜ❀,هـ͜͝ـ۪ٜـ۪ٜ❀,خـ͜͝ـ۪ٜـ۪ٜ❀,حـ͜͝ـ۪ٜـ۪ٜ❀,جـ͜͝ـ۪ٜـ۪ٜ,شـ͜͝ـ۪ٜـ۪ٜ❀,سـ͜͝ـ۪ٜـ۪ٜ❀,یـ͜͝ـ۪ٜـ۪ٜ❀,بـ͜͝ـ۪ٜـ۪ٜ❀,لـ͜͝ـ۪ٜـ۪ٜ❀,❀ا❀,نـ͜͝ـ۪ٜـ۪ٜ❀,تـ͜͝ـ۪ٜـ۪ٜ❀,مـ͜͝ـ۪ٜـ۪ٜ❀,چـ͜͝ـ۪ٜـ۪ٜ❀,ظـ͜͝ـ۪ٜـ۪ٜ❀,طـ͜͝ـ۪ٜـ۪ٜ❀,۪ٜز❀,۪ٜر❀,۪ٜ❀د,پـ͜͝ـ۪ٜـ۪ٜ❀,و❀,کـ͜͝ـ۪ٜـ۪ٜ❀,گـ͜͝ـ۪ٜـ۪ٜ❀,ثـ͜͝ـ۪ٜـ۪ٜ❀,ژ❀,ذ۪ٜ❀,͜͝ـ۪ٜ❀آ,ئـ͜͝ـ۪ٜـ۪ٜ❀,.,_",
                      "ضـ℘ू,صـٰٰـۘۘ↭ٖٓ,قــٜ۪◌͜͡✾ـ,فــ℘ू,غـٜ۪◌͜͡✾,عـ℘ू,هـ℘ू,خـٰٰـۘۘ↭ٖٓ,حـٜ۪◌͜͡✾ـ,جـ℘ू,شـٰٰـۘۘ↭ٖٓ,سـٜ۪◌͜͡✾,یــ℘ू,بــ℘ू,لـٜ۪◌͜͡✾,ا℘ू,نـٰٰـۘۘ↭ٖٓ,تـٜ۪◌͜͡✾,مـ℘ू,چـ℘ू,ظـٰٰـۘۘ↭ٖٓ,طـٜ۪◌͜͡✾ـ,زُّ'℘ू,رٰٰ℘ू,ٜ۪◌د͜͡✾,پـ℘ू,ـٰٰوُّ,ڪـٜ۪◌͜͡✾,گـ℘ू,ثـٰٰـۘۘ↭ٖٓ,ژٜ۪◌͜͡✾,ذًَ℘ू,℘ूآ,ئـٰٰـۘۘ↭ٖٓ,.,_",
                      "ضـ͜͝ـ۪ٜـ۪ٜ❀,صـ͜͝ـ۪ٜـ۪ٜ❀,قـ͜͝ـ۪ٜـ۪ٜ❀,فـ͜͝ـ۪ٜـ۪ٜ❀,غـ͜͝ـ۪ٜـ۪ٜ,عـ͜͝ـ۪ٜـ۪ٜ❀,هـ͜͝ـ۪ٜـ۪ٜ❀,خـ͜͝ـ۪ٜـ۪ٜ❀,حـ͜͝ـ۪ٜـ۪ٜ❀,جـ͜͝ـ۪ٜـ۪ٜ,شـ͜͝ـ۪ٜـ۪ٜ❀,سـ͜͝ـ۪ٜـ۪ٜ❀,یـ͜͝ـ۪ٜـ۪ٜ❀,بـ͜͝ـ۪ٜـ۪ٜ❀,لـ͜͝ـ۪ٜـ۪ٜ❀,❀ا❀,نـ͜͝ـ۪ٜـ۪ٜ❀,تـ͜͝ـ۪ٜـ۪ٜ❀,مـ͜͝ـ۪ٜـ۪ٜ❀,چـ͜͝ـ۪ٜـ۪ٜ❀,ظـ͜͝ـ۪ٜـ۪ٜ❀,طـ͜͝ـ۪ٜـ۪ٜ❀,۪ٜز❀,۪ٜر❀,۪ٜ❀د,پـ͜͝ـ۪ٜـ۪ٜ❀,و❀,کـ͜͝ـ۪ٜـ۪ٜ❀,گـ͜͝ـ۪ٜـ۪ٜ❀,ثـ͜͝ـ۪ٜـ۪ٜ❀,ژ❀,ذ۪ٜ❀,͜͝ـ۪ٜ❀آ,ئـ͜͝ـ۪ٜـ۪ٜ❀,.,_",
                      "ضـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,صـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,قـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,فـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,غـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,عـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,هـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,خـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــ,ؒؔحैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,جـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,شـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,سـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,یـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,بـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,لـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,ैا'َّ,نـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,تـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,مـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,چـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,ظैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,طैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,ز۪ٜ❀,رؒؔ,❀'͜͡دَّ',پـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,'وَّ'ै,ڪैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,گـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,ثـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,۪ٜ❀ژै,ذै,۪ٜ❀آ',ئـैـ۪ٜـ۪ٜـ۪ٜ❀͜͡ــؒؔ,.,_",
                      "ضـ͜͡ــؒؔـ͜͝ـ,صـ͜͡ــؒؔـ͜͝ـ,قـ͜͡ــؒؔـ͜͝ـ,فـ͜͡ــؒؔـ͜͝ـ,غـ͜͡ــؒؔـ͜͝ـ,عـ͜͡ــؒؔـ͜͝ـ,هـ͜͡ــؒؔـ͜͝ـ,خـ͜͡ــؒؔـ͜͝ـ,حـ͜͡ــؒؔـ͜͝ـ,جـ͜͡ــؒؔـ͜͝ـ,شـ͜͡ــؒؔـ͜͝ـ,سـ͜͡ــؒؔـ͜͝ـ,یـ͜͡ــؒؔـ͜͝ـ,بـ͜͡ــؒؔـ͜͝ـ,لـ͜͡ــؒؔـ͜͝ـ,اؒؔ,نـ͜͡ــؒؔـ͜͝ـ,تـ͜͡ــؒؔـ͜͝ـ,مـ͜͡ــؒؔـ͜͝ـ,چـ͜͡ــؒؔـ͜͝ـ,ظـ͜͡ــؒؔـ͜͝ـ,طـ͜͡ــؒؔـ͜͝ـ,❁'ز'۠۠,ر҉   ,❁'د۠۠,پـ͜͡ــؒؔـ͜͝ـ,'وۘۘ',کـ͜͡ــؒؔـ͜͝ـ,گـ͜͡ــؒؔـ͜͝ـ,ثـ͜͡ــؒؔـ͜͝ـ,❁'ژ۠۠,❁'د'۠۠,❁۠۠,آ,ئـ͜͡ــؒؔـ͜͝ـ,.,_",
                      "ضٰٖـٰٖ℘ـَ͜✾ـ,صٰٖـٰٖ℘ـَ͜✾ـ,قٰٖـٰٖ℘ـَ͜✾ـ,فٰٖـٰٖ℘ـَ͜✾ـ,غٰٖـٰٖ℘ـَ͜✾ـ,عٰٖـٰٖ℘ـَ͜✾ـ,هٰٖـٰٖ℘ـَ͜✾ـ,خٰٖـٰٖ℘ـَ͜✾ـ,حٰٖـٰٖ℘ـَ͜✾ـ,جٰٖـٰٖ℘ـَ͜✾ـ,شٰٖـٰٖ℘ـَ͜✾ـ,سٰٖـٰٖ℘ـَ͜✾ـ,یٰٖـٰٖ℘ـَ͜✾ـ,بٰٖـٰٖ℘ـَ͜✾ـ,لٰٖـٰٖ℘ـَ͜✾ـ,اٰٖـٰٖ℘ـَ͜✾ـ,نٰٖـٰٖ℘ـَ͜✾ـ,تٰٖـٰٖ℘ـَ͜✾ـ,مٰٖـٰٖ℘ـَ͜✾ـ,چٰٖـٰٖ℘ـَ͜✾ـ,ظٰٖـٰٖ℘ـَ͜✾ـ,طٰٖـٰٖ℘ـَ͜✾ـ,زٰٖـٰٖ℘ـَ͜✾ـ,رٰٖـٰٖ℘ـَ͜✾ـ,دٰٖـٰٖ℘ـَ͜✾ـ,پٰٖـٰٖ℘ـَ͜✾ـ,وٰٖـٰٖ℘ـَ͜✾ـ,کٰٖـٰٖ℘ـَ͜✾ـ,گٰٖـٰٖ℘ـَ͜✾ـ,ثٰٖـٰٖ℘ـَ͜✾ـ,ژٰٖـٰٖ℘ـَ͜✾ـ,ذٰٖـٰٖ℘ـَ͜✾ـ,آٰٖـٰٖ℘ـَ͜✾ـ,ئٰٖـٰٖ℘ـَ͜✾ـ,.ٰٖـٰٖ℘ـَ͜✾ـ,_",
                      "ض❈ۣۣـ🍁ـ,ص❈ۣۣـ🍁ـ,ق❈ۣۣـ🍁ـ,ف❈ۣۣـ🍁ـ,غ❈ۣۣـ🍁ـ,ع❈ۣۣـ🍁ـ,ه❈ۣۣـ🍁ـ,خ❈ۣۣـ🍁ـ,ح❈ۣۣـ🍁ـ,ج❈ۣۣـ🍁ـ,ش❈ۣۣـ🍁ـ,س❈ۣۣـ🍁ـ,ی❈ۣۣـ🍁ـ,ب❈ۣۣـ🍁ـ,ل❈ۣۣـ🍁ـ,ا❈ۣۣـ🍁ـ,ن❈ۣۣـ🍁ـ,ت❈ۣۣـ🍁ـ,م❈ۣۣـ🍁ـ,چ❈ۣۣـ🍁ـ,ظ❈ۣۣـ🍁ـ,ط❈ۣۣـ🍁ـ,ز❈ۣۣـ🍁ـ,ر❈ۣۣـ🍁ـ,د❈ۣۣـ🍁ـ,پ❈ۣۣـ🍁ـ,و❈ۣۣـ🍁ـ,ک❈ۣۣـ🍁ـ,گ❈ۣۣـ🍁ـ,ث❈ۣۣـ🍁ـ,ژ❈ۣۣـ🍁ـ,ذ❈ۣۣـ🍁ـ,آ❈ۣۣـ🍁ـ,ئ❈ۣۣـ🍁ـ,.❈ۣۣـ🍁ـ,_",
                      "ضْஓ͜ঠৡ,صْஓ͜ঠৡ,قْஓ͜ঠৡ,فْஓ͜ঠৡ,غْஓ͜ঠৡ,عْஓ͜ঠৡ,هْஓ͜ঠৡ,خْஓ͜ঠৡ,حْஓ͜ঠৡ,جْஓ͜ঠৡ,شْஓ͜ঠৡ,سْஓ͜ঠৡ,یْஓ͜ঠৡ,بْஓ͜ঠৡ,لْஓ͜ঠৡ,اْஓ͜ঠৡ,نْஓ͜ঠৡ,تْஓ͜ঠৡ,مْஓ͜ঠৡ,چْஓ͜ঠৡ,ظْஓ͜ঠৡ,طْஓ͜ঠৡ,زْஓ͜ঠৡ,رْஓ͜ঠৡ,دْஓ͜ঠৡ,پْஓ͜ঠৡ,وْஓ͜ঠৡ,کْஓ͜ঠৡ,گْஓ͜ঠৡ,ثْஓ͜ঠৡ,ژْஓ͜ঠৡ,ذْஓ͜ঠৡ,آْஓ͜ঠৡ,ئْஓ͜ঠৡ,.ْஓ͜ঠৡ,_",
                      "ضـೄ,صـ۪۪ـؒؔـؒؔ◌͜͡◌,قـ۪۪ـؒؔـ۪۪,فـ͜͡ــؒؔـ͜͝ـ,غـೄ,عـ۪۪ـؒؔـ۪۪,هٍٖ❦,خـٜٓـٍٜـٜ٘ـ,حـٜ٘ـَٖ,جٍٍـٍٜــٍٍـٜ٘,͜͡∅شٍٜ۩,↜͜͡∅سٍٜ۩,یٜ٘,↭ِِبَٖ↜͜͡,لـٍٍـٍٜــٍٍـٜ٘∅,↜͜͡'اَُ'ِ,❦نٍٓ,تـــ۪۪ـؒؔــؒؔ◌͜͡◌,مـೄ,چــ۪۪ـؒؔـ۪۪,❀ظـؒؔ❀,طــَ͜✿ٰ,✧زٰٰ‌〆۪۪,✵ٍٓ ٍٖر,دٍٖ❦,پـٖٖـٖٖــَ͜✧,℘و'َ͜✿,کـٖٖـٖٖ‍℘,گـؒؔـٰٰ‌℘,❀ثـٜـؒؔ〆۪۪,ژٍٖ❦,✿ٰٰ‌ذ❀✵آٍٓ✵ٓ,ئـೄ,.,_",
                      "✮ًٍضـًٍـَؔ✯ًٍ,✮صًٍـًٍـَؔ✯ًٍ,✮قًٍـًٍـَؔ✯ًٍ,✮ًٍفـًٍـَؔ✯ًٍ,✮غًٍـًٍـَؔ✯,ًٍ✮عًٍـًٍـَؔ✯ًٍ,✮هًٍـًٍـَؔ✯ًٍ,✮خًٍـًٍـَؔ✯ًٍ,✮ًٍحـٜـًٍـَؔ✯ًٍ,✮جًٍـًٍـَؔ✯ًٍ,✮شًٍـًٍـَؔ✯ًٍ,✮سًٍـًٍـَؔ✯ًٍ,✮ًٍیــًٍـَؔ✯ًٍ,✮بـًٍـًٍـَؔ✯ًٍ,✮لـًٍـًٍـَؔ✯ًٍ,✮ًٍا✯ًٍ,✮نًٍـًٍـَؔ✯ًٍ,✮تًٍـًٍـَؔ✯ًٍ,✮مًٍـًٍـَؔ✯ًٍ,✮چًٍـًٍـَؔ✯ًٍ,✮ظًٍـًٍـَؔ✯ًٍ,✮ًٍطـًٍـَؔ✯ًٍ,زَؔ✯ًٍ,ًٍرَؔ✯ًٍ,✮ًٍد,َؔ✮پًٍـًٍـَؔ✯ًٍ,✯ًٍو,✮ًٍکـًٍـَؔ✯ًٍ,✮ًٍگـًٍـَؔ✯ًٍ,✮ًٍثــًٍـَؔ✯ًٍ,✮ژًٍ,✯ًٍذ,✮آًٍ✯ًٍ,✮ئـًٍـًٍـَؔ✯ًٍ,.,_",
                      "ضـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,صـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,قـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,فـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,غـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,عـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,هـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,خـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,حـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,جـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,شـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,سـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,یـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,بـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,لـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,✯اّّ✯,نـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,تـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,مـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,چـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,ظـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,طـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,✯زَّ'✯,✯ر✯,✯د✯,پـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,‌ົ້◌ฺฺ'‌ົ້و◌ฺฺ,ڪـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,گـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,ثـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,‌ົ້◌ฺฺژ,✯ذ✯,ಹ۪۪'آ'‌ົ້◌ฺฺಹ۪۪,ئـؒؔـؒؔـ۪۪ـؒؔـؒؔـ‌ົ້◌ฺฺಹ۪۪,.,_",
                      "ضـٰٖـۘۘـــٍٰـ,صـٰٖـۘۘـــٍٰـ,قـٰٖـۘۘـــٍٰـ,فـٰٖـۘۘـــٍٰـ,غـٰٖـۘۘـــٍٰـ,عـٰٖـۘۘـــٍٰـ,ه',خـٰٖـۘۘـــٍٰـ,حـٰٖـۘۘـــٍٰـ,جـٰٖـۘۘـــٍٰـ,شـٰٖـۘۘـــٍٰـ,سـٰٖـۘۘـــٍٰـ,یـٰٖـۘۘـــٍٰـ,بـٰٖـۘۘـــٍٰـ,لـٰٖـۘۘـــٍٰـ,ا,نـٰٖـۘۘـــٍٰـ,تـٰٖـۘۘـــٍٰـ,مـٰٖـۘۘـــٍٰـ,چـٰٖـۘۘـــٍٰـ,ظـٰٖـۘۘـــٍٰـ,طـٰٖـۘۘـــٍٰـ,ز,ر,د,پـٰٖـۘۘـــٍٰـ,و,ڪـٰٖـۘۘـــٍٰـ,گـٰٖـۘۘـــٍٰـ,ثـٰٖـۘۘـــٍٰـ,ژ,ذ,آ,ئـٰٖـۘۘـــٍٰـ,.,_",
                      "ضٰٓـؒؔـ۪۪ঊ۝,صٰٓـؒؔـ۪۪ঊ۝,قٰٓـؒؔـ۪۪ঊ۝,قٰٓـؒؔـ۪۪ঊ۝,غٰٓـؒؔـ۪۪ঊ۝,عٰٓـؒؔـ۪۪ঊ۝,هٰٓـؒؔـ۪۪ঊ۝,خٰٓـؒؔـ۪۪ঊ۝,ٰحٰٓـؒؔـ۪۪ঊ۝ٰٓ,جٰٓـؒؔـ۪۪ঊ۝,شٰٓـؒؔـ۪۪ঊ۝,سٰٓـؒؔـ۪۪ঊ۝,یٰٓـؒؔـ۪۪ঊ۝,بٰٓـؒؔـ۪۪ঊ۝,لٰٓـؒؔـ۪۪ঊ۝,اٰ۪,نٰٓـؒؔـ۪۪ঊ۝,تٰٓـؒؔـ۪۪ঊ۝,مٰٓـؒؔـ۪۪ঊ۝,چٰٓـؒؔـ۪۪ঊ۝,ظٰٓـؒؔـ۪۪ঊ۝,طٰٓـؒؔـ۪۪ঊ۝ٰٓ,زؓঊ,رٰٓ,۪۪دؓ,پٰٓـؒؔـ۪۪ঊ۝,وٰٓ,۪۪کٰٓـؒؔـ۪۪ঊ۝,گٰٓـؒؔـ۪۪ঊ۝,ثٰٓـؒؔـ۪۪ঊ۝,ؒؔژؓঊ,ذ۪۪ঊ,آٰٓ۝,ئٰٓـؒؔـ۪۪ঊ۝,.,_",
                      "ض۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ص۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ق۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ف۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,غ۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ع۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ه۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,خ۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ح۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ج۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ش۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,س۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ی۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ب۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ل۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ٗؔ✰͜͡ا℘ِِ,ن۪۟ــ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ت۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,م۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,چ۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ظ۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ط۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,✰͜͡ز℘ِِ,ٗؔ✰ر͜͡℘ِِ,✰͜͡د℘ِِ,پ۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,۪ٜ✰و͜͡℘ِِ,ڪ۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,گ۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,ث۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,✰͜͡ژ℘ِِ,ٗؔ✰ذ͜͡℘ِِ,✰͜͡آ'℘ِِ,ئ۪۟ـ۟۟✶ًٍـ۟ـًٍـ۪۟ـ۟ـًٍــ۪۟ـ۟۟ـً۟ــٗؔـٗؔ✰͜͡℘ِِ,.,_",
                      "ضـ۪۪ইٌ,صـ۪۪ইٌ,قـ۪۪ইٌ,فّــٍ͜ـ়়,غــٍ͜ـ়়,ع়ۘـٖٖــ,,ۘۘهُِـۘۘ,,خـ়ـۘۘـٍٰ,حـْ₰ْۜ,جـْ₰ْۜ,شـْ ـْ₰,سّـ ـٍ͜ـ়়,یْۜـْ✤ْ,بـ̴̬℘̴̬ـ̴̬مـ̴̬℘,لـ̴̬ـ̴̬مـ,ا,نـ̴̬℘̴̬ـ̴, تـ̴̬℘̴̬ـ̴̬م̴̬,℘مـ̴̬ـ̴̬مـ℘,چــَؔ۝,ظــَؔ۝,ط়ـۘۘـٍٰ℘,زٌّ,رٌّ,دٌّ,پــٍ͜ـ়়و,ڪ়ۘ,گـٖٖـۘۘـۘۘـُِـۘۘ,ثــَ͜✿ٰٰ‌ᬼ✵,ژ,ذ,آ,ئــٜ۪✦ــٜ۪✦,.,_",
                      "ضؔؑـَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,صؔؑــَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,قؔؑــَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,❂ؔؑفــَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,غؔؑــَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,عـَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,هؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,خؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,حؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,جــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,شؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,سـَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,یؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,بؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,لؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,اสฺฺ,ؔؑنــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,ؔؑتــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,مؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,چؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,ظؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,طؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,❂زؔؑ ـَؔ ,رสฺฺŗ,❂ؔؑـَؔد۪๛ٖؔ,ؔؑپــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,❂وؔؑ ـَؔ,ڪؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,گؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,ثؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,สฺฺŗـذَؔ๛ٖؔ,❂آ,ئؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,.,_",
                      "ضــ ོꯨ҉ــؒؔ҉:ـــ,صــ ོꯨ҉ــؒؔ҉:ــــ,قــ ོꯨ҉ــؒؔ҉:ــــ,فــ ོꯨ҉ــؒؔ҉:ــــ,غــ ོꯨ҉ــؒؔ҉:ــــ,عــ ོꯨ҉ــؒؔ҉:ــــ,هــ ོꯨ҉ــؒؔ҉:ــــ,خــ ོꯨ҉ــؒؔ҉:ــــ,حــ ོꯨ҉ــؒؔ҉:ــــ,ج۪ٜــ ོꯨ҉ــؒؔ҉:ــــ,شــ ོꯨ҉ــؒؔ҉:ــــ,ســ ོꯨ҉ــؒؔ҉:ــــ,یــ ོꯨ҉ــؒؔ҉:ــــ,بــ ོꯨ҉ــؒؔ҉:ــــ,لــ ོꯨ҉ــؒؔ҉:ــــ,اــ ོꯨ҉ــؒؔ҉:ــــ,نــ ོꯨ҉ــؒؔ҉:ــــ,تــ ོꯨ҉ــؒؔ҉:ــــ,مــ ོꯨ҉ــؒؔ҉:ــــ,چــ ོꯨ҉ــؒؔ҉:ــــ,ظــ ོꯨ҉ــؒؔ҉:ــــ,طــ ོꯨ҉ــؒؔ҉:ــــ,زــ ོꯨ҉ــؒؔ҉:ــــ,رــ ོꯨ҉ــؒؔ҉:ــــ,دــ ོꯨ҉ــؒؔ҉:ــــ,پــ ོꯨ҉ــؒؔ҉:ــــ,وــ ོꯨ҉ــؒؔ҉:ــــ,کــ ོꯨ҉ــؒؔ҉:ــــ,گــ ོꯨ҉ــؒؔ҉:ــــ,ثــ ོꯨ҉ــؒؔ҉:ــــ,ژــ ོꯨ҉ــؒؔ҉:ــــ,ذــ ོꯨ҉ــؒؔ҉:ــــ,آ,ئ,.,_",
                      "ضؔؑـَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,صؔؑــَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,قؔؑــَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,❂ؔؑفــَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,غؔؑــَؔـَؔ ـَؔ สฺฺŗــَؔ๛ٖؔ,عـَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,هؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,خؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,حؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,جــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,شؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,سـَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,یؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,بؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,لؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,اสฺฺ,ؔؑنــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,ؔؑتــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,مؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,چؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,ظؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,طؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,❂زؔؑ ـَؔ ,رสฺฺŗ,❂ؔؑـَؔد۪๛ٖؔ,ؔؑپــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,❂وؔؑ ـَؔ,ڪؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,گؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,ثؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,สฺฺŗـذَؔ๛ٖؔ,❂آ,ئؔؑــَؔـَؔ ـَؔ สฺฺŗـَؔ๛ٖؔ,.,_",
                      "ضؔؑـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑصـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑقـَؔ ـؔؑـَؔ๛ٖؔ,فؔؑـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑغـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑعـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑه۪๛ٖؔ,ؔؑخـَؔ ـؔؑـَؔ๛ٖؔ,حؔؑـَؔ ـؔؑـَؔ๛ٖؔ,جؔؑـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑشـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑسـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑیـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑبـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑلـَؔ ـؔؑـَؔ๛ٖؔ,ا,ؔؑنـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑتـَؔ ـؔؑـَؔ๛ٖؔ,مؔؑـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑچـَؔ ـؔؑـَؔ๛ٖؔ,طؔؑـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑظـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑزَؔ,ر,د,پؔؑـَؔ ـؔؑـَؔ๛ٖؔ,و,کؔؑـَؔ ـؔؑـَؔ๛ٖؔ,گؔؑـَؔ ـؔؑـَؔ๛ٖؔ,ؔؑثـَؔ ـؔؑـَؔ๛ٖؔ,ژ,ذ,آ,ؔؑئـَؔ ـؔؑـَؔ๛ٖؔ,.,_",
                      "ضـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,صـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,قـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,فـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,غـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,عـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,ه➤,خـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,حـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,جـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,شـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,سـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,یـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,بـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,لـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,ا✺۠۠➤,نـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,تـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,مـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,چـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,ظـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,طـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,ز✺۠۠➤,ر✺۠۠➤,د✺۠۠➤,پـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,و✺۠۠➤,کـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,گـ͜͝ـ͜͝ـ͜͝ـ✺۠۠➤,ث✺۠۠➤,ژ✺۠۠➤,ذ✺۠۠➤,آ✺۠۠➤,ئ✺۠۠➤,.,_",
                      "ضٖـٖٗ⸭ـٖٖٗـٖٗ⸭ٖٗ,صٖـٖٗ⸭ـٖٗـٖٖٗـٖٗ⸭,قـٖٗ⸭ـٖٗـٖٖٗـٖٗ⸭,فٖـٖٗ⸭ـٖٗـٖٖٗـٖٗ⸭,غٖـٖٗ⸭ــٖٖٗـٖٗ⸭,عٖـٖٗ⸭ــٖٖٗـٖٗ⸭,هٖٗ⸭,خٖـٖٗ⸭ـٖٗـٖٖٗـٖٗ⸭,حـٖٗ⸭ــٖٖٗـٖٗ⸭,جـٖٗ⸭ــٖٖٗـٖٗ⸭,شٖـٖٗ⸭ـٖٗـٖٖٗـٖٗ⸭,سٖـٖٗ⸭ــٖٖٗـٖٗ⸭,یـٖٗ⸭ـٖٗـٖٖٗـٖٗ⸭,ٖبـٖٗ⸭ــٖٖٗـٖٗ⸭,ٖلـٖٗ⸭,ـٖٖٗـٖٗا⸭,ٖنـٖٗ⸭ٖٗـٖٖٗـٖٗ⸭,تٖـٖٗ⸭ـٖٖٗـٖٗ⸭,مٖـٖٗ⸭ـٖٗـٖٗ⸭,چـٖٗ⸭ـٖٖٗـٖٗ⸭,ظـٖٗ⸭ـٖٖٗـٖٗ⸭,طـٖٗ⸭ـٖٖٗـٖٗ⸭,ز⸭,ٖرٖٗ⸭,ٖٗ⸭ـٖٖٗـٖٗد⸭,پـٖٗ⸭ـٖٖٗـٖٗ⸭,⸭ـوٖٖٗـٖٗ⸭,ڪـٖٗ⸭ـٖٖٗـٖٗ⸭,گـٖٗ⸭ـٖٖٗـٖٗ⸭,ثـٖٗ⸭ـٖٖٗـٖٗ⸭,ٖٗژ⸭,ٖٗ⸭ـذٖٗ⸭,⸭آ⸭,ئـٖٖٗـٖٗ⸭ـٖٖٗـٖٗ⸭,.,_",
                      "ِِِِِِْْٰٰٰٰٰٰٖٖٖٖٖٖٖٖٖٖضـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,ص۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,۪ٜقـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,ف۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,۪ٜغـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,عـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,هٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,خ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,خ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,جـ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,ش۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,سـ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,یـ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,بـ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,لـ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,۪ٜاٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,نـ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,تـ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,م۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,چ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,ظ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,طـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,ٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡ز✦,رٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,ٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡د✦,پ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡و✦,ڪـ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,گ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,ث۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,ٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡ژ✦,ذٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,آٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,ئـ۪ٜـ۪ٜـ۪ٜـٰٰٰٰٰٰٰٰٰٰٰٰٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪ٜ۪۪۪۪۪۪ٜٜٜٜٖٜٜٜٖٜٖٖٖٖٖٖٖ͜͡✦,.,_",
                      "ضـٍ͜ـ❉,صـٍ͜ــٍ͜❉,قـٍ͜ــٍ͜ــٍ͜❉,فـٍ͜ـ❉,غـٍ͜ــٍ͜ـ❉,عـٍ͜ــٍ͜ــٍ͜ـ❉,هـٍ͜ـ❉,خـٍ͜ــٍ͜❉,حـٍ͜ــٍ͜ــٍ͜❉,جـٍ͜ـ❉,شـٍ͜ــٍ͜❉,سـٍ͜ــٍ͜ــٍ͜❉,یـٍ͜ـ❉,بـٍ͜ــٍ͜❉,لـٍ͜ــٍ͜❉,ـٍ͜ــٍ͜ــٍ͜ا❉,نـٍ͜ـ❉,تـٍ͜ــٍ͜❉,مـٍ͜ــٍ͜ــٍ͜❉,چـٍ͜ـ❉,ظـٍ͜ــٍ͜❉,طـٍ͜ــٍ͜❉,زٍ͜❉,رٍ͜❉,دٍ͜❉,پـٍ͜ـ❉,وۘ❉,ڪـٍ͜ــٍ͜ــٍ͜❉,گـٍ͜ـ❉,ثـٍ͜ــٍ͜❉,ژً❉,ذٌ❉,آ❉,ئـٍ͜ـ❉,.,_",
                      "ضـْْـْْـْْ/ْْ,صـْْـْْـ,قْْـْْـْْـْْ/ْْ,فـْْـْْـ,ْْغـْْـْْـْْ/,عْْـْْـْْـْْ,هـْْـْْـْْ/,خْْـْْـْْـ,حْْـْْـْْـْْ/ْْ,جـْْـْْـْْ,شـْْـْْـْْ/ْْ,سـْْـْْـْْ,یـْْـْْـْْ/,بْْـْْـْْـ,لْْـْْـْْـْْ/ْْ,ـْْـْْـْْا,نـْْـْْـْْ/ْْ,تـْْـْْـْْ,مـْْـْْـْْ/ْْ,چْـْْـْْـ,ظْْـْْـْْـْْ/,طْْـْْـْْـْْ,زٌ/,ـْْر,ـْْـْْـدْْ/,پْْـْْـْْـ,ـْْـْْـْْو/ْْ,ڪْـْْـْْـْْ,گـْْـْْـْْ/,ثْْـْْـْْـْْ,ـْْـْْـژْْ/,ْْـْْـْْـذ,آْْ/ْْ,ئـْْـْْـْْـْْـْْ/ْْ,.,_",
                      "↜ضٍٍـُِ➲ِِனُِ,صـِْـَِ➲َِனِِ,↜ٍٍقـُِ➲ِِனُِ,فـِْـَِ➲َِனِِ↝,↜ٍٍغـُِ➲ِِனُِ,عـِْـَِ➲َِனِِ↝,↜ٍٍهـُِ➲ِِனُِ,خـِْـَِ➲َِனِِ↝,↜ٍٍحـُِ➲ِِனُِ,جـِْـَِ➲َِனِِ↝,↜ٍٍشـُِ➲ِِனُِ,سـِْـَِ➲َِனِِ↝,↜یٍٍـُِ➲ِِனُِ,بـِْـَِ➲َِனِِ↝,↜ٍٍلـُِ➲ِِனُِ,ِْاَِ➲َِனِِ↝,↜نٍٍـُِ➲ِِனُِ,تـِْـَِ➲َِனِِ↝,↜مٍٍـُِ➲ِِனُِ,چـِْـَِ➲َِனِِ↝,↜ظٍٍـُِ➲ِِனُِ,طـِْـَِ➲َِனِِ↝,↜ٍٍـزُِ➲ِِனُِ,ـِْـَِرِ➲َِனِِ↝,↜ٍٍـُِد➲ِِனُِ,پـِْـَِ➲َِனِِ↝,↜ٍٍـُِو➲ِِனُِ,ـِْـَِ➲َِனِِ↝,↜ٍٍڪـُِ➲ِِனُِ,گـِْـَِ➲َِனِِ↝,↜ثٍٍـُِ➲ِِனُِ,ـِْـژَِ➲َِனِِ↝,↜ٍٍـُِذ➲ِِனُِ,آَِ➲َِனِِ↝,↜ٍٍئـُِ➲ِِனُِ↝,.,_",
                      "ضـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,صـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,قـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,فـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,غـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,عـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,هـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,خـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,حـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,جـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,شـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,سـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,یـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,بـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,لـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,ا✓,ن̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,تـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,مـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,چـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,ظـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,طـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,̺ز◕̟͠₰̵͕◚̶̶₰͕͔,̚͠رـ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,د̵͠◕̟͠₰ ,پـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,ـ̚͠ــ̵͠و̺◕̟͠₰̵͕◚̶̶₰͕͔,ڪـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,گـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,ثـ̚͠ــ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,ژ◕̟͠₰̵͕◚̶̶₰͕͔,ـ̚͠ـذـ̵͠ـ̵͠◕̟͠₰̵͕◚̶̶₰͕͔ ,آ✓,ئـ̚͠ــ̵͠◕̟͠₰̵͕◚̶̶₰͕͔,.,_",
                      "ضـٰٓـًً◑ِّ◑ًً, صـུـٜٜ◑ِّ◑ًً,قـٰٓـًً◑ِّ◑ًً, فـུـٜٜ◑ِّ◑ًً,غـٰٓـًً◑ِّ◑ًً, عـུـٜٜ◑ِّ◑ًً,هـٰٓـًً◑ِّ◑ًً, خـུـٜٜ◑ِّ◑ًً,حـٰٓـًً◑ِّ◑ًً, جـུـٜٜ◑ِّ◑ًً,شـٰٓـًً◑ِّ◑ًً, سـུـٜٜ◑ِّ◑ًً,یـٰٓـًً◑ِّ◑ًً, بـུـٜٜ◑ِّ◑ًً,لـٰٓـًً◑ِّ◑ًً, ا◑ِّ◑ًً,نـٰٓـًً◑ِّ◑ًً, تـུـٜٜ◑ِّ◑ًً,مـٰٓـًً◑ِّ◑ًً, چـུـٜٜ◑ِّ◑ًً,ظـٰٓـًً◑ِّ◑ًً, طـུـٜٜ◑ِّ◑ًً,ز◑ِّ◑ًً,رٜٜ◑ِّ◑ًً,د◑ِّ◑ًً, پـུـٜٜ◑ِّ◑ًً,وًً◑ِّ◑ًً, ڪـུـٜٜ◑ِّ◑ًً,گـٰٓـًً◑ِّ◑ًً, ثـུـٜٜ◑ِّ◑ًً,ژ◑ِّ◑ًً,ذٜٜ◑ِّ◑ًً,ا◑ِّ◑ًً, ئـུـٜٜ◑ِّ◑ًً,.,_",
                      "ضـ͜͡ـ͜͡✭,صـ͜͡ـ͜͡✭,قـ͜͡ـ͜͡ـ͜͡✭,فــ͜͡ـ͜͡✭,غـ͜͡ـ͜͡✭,عـ͜͡ـ͜͡✭,هـ͜͡ـ͜͡ـ͜͡✭,خــ͜͡ـ͜͡✭,حـ͜͡ـ͜͡✭,جـ͜͡ـ͜͡✭,شـ͜͡ـ͜͡ـ͜͡✭,ســ͜͡ـ͜͡✭,یـ͜͡ـ͜͡✭,بـ͜͡ـ͜͡✭,لـ͜͡ـ͜͡ـ͜͡✭,͜͡ا✭,نـ͜͡ـ͜͡✭,تـ͜͡ـ͜͡✭,مـ͜͡ـ͜͡ـ͜͡✭,چــ͜͡ـ͜͡✭,ظـ͜͡ـ͜͡✭,طـ͜͡ـ͜͡✭,ز͜͡✭,͜͡ر✭,͜͡د✭,پـ͜͡ـ͜͡✭,ـ͜͡و͜͡ـ͜͡✭,ڪــ͜͡ـ͜͡✭,گـ͜͡ـ͜͡✭,ـ͜͡ـ͜͡✭,ثـ͜͡ـ͜͡ـ͜͡✭,ـ͜͡ژ͜͡✭,ذ✭,آ✭,ئـ͜͡ـ͜͡ـ͜͡✭,.,_",
                      "ضـًٍـؒؔـؒؔ⸙ؒৡ✪,صـًٍـؒؔـؒؔ⸙ؒৡ✪,قـًٍـؒؔـؒؔ⸙ؒৡ✪,فـًٍـؒؔـؒؔ⸙ؒৡ✪,غـًٍـؒؔـؒؔ⸙ؒৡ✪,عـًٍـؒؔـؒؔ⸙ؒৡ✪,هـًٍـؒؔـؒؔ⸙ؒৡ✪,خـًٍـؒؔـؒؔ⸙ؒৡ✪,حـًٍـؒؔـؒؔ⸙ؒৡ✪,جـًٍـؒؔـؒؔ⸙ؒৡ✪,شـًٍـؒؔـؒؔ⸙ؒৡ✪,سـًٍـؒؔـؒؔ⸙ؒৡ✪,یـًٍـؒؔـؒؔ⸙ؒৡ✪,بـًٍـؒؔـؒؔ⸙ؒৡ✪,لـًٍـؒؔـؒؔ⸙ؒৡ✪,ا✪,نـًٍـؒؔـؒؔ⸙ؒৡ✪,تـًٍـؒؔـؒؔ⸙ؒৡ✪,مـًٍـؒؔـؒؔ⸙ؒৡ✪,چـًٍـؒؔـؒؔ⸙ؒৡ✪,ظـًٍـؒؔـؒؔ⸙ؒৡ✪,طـًٍـؒؔـؒؔ⸙ؒৡ✪,ز✪,ر✪,د✪,پـًٍـؒؔـؒؔ⸙ؒৡ✪,و✪,ڪـًٍـؒؔـؒؔ⸙ؒৡ✪,گـًٍـؒؔـؒؔ⸙ؒৡ✪,ثـًٍـؒؔـؒؔ⸙ؒৡ✪,ژ✪,ذ✪,آ✪,ئـًٍـؒؔـؒؔ⸙ؒৡ✪,.,_",
                      "ضـ◎۪۪❖ुؔ,صـ◎۪۪❖ुؔ,قـ◎۪۪❖ुؔ,فـ◎۪۪❖ुؔ,غـ◎۪۪❖ुؔ,عـ◎۪۪❖ुؔ,هـ◎۪۪❖ुؔ,خـ◎۪۪❖ुؔ,حـ◎۪۪❖ुؔ,جـ◎۪۪❖ु,شـ◎۪۪❖ु,سـ◎۪۪❖ु,یـ◎۪۪❖ु,بـ◎۪۪❖ु,لـ◎۪۪❖ु,ا◎۪۪❖ु,نـ◎۪۪❖ु,تـ◎۪۪❖ु,مـ◎۪۪❖ु,چـ◎۪۪❖ु,ظـ◎۪۪❖ु,طـ◎۪۪❖ु,ز◎۪۪❖ु,ر◎۪۪❖ु,د◎۪۪❖ु,پـ◎۪۪❖ु,و◎۪۪❖ु,ڪـ◎۪۪❖ु,گـ◎۪۪❖ु,ثـ◎۪۪❖ु,ژ◎۪۪❖ु,ذ◎۪۪❖ु,آ◎۪۪❖ु,ئـ◎۪۪❖ु,.,_",
                      "ض۪ٓـٌْ‌ٍٖـ۪ٓـٌْ‌ٍٖ,صــ۪ٓـٌْ‌ٍٖ,‌ قـ۪ٓـٌْ‌ٍٖـ۪ٓ,فـٌْ‌ٍٖـ۪ٓ,غـٌْ‌ٍٖـ۪ٓ,عـٌْ‌ٍٖـ۪ٓ,هـٌْ‌ٍٖـ۪ٓ,خـٌْ‌ٍٖـ۪ٓ,حـٌْ‌ٍٖـ۪ٓ,جـٌْ‌ٍٖـ۪ٓ,شـٌْ‌ٍٖـ۪ٓ,سـٌْ‌ٍٖـ۪ٓ,یـٌْ‌ٍٖـ۪ٓ,بـٌْ‌ٍٖـ۪ٓ,لـٌْ‌ٍٖـ۪ٓ,اٌْ‌ٍٖـ۪ٓ,نـٌْ‌ٍٖـ۪ٓ,تـٌْ‌ٍٖـ۪ٓ,مـٌْ‌ٍٖـ۪ٓ,چـٌْ‌ٍٖـ۪ٓ,ظـٌْ‌ٍٖـ۪ٓ,طـٌْ‌ٍٖـ۪ٓ,زुـ۪ٓ,رٌْ‌ٍٖـ۪ٓ,دुـ۪ٓ,پـٌْ‌ٍٖـ۪ٓ,وुـ۪ٓ,ڪـٌْ‌ٍٖـ۪ٓ,گـٌْ‌ٍٖـ۪ٓ,ثـٌْ‌ٍٖـ۪ٓ,ژुـ۪ٓ,ذـٌْ‌ٍٖـ۪ٓ,آुـ۪ٓ,ئـٌْ‌ٍٖـ۪ٓ,.,_",
                      "ضِْـِْ❉,ِْصـِْ❉,قِْـِْ❉,ِْفـِْ❉,غِْـِْ❉,ِْعـِْ❉,ِْهـِْ❉,ِْخـِْ❉,ِْحـِْ❉,ِْجـِْ❉,ِْشـِْ❉,ِْسـِْ❉,یِْـِْ❉,بِْـِْ❉,لِْـِْ❉,ِْاـِْ❉,نِْـِْ❉,ِْتـِْ❉,ِْمـِْ❉,ِْچـِْ❉,ِْظـِْ❉,طِْـِْ❉,زِْـِْ❉,رِْـِْ❉,ِْدـِْ❉,پِْـِْ❉,وِْـِْ❉,ِْکـِْ❉,ِْگـِْ❉,ِْثـِْ❉,ِْژـِْ❉,ِْذـِْ❉,ِْآـِْ❉,ِْئـِْ❉,.,_",
                      "[ِْـِْضـِْ❉ِْـِْ,[ِْـِْصـِْ❉ِْـِْ,[ِْـِْقـِْ❉ِْـِْ,[ِْـِْفـِْ❉ِْـِْ,[ِْـغِْـِْ❉ِْـِْ,[ِْـعِْـِْ❉ِْـِْ,[ِْـهِْـِْ❉ِْـِْ,[ِْـِْخـِْ❉ِْـِْ,[ِْـِْحـِْ❉ِْـِْ,[ِْـِْجـِْ❉ِْـِْ,[ِْـِْشـِْ❉ِْـِْ,[ِْـِْسـِْ❉ِْـِْ,[ِْـِْیـِْ❉ِْـِْ,[ِْـِْبـِْ❉ِْـِْ,[ِْـلِْـِْ❉ِْـِْ,[ِْـاِْـِْ❉ِْـِْ,[ِْـِْنـِْ❉ِْـِْ,[ِْـِْتـِْ❉ِْـِْ,[ِْـمِْـِْ❉ِْـِْ,[ِْـچِْـِْ❉ِْـِْ,[ِْـِْظـِْ❉ِْـِْ,[ِْـِْطـِْ❉ِْـِْ,[ِْـِْزـِْ❉ِْـِْ,[ِْـرِْـِْ❉ِْـِْ,[ِْـِْدـِْ❉ِْـِْ,[ِْـپِْـِْ❉ِْـِْ,[ِْـِْوـِِْْ❉ِْـِْ,[ِْـڪِْـِْ❉ِْـِْ,[ِْـگِْـِْ❉ِْـِْ,[ِْـِْثـِْ❉ِْـِْ,[ِْـِْژـِْ❉ِْـِْ,[ِْـذِْـِْ❉ِْـِْ,[ِْـآِْـِْ❉ِْـِْ,[ِْـِْئـِْ❉ِْـِْ,.,_",
                      "❅ضـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅صـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅قـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅فـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅غـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅عـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅هـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅خـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅حـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅جـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅شـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅سـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅یـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅بـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅لـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅اؒؔ❢,❅نـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅تـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅مـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅چـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅ظـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅طـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅ـ۪۪ـؒؔـزؒؔـ۪۪ـؒؔـؒؔ❢,❅ـ۪۪ـؒؔـؒؔرـ۪۪ـؒؔـؒؔ❢,❅ـ۪۪ـؒؔـدؒؔـ۪۪ـؒؔـؒؔ❢,❅پـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅ـ۪۪ـؒؔـؒؔوـ۪۪ـؒؔـؒؔ❢,❅ڪـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅گـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅ثـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,❅ـ۪۪ـؒؔـژؒؔـ۪۪ـؒؔـؒؔ❢,❅ـ۪۪ـؒؔـذؒؔـ۪۪ـؒؔـؒؔ❢,❅۪۪آؒؔ❢,❅ئـ۪۪ـؒؔـؒؔـ۪۪ـؒؔـؒؔ❢,.,_",
                      "ضٖؒـؒؔـٰٰـٖٖ,صٖؒـؒؔـٰٰـٖٖ,قٖؒـؒؔـٰٰـٖٖ,فٖؒـؒؔـٰٰـٖٖ,غٖؒـؒؔـٰٰـٖٖ,عٖؒـؒؔـٰٰـٖٖ,هٖؒـؒؔـٰٰـٖٖ,خٖؒـؒؔـٰٰـٖٖ,حٖؒـؒؔـٰٰـٖٖ,جٖؒـؒؔـٰٰـٖٖ,شٖؒـؒؔـٰٰـٖٖ,سٖؒـؒؔـٰٰـٖٖ,یٖؒـؒؔـٰٰـٖٖ,بٖؒـؒؔـٰٰـٖٖ,لٖؒـؒؔـٰٰـٖٖ,اٖؒـؒؔـٰٰـٖٖ,نٖؒـؒؔـٰٰـٖٖ,تٖؒـؒؔـٰٰـٖٖ,مٖؒـؒؔـٰٰـٖٖ,چٖؒـؒؔـٰٰـٖٖ,ظٖؒـؒؔـٰٰـٖٖ,طٖؒـؒؔـٰٰـٖٖ,زٖؒـؒؔـٰٰـٖٖ,رٖؒـؒؔـٰٰـٖٖ,دٖؒـؒؔـٰٰـٖٖ,پٖؒـؒؔـٰٰـٖٖ,وٖؒـؒؔـٰٰـٖٖ,کٖؒـؒؔـٰٰـٖٖ,گٖؒـؒؔـٰٰـٖٖ,ثٖؒـؒؔـٰٰـٖٖ,ژٖؒـؒؔـٰٰـٖٖ,ذٖؒـؒؔـٰٰـٖٖ,آٖؒـؒؔـٰٰـٖٖ,ئٖؒـؒؔـٰٰـٖٖ,.ٖؒـؒؔـٰٰـٖٖ,_"
                    }
                    local result = {}
                    i = 0
                    do
                      do
                        for i = 1, #fonts do
                          i = i + 1
                          local tar_font = fonts[i]:split(",")
                          local text = TextToBeauty
                          local text = text:gsub("ض", tar_font[1])
                          local text = text:gsub("ص", tar_font[2])
                          local text = text:gsub("ق", tar_font[3])
                          local text = text:gsub("ف", tar_font[4])
                          local text = text:gsub("غ", tar_font[5])
                          local text = text:gsub("ع", tar_font[6])
                          local text = text:gsub("ه", tar_font[7])
                          local text = text:gsub("خ", tar_font[8])
                          local text = text:gsub("ح", tar_font[9])
                          local text = text:gsub("ج", tar_font[10])
                          local text = text:gsub("ش", tar_font[11])
                          local text = text:gsub("س", tar_font[12])
                          local text = text:gsub("ی", tar_font[13])
                          local text = text:gsub("ب", tar_font[14])
                          local text = text:gsub("ل", tar_font[15])
                          local text = text:gsub("ا", tar_font[16])
                          local text = text:gsub("ن", tar_font[17])
                          local text = text:gsub("ت", tar_font[18])
                          local text = text:gsub("م", tar_font[18])
                          local text = text:gsub("چ", tar_font[20])
                          local text = text:gsub("ظ", tar_font[21])
                          local text = text:gsub("ط", tar_font[22])
                          local text = text:gsub("ز", tar_font[23])
                          local text = text:gsub("ر", tar_font[24])
                          local text = text:gsub("د", tar_font[25])
                          local text = text:gsub("پ", tar_font[26])
                          local text = text:gsub("و", tar_font[27])
                          local text = text:gsub("ک", tar_font[28])
                          local text = text:gsub("گ", tar_font[29])
                          local text = text:gsub("ث", tar_font[30])
                          local text = text:gsub("ژ", tar_font[31])
                          local text = text:gsub("ذ", tar_font[32])
                          local text = text:gsub("ئ", tar_font[33])
                          local text = text:gsub("آ", tar_font[34])
                          table.insert(result, text)
                        end
                      end
                    end
                    local result_text = "• کلمه مورد نظر شما : " .. TextToBeauty .. "\nطراحی شده با " .. tostring(#fonts) .. " فونت !\n\n"
                    do
                      do
                        for i = 1, #result do
                          result_text = result_text .. i .. " - " .. result[i] .. [[


]]
                        end
                      end
                    end
                    sendText(chat_id, msg_id, result_text, "html")
                  end
                  if text and text:match("^(font) (.*)$") or text and text:match("^(font) (.*)$") then
                    MatchesEN = {
                      text:match("^(font) (.*)$")
                    }
                    MatchesFA = {
                      text:match("^(font) (.*)$")
                    }
                    TextToBeauty = MatchesEN[2] or MatchesFA[2]
                    local font_base = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,9,8,7,6,5,4,3,2,1,.,_"
                    local font_base = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,9,8,7,6,5,4,3,2,1,.,_"
                    local font_hash = "z,y,x,w,v,u,t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,Z,Y,X,W,V,U,T,S,R,Q,P,O,N,M,L,K,J,I,H,G,F,E,D,C,B,A,0,1,2,3,4,5,6,7,8,9,.,_"
                    local fonts = {
                      "ⓐ,ⓑ,ⓒ,ⓓ,ⓔ,ⓕ,ⓖ,ⓗ,ⓘ,ⓙ,ⓚ,ⓛ,ⓜ,ⓝ,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,ⓣ,ⓤ,ⓥ,ⓦ,ⓧ,ⓨ,ⓩ,ⓐ,ⓑ,ⓒ,ⓓ,ⓔ,ⓕ,ⓖ,ⓗ,ⓘ,ⓙ,ⓚ,ⓛ,ⓜ,ⓝ,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,ⓣ,ⓤ,ⓥ,ⓦ,ⓧ,ⓨ,ⓩ,⓪,➈,➇,➆,➅,➄,➃,➂,➁,➀,●,_",
                      "⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⓪,⑼,⑻,⑺,⑹,⑸,⑷,⑶,⑵,⑴,.,_",
                      "α,в,c,∂,є,ƒ,g,н,ι,נ,к,ℓ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,χ,у,z,α,в,c,∂,є,ƒ,g,н,ι,נ,к,ℓ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,χ,у,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,в,c,d,e,ғ,ɢ,н,ι,j,ĸ,l,м,ɴ,o,p,q,r,ѕ,т,υ,v,w,х,y,z,α,в,c,d,e,ғ,ɢ,н,ι,j,ĸ,l,м,ɴ,o,p,q,r,ѕ,т,υ,v,w,х,y,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ą,ҍ,ç,ժ,ҽ,ƒ,ց,հ,ì,ʝ,ҟ,Ӏ,ʍ,ղ,օ,ք,զ,ɾ,ʂ,է,մ,ѵ,ա,×,վ,Հ,ą,ҍ,ç,ժ,ҽ,ƒ,ց,հ,ì,ʝ,ҟ,Ӏ,ʍ,ղ,օ,ք,զ,ɾ,ʂ,է,մ,ѵ,ա,×,վ,Հ,⊘,९,𝟠,7,Ϭ,Ƽ,५,Ӡ,ϩ,𝟙,.,_",
                      "ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,ß,ς,d,ε,ƒ,g,h,ï,յ,κ,ﾚ,m,η,⊕,p,Ω,r,š,†,u,∀,ω,x,ψ,z,α,ß,ς,d,ε,ƒ,g,h,ï,յ,κ,ﾚ,m,η,⊕,p,Ω,r,š,†,u,∀,ω,x,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ﾑ,乃,ζ,Ð,乇,ｷ,Ǥ,ん,ﾉ,ﾌ,ズ,ﾚ,ᄊ,刀,Ծ,ｱ,Q,尺,ㄎ,ｲ,Ц,Џ,Щ,ﾒ,ﾘ,乙,ﾑ,乃,ζ,Ð,乇,ｷ,Ǥ,ん,ﾉ,ﾌ,ズ,ﾚ,ᄊ,刀,Ծ,ｱ,q,尺,ㄎ,ｲ,Ц,Џ,Щ,ﾒ,ﾘ,乙,ᅙ,9,8,ᆨ,6,5,4,3,ᆯ,1,.,_",
                      "α,β,c,δ,ε,Ŧ,ĝ,h,ι,j,κ,l,ʍ,π,ø,ρ,φ,Ʀ,$,†,u,υ,ω,χ,ψ,z,α,β,c,δ,ε,Ŧ,ĝ,h,ι,j,κ,l,ʍ,π,ø,ρ,φ,Ʀ,$,†,u,υ,ω,χ,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ձ,ъ,ƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,ձ,ъ,ƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Λ,ɓ,¢,Ɗ,£,ƒ,ɢ,ɦ,ĩ,ʝ,Қ,Ł,ɱ,ה,ø,Ṗ,Ҩ,Ŕ,Ş,Ŧ,Ū,Ɣ,ω,Ж,¥,Ẑ,Λ,ɓ,¢,Ɗ,£,ƒ,ɢ,ɦ,ĩ,ʝ,Қ,Ł,ɱ,ה,ø,Ṗ,Ҩ,Ŕ,Ş,Ŧ,Ū,Ɣ,ω,Ж,¥,Ẑ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Λ,Б,Ͼ,Ð,Ξ,Ŧ,G,H,ł,J,К,Ł,M,Л,Ф,P,Ǫ,Я,S,T,U,V,Ш,Ж,Џ,Z,Λ,Б,Ͼ,Ð,Ξ,Ŧ,g,h,ł,j,К,Ł,m,Л,Ф,p,Ǫ,Я,s,t,u,v,Ш,Ж,Џ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "A̴,̴B̴,̴C̴,̴D̴,̴E̴,̴F̴,̴G̴,̴H̴,̴I̴,̴J̴,̴K̴,̴L̴,̴M̴,̴N̴,̴O̴,̴P̴,̴Q̴,̴R̴,̴S̴,̴T̴,̴U̴,̴V̴,̴W̴,̴X̴,̴Y̴,̴Z̴,̴a̴,̴b̴,̴c̴,̴d̴,̴e̴,̴f̴,̴g̴,̴h̴,̴i̴,̴j̴,̴k̴,̴l̴,̴m̴,̴n̴,̴o̴,̴p̴,̴q̴,̴r̴,̴s̴,̴t̴,̴u̴,̴v̴,̴w̴,̴x̴,̴y̴,̴z̴,̴0̴,̴9̴,̴8̴,̴7̴,̴6̴,̴5̴,̴4̴,̴3̴,̴2̴,̴1̴,̴.̴,̴_̴",
                      "ⓐ,ⓑ,ⓒ,ⓓ,ⓔ,ⓕ,ⓖ,ⓗ,ⓘ,ⓙ,ⓚ,ⓛ,ⓜ,ⓝ,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,ⓣ,ⓤ,ⓥ,ⓦ,ⓧ,ⓨ,ⓩ,ⓐ,ⓑ,ⓒ,ⓓ,ⓔ,ⓕ,ⓖ,ⓗ,ⓘ,ⓙ,ⓚ,ⓛ,ⓜ,ⓝ,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,ⓣ,ⓤ,ⓥ,ⓦ,ⓧ,ⓨ,ⓩ,⓪,➈,➇,➆,➅,➄,➃,➂,➁,➀,●,_",
                      "⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⓪,⑼,⑻,⑺,⑹,⑸,⑷,⑶,⑵,⑴,.,_",
                      "α,в,c,∂,є,ƒ,g,н,ι,נ,к,ℓ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,χ,у,z,α,в,c,∂,є,ƒ,g,н,ι,נ,к,ℓ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,χ,у,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,в,c,ɗ,є,f,g,н,ι,נ,к,Ɩ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,x,у,z,α,в,c,ɗ,є,f,g,н,ι,נ,к,Ɩ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,x,у,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,в,c,d,e,ғ,ɢ,н,ι,j,ĸ,l,м,ɴ,o,p,q,r,ѕ,т,υ,v,w,х,y,z,α,в,c,d,e,ғ,ɢ,н,ι,j,ĸ,l,м,ɴ,o,p,q,r,ѕ,т,υ,v,w,х,y,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,Ⴆ,ƈ,ԃ,ҽ,ϝ,ɠ,ԋ,ι,ʝ,ƙ,ʅ,ɱ,ɳ,σ,ρ,ϙ,ɾ,ʂ,ƚ,υ,ʋ,ɯ,x,ყ,ȥ,α,Ⴆ,ƈ,ԃ,ҽ,ϝ,ɠ,ԋ,ι,ʝ,ƙ,ʅ,ɱ,ɳ,σ,ρ,ϙ,ɾ,ʂ,ƚ,υ,ʋ,ɯ,x,ყ,ȥ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ą,ɓ,ƈ,đ,ε,∱,ɠ,ɧ,ï,ʆ,ҡ,ℓ,ɱ,ŋ,σ,þ,ҩ,ŗ,ş,ŧ,ų,√,щ,х,γ,ẕ,ą,ɓ,ƈ,đ,ε,∱,ɠ,ɧ,ï,ʆ,ҡ,ℓ,ɱ,ŋ,σ,þ,ҩ,ŗ,ş,ŧ,ų,√,щ,х,γ,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ą,ҍ,ç,ժ,ҽ,ƒ,ց,հ,ì,ʝ,ҟ,Ӏ,ʍ,ղ,օ,ք,զ,ɾ,ʂ,է,մ,ѵ,ա,×,վ,Հ,ą,ҍ,ç,ժ,ҽ,ƒ,ց,հ,ì,ʝ,ҟ,Ӏ,ʍ,ղ,օ,ք,զ,ɾ,ʂ,է,մ,ѵ,ա,×,վ,Հ,⊘,९,𝟠,7,Ϭ,Ƽ,५,Ӡ,ϩ,𝟙,.,_",
                      "მ,ჩ,ƈ,ძ,ε,բ,ց,հ,ἶ,ʝ,ƙ,l,ო,ղ,օ,ր,գ,ɾ,ʂ,է,մ,ν,ω,ჯ,ყ,z,მ,ჩ,ƈ,ძ,ε,բ,ց,հ,ἶ,ʝ,ƙ,l,ო,ղ,օ,ր,գ,ɾ,ʂ,է,մ,ν,ω,ჯ,ყ,z,0,Գ,Ց,Դ,6,5,Վ,Յ,Զ,1,.,_",
                      "ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,ß,ς,d,ε,ƒ,g,h,ï,յ,κ,ﾚ,m,η,⊕,p,Ω,r,š,†,u,∀,ω,x,ψ,z,α,ß,ς,d,ε,ƒ,g,h,ï,յ,κ,ﾚ,m,η,⊕,p,Ω,r,š,†,u,∀,ω,x,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ª,b,¢,Þ,È,F,૬,ɧ,Î,j,Κ,Ļ,м,η,◊,Ƿ,ƍ,r,S,⊥,µ,√,w,×,ý,z,ª,b,¢,Þ,È,F,૬,ɧ,Î,j,Κ,Ļ,м,η,◊,Ƿ,ƍ,r,S,⊥,µ,√,w,×,ý,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Δ,Ɓ,C,D,Σ,F,G,H,I,J,Ƙ,L,Μ,∏,Θ,Ƥ,Ⴓ,Γ,Ѕ,Ƭ,Ʊ,Ʋ,Ш,Ж,Ψ,Z,λ,ϐ,ς,d,ε,ғ,ɢ,н,ι,ϳ,κ,l,ϻ,π,σ,ρ,φ,г,s,τ,υ,v,ш,ϰ,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Λ,ß,Ƈ,D,Ɛ,F,Ɠ,Ĥ,Ī,Ĵ,Ҡ,Ŀ,M,И,♡,Ṗ,Ҩ,Ŕ,S,Ƭ,Ʊ,Ѵ,Ѡ,Ӿ,Y,Z,Λ,ß,Ƈ,D,Ɛ,F,Ɠ,Ĥ,Ī,Ĵ,Ҡ,Ŀ,M,И,♡,Ṗ,Ҩ,Ŕ,S,Ƭ,Ʊ,Ѵ,Ѡ,Ӿ,Y,Z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ﾑ,乃,ζ,Ð,乇,ｷ,Ǥ,ん,ﾉ,ﾌ,ズ,ﾚ,ᄊ,刀,Ծ,ｱ,Q,尺,ㄎ,ｲ,Ц,Џ,Щ,ﾒ,ﾘ,乙,ﾑ,乃,ζ,Ð,乇,ｷ,Ǥ,ん,ﾉ,ﾌ,ズ,ﾚ,ᄊ,刀,Ծ,ｱ,q,尺,ㄎ,ｲ,Ц,Џ,Щ,ﾒ,ﾘ,乙,ᅙ,9,8,ᆨ,6,5,4,3,ᆯ,1,.,_",
                      "α,β,c,δ,ε,Ŧ,ĝ,h,ι,j,κ,l,ʍ,π,ø,ρ,φ,Ʀ,$,†,u,υ,ω,χ,ψ,z,α,β,c,δ,ε,Ŧ,ĝ,h,ι,j,κ,l,ʍ,π,ø,ρ,φ,Ʀ,$,†,u,υ,ω,χ,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ค,๖,¢,໓,ē,f,ງ,h,i,ว,k,l,๓,ຖ,໐,p,๑,r,Ş,t,น,ง,ຟ,x,ฯ,ຊ,ค,๖,¢,໓,ē,f,ງ,h,i,ว,k,l,๓,ຖ,໐,p,๑,r,Ş,t,น,ง,ຟ,x,ฯ,ຊ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ձ,ъ,ƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,ձ,ъ,ƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Â,ß,Ĉ,Ð,Є,Ŧ,Ǥ,Ħ,Ī,ʖ,Қ,Ŀ,♏,И,Ø,P,Ҩ,R,$,ƚ,Ц,V,Щ,X,￥,Ẕ,Â,ß,Ĉ,Ð,Є,Ŧ,Ǥ,Ħ,Ī,ʖ,Қ,Ŀ,♏,И,Ø,P,Ҩ,R,$,ƚ,Ц,V,Щ,X,￥,Ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Λ,ɓ,¢,Ɗ,£,ƒ,ɢ,ɦ,ĩ,ʝ,Қ,Ł,ɱ,ה,ø,Ṗ,Ҩ,Ŕ,Ş,Ŧ,Ū,Ɣ,ω,Ж,¥,Ẑ,Λ,ɓ,¢,Ɗ,£,ƒ,ɢ,ɦ,ĩ,ʝ,Қ,Ł,ɱ,ה,ø,Ṗ,Ҩ,Ŕ,Ş,Ŧ,Ū,Ɣ,ω,Ж,¥,Ẑ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Λ,Б,Ͼ,Ð,Ξ,Ŧ,G,H,ł,J,К,Ł,M,Л,Ф,P,Ǫ,Я,S,T,U,V,Ш,Ж,Џ,Z,Λ,Б,Ͼ,Ð,Ξ,Ŧ,g,h,ł,j,К,Ł,m,Л,Ф,p,Ǫ,Я,s,t,u,v,Ш,Ж,Џ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Թ,Յ,Շ,Ժ,ȝ,Բ,Գ,ɧ,ɿ,ʝ,ƙ,ʅ,ʍ,Ռ,Ծ,ρ,φ,Ր,Տ,Ե,Մ,ע,ա,Ճ,Վ,Հ,Թ,Յ,Շ,Ժ,ȝ,Բ,Գ,ɧ,ɿ,ʝ,ƙ,ʅ,ʍ,Ռ,Ծ,ρ,φ,Ր,Տ,Ե,Մ,ע,ա,Ճ,Վ,Հ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Æ,þ,©,Ð,E,F,ζ,Ħ,Ї,¿,ズ,ᄂ,M,Ñ,Θ,Ƿ,Ø,Ґ,Š,τ,υ,¥,w,χ,y,շ,Æ,þ,©,Ð,E,F,ζ,Ħ,Ї,¿,ズ,ᄂ,M,Ñ,Θ,Ƿ,Ø,Ґ,Š,τ,υ,¥,w,χ,y,շ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "4,8,C,D,3,F,9,H,!,J,K,1,M,N,0,P,Q,R,5,7,U,V,W,X,Y,2,4,8,C,D,3,F,9,H,!,J,K,1,M,N,0,P,Q,R,5,7,U,V,W,X,Y,2,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Λ,M,X,ʎ,Z,ɐ,q,ɔ,p,ǝ,ɟ,ƃ,ɥ,ı,ɾ,ʞ,l,ա,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,Λ,M,X,ʎ,Z,ɐ,q,ɔ,p,ǝ,ɟ,ƃ,ɥ,ı,ɾ,ʞ,l,ա,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,0,9,8,7,6,5,4,3,2,1,.,‾",
                      "A̴,̴B̴,̴C̴,̴D̴,̴E̴,̴F̴,̴G̴,̴H̴,̴I̴,̴J̴,̴K̴,̴L̴,̴M̴,̴N̴,̴O̴,̴P̴,̴Q̴,̴R̴,̴S̴,̴T̴,̴U̴,̴V̴,̴W̴,̴X̴,̴Y̴,̴Z̴,̴a̴,̴b̴,̴c̴,̴d̴,̴e̴,̴f̴,̴g̴,̴h̴,̴i̴,̴j̴,̴k̴,̴l̴,̴m̴,̴n̴,̴o̴,̴p̴,̴q̴,̴r̴,̴s̴,̴t̴,̴u̴,̴v̴,̴w̴,̴x̴,̴y̴,̴z̴,̴0̴,̴9̴,̴8̴,̴7̴,̴6̴,̴5̴,̴4̴,̴3̴,̴2̴,̴1̴,̴.̴,̴_̴",
                      "A̱,̱Ḇ,̱C̱,̱Ḏ,̱E̱,̱F̱,̱G̱,̱H̱,̱I̱,̱J̱,̱Ḵ,̱Ḻ,̱M̱,̱Ṉ,̱O̱,̱P̱,̱Q̱,̱Ṟ,̱S̱,̱Ṯ,̱U̱,̱V̱,̱W̱,̱X̱,̱Y̱,̱Ẕ,̱a̱,̱ḇ,̱c̱,̱ḏ,̱e̱,̱f̱,̱g̱,̱ẖ,̱i̱,̱j̱,̱ḵ,̱ḻ,̱m̱,̱ṉ,̱o̱,̱p̱,̱q̱,̱ṟ,̱s̱,̱ṯ,̱u̱,̱v̱,̱w̱,̱x̱,̱y̱,̱ẕ,̱0̱,̱9̱,̱8̱,̱7̱,̱6̱,̱5̱,̱4̱,̱3̱,̱2̱,̱1̱,̱.̱,̱_̱",
                      "A̲,̲B̲,̲C̲,̲D̲,̲E̲,̲F̲,̲G̲,̲H̲,̲I̲,̲J̲,̲K̲,̲L̲,̲M̲,̲N̲,̲O̲,̲P̲,̲Q̲,̲R̲,̲S̲,̲T̲,̲U̲,̲V̲,̲W̲,̲X̲,̲Y̲,̲Z̲,̲a̲,̲b̲,̲c̲,̲d̲,̲e̲,̲f̲,̲g̲,̲h̲,̲i̲,̲j̲,̲k̲,̲l̲,̲m̲,̲n̲,̲o̲,̲p̲,̲q̲,̲r̲,̲s̲,̲t̲,̲u̲,̲v̲,̲w̲,̲x̲,̲y̲,̲z̲,̲0̲,̲9̲,̲8̲,̲7̲,̲6̲,̲5̲,̲4̲,̲3̲,̲2̲,̲1̲,̲.̲,̲_̲",
                      "Ā,̄B̄,̄C̄,̄D̄,̄Ē,̄F̄,̄Ḡ,̄H̄,̄Ī,̄J̄,̄K̄,̄L̄,̄M̄,̄N̄,̄Ō,̄P̄,̄Q̄,̄R̄,̄S̄,̄T̄,̄Ū,̄V̄,̄W̄,̄X̄,̄Ȳ,̄Z̄,̄ā,̄b̄,̄c̄,̄d̄,̄ē,̄f̄,̄ḡ,̄h̄,̄ī,̄j̄,̄k̄,̄l̄,̄m̄,̄n̄,̄ō,̄p̄,̄q̄,̄r̄,̄s̄,̄t̄,̄ū,̄v̄,̄w̄,̄x̄,̄ȳ,̄z̄,̄0̄,̄9̄,̄8̄,̄7̄,̄6̄,̄5̄,̄4̄,̄3̄,̄2̄,̄1̄,̄.̄,̄_̄",
                      "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "@,♭,ḉ,ⓓ,℮,ƒ,ℊ,ⓗ,ⓘ,נ,ⓚ,ℓ,ⓜ,η,ø,℘,ⓠ,ⓡ,﹩,т,ⓤ,√,ω,ж,૪,ℨ,@,♭,ḉ,ⓓ,℮,ƒ,ℊ,ⓗ,ⓘ,נ,ⓚ,ℓ,ⓜ,η,ø,℘,ⓠ,ⓡ,﹩,т,ⓤ,√,ω,ж,૪,ℨ,0,➈,➑,➐,➅,➄,➃,➌,➁,➊,.,_",
                      "@,♭,¢,ⅾ,ε,ƒ,ℊ,ℌ,ї,נ,к,ℓ,м,п,ø,ρ,ⓠ,ґ,﹩,⊥,ü,√,ω,ϰ,૪,ℨ,@,♭,¢,ⅾ,ε,ƒ,ℊ,ℌ,ї,נ,к,ℓ,м,п,ø,ρ,ⓠ,ґ,﹩,⊥,ü,√,ω,ϰ,૪,ℨ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,♭,ḉ,∂,ℯ,ƒ,ℊ,ℌ,ї,ʝ,ḱ,ℓ,м,η,ø,℘,ⓠ,я,﹩,⊥,ц,ṽ,ω,ჯ,૪,ẕ,α,♭,ḉ,∂,ℯ,ƒ,ℊ,ℌ,ї,ʝ,ḱ,ℓ,м,η,ø,℘,ⓠ,я,﹩,⊥,ц,ṽ,ω,ჯ,૪,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "@,ß,¢,ḓ,℮,ƒ,ℊ,ℌ,ї,נ,ḱ,ʟ,м,п,◎,℘,ⓠ,я,﹩,т,ʊ,♥️,ẘ,✄,૪,ℨ,@,ß,¢,ḓ,℮,ƒ,ℊ,ℌ,ї,נ,ḱ,ʟ,м,п,◎,℘,ⓠ,я,﹩,т,ʊ,♥️,ẘ,✄,૪,ℨ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "@,ß,¢,ḓ,℮,ƒ,ℊ,н,ḯ,נ,к,ℓμ,п,☺️,℘,ⓠ,я,﹩,⊥,υ,ṽ,ω,✄,૪,ℨ,@,ß,¢,ḓ,℮,ƒ,ℊ,н,ḯ,נ,к,ℓμ,п,☺️,℘,ⓠ,я,﹩,⊥,υ,ṽ,ω,✄,૪,ℨ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "@,ß,ḉ,ḓ,є,ƒ,ℊ,ℌ,ї,נ,ḱ,ʟ,ღ,η,◎,℘,ⓠ,я,﹩,⊥,ʊ,♥️,ω,ϰ,૪,ẕ,@,ß,ḉ,ḓ,є,ƒ,ℊ,ℌ,ї,נ,ḱ,ʟ,ღ,η,◎,℘,ⓠ,я,﹩,⊥,ʊ,♥️,ω,ϰ,૪,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "@,ß,ḉ,∂,ε,ƒ,ℊ,ℌ,ї,נ,ḱ,ł,ღ,и,ø,℘,ⓠ,я,﹩,т,υ,√,ω,ჯ,૪,ẕ,@,ß,ḉ,∂,ε,ƒ,ℊ,ℌ,ї,נ,ḱ,ł,ღ,и,ø,℘,ⓠ,я,﹩,т,υ,√,ω,ჯ,૪,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,♭,¢,∂,ε,ƒ,❡,н,ḯ,ʝ,ḱ,ʟ,μ,п,ø,ρ,ⓠ,ґ,﹩,т,υ,ṽ,ω,ж,૪,ẕ,α,♭,¢,∂,ε,ƒ,❡,н,ḯ,ʝ,ḱ,ʟ,μ,п,ø,ρ,ⓠ,ґ,﹩,т,υ,ṽ,ω,ж,૪,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,♭,ḉ,∂,℮,ⓕ,ⓖ,н,ḯ,ʝ,ḱ,ℓ,м,п,ø,ⓟ,ⓠ,я,ⓢ,ⓣ,ⓤ,♥️,ⓦ,✄,ⓨ,ⓩ,α,♭,ḉ,∂,℮,ⓕ,ⓖ,н,ḯ,ʝ,ḱ,ℓ,м,п,ø,ⓟ,ⓠ,я,ⓢ,ⓣ,ⓤ,♥️,ⓦ,✄,ⓨ,ⓩ,0,➒,➑,➐,➏,➄,➍,➂,➁,➀,.,_",
                      "@,♭,ḉ,ḓ,є,ƒ,ⓖ,ℌ,ⓘ,נ,к,ⓛ,м,ⓝ,ø,℘,ⓠ,я,﹩,ⓣ,ʊ,√,ω,ჯ,૪,ⓩ,@,♭,ḉ,ḓ,є,ƒ,ⓖ,ℌ,ⓘ,נ,к,ⓛ,м,ⓝ,ø,℘,ⓠ,я,﹩,ⓣ,ʊ,√,ω,ჯ,૪,ⓩ,0,➒,➇,➆,➅,➄,➍,➌,➋,➀,.,_",
                      "α,♭,ⓒ,∂,є,ⓕ,ⓖ,ℌ,ḯ,ⓙ,ḱ,ł,ⓜ,и,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,⊥,ʊ,ⓥ,ⓦ,ж,ⓨ,ⓩ,α,♭,ⓒ,∂,є,ⓕ,ⓖ,ℌ,ḯ,ⓙ,ḱ,ł,ⓜ,и,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,⊥,ʊ,ⓥ,ⓦ,ж,ⓨ,ⓩ,0,➒,➑,➆,➅,➎,➍,➌,➁,➀,.,_",
                      "ⓐ,ß,ḉ,∂,℮,ⓕ,❡,ⓗ,ї,נ,ḱ,ł,μ,η,ø,ρ,ⓠ,я,﹩,ⓣ,ц,√,ⓦ,✖️,૪,ℨ,ⓐ,ß,ḉ,∂,℮,ⓕ,❡,ⓗ,ї,נ,ḱ,ł,μ,η,ø,ρ,ⓠ,я,﹩,ⓣ,ц,√,ⓦ,✖️,૪,ℨ,0,➒,➑,➐,➅,➄,➍,➂,➁,➊,.,_",
                      "α,ß,ⓒ,ⅾ,ℯ,ƒ,ℊ,ⓗ,ї,ʝ,к,ʟ,ⓜ,η,ⓞ,℘,ⓠ,ґ,﹩,т,υ,ⓥ,ⓦ,ж,ⓨ,ẕ,α,ß,ⓒ,ⅾ,ℯ,ƒ,ℊ,ⓗ,ї,ʝ,к,ʟ,ⓜ,η,ⓞ,℘,ⓠ,ґ,﹩,т,υ,ⓥ,ⓦ,ж,ⓨ,ẕ,0,➈,➇,➐,➅,➎,➍,➌,➁,➊,.,_",
                      "@,♭,ḉ,ⅾ,є,ⓕ,❡,н,ḯ,נ,ⓚ,ⓛ,м,ⓝ,☺️,ⓟ,ⓠ,я,ⓢ,⊥,υ,♥️,ẘ,ϰ,૪,ⓩ,@,♭,ḉ,ⅾ,є,ⓕ,❡,н,ḯ,נ,ⓚ,ⓛ,м,ⓝ,☺️,ⓟ,ⓠ,я,ⓢ,⊥,υ,♥️,ẘ,ϰ,૪,ⓩ,0,➒,➑,➆,➅,➄,➃,➂,➁,➀,.,_",
                      "ⓐ,♭,ḉ,ⅾ,є,ƒ,ℊ,ℌ,ḯ,ʝ,ḱ,ł,μ,η,ø,ⓟ,ⓠ,ґ,ⓢ,т,ⓤ,√,ⓦ,✖️,ⓨ,ẕ,ⓐ,♭,ḉ,ⅾ,є,ƒ,ℊ,ℌ,ḯ,ʝ,ḱ,ł,μ,η,ø,ⓟ,ⓠ,ґ,ⓢ,т,ⓤ,√,ⓦ,✖️,ⓨ,ẕ,0,➈,➇,➐,➅,➄,➃,➂,➁,➀,.,_",
                      "ձ,ъƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,ձ,ъƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,0,9,8,7,6,5,4,3,2,1,.,_",
                      "λ,ϐ,ς,d,ε,ғ,ϑ,ɢ,н,ι,ϳ,κ,l,ϻ,π,σ,ρ,φ,г,s,τ,υ,v,ш,ϰ,ψ,z,λ,ϐ,ς,d,ε,ғ,ϑ,ɢ,н,ι,ϳ,κ,l,ϻ,π,σ,ρ,φ,г,s,τ,υ,v,ш,ϰ,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "მ,ჩ,ƈძ,ε,բ,ց,հ,ἶ,ʝ,ƙ,l,ო,ղ,օ,ր,գ,ɾ,ʂ,է,մ,ν,ω,ჯ,ყ,z,მ,ჩ,ƈძ,ε,բ,ց,հ,ἶ,ʝ,ƙ,l,ო,ղ,օ,ր,գ,ɾ,ʂ,է,մ,ν,ω,ჯ,ყ,z,0,Գ,Ց,Դ,6,5,Վ,Յ,Զ,1,.,_",
                      "ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Λ,Б,Ͼ,Ð,Ξ,Ŧ,g,h,ł,j,К,Ł,m,Л,Ф,p,Ǫ,Я,s,t,u,v,Ш,Ж,Џ,z,Λ,Б,Ͼ,Ð,Ξ,Ŧ,g,h,ł,j,К,Ł,m,Л,Ф,p,Ǫ,Я,s,t,u,v,Ш,Ж,Џ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "λ,ß,Ȼ,ɖ,ε,ʃ,Ģ,ħ,ί,ĵ,κ,ι,ɱ,ɴ,Θ,ρ,ƣ,ર,Ș,τ,Ʋ,ν,ώ,Χ,ϓ,Հ,λ,ß,Ȼ,ɖ,ε,ʃ,Ģ,ħ,ί,ĵ,κ,ι,ɱ,ɴ,Θ,ρ,ƣ,ર,Ș,τ,Ʋ,ν,ώ,Χ,ϓ,Հ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ª,b,¢,Þ,È,F,૬,ɧ,Î,j,Κ,Ļ,м,η,◊,Ƿ,ƍ,r,S,⊥,µ,√,w,×,ý,z,ª,b,¢,Þ,È,F,૬,ɧ,Î,j,Κ,Ļ,м,η,◊,Ƿ,ƍ,r,S,⊥,µ,√,w,×,ý,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Թ,Յ,Շ,Ժ,ȝ,Բ,Գ,ɧ,ɿ,ʝ,ƙ,ʅ,ʍ,Ռ,Ծ,ρ,φ,Ր,Տ,Ե,Մ,ע,ա,Ճ,Վ,Հ,Թ,Յ,Շ,Ժ,ȝ,Բ,Գ,ɧ,ɿ,ʝ,ƙ,ʅ,ʍ,Ռ,Ծ,ρ,φ,Ր,Տ,Ե,Մ,ע,ա,Ճ,Վ,Հ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Λ,Ϧ,ㄈ,Ð,Ɛ,F,Ɠ,н,ɪ,ﾌ,Қ,Ł,௱,Л,Ø,þ,Ҩ,尺,ら,Ť,Ц,Ɣ,Ɯ,χ,Ϥ,Ẕ,Λ,Ϧ,ㄈ,Ð,Ɛ,F,Ɠ,н,ɪ,ﾌ,Қ,Ł,௱,Л,Ø,þ,Ҩ,尺,ら,Ť,Ц,Ɣ,Ɯ,χ,Ϥ,Ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Ǟ,в,ट,D,ę,բ,g,৸,i,j,κ,l,ɱ,П,Φ,Р,q,Я,s,Ʈ,Ц,v,Щ,ж,ყ,ւ,Ǟ,в,ट,D,ę,բ,g,৸,i,j,κ,l,ɱ,П,Φ,Р,q,Я,s,Ʈ,Ц,v,Щ,ж,ყ,ւ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Æ,þ,©,Ð,E,F,ζ,Ħ,Ї,¿,ズ,ᄂ,M,Ñ,Θ,Ƿ,Ø,Ґ,Š,τ,υ,¥,w,χ,y,շ,Æ,þ,©,Ð,E,F,ζ,Ħ,Ї,¿,ズ,ᄂ,M,Ñ,Θ,Ƿ,Ø,Ґ,Š,τ,υ,¥,w,χ,y,շ,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ª,ß,¢,ð,€,f,g,h,¡,j,k,|,m,ñ,¤,Þ,q,®,$,t,µ,v,w,×,ÿ,z,ª,ß,¢,ð,€,f,g,h,¡,j,k,|,m,ñ,¤,Þ,q,®,$,t,µ,v,w,×,ÿ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⒪,⑼,⑻,⑺,⑹,⑸,⑷,⑶,⑵,⑴,.,_",
                      "ɑ,ʙ,c,ᴅ,є,ɻ,მ,ʜ,ι,ɿ,ĸ,г,w,и,o,ƅϭ,ʁ,ƨ,⊥,n,ʌ,ʍ,x,⑃,z,ɑ,ʙ,c,ᴅ,є,ɻ,მ,ʜ,ι,ɿ,ĸ,г,w,и,o,ƅϭ,ʁ,ƨ,⊥,n,ʌ,ʍ,x,⑃,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "4,8,C,D,3,F,9,H,!,J,K,1,M,N,0,P,Q,R,5,7,U,V,W,X,Y,2,4,8,C,D,3,F,9,H,!,J,K,1,M,N,0,P,Q,R,5,7,U,V,W,X,Y,2,0,9,8,7,6,5,4,3,2,1,.,_",
                      "Λ,ßƇ,D,Ɛ,F,Ɠ,Ĥ,Ī,Ĵ,Ҡ,Ŀ,M,И,♡,Ṗ,Ҩ,Ŕ,S,Ƭ,Ʊ,Ѵ,Ѡ,Ӿ,Y,Z,Λ,ßƇ,D,Ɛ,F,Ɠ,Ĥ,Ī,Ĵ,Ҡ,Ŀ,M,И,♡,Ṗ,Ҩ,Ŕ,S,Ƭ,Ʊ,Ѵ,Ѡ,Ӿ,Y,Z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "α,в,c,ɔ,ε,ғ,ɢ,н,ı,נ,κ,ʟ,м,п,σ,ρ,ǫ,я,ƨ,т,υ,ν,ш,х,ч,z,α,в,c,ɔ,ε,ғ,ɢ,н,ı,נ,κ,ʟ,м,п,σ,ρ,ǫ,я,ƨ,т,υ,ν,ш,х,ч,z,0,9,8,7,6,5,4,3,2,1,.,_",
                      "【a】,【b】,【c】,【d】,【e】,【f】,【g】,【h】,【i】,【j】,【k】,【l】,【m】,【n】,【o】,【p】,【q】,【r】,【s】,【t】,【u】,【v】,【w】,【x】,【y】,【z】,【a】,【b】,【c】,【d】,【e】,【f】,【g】,【h】,【i】,【j】,【k】,【l】,【m】,【n】,【o】,【p】,【q】,【r】,【s】,【t】,【u】,【v】,【w】,【x】,【y】,【z】,【0】,【9】,【8】,【7】,【6】,【5】,【4】,【3】,【2】,【1】,.,_",
                      "[̲̲̅̅a̲̅,̲̅b̲̲̅,̅c̲̅,̲̅d̲̲̅,̅e̲̲̅,̅f̲̲̅,̅g̲̅,̲̅h̲̲̅,̅i̲̲̅,̅j̲̲̅,̅k̲̅,̲̅l̲̲̅,̅m̲̅,̲̅n̲̅,̲̅o̲̲̅,̅p̲̅,̲̅q̲̅,̲̅r̲̲̅,̅s̲̅,̲̅t̲̲̅,̅u̲̅,̲̅v̲̅,̲̅w̲̅,̲̅x̲̅,̲̅y̲̅,̲̅z̲̅,[̲̲̅̅a̲̅,̲̅b̲̲̅,̅c̲̅,̲̅d̲̲̅,̅e̲̲̅,̅f̲̲̅,̅g̲̅,̲̅h̲̲̅,̅i̲̲̅,̅j̲̲̅,̅k̲̅,̲̅l̲̲̅,̅m̲̅,̲̅n̲̅,̲̅o̲̲̅,̅p̲̅,̲̅q̲̅,̲̅r̲̲̅,̅s̲̅,̲̅t̲̲̅,̅u̲̅,̲̅v̲̅,̲̅w̲̅,̲̅x̲̅,̲̅y̲̅,̲̅z̲̅,̲̅0̲̅,̲̅9̲̲̅,̅8̲̅,̲̅7̲̅,̲̅6̲̅,̲̅5̲̅,̲̅4̲̅,̲̅3̲̲̅,̅2̲̲̅,̅1̲̲̅̅],.,_",
                      "[̺͆a̺͆͆,̺b̺͆͆,̺c̺͆,̺͆d̺͆,̺͆e̺͆,̺͆f̺͆͆,̺g̺͆,̺͆h̺͆,̺͆i̺͆,̺͆j̺͆,̺͆k̺͆,̺l̺͆͆,̺m̺͆͆,̺n̺͆͆,̺o̺͆,̺͆p̺͆͆,̺q̺͆͆,̺r̺͆͆,̺s̺͆͆,̺t̺͆͆,̺u̺͆͆,̺v̺͆͆,̺w̺͆,̺͆x̺͆,̺͆y̺͆,̺͆z̺,[̺͆a̺͆͆,̺b̺͆͆,̺c̺͆,̺͆d̺͆,̺͆e̺͆,̺͆f̺͆͆,̺g̺͆,̺͆h̺͆,̺͆i̺͆,̺͆j̺͆,̺͆k̺͆,̺l̺͆͆,̺m̺͆͆,̺n̺͆͆,̺o̺͆,̺͆p̺͆͆,̺q̺͆͆,̺r̺͆͆,̺s̺͆͆,̺t̺͆͆,̺u̺͆͆,̺v̺͆͆,̺w̺͆,̺͆x̺͆,̺͆y̺͆,̺͆z̺,̺͆͆0̺͆,̺͆9̺͆,̺͆8̺̺͆͆7̺͆,̺͆6̺͆,̺͆5̺͆,̺͆4̺͆,̺͆3̺͆,̺͆2̺͆,̺͆1̺͆],.,_",
                      "̛̭̰̃ã̛̰̭,̛̭̰̃b̛̰̭̃̃,̛̭̰c̛̛̰̭̃̃,̭̰d̛̰̭̃,̛̭̰̃ḛ̛̭̃̃,̛̭̰f̛̰̭̃̃,̛̭̰g̛̰̭̃̃,̛̭̰h̛̰̭̃,̛̭̰̃ḭ̛̛̭̃̃,̭̰j̛̰̭̃̃,̛̭̰k̛̰̭̃̃,̛̭̰l̛̰̭,̛̭̰̃m̛̰̭̃̃,̛̭̰ñ̛̛̰̭̃,̭̰ỡ̰̭̃,̛̭̰p̛̰̭̃,̛̭̰̃q̛̰̭̃̃,̛̭̰r̛̛̰̭̃̃,̭̰s̛̰̭,̛̭̰̃̃t̛̰̭̃,̛̭̰̃ữ̰̭̃,̛̭̰ṽ̛̰̭̃,̛̭̰w̛̛̰̭̃̃,̭̰x̛̰̭̃,̛̭̰̃ỹ̛̰̭̃,̛̭̰z̛̰̭̃̃,̛̛̭̰ã̛̰̭,̛̭̰̃b̛̰̭̃̃,̛̭̰c̛̛̰̭̃̃,̭̰d̛̰̭̃,̛̭̰̃ḛ̛̭̃̃,̛̭̰f̛̰̭̃̃,̛̭̰g̛̰̭̃̃,̛̭̰h̛̰̭̃,̛̭̰̃ḭ̛̛̭̃̃,̭̰j̛̰̭̃̃,̛̭̰k̛̰̭̃̃,̛̭̰l̛̰̭,̛̭̰̃m̛̰̭̃̃,̛̭̰ñ̛̛̰̭̃,̭̰ỡ̰̭̃,̛̭̰p̛̰̭̃,̛̭̰̃q̛̰̭̃̃,̛̭̰r̛̛̰̭̃̃,̭̰s̛̰̭,̛̭̰̃̃t̛̰̭̃,̛̭̰̃ữ̰̭̃,̛̭̰ṽ̛̰̭̃,̛̭̰w̛̛̰̭̃̃,̭̰x̛̰̭̃,̛̭̰̃ỹ̛̰̭̃,̛̭̰z̛̰̭̃̃,̛̭̰0̛̛̰̭̃̃,̭̰9̛̰̭̃̃,̛̭̰8̛̛̰̭̃̃,̭̰7̛̰̭̃̃,̛̭̰6̛̰̭̃̃,̛̭̰5̛̰̭̃,̛̭̰̃4̛̰̭̃,̛̭̰̃3̛̰̭̃̃,̛̭̰2̛̰̭̃̃,̛̭̰1̛̰̭̃,.,_",
                      "a,ะb,ะc,ะd,ะe,ะf,ะg,ะh,ะi,ะj,ะk,ะl,ะm,ะn,ะo,ะp,ะq,ะr,ะs,ะt,ะu,ะv,ะw,ะx,ะy,ะz,a,ะb,ะc,ะd,ะe,ะf,ะg,ะh,ะi,ะj,ะk,ะl,ะm,ะn,ะo,ะp,ะq,ะr,ะs,ะt,ะu,ะv,ะw,ะx,ะy,ะz,ะ0,ะ9,ะ8,ะ7,ะ6,ะ5,ะ4,ะ3,ะ2,ะ1ะ,.,_",
                      "̑ȃ,̑b̑,̑c̑,̑d̑,̑ȇ,̑f̑,̑g̑,̑h̑,̑ȋ,̑j̑,̑k̑,̑l̑,̑m̑,̑n̑,̑ȏ,̑p̑,̑q̑,̑ȓ,̑s̑,̑t̑,̑ȗ,̑v̑,̑w̑,̑x̑,̑y̑,̑z̑,̑ȃ,̑b̑,̑c̑,̑d̑,̑ȇ,̑f̑,̑g̑,̑h̑,̑ȋ,̑j̑,̑k̑,̑l̑,̑m̑,̑n̑,̑ȏ,̑p̑,̑q̑,̑ȓ,̑s̑,̑t̑,̑ȗ,̑v̑,̑w̑,̑x̑,̑y̑,̑z̑,̑0̑,̑9̑,̑8̑,̑7̑,̑6̑,̑5̑,̑4̑,̑3̑,̑2̑,̑1̑,.,_",
                      "~a,͜͝b,͜͝c,͜͝d,͜͝e,͜͝f,͜͝g,͜͝h,͜͝i,͜͝j,͜͝k,͜͝l,͜͝m,͜͝n,͜͝o,͜͝p,͜͝q,͜͝r,͜͝s,͜͝t,͜͝u,͜͝v,͜͝w,͜͝x,͜͝y,͜͝z,~a,͜͝b,͜͝c,͜͝d,͜͝e,͜͝f,͜͝g,͜͝h,͜͝i,͜͝j,͜͝k,͜͝l,͜͝m,͜͝n,͜͝o,͜͝p,͜͝q,͜͝r,͜͝s,͜͝t,͜͝u,͜͝v,͜͝w,͜͝x,͜͝y,͜͝z,͜͝0,͜͝9,͜͝8,͜͝7,͜͝6,͜͝5,͜͝4,͜͝3,͜͝2͜,͝1͜͝~,.,_",
                      "̤̈ä̤,̤̈b̤̈,̤̈c̤̈̈,̤d̤̈,̤̈ë̤,̤̈f̤̈,̤̈g̤̈̈,̤ḧ̤̈,̤ï̤̈,̤j̤̈,̤̈k̤̈̈,̤l̤̈,̤̈m̤̈,̤̈n̤̈,̤̈ö̤,̤̈p̤̈,̤̈q̤̈,̤̈r̤̈,̤̈s̤̈̈,̤ẗ̤̈,̤ṳ̈,̤̈v̤̈,̤̈ẅ̤,̤̈ẍ̤,̤̈ÿ̤,̤̈z̤̈,̤̈ä̤,̤̈b̤̈,̤̈c̤̈̈,̤d̤̈,̤̈ë̤,̤̈f̤̈,̤̈g̤̈̈,̤ḧ̤̈,̤ï̤̈,̤j̤̈,̤̈k̤̈̈,̤l̤̈,̤̈m̤̈,̤̈n̤̈,̤̈ö̤,̤̈p̤̈,̤̈q̤̈,̤̈r̤̈,̤̈s̤̈̈,̤ẗ̤̈,̤ṳ̈,̤̈v̤̈,̤̈ẅ̤,̤̈ẍ̤,̤̈ÿ̤,̤̈z̤̈,̤̈0̤̈,̤̈9̤̈,̤̈8̤̈,̤̈7̤̈,̤̈6̤̈,̤̈5̤̈,̤̈4̤̈,̤̈3̤̈,̤̈2̤̈̈,̤1̤̈,.,_",
                      "≋̮̑ȃ̮,̮̑b̮̑,̮̑c̮̑,̮̑d̮̑,̮̑ȇ̮,̮̑f̮̑,̮̑g̮̑,̮̑ḫ̑,̮̑ȋ̮,̮̑j̮̑,̮̑k̮̑,̮̑l̮̑,̮̑m̮̑,̮̑n̮̑,̮̑ȏ̮,̮̑p̮̑,̮̑q̮̑,̮̑r̮,̮̑̑s̮,̮̑̑t̮,̮̑̑u̮,̮̑̑v̮̑,̮̑w̮̑,̮̑x̮̑,̮̑y̮̑,̮̑z̮̑,≋̮̑ȃ̮,̮̑b̮̑,̮̑c̮̑,̮̑d̮̑,̮̑ȇ̮,̮̑f̮̑,̮̑g̮̑,̮̑ḫ̑,̮̑ȋ̮,̮̑j̮̑,̮̑k̮̑,̮̑l̮̑,̮̑m̮̑,̮̑n̮̑,̮̑ȏ̮,̮̑p̮̑,̮̑q̮̑,̮̑r̮,̮̑̑s̮,̮̑̑t̮,̮̑̑u̮,̮̑̑v̮̑,̮̑w̮̑,̮̑x̮̑,̮̑y̮̑,̮̑z̮̑,̮̑0̮̑,̮̑9̮̑,̮̑8̮̑,̮̑7̮̑,̮̑6̮̑,̮̑5̮̑,̮̑4̮̑,̮̑3̮̑,̮̑2̮̑,̮̑1̮̑≋,.,_",
                      "a̮,̮b̮̮,c̮̮,d̮̮,e̮̮,f̮̮,g̮̮,ḫ̮,i̮,j̮̮,k̮̮,l̮,̮m̮,̮n̮̮,o̮,̮p̮̮,q̮̮,r̮̮,s̮,̮t̮̮,u̮̮,v̮̮,w̮̮,x̮̮,y̮̮,z̮̮,a̮,̮b̮̮,c̮̮,d̮̮,e̮̮,f̮̮,g̮̮,ḫ̮i,̮̮,j̮̮,k̮̮,l̮,̮m̮,̮n̮̮,o̮,̮p̮̮,q̮̮,r̮̮,s̮,̮t̮̮,u̮̮,v̮̮,w̮̮,x̮̮,y̮̮,z̮̮,0̮̮,9̮̮,8̮̮,7̮̮,6̮̮,5̮̮,4̮̮,3̮̮,2̮̮,1̮,.,_",
                      "A̲,̲B̲,̲C̲,̲D̲,̲E̲,̲F̲,̲G̲,̲H̲,̲I̲,̲J̲,̲K̲,̲L̲,̲M̲,̲N̲,̲O̲,̲P̲,̲Q̲,̲R̲,̲S̲,̲T̲,̲U̲,̲V̲,̲W̲,̲X̲,̲Y̲,̲Z̲,̲a̲,̲b̲,̲c̲,̲d̲,̲e̲,̲f̲,̲g̲,̲h̲,̲i̲,̲j̲,̲k̲,̲l̲,̲m̲,̲n̲,̲o̲,̲p̲,̲q̲,̲r̲,̲s̲,̲t̲,̲u̲,̲v̲,̲w̲,̲x̲,̲y̲,̲z̲,̲0̲,̲9̲,̲8̲,̲7̲,̲6̲,̲5̲,̲4̲,̲3̲,̲2̲,̲1̲,̲.̲,̲_̲",
                      "Â,ß,Ĉ,Ð,Є,Ŧ,Ǥ,Ħ,Ī,ʖ,Қ,Ŀ,♏,И,Ø,P,Ҩ,R,$,ƚ,Ц,V,Щ,X,￥,Ẕ,Â,ß,Ĉ,Ð,Є,Ŧ,Ǥ,Ħ,Ī,ʖ,Қ,Ŀ,♏,И,Ø,P,Ҩ,R,$,ƚ,Ц,V,Щ,X,￥,Ẕ,0,9,8,7,6,5,4,3,2,1,.,_"
                    }
                    local result = {}
                    i = 0
                    do
                      do
                        for i = 1, #fonts do
                          i = i + 1
                          local tar_font = fonts[i]:split(",")
                          local text = TextToBeauty
                          local text = text:gsub("A", tar_font[1])
                          local text = text:gsub("B", tar_font[2])
                          local text = text:gsub("C", tar_font[3])
                          local text = text:gsub("D", tar_font[4])
                          local text = text:gsub("E", tar_font[5])
                          local text = text:gsub("F", tar_font[6])
                          local text = text:gsub("G", tar_font[7])
                          local text = text:gsub("H", tar_font[8])
                          local text = text:gsub("I", tar_font[9])
                          local text = text:gsub("J", tar_font[10])
                          local text = text:gsub("K", tar_font[11])
                          local text = text:gsub("L", tar_font[12])
                          local text = text:gsub("M", tar_font[13])
                          local text = text:gsub("N", tar_font[14])
                          local text = text:gsub("O", tar_font[15])
                          local text = text:gsub("P", tar_font[16])
                          local text = text:gsub("Q", tar_font[17])
                          local text = text:gsub("R", tar_font[18])
                          local text = text:gsub("S", tar_font[18])
                          local text = text:gsub("T", tar_font[20])
                          local text = text:gsub("U", tar_font[21])
                          local text = text:gsub("V", tar_font[22])
                          local text = text:gsub("W", tar_font[23])
                          local text = text:gsub("X", tar_font[24])
                          local text = text:gsub("Y", tar_font[25])
                          local text = text:gsub("Z", tar_font[26])
                          local text = text:gsub("a", tar_font[27])
                          local text = text:gsub("b", tar_font[28])
                          local text = text:gsub("c", tar_font[29])
                          local text = text:gsub("d", tar_font[30])
                          local text = text:gsub("e", tar_font[31])
                          local text = text:gsub("f", tar_font[32])
                          local text = text:gsub("g", tar_font[33])
                          local text = text:gsub("h", tar_font[34])
                          local text = text:gsub("i", tar_font[35])
                          local text = text:gsub("j", tar_font[36])
                          local text = text:gsub("k", tar_font[37])
                          local text = text:gsub("l", tar_font[38])
                          local text = text:gsub("m", tar_font[39])
                          local text = text:gsub("n", tar_font[40])
                          local text = text:gsub("o", tar_font[41])
                          local text = text:gsub("p", tar_font[42])
                          local text = text:gsub("q", tar_font[43])
                          local text = text:gsub("r", tar_font[44])
                          local text = text:gsub("s", tar_font[45])
                          local text = text:gsub("t", tar_font[46])
                          local text = text:gsub("u", tar_font[47])
                          local text = text:gsub("v", tar_font[48])
                          local text = text:gsub("w", tar_font[49])
                          local text = text:gsub("x", tar_font[50])
                          local text = text:gsub("y", tar_font[51])
                          local text = text:gsub("z", tar_font[52])
                          local text = text:gsub("0", tar_font[53])
                          local text = text:gsub("9", tar_font[54])
                          local text = text:gsub("8", tar_font[55])
                          local text = text:gsub("7", tar_font[56])
                          local text = text:gsub("6", tar_font[57])
                          local text = text:gsub("5", tar_font[58])
                          local text = text:gsub("4", tar_font[59])
                          local text = text:gsub("3", tar_font[60])
                          local text = text:gsub("2", tar_font[61])
                          local text = text:gsub("1", tar_font[62])
                          table.insert(result, text)
                        end
                      end
                    end
                    local result_text = "• کلمه مورد نظر شما : " .. TextToBeauty .. "\nطراحی شده با " .. tostring(#fonts) .. " فونت !\n\n"
                    do
                      do
                        for i = 1, #result do
                          result_text = "" .. result_text .. i .. " - " .. result[i] .. [[


]]
                        end
                      end
                    end
                    sendText(chat_id, msg_id, result_text, "html")
                  end
                end
                if text == "mydel" or text == "پاکسازی پیام های من" then
                  sendText(TD_ID, 0, "delall " .. chat_id .. " " .. msg.from.id, "md")
                end
                if string.lower(text) == "lock poll" or text == "t" then
                  sendVideonote(chat_id, redis:get("Welcome:videonote" .. chat_id), 0, "", "html")
                end
                if text == "buy" or text == "خرید" then
                  local nerkh = redis:get("ner") or "نرخی برای ربات تنظیم نشده است"
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• مدیرکل",
                        url = "https://t.me/" .. UserSudo_1
                      }
                    },
                    {
                      {
                        text = "• کانال ربات",
                        url = "https://t.me/" .. chjoi
                      }
                    },
                    {
                      {
                        text = "• نویسنده سورس",
                        url = "https://t.me/Developer4"
                      }
                    }
                  }
                  Send(chat_id, 0, "نرخ ربات " .. nerkh .. "", keyboard, "html")
                end
              end
            end
          end
          if msg.callback_query then
            local Leader = msg.callback_query
            LeaderCode = Leader.data
            msg.user_first = Leader.from.first_name
            chat_id = "-" .. Leader.data:match("(%d+)")
            user_id = Leader.data:match("(%d+)")
            msg.inline_id = Leader.message.message_id
            msg.chat_id = Leader.message.chat.id
            sender_id = Leader.from.id
            GpName = Leader.message.chat.title
            if not is_mod(chat_id, Leader.from.id) then
            elseif Leader.message.reply_to_message and (Leader.message.reply_to_message.from.id or Leader.from.id) ~= Leader.from.id then
              Alert(Leader.id, "• این پنل از شما فرمان نمیگیرد !", true)
            else
              if redis:get("cheaktimepanel:" .. chat_id .. Leader.from.id) then
                Alert(Leader.id, "سریع لمس میکنید،\nلطفا آهسته تر!", true)
              else
                redis:setex("cheaktimepanel:" .. chat_id .. Leader.from.id, 1, true)
              end
              if LeaderCode == "LeaveToGp:" .. chat_id .. "" then
                sendText(TD_ID, 0, "leave " .. chat_id .. "", "html")
                Edit(msg.chat_id, msg.inline_id, "باموفقیت ربات گروه  را ترک کرد", nil, "html")
                Leave(chat_id)
                remRedis(chat_id)
              end
              if LeaderCode == "AddToGp:" .. chat_id .. "" then
                if getChatMember(chat_id, TD_ID).result and getChatMember(chat_id, TD_ID).result.can_invite_users then
                  sendText(TD_ID, 0, "join " .. chat_id .. " " .. sender_id, "html")
                  Alert(Leader.id, "با موفقیت به گروه افزوده شدید", true)
                else
                  if getChatMember(chat_id, BotHelper).result and getChatMember(chat_id, BotHelper).result.can_invite_users then
                    exportChatInviteLink(chat_id)
                    if getChat(chat_id).result.invite_link then
                      GpLink = getChat(chat_id).result.invite_link
                    else
                      GpLink = "---"
                    end
                  else
                    GpLink = "دسترسی دریافت لینک را ندارم !"
                  end
                  Alert(Leader.id, "عملیات شکست خورد ربات پاکسازی دسترسی افزودن عضو را ندارد یا در گروه حضور ندارد\n لینک به پی وی شما ارسال گردید", true)
                  sendText(sender_id, 0, "" .. GpLink .. "", "html")
                end
              end
              if LeaderCode == "ChatsPage:" .. string.sub(chat_id, 2) then
                local page = tonumber(string.sub(chat_id, 2))
                local keyboard = {}
                keyboard.inline_keyboard = {}
                local list = redis:smembers("group:")
                local pages = math.floor(#list / 10)
                if 0 < #list % 10 then
                  pages = pages + 1
                end
                pages = pages - 1
                if #list == 0 then
                  tt = "لیست گروهها مدیریت  خالی میباشد"
                else
                  tt = "به بخش مدیریت گروه ها خوش امدید"
                  do
                    do
                      for i, i in pairs(list) do
                        if i > page * 10 and i < page * 10 + 11 then
                          local GroupsName = redis:get("StatsGpByName" .. i)
                          if GroupsName then
                            temp = {
                              {
                                {
                                  text = GroupsName,
                                  callback_data = "panel:" .. i
                                }
                              }
                            }
                          else
                            temp = {
                              {
                                {
                                  text = i,
                                  callback_data = "panel:" .. i
                                },
                                {
                                  text = "خروج",
                                  callback_data = "LeaveToGp:" .. i
                                }
                              }
                            }
                          end
                          do
                            for i, i in pairs(temp) do
                              table.insert(keyboard.inline_keyboard, i)
                            end
                          end
                        end
                      end
                    end
                  end
                  if page == 0 then
                    if pages > 0 then
                      temp = {
                        {
                          {
                            text = "► صفحه بعد",
                            callback_data = "ChatsPage:1"
                          }
                        }
                      }
                      do
                        for i, i in pairs(temp) do
                          table.insert(keyboard.inline_keyboard, i)
                        end
                      end
                    end
                  elseif page == pages then
                    temp = {
                      {
                        {
                          text = "برگشت ◄",
                          callback_data = "ChatsPage:" .. page - 1
                        }
                      }
                    }
                    do
                      for i, i in pairs(temp) do
                        table.insert(keyboard.inline_keyboard, i)
                      end
                    end
                  else
                    temp = {
                      {
                        {
                          text = "برگشت ◄",
                          callback_data = "ChatsPage:" .. page - 1
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "ChatsPage:" .. page + 1
                        }
                      }
                    }
                    do
                      for i, i in pairs(temp) do
                        table.insert(keyboard.inline_keyboard, i)
                      end
                    end
                  end
                  temp = {
                    {
                      {
                        text = "↫ بستن لیست گروه ها",
                        callback_data = "Exit:-1"
                      }
                    }
                  }
                  do
                    for i, i in pairs(temp) do
                      table.insert(keyboard.inline_keyboard, i)
                    end
                  end
                end
                Edit(msg.chat_id, msg.inline_id, tt, keyboard, "html")
              end
              if LeaderCode == "panel:" .. chat_id .. "" then
                if is_Fullsudo(sender_id) then
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• تنظیمات",
                        callback_data = "ehsanleader:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "• بخش پاکسازی",
                        callback_data = "cclliif:" .. chat_id
                      },
                      {
                        text = "• اطلاعات گروه",
                        callback_data = "groupinfo:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "• واردشدن",
                        callback_data = "AddToGp:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "• خروج ربات",
                        callback_data = "LeaveToGp:" .. chat_id
                      },
                      {
                        text = "• شارژ گروه",
                        callback_data = "ChargeGp:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "• پنل گروه ها",
                        callback_data = "ChatsPage:0"
                      }
                    },
                    {
                      {
                        text = "• نویسنده سورس",
                        url = "https://t.me/Developer4"
                      }
                    },
                    {
                      {
                        text = "• بستن",
                        callback_data = "Exit:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, "• لطفاً بخش مورد نظر خود را انتخاب کنید :", keyboard, "html")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• تنظیمات",
                        callback_data = "ehsanleader:" .. chat_id
                      },
                      {
                        text = "• اطلاعات گروه",
                        callback_data = "groupinfo:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "• راهنمای ربات",
                        callback_data = "help:" .. chat_id
                      },
                      {
                        text = "• بخش پاکسازی",
                        callback_data = "cclliif:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "• نویسنده سورس",
                        url = "https://t.me/Developer4"
                      }
                    },
                    {
                      {
                        text = "• بستن فهرست",
                        callback_data = "Exit:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, "• لطفاً بخش مورد نظر خود را انتخاب کنید :", keyboard, "html")
                end
              end
              if LeaderCode == "ehsanleader:" .. chat_id .. "" then
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• حالت های گروه",
                      callback_data = "page_a:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• قفل های اصلی",
                      callback_data = "Pageone:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• قفل های رسانه",
                      callback_data = "settings_a:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• دسترسی مدیران",
                      callback_data = "management:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "panel:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "• لطفاً بخش مورد نظر خود را انتخاب کنید :", keyboard, "md")
              end
              if LeaderCode == "page_a:" .. chat_id and ModAccess2(Leader, chat_id, Leader.from.id) and settingsacsuser(Leader, chat_id, Leader.from.id) then
                setting1(msg, chat_id)
              end
              if LeaderCode == "page_b:" .. chat_id and ModAccess2(Leader, chat_id, Leader.from.id) and settingsacsuser(Leader, chat_id, Leader.from.id) then
                setting2(msg, chat_id)
              end
              if LeaderCode == "Pageone:" .. chat_id and ModAccess1(Leader, chat_id, Leader.from.id) and locksacsuser(Leader, chat_id, Leader.from.id) then
                Page1(msg, chat_id)
              end
              if LeaderCode == "AccessGp:" .. chat_id then
                ChatPermissions(msg, chat_id)
              end
              if LeaderCode == "Pagetow:" .. chat_id then
                Page2(msg, chat_id)
              end
              if LeaderCode == "Pagetree:" .. chat_id then
                Page3(msg, chat_id)
              end
              if LeaderCode == "Pagefour:" .. chat_id and ModAccess1(Leader, chat_id, Leader.from.id) and locksacsuser(Leader, chat_id, Leader.from.id) then
                Page4(msg, chat_id)
              end
              if LeaderCode == "settings_a:" .. chat_id and ModAccess1(Leader, chat_id, Leader.from.id) and locksacsuser(Leader, chat_id, Leader.from.id) then
                Page5(msg, chat_id)
              end
              if LeaderCode == "PageCAPTOW:" .. chat_id then
                Page6(msg, chat_id)
              end
              if LeaderCode == "PageCAPTREE:" .. chat_id then
                Page7(msg, chat_id)
              end
              if LeaderCode == "management:" .. chat_id then
                ModAccess(msg, chat_id)
              end
              if LeaderCode == "autolock:" .. chat_id then
                if redis:get("AutoLock:" .. chat_id) then
                  redis:del("AutoLock:" .. chat_id)
                  Alert(Leader.id, " قفل خودکار غیرفعال شد")
                else
                  redis:set("AutoLock:" .. chat_id, true)
                  Alert(Leader.id, " قفل خودکار فعال شد")
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "forceadd:" .. chat_id then
                if redis:get("forceadd" .. chat_id) then
                  redis:del("forceadd" .. chat_id)
                  redis:del("Force:Pm:" .. chat_id)
                  redis:del("Force:Max:" .. chat_id)
                  Alert(Leader.id, " وضعیت اداجباری غیرفعال شد ")
                else
                  redis:set("forceadd" .. chat_id, true)
                  Alert(Leader.id, "وضعیت اداجباری فعال شد")
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "delbotmsg:" .. chat_id then
                if redis:get("DelBotMsg:" .. chat_id) then
                  redis:del("DelBotMsg:" .. chat_id)
                  Alert(Leader.id, " وضعیت پاکسازی خودکار غیرفعال شد ")
                else
                  redis:set("DelBotMsg:" .. chat_id, true)
                  Alert(Leader.id, "وضعیت پاکسازی خودکار فعال شد")
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "delbotmsggg:" .. chat_id then
                if redis:get("cbmon" .. chat_id) then
                  redis:del("cbmon" .. chat_id)
                  Alert(Leader.id, " وضعیت پاکسازی خودکار غیرفعال شد ")
                else
                  redis:set("cbmon" .. chat_id, true)
                  Alert(Leader.id, "وضعیت پاکسازی خودکار فعال شد")
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "forcestatus:" .. chat_id then
                if redis:get("force_NewUser" .. chat_id) then
                  redis:set("force_NewUser" .. chat_id, true)
                  forcestatus = "کاربران جدید"
                  Alert(Leader.id, "وضعیت اداجباری بر روی " .. forcestatus .. " قرار گرفت")
                else
                  redis:del("force_NewUser" .. chat_id)
                  forcestatus = "همه"
                  Alert(Leader.id, "وضعیت اداجباری بر روی " .. forcestatus .. " قرار گرفت")
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "delbotmsgup:" .. chat_id then
                if tonumber(DelBotMsg_Time) == 200 then
                  Alert(Leader.id, "حداکثر مقدار 200")
                else
                  DelBotMsg_Time = redis:get("DelBotMsg:Time:" .. chat_id) or 60
                  DelBotMsg_Time = tonumber(DelBotMsg_Time) + 1
                  Alert(Leader.id, DelBotMsg_Time)
                  redis:set("DelBotMsg:Time:" .. chat_id, DelBotMsg_Time)
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "delbotmsgdown:" .. chat_id then
                if tonumber(DelBotMsg_Time) == 60 then
                  Alert(Leader.id, "حداقل مقدار  60", true)
                else
                  DelBotMsg_Time = redis:get("DelBotMsg:Time:" .. chat_id) or 60
                  DelBotMsg_Time = tonumber(DelBotMsg_Time) - 1
                  Alert(Leader.id, DelBotMsg_Time)
                  redis:set("DelBotMsg:Time:" .. chat_id, DelBotMsg_Time)
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "delbotmsguppp:" .. chat_id then
                if tonumber(DelBotMsg_Timeee) == 80 then
                  Alert(Leader.id, "حداکثر مقدار 80")
                else
                  DelBotMsg_Timeee = redis:get("cbmtime:" .. chat_id) or 10
                  DelBotMsg_Timeee = tonumber(DelBotMsg_Timeee) + 1
                  Alert(Leader.id, DelBotMsg_Timeee)
                  redis:set("cbmtime:" .. chat_id, DelBotMsg_Timeee)
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "delbotmsgdownnn:" .. chat_id then
                if tonumber(DelBotMsg_Timeee) == 10 then
                  Alert(Leader.id, "حداقل مقدار  10", true)
                else
                  DelBotMsg_Timeee = redis:get("cbmtime:" .. chat_id) or 10
                  DelBotMsg_Timeee = tonumber(DelBotMsg_Timeee) - 1
                  Alert(Leader.id, DelBotMsg_Timeee)
                  redis:set("cbmtime:" .. chat_id, DelBotMsg_Timeee)
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "forcemaxup:" .. chat_id then
                if tonumber(Force_Max) == 200 then
                  Alert(Leader.id, "حداکثر مقدار 200")
                else
                  Force_Max = redis:get("Force:Max:" .. chat_id) or 1
                  Force_Max = tonumber(Force_Max) + 1
                  Alert(Leader.id, Force_Max)
                  redis:set("Force:Max:" .. chat_id, Force_Max)
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "forcemaxdown:" .. chat_id then
                if tonumber(Force_Max) == 1 then
                  Alert(Leader.id, "حداقل مقدار 1", true)
                else
                  Force_Max = redis:get("Force:Max:" .. chat_id) or 1
                  Force_Max = tonumber(Force_Max) - 1
                  Alert(Leader.id, Force_Max)
                  redis:set("Force:Max:" .. chat_id, Force_Max)
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "forcemaxwarn:" .. chat_id then
                if tonumber(Force_Warn) == 200 then
                  Alert(Leader.id, "حداکثر مقدار 200")
                else
                  Force_Warn = redis:get("Force:Pm:" .. chat_id) or 1
                  Force_Warn = tonumber(Force_Warn) + 1
                  Alert(Leader.id, Force_Warn)
                  redis:set("Force:Pm:" .. chat_id, Force_Warn)
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "forcemaxdwarn:" .. chat_id then
                if tonumber(Force_Warn) == 1 then
                  Alert(Leader.id, "حداقل مقدار 1", true)
                else
                  Force_Warn = redis:get("Force:Pm:" .. chat_id) or 1
                  Force_Warn = tonumber(Force_Warn) - 1
                  Alert(Leader.id, Force_Warn)
                  redis:set("Force:Pm:" .. chat_id, Force_Warn)
                end
                setting1(msg, chat_id)
              end
              if LeaderCode == "/tabchi_Identify" .. chat_id then
                if not redis:get("AntiTabchi" .. chat_id) then
                  text = "وضعیت انتی تبچی بر رویتاید قرار گرفت!"
                  redis:set("AntiTabchi" .. chat_id, "All")
                elseif redis:get("AntiTabchi" .. chat_id) == "All" then
                  text = "وضعیت انتی تبچی بر روی ارسال اموجی قرار گرفت !"
                  redis:set("AntiTabchi" .. chat_id, "Emoji")
                elseif redis:get("AntiTabchi" .. chat_id) == "Emoji" then
                  text = "وضعیت انتی تبچی بر روی ارسال اعداد قرار گرفت !"
                  redis:set("AntiTabchi" .. chat_id, "Number")
                elseif redis:get("AntiTabchi" .. chat_id) == "Number" then
                  text = " وضعیت انتی تبچی غیرفعال شد !"
                  redis:del("AntiTabchi" .. chat_id)
                end
                Alert(Leader.id, text, true)
                setting1(msg, chat_id)
              end
              if LeaderCode == "lock spam:" .. chat_id then
                if redis:get("Spam:Lock:" .. chat_id) then
                  redis:del("Spam:Lock:" .. chat_id)
                  Alert(Leader.id, " قفل اسپم غیرفعال شد ")
                else
                  redis:set("Spam:Lock:" .. chat_id, "Enable")
                  Alert(Leader.id, " قفل اسپم فعال شد")
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "msgmaxup:" .. chat_id then
                if tonumber(MSG_MAX) == 15 then
                  Alert(Leader.id, "حداکثر مقدار 15", true)
                else
                  MSG_MAX = redis:get("Flood:Max:" .. chat_id) or 6
                  MSG_MAX = tonumber(MSG_MAX) + 1
                  Alert(Leader.id, MSG_MAX)
                  redis:set("Flood:Max:" .. chat_id, MSG_MAX)
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "msgmaxdown:" .. chat_id then
                if tonumber(MSG_MAX) == 3 then
                  Alert(Leader.id, "حداقل مقدار 3", true)
                else
                  MSG_MAX = redis:get("Flood:Max:" .. chat_id) or 6
                  MSG_MAX = tonumber(MSG_MAX) - 1
                  Alert(Leader.id, MSG_MAX)
                  redis:set("Flood:Max:" .. chat_id, MSG_MAX)
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "warnmaxup:" .. chat_id then
                if tonumber(Warn_Max) == 200 then
                  Alert(Leader.id, "حداکثر مقدار 200")
                else
                  Warn_Max = redis:get("Warn:Max:" .. chat_id) or 1
                  Warn_Max = tonumber(Warn_Max) + 1
                  Alert(Leader.id, Warn_Max)
                  redis:set("Warn:Max:" .. chat_id, Warn_Max)
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "warnmaxdown:" .. chat_id then
                if tonumber(Warn_Max) == 3 then
                  Alert(Leader.id, "حداقل مقدار  3", true)
                else
                  Warn_Max = redis:get("Warn:Max:" .. chat_id) or 1
                  Warn_Max = tonumber(Warn_Max) - 1
                  Alert(Leader.id, Warn_Max)
                  redis:set("Warn:Max:" .. chat_id, Warn_Max)
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "timemaxup:" .. chat_id then
                if tonumber(TIME_CHECK) == 9 then
                  Alert(Leader.id, "حداکثر مقدار 9")
                else
                  TIME_CHECK = redis:get("Flood:Time:" .. chat_id) or 2
                  TIME_CHECK = tonumber(TIME_CHECK) + 1
                  Alert(Leader.id, TIME_CHECK)
                  redis:set("Flood:Time:" .. chat_id, TIME_CHECK)
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "timemaxdown:" .. chat_id then
                if tonumber(TIME_CHECK) == 2 then
                  Alert(Leader.id, "حداقل مقدار 2", true)
                else
                  TIME_CHECK = redis:get("Flood:Time:" .. chat_id) or 2
                  TIME_CHECK = tonumber(TIME_CHECK) - 1
                  Alert(Leader.id, TIME_CHECK)
                  redis:set("Flood:Time:" .. chat_id, TIME_CHECK)
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "chmaxup:" .. chat_id then
                if tonumber(CH_MAX) == 4096 then
                  Alert(Leader.id, "حداکثر مقدار 4096", true)
                else
                  CH_MAX = redis:get("NUM_CH_MAX:" .. chat_id) or 400
                  CH_MAX = tonumber(CH_MAX) + 50
                  Alert(Leader.id, CH_MAX)
                  redis:set("NUM_CH_MAX:" .. chat_id, CH_MAX)
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "chmaxdown:" .. chat_id then
                if tonumber(CH_MAX) == 50 then
                  Alert(Leader.id, "حداقل مقدار 50", true)
                else
                  CH_MAX = redis:get("NUM_CH_MAX:" .. chat_id) or 400
                  CH_MAX = tonumber(CH_MAX) - 50
                  Alert(Leader.id, CH_MAX)
                  redis:set("NUM_CH_MAX:" .. chat_id, CH_MAX)
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "floodstatus:" .. chat_id then
                local hash = redis:get("Flood:Status:" .. chat_id)
                if hash then
                  if redis:get("Flood:Status:" .. chat_id) == "kickuser" then
                    redis:set("Flood:Status:" .. chat_id, "muteuser")
                    floodstatus = "بیصدا کاربر"
                    Alert(Leader.id, "وضعیت فلود بر روی " .. floodstatus .. " قرار گرفت")
                  elseif redis:get("Flood:Status:" .. chat_id) == "muteuser" then
                    redis:set("Flood:Status:" .. chat_id, "deletemsg")
                    floodstatus = "حذف پیام"
                    Alert(Leader.id, "وضعیت فلود بر روی " .. floodstatus .. " قرار گرفت")
                  elseif redis:get("Flood:Status:" .. chat_id) == "deletemsg" then
                    redis:del("Flood:Status:" .. chat_id)
                    floodstatus = "تنظیم نشده"
                    Alert(Leader.id, "وضعیت فلود بر روی " .. floodstatus .. " قرار گرفت")
                  end
                else
                  redis:set("Flood:Status:" .. chat_id, "kickuser")
                  floodstatus = "اخراج کاربر"
                  Alert(Leader.id, "وضعیت فلود بر روی " .. floodstatus .. " قرار گرفت")
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "welcstatuse:" .. chat_id then
                if redis:get("Welcome:" .. chat_id) then
                  redis:del("Welcome:" .. chat_id)
                  Alert(Leader.id, "وضعیت خوشامد بر روی غیرفعال قرار گرفت")
                else
                  redis:set("Welcome:" .. chat_id, true)
                  Alert(Leader.id, "وضعیت خوشامد بر روی فعال قرار گرفت")
                end
                setting2(msg, chat_id)
              end
              if LeaderCode == "/CleanWlc_status" .. chat_id then
                if redis:get("CleanWlc" .. chat_id) then
                  redis:del("CleanWlc" .. chat_id)
                  text = "• حالت پاکسازی خودکار پیام خوشامدگویی غیرفعال شد !"
                else
                  redis:set("CleanWlc" .. chat_id, true)
                  text = "• حالت پاکسازی خودکار پیام خوشامد فعال شد !"
                end
                Alert(Leader.id, text)
                setting2(msg, chat_id)
              end
              if LeaderCode == "/Low_Clean_Wlc" .. chat_id then
                MaxCleanWlc = redis:get("Max:CleanWlc" .. chat_id) or 30
                MaxCleanWlc = tonumber(MaxCleanWlc) - 10
                if 10 > MaxCleanWlc then
                  ShowText = "• کمتر از حد مجاز !"
                else
                  ShowText = "• زمان پاکسازی خودکار پیام خوشامدگویی به " .. MaxCleanWlc .. " تنظیم شد !"
                  redis:set("Max:CleanWlc" .. chat_id, MaxCleanWlc)
                end
                Alert(Leader.id, ShowText)
                setting2(msg, chat_id)
              end
              if LeaderCode == "/High_Clean_Wlc" .. chat_id then
                MaxCleanWlc = redis:get("Max:CleanWlc" .. chat_id) or 30
                MaxCleanWlc = tonumber(MaxCleanWlc) + 10
                if MaxCleanWlc > 100 then
                  ShowText = "• بیشتر از حد مجاز !"
                else
                  ShowText = "• زمان پاکسازی خودکار پیام خوشامدگویی به " .. MaxCleanWlc .. " تنظیم شد !"
                  redis:set("Max:CleanWlc" .. chat_id, MaxCleanWlc)
                end
                Alert(Leader.id, ShowText)
                setting2(msg, chat_id)
              end
              if LeaderCode == "groupinfo:" .. chat_id then
                local text = "• لطفاً بخش مورد نظر خود را انتخاب کنید :"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• لیست مالکان",
                      callback_data = "ownerlist:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیست مدیران",
                      callback_data = "modlist:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیست مسدود",
                      callback_data = "banlist:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیست معافان",
                      callback_data = "freeblist:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیست بیصدا",
                      callback_data = "silentlist:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیست ویژه",
                      callback_data = "viplist:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "panel:" .. chat_id
                    },
                    {
                      text = "► صفحه بعد",
                      callback_data = "groupinfo_b:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
              end
              if LeaderCode == "groupinfo_b:" .. chat_id then
                local text = "• لطفاً بخش مورد نظر خود را انتخاب کنید :"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• بررسی شارژ گروه",
                      callback_data = "chargegp:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیست فیلتر",
                      callback_data = "filterlist:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• امار گروه",
                      callback_data = "aamar:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لینک گروه",
                      callback_data = "grouplink:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• قوانین گروه",
                      callback_data = "grouprules:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• دسترسی های گروه",
                      callback_data = "AccessGp:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• درباره سورس",
                      callback_data = "forcegp:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیست فیلتر استیکر",
                      callback_data = "ssticlist:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "groupinfo:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
              end
              if LeaderCode == "silentlist:" .. chat_id then
                List = redis:smembers("MuteList:" .. chat_id)
                if #List == 0 then
                  Stext = "• لیست افراد بیصدا گروه خالی است !"
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List > 25 then
                  local Stext = "• لیست افراد بیصدا گروه :\n\n"
                  do
                    do
                      for i = 1, 25 do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleansilentlist:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "► صفحه بعد",
                        callback_data = "Pagesilentlist:1:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List <= 25 then
                  local List = redis:smembers("MuteList:" .. chat_id)
                  local Stext = "• لیست افراد بیصدا گروه :\n\n"
                  do
                    do
                      for i = 1, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleansilentlist:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                end
              end
              if LeaderCode:match("Pagesilentlist:") then
                Split = LeaderCode:split(":")
                chat_id = Split[3]
                Safhe = Split[2]
                local List = redis:smembers("MuteList:" .. chat_id)
                if #List > Safhe * 25 and #List <= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست افراد بیصدا گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "silentlist:" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleansilentlist:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "Pagesilentlist:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleansilentlist:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                elseif #List >= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست افراد بیصدا گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, (Safhe + 1) * 25 + Safhe do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleansilentlist:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "silentlist:" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "Pagesilentlist:2:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleansilentlist:"
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "Pagesilentlist:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "Pagesilentlist:" .. tonumber(Safhe + 1) .. ":" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                end
              end
              if LeaderCode == "cleansilentlist:" .. chat_id then
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local MuteList = redis:smembers("MuteList:" .. chat_id)
                  do
                    do
                      for i, i in pairs(MuteList) do
                        Mute(chat_id, i, 2, 0)
                        redis:srem("MuteList:" .. chat_id, i)
                        Stext = "• تعداد " .. i .. " کاربر از لیست افراد سکوت ، حذف شدند !"
                      end
                    end
                  end
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "silentlist:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, keyboard, "html")
                end
              end
              if LeaderCode == "freeblist:" .. chat_id then
                List = redis:smembers("VipAdd:" .. chat_id)
                if #List == 0 then
                  Stext = "• لیست افراد معاف گروه خالی است !"
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List > 25 then
                  local Stext = "• لیست افراد معاف گروه :\n\n"
                  do
                    do
                      for i = 1, 25 do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleanVipAdd:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "► صفحه بعد",
                        callback_data = "PageVipAdd:1:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List <= 25 then
                  local List = redis:smembers("VipAdd:" .. chat_id)
                  local Stext = "• لیست افراد معاف گروه :\n\n"
                  do
                    do
                      for i = 1, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleanVipAdd:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                end
              end
              if LeaderCode:match("PageVipAdd:") then
                Split = LeaderCode:split(":")
                chat_id = Split[3]
                Safhe = Split[2]
                local List = redis:smembers("VipAdd:" .. chat_id)
                if #List > Safhe * 25 and #List <= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست افراد معاف گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "freeblist:" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanVipAdd:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "PageVipAdd:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanVipAdd:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                elseif #List >= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست افراد معاف گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, (Safhe + 1) * 25 + Safhe do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanVipAdd:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "freeblist:" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "PageVipAdd:2:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanVipAdd:"
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "PageVipAdd:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "PageVipAdd:" .. tonumber(Safhe + 1) .. ":" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                end
              end
              if LeaderCode == "cleanVipAdd:" .. chat_id then
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local MuteList = redis:smembers("VipAdd:" .. chat_id)
                  do
                    do
                      for i, i in pairs(MuteList) do
                        redis:srem("VipAdd:" .. chat_id, i)
                        Stext = "• تعداد " .. i .. " کاربر از لیست افراد معاف ، حذف شدند !"
                      end
                    end
                  end
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "freeblist:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, keyboard, "html")
                end
              end
              if LeaderCode == "aamar:" .. chat_id then
                addedU1 = redis:get("Total:added:" .. chat_id) or 0
                addedU11 = redis:get("Total:Stickers:" .. chat_id) or 0
                addedU12 = redis:get("Total:Text:" .. chat_id) or 0
                addedU13 = redis:get("Total:ChatDeleteMember:" .. chat_id) or 0
                addedU14 = redis:get("Total:ChatJoinByLink:" .. chat_id) or 0
                addedU15 = redis:get("Total:Audio:" .. chat_id) or 0
                addedU16 = redis:get("Total:Voice:" .. chat_id) or 0
                addedU17 = redis:get("Total:Video:" .. chat_id) or 0
                addedU18 = redis:get("Total:Animation:" .. chat_id) or 0
                addedU19 = redis:get("Total:Location:" .. chat_id) or 0
                addedU10 = redis:get("Total:ForwardedFromUser:" .. chat_id) or 0
                addedU9 = redis:get("Total:Document:" .. chat_id) or 0
                addedU8 = redis:get("Total:Contact:" .. chat_id) or 0
                addedU7 = redis:get("Total:Photo:" .. chat_id) or 0
                gmsg = redis:get("Total:messages:" .. chat_id) or 0
                Text = "🎗 آمار گروه شما در ساعت " .. os.date("%H:%M:%S") .. "\n\n• تعداد پیام ها: [" .. addedU12 .. "]\n• تعداد استیکرها: [" .. addedU11 .. "]\n• تعداد فایل ها: [" .. addedU9 .. "]\n• تعداد گیف ها : [" .. addedU18 .. "]\n• تعداد عکس ها: [" .. addedU7 .. "]\n• تعداد مخاطب: [" .. addedU8 .. "]\n• تعداد آهنگ ها: [" .. addedU15 .. "]\n• تعداد فیلم ها : [" .. addedU17 .. "]\n• تعداد ویس ها: [" .. addedU16 .. "]\n\n• تعداد نفرات افزوده شده: [" .. addedU1 .. "]\n• تعداد نفرات جوین داده شده: [" .. addedU14 .. "]\n• تعداد نفرات اخراج شده: [" .. addedU13 .. "]"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "•ریست امار",
                      callback_data = "cleanam:" .. chat_id
                    },
                    {
                      text = "• فعالیت کاربران",
                      callback_data = "faall:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "groupinfo_b:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, Text, keyboard, "html")
              end
              if LeaderCode == "faall:" .. chat_id then
                local Data = {}
                local Max1, Max2, Max3, Max4, Max5 = 0, 0, 0, 0, 0
                local User1Data, User2Data, User3Data, User4Data, User5Data = {}, {}, {}, {}, {}
                local users = redis:smembers("Total:users:" .. chat_id) or 0
                do
                  do
                    for i, i in pairs(users) do
                      local Msgs = redis:get("Total:messages:" .. chat_id .. ":" .. i) or 0
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
                local users = redis:smembers("Total:users:" .. chat_id) or 0
                do
                  do
                    for i, i in pairs(users) do
                      local Added = redis:get("Total:added:" .. chat_id .. ":" .. i) or 0
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
                local txt = "• فعال ترین ها در گروه در ارسال پیام :\n\n" .. test .. "\n\n• فعال ترین های گروه در اضافه کردن اعضا :\n\n" .. testt .. ""
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "aamar:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, txt, keyboard, "html")
              end
              if LeaderCode == "cleanam:" .. chat_id then
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
                local users = redis:smembers("Total:users:" .. chat_id)
                do
                  do
                    for i, i in pairs(users) do
                      redis:del("Total:messages:" .. chat_id .. ":" .. i)
                      redis:del("Total:added:" .. chat_id .. ":" .. i)
                    end
                  end
                end
                redis:del("Total:users:" .. chat_id)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "groupinfo_b:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "امار گروه صفر شد", keyboard, "html")
              end
              if LeaderCode == "grouprules:" .. chat_id then
                local rules = redis:get("Rules:" .. chat_id)
                if rules then
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• حذف قوانین",
                        callback_data = "delrules:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo_b:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, rules, keyboard, "html")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo_b:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, "_قوانین گروه ثبت نشده است!_", keyboard, "md")
                end
              end
              if LeaderCode == "ssticlist:" .. chat_id then
                local packlist = redis:smembers("filterpackname" .. chat_id)
                text = "لیست استیکرهای قفل شده:\n"
                do
                  do
                    for i, i in pairs(packlist) do
                      text = text .. i .. " - t.me/addstickers/" .. i .. " \n"
                    end
                  end
                end
                if #packlist == 0 then
                  text = "لیست مورد نظر خالی میباشد!"
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo_b:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleanstiiclist:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo_b:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                end
              end
              if LeaderCode == "cleanstiiclist:" .. chat_id then
                text = "_لیست مورد نظر پاکسازی شد !_"
                redis:del("filterpackname" .. chat_id)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "groupinfo_b:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
              end
              if LeaderCode == "delrules:" .. chat_id then
                redis:del("Rules:" .. chat_id)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "grouprules:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "_قوانین گروه حذف شد!_", keyboard, "md")
              end
              if LeaderCode == "grouplink:" .. chat_id then
                local link = redis:get("Link:" .. chat_id)
                if link then
                  local link = "[جهت ورود به گروه کلیک کنید](" .. link .. ")"
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• حذف لینک",
                        callback_data = "dellink:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo_b:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, link, keyboard, "md")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo_b:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, "_لینک گروه ثبت نشده است!_", keyboard, "md")
                end
              end
              if LeaderCode == "dellink:" .. chat_id then
                redis:del("Link:" .. chat_id)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "groupinfo_b:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "_لینک گروه حذف شد!_", keyboard, "md")
              end
              if LeaderCode == "filterlist:" .. chat_id then
                local Filters = redis:smembers("Filters:" .. chat_id)
                local text = "لیست عبارات فیلتر گروه \n"
                do
                  do
                    for i, i in pairs(Filters) do
                      text = text .. i .. " - [" .. i .. "]\n"
                    end
                  end
                end
                if #Filters == 0 then
                  text = "_لیست مورد نظر خالی میباشد!_"
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo_b:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• پاکسازی لیست فیلتر",
                        callback_data = "cleanfilters:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo_b:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
                end
              end
              if LeaderCode == "cleanfilters:" .. chat_id then
                local text = "_لیست فیلتر پاکسازی شد!_"
                redis:del("Filters:" .. chat_id)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "groupinfo_b:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
              end
              if LeaderCode == "chargegp:" .. chat_id .. "" then
                local ex = redis:ttl("ExpireData:" .. chat_id)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "groupinfo_b:" .. chat_id
                    }
                  }
                }
                if ex == -1 then
                  Edit(msg.chat_id, msg.inline_id, "طرح نامحدود برای گروه شما فعال شده است و نیاز به تمدید ندارید.", keyboard, "html")
                else
                  local time = redis:ttl("ExpireData:" .. chat_id)
                  local days = math.floor(time / 86400)
                  time = time - days * 86400
                  local hour = math.floor(time / 3600)
                  time = time - hour * 3600
                  local minute = math.floor(time / 60)
                  time = time - minute * 60
                  sec = time
                  Edit(msg.chat_id, msg.inline_id, "*آخرین بروزرسانی در ساعت : [" .. os.date("%X") .. "]*\n\n_تا پایان مدت زمان کارکرد ربات در گروه شما :_\n [" .. days .. "] _روز_\n [" .. hour .. "] _ساعت_\n [" .. minute .. "] _دقیقه_\n_دیگر باقی مانده است._", keyboard, "md")
                end
              end
              if LeaderCode == "forcegp:" .. chat_id .. "" then
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "groupinfo_b:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "  (@Developer4)\n لطفا منبع اپن کننده را پاک نکنید\n التماس دعا", keyboard, "html")
              end
              if LeaderCode == "viplist:" .. chat_id then
                List = redis:smembers("Vip:" .. chat_id)
                if #List == 0 then
                  Stext = "• لیست افراد ویژه گروه خالی است !"
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List > 25 then
                  local Stext = "• لیست افراد ویژه گروه :\n\n"
                  do
                    do
                      for i = 1, 25 do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleanviplist:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "► صفحه بعد",
                        callback_data = "PageVip:1:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List <= 25 then
                  local List = redis:smembers("Vip:" .. chat_id)
                  local Stext = "• لیست افراد ویژه گروه :\n\n"
                  do
                    do
                      for i = 1, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleanviplist:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                end
              end
              if LeaderCode:match("PageVip:") then
                Split = LeaderCode:split(":")
                chat_id = Split[3]
                Safhe = Split[2]
                local List = redis:smembers("Vip:" .. chat_id)
                if #List > Safhe * 25 and #List <= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست افراد ویژه گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "viplist:" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanviplist:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "PageVip:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanviplist:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                elseif #List >= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست افراد ویژه گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, (Safhe + 1) * 25 + Safhe do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanviplist:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "viplist:" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "PageVip:2:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanviplist:"
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "PageVip:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "PageVip:" .. tonumber(Safhe + 1) .. ":" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                end
              end
              if LeaderCode == "cleanviplist:" .. chat_id then
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local text = "_لیست ویژه پاکسازی شد!_"
                  redis:del("Vip:" .. chat_id)
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "viplist:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                end
              end
              if LeaderCode == "banlist:" .. chat_id then
                List = redis:smembers("BanUser:" .. chat_id)
                if #List == 0 then
                  Stext = "• لیست افراد مسدود گروه خالی است !"
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List > 25 then
                  local Stext = "• لیست افراد مسدود گروه :\n\n"
                  do
                    do
                      for i = 1, 25 do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          local Username = redis:get("firstname" .. List[i])
                          if Username then
                            Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                          else
                            Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                          end
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleanbanlist:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "► صفحه بعد",
                        callback_data = "PageBan:1:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List <= 25 then
                  local List = redis:smembers("BanUser:" .. chat_id)
                  local Stext = "• لیست افراد مسدود گروه :\n\n"
                  do
                    do
                      for i = 1, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleanbanlist:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                end
              end
              if LeaderCode:match("PageBan:") then
                Split = LeaderCode:split(":")
                chat_id = Split[3]
                Safhe = Split[2]
                local List = redis:smembers("BanUser:" .. chat_id)
                if #List > Safhe * 25 and #List <= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست افراد مسدود گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "banlist:" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanbanlist:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "PageBan:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanbanlist:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                elseif #List >= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست افراد مسدود گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, (Safhe + 1) * 25 + Safhe do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanbanlist:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "banlist:" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "PageBan:2:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanbanlist:"
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "PageBan:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "PageBan:" .. tonumber(Safhe + 1) .. ":" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                end
              end
              if LeaderCode == "cleanbanlist:" .. chat_id then
                local text = "_لیست مسدود پاکسازی شد!_"
                redis:del("BanUser:" .. chat_id)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "banlist:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "modlist:" .. chat_id then
                List = redis:smembers("ModList:" .. chat_id)
                if #List == 0 then
                  Stext = "• لیست مدیران گروه خالی است !"
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List > 25 then
                  local Stext = "• لیست مدیران گروه :\n\n"
                  do
                    do
                      for i = 1, 25 do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleanmodlist:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "► صفحه بعد",
                        callback_data = "PageOwner:1:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                elseif #List <= 25 then
                  local List = redis:smembers("ModList:" .. chat_id)
                  local Stext = "• لیست مدیران گروه :\n\n"
                  do
                    do
                      for i = 1, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "groupinfo:" .. chat_id
                      },
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "cleanmodlist:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                end
              end
              if LeaderCode:match("PageOwner:") then
                Split = LeaderCode:split(":")
                chat_id = Split[3]
                Safhe = Split[2]
                local List = redis:smembers("ModList:" .. chat_id)
                if #List > Safhe * 25 and #List <= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست مدیران گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, #List do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "modlist:" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanmodlist:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "PageOwner:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanmodlist:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                elseif #List >= (Safhe + 1) * 25 + Safhe then
                  local Stext = "• لیست مدیران گروه :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                  do
                    do
                      for i = Safhe * 26, (Safhe + 1) * 25 + Safhe do
                        local Username = redis:get("firstname" .. List[i])
                        if Username then
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. check_html(Username) .. "</a> [<code>" .. List[i] .. "</code>]"
                        else
                          Users = "<a href=\"tg://user?id=" .. List[i] .. "\">" .. List[i] .. "</a>"
                        end
                        Stext = Stext .. i .. " - " .. Users .. "\n"
                      end
                    end
                  end
                  if tonumber(Safhe) == 1 then
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanmodlist:" .. chat_id
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "modlist:" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "PageOwner:2:" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  else
                    local Keyboard = {}
                    Keyboard.inline_keyboard = {
                      {
                        {
                          text = "• پاکسازی لیست",
                          callback_data = "cleanmodlist:"
                        }
                      },
                      {
                        {
                          text = "صفحه قبل ◄",
                          callback_data = "PageOwner:" .. tonumber(Safhe - 1) .. ":" .. chat_id
                        },
                        {
                          text = "► صفحه بعد",
                          callback_data = "PageOwner:" .. tonumber(Safhe + 1) .. ":" .. chat_id
                        }
                      }
                    }
                    Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                  end
                end
              end
              if LeaderCode == "cleanmodlist:" .. chat_id then
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local Stext = "_لیست مدیران پاکسازی شد!_"
                  redis:del("ModList:" .. chat_id)
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "modlist:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "md")
                end
              end
              if LeaderCode == "ownerlist:" .. chat_id then
                local OwnerList = redis:smembers("OwnerList:" .. chat_id)
                local text = "• لیست مالکان گروه :\n\n"
                do
                  do
                    for i, i in pairs(OwnerList) do
                      local Username = redis:get("firstname" .. i)
                      if Username then
                        Users = "<a href=\"tg://user?id=" .. i .. "\">" .. Username .. "</a>"
                      else
                        Users = "<a href=\"tg://user?id=" .. i .. "\">" .. i .. "</a>"
                      end
                      text = text .. i .. " - " .. Users .. "\n"
                    end
                  end
                end
                if #OwnerList == 0 then
                  text = "_لیست صاحبان گروه خالی میباشد!_"
                end
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "groupinfo:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "ChargeGp:" .. chat_id then
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  charge(msg, chat_id)
                end
              end
              if LeaderCode == "Charge:TeDay:" .. chat_id then
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  local time = 1728000
                  redis:setex("ExpireData:" .. chat_id, time, true)
                  redis:del("Mel" .. chat_id)
                  charge(msg, chat_id)
                  text = "گروه شما به مدت 20 روز شارژ شد !"
                  Alert(Leader.id, text, true)
                  sendText(chat_id, 0, text, "html")
                end
              end
              if LeaderCode == "Charge:FiDay:" .. chat_id then
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  local time = 1296000
                  redis:setex("ExpireData:" .. chat_id, time, true)
                  redis:del("Mel" .. chat_id)
                  charge(msg, chat_id)
                  text = "گروه شما به مدت 15 روز شارژ شد !"
                  Alert(Leader.id, text, true)
                  sendText(chat_id, 0, text, "html")
                end
              end
              if LeaderCode == "Charge:TenDay:" .. chat_id then
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  local time = 864000
                  redis:setex("ExpireData:" .. chat_id, time, true)
                  redis:del("Mel" .. chat_id)
                  charge(msg, chat_id)
                  text = "گروه شما به مدت 10 روز شارژ شد !"
                  Alert(Leader.id, text, true)
                  sendText(chat_id, 0, text, "html")
                end
              end
              if LeaderCode == "Charge:OneM:" .. chat_id then
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  local time = 2592000
                  redis:setex("ExpireData:" .. chat_id, time, true)
                  redis:del("Mel" .. chat_id)
                  charge(msg, chat_id)
                  text = "گروه شما به مدت 30 روز شارژ شد !"
                  Alert(Leader.id, text, true)
                  sendText(chat_id, 0, text, "html")
                end
              end
              if LeaderCode == "Charge:towM:" .. chat_id then
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  local time = 5184000
                  redis:setex("ExpireData:" .. chat_id, time, true)
                  redis:del("Mel" .. chat_id)
                  charge(msg, chat_id)
                  text = "گروه شما به مدت 60 روز شارژ شد !"
                  Alert(Leader.id, text, true)
                  sendText(chat_id, 0, text, "html")
                end
              end
              if LeaderCode == "Charge:treeM:" .. chat_id then
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  local time = 7776000
                  redis:setex("ExpireData:" .. chat_id, time, true)
                  redis:del("Mel" .. chat_id)
                  charge(msg, chat_id)
                  text = "گروه شما به مدت 90 روز شارژ شد !"
                  Alert(Leader.id, text, true)
                  sendText(chat_id, 0, text, "html")
                end
              end
              if LeaderCode == "Charge:sexM:" .. chat_id then
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  local time = 15552000
                  redis:setex("ExpireData:" .. chat_id, time, true)
                  redis:del("Mel" .. chat_id)
                  charge(msg, chat_id)
                  text = "گروه شما به مدت 180 روز شارژ شد !"
                  Alert(Leader.id, text, true)
                  sendText(chat_id, 0, text, "html")
                end
              end
              if LeaderCode == "Charge:Year:" .. chat_id then
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  local time = 31536000
                  redis:setex("ExpireData:" .. chat_id, time, true)
                  redis:del("Mel" .. chat_id)
                  charge(msg, chat_id)
                  text = "گروه شما به مدت 365 روز شارژ شد !"
                  Alert(Leader.id, text, true)
                  sendText(chat_id, 0, text, "html")
                end
              end
              if LeaderCode == "SendPvGpLink:" .. chat_id then
                if getChatMember(chat_id, BotHelper).result.can_invite_users then
                  exportChatInviteLink(chat_id)
                  if getChat(chat_id).result.invite_link then
                    GpLink = getChat(chat_id).result.invite_link
                  else
                    GpLink = "---"
                  end
                  Alert(Leader.id, "لینک گروه به پی وی شما ارسال شد", true)
                  sendText(sender_id, 0, GpLink, "html")
                else
                  Alert(Leader.id, "• لطفا دسترسی \"دعوت و دریافت لینک گروه\" را به ربات بدهید !", true)
                end
              end
              if LeaderCode == "ShowGpLink:" .. chat_id then
                if getChatMember(chat_id, BotHelper).result.can_invite_users then
                  exportChatInviteLink(chat_id)
                  if getChat(chat_id).result.invite_link then
                    GpLink = getChat(chat_id).result.invite_link
                  else
                    GpLink = "---"
                  end
                  sendText(chat_id, 0, GpLink, "html")
                else
                  Alert(Leader.id, "• لطفا دسترسی \"دعوت و دریافت لینک گروه\" را به ربات بدهید !", true)
                end
              end
              if LeaderCode == "Exit:" .. chat_id .. "" then
                Edit(msg.chat_id, msg.inline_id, "• فهرست بسته شد !", nil, "md")
              end
              if LeaderCode:match("Exitacs:(%d+)") then
                user_id = LeaderCode:match("Exitacs:(%d+)")
                if getChat(user_id).result.username then
                  Username = "<a href=\"tg://user?id=" .. user_id .. "\">" .. getChat(user_id).result.username .. "</a>"
                else
                  Username = "<a href=\"tg://user?id=" .. user_id .. "\">" .. getChat(user_id).result.first_name .. "</a>"
                end
                Edit(msg.chat_id, msg.inline_id, "پنل مدیریتی کاربر " .. Username .. " بسته شد !", nil, "html")
              end
              if LeaderCode:match("promotee:(%d+)") then
                user_id = LeaderCode:match("promotee:(%d+)")
                if not is_owner(msg.chat_id, sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید")
                else
                  if redis:sismember("ModList:" .. msg.chat_id, user_id) then
                    redis:srem("ModList:" .. msg.chat_id, user_id)
                    Alert(Leader.id, "• کاربر از لیست مدیران گروه حذف شد!")
                  else
                    redis:sadd("ModList:" .. msg.chat_id, user_id)
                    Alert(Leader.id, " کاربر باموفقیت به لیست مدیران گروه اضافه شد !")
                  end
                  remote(msg.chat_id, msg.inline_id, user_id)
                end
              end
              if LeaderCode:match("addsudo:(%d+)") then
                user_id = LeaderCode:match("addsudo:(%d+)")
                if not is_Fullsudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید")
                else
                  if redis:sismember("SUDO-ID", user_id) then
                    redis:srem("SUDO-ID", user_id)
                    Alert(Leader.id, "• کاربر از لیست مدیران ربات حذف شد!")
                  else
                    redis:sadd("SUDO-ID", user_id)
                    Alert(Leader.id, " کاربر باموفقیت به لیست مدیران ربات اضافه شد !")
                  end
                  remote(msg.chat_id, msg.inline_id, user_id)
                end
              end
              if LeaderCode:match("ownerr:(%d+)") then
                user_id = LeaderCode:match("ownerr:(%d+)")
                if not is_sudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید")
                else
                  if redis:sismember("OwnerList:" .. msg.chat_id, user_id) then
                    redis:srem("OwnerList:" .. msg.chat_id, user_id)
                    Alert(Leader.id, "• کاربر از لیست مالکین گروه حذف شد!")
                  else
                    redis:sadd("OwnerList:" .. msg.chat_id, user_id)
                    Alert(Leader.id, " کاربر باموفقیت به لیست مالکین گروه اضافه شد !")
                  end
                  remote(msg.chat_id, msg.inline_id, user_id)
                end
              end
              if LeaderCode:match("addvip:(%d+)") then
                user_id = LeaderCode:match("addvip:(%d+)")
                if redis:sismember("Vip:" .. msg.chat_id, user_id) then
                  redis:srem("Vip:" .. msg.chat_id, user_id)
                  Alert(Leader.id, "• کاربر از لیست افراد ویژه گروه حذف شد!")
                else
                  redis:sadd("Vip:" .. msg.chat_id, user_id)
                  Alert(Leader.id, " کاربر باموفقیت به لیست افراد ویژه گروه اضافه شد !")
                end
                remote(msg.chat_id, msg.inline_id, user_id)
              end
              if LeaderCode:match("mytee:(%d+)") then
                user_id = LeaderCode:match("mytee:(%d+)")
                if private(msg.chat_id, user_id) then
                  Alert(Leader.id, "من نمیتوانم مدیران را سکوت کنم", true)
                else
                  if redis:sismember("MuteList:" .. msg.chat_id, user_id) then
                    redis:srem("MuteList:" .. msg.chat_id, user_id)
                    Mute(msg.chat_id, user_id, 2, 0)
                    Alert(Leader.id, "• کاربر از لیست بیصدا گروه حذف شد!")
                  else
                    redis:sadd("MuteList:" .. msg.chat_id, user_id)
                    Mute(msg.chat_id, user_id, 1, 1)
                    Alert(Leader.id, " کاربر باموفقیت به لیست بیصدا گروه اضافه شد !")
                  end
                  remote(msg.chat_id, msg.inline_id, user_id)
                end
              end
              if LeaderCode:match("addmof:(%d+)") then
                user_id = LeaderCode:match("addmof:(%d+)")
                if private(msg.chat_id, user_id) then
                  Alert(Leader.id, "من نمیتوانم مدیران را معاف کنم", true)
                else
                  if redis:sismember("VipAdd:" .. msg.chat_id, user_id) then
                    redis:srem("VipAdd:" .. msg.chat_id, user_id)
                    Alert(Leader.id, "• کاربر از لیست معافان اداجباری گروه حذف شد!")
                  else
                    redis:sadd("VipAdd:" .. msg.chat_id, user_id)
                    Alert(Leader.id, " کاربر باموفقیت به لیست معافان اداجباری گروه اضافه شد !")
                  end
                  remote(msg.chat_id, msg.inline_id, user_id)
                end
              end
              if LeaderCode:match("bannnd:(%d+)") then
                user_id = LeaderCode:match("bannnd:(%d+)")
                if private(msg.chat_id, user_id) then
                  Alert(Leader.id, "من نمیتوانم مدیران را مسدود کنم", true)
                else
                  if redis:sismember("BanUser:" .. msg.chat_id, user_id) then
                    redis:srem("BanUser:" .. msg.chat_id, user_id)
                    UnBan(msg.chat_id, user_id)
                    Alert(Leader.id, "• کاربر از لیست مدیران گروه حذف شد!")
                  else
                    redis:sadd("BanUser:" .. msg.chat_id, user_id)
                    Ban(msg.chat_id, user_id)
                    Alert(Leader.id, " کاربر باموفقیت به لیست مدیران گروه اضافه شد !")
                  end
                  remote(msg.chat_id, msg.inline_id, user_id)
                end
              end
              if LeaderCode == "/settings_acs" .. chat_id then
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید")
                else
                  if redis:get("settings_acs:ModAccess" .. chat_id) == "Owner" then
                    redis:del("settings_acs:ModAccess" .. chat_id)
                    text = "• دسترسی به تنظیم و حذف برای مدیران فعال شد !"
                  else
                    redis:set("settings_acs:ModAccess" .. chat_id, "Owner")
                    text = "• دسترسی به تنظیمات برای مدیران غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccess(msg, chat_id)
                end
              end
              if LeaderCode == "/locks_acs" .. chat_id then
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید")
                else
                  if redis:get("locks_acs:ModAccess" .. chat_id) == "Owner" then
                    redis:del("locks_acs:ModAccess" .. chat_id)
                    text = "• دسترسی به تغییر قفل ها برای مدیران فعال شد !"
                  else
                    redis:set("locks_acs:ModAccess" .. chat_id, "Owner")
                    text = "• دسترسی به تغییر قفل ها برای مدیران غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccess(msg, chat_id)
                end
              end
              if LeaderCode == "/menu_acs" .. chat_id then
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید")
                else
                  if redis:get("menu_acs:ModAccess" .. chat_id) == "Owner" then
                    redis:del("menu_acs:ModAccess" .. chat_id)
                    text = "• دسترسی به فهرست برای مدیران فعال شد !"
                  else
                    redis:set("menu_acs:ModAccess" .. chat_id, "Owner")
                    text = "• دسترسی به فهرست برای مدیران غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccess(msg, chat_id)
                end
              end
              if LeaderCode == "/users_acs" .. chat_id then
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید")
                else
                  if redis:get("users_acs:ModAccess" .. chat_id) == "Owner" then
                    redis:del("users_acs:ModAccess" .. chat_id)
                    text = "• دسترسی به مدیریت کاربر برای مدیران فعال شد !"
                  else
                    redis:set("users_acs:ModAccess" .. chat_id, "Owner")
                    text = "• دسترسی به مدیریت کاربر برای مدیران غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccess(msg, chat_id)
                end
              end
              if LeaderCode == "/clean_acs" .. chat_id then
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید")
                else
                  if redis:get("clean_acs:ModAccess" .. chat_id) == "Owner" then
                    redis:del("clean_acs:ModAccess" .. chat_id)
                    text = "• دسترسی به پاکسازی برای مدیران فعال شد !"
                  else
                    redis:set("clean_acs:ModAccess" .. chat_id, "Owner")
                    text = "• دسترسی به پاکسازی برای مدیران غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccess(msg, chat_id)
                end
              end
              if LeaderCode == "cclliif:" .. chat_id and ModAccess5(Leader, chat_id, sender_id) and acsclean(Leader, chat_id, sender_id) then
                local text = "به بخش پاکسازی ربات خوش امدید"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• پاکسازی پیام ها",
                      callback_data = "cgm:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی پیام ",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی کاربر ",
                      callback_data = "clesnnuser:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "panel:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cgm:" .. chat_id then
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cclliif:" .. chat_id
                    }
                  }
                }
                local aa = getChatMember(chat_id, TD_ID).result
                if aa.can_delete_messages then
                  local LLc = redis:get("firstname" .. TD_ID) or TD_ID
                  getuser = "<a href=\"tg://user?id=" .. TD_ID .. "\">" .. LLc .. "</a>"
                  yyyyyyy = "بپاک"
                  sendText(chat_id, 0, yyyyyyy .. " " .. getuser, "html")
                  Edit(msg.chat_id, msg.inline_id, getuser, nil, "html")
                else
                  text = "دسترسی {حذف پیام برای ربات پاکسازی } فعال نشده"
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
                end
              end
              if LeaderCode == "cleannmsg:" .. chat_id then
                local text = "به بخش پاکسازی پیام خوش امدید"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• پاکسازی فیلم ها",
                      callback_data = "cgmf" .. chat_id
                    },
                    {
                      text = "• پاکسازی گیف ها",
                      callback_data = "cgmg" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی فایل ها",
                      callback_data = "cgmsfi" .. chat_id
                    },
                    {
                      text = "• پاکسازی کلمه ها",
                      callback_data = "CleanWord:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی استیکر ها",
                      callback_data = "cgmsss" .. chat_id
                    },
                    {
                      text = "• پاکسازی عکس ها",
                      callback_data = "cgmsas" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی ویس ها",
                      callback_data = "cgmvi" .. chat_id
                    },
                    {
                      text = "• پاکسازی فروارد ها",
                      callback_data = "cgmfwd" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی بازی ها",
                      callback_data = "cvGame" .. chat_id
                    },
                    {
                      text = "• پاکسازی مخاطب ها",
                      callback_data = "cvContact" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی متن ها",
                      callback_data = "cvText" .. chat_id
                    },
                    {
                      text = "• پاکسازی مکان ها",
                      callback_data = "cvLocation" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی عددی",
                      callback_data = "Cleannumber:" .. chat_id
                    },
                    {
                      text = "• پاکسازی فیلم سلفی",
                      callback_data = "cvVideoNote" .. chat_id
                    }
                  },
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cclliif:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "clesnnuser:" .. chat_id then
                local text = "به بخش پاکسازی کاربران خوش امدید"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• پاکسازی ربات ها",
                      callback_data = "cgmbot" .. chat_id
                    },
                    {
                      text = "• پاکسازی دیلیت اکانت",
                      callback_data = "cgmff" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی اخیرا",
                      callback_data = "cleanmonn:" .. chat_id
                    },
                    {
                      text = "• پاکسازی فیک ها",
                      callback_data = "crf:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی کاربران",
                      callback_data = "cgmsr" .. chat_id
                    },
                    {
                      text = "• پاکسازی هفته پیش",
                      callback_data = "crh:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی انلاین ",
                      callback_data = "cro:" .. chat_id
                    },
                    {
                      text = "• پاکسازی یک ماه پیش ",
                      callback_data = "crm:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی محدود",
                      callback_data = "CleanRes:" .. chat_id
                    },
                    {
                      text = "• پاکسازی لیست سیاه",
                      callback_data = "cleanBan:" .. chat_id
                    }
                  },
                  {
                    {
                      text = " برگشت ◄ ",
                      callback_data = "cclliif:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cvGame" .. chat_id then
                text = "درحال پاکسازی بازی های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cvmessageGame" .. chat_id, true)
                text = "بازی های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cvContact" .. chat_id then
                text = "درحال پاکسازی فایل های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cvmessageContact" .. chat_id, true)
                text = "مخاطب های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cvText" .. chat_id then
                text = "درحال پاکسازی متن های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                text = "متن های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cvLocation" .. chat_id then
                text = "درحال پاکسازی مکان های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cvmessageLocation" .. chat_id, true)
                text = "مکان های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cleanmonn:" .. chat_id then
                if not is_owner(chat_id, Leader.from.id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "◄ بازگشت",
                        callback_data = "clesnnuser:" .. chat_id
                      }
                    }
                  }
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_restrict_members then
                    redis:set("CleanLastSeenRecntly" .. chat_id, true)
                    text = "کاربرانی که بازدید اخیرا دارند پاکسازی شدند"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  else
                    text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  end
                end
              end
              if LeaderCode == "crh:" .. chat_id then
                if not is_owner(chat_id, Leader.from.id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "◄ بازگشت",
                        callback_data = "clesnnuser:" .. chat_id
                      }
                    }
                  }
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_restrict_members then
                    redis:set("CleanLastWeek" .. chat_id, true)
                    text = "کاربرانی که بازدید یک هفته پیش دارند پاکسازی شدند"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  else
                    text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  end
                end
              end
              if LeaderCode == "CleanRes:" .. chat_id then
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "◄ بازگشت",
                      callback_data = "clesnnuser:" .. chat_id
                    }
                  }
                }
                local aa = getChatMember(chat_id, BotHelper).result
                if aa.can_restrict_members then
                  redis:set("CleanRestriced" .. chat_id, true)
                  text = "کاربرانی که در لیست محدود بودند پاکسازی شدند"
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                else
                  text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                end
              end
              if LeaderCode == "crm:" .. chat_id then
                if not is_owner(chat_id, Leader.from.id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "◄ بازگشت",
                        callback_data = "clesnnuser:" .. chat_id
                      }
                    }
                  }
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_restrict_members then
                    redis:set("CleanLastMonth" .. chat_id, true)
                    text = "کاربرانی که بازدید یک ماه پیش دارند پاکسازی شدند"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  else
                    text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  end
                end
              end
              if LeaderCode == "cro:" .. chat_id then
                if not is_owner(chat_id, Leader.from.id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "◄ بازگشت",
                        callback_data = "clesnnuser:" .. chat_id
                      }
                    }
                  }
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_restrict_members then
                    redis:set("CleanOnline" .. chat_id, true)
                    text = "کاربرانی که بازدید انلاین دارند پاکسازی شدند"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  else
                    text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  end
                end
              end
              if LeaderCode == "crf:" .. chat_id then
                if not is_owner(chat_id, Leader.from.id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "◄ بازگشت",
                        callback_data = "clesnnuser:" .. chat_id
                      }
                    }
                  }
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_restrict_members then
                    redis:set("CleanLastEmpty" .. chat_id, true)
                    text = "تعدادی از کاربران فیک پاکسازی شدند"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  else
                    text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  end
                end
              end
              if LeaderCode == "cgmff" .. chat_id then
                if not is_owner(chat_id, Leader.from.id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "◄ بازگشت",
                        callback_data = "clesnnuser:" .. chat_id
                      }
                    }
                  }
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_restrict_members then
                    redis:set("CleanDeleted" .. chat_id, true)
                    text = "دلیت اکانت های گروه با موفقیت پاکسازی شدند"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  else
                    text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  end
                end
              end
              if LeaderCode == "cleanBan:" .. chat_id then
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "◄ بازگشت",
                      callback_data = "clesnnuser:" .. chat_id
                    }
                  }
                }
                local aa = getChatMember(chat_id, BotHelper).result
                if aa.can_restrict_members then
                  redis:set("CleanBan" .. chat_id, true)
                  text = "تعدادی از لیست سیاه گروه با موفقیت پاکسازی شدند"
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                else
                  text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                end
              end
              if LeaderCode == "cgmsr" .. chat_id then
                if not is_owner(chat_id, Leader.from.id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "◄ بازگشت",
                        callback_data = "clesnnuser:" .. chat_id
                      }
                    }
                  }
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_restrict_members then
                    redis:set("Cleanmembers" .. chat_id, true)
                    text = "تعدادی از کاربران گروه با موفقیت پاکسازی شدند"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  else
                    text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                    Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                  end
                end
              end
              if LeaderCode == "cvVideoNote" .. chat_id then
                text = "درحال پاکسازی فیلم سلفی های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cvmessageVideoNote" .. chat_id, true)
                text = "فیلم سلفی های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cgmf" .. chat_id then
                text = "درحال پاکسازی فیلم های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cvideos" .. chat_id, true)
                text = "فیلم های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cgmg" .. chat_id then
                redis:set("cgifs" .. chat_id, true)
                text = "گیف های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cgmsfi" .. chat_id then
                text = "درحال پاکسازی فایل های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cfiles" .. chat_id, true)
                text = "فایل های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cgmsss" .. chat_id then
                text = "درحال پاکسازی استیکر های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cstickers" .. chat_id, true)
                text = "استیکر های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cgmsas" .. chat_id then
                text = "درحال پاکسازی عکس های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cphotos" .. chat_id, true)
                text = "عکس های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cgmfwd" .. chat_id then
                text = "درحال پاکسازی فرواردی های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cfwdmsg" .. chat_id, true)
                text = "فرواردی های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "cgmvi" .. chat_id then
                text = "درحال پاکسازی ویس های گروه"
                getuser = "[" .. text .. "](tg://user?id=" .. TD_ID .. ")"
                Edit(msg.chat_id, msg.inline_id, getuser, nil, "md")
                sleep(2)
                redis:set("cvoices" .. chat_id, true)
                text = "ویس های گروه با موفقیت پاکسازی شدند"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "CleanWord:" .. chat_id .. "" then
                redis:set("cleanword" .. chat_id .. ":" .. Leader.from.id, true)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "لطفا کلمه مورد نظر خودرا ارسال کنید", keyboard, "html")
              end
              if LeaderCode == "Cleannumber:" .. chat_id .. "" then
                redis:setex("Cleanumber" .. chat_id .. ":" .. Leader.from.id, 60, true)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "cleannmsg:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "لطفا عدد مورد نظر خودرا ارسال کنید", keyboard, "html")
              end
              if LeaderCode == "cgmbot" .. chat_id then
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "clesnnuser:" .. chat_id
                    }
                  }
                }
                local aa = getChatMember(chat_id, BotHelper).result
                if aa.can_restrict_members then
                  redis:set("Clean‌Bot" .. chat_id, true)
                  text = "ربات های گروه با موفقیت پاکسازی شدند"
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                else
                  text = "دسترسی {اخراج و محدود کردن } برای ربات فعال نشده"
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
                end
              end
              if LeaderCode == "lockcontact:" .. chat_id then
                if not redis:get("Lock:Contact:" .. chat_id) then
                  redis:set("Lock:Contact:" .. chat_id, "Kick")
                elseif redis:get("Lock:Contact:" .. chat_id) == "Kick" then
                  redis:set("Lock:Contact:" .. chat_id, "Warn")
                elseif redis:get("Lock:Contact:" .. chat_id) == "Warn" then
                  redis:set("Lock:Contact:" .. chat_id, "Ban")
                elseif redis:get("Lock:Contact:" .. chat_id) == "Ban" then
                  redis:set("Lock:Contact:" .. chat_id, "Mute")
                elseif redis:get("Lock:Contact:" .. chat_id) == "Mute" then
                  redis:set("Lock:Contact:" .. chat_id, "Enable")
                elseif redis:get("Lock:Contact:" .. chat_id) == "Enable" then
                  redis:del("Lock:Contact:" .. chat_id)
                end
                Page5(msg, chat_id)
              end
              if LeaderCode == "lockcaption:" .. chat_id then
                if not redis:get("Lock:Caption:" .. chat_id) then
                  redis:set("Lock:Caption:" .. chat_id, "Kick")
                elseif redis:get("Lock:Caption:" .. chat_id) == "Kick" then
                  redis:set("Lock:Caption:" .. chat_id, "Warn")
                elseif redis:get("Lock:Caption:" .. chat_id) == "Warn" then
                  redis:set("Lock:Caption:" .. chat_id, "Ban")
                elseif redis:get("Lock:Caption:" .. chat_id) == "Ban" then
                  redis:set("Lock:Caption:" .. chat_id, "Mute")
                elseif redis:get("Lock:Caption:" .. chat_id) == "Mute" then
                  redis:set("Lock:Caption:" .. chat_id, "Enable")
                elseif redis:get("Lock:Caption:" .. chat_id) == "Enable" then
                  redis:del("Lock:Caption:" .. chat_id)
                end
                Page5(msg, chat_id)
              end
              if LeaderCode == "locktag:" .. chat_id then
                if not redis:get("Lock:Tag:" .. chat_id) then
                  redis:set("Lock:Tag:" .. chat_id, "Kick")
                elseif redis:get("Lock:Tag:" .. chat_id) == "Kick" then
                  redis:set("Lock:Tag:" .. chat_id, "Warn")
                elseif redis:get("Lock:Tag:" .. chat_id) == "Warn" then
                  redis:set("Lock:Tag:" .. chat_id, "Ban")
                elseif redis:get("Lock:Tag:" .. chat_id) == "Ban" then
                  redis:set("Lock:Tag:" .. chat_id, "Mute")
                elseif redis:get("Lock:Tag:" .. chat_id) == "Mute" then
                  redis:set("Lock:Tag:" .. chat_id, "Enable")
                elseif redis:get("Lock:Tag:" .. chat_id) == "Enable" then
                  redis:del("Lock:Tag:" .. chat_id)
                end
                Page2(msg, chat_id)
              end
              if LeaderCode == "lockfwduser:" .. chat_id then
                if not redis:get("Lock:Fwduser:" .. chat_id) then
                  redis:set("Lock:Fwduser:" .. chat_id, "Kick")
                elseif redis:get("Lock:Fwduser:" .. chat_id) == "Kick" then
                  redis:set("Lock:Fwduser:" .. chat_id, "Warn")
                elseif redis:get("Lock:Fwduser:" .. chat_id) == "Warn" then
                  redis:set("Lock:Fwduser:" .. chat_id, "Ban")
                elseif redis:get("Lock:Fwduser:" .. chat_id) == "Ban" then
                  redis:set("Lock:Fwduser:" .. chat_id, "Mute")
                elseif redis:get("Lock:Fwduser:" .. chat_id) == "Mute" then
                  redis:set("Lock:Fwduser:" .. chat_id, "Enable")
                elseif redis:get("Lock:Fwduser:" .. chat_id) == "Enable" then
                  redis:del("Lock:Fwduser:" .. chat_id)
                end
                Page1(msg, chat_id)
              end
              if LeaderCode == "lockfile:" .. chat_id then
                if not redis:get("Lock:File:" .. chat_id) then
                  redis:set("Lock:File:" .. chat_id, "Kick")
                elseif redis:get("Lock:File:" .. chat_id) == "Kick" then
                  redis:set("Lock:File:" .. chat_id, "Warn")
                elseif redis:get("Lock:File:" .. chat_id) == "Warn" then
                  redis:set("Lock:File:" .. chat_id, "Ban")
                elseif redis:get("Lock:File:" .. chat_id) == "Ban" then
                  redis:set("Lock:File:" .. chat_id, "Mute")
                elseif redis:get("Lock:File:" .. chat_id) == "Mute" then
                  redis:set("Lock:File:" .. chat_id, "Enable")
                elseif redis:get("Lock:File:" .. chat_id) == "Enable" then
                  redis:del("Lock:File:" .. chat_id)
                end
                Page1(msg, chat_id)
              end
              if LeaderCode == "lockfwd:" .. chat_id then
                if not redis:get("Lock:Forward:" .. chat_id) then
                  redis:set("Lock:Forward:" .. chat_id, "Kick")
                elseif redis:get("Lock:Forward:" .. chat_id) == "Kick" then
                  redis:set("Lock:Forward:" .. chat_id, "Warn")
                elseif redis:get("Lock:Forward:" .. chat_id) == "Warn" then
                  redis:set("Lock:Forward:" .. chat_id, "Ban")
                elseif redis:get("Lock:Forward:" .. chat_id) == "Ban" then
                  redis:set("Lock:Forward:" .. chat_id, "Mute")
                elseif redis:get("Lock:Forward:" .. chat_id) == "Mute" then
                  redis:set("Lock:Forward:" .. chat_id, "Enable")
                elseif redis:get("Lock:Forward:" .. chat_id) == "Enable" then
                  redis:del("Lock:Forward:" .. chat_id)
                end
                Page1(msg, chat_id)
              end
              if LeaderCode == "locklink:" .. chat_id then
                if not redis:get("Lock:Link:" .. chat_id) then
                  redis:set("Lock:Link:" .. chat_id, "Kick")
                elseif redis:get("Lock:Link:" .. chat_id) == "Kick" then
                  redis:set("Lock:Link:" .. chat_id, "Warn")
                elseif redis:get("Lock:Link:" .. chat_id) == "Warn" then
                  redis:set("Lock:Link:" .. chat_id, "Ban")
                elseif redis:get("Lock:Link:" .. chat_id) == "Ban" then
                  redis:set("Lock:Link:" .. chat_id, "Mute")
                elseif redis:get("Lock:Link:" .. chat_id) == "Mute" then
                  redis:set("Lock:Link:" .. chat_id, "Enable")
                elseif redis:get("Lock:Link:" .. chat_id) == "Enable" then
                  redis:del("Lock:Link:" .. chat_id)
                end
                Page1(msg, chat_id)
              end
              if LeaderCode == "lockfwdch:" .. chat_id then
                if not redis:get("Lock:Fwdch:" .. chat_id) then
                  redis:set("Lock:Fwdch:" .. chat_id, "Kick")
                elseif redis:get("Lock:Fwdch:" .. chat_id) == "Kick" then
                  redis:set("Lock:Fwdch:" .. chat_id, "Warn")
                elseif redis:get("Lock:Fwdch:" .. chat_id) == "Warn" then
                  redis:set("Lock:Fwdch:" .. chat_id, "Ban")
                elseif redis:get("Lock:Fwdch:" .. chat_id) == "Ban" then
                  redis:set("Lock:Fwdch:" .. chat_id, "Mute")
                elseif redis:get("Lock:Fwdch:" .. chat_id) == "Mute" then
                  redis:set("Lock:Fwdch:" .. chat_id, "Enable")
                elseif redis:get("Lock:Fwdch:" .. chat_id) == "Enable" then
                  redis:del("Lock:Fwdch:" .. chat_id)
                end
                Page1(msg, chat_id)
              end
              if LeaderCode == "lockgame:" .. chat_id then
                if not redis:get("Lock:Game:" .. chat_id) then
                  redis:set("Lock:Game:" .. chat_id, "Kick")
                elseif redis:get("Lock:Game:" .. chat_id) == "Kick" then
                  redis:set("Lock:Game:" .. chat_id, "Warn")
                elseif redis:get("Lock:Game:" .. chat_id) == "Warn" then
                  redis:set("Lock:Game:" .. chat_id, "Ban")
                elseif redis:get("Lock:Game:" .. chat_id) == "Ban" then
                  redis:set("Lock:Game:" .. chat_id, "Mute")
                elseif redis:get("Lock:Game:" .. chat_id) == "Mute" then
                  redis:set("Lock:Game:" .. chat_id, "Enable")
                elseif redis:get("Lock:Game:" .. chat_id) == "Enable" then
                  redis:del("Lock:Game:" .. chat_id)
                end
                Page1(msg, chat_id)
              end
              if LeaderCode == "mutetext:" .. chat_id then
                if redis:get("Lock:Text:" .. chat_id) then
                  redis:del("Lock:Text:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ارسال متن غیرفعال شد")
                else
                  redis:set("Lock:Text:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  ارسال متن فعال شد ")
                end
                Page3(msg, chat_id)
              end
              if LeaderCode == "lock botadder:" .. chat_id then
                if redis:get("Lock:Botadder:" .. chat_id) then
                  redis:del("Lock:Botadder:" .. chat_id)
                  Alert(Leader.id, " قفل ورود ربات و اضافه کننده ربات غیرفعال شد")
                else
                  redis:set("Lock:Botadder:" .. chat_id, "Enable")
                  Alert(Leader.id, " قفل ورود ربات و اضافه کننده ربات فعال شد")
                end
                Page2(msg, chat_id)
              end
              if LeaderCode == "lockbot:" .. chat_id then
                if redis:get("Lock:Bot:" .. chat_id) then
                  redis:del("Lock:Bot:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ورود ربات غیرفعال شد")
                else
                  redis:set("Lock:Bot:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل ورود ربات فعال شد")
                end
                Page2(msg, chat_id)
              end
              if LeaderCode == "lockmen:" .. chat_id then
                if redis:get("Lock:Mention:" .. chat_id) then
                  redis:del("Lock:Mention:" .. chat_id)
                  Alert(Leader.id, "🔓 ")
                else
                  redis:set("Lock:Mention:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 ")
                end
                Page3(msg, chat_id)
              end
              if LeaderCode == "lockjoin:" .. chat_id then
                if not redis:get("Lock:Join:" .. chat_id) then
                  redis:set("Lock:Join:" .. chat_id, "Link")
                elseif redis:get("Lock:Join:" .. chat_id) == "Link" then
                  redis:set("Lock:Join:" .. chat_id, "Add")
                elseif redis:get("Lock:Join:" .. chat_id) == "Add" then
                  redis:del("Lock:Join:" .. chat_id)
                end
                Page3(msg, chat_id)
              end
              if LeaderCode == "lock hashtag:" .. chat_id then
                if redis:get("Lock:Hashtag:" .. chat_id) then
                  redis:del("Lock:Hashtag:" .. chat_id)
                  Alert(Leader.id, " قفل هشتگ غیرفعال شد")
                else
                  redis:set("Lock:Hashtag:" .. chat_id, "Enable")
                  Alert(Leader.id, " قفل  هشتگ فعال  شد")
                end
                Page3(msg, chat_id)
              end
              if LeaderCode == "lockmarkdown:" .. chat_id then
                if redis:get("Lock:Markdown:" .. chat_id) then
                  redis:del("Lock:Markdown:" .. chat_id)
                  Alert(Leader.id, "  قفل نشانه گذاری غیرفعال شد ! 🔓")
                else
                  redis:set("Lock:Markdown:" .. chat_id, "Enable")
                  Alert(Leader.id, "  قفل نشانه گذاری غیرفعال شد ! 🔒")
                end
                Page3(msg, chat_id)
              end
              if LeaderCode == "lockeditt:" .. chat_id then
                if redis:get("Lock:Edit:" .. chat_id) then
                  redis:del("Lock:Edit:" .. chat_id)
                else
                  redis:set("Lock:Edit:" .. chat_id, "Enable")
                end
                Page3(msg, chat_id)
              end
              if LeaderCode == "lock bio:" .. chat_id then
                if redis:get("Lock:bio:" .. chat_id) then
                  redis:del("Lock:bio:" .. chat_id)
                  Alert(Leader.id, "قفل بیوگررافی غیرفعال شد")
                else
                  redis:set("Lock:bio:" .. chat_id, "Enable")
                  Alert(Leader.id, "قفل بیوگررافی فعال شد")
                end
                Page2(msg, chat_id)
              end
              if LeaderCode == "lockenglish:" .. chat_id then
                if redis:get("Lock:English:" .. chat_id) then
                  redis:del("Lock:English:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل زبان انگلیسی غیرفعال شد")
                else
                  redis:set("Lock:English:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل زبان انگلیسی فعال شد")
                end
                Page2(msg, chat_id)
              end
              if LeaderCode == "lockarabic:" .. chat_id then
                if redis:get("Lock:Farsi:" .. chat_id) then
                  redis:del("Lock:Farsi:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل زبان فارسی غیرفعال شد")
                else
                  redis:set("Lock:Farsi:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل زبان فارسی فعال شد")
                end
                Page2(msg, chat_id)
              end
              if LeaderCode == "lockfosh:" .. chat_id then
                if redis:get("Lock:fosh:" .. chat_id) then
                  redis:del("Lock:fosh:" .. chat_id)
                  Alert(Leader.id, " قفل فحش غیرفعال شد")
                else
                  redis:set("Lock:fosh:" .. chat_id, "Enable")
                  Alert(Leader.id, " قفل فحش فعال شد")
                end
                Page4(msg, chat_id)
              end
              if LeaderCode == "lockgroup:" .. chat_id then
                if redis:get("Lock:Group:" .. chat_id) then
                  redis:del("Lock:Group:" .. chat_id)
                  Alert(Leader.id, " قفل گروه غیرفعال شد")
                else
                  redis:set("Lock:Group:" .. chat_id, "Enable")
                  Alert(Leader.id, " قفل گروه فعال شد")
                end
                Page4(msg, chat_id)
              end
              if LeaderCode == "lockcmd:" .. chat_id then
                if redis:get("Lock:Cmd:" .. chat_id) then
                  redis:del("Lock:Cmd:" .. chat_id)
                  Alert(Leader.id, " قفل دستورات برای کاربر عادی غیر فعال شد")
                else
                  redis:set("Lock:Cmd:" .. chat_id, "Enable")
                  Alert(Leader.id, " قفل دستورات برای کاربر عادی فعال شد")
                end
                Page4(msg, chat_id)
              end
              if LeaderCode == "locktgservise:" .. chat_id then
                if redis:get("Lock:Tgservice:" .. chat_id) then
                  redis:del("Lock:Tgservice:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل  حدف پیام ورود خروج غیرفعال شد ")
                else
                  redis:set("Lock:Tgservice:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  حدف پیام ورود خروج فعال شد")
                end
                Page4(msg, chat_id)
              end
              if LeaderCode == "lockweb:" .. chat_id then
                if redis:get("Lock:Web:" .. chat_id) then
                  redis:del("Lock:Web:" .. chat_id)
                  Alert(Leader.id, "قفل صفحات اینترنتی غیرفعال شد")
                else
                  redis:set("Lock:Web:" .. chat_id, "Enable")
                  Alert(Leader.id, "قفل صفحات اینترنتی فعال شد")
                end
                Page4(msg, chat_id)
              end
              if LeaderCode == "mutemusic:" .. chat_id then
                if redis:get("Lock:Music:" .. chat_id) then
                  redis:del("Lock:Music:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ارسال موزیک غیرفعال شد")
                else
                  redis:set("Lock:Music:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  ارسال موزیک فعال شد")
                end
                Page5(msg, chat_id)
              end
              if LeaderCode == "mutevideo:" .. chat_id then
                if redis:get("Lock:Video:" .. chat_id) then
                  redis:del("Lock:Video:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ارسال ویدیو غیرفعال شد")
                else
                  redis:set("Lock:Video:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  ارسال ویدیو فعال شد")
                end
                Page5(msg, chat_id)
              end
              if LeaderCode == "locksticker:" .. chat_id then
                if redis:get("Lock:Sticker:" .. chat_id) then
                  redis:del("Lock:Sticker:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل  استیکر غیرفعال شد")
                else
                  redis:set("Lock:Sticker:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  استیکر فعال شد")
                end
                Page5(msg, chat_id)
              end
              if LeaderCode == "lockstickerm:" .. chat_id then
                if redis:get("Lock:Stickermm:" .. chat_id) then
                  redis:del("Lock:Stickermm:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل  استیکر متحرک غیرفعال شد")
                else
                  redis:set("Lock:Stickermm:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  استیکر متحرک فعال شد")
                end
                Page5(msg, chat_id)
              end
              if LeaderCode == "mutedocument:" .. chat_id then
                if redis:get("Lock:File:" .. chat_id) then
                  redis:del("Lock:File:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ارسال فایل غیرفعال شد")
                else
                  redis:set("Lock:File:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  ارسال فایل فعال شد")
                end
                Page6(msg, chat_id)
              end
              if LeaderCode == "mutephoto:" .. chat_id then
                if redis:get("Lock:Photo:" .. chat_id) then
                  redis:del("Lock:Photo:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ارسال عکس غیرفعال شد")
                else
                  redis:set("Lock:Photo:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  ارسال عکس فعال شد")
                end
                Page6(msg, chat_id)
              end
              if LeaderCode == "mutevoice:" .. chat_id then
                if redis:get("Lock:Voice:" .. chat_id) then
                  redis:del("Lock:Voice:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ارسال صدا غیرفعال شد")
                else
                  redis:set("Lock:Voice:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  ارسال صدا فعال شد")
                end
                Page6(msg, chat_id)
              end
              if LeaderCode == "lockemoji:" .. chat_id then
                if redis:get("Lock:Emoji:" .. chat_id) then
                  redis:del("Lock:Emoji:" .. chat_id)
                  Alert(Leader.id, "قفل اموجی غیرفعال شد")
                else
                  redis:set("Lock:Emoji:" .. chat_id, "Enable")
                  Alert(Leader.id, "قفل اموجی فعال شد")
                end
                Page6(msg, chat_id)
              end
              if LeaderCode == "lockinline:" .. chat_id then
                if redis:get("Lock:Inline:" .. chat_id) then
                  redis:del("Lock:Inline:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل  دکمه شیشه ای غیرفعال شد ")
                else
                  redis:set("Lock:Inline:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  دکمه شیشه ای فعال شد")
                end
                Page6(msg, chat_id)
              end
              if LeaderCode == "mutegif:" .. chat_id then
                if redis:get("Lock:Gif:" .. chat_id) then
                  redis:del("Lock:Gif:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ارسال گیف غیرفعال شد")
                else
                  redis:set("Lock:Gif:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  ارسال گیف فعال شد")
                end
                Page6(msg, chat_id)
              end
              if LeaderCode == "lockvideo_note:" .. chat_id then
                if redis:get("Lock:Videonote:" .. chat_id) then
                  redis:del("Lock:Videonote:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل  فیلم سلفی غیرفعال شد !")
                else
                  redis:set("Lock:Videonote:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل فیلم سلفی فعال شد !")
                end
                Page7(msg, chat_id)
              end
              if LeaderCode == "mutereply:" .. chat_id then
                if redis:get("Lock:Reply:" .. chat_id) then
                  redis:del("Lock:Reply:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ریپلی غیرفعال شد")
                else
                  redis:set("Lock:Reply:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  ریپلی فعال شد")
                end
                Page7(msg, chat_id)
              end
              if LeaderCode == "mutelocation:" .. chat_id then
                if redis:get("Lock:Location:" .. chat_id) then
                  redis:del("Lock:Location:" .. chat_id)
                  Alert(Leader.id, "🔓 قفل ارسال مکان غیرفعال شد")
                else
                  redis:set("Lock:Location:" .. chat_id, "Enable")
                  Alert(Leader.id, "🔒 قفل  ارسال مکان فعال شد")
                end
                Page7(msg, chat_id)
              end
              if LeaderCode == "panelsudo:" .. chat_id .. "" then
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• امار ربات",
                      callback_data = "stats:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیست سودو",
                      callback_data = "sudolist:" .. chat_id
                    },
                    {
                      text = "• راهنما سودو",
                      callback_data = "helpsudo:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیست مسدود همگانی",
                      callback_data = "PageBamAllsudo:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• بستن فهرست سودو",
                      callback_data = "Exit:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "به بخش فهرست مدیریتی ربات مدیریت گروه خوش امدید.\n\nپنل در حال کنترل توسط : [این کاربر](tg://user?id=" .. Leader.from.id .. ") در ساعت " .. os.date("%X") .. "", keyboard, "md")
              end
              if LeaderCode == "PageBamAllsudo:" .. chat_id then
                local Sudolist = redis:smembers("GlobalyBanned:")
                local text = "لیست مسدود همگانی \n\n"
                do
                  do
                    for i, i in pairs(Sudolist) do
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
                if #Sudolist == 0 then
                  text = "لیست  خالی میباشد!"
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "panelsudo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• پاکسازی لیست",
                        callback_data = "PageBamAllsudoiii:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "panelsudo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
                end
              end
              if LeaderCode == "PageBamAllsudoiii:" .. chat_id .. "" then
                if not is_Fullsudo(sender_id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  redis:del("GlobalyBanned:")
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "PageBamAllsudo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, " لیست پاکسازی شد.", keyboard, "html")
                end
              end
              if LeaderCode == "stats:" .. chat_id .. "" then
                local pvs = redis:scard("ChatPrivite")
                local addgps = redis:scard("group:")
                local whoami = io.popen("whoami"):read("*a")
                local uptime = io.popen("uptime"):read("*all")
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• سوپر گروه های ربات : " .. addgps .. "",
                      callback_data = "LeaderCode:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• کاربران خصوصی : " .. pvs .. "",
                      callback_data = "LeaderCode:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• شماره ردیس : " .. rediscode .. "",
                      callback_data = "LeaderCode:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• یوزر : " .. whoami .. "",
                      callback_data = "LeaderCode:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "panelsudo:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, " به بخش امار ربات مدیریت گروه خوش امدید.\n\n• تعداد سوپر گروه ها : " .. addgps .. "\n• تعداد خصوصی ها : " .. pvs .. "\n• شماره ردیس : " .. rediscode .. "\n• یوزر : " .. whoami .. "\n\n (@Developer4)", keyboard, "html")
              end
              if LeaderCode == "sudolist:" .. chat_id then
                local Sudolist = redis:smembers("SUDO-ID")
                local text = "لیست سودو های ربات مدیریت گروه  \n\n"
                do
                  do
                    for i, i in pairs(Sudolist) do
                      local user = getChat(i).result
                      if user and user.username then
                        text = text .. i .. " - [" .. user.username .. "](tg://user?id=" .. i .. ")\n"
                      else
                        text = text .. i .. " - [" .. i .. "](tg://user?id=" .. i .. ")\n"
                      end
                    end
                  end
                end
                if #Sudolist == 0 then
                  text = "لیست سودو خالی میباشد!"
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "panelsudo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
                else
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "• پاکسازی لیست سودو",
                        callback_data = "cleansudo:" .. chat_id
                      }
                    },
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "panelsudo:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
                end
              end
              if LeaderCode == "cleansudo:" .. chat_id .. "" then
                if not is_Fullsudo(Leader.from.id) then
                  Alert(Leader.id, "دسترسی کافی ندارید", true)
                else
                  redis:del("SUDO-ID")
                  local keyboard = {}
                  keyboard.inline_keyboard = {
                    {
                      {
                        text = "برگشت ◄",
                        callback_data = "sudolist:" .. chat_id
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, " لیست سودو های ربات مدیریت گروه   پاکسازی شد.", keyboard, "html")
                end
              end
              if LeaderCode == "/settings_acsuser" .. chat_id then
                local user = Leader.message.entities[1].user.id
                print("" .. user .. "")
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  if redis:sismember("settings_acsuser:" .. chat_id, user) then
                    redis:srem("settings_acsuser:" .. chat_id, user)
                    text = "• دسترسی به تنظیم و حذف برای این مدیر فعال شد !"
                  else
                    redis:sadd("settings_acsuser:" .. chat_id, user)
                    text = "• دسترسی به تنظیمات برای این مدیر غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccessuser(Leader, msg, chat_id, user)
                end
              end
              if LeaderCode == "/locks_acsuser" .. chat_id then
                local user = Leader.message.entities[1].user.id
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  if redis:sismember("locks_acsuser:" .. chat_id, user) then
                    redis:srem("locks_acsuser:" .. chat_id, user)
                    text = "• دسترسی به تغییر قفل ها برای این مدیر فعال شد !"
                  else
                    redis:sadd("locks_acsuser:" .. chat_id, user)
                    text = "• دسترسی به تغییر قفل ها برای این مدیر غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccessuser(Leader, msg, chat_id, user)
                end
              end
              if LeaderCode == "/menu_acsuser" .. chat_id then
                local user = Leader.message.entities[1].user.id
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  if redis:sismember("menu_acsuser:" .. chat_id, user) then
                    redis:srem("menu_acsuser:" .. chat_id, user)
                    text = "• دسترسی به فهرست برای این مدیر فعال شد !"
                  else
                    redis:sadd("menu_acsuser:" .. chat_id, user)
                    text = "• دسترسی به فهرست برای این مدیر غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccessuser(Leader, msg, chat_id, user)
                end
              end
              if LeaderCode == "/users_acsuser" .. chat_id then
                local user = Leader.message.entities[1].user.id
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  if redis:sismember("users_acsuser:" .. chat_id, user) then
                    redis:srem("users_acsuser:" .. chat_id, user)
                    text = "• دسترسی به مدیریت کاربر برای این مدیر فعال شد !"
                  else
                    redis:sadd("users_acsuser:" .. chat_id, user)
                    text = "• دسترسی به مدیریت کاربر برای این مدیر غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccessuser(Leader, msg, chat_id, user)
                end
              end
              if LeaderCode == "/clean_acsuser" .. chat_id then
                local user = Leader.message.entities[1].user.id
                if not is_owner(chat_id, sender_id) then
                  Alert(Leader.id, "شما مالک گروه نیستید")
                else
                  if redis:sismember("acsclean:" .. chat_id, user) then
                    redis:srem("acsclean:" .. chat_id, user)
                    text = "• دسترسی به پاکسازی برای این مدیر فعال شد !"
                  else
                    redis:sadd("acsclean:" .. chat_id, user)
                    text = "• دسترسی به پاکسازی برای این مدیر غیرفعال شد !"
                  end
                  Alert(Leader.id, text, true)
                  ModAccessuser(Leader, msg, chat_id, user)
                end
              end
              if LeaderCode == "help:" .. chat_id .. "" then
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• قفلی",
                      callback_data = "helplock:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• ارتقا و عزل",
                      callback_data = "PromoteDemote:" .. chat_id
                    },
                    {
                      text = "• خوشامدگویی",
                      callback_data = "Wlchelp:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• اجبار ها",
                      callback_data = "ForceADD:" .. chat_id
                    },
                    {
                      text = "• اسپم و هرزنامه",
                      callback_data = "SpamHelp:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• مدیریتی",
                      callback_data = "helpmod:" .. chat_id
                    },
                    {
                      text = "• فلود",
                      callback_data = "FloodHelp:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• محدودیت و رفع",
                      callback_data = "Restricted:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• پاکسازی",
                      callback_data = "helpclean:" .. chat_id
                    },
                    {
                      text = "• تنظیمی",
                      callback_data = "SetHelp:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• سرگرمی",
                      callback_data = "helpfun:" .. chat_id
                    },
                    {
                      text = "• فیلتر",
                      callback_data = "Filterhelp:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• لیستی",
                      callback_data = "helplist:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "panel:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "به بخش راهنما ربات مدیریت گروه خوش امدید.", keyboard, "html")
              end
              if LeaderCode == "PromoteDemote:" .. chat_id .. "" then
                local text = "ا┓\n ‌‌┇بخش راهنما ارتقا و عزل کاربر\n ┇ربات مدیریت گروه لیدر ▸ \nا┛\n\n➏ ارتقا شخص به ادمین ربات و تغیر دسترسی های شخص در ربات :\n» با دستور اول فرد مورد نظر مدیر ربات میشود ، با دستور دوم از مدیریت برکنار میشود\n ɤ      ارتقا مقام\n ɤ      عزل مقام\n ɤ     promote\n ɤ     demote\n─━━━━━━━━─\n➐ دسترسی های کاربر :\n» با دستور اول پنل دسترسی های کاربر باز میشود که میتوانید دسترسی های لازم را بهش داده و یا ازش بگیرید ، با دستور دوم میتوانید وضعیت دسترسی فرد را مشاهده کنید.\n ɤ    دسترسی\n ɤ    دسترسی مدیر\n─━━━━━━━━─\n➑ تنظیم شخص به ادمین گروه و تغیر دسترسی های ادمین گروه :\n» با دستور اول میتوانید مستقیم فرد مورد نظر را به ادمین گروه خود کنید.\nبا دستور دوم از ادمینی برکنار و با دستور سوم پنل دسترسی کاربر باز شده و میتوانید سطح دسترسی فرد را تعین کنید.\n ɤ     تنظیم ادمین . . . .\n ɤ     عزل ادمین . ‌. . .\n ɤ     تنظیم ادمین گروه\n ɤ‌     setadmin\n ɤ     deladmin\n─━━━━━━━━─\n➒ مدیریت کاربر و دسترسی های گروه :\n» با ریپلی روی پیام کاربر و وارد کردن دستور اول پنل مدیریتی شخص ارسال میشود ، که با استفاده از آن به راحتی میتوانید فرد مورد نظر خود را مدیریت کنید. و با دستور دوم میتوانید دسترسی های گروه خود را مشاهده و تغیر دهید.\n ɤ      مدیریت . . . ‌.\n ɤ      دسترسی های گروه\n─━━━━━━━━─\n➓ ارتقا کاربر به مالک گروه :\n» با دستور اول فرد مورد نظر مالک ربات میشود. و با دستور دوم برکنار از مالکیت\n • نکته این دستور به دستور مالک اصلی ربات و سودو عمل میکند.\n ɤ    مالک . . . ‌.\n ɤ    حذف مالک\n ɤ    setowner . . . ‌.\n ɤ    remowner\n─━━━━━━━━─\n⓫ ارتقا کاربر به عضو ویژه گروه :\n» با این دستور میتوانید فرد مورد نظر خود را ویژه و با دستور دوم به کاربر عادی برگردانید\n ɤ    ویژه  . . . .\n ɤ    حذف ویژه \n ɤ    vip  . . . .\n ɤ    remvip \n─━━━━━━━━─\n⓬ فیلتر کردن کلمه ای مورد نظر :\nبا دستور اول میتوانید کلمات مورد نظر خود را فیلتر کنید و با دستور دوم میتوانید کلمه فیلتر شده را از لیست فیلتر حذف نماید.\n ɤ     ( فیلتر ( کلمه \n ɤ     filter ( word )\n ɤ     حذف فیلتر ( کلمه مورد نظر )\n ɤ     unfilter ( word )\n─━━━━━━━━─\n⓭ عزل کردن ادمین اسپمر :\n» در صورت فعال بودن این قابلیت ادمین اسپمر ( دشمن ) هنگام حذف کاربران گروه شما و بعد از اخراج تعداد کاربران تعین شده به طور خودکار توسط ربات ادمینی گروه برکنار میشود.\n ɤ    عزل خودکار فعال\n ɤ    عزل خودکار غیرفعال\n ɤ    ( تنظیم تعداد اخراج ( عدد\n─━━━━━━━━─\n🅲 @Developer4 ◃\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "Filterhelp:" .. chat_id .. "" then
                local text = " ◄ راهنمای فیلتر به شرح زیر است :\n\n• برای فیلتر کردن عبارت یا کلمه ای ، مانند مثال زیر عمل کنید :\n\nا┓\n ‌┇ فیلتر متن مورد نظر\nا┛\n\n• برای حذف فیلتر کردن عبارت یا کلمه ای ، مانند مثال زیر عمل کنید :\n\nا┓\n ‌ حذف فیلتر متن مورد نظر|\nا┛\n\n➖➖➖➖➖➖➖➖➖➖\n\n◄ برای دستورات انگلیسی : \n( Filter Text | Unfilter Text)\n\n➖➖➖➖➖➖➖➖➖➖\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "helplock:" .. chat_id .. "" then
                local text = " ◄ راهنمای قفل های مدیریتی به شرح زیر است :\n\n• برای قفل کردن هر یک از قفل های مدیریتی ربات ، مانند مثال زیر عمل کنید :\n\nا┓\n ‌┇ قفل لینک\nا┛\n\n• برای باز کردن هر یک از قفل های مدیریتی ربات ، مانند مثال زیر عمل کنید :\n\nا┓\n ‌┇ بازکردن لینک\nا┛\n\n➖➖➖➖➖➖➖➖➖➖\n\n▪️همچنین شما میتوانید به جای عبارت لینک از لیست زیر استفاده کنید :\n\n◄ برای دستورات فارسی :\n\n(لینک | گروه | تگ | فروارد | هشتگ | وب | متن | فونت | انگلیسی | فارسی | سرویس تلگرام | منشن | ویرایش | ورود لینک | دستورات | ربات | عکس | فایل | استیکر | فیلم | فیلم سلفی | اسپم | شماره | مخاطب | بازی | اینلاین | موقعیت | گیف | آهنگ | ویس | اضافه کننده ربات | رسانه | ریپلی | بیوگرافی | استیکر متحرک | فلود | فروارد کاربر | ایموجی | ورود ادد | فروارد کانال )\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "helpmod:" .. chat_id .. "" then
                local help = "    ✼ راهنمای تنظیمات گروه ✼ \n\t\n    ↜ قوانین\n    ➢ rules\n    ✦ دریافت قوانین گروه\n     -------------------------------------------\n    ↜ لینک\n    ➢ link\n    ✦ دریافت لینک گروه\n     -------------------------------------------\n    ↜ فهرست\n    ➢ menu\n    ✦ بازکردن فهرست مدیریت گروه\n     -------------------------------------------\n    ↜ راهنما\n    ➢ help\n    ✦ بازکردن فهرست راهنمای ربات\n     -------------------------------------------\n    ↜ فهرست خصوصی\n    ➢ menupv\n    ✦ بازکردن فهرست مدیریت گروه\n\t-------------------------------------------\n\t✼  برای تنظیم کردن زمان پاکسازی پیام ربات توسط ربات :\n    ⇠  پاکسازی پیام ربات  50-1000\n    ➢ Delbotmsg  50-1000\n\t  -------------------------------------------\n\t✼  برای فعالسازی پاکسازی پیام ربات توسط ربات :\n    ⇠  پاکسازی پیام ربات  فعال/غیرفعال\n    ➢ Delbotmsg  on/off\n\t -------------------------------------------\n    ⇠ جواب {روشن,خاموش}\n    ➢ answer {on,off}\n    ✼ برای فعالسازی هوش مصنوعی ربات\n     -------------------------------------------\n    ⇠ جواب \"متن۱\" \"متن۲\"\n    ➢ answer \"txt1\" \"txt2\"\n    ✼ برای تنظیم جواب ربات\n\t-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "► صفحه بعد",
                      callback_data = "helpa:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, help, keyboard, "html")
              end
              if LeaderCode == "helpa:" .. chat_id .. "" then
                local help = "• راهنمای مدیریتی گروه •    \n    ⇠ اعتبار\n    ➟ expire\n    • نمایش مقدار اعتبار گروه\n     -------------------------------------------\n    ⇠ پاکسازی خودکار {فعال ، غیرفعال}\n    ➟ autoclean {bot , helper} \n    • فعال و غیرفعال کردن پاکسازی خودکار پیام های ربات و ربات کمکی\n     -------------------------------------------\n    ⇠  تنظیمات \n    ➢ Settings \n\t✼  برای نمایش تنظیمات اعمال شده در گروه \n\t  -------------------------------------------\n    ⇠ ایدی {ریپلی،یوزرنیم،آیدی}\n    ➟ id {Reply,Username,Id}\n    • دریافت مشخصات شخص\n     -------------------------------------------\n    ⇠ سنجاق {ریپلی}\n    ➟ pin {Reply}\n    • سنجاق کردن پیام\n     -------------------------------------------\n    ⇠ حذف سنجاق\n    ➟ unpin\n    • حذف سنجاق کردن پیام\n\t  -------------------------------------------\n    ⇠ پاکسازی جواب {متن ۱}\n    ➢ rem answer {txt1}\n    ✼ برای پاکسازی متن جواب\n     -------------------------------------------\n    ⇠تنظیم عکس گروه {ریپلی}\n    ➢ setphoto {Reply}\n    ✼ برای تنظیم عکس گروه توسط ربات\n    ⇠ زمان پاکسازی ربات{عدد}\n    ➢ cbmtime {number}\n    ✼ تنظیم حذف پیام ربات\n\t-------------------------------------------\n (@Developer4)\n     -------------------------------------------\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "helpmod:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "► صفحه بعد",
                      callback_data = "helpb:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, help, keyboard, "html")
              end
              if LeaderCode == "helpb:" .. chat_id .. "" then
                local help = "✼ راهنمای تنظیمات گروه ✼    \n    ⇠ پاکسازی خودکار {فعال,غیرفعال} \n    ➢ autoclean {number}\n    ✼ فعال سازی پاکسازی خودکار\n     -------------------------------------------\n\t  ⇠زمان پاکسازی خودکار {عدد به ساعت} \n    ➢ cgmautotime {number}\n    ✼ تنظیم زمان پاکسازی خودکار\n     -------------------------------------------\n    ⇠  قفل گروه  [محدود | حذف پیام]\n    ➢ Lock group  [rcd | delmsg]\n    ✼  برای تنظیم قفل گروه توسط ربات \n\t  -------------------------------------------\n    ⇠  قفل خودکار  00:00-07:00\n    ➢  Autolock  00:00-07:00\n    ✼ برای  تنظیم قفل خودکار توسط ربات\n\t  -------------------------------------------\n    ⇠  قفل خودکار  فعال/غیرفعال\n    ➢ Autolock  on/off\n    ✼ برای فعالسازی قفل خودکار توسط ربات\n\t  -------------------------------------------\n    ⇠  امارگروه \n    ➢ statsgp \n      ✼ برای دریافت امارگروه \n\t  -------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "helpa:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, help, keyboard, "html")
              end
              if LeaderCode == "helplist:" .. chat_id .. "" then
                local text = "◄ راهنمای دریافت لیست به شرح زیر است :\n\n• برای دریافت هرنوع لیستی ، مانند مثال زیر عمل کنید :\n\nا┓\n ‌┇ دستور فارسی ⇜ لیست سکوت\n‌‌ ┇ دستور انگلیسی ⇜ Mutelist\nا┛\n\n➖➖➖➖➖➖➖➖➖➖\n\n▪️همچنین شما میتوانید به جای عبارت  \"لیست سکوت\" یا \"Mutelist\"  از لیست زیر استفاده کنید :\n\n◄ برای دستورات فارسی : \n\n⦗ لیست جواب | لیست قفل پک | لیست ربات ها |  لیست اخطار | لیست فیلتر | لیست مالک | لیست معافان | لیست مدیران | لیست ویژه | لیست مسدود ⦘ \n\n◄ برای دستورات انگلیسی : \n\n⦗ Bots list | Warnlist | Filterlist | Ownerlist | Vipaddlist | Modlist | Viplist | Banlist |\n-------------------------------------------\n (@Developer4)\n\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "helpclean:" .. chat_id .. "" then
                local text = "ا┓\n ‌‌┇ بخش راهنما دستورات پاکسازی\n ┇ ربات مدیریت گروه لیدر ▸ \nا┛─━━━━━━━━━━─\n✷ پاکسازی لیستی :\n\n♼ پاکسازی مدیران\n♼ پاکسازی مالک\n♼ پاکسازی اخطار\n♼ پاکسازی ویژه\n♼ پاکسازی پک\n♼ پاکسازی بیصدا\n♼ پاکسازی مسدود\n♼ پاکسازی فیلتر\n♼ پاکسازی محدود\n♼ پاکسازی معافان\n♼ پاکسازی کاربران\n♼ پاکسازی ربات ها\n♼ پاکسازی تنظیمات\n♼ پاکسازی لیست سیاه\n♼ پاکسازی دلیت اکانت\n♼ پاکسازی لیست جواب\n─━━━━━━━━━━━─\n✷ پاکسازی براساس اسم و بیوگرافی :\n\n♼ مسدود همنام . . . .\n♼ بیصدا همنام . . . ‌‌.\n♼ مسدود بیوگرافی لینک\n♼ بیصدا بیوگرافی لینک\n♼ مسدود بیوگرافی . . . .\n♼ بیصدا بیوگرافی . . . .\n♼ پاکسازی بیوگرافی\n─━━━━━━━━━━━─\n✷ پاکسازی تکی رسانه ها :\n\n♼ پاکسازی عکس\n♼ پاکسازی فیلم\n♼ پاکسازی ویس\n♼ پاکسازی استیکر\n♼ پاکسازی گیف\n♼ پاکسازی اهنگ\n♼ پاکسازی فیلم سلفی\n♼ پاکسازی مخاطب\n♼ پاکسازی فایل\n♼ پاکسازی بازی\n♼ پاکسازی یوزرنیم\n♼ پاکسازی کلمه . . . \n♼ پاکسازی کلمه ها\n♼ پاکسازی متن ها\n─━━━━━━━━━━━─\n✷ پاکسازی کلی پیام ها :\n\n♼ پاکسازی گروه\n♼ پاکسازی پیام ها\n♼ پاکسازی کلی\n─━━━━━━━━━━━─\n✷ پاکسازی خودکار گروه :\n\n ◄ پاکسازی خودکار فعال\n ◄ پاکسازی خودکار غیرفعال \n ◄ زمان پاکسازی 24:00\n ◄ پاکسازی پیام ربات فعال\n ◄ پاکسازی پیام‌‌ ربات غیرفعال\n ◄ زمان پاکسازی پیام ربات .‌‌‌ . . .\n ◄ پاکسازی خوشامد فعال\n ◄ پاکسازی خوشامد غیرفعال\n─━━━━━━━━━━━─\n🅲 @Developer4 ◃\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "SetHelp:" .. chat_id .. "" then
                local text = " ◄ راهنمای تنظیمی به شرح زیر است :\n\n\n◄ برای دستورات فارسی :\n\n(تنظیم اخطار (%d+) | تنظیم قوانین (.*) |تنظیم لینک (.*) | تنظیم نام (.*) | تنظیم درباره گروه (.*) | تنظیم تعداد اخراج (%d+) | حالت اخطار  سکوت / اخراج | )\n\n◄ برای دستورات انگلیسی : \n(setwarn (%d+) | Setrules (.*) | Setlink (.*) | Setname (.*) | Setabout (.*) | Setkick (%d+) )\n\n➖➖➖➖➖➖➖➖➖➖\n\n\n▪️ به جای |عدد| و |(%d+)| عدد به صورت لاتین وارد کنید.\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "Wlchelp:" .. chat_id .. "" then
                local text = " ◄ راهنمای خوشامدگویی به شرح زیر است :\n\n• مانند مثال زیر عمل کنید :\n\nا┓\n ‌┇ خوشامد فعال\n ┇ خوشامد غیرفعال\nا┛\n \n •  برای تنظیم خوشامد مانند مثال زیر عمل کنید :\n\n◄ برای دستورات فارسی :\n\n(تنظیم خوشامد (.*) |  تنظیم خوشامد (.*) ریپلی  /فیلم / گیف / فایل / عکس / آهنگ / عکس)\n\n◄ برای دستورات انگلیسی : \n(Setwelcome (.*))\n\n➖➖➖➖➖➖➖➖➖➖\n •  برای تنظیم حذف پیام خوشامد مانند مثال زیر عمل کنید :\n \nا┓\n ‌┇ پاکسازی خوشامد فعال\n ┇ پاکسازی خوشامد غیرفعال\nا┛\n\n(تنظیم زمان پاکسازی خوشامد (%d+))\n ➖➖➖➖➖➖➖➖➖➖\n▪️ فهرست / تنظیمات / حالت های گروه / صفحه دوم.\n\n\n▪️ به جای |عدد| و |(%d+)| عدد به صورت لاتین وارد کنید.\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "SpamHelp:" .. chat_id .. "" then
                local text = " ◄ راهنمای اسپم و  هرزنامه به شرح زیر است :\n\n• مانند مثال زیر عمل کنید :\n\nا┓\n ‌┇ قفل اسپم\n ┇ بازکردن اسپم\nا┛\n \n •  برای تنظیم اسپم مانند مثال زیر عمل کنید :\n\n◄ برای دستورات فارسی :\n\n(تنظیم کاراکتر (%d+) | )\n\n◄ برای دستورات انگلیسی : \n( Setspam (%d+) |)\n\n➖➖➖➖➖➖➖➖➖➖\n▪️ فهرست / تنظیمات / حالت های گروه / صفحه دوم.\n\n\n▪️ به جای |عدد| و |(%d+)| عدد به صورت لاتین وارد کنید.\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "FloodHelp:" .. chat_id .. "" then
                local text = " ◄ راهنمای فلود و پیام مکرر به شرح زیر است :\n\n• مانند مثال زیر عمل کنید :\n\nا┓\n ‌┇ قفل فلود\n ┇ بازکردن فلود\nا┛\n \n •  برای تنظیم فلود مانند مثال زیر عمل کنید :\n\n◄ برای دستورات فارسی :\n\n(تنظیم پیام مکرر عدد | تنظیم پیام مکرر / اخراج / بیصدا / حذف پیام | تنظیم زمان برسی عدد)\n\n◄ برای دستورات انگلیسی : \n(Setflood / Kick / Mute / Delmsg | setflood (%d+) | setfloodtime (%d+) )\n\n➖➖➖➖➖➖➖➖➖➖\n▪️ فهرست / تنظیمات / حالت های گروه / صفحه دوم.\n\n\n▪️ به جای |عدد| و |(%d+)| عدد به صورت لاتین وارد کنید.\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "Restricted:" .. chat_id .. "" then
                local text = " ا┓\n ‌‌┇بخش محدودیت و رفع...\n ┇ربات مدیریت گروه لیدر\nا┛\n    \n➊ مسدود کردن کاربر :\n» ریپل | یوزرنیم | آیدی شخص :\n ɤ      مسدود  . . . ‌.\n ɤ      حذف مسدود \n ɤ      ban . ‌. . .\n ɤ      unban\n─━━━━━━━━─\n➋ بیصدا کردن کاربر :\n» با دستور اول توانای چت کردن فرد گرفته و با دستور دوم ازاد میشود.\n ɤ     بیصدا  . . . . \n ɤ     حذف بیصدا\n ɤ     Mute . . . .\n ɤ     unsilent\n─━━━━━━━━─\n➌ بیصدا کردن زمانی :\n» با دستور اول فرد مورد نظر به مدت کوتاه از چت کردن محروم، و با دستور سوم ازاد میشود.\n ɤ   .  ‌. . . سکوت\n ɤ    mute . . . . \n ɤ    حذف سکوت\n─━━━━━━━━─\n➍ اخراج کردن کاربر :\n» با دستور اول و دوم فرد مورد نظر از گروه اخراج و با دستور چهارم ازاد میشود.\n ɤ     سیکتیر\n ɤ     اخراج . . . .\n ɤ     kick . . . ‌.\nɤ     حذف مسدود \n─━━━━━━━━─\n➎ اخطار دادن به کاربر  :\n» با دستور اول فرد مورد نظر اخطار میگیرد ، و با دستور دوم حذف اخطار میشود\n ɤ     اخطار . . . .\n ɤ     حذف اخطار\n ɤ     warn . . . ‌.\n ɤ     unwarn\n─━━━━━━━━─\n➑ مدیریت کاربر :\n» با این دستور ربات پنل  کاربر را ارسال میکند که به راحتی میتوانید با استفاده از پنل شیشه ای فرد مورد نظر خود را مدیریت کنید\n ɤ      مدیریت . . . ‌.\n─━━━━━━━━─\n🅲 @Developer4 ◃\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text .. "<a href='https://t.me/UraxTelegram/20'>​​​​​​​​​​​​​​​​​​​​​ </a>", keyboard, "html")
              end
              if LeaderCode == "ForceADD:" .. chat_id .. "" then
                local text = "◄ دستورات اداجباری :\n\n⦗ اداجباری فعال / غیرفعال | ریست اداجباری | تنظیم اداجباری همه / جدید | تنظیم اداجباری عدد | تنظیم اخطار اداجباری عدد ⦘ \n\n◄ دستورات اجبار عضویت در کانال گروه :\n\n(اجبارعضویت فعال/غیرفعال | تنظیم کانال ایدی کانال | حذف کانال\n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "helpfun:" .. chat_id .. "" then
                local text = "◄ دستورات فان :\n\n⦗ ترجمه | ساخت گیف متن | فال | شعر | جوک | تبدیل به عکس | تبدیل به استیکر | موزیک اسم خواننده | بگو متن | ترافیک اسم شهر ⦘ \n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "help:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "html")
              end
              if LeaderCode == "helpsudo:" .. chat_id .. "" then
                local help = "*راهنما سودو\n ربات مدیریت گروه*\n     -------------------------------------------\n    ↜ افزودن سودو {ریپلی،یوزرنیم،آیدی}\n    ➢ Setsudo {Reply,Username,Id}\n    ✦ برای تنظیم کردن فرد به رسانه سودو ربات \n     -------------------------------------------\n    ↜حذف سودو {ریپلی،یوزرنیم،آیدی}\n    ➢ Remsudo {Reply,Username,Id}\n    ✦ برای حذف کرد فرد از رسانه سودو ربات \n     -------------------------------------------\n    ↜ لیست سودو \n    ➢ Sudolist\n    ✦  برای دربافت لیست سودو توسط ربات \n     -------------------------------------------\n    ↜ پاکسازی سودو\n    ➢ Clean sudos\n    ✦ برای پاکسازی لیست سودو توسط ربات\n     -------------------------------------------\n    ↜ نصب\n    ➢ Add\n    ✦ برای نصب ربات درگروه توسط ربات\n     -------------------------------------------\n    ↜ حذف گروه\n    ➢ rem\n    ✦  برای حذف نصب درگروه توسط ربات\n     -------------------------------------------\n    ↜ شارژ روز\n    ➢ Charge day\n    ✦ برای تنظیم کردن شارژ گروه توسط ربات\n     -------------------------------------------\n    ↜ مسدودهمگانی {ریپلی،یوزرنیم،آیدی}\n    ➢ Banall {Reply,Username,Id}\n    ✦ برای مسدود همگانی از گروه ها توسط ربات\n     -------------------------------------------\n    ↜ حذف مسدودهمگانی {ریپلی،یوزرنیم،آیدی}\n    ➢ unbanall {Reply,Username,Id}\n    ✦  برای حذف از مسدود همگانی از گروه ها توسط ربات \n\t  -------------------------------------------\n\t↜ لیست مسدود همگانی\n    ➢ gbanlist\n    ✦ برای دریافت لیست مسدود همگانی توسط ربات\n     -------------------------------------------\n    ↜ بیصدا همگانی{ریپلی،یوزرنیم،آیدی}\n    ➢ mutealluser {Reply,Username,Id}\n    ✦ برای بیصدا همگانی از تمام گروه ها\n     -------------------------------------------\n    ↜حذف بیصدا همگانی {ریپلی،یوزرنیم،آیدی}\n    ➢ unmutealluser {Reply,Username,Id}\n    ✦ برای حذف بیصدا همگانی از تمام گروه ها\n\t  -------------------------------------------\n\t↜ لیست بیصدا همگانی\n    ➢ mutealllist\n    ✦ برای نامحدود کردن شارژ گروه توسط ربات\n     -------------------------------------------\n    ↜ پاکسازی مسدود همگانی\n    ➢ Clean gbans\n    ✦ برای پاکسازی لیست مسدود همگانی توسط ربات\n     -------------------------------------------\n    ↜ پاکسازی بیصدا همگانی\n    ➢ clean mutealllist\n    ✦ برای پاکسازی لیست بیصدا همگانی\n\t  -------------------------------------------\n\t↜مالک {ریپلی،یوزرنیم،آیدی}\n    ➢ Setowner {Reply,Username,Id}\n    ✦ برای تنظیم مالک گروه توسط ربات\n     -------------------------------------------\n    ↜حذف مالک {ریپلی،یوزرنیم،آیدی}\n    ➢ Remowner {Reply,Username,Id}\n    ✦ برای تنظیم حذف مالک گروه توسط ربات \n\t  -------------------------------------------\n\t↜ لیست مالک \n    ➢ Ownerlist\n    ✦ برای دریافت لیست صاحبان توسط ربات\n     -------------------------------------------\n\t↜ پاکسازی مالک\n    ✦ Clean owners\n    ✦ برای پاکسازی لیست صاحبان توسط ربات \n     -------------------------------------------\n    ↜ ریلود\n    ➢ Reload\n    ✦ برای بازنگری ربات توسط ربات \n     -------------------------------------------\n\t↜ پیکربندی \n    ➢ Config\n    ✦ برای ارتقا اعضا گروه فرد توسط ربات \n     -------------------------------------------\n\t↜ فوروارد \n    ➢ Fwd {All,sgps,gps,pv}\n    ✦ برای فوروارد به گروه ها توسط ربات \n     -------------------------------------------\n\t↜ پاکسازی کاربران \n    ➢ Clean members    \n    ✦  برای پاکسازی اعضا توسط ربات \n     -------------------------------------------\n\t↜ لیست گروه ها \n    ➢ Chats \n    ✦  برای دریافت لیست گروه ها توسط ربات \n-------------------------------------------\n (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "panelsudo:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "► صفحه بعد",
                      callback_data = "helpsudoooooo:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, help, keyboard, "html")
              end
              if LeaderCode == "helpsudoooooo:" .. chat_id .. "" then
                local help = "   *راهنما سودو\n ربات مدیریت گروه*\n     -------------------------------------------\n\t↜ اعتبار \n    ➢ Expire \n    ✦  برای دریافت اعتبار گروه توسط ربات \n     -------------------------------------------\n\t↜ اعتبار  ایدی گروه\n    ➢ Expire  groupid\n    ✦  برای دریافت اعتبار گروهی توسط ربات \n     -------------------------------------------\n\t↜ خروج \n    ➢ Leave \n    ✦ برای خروج ربات از گروه توسط ربات \n     -------------------------------------------\n\t↜ خروج  ایدی گروه\n    ➢ Leave  groupid\n    ✦  برای خروج ربات از گروهی توسط ربات \n     -------------------------------------------\n\t↜ جوین اجباری  فعال/غیرفعال\n    ➢ Forcejoin  on/off\n    ✦ برای فعالسازی جوین اجباری توسط ربات\n     -------------------------------------------\n\t↜ شارژ هدیه عدد \n    ➢ addcharge  number\n    ✦ برای اضافه کردن شارژ همگانی گروه ها\n     -------------------------------------------\n\t↜ تنظیم بیوربات متن  \n    ➢ Setbio  text\n\t✦ برای تنظیم بیوگرافی ربات\n     -------------------------------------------\n    ✦ برای تنظیم نام ربات:\n    ✦ setbotname  txt \n     -------------------------------------------\n\t↜ شماره ربات  \n    ➢ botphone \n    ✦ برای دریافت شماره ربات\n     -------------------------------------------\n\t↜ ذخیره شماره  ریپلی\n    ➢ addc \n    ✦ برای ذخیره مخاطب توسط ربات:\n     -------------------------------------------\n    ➢ start  یوزرنیم\n    ✦  برای استارت ربات Apiتوسط ربات:\n     -------------------------------------------\n\t↜  تنظیم نرخ  متن \n    ➢  setnerkh  txt\n    ✦  برای تنظیم نرخ توسط ربات\n     -------------------------------------------\n\t↜ فهرست سودو  \n    ➢  menu sudo \n    ✦  برای دریافت فهرست شیشه ای سودو توسط ربات\n     -------------------------------------------\n\t↜ آمار  \n    ➢ stats \n    ✦  برای دریافت آمار توسط ربات \n\t (@Developer4)\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "helpsudo:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, help, keyboard, "html")
              end
              function remoteures(msg, chat_id, user, name)
                local user = Leader.message.entities[1].user.id
                if redis:get("changgo:" .. chat_id .. user) then
                  infogp = "|✅|"
                else
                  infogp = "|✗|"
                end
                if redis:get("resmm:" .. chat_id .. user) then
                  resmember = "|✅|"
                else
                  resmember = "|✗|"
                end
                if redis:get("pinmm:" .. chat_id .. user) then
                  pinmsage = "|✅|"
                else
                  pinmsage = "|✗|"
                end
                if redis:get("delmsgg:" .. chat_id .. user) then
                  delmsgsgp = "|✅|"
                else
                  delmsgsgp = "|✗|"
                end
                if redis:get("invblink:" .. chat_id .. user) then
                  invbylink = "|✅|"
                else
                  invbylink = "|✗|"
                end
                if redis:get("adadmin:" .. chat_id .. user) then
                  addadmin = "|✅|"
                else
                  addadmin = "|✗|"
                end
                ehsan = "<a href=\"tg://user?id=" .. user .. "\">" .. check_html(name) .. "</a>"
                local BD = "مدیریت کاربر:【" .. ehsan .. "】\nدر گروه : " .. GpName .. "\n بروز رسانی در ساعت [" .. os.date("%X") .. "]"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• تغییر اطلاعات گروه " .. infogp .. "",
                      callback_data = "etal:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• اخراج و محدود کردن کاربر " .. resmember .. "",
                      callback_data = "mah:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• سنجاق کردن پیام ها " .. pinmsage .. "",
                      callback_data = "sanj:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• حذف پیام ها " .. delmsgsgp .. "",
                      callback_data = "delmsggg:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• دعوت با لینک " .. invbylink .. "",
                      callback_data = "invblinkk:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• ارتقا به ادمین" .. addadmin .. "",
                      callback_data = "adadminn:" .. chat_id
                    }
                  },
                  {
                    {
                      text = "• تایید تغییرات",
                      callback_data = "setetla:" .. chat_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, BD, keyboard, "html")
              end
              
              if LeaderCode == "sanj:" .. chat_id .. "" then
                if redis:get("pinmm:" .. chat_id .. Leader.message.entities[1].user.id) then
                  redis:del("pinmm:" .. chat_id .. Leader.message.entities[1].user.id)
                  Alert(Leader.id, "دسترسی سنجاق از این شخص گرفته شد", true)
                else
                  MSG_MAX = tonumber(1)
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_pin_messages then
                    redis:set("pinmm:" .. chat_id .. Leader.message.entities[1].user.id, MSG_MAX)
                    Alert(Leader.id, "به شخص دسترسی سنجاق پیام داده شد از این به بعد میتواند پیامی را از سنجاق بردارد یا سنجاق کند", true)
                  else
                    Alert(Leader.id, "این دسترسی برای ربات فعال نیست", true)
                  end
                end
                remoteures(msg, chat_id, Leader.message.entities[1].user.id, Leader.message.entities[1].user.first_name)
              end
              if LeaderCode == "delmsggg:" .. chat_id .. "" then
                if redis:get("delmsgg:" .. chat_id .. Leader.message.entities[1].user.id) then
                  redis:del("delmsgg:" .. chat_id .. Leader.message.entities[1].user.id)
                  Alert(Leader.id, "دسترسی حذف پیام از شخص گرفته شد", true)
                else
                  MSG_MAX = tonumber(1)
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_delete_messages then
                    redis:set("delmsgg:" .. chat_id .. Leader.message.entities[1].user.id, MSG_MAX)
                    Alert(Leader.id, "شخص میتواند پیام ها را پاکسازی کنید", true)
                  else
                    Alert(Leader.id, "این دسترسی برای ربات فعال نیست", true)
                  end
                end
                remoteures(msg, chat_id, Leader.message.entities[1].user.id, Leader.message.entities[1].user.first_name)
              end
              if LeaderCode == "invblinkk:" .. chat_id .. "" then
                if redis:get("invblink:" .. chat_id .. Leader.message.entities[1].user.id) then
                  redis:del("invblink:" .. chat_id .. Leader.message.entities[1].user.id)
                  Alert(Leader.id, "دسترسی دعوت با لینک از این شخص گرفته شد", true)
                else
                  MSG_MAX = tonumber(1)
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_invite_users then
                    redis:set("invblink:" .. chat_id .. Leader.message.entities[1].user.id, MSG_MAX)
                    Alert(Leader.id, "شخص میتواند کاربری را به گروه دعوت کنید", true)
                  else
                    Alert(Leader.id, "این دسترسی برای ربات فعال نیست", true)
                  end
                end
                remoteures(msg, chat_id, Leader.message.entities[1].user.id, Leader.message.entities[1].user.first_name)
              end
              if LeaderCode == "adadminn:" .. chat_id .. "" then
                if redis:get("adadmin:" .. chat_id .. Leader.message.entities[1].user.id) then
                  redis:del("adadmin:" .. chat_id .. Leader.message.entities[1].user.id)
                  Alert(Leader.id, "دسترسی ارتقا به ادمین از این شخص گرفته شد", true)
                else
                  MSG_MAX = tonumber(1)
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_promote_members then
                    redis:set("adadmin:" .. chat_id .. Leader.message.entities[1].user.id, MSG_MAX)
                    Alert(Leader.id, "شخص میتواند کاربری را به ادمین گروه ارتقا دهد", true)
                  else
                    Alert(Leader.id, "این دسترسی برای ربات فعال نیست", true)
                  end
                end
                remoteures(msg, chat_id, Leader.message.entities[1].user.id, Leader.message.entities[1].user.first_name)
              end
              if LeaderCode == "mah:" .. chat_id .. "" then
                if redis:get("resmm:" .. chat_id .. Leader.message.entities[1].user.id) then
                  redis:del("resmm:" .. chat_id .. Leader.message.entities[1].user.id)
                  Alert(Leader.id, "دسترسی اخراج و محدود کاربر از شخص گرفته شد", true)
                else
                  MSG_MAX = tonumber(1)
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_restrict_members then
                    redis:set("resmm:" .. chat_id .. Leader.message.entities[1].user.id, MSG_MAX)
                    Alert(Leader.id, "شخص میتواند کاربران را اخراج یا محدود کند", true)
                  else
                    Alert(Leader.id, "این دسترسی برای ربات فعال نیست", true)
                  end
                end
                remoteures(msg, chat_id, Leader.message.entities[1].user.id, Leader.message.entities[1].user.first_name)
              end
              if LeaderCode == "etal:" .. chat_id .. "" then
                local user = Leader.message.entities[1].user.id
                if redis:get("changgo:" .. chat_id .. Leader.message.entities[1].user.id) then
                  redis:del("changgo:" .. chat_id .. Leader.message.entities[1].user.id)
                  Alert(Leader.id, "دسترسی تغییر اطلاعات از شخص گرفته شد", true)
                else
                  MSG_MAX = tonumber(1)
                  local aa = getChatMember(chat_id, BotHelper).result
                  if aa.can_change_info then
                    redis:set("changgo:" .. chat_id .. Leader.message.entities[1].user.id, MSG_MAX)
                    Alert(Leader.id, "شخص میتواند اطلاعات گروه را تغییر دهد", true)
                  else
                    Alert(Leader.id, "این دسترسی برای ربات فعال نیست", true)
                  end
                end
                remoteures(msg, chat_id, Leader.message.entities[1].user.id, Leader.message.entities[1].user.first_name)
              end
              if LeaderCode == "setetla:" .. chat_id .. "" then
                local user = Leader.message.entities[1].user.id
                redis:sadd("ModList:" .. chat_id, user)
                can_change_info = redis:get("changgo:" .. chat_id .. user) or 0
                can_post_messages = 0
                can_edit_messages = redis:get("editmm:" .. chat_id .. user) or 0
                can_delete_messages = redis:get("delmsgg:" .. chat_id .. user) or 0
                can_invite_users = redis:get("invblink:" .. chat_id .. user) or 0
                can_restrict_members = redis:get("resmm:" .. chat_id .. user) or 0
                can_pin_messages = redis:get("pinmm:" .. chat_id .. user) or 0
                can_promote_members = redis:get("adadmin:" .. chat_id .. user) or 0
                promoteChatMember(msg.chat_id, user, can_change_info, can_post_messages, can_edit_messages, can_delete_messages, can_invite_users, can_restrict_members, can_pin_messages, can_promote_members)
                can_change_infos = redis:get("changgo:" .. chat_id .. user) and "[✓]" or "[✘]"
                can_delete_messagess = redis:get("delmsgg:" .. chat_id .. user) and "[✓]" or "[✘]"
                can_restrict_memberss = redis:get("resmm:" .. chat_id .. user) and "[✓]" or "[✘]"
                can_promote_memberss = redis:get("adadmin:" .. chat_id .. user) and "[✓]" or "[✘]"
                can_pin_messagess = redis:get("pinmm:" .. chat_id .. user) and "[✓]" or "[✘]"
                can_invite_userss = redis:get("invblink:" .. chat_id .. user) and "[✓]" or "[✘]"
                output = "دسترسی شخص :\n\nوضعیت ادمین بودن: " .. can_restrict_memberss .. "\nاخراج و محدود کردن : " .. can_restrict_memberss .. "\nتغییر اطلاعات گروه : " .. can_change_infos .. "\nارتقا به ادمین : " .. can_promote_memberss .. "\nسنجاق پیام : " .. can_pin_messagess .. "\nحذف پیام : " .. can_delete_messagess .. "\n دعوت کاربران با لینک : " .. can_invite_userss
                Edit(msg.chat_id, msg.inline_id, output, nil, "md")
                redis:del("changgo:" .. chat_id .. user)
                redis:del("editmm:" .. chat_id .. user)
                redis:del("delmsgg:" .. chat_id .. user)
                redis:del("invblink:" .. chat_id .. user)
                redis:del("resmm:" .. chat_id .. user)
                redis:del("pinmm:" .. chat_id .. user)
                redis:del("adadmin:" .. chat_id .. user)
              end
              if LeaderCode == "AccessGp:AccessWeb" .. chat_id then
                if getChat(chat_id).result.permissions.can_add_web_page_previews then
                  AccessWeb = false
                else
                  AccessWeb = true
                end
                AccessOther = getChat(chat_id).result.permissions.can_send_other_messages
                AccessPolls = getChat(chat_id).result.permissions.can_send_polls
                AccessMedia = getChat(chat_id).result.permissions.can_send_media_messages
                AccessChangeInfo = getChat(chat_id).result.permissions.can_change_info
                AccessInviteUsers = getChat(chat_id).result.permissions.can_invite_users
                AccessPinMessage = getChat(chat_id).result.permissions.can_pin_messages
                AccessSendMessage = getChat(chat_id).result.permissions.can_send_messages
                Permissions = {
                  can_send_messages = AccessSendMessage,
                  can_send_media_messages = AccessMedia,
                  can_send_other_messages = AccessOther,
                  can_send_polls = AccessPolls,
                  can_change_info = AccessChangeInfo,
                  can_invite_users = AccessInviteUsers,
                  can_pin_messages = AccessPinMessage,
                  can_add_web_page_previews = AccessWeb
                }
                setChatPermissions(chat_id, Permissions)
                ChatPermissions(msg, chat_id)
              end
              if LeaderCode == "AccessGp:AccessOther" .. chat_id then
                if getChat(chat_id).result.permissions.can_send_other_messages then
                  AccessOther = false
                else
                  AccessOther = true
                end
                AccessWeb = getChat(chat_id).result.permissions.can_add_web_page_previews
                AccessPolls = getChat(chat_id).result.permissions.can_send_polls
                AccessMedia = getChat(chat_id).result.permissions.can_send_media_messages
                AccessChangeInfo = getChat(chat_id).result.permissions.can_change_info
                AccessInviteUsers = getChat(chat_id).result.permissions.can_invite_users
                AccessPinMessage = getChat(chat_id).result.permissions.can_pin_messages
                AccessSendMessage = getChat(chat_id).result.permissions.can_send_messages
                Permissions = {
                  can_send_messages = AccessSendMessage,
                  can_send_media_messages = AccessMedia,
                  can_send_other_messages = AccessOther,
                  can_send_polls = AccessPolls,
                  can_change_info = AccessChangeInfo,
                  can_invite_users = AccessInviteUsers,
                  can_pin_messages = AccessPinMessage,
                  can_add_web_page_previews = AccessWeb
                }
                setChatPermissions(chat_id, Permissions)
                ChatPermissions(msg, chat_id)
              end
              if LeaderCode == "AccessGp:AccessPolls" .. chat_id then
                if getChat(chat_id).result.permissions.can_send_polls then
                  AccessPolls = false
                else
                  AccessPolls = true
                end
                AccessOther = getChat(chat_id).result.permissions.can_send_other_messages
                AccessWeb = getChat(chat_id).result.permissions.can_add_web_page_previews
                AccessMedia = getChat(chat_id).result.permissions.can_send_media_messages
                AccessChangeInfo = getChat(chat_id).result.permissions.can_change_info
                AccessInviteUsers = getChat(chat_id).result.permissions.can_invite_users
                AccessPinMessage = getChat(chat_id).result.permissions.can_pin_messages
                AccessSendMessage = getChat(chat_id).result.permissions.can_send_messages
                Permissions = {
                  can_send_messages = AccessSendMessage,
                  can_send_media_messages = AccessMedia,
                  can_send_other_messages = AccessOther,
                  can_send_polls = AccessPolls,
                  can_change_info = AccessChangeInfo,
                  can_invite_users = AccessInviteUsers,
                  can_pin_messages = AccessPinMessage,
                  can_add_web_page_previews = AccessWeb
                }
                setChatPermissions(chat_id, Permissions)
                ChatPermissions(msg, chat_id)
              end
              if LeaderCode == "AccessGp:AccessMedia" .. chat_id then
                if getChat(chat_id).result.permissions.can_send_media_messages then
                  AccessMedia = false
                else
                  AccessMedia = true
                end
                AccessOther = getChat(chat_id).result.permissions.can_send_other_messages
                AccessPolls = getChat(chat_id).result.permissions.can_send_polls
                AccessWeb = getChat(chat_id).result.permissions.can_add_web_page_previews
                AccessChangeInfo = getChat(chat_id).result.permissions.can_change_info
                AccessInviteUsers = getChat(chat_id).result.permissions.can_invite_users
                AccessPinMessage = getChat(chat_id).result.permissions.can_pin_messages
                AccessSendMessage = getChat(chat_id).result.permissions.can_send_messages
                Permissions = {
                  can_send_messages = AccessSendMessage,
                  can_send_media_messages = AccessMedia,
                  can_send_other_messages = AccessOther,
                  can_send_polls = AccessPolls,
                  can_change_info = AccessChangeInfo,
                  can_invite_users = AccessInviteUsers,
                  can_pin_messages = AccessPinMessage,
                  can_add_web_page_previews = AccessWeb
                }
                setChatPermissions(chat_id, Permissions)
                ChatPermissions(msg, chat_id)
              end
              if LeaderCode == "AccessGp:AccessChangeInfo" .. chat_id then
                if getChat(chat_id).result.permissions.can_change_info then
                  AccessChangeInfo = false
                else
                  AccessChangeInfo = true
                end
                AccessOther = getChat(chat_id).result.permissions.can_send_other_messages
                AccessPolls = getChat(chat_id).result.permissions.can_send_polls
                AccessMedia = getChat(chat_id).result.permissions.can_send_media_messages
                AccessWeb = getChat(chat_id).result.permissions.can_add_web_page_previews
                AccessInviteUsers = getChat(chat_id).result.permissions.can_invite_users
                AccessPinMessage = getChat(chat_id).result.permissions.can_pin_messages
                AccessSendMessage = getChat(chat_id).result.permissions.can_send_messages
                Permissions = {
                  can_send_messages = AccessSendMessage,
                  can_send_media_messages = AccessMedia,
                  can_send_other_messages = AccessOther,
                  can_send_polls = AccessPolls,
                  can_change_info = AccessChangeInfo,
                  can_invite_users = AccessInviteUsers,
                  can_pin_messages = AccessPinMessage,
                  can_add_web_page_previews = AccessWeb
                }
                setChatPermissions(chat_id, Permissions)
                ChatPermissions(msg, chat_id)
              end
              if LeaderCode == "AccessGp:AccessInviteUsers" .. chat_id then
                if getChat(chat_id).result.permissions.can_invite_users then
                  AccessInviteUsers = false
                else
                  AccessInviteUsers = true
                end
                AccessOther = getChat(chat_id).result.permissions.can_send_other_messages
                AccessPolls = getChat(chat_id).result.permissions.can_send_polls
                AccessMedia = getChat(chat_id).result.permissions.can_send_media_messages
                AccessChangeInfo = getChat(chat_id).result.permissions.can_change_info
                AccessWeb = getChat(chat_id).result.permissions.can_add_web_page_previews
                AccessPinMessage = getChat(chat_id).result.permissions.can_pin_messages
                AccessSendMessage = getChat(chat_id).result.permissions.can_send_messages
                Permissions = {
                  can_send_messages = AccessSendMessage,
                  can_send_media_messages = AccessMedia,
                  can_send_other_messages = AccessOther,
                  can_send_polls = AccessPolls,
                  can_change_info = AccessChangeInfo,
                  can_invite_users = AccessInviteUsers,
                  can_pin_messages = AccessPinMessage,
                  can_add_web_page_previews = AccessWeb
                }
                setChatPermissions(chat_id, Permissions)
                ChatPermissions(msg, chat_id)
              end
              if LeaderCode == "AccessGp:AccessPinMessage" .. chat_id then
                if getChat(chat_id).result.permissions.can_pin_messages then
                  AccessPinMessage = false
                else
                  AccessPinMessage = true
                end
                AccessOther = getChat(chat_id).result.permissions.can_send_other_messages
                AccessPolls = getChat(chat_id).result.permissions.can_send_polls
                AccessMedia = getChat(chat_id).result.permissions.can_send_media_messages
                AccessChangeInfo = getChat(chat_id).result.permissions.can_change_info
                AccessInviteUsers = getChat(chat_id).result.permissions.can_invite_users
                AccessWeb = getChat(chat_id).result.permissions.can_add_web_page_previews
                AccessSendMessage = getChat(chat_id).result.permissions.can_send_messages
                Permissions = {
                  can_send_messages = AccessSendMessage,
                  can_send_media_messages = AccessMedia,
                  can_send_other_messages = AccessOther,
                  can_send_polls = AccessPolls,
                  can_change_info = AccessChangeInfo,
                  can_invite_users = AccessInviteUsers,
                  can_pin_messages = AccessPinMessage,
                  can_add_web_page_previews = AccessWeb
                }
                setChatPermissions(chat_id, Permissions)
                ChatPermissions(msg, chat_id)
              end
              if LeaderCode == "AccessGp:AccessSendMessage" .. chat_id then
                if getChat(chat_id).result.permissions.can_send_messages then
                  Permissions = {
                    can_send_messages = false,
                    can_send_media_messages = false,
                    can_send_other_messages = false,
                    can_send_polls = false,
                    can_change_info = false,
                    can_invite_users = false,
                    can_pin_messages = false,
                    can_add_web_page_previews = false
                  }
                else
                  Permissions = {
                    can_send_messages = true,
                    can_send_media_messages = true,
                    can_send_other_messages = true,
                    can_send_polls = true,
                    can_change_info = true,
                    can_invite_users = true,
                    can_pin_messages = true,
                    can_add_web_page_previews = true
                  }
                end
                setChatPermissions(chat_id, Permissions)
                ChatPermissions(msg, chat_id)
              end
            end
            if LeaderCode == "Chatps:0" then
              List = redis:smembers("group:")
              if #List == 0 then
                Stext = "• لیست مدیران گروه خالی است !"
              elseif #List > 15 then
                local Stext = "• لیست گروه های مدیریتی :\n\n"
                do
                  do
                    for i = 1, 15 do
                      local check_time = redis:ttl("ExpireData:" .. List[i])
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
                      if 1 < tonumber(check_time) and check_time < 60 then
                        remained_expire = "" .. sec .. " ثانیه"
                      elseif 60 < tonumber(check_time) and check_time < 3600 then
                        remained_expire = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
                      elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
                        remained_expire = "" .. hours .. " ساعت و " .. min .. " دقیقه"
                      elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
                        remained_expire = "" .. day .. " روز و " .. hours .. " ساعت"
                      elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
                        remained_expire = "" .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                      elseif 31536000 < tonumber(check_time) then
                        remained_expire = "" .. year .. " سال " .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                      end
                      if not redis:get("ExpireData:" .. List[i]) then
                        expire = "فاقد اعتبار !"
                      elseif check_time == -1 then
                        expire = "نامحدود !"
                      elseif check_time then
                        expire = "" .. remained_expire .. ""
                      end
                      local GpName = redis:get("StatsGpByName" .. List[i])
                      if GpName then
                        Gp = "" .. GpName .. ""
                      else
                        Gp = "یافت نشد !"
                      end
                      Stext = Stext .. i .. " - " .. Gp .. "\n• شناسه گروه : <code>" .. List[i] .. "</code>\n• اعتبار : " .. expire .. "\n <code>مدیریت گروه " .. List[i] .. "</code> \n➖➖➖➖➖➖➖\n"
                    end
                  end
                end
                local Keyboard = {}
                Keyboard.inline_keyboard = {
                  {
                    {
                      text = "► صفحه بعد",
                      callback_data = "Chatp:1"
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
              elseif #List <= 15 then
                local List = redis:smembers("group:")
                local Stext = "• لیست گروه های مدیریتی :\n\n"
                do
                  do
                    for i = 1, #List do
                      local check_time = redis:ttl("ExpireData:" .. List[i])
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
                      if 1 < tonumber(check_time) and check_time < 60 then
                        remained_expire = "" .. sec .. " ثانیه"
                      elseif 60 < tonumber(check_time) and check_time < 3600 then
                        remained_expire = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
                      elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
                        remained_expire = "" .. hours .. " ساعت و " .. min .. " دقیقه"
                      elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
                        remained_expire = "" .. day .. " روز و " .. hours .. " ساعت"
                      elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
                        remained_expire = "" .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                      elseif 31536000 < tonumber(check_time) then
                        remained_expire = "" .. year .. " سال " .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                      end
                      if not redis:get("ExpireData:" .. List[i]) then
                        expire = "فاقد اعتبار !"
                      elseif check_time == -1 then
                        expire = "نامحدود !"
                      elseif check_time then
                        expire = "" .. remained_expire .. ""
                      end
                      local GpName = redis:get("StatsGpByName" .. List[i])
                      if GpName then
                        Gp = "" .. GpName .. ""
                      else
                        Gp = "یافت نشد !"
                      end
                      Stext = Stext .. i .. " - " .. Gp .. "\n• شناسه گروه : <code>" .. List[i] .. "</code>\n• اعتبار : " .. expire .. "\n <code>مدیریت گروه " .. List[i] .. "</code> \n➖➖➖➖➖➖➖\n"
                    end
                  end
                end
                Edit(msg.chat_id, msg.inline_id, Stext, nil, "html")
              end
            end
            if LeaderCode:match("^Chatp:(%d+)$") then
              local Safhe = LeaderCode:match("^Chatp:(%d+)$")
              List = redis:smembers("group:")
              if #List > Safhe * 15 and #List <= (Safhe + 1) * 15 + Safhe then
                local Stext = "• لیست گروه های مدیریتی :\n( صفحه " .. Safhe + 1 .. [[
 )

]]
                do
                  do
                    for i = Safhe * 14, #List do
                      local check_time = redis:ttl("ExpireData:" .. List[i])
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
                      if 1 < tonumber(check_time) and check_time < 60 then
                        remained_expire = "" .. sec .. " ثانیه"
                      elseif 60 < tonumber(check_time) and check_time < 3600 then
                        remained_expire = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
                      elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
                        remained_expire = "" .. hours .. " ساعت و " .. min .. " دقیقه"
                      elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
                        remained_expire = "" .. day .. " روز و " .. hours .. " ساعت"
                      elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
                        remained_expire = "" .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                      elseif 31536000 < tonumber(check_time) then
                        remained_expire = "" .. year .. " سال " .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                      end
                      if not redis:get("ExpireData:" .. List[i]) then
                        expire = "فاقد اعتبار !"
                      elseif check_time == -1 then
                        expire = "نامحدود !"
                      elseif check_time then
                        expire = "" .. remained_expire .. ""
                      end
                      local GpName = redis:get("StatsGpByName" .. List[i])
                      if GpName then
                        Gp = "" .. GpName .. ""
                      else
                        Gp = "یافت نشد !"
                      end
                      Stext = Stext .. i .. " - " .. Gp .. "\n• شناسه گروه : <code>" .. List[i] .. "</code>\n• اعتبار : " .. expire .. "\n <code>مدیریت گروه " .. List[i] .. "</code> \n➖➖➖➖➖➖➖\n"
                    end
                  end
                end
                if tonumber(Safhe) == 1 then
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "صفحه قبل ◄",
                        callback_data = "Chatps:0"
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                else
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "صفحه قبل ◄",
                        callback_data = "Chatp:" .. tonumber(Safhe - 1)
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                end
              elseif #List >= (Safhe + 1) * 15 + Safhe then
                local Stext = "• لیست گروه های مدیریتی :\n( صفحه " .. Safhe + 1 .. " )\n➖➖➖➖➖➖➖\n"
                do
                  do
                    for i = Safhe * 14, (Safhe + 1) * 15 + Safhe do
                      local check_time = redis:ttl("ExpireData:" .. List[i])
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
                      if 1 < tonumber(check_time) and check_time < 60 then
                        remained_expire = "" .. sec .. " ثانیه"
                      elseif 60 < tonumber(check_time) and check_time < 3600 then
                        remained_expire = "" .. min .. " دقیقه و " .. sec .. " ثانیه"
                      elseif 3600 < tonumber(check_time) and 86400 > tonumber(check_time) then
                        remained_expire = "" .. hours .. " ساعت و " .. min .. " دقیقه"
                      elseif 86400 < tonumber(check_time) and 2592000 > tonumber(check_time) then
                        remained_expire = "" .. day .. " روز و " .. hours .. " ساعت"
                      elseif 2592000 < tonumber(check_time) and 31536000 > tonumber(check_time) then
                        remained_expire = "" .. month .. " ماه " .. day .. " روز و " .. hours .. " ساعت"
                      elseif 31536000 < tonumber(check_time) then
                        remained_expire = "" .. year .. " سال " .. month .. " ماه " .. day .. "روز"
                      end
                      if not redis:get("ExpireData:" .. List[i]) then
                        expire = "فاقد اعتبار !"
                      elseif check_time == -1 then
                        expire = "نامحدود !"
                      elseif check_time then
                        expire = "" .. remained_expire .. ""
                      end
                      local GpName = redis:get("StatsGpByName" .. List[i])
                      if GpName then
                        Gp = "" .. GpName .. ""
                      else
                        Gp = "یافت نشد !"
                      end
                      Stext = Stext .. i .. " - " .. Gp .. "\n• شناسه گروه : <code>" .. List[i] .. "</code>\n• اعتبار : " .. expire .. "\n <code>مدیریت گروه " .. List[i] .. "</code> \n➖➖➖➖➖➖➖\n"
                    end
                  end
                end
                if tonumber(Safhe) == 1 then
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "صفحه قبل ◄",
                        callback_data = "Chatps:0"
                      },
                      {
                        text = "► صفحه بعد",
                        callback_data = "Chatp:2"
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                else
                  local Keyboard = {}
                  Keyboard.inline_keyboard = {
                    {
                      {
                        text = "صفحه قبل ◄",
                        callback_data = "Chatp:" .. tonumber(Safhe - 1)
                      },
                      {
                        text = "► صفحه بعد",
                        callback_data = "Chatp:" .. tonumber(Safhe + 1)
                      }
                    }
                  }
                  Edit(msg.chat_id, msg.inline_id, Stext, Keyboard, "html")
                end
              end
            end
            if LeaderCode == "bk:" .. user_id .. "" then
              old_text = Leader.message.text
              new_text = okname(Leader.from.first_name)
              if not old_text:match("(.*)" .. new_text .. "(.*)") then
                Alert(Leader.id, "شما " .. Leader.from.first_name .. " هم به کیرتان", true)
                local text = "\n"
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "من نیزبه کیرم",
                      callback_data = "bk:" .. user_id
                    }
                  }
                }
                text = text .. old_text .. "\n" .. new_text
                Edit(msg.chat_id, msg.inline_id, text, keyboard, "md")
              else
              end
              Alert(Leader.id, "کاربر " .. Leader.from.first_name .. " مطلب قبلا به کیرتان بود", true)
            end
            if LeaderCode:match("textstart:(%d+)") then
              user_id = LeaderCode:match("textstart:(%d+)")
              local name = Leader.from.first_name
              getuser = "<a href='tg://user?id=" .. sender_id .. "'>" .. check_html(name) .. "</a>"
              local nerkh = redis:get("ner") or "نرخی برای ربات تنظیم نشده است"
              local textstart = redis:get("startmttn") or "، من یک ربات مدیریت گروه هستم ، برای استفاده از من داخل گروهت ؛ میتونی با مدیر من در ارتباط باشی.\nخوشحال میشم به شما هم خدمت کنم🌹\n\nیوزرنیم مدیر: " .. "@" .. UserSudo_1 .. "\n (@Developer4)"
              local keyboard = {}
              keyboard.inline_keyboard = {
                {
                  {
                    text = "• کانال دستورات",
                    url = "https://t.me/" .. chcmd
                  }
                },
                {
                  {
                    text = "• خرید ربات",
                    url = "https://t.me/" .. UserSudo_1
                  }
                },
                {
                  {
                    text = "• کانال ربات",
                    url = "https://t.me/" .. chjoi
                  }
                },
                {
                  {
                    text = "• درباره ربات",
                    callback_data = "statsbott:" .. user_id
                  }
                }
              }
              Edit(msg.chat_id, msg.inline_id, "• سلام " .. getuser .. [[

 ]] .. textstart .. "\n\n (@Developer4)", keyboard, "html")
            end
            if LeaderCode:match("statsbott:(%d+)") then
              user_id = LeaderCode:match("statsbott:(%d+)")
              local nerkhh = redis:get("startmttnn") or "این بخش توسط مدیرکل تکمیل نشده"
              local keyboard = {}
              keyboard.inline_keyboard = {
                {
                  {
                    text = "برگشت ◄",
                    callback_data = "textstart:" .. user_id
                  }
                }
              }
              Edit(msg.chat_id, msg.inline_id, nerkhh, keyboard, "html")
            end
            if LeaderCode == "setleader:" .. user_id .. "" then
              if not is_Fullsudo(sender_id) then
                Alert(Leader.id, "دسترسی کافی ندارید", true)
              else
                if redis:get("AutoInstall" .. Sudoid) then
                  AutoInstall = "فعال"
                else
                  AutoInstall = "غیرفعال"
                end
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• نصب خودکار: " .. AutoInstall .. "",
                      callback_data = "AutoInstall:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• کانال جوین اجباری",
                      callback_data = "setchjoin:" .. user_id
                    },
                    {
                      text = "• یوزرنیم سودو",
                      callback_data = "usersudo:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• کانال دستورات",
                      callback_data = "setchcmd:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• درباره",
                      callback_data = "sudoaboto:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• پیام اخر",
                      callback_data = "setendsgs:" .. user_id
                    },
                    {
                      text = "• منشی",
                      callback_data = "SetClerkAns:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• نرخ",
                      callback_data = "resetnerkh:" .. user_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "به تنظیمات ربات ربات خوش امدید\nکانال جوین : " .. chjoi .. "\n پیام اخر :" .. EndMsg .. "\n (@Developer4)", keyboard, "html")
              end
            end
            if LeaderCode == "AutoInstall:" .. user_id .. "" then
              print("" .. msg.chat_id .. "")
              if not is_Fullsudo(sender_id) then
                Alert(Leader.id, "دسترسی کافی ندارید", true)
              else
                if redis:get("AutoInstall" .. Sudoid) then
                  redis:del("AutoInstall" .. Sudoid)
                  Alert(Leader.id, "🔓 نصب خودکار گروه  غیر فعال شد!")
                else
                  redis:set("AutoInstall" .. Sudoid, true)
                  Alert(Leader.id, "🔒 نصب خودکار گروه فعال شد!")
                end
                if redis:get("AutoInstall" .. Sudoid) then
                  AutoInstall = "فعال"
                else
                  AutoInstall = "غیرفعال"
                end
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "• نصب خودکار: " .. AutoInstall .. "",
                      callback_data = "AutoInstall:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• کانال جوین اجباری",
                      callback_data = "setchjoin:" .. user_id
                    },
                    {
                      text = "• یوزرنیم سودو",
                      callback_data = "usersudo:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• کانال دستورات",
                      callback_data = "setchcmd:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• درباره",
                      callback_data = "sudoaboto:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• پیام اخر",
                      callback_data = "setendsgs:" .. user_id
                    },
                    {
                      text = "• منشی",
                      callback_data = "SetClerkAns:" .. user_id
                    }
                  },
                  {
                    {
                      text = "• نرخ",
                      callback_data = "resetnerkh:" .. user_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "به تنظیمات ربات ربات خوش امدید\nکانال جوین : " .. chjoi .. "\n پیام اخر :" .. EndMsg .. "\n (@Developer4)", keyboard, "html")
              end
            end
            if LeaderCode == "usersudo:" .. user_id .. "" then
              print("" .. msg.chat_id .. "")
              if not is_Fullsudo(sender_id) then
                Alert(Leader.id, "دسترسی کافی ندارید", true)
              else
                redis:setex("usersudowait" .. msg.chat_id .. ":" .. sender_id, 60, true)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "setleader:" .. user_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "لطفا یوزرنیم  خود را بدون {@} ارسال کنید", keyboard, "html")
              end
            end
            if LeaderCode == "setchjoin:" .. user_id .. "" then
              print("" .. msg.chat_id .. "")
              if not is_Fullsudo(sender_id) then
                Alert(Leader.id, "دسترسی کافی ندارید", true)
              else
                redis:setex("setchjoinwait" .. msg.chat_id .. ":" .. sender_id, 60, true)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "setleader:" .. user_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "لطفا ایدی کانال خود را بدون {@} ارسال کنید", keyboard, "html")
              end
            end
            if LeaderCode == "setchcmd:" .. user_id .. "" then
              if not is_Fullsudo(sender_id) then
                Alert(Leader.id, "دسترسی کافی ندارید", true)
              else
                redis:setex("setchcmdwait" .. msg.chat_id .. ":" .. sender_id, 60, true)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "setleader:" .. user_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "لطفا ایدی کانال خود را بدون {@} ارسال کنید", keyboard, "html")
              end
            end
            if LeaderCode == "SetClerkAns:" .. user_id .. "" then
              if not is_Fullsudo(sender_id) then
                Alert(Leader.id, "دسترسی کافی ندارید", true)
              else
                redis:setex("WaitSetClerk" .. msg.chat_id .. ":" .. sender_id, 60, true)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "setleader:" .. user_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "لطفا متن مورد نظر خودرا ارسال کنید", keyboard, "html")
              end
            end
            if LeaderCode == "sudoaboto:" .. user_id .. "" then
              if not is_Fullsudo(sender_id) then
                Alert(Leader.id, "دسترسی کافی ندارید", true)
              else
                redis:setex("sudoabotoset" .. msg.chat_id .. ":" .. sender_id, 60, true)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "setleader:" .. user_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "لطفا متن مورد نظر خودرا ارسال کنید", keyboard, "html")
              end
            end
            if LeaderCode == "resetnerkh:" .. user_id .. "" then
              if not is_Fullsudo(sender_id) then
                Alert(Leader.id, "دسترسی کافی ندارید", true)
              else
                redis:setex("resetnerkhset" .. msg.chat_id .. ":" .. sender_id, 60, true)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "setleader:" .. user_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "لطفا نرخ موردنظر خودرا ارسال کنید", keyboard, "html")
              end
            end
            if LeaderCode == "setendsgs:" .. user_id .. "" then
              if not is_Fullsudo(sender_id) then
                Alert(Leader.id, "دسترسی کافی ندارید", true)
              else
                redis:set("setendsgsset" .. msg.chat_id .. ":" .. sender_id, true)
                local keyboard = {}
                keyboard.inline_keyboard = {
                  {
                    {
                      text = "برگشت ◄",
                      callback_data = "setleader:" .. user_id
                    }
                  }
                }
                Edit(msg.chat_id, msg.inline_id, "لطفا متن مورد نظر خودرا ارسال کنید", keyboard, "html")
              end
            end
            if LeaderCode:match("tabchin:(%d+)") then
              user_id = LeaderCode:match("tabchin:(%d+)")
              if tonumber(sender_id) == tonumber(user_id) then
                local user = "<a href=\"tg://user?id=" .. user_id .. "\">" .. check_html(Leader.from.first_name) .. "</a>"
                Mute(msg.chat_id, sender_id, 2, 0)
                Edit(msg.chat_id, msg.inline_id, "• کاربر " .. user .. " هویت شما تایید شد!", nil, "html")
              else
                Alert(Leader.id, "• دکمه متعلق به شخص دیگری میباشد !", true)
              end
            end
            if LeaderCode:match("Bantabchi:(%d+)") then
              user_id = LeaderCode:match("Bantabchi:(%d+)")
              if tonumber(sender_id) == tonumber(user_id) then
                local user = "<a href=\"tg://user?id=" .. user_id .. "\">" .. check_html(Leader.from.first_name) .. "</a>"
                Mute(msg.chat_id, sender_id, 1, 1)
                redis:sadd("tabchiList:" .. msg.chat_id, user_id)
                Edit(msg.chat_id, msg.inline_id, "• کاربر " .. user .. " تبچی شناسایی شد !", nil, "html")
              else
                Alert(Leader.id, "• دکمه متعلق به شخص دیگری میباشد !", true)
              end
            end
          end
          do
            for i, i in pairs(redis:smembers("group:")) do
              HalGhe(i)
            end
          end
        end
      end
    end
  end
end

return LeaderCodeHelper()
