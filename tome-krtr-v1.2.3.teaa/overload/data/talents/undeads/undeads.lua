﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- Undead talents
newTalentType{ type="undead/base", name = "base", generic = true, description = "언데드의 선천적 능력." }
newTalentType{ type="undead/ghoul", name = "ghoul", generic = true, description = "구울의 선천적 능력." }
newTalentType{ type="undead/skeleton", name = "skeleton", generic = true, description = "스켈레톤의 선천적 능력." }
newTalentType{ type="undead/vampire", name = "vampire", generic = true, description = "흡혈귀의 선천적 능력." }
newTalentType{ type="undead/lich", name = "lich", generic = true, description = "리치의 선천적 능력." }

-- Generic requires for undeads based on talent level
undeads_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
undeads_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
undeads_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
undeads_req4 = {
	level = function(level) return 12 + (level-1)  end,
}
undeads_req5 = {
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/undeads/ghoul.lua")
load("/data/talents/undeads/skeleton.lua")


-- Undeads's power: ID
newTalent{
	short_name = "UNDEAD_ID",
	name = "Knowledge of the Past",
	kr_name = "과거로부터의 지식",
	type = {"undead/base", 1},
	no_npc_use = true,
	mode = "passive",
	no_unlearn_last = true,
	on_learn = function(self, t) self.auto_id = 100 end,
	info = function(self)
		return ([[집중하여 자신이 살아있던 시절의 기억을 되살립니다. 이 생전의 기억에서, 진귀한 물건을 감정하기 위한 지식을 찾아봅니다.]])
	end,
}
