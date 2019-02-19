AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

team_colors  = {Color(255,50,50,255),Color(50,50,255,255),Color(255,200,50,255),Color(30,200,30,255),Color(100,0,80,255),Color(100,255,255,255),Color(255,120,0,255),Color(255,100,150,255)}

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetMoveType( MOVETYPE_NONE )
	self:SetMaterial("models/combine_scanner/scanner_eye")
	self:SetModel("models/props_junk/watermelon01.mdl")
	self:SetColor(Color(255,0,0,255))
	self:SetUseType( SIMPLE_USE )
	self.melonTeam = 0
	self.melonClass = "NO CLASS ASIGNED"
	self.attach = false;
end

function ENT:Use( activator, caller, useType, value )
	net.Start("EditorSetTeam")
		net.WriteEntity(self)
	net.Send(activator)
	--self.melonTeam = 2
	--self:SetColor(Color(0,0,255,255))
end

function ENT:PostEntityPaste( ply, ent, createdEntities )
	self:SetColor(team_colors[self.melonTeam])
end

function ENT:SetMelonTeam(newteam, class, attach)
	self.melonTeam = newteam
	self.melonClass = class
	self.attach = attach
	self:SetColor(team_colors[self.melonTeam])
end