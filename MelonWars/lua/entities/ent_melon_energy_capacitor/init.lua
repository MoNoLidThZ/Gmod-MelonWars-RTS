AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	Defaults ( self )

	self.modelString = "models/props_phx/wheels/drugster_back.mdl"
	self.maxHP = 100
	self.Angles = Angle(0,0,0)
	self:SetPos(self:GetPos()+Vector(0,0,-5))
	--self:SetPos(self:GetPos()+Vector(0,0,10))
	self.moveType = MOVETYPE_NONE
	self.connections = {}

	self.population = 0
	self:SetNWInt("energy", 0)
	self:SetNWInt("maxenergy", 1000)
	self:SetNWVector("energyPos", Vector(0,0,30))
	--print("Finished changing stats")

	Setup ( self )
	
	--InciteConnections(self)

	CalculateConnections(self)
	self:SetNWBool("canGive", true)
	--print("Finished Initialize")
end

function ENT:Think(ent)
	local energy = math.Round(self:GetNWInt("energy", 0))
	local max = self:GetNWInt("maxenergy", 0)
	self:SetNWString("message", "Energy: "..energy.." / "..max)

	ExchangeEnergy(self)

	self:NextThink( CurTime()+0.5 )
	return true
end

function ENT:SlowThink(ent)

end

function ENT:Shoot ( ent )

end

function ENT:DeathEffect ( ent )
	DefaultDeathEffect ( ent )
end