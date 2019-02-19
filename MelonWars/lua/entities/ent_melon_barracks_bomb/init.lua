AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	Defaults ( self )

	self.unit = 3
	self.modelString = "models/props_wasteland/laundry_basket001.mdl"
	self.Angles = Angle(0,0,180)
	self.maxHP = 100
	self:SetPos(self:GetPos()+Vector(0,0,10))

	--print("Changing stats")
	
	self:BarrackInitialize()
	self.population = 3
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