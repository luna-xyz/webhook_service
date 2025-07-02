local WebhookServicePresets = {
	
	["kick"] = function(player, reason)

		if not player then error("Argument 1 is missing or nil") end
		if not player:IsA("Player") then error(`Argument 1 is a {tostring(player.ClassName)}, expected Player.`) end
		
		reason = reason or "Not provided"
		
		local function GetAccountAgeDate(AccountAge)

			local dateTable =  DateTime.fromUnixTimestamp(DateTime.now().UnixTimestamp - (AccountAge * 86400)):ToUniversalTime()
			local year, month, day = dateTable.Year, dateTable.Month, dateTable.Day
			
			return string.format("%02d/%02d/%04d", month, day, year)
		end

		local __data = game:GetService("HttpService"):GetAsync(`https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds={tostring(player.UserId)}&size=420x420&format=Png&isCircular=false&thumbnailType=HeadShot`)
		__data = game:GetService("HttpService"):JSONDecode(__data).data[1]
		
		local __data2 = game:GetService("HttpService"):GetAsync(`https://thumbnails.roproxy.com/v1/users/avatar?userIds={tostring(player.UserId)}&size=420x420&format=Png&isCircular=false&thumbnailType=HeadShot`)
		__data2 = game:GetService("HttpService"):JSONDecode(__data2).data[1]
		
		local __d = {

			author = {

				name = `{tostring(player.Name)} - (@{tostring(player.DisplayName)})`,

				url = `https://www.roblox.com/users/{tostring(player.UserId)}/profile`,
				icon_url = __data and tostring(__data.imageUrl) or ``,
			},
			
			description = `Kicked for: {tostring(reason)}`,

			thumbnail = {
				url = __data2 and tostring(__data2.imageUrl) or ``,
			},
			
			color = tonumber(0xFF0000),

			fields = {

				{
					["name"] = `Account Creation:`,
					["value"] = `{GetAccountAgeDate(player.AccountAge)} - **(Over {tostring(player.AccountAge)} days ago)**`,

					["inline"] = true
				},

				{
					["name"] = `UserId:`,
					["value"] = tostring(player.UserId),

					["inline"] = true
				},
				
				{
					["name"] = `Server Type:`,
					["value"] = game.VIPServerOwnerId ~= 0 and `VIP` or `PUBLIC`,

					["inline"] = true
				},
				
				{
					["name"] = `PlaceId:`,
					["value"] = tostring(game.PlaceId),

					["inline"] = true
				},
				
				{
					["name"] = `Place Version:`,
					["value"] = tostring(game.PlaceVersion),

					["inline"] = true
				},
			},

			footer = {

				text = `Send by .bella🦋 Webhook Service`,
				icon_url = `https://cdn.discordapp.com/avatars/1327368716589076510/d2bbed5126bbf1e8f948b2af77941108.webp?size=1024`,
			},

			timestamp = DateTime.now():ToIsoDate()
		}
		
		return __d
	end,
	
	["Log"] = function(player, message)

		if not player then error("Argument 1 is missing or nil") end
		if not player:IsA("Player") then error(`Argument 1 is a {tostring(player.ClassName)}, expected Player.`) end
		
		if not message then error("Argument 2 is missing or nil") end
		if typeof(message) ~= "string" then error(`Argument 2 is a {typeof(message)}, expected String.`) end
		
		local __data = game:GetService("HttpService"):GetAsync(`https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds={tostring(player.UserId)}&size=420x420&format=Png&isCircular=false&thumbnailType=HeadShot`)
		__data = game:GetService("HttpService"):JSONDecode(__data).data[1]

		local __data2 = game:GetService("HttpService"):GetAsync(`https://thumbnails.roproxy.com/v1/users/avatar?userIds={tostring(player.UserId)}&size=420x420&format=Png&isCircular=false&thumbnailType=HeadShot`)
		__data2 = game:GetService("HttpService"):JSONDecode(__data2).data[1]

		local __d = {

			author = {

				name = `{tostring(player.Name)} - (@{tostring(player.DisplayName)})`,

				url = `https://www.roblox.com/users/{tostring(player.UserId)}/profile`,
				icon_url = __data and tostring(__data.imageUrl) or ``,
			},

			description = tostring(message),

			--[[thumbnail = {
				url = __data2 and tostring(__data2.imageUrl) or ``,
			},]]--

			color = tonumber(0xFE9900),

			fields = {

				{
					["name"] = `UserId:`,
					["value"] = tostring(player.UserId),

					["inline"] = true
				},

				{
					["name"] = `Server Type:`,
					["value"] = game.VIPServerOwnerId ~= 0 and `VIP` or `PUBLIC`,

					["inline"] = true
				},

				{
					["name"] = `PlaceId:`,
					["value"] = tostring(game.PlaceId),

					["inline"] = true
				},

				{
					["name"] = `Place Version:`,
					["value"] = tostring(game.PlaceVersion),

					["inline"] = true
				},
			},

			footer = {

				text = `Send by .bella🦋 Webhook Service`,
				icon_url = `https://cdn.discordapp.com/avatars/1327368716589076510/d2bbed5126bbf1e8f948b2af77941108.webp?size=1024`,
			},

			timestamp = DateTime.now():ToIsoDate()
		}

		return __d
	end,
	
}

return setmetatable({}, {
	
	__index = function(__t, __i)

		local __f = WebhookServicePresets[__i]

		if typeof(__f) == "table" or typeof(__f) == "function" then
			return __f
		end
		
		error(`No preset found with index {__i}`)
	end;
})