AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

ENT.PrintName = "Wizard"
ENT.Author = "Your Name"
ENT.Contact = ""
ENT.Purpose = "A magical wizard NPC that can cast spells"
ENT.Instructions = "Spawns a wizard NPC that will defend itself with magic"
ENT.Category = "NPCs"

ENT.Spawnable = true
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

-- Health and stats
ENT.Health = 150
ENT.WalkSpeed = 60
ENT.RunSpeed = 120

-- Spell system
ENT.Spells = {
    "fireball",
    "lightning",
    "heal",
    "teleport"
}
ENT.ManaCost = {
    fireball = 25,
    lightning = 30,
    heal = 10, -- Reduced from 20 to allow more frequent healing
    teleport = 40
}
ENT.MaxMana = 100
ENT.ManaRegen = 4 -- Increased from 2 to support constant healing

-- Combat settings
ENT.AttackRange = 800
ENT.SpellCooldown = 3
ENT.LastSpellTime = 0

-- Behavior settings
ENT.PatrolRadius = 400
ENT.AlertRadius = 600
ENT.FleeHealthPercent = 0.2

-- AI Enhancement Variables
ENT.AIState = "idle" -- idle, patrol, combat, flee, investigate
ENT.LastKnownEnemyPos = nil
ENT.SearchTime = 0
ENT.InvestigatePos = nil
ENT.CoverPoints = {}
ENT.PreferredRange = 400 -- Optimal combat distance
ENT.Personality = "balanced" -- aggressive, defensive, balanced, chaotic

-- Memory and Learning System
ENT.EnemyMemory = {} -- Stores info about encountered enemies
ENT.ThreatLevels = {} -- Dynamic threat assessment
ENT.SpellPreferences = {} -- Learns which spells work best
ENT.LastPositions = {} -- Track enemy movement patterns

-- Tactical AI Variables
ENT.UsesCover = true
ENT.CurrentCover = nil
ENT.LastCoverCheck = 0
ENT.KiteDistance = 300
ENT.IsKiting = false

function ENT:Initialize()
    self:SetModel("models/player/kleiner.mdl") -- Default model, can be changed
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_IDLE)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_MOVE_GROUND)
    self:CapabilitiesAdd(CAP_OPEN_DOORS)
    self:CapabilitiesAdd(CAP_TURN_HEAD)
    self:SetMaxYawSpeed(90)
    
    -- Initialize stats
    self:SetHealth(self.Health)
    self:SetMaxHealth(self.Health)
    self.CurrentMana = self.MaxMana
    self.SpawnPos = self:GetPos()
    self.IsPatrolling = true
    self.Target = nil
    self.LastManaRegen = CurTime()
    
    -- Initialize AI systems
    self:InitializeAI()
    self:GeneratePersonality()
    self:FindCoverPoints()
    
    -- Set up think timer
    self:SetThink(self.WizardThink)
    self:NextThink(CurTime() + 0.1)
    
    if SERVER then
        self:CreateWizardEffects()
    end
end

function ENT:InitializeAI()
    self.AIState = "idle"
    self.EnemyMemory = {}
    self.ThreatLevels = {}
    self.SpellPreferences = {
        fireball = {effectiveness = 0.5, uses = 0, hits = 0},
        lightning = {effectiveness = 0.5, uses = 0, hits = 0},
        heal = {effectiveness = 0.8, uses = 0, success = 0}
    }
    self.LastPositions = {}
end

