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

local Trap = require "mod.class.Trap"

newTalent{
	name = "Glyph of Paralysis",
	kr_name = "마비의 문양",
	type = {"celestial/glyphs", 1},
	require = divi_req_high1,
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	positive = -10,
	no_energy = true,
	requires_target = true,
	tactical = { DISABLE = 2 },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getDazeDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end, -- Duration of glyph
	trapPower = function(self,t) return math.max(1,self:combatScale(self:getTalentLevel(t) * self:getMag(15, true), 0, 0, 75, 75)) end, -- Used to determine detection and disarm power, about 75 at level 50
	action = function(self, t)
		local tg = {type="hit", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = self:spellCrit(t.getDazeDuration(self, t))
		local trap = Trap.new{
			name = "glyph of paralysis",
			kr_name = "마비의 문양", kr_unided_name = "함정",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD, image = "trap/trap_glyph_paralysis_01_64.png",
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				if who:canBe("stun") then
					who:setEffect(who.EFF_DAZED, self.dam, {})
				end
				return true
			end,
			temporary = t.getDuration(self, t),
			x = tx, y = ty,
			disarm_power = math.floor(t.trapPower(self,t)),
			detect_power = math.floor(t.trapPower(self,t) * 0.8),
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local dazeduration = t.getDazeDuration(self, t)
		local duration = t.getDuration(self, t)
		return ([[바닥에 문양을 새기고 빛을 불어넣습니다. 문양 위에 발을 올린 모든 적들은 %d 턴 동안 혼절하게 됩니다. 
 		문양은 (탐지 난이도 %d / 해체 난이도 %d 이며 마법 능력치의 영향을 받아 난이도가 증가하는) 숨겨진 함정이며, %d 턴 동안 유지됩니다.]]):format(dazeduration, t.trapPower(self,t)*0.8, t.trapPower(self,t), duration) 
 	end, 
}

newTalent{
	name = "Glyph of Repulsion",
	kr_name = "격퇴의 문양",
	type = {"celestial/glyphs", 2},
	require = divi_req_high2,
	random_ego = "attack",
	points = 5,
	positive = -10,
	cooldown = 20,
	no_energy = true,
	tactical = { DISABLE = 2 },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getDamage = function(self, t) return 15 + self:combatSpellpower(0.12) * self:combatTalentScale(t, 1.5, 5) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end, -- Duration of glyph
	trapPower = function(self,t) return math.max(1,self:combatScale(self:getTalentLevel(t) * self:getMag(15, true), 0, 0, 75, 75)) end, -- Used to determine detection and disarm power, about 75 at level 50
	action = function(self, t)
		local tg = {type="hit", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = self:spellCrit(t.getDamage(self, t))
		local sp = self:combatSpellpower()
		local trap = Trap.new{
			name = "glyph of repulsion",
			kr_name = "격퇴의 문양", kr_unided_name = "함정",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD, image = "trap/trap_glyph_repulsion_01_64.png",
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				local ox, oy = self.x, self.y
				local dir = util.getDir(who.x, who.y, who.old_x, who.old_y)
				self.x, self.y = util.coordAddDir(self.x, self.y, dir)
				self:project({type="hit",x=x,y=y}, x, y, engine.DamageType.SPELLKNOCKBACK, self.dam)
				self.x, self.y = ox, oy
				return true
			end,
			temporary = t.getDuration(self, t),
			x = tx, y = ty,
			disarm_power = math.floor(t.trapPower(self,t)),
			detect_power = math.floor(t.trapPower(self,t) * 0.8),
			inc_damage = table.clone(self.inc_damage or {}, true),
			resists_pen = table.clone(self.resists_pen or {}, true),
			canAct = false,
			energy = {value=0},
			combatSpellpower = function(self) return self.sp end, sp = sp,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[바닥에 문양을 새기고 빛을 불어넣습니다. 문양 위에 발을 올린 모든 대상은 물리 속성의 %0.2f 피해를 받고 밀려납니다. 
 		문양은 (탐지 난이도 %d / 해체 난이도 %d 이며 마법 능력치의 영향을 받아 난이도가 증가하는) 숨겨진 함정이며, %d 턴 동안 유지됩니다. 
 		피해량은 주문력의 영향을 받아 증가합니다.]]): 
		format(damDesc(self, DamageType.PHYSICAL, damage), t.trapPower(self, t)*0.8, t.trapPower(self, t), duration)
	end,
}

newTalent{
	name = "Glyph of Explosion",
	kr_name = "폭발의 문양",
	type = {"celestial/glyphs", 3},
	require = divi_req_high3,
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	positive = -10,
	no_energy = true,
	tactical = { ATTACKAREA = {LIGHT = 2} },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getDamage = function(self, t) return 15 + self:combatSpellpower(0.12) * self:combatTalentScale(t, 1.5, 5) end,-- Should this be higher than glyph of repulsion?
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end, -- Duration of glyph
	trapPower = function(self,t) return math.max(1,self:combatScale(self:getTalentLevel(t) * self:getMag(15, true), 0, 0, 75, 75)) end, -- Used to determine detection and disarm power, about 75 at level 50
	action = function(self, t)
		local tg = {type="hit", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = self:spellCrit(t.getDamage(self, t))
		local trap = Trap.new{
			name = "glyph of explosion",
			kr_name = "폭발의 문양", kr_unided_name = "함정",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD, image = "trap/trap_glyph_explosion_02_64.png",
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				self:project({type="ball", x=x,y=y, radius=1}, x, y, engine.DamageType.LIGHT, self.dam, {type="light"})
				game.level.map:particleEmitter(x, y, 1, "sunburst", {radius=1, tx=x, ty=y})
				return true
			end,
			temporary = t.getDuration(self, t),
			x = tx, y = ty,
			disarm_power = math.floor(t.trapPower(self,t) * 0.8),
			detect_power = math.floor(t.trapPower(self,t) * 0.8),
			inc_damage = table.clone(self.inc_damage or {}, true),
			resists_pen = table.clone(self.resists_pen or {}, true),
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[바닥에 문양을 새기고 빛을 불어넣습니다. 문양 위에 발을 올린 모든 대상은 빛의 폭발에 휘말려 %0.2f 피해를 받습니다. 빛의 폭발은 주변 1 칸 반경에 영향을 줍니다. 
 		문양은 (탐지 난이도 %d / 해체 난이도 %d 이며 마법 능력치의 영향을 받아 난이도가 증가하는) 숨겨진 함정이며, %d 턴 동안 유지됩니다. 
 		피해량은 마법 능력치의 영향을 받아 증가합니다.]]): 
		format(damDesc(self, DamageType.LIGHT, damage), t.trapPower(self, t)*0.8, t.trapPower(self, t)*0.8, duration)
	end,
}

newTalent{
	name = "Glyph of Fatigue",
	kr_name = "피로의 문양",
	type = {"celestial/glyphs", 4},
	require = divi_req_high4,
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	positive = -10,
	no_energy = true,
	tactical = { DISABLE = 2 },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 100, 0.27, 0.55) end, -- Limit <100% slow
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end, -- Duration of glyph
	trapPower = function(self,t) return math.max(1,self:combatScale(self:getTalentLevel(t) * self:getMag(15, true), 0, 0, 75, 75)) end, -- Used to determine detection and disarm power, about 75 at level 50
	action = function(self, t)
		local tg = {type="hit", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = self:spellCrit(t.getSlow(self, t))
		local trap = Trap.new{
			name = "glyph of fatigue",
			kr_name = "피로의 문양", kr_unided_name = "함정",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD, image = "trap/trap_glyph_fatigue_01_64.png",
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				who:setEffect(who.EFF_SLOW, 5, {power=self.dam})
				return true
			end,
			temporary = t.getDuration(self, t),
			x = tx, y = ty,
			disarm_power = math.floor(t.trapPower(self,t)),
			detect_power = math.floor(t.trapPower(self,t)),
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t)
		local duration = t.getDuration(self, t)
		return ([[바닥에 문양을 새기고 빛을 불어넣습니다. 문양 위에 발을 올린 모든 대상은 5 턴 동안 %d%% 감속됩니다. 
 		문양은 (탐지 난이도 %d / 해체 난이도 %d 이며 마법 능력치의 영향을 받아 난이도가 증가하는) 숨겨진 함정이며, %d 턴 동안 유지됩니다.]]): 
 		format(100 * slow, t.trapPower(self, t), t.trapPower(self, t), duration)  
 	end, 
}
