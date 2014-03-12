_mf.items = {}

function _mf.items.getCustomBullet(item, ...)
	local bullet = nil
	
	if item.def.getCustomBullet then
		bullet = item.def.getCustomBullet(item, ...)
	end
	
	bullet = bullet or item:_oldGetBullet()
	return bullet
end

function _mf.items.getCustomBulletSpeed(item, ...)
	local bulletSpeed = nil
	
	if item.def.getCustomBulletSpeed then
		bulletSpeed = item.def.getCustomBulletSpeed(item, ...)
	end
	
	bulletSpeed = bulletSpeed or item:_oldGetBulletSpeed()
	return bulletSpeed
end

function _mf.items.getCustomMuzzleFx(item, ...)
	local muzzleFx = nil
	
	if item.def.getCustomMuzzleFx then
		muzzleFx = item.def.getCustomMuzzleFx(item, ...)
	end
	
	muzzleFx = muzzleFx or item:_oldGetMuzzleFx()
	return muzzleFx
end

function _mf.items.getCustomSpecial(item, ...)
	local special = nil
	
	if item.def.getCustomSpecial then
		special = item.def.getCustomSpecial(item, ...)
	end
	
	special = special or item:_oldGetSpecial()
	return special
end

function _mf.items.getCustomPushback(item, ...)
	local pushback = nil
	
	if item.def.getCustomPushback then
		pushback = item.def.getCustomPushback(item, ...)
	end
	
	pushback = pushback or item:_oldGetPushback()
	return pushback
end

function _mf.items.getCustomGriplessAmount(item, ...)
	local griplessAmount = nil
	
	if item.def.getCustomGriplessAmount then
		griplessAmount = item.def.getCustomGriplessAmount(item, ...)
	end
	
	griplessAmount = griplessAmount or item:_oldGetGriplessAmount()
	return griplessAmount
end

function _mf.items.getCustomBulletSpread(item, ...)
	local bulletSpread = nil
	
	if item.def.getCustomBulletSpread then
		bulletSpread = item.def.getCustomBulletSpread(item, ...)
	end
	
	bulletSpread = bulletSpread or item:_oldGetBulletSpread()
	return bulletSpread
end

function _mf.items.customUseMethod(item, ...)
	local value = nil
	
	if item.def.customUseMethod then
		value = item.def.customUseMethod(item, ...)
	elseif item.def.custom and item.def.customUseType == "genericWeapon" then
		value = _mf.items.customGenericWeaponUse(item, ...)
	end
	
	value = value or item:_oldUse(...)
	
	if item.def.customAdditionalUseMethod
		value = item.def.customAdditionalUseMethod(value, item, ...)
	end
	
	return value
end

function _mf.items.createItem(index, parent, name)
	if type(parent) == "table" then
		ITEMS[index] = _mf.deepcopy(parent)
	elseif type(ITEMS[parent]) == "table" then
		ITEMS[index] = _mf.deepcopy(ITEMS[parent])
	else
		ITEMS[index] = {}
	end
	
	ITEMS[index].index = index
	ITEMS[index].name = name or index
	
	return ITEMS[index]
end

function _mf.items.createAmmo(index, parent, name, small, medium, large, icon)
	_mf.createObjectItem(index, parent, name)
	
	ITEMS.ammoSmall.ammoAmounts[index] = small or ITEMS.ammoSmall.ammoAmounts[parent]
	ITEMS.ammoSmallDouble.ammoAmounts[index] = small or ITEMS.ammoSmall.ammoAmounts[parent]
	ITEMS.ammoMedium.ammoAmounts[index] = medium or ITEMS.ammoMedium.ammoAmounts[parent]
	ITEMS.ammoMediumDouble.ammoAmounts[index] = medium or ITEMS.ammoMediumDouble.ammoAmounts[parent]
	ITEMS.ammoLarge.ammoAmounts[index] = large or ITEMS.ammoLarge.ammoAmounts[parent]
	ITEMS.ammoLargeDouble.ammoAmounts[index] = large or ITEMS.ammoLargeDouble.ammoAmounts[parent]
	
	return OBJECTS[index], ITEMS[index]
end