function ENT:GeneratePersonality()
    local personalities = {"aggressive", "defensive", "balanced", "chaotic"}
    self.Personality = personalities[math.random(#personalities)]
    
    -- Adjust stats based on personality
    if self.Personality == "aggressive" then
        self.AttackRange = 600
        self.FleeHealthPercent = 0.1
        self.SpellCooldown = 2
        self.PreferredRange = 300
    elseif self.Personality == "defensive" then
        self.AttackRange = 900
        self.FleeHealthPercent = 0.4
        self.SpellCooldown = 4
        self.PreferredRange = 500
        self.UsesCover = true
    elseif self.Personality == "chaotic" then
        self.AttackRange = math.random(400, 800)
        self.SpellCooldown = math.random(1, 5)
        self.PreferredRange = math.random(200, 600)
    end
end

function ENT:FindCoverPoints()
    local coverPoints = {}
    local trace = {}
    trace.start = self:GetPos()
    trace.mask = MASK_SOLID_BRUSHONLY
    
    -- Find potential cover points in a radius
    for angle = 0, 360, 45 do
        for dist = 100, 400, 100 do
            local pos = self:GetPos() + Vector(math.cos(math.rad(angle)) * dist, math.sin(math.rad(angle)) * dist, 0)
            trace.endpos = pos + Vector(0, 0, 50)
            local tr = util.TraceLine(trace)
            
            if tr.Hit then
                table.insert(coverPoints, tr.HitPos - Vector(0, 0, 50))
            end
        end
    end
    
    self.CoverPoints = coverPoints
end

function ENT:CreateWizardEffects()
    -- Add particle effects or visual indicators that this is a wizard
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos() + Vector(0, 0, 60))
    effectdata:SetEntity(self)
    util.Effect("wizard_aura", effectdata)
end

function ENT:WizardThink()
    if not IsValid(self) then return end
    
    -- Regenerate mana
    if CurTime() - self.LastManaRegen >= 1 then
        self.CurrentMana = math.min(self.CurrentMana + self.ManaRegen, self.MaxMana)
        self.LastManaRegen = CurTime()
    end
    
    -- Constant healing check - prioritize healing above all else
    local healthPercent = self:Health() / self:GetMaxHealth()
    if healthPercent < 0.95 and self.CurrentMana >= self.ManaCost.heal then
        -- Always try to heal if not at full health and have mana
        if CurTime() - self.LastSpellTime >= (self.SpellCooldown * 0.5) then -- Reduced cooldown for healing
            self:CastHeal()
        end
    end
    
    -- Update AI state machine
    self:UpdateAIState()
    
    -- Execute current AI behavior
    if self.AIState == "idle" then
        self:IdleBehavior()
    elseif self.AIState == "patrol" then
        self:PatrolBehavior()
    elseif self.AIState == "combat" then
        self:AdvancedCombatBehavior()
    elseif self.AIState == "flee" then
        self:FleeBehavior()
    elseif self.AIState == "investigate" then
        self:InvestigateBehavior()
    end
    
    -- Update enemy memory and learning
    self:UpdateEnemyMemory()
    self:UpdateThreatAssessment()
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:UpdateAIState()
    local hasTarget = IsValid(self.Target)
    local healthPercent = self:Health() / self:GetMaxHealth()
    
    if hasTarget then
        if healthPercent <= self.FleeHealthPercent then
            self.AIState = "flee"
        else
            self.AIState = "combat"
        end
    elseif self.LastKnownEnemyPos and CurTime() - self.SearchTime < 10 then
        self.AIState = "investigate"
    elseif self.IsPatrolling then
        self.AIState = "patrol"
    else
        self.AIState = "idle"
    end
end

function ENT:IdleBehavior()
    -- Stand around, occasionally look around
    if math.random(1, 100) <= 5 then -- 5% chance per think
        local lookDir = VectorRand()
        lookDir.z = 0
        self:SetTarget(self:GetPos() + lookDir * 100)
    end
end

function ENT:InvestigateBehavior()
    if not self.InvestigatePos then
        self.InvestigatePos = self.LastKnownEnemyPos
    end
    
    if self.InvestigatePos then
        local dist = self:GetPos():Distance(self.InvestigatePos)
        if dist > 50 then
            self:SetTarget(self.InvestigatePos)
        else
            -- Reached investigation point, look around
            self:FindEnemies()
            if not IsValid(self.Target) then
                self.InvestigatePos = nil
                self.LastKnownEnemyPos = nil
                self.AIState = "patrol"
            end
        end
    end
end

function ENT:FindEnemies()
    local enemies = {}
    
    -- Find players
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() and ply:GetPos():Distance(self:GetPos()) <= self.AlertRadius then
            -- Check line of sight
            if self:CanSeeTarget(ply) then
                table.insert(enemies, ply)
                self:UpdateEnemyInfo(ply)
            end
        end
    end
    
    -- Find hostile NPCs
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), self.AlertRadius)) do
        if IsValid(ent) and ent ~= self and (ent:IsNPC() or ent:IsNextBot()) then
            if ent:GetClass() != "npc_wizard" and self:CanSeeTarget(ent) then
                table.insert(enemies, ent)
                self:UpdateEnemyInfo(ent)
            end
        end
    end
    
    -- Smart target selection based on threat level
    if #enemies > 0 then
        self.Target = self:SelectBestTarget(enemies)
        if IsValid(self.Target) then
            self.LastKnownEnemyPos = self.Target:GetPos()
            self.SearchTime = CurTime()
        end
    else
        self.Target = nil
    end
