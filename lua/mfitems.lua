_mf.items = {}

function _mf.items.getCustomBullet(item, ...)
	local bullet = nil
	if item.getCustomBullet then
		bullet = item.getCustomBullet(item, ...)
	end
	bullet = bullet or item:_oldGetBullet()
	return bullet
end

function _mf.items.getCustomBulletSpeed(item, ...)
	local bulletSpeed = nil
	if item.getCustomBulletSpeed then
		bulletSpeed = item:getCustomBulletSpeed(...)
	end
	bulletSpeed = bulletSpeed or item:_oldGetBulletSpeed()
	return bulletSpeed
end

function _mf.items.getCustomMuzzleFx(item, ...)
	local muzzleFx = nil
	if item.getCustomMuzzleFx then
		muzzleFx = item:getCustomMuzzleFx(...)
	end
	muzzleFx = muzzleFx or item:_oldGetMuzzleFx()
	return muzzleFx
end

function _mf.items.getCustomSpecial(item, ...)
	local special = nil
	if item.getCustomSpecial then
		special = item:getCustomSpecial(...)
	end
	special = special or item:_oldGetSpecial()
	return special
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

function _mf.items.customWeaponShootBullet(self, actor, x,y, fireAngle, angle)
        local obj = nil
        local angle = angle or fireAngle
        if self.def.newtonian then
                obj = self:shootNewtonianBullet(actor, x,y, fireAngle, self:getBulletSpeed(), self:getBullet())
        else
                obj = self:shootProjectedBullet(actor, x,y, fireAngle, self:getBulletSpeed(), self:getBullet())
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
        return obj
end
 
function _mf.items.customWeaponFeedback(self, actor, x, y, angle)
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
 
function _mf.items.customUseMethod(item, ...)
	local value = nil
	if item.def.customUseMethod then
		value = item.def.customUseMethod(item, ...)
	end
	value = value or item:_oldUse(...)
	return value
end
 
function _mf.items.customGenericWeaponUse(self, actor, angle)
		if self.customUseMethod == nil and self._oldUseMethod then self:_oldUseMethod(actor, angle) end
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
	Item._oldUse = Item.use
	Item.use = _mf.items.customUseMethod
end