function _mf.items.customWeaponShootBullet(self, actor, x, y, fireAngle, angle)
	local obj = nil
	if self.def.customWeaponShootBullet then
		obj = self.def.customWeaponShootBullet(self, actor, x, y, fireAngle, angle)
	else
		local angle = angle or fireAngle
		if self.def.newtonian then
			obj = self:shootNewtonianBullet(actor, x,y, fireAngle, self:getBulletSpeed(), self:getBullet())
		else
			obj = self:shootProjectedBullet(actor, x,y, fireAngle, self:getBulletSpeed(), self:getBullet())
		end
		
		if self.def.customBulletInit then
			self.def.customBulletInit(obj, self, actor, x,y, fireAngle, angle)
		end

		if self.def.aimUp then
			obj.targetAngle = angle
		end

		if self.def.bulletBonusTime then
			obj:setTime(-self.def.bulletBonusTime)
		end

		if self.upgrades and self.upgrades.scope then
			self.upgrades.scope:onUsed(actor, obj, self)
		end

		local spec = self:getSpecial()
		if spec then
			obj:applySpecial(spec, actor, self)
		end
	end
	if self.def.customAdditionalWeaponShootBullet then
		return self.def.customAdditionalWeaponShootBullet(obj, self, actor, x, y, fireAngle, angle)
	else
		return obj
	end
end
 
function _mf.items.customWeaponFeedback(self, actor, x, y, angle)
	if self.def.customWeaponFeedback then
		self.def.customWeaponFeedback(self, actor, x, y, angle)
	else
		if actor.map then
			local muz = self:getMuzzleFx()
			if muz then
				self:createMuzzleFx(actor, x, y, muz)
			elseif self.def.muzzleMethod then
				self.def.muzzleMethod(self, actor, angle, x, y)
			end
			actor:emitSoundAt(self:getUseSound(), x,y, 1, self:getUseSoundMod()*(self.soundMod or 1), self:getSoundRange())
		end
		local rec = self:getRecoilAmount()
		actor:setStealthPenalty(self:getSoundRange()*soundToVisFactor + rec*recoilToVisFactor)
		self:applyRandomRecoil(actor, angle, rec)
		self:applyRecoilFatigue(self:getRecoilFatigue())
	end
	if self.def.customAdditionalWeaponFeedback then
		self.def.customAdditionalWeaponFeedback(self, actor, x, y, angle)
	end
end

function _mf.items.customGenericWeaponUse(self, actor, angle)
	if self.ammo > 0 then
		local x,y = actor:getSafeWeaponXY()
		local fireAngle = angle

		local aimUp = self.def.aimUp
		if aimUp then
			fireAngle = math.approachAngle(angle, -math.pi*0.5, aimUp)
		end

		local bullets = self:getBullets()
		if bullets > 1 then
			bullets = math.ceil(math.min(self.ammo/self:getAmmoUse(), bullets))
			for i=1,bullets do
				local fireAngle = fireAngle + (i -((bullets+1)%2)*0.5 - math.ceil(bullets/2))*self:getBulletSpread()
				_mf.customWeaponShootBullet(self, actor, x,y, fireAngle, angle)
			end
		else
			_mf.customWeaponShootBullet(self, actor, x,y, fireAngle, angle)
		end

		_mf.customWeaponFeedback(self, actor, x, y, angle)

		local gl = self:getGriplessAmount()
		if gl > 0 then
			actor:gripless(gl)
			actor:airGripless(gl)
		end
		local pb = self:getPushback()
		if pb > 0 then
			actor:applyItemPushback(angle + math.pi, pb)
		end

		self:useAmmo(actor, self:getAmmoUse()*bullets)
	else
		self:failedUse(actor, angle); return false
	end
	
	return true
end

function _mf.items._initItems()
	Item._oldGetBullet = Item.getBullet
	Item.getBullet = _mf.items.getCustomBullet
	Item._oldGetBulletSpeed = Item.getBulletSpeed
	Item.getBulletSpeed = _mf.items.getCustomBulletSpeed
	Item._oldGetMuzzleFx = Item.getMuzzleFx
	Item.getMuzzleFx = _mf.items.getCustomMuzzleFx
	Item._oldGetSpecial = Item.getSpecial
	Item.getSpecial = _mf.items.getCustomSpecial
	Item._oldGetPushback = Item.getPushback
	Item.getPushback = _mf.items.getCustomPushback
	Item._oldGetGriplessAmount = Item.getGriplessAmount
	Item.getGriplessAmount = _mf.items.getCustomGriplessAmount
	Item._oldGetBulletSpread = Item.getBulletSpread
	Item.getBulletSpread = _mf.items.getCustomBulletSpread
	Item._oldUse = Item.use
	Item.use = _mf.items.customUseMethod
end