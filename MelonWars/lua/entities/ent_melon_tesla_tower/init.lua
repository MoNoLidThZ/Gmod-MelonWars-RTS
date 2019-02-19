AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")
	
	Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/props_c17/FurnitureBoiler001a.mdl"
	self.speed = 80
	self.spread = 10
	self.damageDeal = 4
	self.maxHP = 100
	self.range = 250
	self.shotSound = "weapons/stunstick/stunstick_impact1.wav"
	--self.tracer = "AR2Tracer"
	self:SetPos(self:GetPos()+Vector(0,0,40))
	self.shotOffset = Vector(0,0,30)
	
	self.canMove = false
	self.canBeSelected = false
	self.moveType = MOVETYPE_NONE
	
	self.slowThinkTimer = 0.5
	--print("Finished changing stats")
	
	self:SetNWInt("energy", 0)
	self:SetNWInt("maxenergy", 100)
	self:SetNWVector("energyPos", Vector(0,0,20))
	--print("Finished changing stats")

	Setup ( self )
	
	--InciteConnections(self)

	CalculateConnections(self)
	self:SetNWBool("canGive", false)

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:GetPhysicsObject():EnableMotion(false)
end

function ENT:SlowThink ( ent )

	PullEnergy(self)

	if (self:GetNWInt("energy", 0) >= 15) then
		local entities = ents.FindInSphere( ent:GetPos(), ent.range )
		--------------------------------------------------------Disparar
		local targets = 0
		local maxtargets = 5

		local foundEntities = {}
		print("=============")
		for k, v in pairs(entities) do
			local tr = util.TraceLine( {
				start = self:GetPos()+self:GetVar("shotOffset", Vector(0,0,0)),
				endpos = v:GetPos()+v:GetVar("shotOffset", Vector(0,0,0)),
				filter = function( foundEnt )
					if ( foundEnt.Base == "ent_melon_base" or foundEnt:GetClass() == "prop_physics") then--si hay un prop en el medio
						return false
					end
					return true
				end
			})
			print(PrintTable(tr))
			if (tostring(tr.Entity) == '[NULL Entity]') then
				if (v.Base == "ent_melon_base" and !ent:SameTeam(v) and v:GetNWInt("melonTeam", 0) != ent:GetNWInt("melonTeam", 0)) then -- si no es un aliado
					table.insert(foundEntities, v)
				end
			end
		end

		local closestEntities = {}
		for i=1, maxtargets do
			local closestDistance = 0
			local closestEntity = nil
			for k, v in pairs(foundEntities) do
				if (closestEntity == nil or ent:GetPos():DistToSqr( v:GetPos() ) < closestDistance) then
					closestEntity = v
					closestDistance = ent:GetPos():DistToSqr( v:GetPos() )
				end
			end
			table.RemoveByValue(foundEntities, closestEntity)
			table.insert(closestEntities, closestEntity)
		end

		for k, v in pairs(closestEntities) do
			if (self:GetNWInt("energy", 0) >= 15) then
			----------------------------------------------------------Encontró target
				v.damage = v.damage+self.damageDeal
				local effectdata = EffectData()
				effectdata:SetScale(1)
				effectdata:SetMagnitude(1)
				effectdata:SetStart( ent:GetPos() + Vector(0,0,45)) 
				effectdata:SetOrigin( v:GetPos() )
				util.Effect( "ToolTracer", effectdata )
				sound.Play( ent.shotSound, ent:GetPos() )
				self:SetNWInt("energy", self:GetNWInt("energy", 0)-15)
			end
		end
	end

	local energy = math.Round(self:GetNWInt("energy", 0))
	local max = self:GetNWInt("maxenergy", 0)
	self:SetNWString("message", "Energy: "..energy.." / "..max)
end

function ENT:Shoot ( ent )
	
end

function ENT:DeathEffect ( ent )
	DefaultDeathEffect ( ent )
end