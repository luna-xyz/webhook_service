local HttpService = game:GetService("HttpService")
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/luna-xyz/webhook_service/refs/heads/main/packages/GoodSignal.lua"))();
local Janitor = loadstring(game:HttpGet("https://raw.githubusercontent.com/luna-xyz/webhook_service/refs/heads/main/packages/Janitor.lua"))();

local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/luna-xyz/webhook_service/refs/heads/main/packages/Utility.lua"))();

local WebhookService, webhooksDict, WebhooksList = {}, {}, {}
WebhookService.__index = WebhookService

WebhookService.Presets = loadstring(game:HttpGet("https://raw.githubusercontent.com/luna-xyz/webhook_service/refs/heads/main/WebhookServicePresets.lua"))();

local sendWebhook = function(self, _data)

	local __s, __d = pcall(function()
		
		return httprequest({

			Url = tostring(self._url),

			Method = "POST",

			Headers = {
				["Content-Type"] = "application/json",
			},

			Body = HttpService:JSONEncode(_data),
		})
	end)
	
	return (not __s and error(__d.Body)) or __d --warn(`[WEBHOOK_SERVICE]: Webhook succesfully send!`)
end

function WebhookService.new()

	local self = setmetatable({}, WebhookService)

	local janitor = Janitor.new()
	self.janitor = janitor

	local iconUID = Utility:NewUID()
	webhooksDict[iconUID] = self

	janitor:add(function()
		webhooksDict[iconUID] = nil
	end)

	self.UID = tostring(HttpService:GenerateGUID(false))
	self.preset = "none"

	self.bindedEvents = {}

	self.OnChanged = janitor:add(Signal.new())

	self.OnMessageSend = janitor:add(Signal.new())
	self.OnEmbedSend = janitor:add(Signal.new())

	return self
end

function WebhookService:setURL(_url)

	if not _url then error("Argument 1 is missing or nil") end
	if typeof(_url) ~= "string" then error(`Argument 1 is a {typeof(_url)}, expected String.`) end

	self._url = _url:gsub("discord.com", "webhook.lewisakura.moe")
	return self
end

function WebhookService:setCustomProxy(custom_proxy)

	if not custom_proxy then error("Argument 1 is missing or nil") end
	if typeof(custom_proxy) ~= "string" then error(`Argument 1 is a {typeof(custom_proxy)}, expected String.`) end

	self.custom_proxy = tostring(custom_proxy)

	self._url = self._url:gsub("webhook.lewisakura.moe", tostring(custom_proxy))
	self._url = self._url:gsub("discord.com", tostring(custom_proxy))

	self.OnChanged:Fire("Proxy", "ProxyURL", custom_proxy)
	return self
end

function WebhookService:setPreset(webhook_preset)

	self.preset = webhook_preset
	self.OnChanged:Fire("Appearance", "Preset", self.preset)

	return self
end

function WebhookService:setAvatar(_settings)

	if not _settings.username then error("Argument 1 is missing or nil") end
	if typeof(_settings.username) ~= "string" then error(`Argument 1 is a {typeof(_settings.username)}, expected String.`) end

	if #_settings.username <= 0 then error(`Argument 1 is a {typeof(_settings.username)}, expected String.`) end

	self.username = tostring(_settings.username)
	self.OnChanged:Fire("Appearance", "Username", _settings.username)

	self.avatar_url = tostring(_settings.avatar_url) or ""
	self.OnChanged:Fire("Appearance", "Avatar", _settings.avatar_url)

	return self
end

function WebhookService:sendMessage(_settings)

	if not self._url then error("Webhook url is missing or nil") end

	if not _settings.message then error("Argument 1 is missing or nil") end
	if typeof(_settings.message) ~= "string" then error(`Argument 1 is a {typeof(_settings.message)}, expected String.`) end

	if #_settings.message <= 0 then error(`Argument 1 is a {typeof(_settings.message)}, expected String.`) end

	local __d = {
		content = _settings.message
	}

	if self.username or self.avatar_url then

		if self.username then __d.username = self.username end
		if self.avatar_url then __d.avatar_url = self.avatar_url end
	end

	sendWebhook(self, __d)
	self.OnMessageSend:Fire(__d)

	return self
end

function WebhookService:sendEmbed(_settings)

	if not self._url then error("Webhook url is missing or nil") end

	if self.preset ~= "none" then

		local __d = {
			embeds = { typeof(self.preset) == "function" and self.preset(table.unpack(_settings)) or self.preset }
		}

		sendWebhook(self, __d)
		self.OnEmbedSend:Fire(__d.embeds[1])

		return self
	end

	if not _settings.message then error("Argument 1 is missing or nil") end
	if typeof(_settings.message) ~= "string" then error(`Argument 1 is a {typeof(_settings.message)}, expected String.`) end

	if #_settings.message <= 0 then error(`Argument 1 is a {typeof(_settings.message)}, expected String.`) end

	local __d = {
		embeds = {{

			title = _settings.title,
			description = _settings.message,

			color = _settings.color or tonumber(0xFFFAFA),

			image = {
				url = _settings.image or "",
			},

			thumbnail = {
				url = _settings.thumbnail or "",
			},

			fields = _settings.fields or {},
		}},
	}

	if self.username or self.avatar_url then

		if self.username then __d.username = self.username end
		if self.avatar_url then __d.avatar_url = self.avatar_url end
	end

	if _settings.author then
		__d.embeds[1].author = _settings.author
	end

	if _settings.footer then
		__d.embeds[1].footer = _settings.footer
	end

	if _settings.timestamp == true then
		__d.embeds[1].timestamp = DateTime.now():ToIsoDate()
	end

	sendWebhook(self, __d)
	self.OnEmbedSend:Fire(__d.embeds[1])

	return self
end

function WebhookService:bindEvent(__n, __f)

	local __e = self[__n]

	assert(__e and typeof(__e) == "table" and __e.Connect, "argument[1] must be a valid WebhookService event name!")
	assert(typeof(__f) == "function", "argument[2] must be a function!")

	self.bindedEvents[__n] = __e:Connect(function(...)
		__f(...)
	end)

	return self
end

function WebhookService:unbindEvent(__n)

	local eventConnection = self.bindedEvents[__n]

	if eventConnection then

		eventConnection:Disconnect()
		self.bindedEvents[__n] = nil
	end

	return self
end

function WebhookService:destroy()

	self.janitor:clean()
	self = nil
end

function WebhookService:getWebhook()
	return self
end

WebhookService.URL = WebhookService.setURL

WebhookService.Remove = WebhookService.destroy
WebhookService.Get = WebhookService.getWebhook

WebhookService.Embed = WebhookService.sendEmbed
WebhookService.Message = WebhookService.sendMessage

return WebhookService