end

function ENT:CanSeeTarget(target)
    if not IsValid(target) then return false end
    
    local trace = {}
    trace.start = self:GetPos() + Vector(0, 0, 50)
    trace.endpos = target:GetPos() + Vector(0, 0, 30)
    trace.filter = self
    trace.mask = MASK_SOLID_BRUSHONLY
    
    local tr = util.TraceLine(trace)
    return not tr.Hit
end

function ENT:UpdateEnemyInfo(enemy)
    if not IsValid(enemy) then return end
    
    local id = enemy:EntIndex()
    if not self.EnemyMemory[id] then
        self.EnemyMemory[id] = {
            entity = enemy,
            firstSeen = CurTime(),
            lastSeen = CurTime(),
            damageDealt = 0,
            damageTaken = 0,
            positions = {}
        }
    end
    
    self.EnemyMemory[id].lastSeen = CurTime()
    table.insert(self.EnemyMemory[id].positions, {pos = enemy:GetPos(), time = CurTime()})
    
    -- Keep only recent positions
    if #self.EnemyMemory[id].positions > 10 then
        table.remove(self.EnemyMemory[id].positions, 1)
    end
end

function ENT:SelectBestTarget(enemies)
    local bestTarget = nil
    local bestScore = -1
    
    for _, enemy in pairs(enemies) do
        local score = self:CalculateThreatScore(enemy)
        if score > bestScore then
            bestScore = score
            bestTarget = enemy
        end
    end
    
    return bestTarget
end

function ENT:CalculateThreatScore(enemy)
    if not IsValid(enemy) then return 0 end
    
    local score = 0
    local dist = enemy:GetPos():Distance(self:GetPos())
    local id = enemy:EntIndex()
    
    -- Distance factor (closer = higher threat)
    score = score + (1000 - dist) / 1000 * 30
    
    -- Health factor (lower health = prioritize)
    if enemy:IsPlayer() then
        score = score + (100 - enemy:Health()) / 100 * 20
    end
    
    -- Memory-based threat assessment
    if self.EnemyMemory[id] then
        local memory = self.EnemyMemory[id]
        score = score + memory.damageDealt * 0.5
        score = score - memory.damageTaken * 0.3
    end
    
    -- Weapon-based threat (for players)
    if enemy:IsPlayer() and IsValid(enemy:GetActiveWeapon()) then
        local weapon = enemy:GetActiveWeapon():GetClass()
        if string.find(weapon, "rocket") or string.find(weapon, "grenade") then
            score = score + 40 -- High threat weapons
        elseif string.find(weapon, "shotgun") or string.find(weapon, "rifle") then
            score = score + 25
        end
    end
    
    return score
end

function ENT:AdvancedCombatBehavior()
    if not IsValid(self.Target) then return end
    
    self:FindEnemies() -- Keep updating targets
    
    local dist = self.Target:GetPos():Distance(self:GetPos())
    local healthPercent = self:Health() / self:GetMaxHealth()
    
    -- Personality-based behavior modifications
    if self.Personality == "chaotic" and math.random(1, 100) <= 10 then
        -- 10% chance to do something random
        self:ChaoticBehavior()
        return
    end
    
    -- Face the target
    self:SetTarget(self.Target)
    
    -- Tactical positioning
    if self:ShouldUseCover() then
        self:MoveToCover()
    elseif self:ShouldKite() then
        self:KiteBehavior()
    elseif dist > self.PreferredRange * 1.2 then
        -- Move closer if too far
        self:ApproachTarget()
    elseif dist < self.PreferredRange * 0.5 then
        -- Back away if too close
        self:RetreatFromTarget()
    end
    
    -- Cast spells with intelligent selection
    if CurTime() - self.LastSpellTime >= self.SpellCooldown then
        local spell = self:SelectOptimalSpell()
        if spell then
            self:CastSpellByName(spell)
        end
    end
