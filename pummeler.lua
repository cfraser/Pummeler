Pummeler = {};
function Pummeler_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("ADDON_LOADED");
	DEFAULT_CHAT_FRAME:AddMessage("Pummeler addon loaded. Type /pummeler for usage.");
	SlashCmdList["PUMMELER"] = function()
		local msg = "To use Pummeler addon, create a macro and type /script Pummeler_main();"
		DEFAULT_CHAT_FRAME:AddMessage(msg);
	end;
	SLASH_PUMMELER1 = "/pummeler";
end;




Pummeler_Start_HasteBuff_Time = 0;
function Pummeler_main()
	createPummelerFrame();
	local haste, hasteIndex = Pummeler_isBuffNameActive("Haste");
	local slotId = GetInventorySlotInfo("MAINHANDSLOT");
	local itemLink = GetInventoryItemLink("player", slotId);
	local pummelerWeapon = GetItemInfo(9449);
	local weaponTimer, weaponCd = GetInventoryItemCooldown("player", 16);
	local gameTime = GetTime();
	local timeLeft = 0;
	local chargesText = nil;
	local charge = 0;
	local buffTimeLeft = nil;
	local bagPummeler, slotPummeler = nil;
	
	chargesText = Pummeler_getChargesText{};
	charge = Pummeler_getChargeNumber(chargesText);
	
	if(haste == true) then
		buffTimeLeft = 30 - math.floor(gameTime - Pummeler_Start_HasteBuff_Time);
		DEFAULT_CHAT_FRAME:AddMessage("Pummeler: "..itemLink.." Is active for "..buffTimeLeft.." more seconds!");
	elseif(haste == false) then 
		if(weaponCd ~= 0) then
			timeLeft = weaponCd - math.floor(gameTime - weaponTimer);
			DEFAULT_CHAT_FRAME:AddMessage("Pummeler: "..itemLink.." On cooldown, "..timeLeft.." seconds left!");
		elseif(itemLink ~= nil and string.find(itemLink, pummelerWeapon) and charge ~= 0 and weaponCd == 0) then 
			charge = charge - 1;
			UseInventoryItem(16);
			Pummeler_Start_HasteBuff_Time = gameTime;
			DEFAULT_CHAT_FRAME:AddMessage("Pummeler: Using "..itemLink..": "..charge.." charges left!");
		else
			bagPummeler, slotPummeler = Pummeler_isPummelerInBag("Manual Crowd Pummeler");
			if(bagPummeler ~= nil and slotPummeler ~= nil) then
				UseContainerItem(bagPummeler, slotPummeler, 1);
				DEFAULT_CHAT_FRAME:AddMessage("Pummeler: Equipping a "..pummelerWeapon..".");
			end;
		end;
	end;
end;

function Pummeler_getChargesText(options)
	pummelerTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
	if(options.bag and options.slot) then 
		pummelerTooltip:SetBagItem(options.bag, options.slot);
	else
		pummelerTooltip:SetInventoryItem("player", 16);
	end;
	local charges = nil;
	local i = 1;
	while (true)
		do
			text = getglobal("pummelerTooltipTextLeft"..i):GetText();
			if(not text) then break;
			elseif(string.find(text, "Charge")) then
				charges = text;
				pummelerTooltip:Hide();
				return charges;
			end;
			i=i+1;
	end;
	pummelerTooltip:Hide();
	return charges;
end;

function Pummeler_getChargeNumber(chargesText)
	local charge = 0;
	if(chargesText ~= nil) then
		for i = 0, 3, 1
			do
				if(chargesText ~= nil and string.find(chargesText, i)) then 
					charge = i; break;
				end;
		end;
	end;
	return charge;
end;

function Pummeler_isBuffTextureActive(texture)
	local i=0;
	local g=GetPlayerBuff;
	local isBuffActive = false;

	while not(g(i) == -1)
	do
		if(strfind(GetPlayerBuffTexture(g(i)), texture)) then isBuffActive = true; end;
		i=i+1
	end;	
	return isBuffActive;
end;

function createPummelerFrame()
    if pummelerFrame == nil then
        pummelerFrame = CreateFrame("GameTooltip", "pummelerTooltip", nil, "GameTooltipTemplate");
    end;
end;

function Pummeler_isBuffNameActive(buff)
	isActive = false;
	index = -1;
	local i = 1;
	local g=UnitBuff;
	local textleft1 = nil;
	while not(g("player", i) == -1 or g("player", i) == nil)
		do
		pummelerTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
		pummelerTooltip:SetUnitBuff("player", i);
		textleft1 = getglobal(pummelerTooltip:GetName().."TextLeft1");		

		if(textleft1 ~= nil and string.find(string.lower(textleft1:GetText()), string.lower(buff))) then 
			isActive = true;
			index = i;
			pummelerTooltip:Hide();
			break;
		end;
		pummelerTooltip:Hide();
		i=i+1;
	end;
	return isActive, index;
end;

function Pummeler_isPummelerInBag(itemName)
    local itemBag, itemSlot = nil;
	local charges = nil;
    for bag = 0, 4, 1
        do 
            for slot = 1, GetContainerNumSlots(bag), 1
                do local name = GetContainerItemLink(bag,slot)
                if name and string.find(name, itemName) then
                    if string.find(name, itemName) then 
						charges = Pummeler_getChargeNumber(Pummeler_getChargesText{bag = bag, slot = slot});
						if(charges > 0) then
							itemBag = bag; itemSlot = slot; 
							break;
						end;
					end;
                end;
            end;
        end;
    return itemBag, itemSlot;   
end;