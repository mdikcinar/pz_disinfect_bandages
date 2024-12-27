--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISDisinfectBandage = ISBaseTimedAction:derive("ISDisinfectBandage")

function ISDisinfectBandage:isValid()
	if self.item:getContainer() ~= self.character:getInventory() then return false end
	if self.hotItem:getFluidContainer():getAmount() < 0.1 then return false end
	return true
end

function ISDisinfectBandage:waitToStart()
	return self.character:shouldBeTurning()
end

function ISDisinfectBandage:update()
	self.item:setJobDelta(self:getJobDelta())
end

function ISDisinfectBandage:start()
	self:setActionAnim("Craft")
	self.sound = self.character:playSound("FirstAidCleanRag")
end

function ISDisinfectBandage:stop()
	self:stopSound()
	self.item:setJobDelta(0.0)
	ISBaseTimedAction.stop(self)
end

function ISDisinfectBandage:perform()
	self:stopSound()
	self.item:setJobDelta(0.0)
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISDisinfectBandage:complete()
	local primary = self.character:isPrimaryHandItem(self.item)
	local secondary = self.character:isSecondaryHandItem(self.item)
	self.character:getInventory():Remove(self.item)
	local item = self.character:getInventory():AddItem(self.result)
	sendReplaceItemInContainer(self.character:getInventory(), self.item, item)
	if primary then
		self.character:setPrimaryHandItem(item)
	end
	if secondary then
		self.character:setSecondaryHandItem(item)
	end
	sendEquip(self.character)

	self.hotItem:getFluidContainer():adjustAmount(self.hotItem:getFluidContainer():getAmount() - 0.1)

	return true;
end

function ISDisinfectBandage:getDuration()
	if self.character:isTimedActionInstant() then
		return 1;
	end
	return 80;
end

function ISDisinfectBandage:stopSound()
	if self.sound and self.character:getEmitter():isPlaying(self.sound) then
		self.character:stopOrTriggerSound(self.sound)
	end
end

local resultItem = {
	["Base.Bandage"] = "Base.AlcoholBandage",
    ["Base.RippedSheets"] = "Base.AlcoholRippedSheets"
}

function ISDisinfectBandage:new(character, item, hotItem)
	local o = ISBaseTimedAction.new(self, character)
	if o.character:isTimedActionInstant() then o.maxTime = 1; end
	o.item = item
	o.result = resultItem[item:getFullType()]
	o.hotItem = hotItem
	o.maxTime = o:getDuration()
	return o
end    	
