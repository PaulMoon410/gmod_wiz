-- Wizard NPC Configuration
-- This file contains all the configurable settings for the Wizard NPC

WizardConfig = WizardConfig or {}

-- Health and Stats
WizardConfig.Health = 150
WizardConfig.MaxMana = 100
WizardConfig.ManaRegen = 4 -- Increased for constant healing support

-- Movement
WizardConfig.WalkSpeed = 60
WizardConfig.RunSpeed = 120

-- Combat Settings
WizardConfig.AttackRange = 800
WizardConfig.SpellCooldown = 3
WizardConfig.AlertRadius = 600

-- Behavior Settings
WizardConfig.PatrolRadius = 400
WizardConfig.FleeHealthPercent = 0.2

-- AI Enhancement Settings
WizardConfig.AI = {
    -- Learning System
    MemoryTimeout = 30, -- seconds to remember enemies
    SpellLearningRate = 0.1, -- how quickly spells adapt
    ThreatAssessmentWeight = 0.5, -- importance of threat levels
    
    -- Tactical Behavior
    UseAdvancedPositioning = true,
    CoverSearchRadius = 400,
    KiteDistance = 300,
    PredictionAccuracy = 0.8,
    
    -- Personality System
    PersonalityTypes = {"aggressive", "defensive", "balanced", "chaotic"},
    PersonalityInfluence = 0.7, -- how much personality affects behavior
    
    -- Performance
    ThinkInterval = 0.1,
    MaxMemoryEntries = 20,
    CleanupInterval = 60
}

-- Spell Damage
WizardConfig.FireballDamage = {min = 30, max = 50}
WizardConfig.LightningDamage = {min = 25, max = 40}
WizardConfig.HealAmount = {min = 20, max = 35}

-- Spell Costs
WizardConfig.ManaCost = {
    fireball = 25,
    lightning = 30,
    heal = 10, -- Reduced for frequent healing
    teleport = 40
}

-- Visual Settings
WizardConfig.Model = "models/player/kleiner.mdl"
WizardConfig.ShowManaBar = true
WizardConfig.ManaBarDistance = 400

-- Sound Settings
WizardConfig.Sounds = {
    fireball = "ambient/fire/mtov_flame2.wav",
    lightning = "ambient/energy/zap",
    heal = "items/medshot4.wav",
    death = "vo/npc/male01/pain0",
    cast = "npc/scanner/scanner_blip1.wav"
}

-- Effect Settings
WizardConfig.Effects = {
    enableAura = true,
    enableManaBar = true,
    enableParticles = true
}

-- Faction Settings (for compatibility with other mods)
WizardConfig.Faction = "neutral" -- Can be "neutral", "friendly", "hostile"
WizardConfig.FriendlyToPlayers = false -- Set to true if wizards should not attack players by default

-- Admin Console Commands
if SERVER then
    -- Spawn wizard with specific personality
    concommand.Add("wizard_spawn", function(ply, cmd, args)
        if not ply:IsAdmin() then 
            ply:ChatPrint("You must be an admin to use this command!")
            return 
        end
        
        local personality = args[1] or "balanced"
        local validPersonalities = {"aggressive", "defensive", "balanced", "chaotic"}
        
        if not table.HasValue(validPersonalities, personality) then
            personality = "balanced"
            ply:ChatPrint("Invalid personality! Using 'balanced'. Valid types: " .. table.concat(validPersonalities, ", "))
        end
        
        local trace = ply:GetEyeTrace()
        local wizard = ents.Create("npc_wizard")
        if IsValid(wizard) then
            wizard:SetPos(trace.HitPos + Vector(0, 0, 10))
            wizard:Spawn()
            wizard.Personality = personality
            wizard:GeneratePersonality()
            
            ply:ChatPrint("Spawned " .. personality .. " wizard at your crosshair!")
        else
            ply:ChatPrint("Failed to create wizard entity!")
        end
    end)
    
    -- Get wizard information
    concommand.Add("wizard_info", function(ply, cmd, args)
        if not ply:IsAdmin() then 
            ply:ChatPrint("You must be an admin to use this command!")
            return 
        end
        
        local trace = ply:GetEyeTrace()
        local ent = trace.Entity
        
        if IsValid(ent) and ent:GetClass() == "npc_wizard" then
            ply:ChatPrint("=== Wizard Information ===")
            ply:ChatPrint("Personality: " .. (ent.Personality or "Unknown"))
            ply:ChatPrint("Health: " .. ent:Health() .. "/" .. ent:GetMaxHealth())
            ply:ChatPrint("Mana: " .. (ent.CurrentMana or 0) .. "/" .. (ent.MaxMana or 100))
            ply:ChatPrint("AI State: " .. (ent.AIState or "Unknown"))
            ply:ChatPrint("Enemies Remembered: " .. table.Count(ent.EnemyMemory or {}))
            ply:ChatPrint("Current Target: " .. (IsValid(ent.Target) and ent.Target:GetClass() or "None"))
        else
            ply:ChatPrint("Look at a wizard NPC to get information!")
        end
    end)
    
    -- Remove all wizards
    concommand.Add("wizard_removeall", function(ply, cmd, args)
        if not ply:IsAdmin() then 
            ply:ChatPrint("You must be an admin to use this command!")
            return 
        end
        
        local count = 0
        for _, ent in pairs(ents.FindByClass("npc_wizard")) do
            if IsValid(ent) then
                ent:Remove()
                count = count + 1
            end
        end
        
        ply:ChatPrint("Removed " .. count .. " wizard NPCs!")
    end)
    
    -- Toggle wizard AI debug mode
    concommand.Add("wizard_debug", function(ply, cmd, args)
        if not ply:IsAdmin() then 
            ply:ChatPrint("You must be an admin to use this command!")
            return 
        end
        
        WizardConfig.AI.DebugMode = not (WizardConfig.AI.DebugMode or false)
        ply:ChatPrint("Wizard AI Debug Mode: " .. (WizardConfig.AI.DebugMode and "ENABLED" or "DISABLED"))
    end)
    
    print("[Wizard NPC] Admin commands loaded:")
    print("  wizard_spawn <personality> - Spawn wizard with personality")
    print("  wizard_info - Get wizard information") 
    print("  wizard_removeall - Remove all wizards")
    print("  wizard_debug - Toggle AI debug mode")
end

return WizardConfig
