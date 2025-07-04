AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

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