end

function ENT:ShouldUseCover()
    if not self.UsesCover or #self.CoverPoints == 0 then return false end
    
    local healthPercent = self:Health() / self:GetMaxHealth()
    local dist = IsValid(self.Target) and self.Target:GetPos():Distance(self:GetPos()) or 999
    
    -- Use cover if low health or facing multiple enemies
    if healthPercent < 0.4 or self:CountNearbyEnemies() > 1 then
        return true
    end
    
    -- Defensive personality uses cover more often
    if self.Personality == "defensive" and healthPercent < 0.7 then
        return true
    end
    
    return false
end

function ENT:MoveToCover()
    if CurTime() - self.LastCoverCheck < 2 then return end
    self.LastCoverCheck = CurTime()
    
    local bestCover = nil
    local bestScore = -1
    
    for _, coverPos in pairs(self.CoverPoints) do
        local score = self:EvaluateCoverPoint(coverPos)
        if score > bestScore then
            bestScore = score
            bestCover = coverPos
        end
    end
    
    if bestCover then
        self.CurrentCover = bestCover
        self:SetTarget(bestCover)
    end
end

function ENT:EvaluateCoverPoint(coverPos)
    if not IsValid(self.Target) then return 0 end
    
    local score = 0
    local distToCover = self:GetPos():Distance(coverPos)
    local distToEnemy = coverPos:Distance(self.Target:GetPos())
    
    -- Prefer closer cover
    score = score + (500 - distToCover) / 500 * 30
    
    -- Prefer cover that maintains good distance from enemy
    if distToEnemy > self.PreferredRange * 0.8 and distToEnemy < self.PreferredRange * 1.5 then
        score = score + 20
    end
    
    -- Check if cover actually blocks line of sight
    local trace = {}
    trace.start = coverPos + Vector(0, 0, 50)
    trace.endpos = self.Target:GetPos() + Vector(0, 0, 30)
    trace.mask = MASK_SOLID_BRUSHONLY
    
    if util.TraceLine(trace).Hit then
        score = score + 25 -- Good cover
    end
    
    return score
end

function ENT:ShouldKite()
    if not IsValid(self.Target) then return false end
    
    local dist = self.Target:GetPos():Distance(self:GetPos())
    local enemySpeed = self.Target:GetVelocity():Length()
    
    -- Kite if enemy is fast and close
    if dist < self.KiteDistance and enemySpeed > 100 then
        return true
    end
    
    -- Aggressive personality kites less
    if self.Personality == "aggressive" then
        return false
    end
    
    return self.IsKiting
end

function ENT:KiteBehavior()
    if not IsValid(self.Target) then return end
    
    self.IsKiting = true
    local enemyPos = self.Target:GetPos()
    local myPos = self:GetPos()
    
    -- Predict enemy movement
    local enemyVel = self.Target:GetVelocity()
    local predictedPos = enemyPos + enemyVel * 0.5
    
    -- Move perpendicular to enemy's movement
    local awayVector = (myPos - predictedPos):GetNormalized()
    local perpVector = Vector(-awayVector.y, awayVector.x, 0)
    
    -- Choose left or right based on obstacles
    local leftPos = myPos + perpVector * 200
    local rightPos = myPos - perpVector * 200
    
    local kitePos = self:ChooseBetterKitePosition(leftPos, rightPos)
    self:SetTarget(kitePos)
    
    -- Stop kiting if we get good distance
    if myPos:Distance(enemyPos) > self.PreferredRange then
        self.IsKiting = false
    end
end

