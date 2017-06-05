-- Contains all informations for a Level

cLevel = {}
cLevel.__index = cLevel


function cLevel.new(a_File)
	local self = setmetatable({}, cLevel)

	self.m_Challenges = {}
	self.m_AmountChallenges = 0
	self:Load(a_File)
	return self
end


function cLevel:Load(a_File)
	local levelIni = cIniFile()
	levelIni:ReadFile(PLUGIN:GetLocalFolder() .. "/challenges/" .. a_File)

	self.m_LevelName = levelIni:GetValue("General", "LevelName")
	self.m_DisplayItem = levelIni:GetValueI("General", "DisplayItem")
	self.m_Description = levelIni:GetValue("General", "Description")

	local amount = levelIni:GetNumValues("Challenges")
	for counter = 1, amount do
		local challengeName = levelIni:GetValue("Challenges", tostring(counter))
		local challengeInfo = LoadBasicInfos(challengeName, levelIni, self.m_LevelName)
		if (challengeInfo ~= nil) then
			-- Load the challenge specific values
			if (challengeInfo:Load(levelIni)) then
				self.m_Challenges[challengeName] = challengeInfo
				self.m_AmountChallenges = self.m_AmountChallenges + 1
			end
		end
	end
end
