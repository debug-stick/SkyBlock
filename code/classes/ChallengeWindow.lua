cChallengeWindow = {}
cChallengeWindow.__index = cChallengeWindow

-- Creates a new challenge window
function cChallengeWindow.new(a_PlayerInfo)
	local self = setmetatable({}, cChallengeWindow)

	-- Key: cLuaWindow; Value: True
	self.m_Windows = {}

	for i = 1, #LEVELS do
		-- Create window, get amount rows required
		table.insert(self.m_Windows, cLuaWindow(cWindow.wtChest, 9, math.ceil((9 + LEVELS[i].m_AmountChallenges) / 9), "Challenges: " .. LEVELS[i].m_LevelName))
		local cnt = 0
		for _, challenge in pairs(LEVELS[i].m_Challenges) do
			local item
			if a_PlayerInfo:HasCompleted(LEVELS[i].m_LevelName, challenge.m_ChallengeName) then
				item = cItem(challenge.m_DisplayItem)
				item.m_CustomName = cChatColor.Yellow .. challenge.m_ChallengeName
				if not(challenge.m_IsRepeatable) then
					item.m_Lore = cChatColor.Red .. "This challenge is not repeatable"
				else
					local lore = cChatColor.Purple .. challenge.m_Description .. "`"
					lore = lore .. cChatColor.Yellow .. "This items are required`"
					lore = lore .. cChatColor.Purple .. wrap(challenge.m_RptRequiredText) .. "`"
					lore = lore .. cChatColor.Green .. "Reward:`"
					lore = lore .. cChatColor.Purple .. "xp: " .. challenge.m_RptRewardXP .. "`"
					lore = lore .. cChatColor.Purple .. "Items: " .. wrap(challenge.m_RptRewardText) .. "`"
					lore = lore .. cChatColor.Yellow .. "Click to complete this challenge`"
					item.m_Lore = lore
					self.m_Windows[i]:GetContents():SetSlot(9 + cnt, item)
					self.m_Windows[i].m_LevelName = LEVELS[i].m_LevelName
				end
			else
				item = cItem(E_BLOCK_STAINED_GLASS_PANE, 1, E_META_STAINED_GLASS_PANE_YELLOW)
				item.m_CustomName = cChatColor.Yellow .. challenge.m_ChallengeName
				local lore = cChatColor.Purple .. challenge.m_Description .. "`"
				if challenge:GetChallengeType() == "ITEMS" then
					lore = lore .. cChatColor.Yellow .. "This items are required`"
				elseif challenge:GetChallengeType() == "VALUES" then
					lore = lore .. cChatColor.Yellow .. "This value is required`"
				end
				lore = lore .. cChatColor.Purple .. wrap(challenge.m_RequiredText) .. "`"
				lore = lore .. cChatColor.Green .. "Reward:`"
				lore = lore .. cChatColor.Purple .. "xp: " .. challenge.m_RewardXP .. "`"
				lore = lore .. cChatColor.Purple .. "Items: " .. wrap(challenge.m_RewardText) .. "`"
				lore = lore .. cChatColor.Yellow .. "Click to complete this challenge`"
				item.m_Lore = lore
			end
			self.m_Windows[i]:GetContents():SetSlot(9 + cnt, item)
			self.m_Windows[i].m_LevelName = LEVELS[i].m_LevelName
			cnt = cnt + 1
		end

		-- Add item for level
		local itemLevel = cItem(LEVELS[i].m_DisplayItem)
		itemLevel.m_CustomName = cChatColor.LightBlue .. "Level: " .. cChatColor.Green .. LEVELS[i].m_LevelName
		itemLevel.m_Lore = cChatColor.Gold .. LEVELS[i].m_Description
		self.m_Windows[i]:GetContents():SetSlot(4, itemLevel)

		if i < #LEVELS then
			-- Add forward item
			local item = cItem(1)
			item.m_CustomName = cChatColor.LightBlue .. "Click to go forward."
			-- item.m_Lore = cChatColor.Green ""
			self.m_Windows[i]:GetContents():SetSlot(5, item)
		elseif i > 1 and i <= #LEVELS then
			-- Add backward item
			local item = cItem(1)
			item.m_CustomName = cChatColor.LightBlue .. "Click to go backward."
			self.m_Windows[i]:GetContents():SetSlot(3, item)
		end
	end
	return self
end



function wrap(str)
	if #str < 35 then
		return str
	end

	local here = 1
	return str:gsub("(%s+)()(%S+)()",
		function(sp, st, word, fi)
			if fi - here > 35 then
				here = st
				return "`" .. word
			end
		end)
end



function cChallengeWindow:HandleClick(a_Player, a_Window, a_ClickedItem, a_ClickAction, a_SlotNum)
	-- Find window
	local window = nil
	local index = -1
	for i in ipairs(self.m_Windows) do
		index = i
		local levelName = ReplaceString(a_Window:GetWindowTitle(), "Challenges: ", "")
		if self.m_Windows[i].m_LevelName == levelName then
			window = self.m_Windows[i]
			break
		end
	end

	if not(window) then
		return false
	end

	if not(a_ClickedItem:IsEmpty()) then
		if a_SlotNum == 5 then
			-- Forward item
			a_Player:OpenWindow(self.m_Windows[index + 1])
			return true
		end

		if a_SlotNum == 3 then
			-- Backward item
			a_Player:OpenWindow(self.m_Windows[index - 1])
			return true
		end
	end

	if a_SlotNum >= 9 then
		local challengeName = ReplaceString(a_ClickedItem.m_CustomName, cChatColor.Yellow, "")
		local challenge = LEVELS[GetLevelAsNumber(window.m_LevelName)].m_Challenges[challengeName]
		if challenge and challenge:IsCompleted(a_Player) then
			window:GetContents():SetSlot(a_SlotNum, cItem(challenge.m_DisplayItem))
		end
	end
	return true
end


function cChallengeWindow:Open(a_Player)
	a_Player:OpenWindow(self.m_Windows[1])
end