function ENT:ChooseBetterKitePosition(pos1, pos2)
    local trace1 = util.TraceLine({
        start = self:GetPos(),
        endpos = pos1,
        filter = self,
        mask = MASK_SOLID
    })
    
    local trace2 = util.TraceLine({
        start = self:GetPos(),
        endpos = pos2,
        filter = self,
        mask = MASK_SOLID
    })
    
    if trace1.Hit and not trace2.Hit then
        return pos2
    elseif trace2.Hit and not trace1.Hit then
        return pos1
    else
        -- Both clear or both blocked, choose randomly
        return math.random(2) == 1 and pos1 or pos2
    end
end

function ENT:ApproachTarget()
    if IsValid(self.Target) then
        self:SetTarget(self.Target:GetPos())
    end
end

function ENT:RetreatFromTarget()
    if not IsValid(self.Target) then return end
    
    local retreatDir = (self:GetPos() - self.Target:GetPos()):GetNormalized()
    local retreatPos = self:GetPos() + retreatDir * 150
    self:SetTarget(retreatPos)
end

function ENT:ChaoticBehavior()
    local actions = {
        function() self:CastRandomSpell() end,
        function() self:SetTarget(self:GetPos() + VectorRand() * 300) end,
        function() self:EmitSound("vo/npc/male01/fantastic01.wav") end,
        function() self:TeleportRandomly() end
    }
    
    local action = actions[math.random(#actions)]
    action()
end

function ENT:CountNearbyEnemies()
    local count = 0
    local myPos = self:GetPos()
    
    for _, ent in pairs(ents.FindInSphere(myPos, self.AlertRadius)) do
        if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) and ent ~= self then
            if ent:GetClass() ~= "npc_wizard" then
                count = count + 1
            end
        end
    end
    
    return count
end

function ENT:PatrolBehavior()
    if self.IsPatrolling then
        -- Simple patrol around spawn point
        if not self:IsMoving() then
            local patrolPos = self.SpawnPos + Vector(
                math.random(-self.PatrolRadius, self.PatrolRadius),
                math.random(-self.PatrolRadius, self.PatrolRadius),
                0
            )
            self:SetTarget(patrolPos)
        end
    end
end

function ENT:FleeBehavior()
    if IsValid(self.Target) then
        local fleeDir = (self:GetPos() - self.Target:GetPos()):GetNormalized()
        local fleePos = self:GetPos() + fleeDir * 400
        self:SetTarget(fleePos)
        
        -- Constantly try to heal when fleeing - ignore cooldowns
        if self.CurrentMana >= self.ManaCost.heal and self:Health() < self:GetMaxHealth() then
            if CurTime() - self.LastSpellTime >= 1 then -- Very short cooldown when fleeing
                self:CastHeal()
            end
        end
    end
end

function ENT:SelectOptimalSpell()
    if not IsValid(self.Target) then return nil end
    
    local dist = self.Target:GetPos():Distance(self:GetPos())
    local healthPercent = self:Health() / self:GetMaxHealth()
    local targetHealth = self.Target:Health and self.Target:Health() or 100
    local availableSpells = {}
    
    -- Check which spells we can afford
    for spell, cost in pairs(self.ManaCost) do
        if self.CurrentMana >= cost then
            table.insert(availableSpells, spell)
        end
    end
    
    if #availableSpells == 0 then return nil end
    
    -- Priority system based on situation
    local spellScores = {}
    
    for _, spell in pairs(availableSpells) do
        local score = 0
        
        if spell == "heal" then
            -- Extremely high priority for any health loss
            if healthPercent < 0.95 then
                score = 200 -- Maximum priority for any damage
            elseif healthPercent < 0.99 then
                score = 150 -- Very high priority even for minor damage
            else
                score = 100 -- Still high priority when at full health (for prevention)
            end
            
            -- Extra bonus if we have lots of mana
            if self.CurrentMana > self.MaxMana * 0.7 then
                score = score + 50
            end
        elseif spell == "fireball" then
            -- Good for medium-long range, high damage
            if dist > 200 and dist < 600 then
                score = 60
            elseif targetHealth > 50 then
                score = 50 -- Good against healthy targets
            else
                score = 30
            end
            
            -- Bonus based on past effectiveness
            score = score + self.SpellPreferences.fireball.effectiveness * 20
            
        elseif spell == "lightning" then
            -- Good for close-medium range, instant hit
            if dist < 400 then
                score = 70
            else
                score = 40
            end
            
            -- Better against fast-moving targets
            if IsValid(self.Target) and self.Target:GetVelocity():Length() > 200 then
                score = score + 20
            end
            
            score = score + self.SpellPreferences.lightning.effectiveness * 20
            
        elseif spell == "teleport" then
            -- Emergency escape or tactical repositioning
            if healthPercent < 0.2 then
                score = 90
            elseif dist < 150 then -- Too close
                score = 60
            elseif self:CountNearbyEnemies() > 2 then
                score = 50
            else
                score = 20
            end
        end
        
        -- Personality modifiers - but always prioritize healing heavily
        if self.Personality == "aggressive" then
            if spell == "fireball" or spell == "lightning" then
                score = score * 1.3
            elseif spell == "heal" then
                score = score * 1.2 -- Even aggressive wizards heal aggressively now
            end
        elseif self.Personality == "defensive" then
            if spell == "heal" or spell == "teleport" then
                score = score * 1.8 -- Defensive wizards heal extremely aggressively
            end
        elseif self.Personality == "balanced" then
            if spell == "heal" then
                score = score * 1.5 -- Balanced wizards also prioritize healing
            end
        elseif self.Personality == "chaotic" then
            score = score * math.random(50, 150) / 100
        end
        
        spellScores[spell] = score
    end
    
    -- Select best spell
    local bestSpell = nil
    local bestScore = -1
    
    for spell, score in pairs(spellScores) do
        if score > bestScore then
            bestScore = score
            bestSpell = spell
        end
    end
    
    return bestSpell
end

function ENT:CastSpellByName(spellName)
    if not spellName or self.CurrentMana < self.ManaCost[spellName] then return end
    
    local success = false
    
    if spellName == "fireball" then
        success = self:CastFireball()
    elseif spellName == "lightning" then
        success = self:CastLightning()
    elseif spellName == "heal" then
        success = self:CastHeal()
    elseif spellName == "teleport" then
        success = self:CastTeleport()
    end
    
    if success then
        self.CurrentMana = self.CurrentMana - self.ManaCost[spellName]
        self.LastSpellTime = CurTime()
        
        -- Update spell usage statistics
        if self.SpellPreferences[spellName] then
            self.SpellPreferences[spellName].uses = self.SpellPreferences[spellName].uses + 1
        end
    end
end

function ENT:CastRandomSpell()
    local spells = {"fireball", "lightning", "teleport"}
    local spell = spells[math.random(#spells)]
    
    if self.CurrentMana >= self.ManaCost[spell] then
        self:CastSpellByName(spell)
    end
end

function ENT:CastTeleport()
    local teleportPositions = {}
    
    -- Find safe teleport positions
    for i = 1, 8 do
        local angle = (i - 1) * 45
        local dist = math.random(200, 400)
        local pos = self:GetPos() + Vector(
            math.cos(math.rad(angle)) * dist,
            math.sin(math.rad(angle)) * dist,
            0
        )
        
        -- Check if position is valid
        local trace = util.TraceLine({
            start = pos + Vector(0, 0, 50),
            endpos = pos - Vector(0, 0, 100),
            filter = self,
            mask = MASK_SOLID
        })
        
        if trace.Hit then
            table.insert(teleportPositions, trace.HitPos + Vector(0, 0, 10))
        end
    end
    
    if #teleportPositions > 0 then
        local teleportPos = teleportPositions[math.random(#teleportPositions)]
        
        -- Teleport effect at current position
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("wizard_teleport_out", effectdata)
        
        self:SetPos(teleportPos)
        
        -- Teleport effect at new position
        effectdata:SetOrigin(teleportPos)
        util.Effect("wizard_teleport_in", effectdata)
        
        self:EmitSound("ambient/machines/teleport" .. math.random(1, 4) .. ".wav", 75, 100)
        
        return true
    end
    
    return false
end

function ENT:TeleportRandomly()
    self:CastTeleport()
end

function ENT:CastFireball()
    if not IsValid(self.Target) then return false end
    
    local startPos = self:GetPos() + Vector(0, 0, 50)
    local targetPos = self:PredictTargetPosition()
    local direction = (targetPos - startPos):GetNormalized()
    
    -- Create fireball projectile
    local fireball = ents.Create("ent_wizard_fireball")
    if IsValid(fireball) then
        fireball:SetPos(startPos)
        fireball:SetAngles(direction:Angle())
        fireball:SetOwner(self)
        fireball:Spawn()
        fireball:SetVelocity(direction * 800)
        
        -- Store reference for hit tracking
        fireball.WizardCaster = self
        fireball.SpellType = "fireball"
    end
    
    -- Visual and sound effects
    self:EmitSound("ambient/fire/mtov_flame2.wav", 75, 100)
    
    -- Casting animation
    self:PlaySequenceAndWait("magic_cast")
    
    return true
end

function ENT:CastLightning()
    if not IsValid(self.Target) then return false end
    
    local startPos = self:GetPos() + Vector(0, 0, 50)
    local targetPos = self:PredictTargetPosition()
    
    -- Lightning effect
    local effectdata = EffectData()
    effectdata:SetStart(startPos)
    effectdata:SetOrigin(targetPos)
    effectdata:SetMagnitude(1)
    effectdata:SetScale(1)
    util.Effect("wizard_lightning", effectdata)
    
    -- Check if we hit the target
    local hit = false
    local dist = targetPos:Distance(self.Target:GetPos())
    
    if dist < 100 then -- Lightning has some area effect
        hit = true
        local damage = math.random(25, 40)
        
        -- Apply damage
        local damageinfo = DamageInfo()
        damageinfo:SetDamage(damage)
        damageinfo:SetAttacker(self)
        damageinfo:SetInflictor(self)
        damageinfo:SetDamageType(DMG_SHOCK)
        self.Target:TakeDamageInfo(damageinfo)
        
        -- Track damage for learning
        local id = self.Target:EntIndex()
        if self.EnemyMemory[id] then
            self.EnemyMemory[id].damageDealt = self.EnemyMemory[id].damageDealt + damage
        end
    end
    
    -- Update spell effectiveness
    if self.SpellPreferences.lightning then
        if hit then
            self.SpellPreferences.lightning.hits = self.SpellPreferences.lightning.hits + 1
        end
        self:UpdateSpellEffectiveness("lightning")
    end
    
    -- Sound effect
    self:EmitSound("ambient/energy/zap" .. math.random(1, 9) .. ".wav", 75, 100)
    
    -- Casting animation
    self:PlaySequenceAndWait("magic_cast")
    
    return true
end

function ENT:CastHeal()
    local oldHealth = self:Health()
    if oldHealth >= self:GetMaxHealth() then return false end
    
    local healAmount = math.random(20, 35)
    local newHealth = math.min(oldHealth + healAmount, self:GetMaxHealth())
    self:SetHealth(newHealth)
    
    -- Healing effect
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos() + Vector(0, 0, 30))
    util.Effect("wizard_heal", effectdata)
    
    -- Sound effect
    self:EmitSound("items/medshot4.wav", 75, 120)
    
    -- Track healing effectiveness
    if self.SpellPreferences.heal then
        self.SpellPreferences.heal.success = self.SpellPreferences.heal.success + (newHealth - oldHealth)
        self:UpdateSpellEffectiveness("heal")
    end
    
    return true
end

function ENT:PredictTargetPosition()
    if not IsValid(self.Target) then return self:GetPos() end
    
    local targetPos = self.Target:GetPos() + Vector(0, 0, 30)
    local targetVel = self.Target:GetVelocity()
    
    -- Simple prediction based on velocity
    if targetVel:Length() > 50 then
        local timeToTarget = targetPos:Distance(self:GetPos()) / 800 -- Projectile speed
        targetPos = targetPos + targetVel * timeToTarget * 0.8 -- Slight prediction
    end
    
    return targetPos
end

function ENT:UpdateSpellEffectiveness(spellName)
    if not self.SpellPreferences[spellName] then return end
    
    local pref = self.SpellPreferences[spellName]
    
    if spellName == "heal" then
        -- Effectiveness based on how much we actually healed
        if pref.uses > 0 then
            pref.effectiveness = math.min(pref.success / (pref.uses * 30), 1.0) -- 30 is average heal
        end
    else
        -- Effectiveness based on hit rate
        if pref.uses > 0 then
            pref.effectiveness = pref.hits / pref.uses
        end
    end
end

function ENT:UpdateEnemyMemory()
    -- Clean up old memory entries
    for id, memory in pairs(self.EnemyMemory) do
        if not IsValid(memory.entity) or CurTime() - memory.lastSeen > 30 then
            self.EnemyMemory[id] = nil
        end
    end
end

function ENT:UpdateThreatAssessment()
    -- Update threat levels based on recent encounters
    for id, memory in pairs(self.EnemyMemory) do
        if IsValid(memory.entity) then
            local threat = 0
            threat = threat + memory.damageDealt * 0.1
            threat = threat - memory.damageTaken * 0.05
            threat = threat + (CurTime() - memory.firstSeen) * 0.01 -- Persistent enemies are more threatening
            
            self.ThreatLevels[id] = math.max(0, math.min(threat, 100))
        end
    end
end

function ENT:OnTakeDamage(dmg)
    local attacker = dmg:GetAttacker()
    local damage = dmg:GetDamage()
    
    -- Track damage taken for learning
    if IsValid(attacker) and attacker != self then
        self.Target = attacker
        self.LastKnownEnemyPos = attacker:GetPos()
        self.SearchTime = CurTime()
        
        -- Update enemy memory
        local id = attacker:EntIndex()
        if self.EnemyMemory[id] then
            self.EnemyMemory[id].damageTaken = self.EnemyMemory[id].damageTaken + damage
        else
            self:UpdateEnemyInfo(attacker)
            if self.EnemyMemory[id] then
                self.EnemyMemory[id].damageTaken = damage
            end
        end
        
        -- Become more aggressive against this attacker
        if self.ThreatLevels[id] then
            self.ThreatLevels[id] = self.ThreatLevels[id] + damage * 0.2
        else
            self.ThreatLevels[id] = damage * 0.2
        end
    end
    
    -- Immediately try to heal when taking damage
    if self.CurrentMana >= self.ManaCost.heal and damage > 5 then
        -- Force healing with minimal cooldown when taking significant damage
        if CurTime() - self.LastSpellTime >= 0.5 then
            timer.Simple(0.1, function()
                if IsValid(self) and self:Health() < self:GetMaxHealth() then
                    self:CastHeal()
                end
            end)
        end
    end
    
    -- Pain sounds based on personality
    if self.Personality == "chaotic" then
        self:EmitSound("vo/npc/male01/ow0" .. math.random(1, 2) .. ".wav", 75, math.random(80, 120))
    else
        self:EmitSound("vo/npc/male01/pain0" .. math.random(1, 9) .. ".wav", 75, 100)
    end
    
    -- Default damage handling
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        self:OnKilled(dmg)
    end
end

function ENT:OnKilled(dmg)
    -- Death effects
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect("wizard_death", effectdata)
    
    self:EmitSound("vo/npc/male01/pain0" .. math.random(1, 9) .. ".wav", 75, 80)
    
    -- Remove the entity
    self:Remove()
end

-- Utility functions
function ENT:PlaySequenceAndWait(sequence)
    local seqId = self:LookupSequence(sequence)
    if seqId > 0 then
        self:SetSequence(seqId)
        self:SetPlaybackRate(1)
    end
end

function ENT:IsMoving()
    return self:GetVelocity():Length() > 10
end

-- Networking for mana display
if SERVER then
    util.AddNetworkString("wizard_mana_update")
    
    function ENT:SendManaUpdate()
        net.Start("wizard_mana_update")
        net.WriteEntity(self)
        net.WriteFloat(self.CurrentMana / self.MaxMana)
        net.Broadcast()
    end
end
