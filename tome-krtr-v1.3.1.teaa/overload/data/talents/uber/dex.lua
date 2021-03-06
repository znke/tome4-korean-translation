-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

uberTalent{
	name = "Through The Crowd",
	kr_name = "군중 속으로",
	require = { special={desc="동시에 6 명 이상의 동료와 함께 다녀봤을 것", fct=function(self)
		return self:attr("huge_party")
	end} },
	mode = "sustained",
	on_learn = function(self, t)
		self:attr("bump_swap_speed_divide", 10)
	end,
	on_unlearn = function(self, t)
		self:attr("bump_swap_speed_divide", -10)
	end,
	callbackOnAct = function(self, t)
		local nb_friends = 0
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) > 0 and self:canSee(act) then nb_friends = nb_friends + 1 end
		end
		if nb_friends > 1 then
			nb_friends = math.min(nb_friends, 5)
			self:setEffect(self.EFF_THROUGH_THE_CROWD, 4, {power=nb_friends * 10})
		end
	end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "nullify_all_friendlyfire", 1)
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[언제나 무리지어 다녔던 경험을 바탕으로, 
		- 동료와 위치를 바꿀 때 0.1 턴 만에 바꿀 수 있습니다 (이 효과는 해당 특수기술이 유지중이 아니더라도, 항상 지속적으로 적용됩니다).
		- 당신은 이 기술이 유지되는 동안 절대 동료나 중립적인 존재에게 피해를 주지 않게 됩니다.
		- 당신은 동료들과 함께 있는 것을 좋아하여, 시야내에 존재하는 동료의 수만큼 각각 모든 내성이 10씩 증가합니다.]])
		:format()
	end,
}

