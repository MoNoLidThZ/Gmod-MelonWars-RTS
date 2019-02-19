AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")

	Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/props_phx/misc/soccerball.mdl"
	self.materialString = "models/shiny"
	
	self.deathSound = "ambient/explosions/explode_9.wav"
	
	self.careForFriendlyFire = false
	
	self.slowThinkTimer = 1
	
	self.population = 2
	
	self.moveType = MOVETYPE_VPHYSICS
	self.canMove = true
	self.range = 80
	self.speed = 105
	self.damageDeal = 100
	self.maxHP = 10

	--print("Finished changing stats")
	
	Setup ( self )
	
	--print("Finished Initialize")
	
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r*1.3, self:GetColor().g*1.3, self:GetColor().b*1.3, 255))
end

function ENT:DeathEffect( ent )
	timer.Simple( 0.02, function()
		if (IsValid(ent)) then
			util.BlastDamage( ent, ent, ent:GetPos(), 80, ent.damageDeal )
			local effectdata = EffectData()
			effectdata:SetOrigin( ent:GetPos() )
			util.Effect( "Explosion", effectdata )
			
			local pos1 = ent:GetPos()// Set worldpos 1. Add to the hitpos the world normal.
			local pos2 = ent:GetPos()+Vector(0,0,-20) // Set worldpos 2. Subtract from the hitpos the world normal.
			ent.fired = true
			ent:Remove()
			
			util.Decal("Scorch",pos1,pos2)
		end
	end)
end

function ENT:SlowThink ( ent )
	if (ent.canMove) then
		DefaultThink ( ent )
		
		if (ent:GetVelocity():Length() < 15 and self.moving == false) then
			self.phys:Sleep()
		end
	else 
		local pos = ent:GetPos()
		if (ent.targetEntity == nil) then
			----------------------------------------------------------------------Buscar target
			local foundEnts = ents.FindInSphere(pos, ent.range )
			for k, v in RandomPairs( foundEnts ) do
				if (v.Base == "ent_melon_base") then
					if (v:GetNWInt("melonTeam", 0) ~= ent:GetNWInt("melonTeam", 0)) then
						ent.targetEntity = v
						ent:Shoot(ent)
					end
				end
			end
		end 
	end
end

function ENT:PostEntityPaste( ply, ent, createdEntities )
	self:SetPos(self:GetPos()+Vector(0,0,1.2))
end

function ENT:Welded (ent, trace)
	ent:SetModel("models/props_c17/clock01.mdl")
	ent:SetPos(ent:GetPos()+Vector(0,0,-5))
	ent:SetMaterial("models/debug/debugwhite")
	local color = ent:GetColor()
	ent:SetColor(Color(color.r*0.5, color.g*0.5, color.b*0.5, 100))
	ent.canMove = false
	ent:SetMoveType( MOVETYPE_NONE )
	ent:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
	ent.maxHP = 10
	ent.HP = 10
	ent.population = 1
	UpdatePopulation(-1, melonTeam)
	ent.range = 100
	ent.materialString = "Models/effects/vol_light001"
	for i = 1, 4 do
		timer.Simple( 1+i*0.05, function()
			if (IsValid(ent)) then
				ent:SetPos(ent:GetPos()+Vector(0,0,-0.3))
			end
		end	)
	end
	timer.Simple( 1.3, function()
		ent:SetMaterial("Models/effects/vol_light001")
		ent:DrawShadow( false )
		local effectdata = EffectData()
		effectdata:SetStart( ent:GetPos())
		util.Effect( "ImpactJeep", effectdata )
	end )
	local weld = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0, true , false )
end

function ENT:OnTakeDamage( damage )
	if (self.canMove) then
		if ((damage:GetAttacker():GetNWInt("melonTeam", 0) ~= self:GetNWInt("melonTeam", 0) or not damage:GetAttacker():GetVar('careForFriendlyFire')) and not damage:GetAttacker():IsPlayer()) then 
			if (damage:GetAttacker():GetNWInt("melonTeam", 0) == self:GetNWInt("melonTeam", 0)) then
				self.HP = self.HP - damage:GetDamage()/2
			else
				self.HP = self.HP - damage:GetDamage()
			end
			self:SetNWFloat( "health", self.HP )
			if (self.HP <= 0) then
				Die (self)
			end
		end
	else
		--Negate damage
	end
end

function ENT:Shoot ( ent )
	sound.Play("buttons/button8.wav", ent:GetPos())
	timer.Simple( 0.3, function()
		if (!IsValid(ent.targetEntity)) then
			ent.targetEntity = nil
			ent.nextSlowThink = CurTime()+0.1
			return false
		else
			if (tostring( ent.targetEntity ) ~= "[NULL Entity]") then
			--util.BlastDamage( ent, ent, ent:GetPos(), 100, ent.damageDeal )
			--local effectdata = EffectData()
			--effectdata:SetOrigin( ent:GetPos() )
			--util.Effect( "Explosion", effectdata )
			--ent:Remove()
				ent:SetPos(ent:GetPos()+Vector(0,0,3))
				Die ( ent )
			end
		end
	end )
end