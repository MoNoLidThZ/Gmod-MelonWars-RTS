AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	Defaults ( self )

	self.unit = 2
	self.modelString = "models/props_junk/wood_crate002a.mdl"
	self.maxHP = 100
	self.Angles = Angle(0,0,0)
	self:SetPos(self:GetPos()+Vector(0,0,10))

	--print("Changing stats")
	
	self:BarrackInitialize()
	self.population = 3
	self:SetNWInt("maxunits", 5)
	--print("Finished changing stats")

	Setup ( self )
	
	--print("Finished Initialize")
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r+50, self:GetColor().g+50, self:GetColor().b+50, 255))
end

function ENT:Think(ent)

	self:SetNWInt("count", 0)

	self:BarrackSlowThink()

	self:NextThink(CurTime()+0.2)
	return true
end

function ENT:Shoot ( ent )
	--DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	DefaultDeathEffect ( ent )
end