uberTalent{
	name = "Swift Hands",
	kr_name = "빠른 손놀림",
	mode = "passive",
	on_learn = function(self, t)
		self:attr("quick_weapon_swap", 1)
		self:attr("quick_equip_cooldown", 1)
		self:attr("quick_wear_takeoff", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("quick_weapon_swap", -1)
		self:attr("quick_equip_cooldown", -1)
		self:attr("quick_wear_takeoff", -1)
	end,
	info = function(self, t)
		return ([[재빠른 손놀림을 익혀, 보조장비로 교체할 때 턴 소모가 되지 않게 됩니다. (기본 단축키 : q) 
		이 효과는 턴 당 한번씩만 적용됩니다.
		또한 장비를 착용하거나 착용 해제를 할 경우에도 턴 소모가 되지 않으며, 발동 가능한 장비를 장착했을 때 재사용 대기시간 없이 즉시 장비를 발동시킬 수 있게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Windblade",
	kr_name = "칼바람",
	mode = "activated",
	require = { special={desc="쌍수 무기로 적에게 총 50,000 이상의 피해를 가할 것", fct=function(self) return self.damage_log and self.damage_log.weapon.dualwield and self.damage_log.weapon.dualwield >= 50000 end} },
	cooldown = 12,
	radius = 4,
	range = 1,
	tactical = { ATTACKAREA = {  weapon = 2  }, DISABLE = { disarm = 2 } },
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	is_melee = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, nil, 3.2, true)
				if hit and target:canBe("disarm") then
					target:setEffect(target.EFF_DISARMED, 4, {})
				end
			end
		end)
		self:addParticles(Particles.new("meleestorm", 1, {radius=4, img="spinningwinds_blue"}))

		return true
	end,
	info = function(self, t)
		return ([[쌍수 무기를 든 채로 빠르게 회전하여, 주변에 회오리 바람을 만들어냅니다. 주변 4 칸 반경에 320%% 무기 피해를 주고, 적들의 무장을 4 턴 동안 해제시킵니다.]])
		:format()
	end,
}

uberTalent{
	name = "Windtouched Speed",
	kr_name = "순풍",
	mode = "passive",
	require = { special={desc="평정을 소모하는 기술 레벨의 총 합이 20 이상일 것", fct=function(self) return knowRessource(self, "equilibrium", 20) end} },
	on_learn = function(self, t)
		self:attr("global_speed_add", 0.2)
		self:attr("avoid_pressure_traps", 1)
		self:recomputeGlobalSpeed()
	end,
	on_unlearn = function(self, t)
		self:attr("global_speed_add", -0.2)
		self:attr("avoid_pressure_traps", -1)
		self:recomputeGlobalSpeed()
	end,
	info = function(self, t)
		return ([[자연과 동화되어, 움직일 때 자연의 힘을 이용할 수 있게 됩니다.
		전체 속도가 20%% 증가하며, 밟으면 작동되는 함정을 무시할 수 있게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Giant Leap",
	kr_name = "대약진",
	mode = "activated",
	require = { special={desc="무기나 맨손으로 적에게 총 50,000 이상의 피해를 가할 것", fct=function(self) return 
		self.damage_log and (
			(self.damage_log.weapon.twohanded and self.damage_log.weapon.twohanded >= 50000) or
			(self.damage_log.weapon.shield and self.damage_log.weapon.shield >= 50000) or
			(self.damage_log.weapon.dualwield and self.damage_log.weapon.dualwield >= 50000) or
			(self.damage_log.weapon.other and self.damage_log.weapon.other >= 50000)
		)
	end} },
	cooldown = 20,
	radius = 1,
	range = 10,
	is_melee = true,
	tactical = { CLOSEIN = 2, ATTACKAREA = { weapon = 2 }, DISABLE = { daze = 1 } },
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		if game.level.map(x, y, Map.ACTOR) then
			x, y = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
			if not x then return end
		end

		if game.level.map:checkAllEntities(x, y, "block_move") then return end

		local ox, oy = self.x, self.y
		self:move(x, y, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end

		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, nil, 2, true)
				if hit and target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, 3, {})
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[대상에게 도약하여, 대상과 주변 1 칸 반경의 적들에게 200%% 무기 피해를 주고 3 턴 동안 혼절시킵니다.]])
		:format()
	end,
}

uberTalent{
	name = "Crafty Hands",
	kr_name = "장인의 손",
	mode = "passive",
	require = { special={desc="장비 강화 마법을 5 레벨까지 올릴 것", fct=function(self)
		return self:getTalentLevelRaw(self.T_IMBUE_ITEM) >= 5
	end} },
	info = function(self, t)
		return ([[보석의 장인이 되어, 투구류와 허리띠에도 보석의 힘을 주입할 수 있게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Roll With It",
	kr_name = "피할 수 없다면 즐겨라",
	mode = "sustained",
	cooldown = 10,
	tactical = { ESCAPE = 1 },
	require = { special={desc="적의 공격을 받아 50 회 이상 밀려나볼 것", fct=function(self) return self:attr("knockback_times") and self:attr("knockback_times") >= 50 end} },
	-- Called by default projector in mod.data.damage_types.lua
	getMult = function(self, t) return self:combatLimit(self:getDex(), 0.7, 0.9, 50, 0.85, 100) end, -- Limit > 70% damage taken
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "knockback_on_hit", 1)
		self:talentTemporaryValue(ret, "movespeed_on_hit", {speed=3, dur=1})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[경험을 통해, 적의 공격을 허용해주면서 전투의 흐름을 타는 방법을 익혔습니다.
		때문에 이동할 수 있는 한 공격을 피하고, 흘리며, 튕겨내는 등 캐릭터가 받는 물리 공격 피해를 %d%% 감소시킬 수 있게 됩니다.
		또한 근접 공격이나 원거리 물리 공격을 맞을 때마다 턴 소모 없이 한 칸 뒤로 이동할 수 있게 되며 (한 턴에 한 번만 가능합니다), 1 턴 동안 200%% 의 이동속도를 얻게 됩니다.
		피해 감소량은 민첩 능력치의 영향을 받아 증가하며, 다른 저항력에 의한 계산이 끝난 뒤에 적용됩니다.]])
		:format(100*(1-t.getMult(self, t)))
	end,
}

uberTalent{
	name = "Vital Shot",
	kr_name = "숨통을 끊는 한 발",
	no_energy = "fake",
	cooldown = 10,
	range = archery_range,
	require = { special={desc="원거리 무기로 적에게 총 50,000 이상의 피해를 가할 것", fct=function(self) return self.damage_log and self.damage_log.weapon.archery and self.damage_log.weapon.archery >= 50000 end} },
	tactical = { ATTACK = { weapon = 3 }, DISABLE = 3 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, 5, {apply_power=self:combatAttack()})
		end
		target:setEffect(target.EFF_CRIPPLE, 5, {speed=0.50, apply_power=self:combatAttack()})
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=4.5})
		return true
	end,
	info = function(self, t)
		return ([[대상의 치명적 약점을 노려, 엄청난 피해를 줍니다.
		대상에게 450%% 무기 피해를 주고, 5 턴 동안 기절과 무력화 (물리, 마법, 정신 공격 속도 50%% 감소) 상태효과를 동시에 줍니다.
		기절과 무력화 확률은 정확도 능력치의 영향을 받아 증가합니다.]]):format()
	end,
}
