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
local Object = require "engine.Object"

newTalent{
	name = "Flame Infusion", short_name = "FIRE_INFUSION",
	kr_name = "화염 주입",
	type = {"spell/fire-alchemy", 1},
	mode = "sustained",
	require = spells_req1,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:combatTalentScale(t, 0.05, 0.25) * 100 end,
	sustain_slots = 'alchemy_infusion',
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		local ret = {}
		self:talentTemporaryValue(ret, "inc_damage", {[DamageType.FIRE] = t.getIncrease(self, t)})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[연금술 폭탄을 던질 때, 적을 몇 턴 동안 불타오르게 만드는 화염을 주입해 던집니다.
		또한, 모든 화염 피해량이 %d%% 증가합니다.]]): 
		format(daminc)
	end,
}

newTalent{
	name = "Smoke Bomb",
	kr_name = "연막탄",
	type = {"spell/fire-alchemy", 2},
	require = spells_req2,
	points = 5,
	mana = function(self, t) return util.bound(math.ceil(82 - self:getTalentLevel(t) * 10), 10, 100) end,
	cooldown = 34,
	range = 6,
	direct_hit = true,
	tactical = { DISABLE = 2 },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 10, 8)) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=2, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local heat = nil
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target:hasEffect(target.EFF_BURNING) then heat = target:hasEffect(target.EFF_BURNING) end
		end)

		if not heat then
			self:project(tg, x, y, function(px, py)
				local e = Object.new{
					block_sight=true,
					temporary = t.getDuration(self, t),
					x = px, y = py,
					canAct = false,
					act = function(self)
						self:useEnergy()
						self.temporary = self.temporary - 1
						if self.temporary <= 0 then
							game.level.map:remove(self.x, self.y, engine.Map.TERRAIN+2)
							game.level:removeEntity(self)
							game.level.map:scheduleRedisplay()
						end
					end,
					summoner_gain_exp = true,
					summoner = self,
				}
				game.level:addEntity(e)
				game.level.map(px, py, Map.TERRAIN+2, e)
			end, nil, {type="dark"})
		else
			self:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and not target:hasEffect(target.EFF_BURNING) and self:reactionToward(target) < 0 then
					target:setEffect(target.EFF_BURNING, heat.dur + math.ceil(t.getDuration(self, t)/3), {src=self, power=heat.power})
				end
			end)
		end
		game:playSoundNear(self, "talents/breath")
		game.level.map:redisplay()
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[마법으로 만들어낸 연막탄을 던져, 해당 지역의 시야를 가립니다. 이 기술로 발생한 연막은 %d 턴 후에 사라집니다.
		연막 내의 적 중 하나에게 화상 상태효과를 가하면, 연막 내의 모든 적이 동시에 화상 상태효과의 영향을 받으며 화상의 지속시간이 %d 턴 증가합니다.
		연막의 지속시간은 주문력의 영향을 받아 증가합니다.]]):
		format(duration, math.ceil(duration / 3))
	end,
}

newTalent{
	name = "Fire Storm",
	kr_name = "화염 폭풍",
	type = {"spell/fire-alchemy",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 70,
	cooldown = 20,
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false}
	end,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.05) + self:getTalentLevel(t), 5, 0, 12.67, 7.66)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 120) end,
	action = function(self, t)
		-- Add a lasting map effect
		local ef = game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.FIRE_FRIENDS, t.getDamage(self, t),
			3,
			5, nil,
			{type="firestorm", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			0, 0
		)
		ef.name = "firestorm"
		ef.kr_name = "화염 폭풍"
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[타오르는 화염 폭풍을 주변에 만들어내, 주변 3 칸 반경에 %0.2f 화염 피해를 줍니다. (지속시간 : %d 턴)
		화염 폭풍 마법은 세밀하게 제어할 수 있어, 동료들이 화염 폭풍에 휘말리지 않게 할 수 있습니다.
		피해량과 지속시간은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.FIRE, damage), duration)
	end,
}


newTalent{
	name = "Body of Fire",
	kr_name = "불타는 육신",
	type = {"spell/fire-alchemy",4},
	require = spells_req4,
	mode = "sustained",
	cooldown = 40,
	sustain_mana = 250,
	points = 5,
	proj_speed = 2.4,
	range = 6,
	tactical = { ATTACKAREA = { FIRE = 3 } },
	getFireDamageOnHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getResistance = function(self, t) return self:combatTalentSpellDamage(t, 5, 45) end,
	getFireDamageInSight = function(self, t) return self:combatTalentSpellDamage(t, 15, 70) end,
	getManaDrain = function(self, t) return -0.1 * self:getTalentLevelRaw(t) end,
	callbackOnActBase = function(self, t)
		if self:getMana() <= 0 then
			self:forceUseTalent(t.id, {ignore_energy=true})
			return
		end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire"}, friendlyblock=false, friendlyfire=false}
		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:projectile(table.clone(tg), a.x, a.y, DamageType.FIRE, self:spellCrit(t.getFireDamageInSight(self, t)), {type="flame"})
			game:playSoundNear(self, "talents/fire")
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fireflash")
		game.logSeen(self, "#FF8000#%s의 몸에 순수한 화염이 타오릅니다!", (self.kr_name or self.name):capitalize())
		self:addShaderAura("body_of_fire", "awesomeaura", {time_factor=3500, alpha=1, flame_scale=1.1}, "particles_images/wings.png")
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.FIRE]=t.getFireDamageOnHit(self, t)}),
			res = self:addTemporaryValue("resists", {[DamageType.FIRE] = t.getResistance(self, t)}),
			drain = self:addTemporaryValue("mana_regen", t.getManaDrain(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeShaderAura("body_of_fire")
		game.logSeen(self, "#FF8000#%s의 주변에 타오르던 화염이 사그라들다가, 완전히 사라졌습니다.", (self.kr_name or self.name))
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("resists", p.res)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		local onhitdam = t.getFireDamageOnHit(self, t)
		local insightdam = t.getFireDamageInSight(self, t)
		local res = t.getResistance(self, t)
		local manadrain = t.getManaDrain(self, t)
		return ([[몸에 순수한 화염이 타올라 화염 저항력이 %d%% 증가하고, 자신을 공격하는 적에게 %0.2f 화염 피해를 줍니다. 
		또한 느리게 움직이며, 시야 내의 적들을 목표로 하고 %0.2f 화염 피해를 주는 불꽃을 매 턴마다 %d 개씩 만들어냅니다. 이 불꽃은 아군에게 완전히 무해합니다.
		마법을 유지하는 동안, 매 턴마다 %0.2f 마나가 소진됩니다.
		피해량과 저항력 상승량은 주문력의 영향을 받아 증가합니다.]]):
		format(res, onhitdam, insightdam, math.floor(self:getTalentLevel(t)), -manadrain) --@ 변수 순서 조정
	end,
}
