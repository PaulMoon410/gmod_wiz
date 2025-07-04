AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Wizard Fireball"
ENT.Author = "Your Name"
ENT.Contact = ""
ENT.Purpose = "Fireball projectile for wizard NPC"
ENT.Instructions = ""
ENT.Category = "Projectiles"

ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/dav0r/hoverball.mdl")
        self:SetMaterial("models/debug/debugwhite")
        self:SetColor(Color(255, 100, 0, 255))
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:SetMass(1)
        end
        
        -- Set up collision detection
        self:SetTrigger(true)
        
        -- Remove after 10 seconds
        timer.Simple(10, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
        
        -- Fire trail effect
        self:CreateFireTrail()
    end
end

function ENT:CreateFireTrail()
    if CLIENT then return end
    
    timer.Create("fireball_trail_" .. self:EntIndex(), 0.05, 0, function()
        if not IsValid(self) then return end
        
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetScale(1)
        util.Effect("fire_trail", effectdata)
    end)
end

function ENT:PhysicsCollide(data, physobj)
    if SERVER then
        self:Explode()
    end
end

function ENT:Touch(ent)
    if SERVER and IsValid(ent) and ent != self:GetOwner() then
        if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
            self:Explode()
        end
    end
end

function ENT:Explode()
    if not IsValid(self) then return end
    
    local pos = self:GetPos()
    local owner = self:GetOwner()
    local hitSomething = false
    
    -- Explosion effect
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    effectdata:SetMagnitude(100)
    effectdata:SetScale(1)
    effectdata:SetRadius(100)
    util.Effect("Explosion", effectdata)
    
    -- Sound
    self:EmitSound("weapons/explode" .. math.random(3, 5) .. ".wav", 75, 100)
    
    -- Damage nearby entities
    local damage = 40
    local radius = 100
    
    for _, ent in pairs(ents.FindInSphere(pos, radius)) do
        if IsValid(ent) and ent != self and ent != owner then
            if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
                local distance = ent:GetPos():Distance(pos)
                local damageAmount = damage * (1 - (distance / radius))
                
                if damageAmount > 0 then
                    hitSomething = true
                    
                    local damageinfo = DamageInfo()
                    damageinfo:SetDamage(damageAmount)
                    damageinfo:SetAttacker(owner or self)
                    damageinfo:SetInflictor(self)
                    damageinfo:SetDamageType(DMG_BURN)
                    damageinfo:SetDamagePosition(pos)
                    ent:TakeDamageInfo(damageinfo)
                    
                    -- Track damage for wizard learning system
                    if IsValid(owner) and owner:GetClass() == "npc_wizard" then
                        local id = ent:EntIndex()
                        if owner.EnemyMemory[id] then
                            owner.EnemyMemory[id].damageDealt = owner.EnemyMemory[id].damageDealt + damageAmount
                        end
                    end
                    
                    -- Set on fire
                    if ent:IsPlayer() and damageAmount > 10 then
                        ent:Ignite(3, 0)
                    end
                end
            end
        end
    end
    
    -- Update spell effectiveness for wizard AI
    if IsValid(owner) and owner:GetClass() == "npc_wizard" then
        if owner.SpellPreferences.fireball then
            if hitSomething then
                owner.SpellPreferences.fireball.hits = owner.SpellPreferences.fireball.hits + 1
            end
            owner:UpdateSpellEffectiveness("fireball")
        end
    end
    
    -- Clean up timer
    timer.Remove("fireball_trail_" .. self:EntIndex())
    
    -- Remove the fireball
    self:Remove()
end

function ENT:OnRemove()
    if SERVER then
        timer.Remove("fireball_trail_" .. self:EntIndex())
    end
end
