AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	Defaults ( self )

	self.modelString = "models/props_combine/combine_light001a.mdl"
	self.maxHP = 100
	self.Angles = Angle(0,0,0)
	--self:SetPos(self:GetPos()+Vector(0,0,-5))
	--self:SetPos(self:GetPos()+Vector(0,0,10))
	self.canMove = false
	self.moveType = MOVETYPE_NONE
	self.connections = {}

	self.range = 50

	self.population = 0
	self:SetNWInt("energy", 0)
	self:SetNWInt("maxenergy", 100)
	self:SetNWVector("energyPos", Vector(0,0,0))
	--print("Finished changing stats")
	--self:BarrackInitialize()
	self.population = 3
	self.canBeSelected = false

	Setup ( self )

	self.connection = nil

	self:SetNWBool("active", false)
	--InciteConnections(self)
	CalculateConnections(self)
	self:SetNWBool("canGive", false)
	self:SetNWFloat("overdrive", 0)
	self:GetPhysicsObject():EnableMotion(false)
	--print("Finished Initialize")

	self:NextThink(CurTime()+1)
	timer.Simple(0.5, function () self:ConnectToBarrack() end)
end

function ENT:ConnectToBarrack()
	local connected = false
	local entities = ents.FindInSphere( self:GetPos(), self.range )
		--------------------------------------------------------Disparar
	local foundEntities = {}

	for k, v in pairs(entities) do
		if ((string.StartWith(v:GetClass(), "ent_melon_barracks") or v:GetClass() == "ent_melon_contraption_assembler") and v:GetNWInt("melonTeam", 0) == self:GetNWInt("melonTeam", 0)) then -- si no es un aliado
			table.insert(foundEntities, v)
		end
	end

	local closestEntity = nil
	local closestDistance = 0
	for k, v in pairs(foundEntities) do
		if (closestEntity == nil or self:GetPos():DistToSqr( v:GetPos() ) < closestDistance) then
			closestEntity = v
			closestDistance = self:GetPos():DistToSqr( v:GetPos() )
		end
	end
	
	if (closestEntity != nil) then
		self.connection = closestEntity
		constraint.Rope( self, closestEntity, 0, 0, Vector(0,0,10), Vector(0,0,5), self:GetPos():Distance(closestEntity:GetPos()), 0, 0, 10, "cable/physbeam", false )
	else
		for k, v in pairs(player.GetAll()) do
			if (v:GetInfoNum("mw_team", 0) == self:GetNWInt("melonTeam", 0)) then
				v:PrintMessage( HUD_PRINTTALK, "///// Over-Clockers must be spawned next to a Barracks" )
			end
		end
		self:Remove()
	end
end

function ENT:Think(ent)
	if (!IsValid(self.connection)) then
		self:DeathEffect( self )
	else
		local energy = math.Round(self:GetNWInt("energy", 0))
		local max = self:GetNWInt("maxenergy", 0)
		self:SetNWString("message", "Energy: "..energy.." / "..max)
		PullEnergy(self)
		if (self:GetNWBool("active", true) and (!self.connection:GetNWBool("spawned", false) or self.connection:GetClass() == "ent_melon_contraption_assembler") and self.connection:GetNWBool("active", false)) then
			if (energy > 10) then
				self.connection:SetNWFloat("overdrive", self.connection:GetNWFloat("overdrive", 0)+0.125)
				self:SetNWInt("energy", self:GetNWInt("energy", 0)-10)
			end
		end
	end
end

function ENT:SlowThink(ent)

end

function ENT:Shoot ( ent )

end

function ENT:DeathEffect ( ent )
	DefaultDeathEffect ( ent )
end

function ENT:BarrackSlowThink()

end