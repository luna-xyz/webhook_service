local Utility = {}

local validCharacters = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0","<",">","?","@","{","}","[","]","!","(",")","=","+","~","#"}

function Utility:NewUID(length)
	
	length = length or 8
	
	local UID = ""
	
	local list = validCharacters
	
	local total = #list
	
	for i = 1, length do
		
		local randomCharacter = list[math.random(1, total)]
		UID = UID..randomCharacter
	end
	return UID
end

return Utility