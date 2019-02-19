AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	Defaults ( self )

	self.modelString = "models/props_combine/weaponstripper.mdl"
	self.maxHP = 100
	self.Angles = Angle(-90,0,180)
	local offset = Vector(-62.5,0,0)
	offset:Rotate(self:GetAngles())
	self:SetPos(self:GetPos()+offset)
	--self:SetPos(self:GetPos()+Vector(0,0,10))
	self.moveType = MOVETYPE_NONE
	self.connections = {}

	self.population = 0
	self:SetNWInt("energy", 0)
	self:SetNWInt("maxenergy", 50)
	self:SetNWVector("energyPos", Vector(0,0,62.5))

	--print("Finished changing stats")
	Setup ( self )
	
	--InciteConnections(self)
	CalculateConnections(self)
	self:SetNWBool("canGive", true)
	--print("Finished Initialize")
end

function ENT:Think(ent)
	if(self.spawned) then
		local energy = math.Round(self:GetNWInt("energy", 0))
		local max = self:GetNWInt("maxenergy", 0)
		if (energy < max) then
			self:SetNWString("message", "Generating energy")
			self:SetNWInt("energy", self:GetNWInt("energy", 0)+1) -- 1 es el valor normal
		else
			self:SetNWString("message", "Energy full!")
		end

		ExchangeEnergy(self)
	end

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