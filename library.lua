local rootElem = { }

rootElem.dots = { }
rootElem.blacklist = { }
rootElem.items = { }
rootElem.flagged = GetTime()
rootElem.unflagged = GetTime()
rootElem.tempNum = 0

function rootElem.openTotem(index)
  -- (Fire = 1 Earth = 2 Water = 3 Air = 4)
  local _,name = GetTotemInfo(index)
  if name == "" then
    return true
  end
end

rootElem.resetLists = function (self, ...)
  if #rootElem.dots > 0 then rootElem.dots = {} end
  if #rootElem.blacklist > 0 then rootElem.blacklist = {} end
end

rootElem.setFlagged = function (self, ...)
  rootElem.flagged = GetTime()
end

rootElem.setUnflagged = function (self, ...)
  rootElem.unflagged = GetTime()
  if rootElem.items[77589] then
    rootElem.items[77589].exp = rootElem.unflagged + 60
  end
end

rootElem.eventHandler = function(self, ...)
  local subEvent		= select(1, ...)
  local source		= select(4, ...)
  local destGUID		= select(7, ...)
  local spellID		= select(11, ...)
  local failedType = select(14, ...)
  
  if subEvent == "UNIT_DIED" then
    if #rootElem.dots > 0 then
      for i=1,#rootElem.dots do
        if rootElem.dots[i].guid == destGUID then
          tremove(rootElem.dots, i)
          return true
        end
      end
    end
  end
  
  if UnitName("player") == source then
    if subEvent == "SPELL_CAST_SUCCESS" then
      if spellID == 6262 then -- Healthstone
        rootElem.items[6262] = { lastCast = GetTime() }
      end
      if spellID == 124199 then -- Landshark (itemId 77589)
        rootElem.items[77589] = { lastCast = GetTime(), exp = 0 }
      end
    end
    
    if subEvent == "SPELL_AURA_REMOVED" then
      if spellID == 44457 then
        for i=1,#rootElem.dots do
          if rootElem.dots[i].guid == destGUID then
            tremove(rootElem.dots, i)
            return true
          end
        end
      end
    end
  
    if subEvent == "SPELL_AURA_APPLIED" then
      local existingDot = false
      if spellID == 44457 then
          for i=1,#rootElem.dots do
            if rootElem.dots[i].guid == destGUID and rootElem.dots[i].spellID == spellID then
              rootElem.dots[i].spellTime = GetTime()
              existingDot = true
            end
          end
          if not existingDot then
            table.insert(rootElem.dots, {guid = destGUID, spellID = spellID, spellTime = GetTime()})
          end
      end
    end
    
    if subEvent == "SPELL_CAST_FAILED" then
      if failedType and failedType == "Invalid target" then
        if spellID == 44457 or spellID == 114923 then
          rootElem.blacklist[destGUID] = spellTime
        end
      end 
    end
  end
end

ProbablyEngine.listener.register("rootElem", "COMBAT_LOG_EVENT_UNFILTERED", rootElem.eventHandler)
ProbablyEngine.listener.register("rootElem", "PLAYER_REGEN_DISABLED", rootElem.setFlagged)
ProbablyEngine.listener.register("rootElem", "PLAYER_REGEN_DISABLED", rootElem.resetLists)
ProbablyEngine.listener.register("rootElem", "PLAYER_REGEN_DISABLED", rootElem.setUnflagged)
ProbablyEngine.listener.register("rootElem", "PLAYER_REGEN_ENABLED", rootElem.resetLists)

function rootElem.spellCooldown(spell)
  local spellName = GetSpellInfo(spell)
  if spellName then
    local spellCDstart,spellCDduration,_ = GetSpellCooldown(spellName)
    if spellCDduration == 0 then
      return 0
    elseif spellCDduration > 0 then
      local spellCD = spellCDstart + spellCDduration - GetTime()
      return spellCD
    end
  end
  return 0
end

function rootElem.useGloves(target)
  local hasEngi = false
  for i=1,9 do
    if select(7,GetProfessionInfo(i)) == 202 then hasEngi = true end
  end
  if hasEngi == false then return false end
  if GetItemCooldown(GetInventoryItemID("player", 10)) > 0 then return false end
  
  local ATCD = rootElem.spellCooldown(108978)
  if ATCD > 10 and ATCD < 46 then
    return false
  end
  if IsPlayerSpell(12051) then
    local INVOB = select(7, UnitAura("player",116257))
    if INVOB then
      if (INVOB - GetTime()) < 21 then
        return false
      end
    end
  end
  if IsUsableSpell(55342) then
    local MICD = rootElem.spellCooldown(55342)
    if MICD < 40 then 
      return false
    end
  end
  return true
end

function rootElem.numDots()
  local removes = { }
  for i=1,#rootElem.dots do
    if (GetTime() - rootElem.dots[i].spellTime) >= 13 then
      table.insert(removes, { id = i } )
    end
  end
  
  if #removes > 0 then
    for i=1,#removes do
      tremove(rootElem.dots, removes[i].id)
    end
  end
  
  for k,v in pairs(rootElem.blacklist) do
    if (GetTime() - v) >= 13 then
      tremove(rootElem.blacklist, k)
    end
  end
  

  
  if #rootElem.dots ~= rootElem.tempNum then
    rootElem.tempNum = #rootElem.dots
  end
  return #rootElem.dots
end

