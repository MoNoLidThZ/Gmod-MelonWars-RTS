AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	Defaults ( self )

	self.unit = 8
	self.modelString = "models/props_wasteland/laundry_washer001a.mdl"
	self.maxHP = 120
	self.Angles = Angle(0,0,0)
	self:SetPos(self:GetPos()+Vector(0,0,20))

	--print("Changing stats")
	
	self:BarrackInitialize()
	self.population = 5
	self:SetNWInt("maxunits", 3)
	--print("Finished changing stats")

	Setup ( self )
	
	--print("Finished Initialize")
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