function rootElem.usePot(target)
	if not (UnitBuff("player", 2825) or
			UnitBuff("player", 32182) or 
			UnitBuff("player", 80353) or
			UnitBuff("player", 90355)) then
		return false
	end
	if GetItemCount(76093) < 1 then return false end
	if GetItemCooldown(76093) ~= 0 then return false end
	if not ProbablyEngine.condition["modifier.cooldowns"] then return false end
	if UnitLevel(target) ~= -1 then return false end
  if rootElem.t2d(target) > 30 then return false end
	return true 
end

function rootElem.t2d(target)
  if ProbablyEngine.condition["deathin"](target) then
    return ProbablyEngine.condition["deathin"](target)
	end
  return 600
end

function rootElem.needsManagem(target)
	if IsPlayerSpell(56383) then
		if GetItemCount(81901, nil, true) < 10 then return true end
	end
	if GetItemCount(36799, nil, true) < 3 then return true end
end

function rootElem.useManagem(target)
	local Max = UnitPowerMax("player")
	local Mana = 100 * UnitPower("player") / Max
	if Mana < 70 then
		if GetItemCount(81901, nil, true) >= 1 then
			if GetItemCooldown(81901) == 0 then return true end
		end
		if GetItemCount(36799, nil, true) >= 1 then
		    if GetItemCooldown(36799) == 0 then return true end
		end
	end
end

function rootElem.dotTime(unit, spellId)
  local debuff, count, expires, caster = rootElem.unitDebuff(unit, spellId)
  if expires and caster == "player" then
    return expires - GetTime()
  end
  return 0
end

function rootElem.unitDebuff(target, spell)
  local debuff, count, caster, expires, spellID
  if tonumber(spell) then
    local i = 0; local go = true
    while i <= 40 and go do
      i = i + 1
      debuff,_,_,count,_,_,expires,caster,_,_,spellID = _G['UnitDebuff'](target, i)
      if spellID == tonumber(spell) and caster == "player" then go = false end
    end
  else
    debuff,_,_,count,_,_,expires,caster = _G['UnitDebuff'](target, spell)
  end
  return debuff, count, expires, caster
end

function rootElem.dotCheck(unit, spellId)
  local destGUID = UnitGUID(unit)
  if rootElem.blacklist[destGUID] then return false end
  if spellId == 44457 then  -- Living Bomb
    if IsPlayerSpell(spellId) then
      local bombExp = rootElem.dotTime(unit, spellId)
      if bombExp then
        if bombExp > 1.6 then
          return false
        end
      end
      local numDots = rootElem.numDots()
      if numDots >= 3 then
          return false
      end
    else
      return false
    end
  elseif spellId == 114923 then -- Nether Tempest
    if IsPlayerSpell(spellId) then
      local bombExp = rootElem.dotTime(unit, spellId)
      if bombExp then
        if bombExp > 1.6 then
          return false
        end
      end
    else
      return false
    end
  end
  return true
end

function rootElem.validTarget(unit)
  if not UnitIsVisible(unit) then return false end
  if not UnitExists(unit) then return false end
  if not (UnitCanAttack("player", unit) == 1) then return false end
  if UnitIsDeadOrGhost(unit) then return false end
  local inRange = IsSpellInRange(GetSpellInfo(116), unit) -- Elembolt
  if not inRange then return false end
  if inRange == 0 then return false end
  if not rootElem.immuneEvents(unit) then return false end
  if not rootElem.interruptEvents(unit) then return false end
  return true
end

function rootElem.bossDotCheck(unit, spellId)
  local bossUnit = unit
  if not rootElem.validTarget(bossUnit) then return false end
  if not rootElem.dotCheck(bossUnit, spellId) then return false end
  return true
end

function rootElem.interruptEvents(unit)
  if UnitBuff("player", 31821) then return true end -- Devo
  if not unit then unit = "boss1" end
  local spell = UnitCastingInfo(unit)
  local stop = false
  if spell == GetSpellInfo(138763) then stop = true end
  if spell == GetSpellInfo(137457) then stop = true end
  if spell == GetSpellInfo(143343) then stop = true end -- Thok
  if stop then
    if UnitCastingInfo("player") or UnitChannelInfo("player") then
      RunMacroText("/stopcasting")
      return false
    end
  end
  return true
end

function rootElem.itemCooldown(itemID)
  return GetItemCooldown(itemID)
end

function rootElem.immuneEvents(unit)
  if UnitAura(unit,GetSpellInfo(116994))
		or UnitAura(unit,GetSpellInfo(122540))
		or UnitAura(unit,GetSpellInfo(123250))
		or UnitAura(unit,GetSpellInfo(106062))
		or UnitAura(unit,GetSpellInfo(110945))
		or UnitAura(unit,GetSpellInfo(143593)) -- General Nazgrim: Defensive Stance
    or UnitAura(unit,GetSpellInfo(143574)) -- Heroic Immerseus: Swelling Corruption
		then return false end
  return true
end

function rootElem.checkStone(target)
  if GetItemCount(6262, false, true) > 0 then
    if not rootElem.items[6262] then
      return true
    elseif (GetTime() - rootElem.items[6262].lastCast) > 120 then
      return true
    end
  end
end

function rootElem.checkShark(target)
  if GetItemCount(77589, false, false) > 0 then
    if not rootElem.items[77589] then return true end
    if rootElem.items[77589].exp ~= 0 and
      rootElem.items[77589].exp < GetTime() then return true end
  end
end

ProbablyEngine.library.register("rootElem", rootElem)