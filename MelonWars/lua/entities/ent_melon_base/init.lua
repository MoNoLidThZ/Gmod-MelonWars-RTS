AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include("shared.lua")

function Defaults( ent )
	--print("Defaults")
	--ent:NextThink(CurTime() + 0.1)
	ent.maxHP = 20
	ent.HP = 1
	ent:SetNWFloat( "health", 1 )
	ent.speed = 100
	ent.range = 250
	ent.spread = 5
	ent.damageDeal = 4
	ent.canMove = true
	ent.canBeSelected = true
	ent.careForFriendlyFire = true
	ent.careForWalls = true
	ent.targetPos = ent:GetPos()
	local z = Vector(0,0,0)
	ent.rallyPoints = {z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z}

	ent.minRange = 0
	
	ent.population = 1

	ent.chasing = false
	
	ent.value = 0
	
	ent.damage = 0
	
	ent.fired = false
	ent.gotHit = false
	
	ent.changeAngles = true
	ent.changeModel = true

	ent.spawned = false
	
	ent.shotOffset = Vector(0,0,0)
	ent.modelString = "models/props_junk/watermelon01.mdl"
	ent.materialString = "models/debug/debugwhite"
	
	ent.deathSound = "phx/eggcrack.wav"
	ent.shotSound = "weapons/alyx_gun/alyx_gun_fire6.wav"
	
	ent.tracer = "AR2Tracer"
	ent.onFire = false
	
	ent.deathEffect = "cball_explode"
	
	ent:SetNWInt("melonTeam", 0)
	ent.melonTeam = 0
	ent.canShoot = true
	
	ent.slowThinkTimer = 2

	ent.lastPosition = Vector(0,0,0)
	ent.stuck = 0
	
	ent.Angles = Angle(0,0,0)
		--print("Finished Defaults")
	ent:SetMaterial( "Models/effects/comball_sphere" )
	
	ent:SetColor( melonTeam )

	ent.damping = 1.5

	--ent.parent = ent
	
	ent.nextSlowThink = 0

	--Bot variables-
	ent.defensiveStance = false
	ent.speedCap = 1000

	ent.barrier = nil
	----------------
end

function ENT:Ini( teamnumber )
	self:SetNWInt("melonTeam", teamnumber)
	self:MelonSetColor( teamnumber )
	self.nextSlowThink = CurTime()+1
	UpdatePopulation(self.population, teamnumber)
end

function ENT:MelonSetColor( teamnumber )
	local unit_colors  = {Color(255,50,50,255),Color(50,50,255,255),Color(255,200,50,255),Color(30,200,30,255),Color(100,0,80,255),Color(100,255,255,255),Color(255,120,0,255),Color(255,100,150,255)}
	local newColor
	if (teamnumber == 0) then
		newColor = Color(50,50,50,255)
	else
		newColor = unit_colors[teamnumber]
	end
	self:SetColor(newColor)
	self:ModifyColor()
end

function ENT:ModifyColor()
end

function Setup( ent )
	--print("Setup")
	ent.targetEntity = nil
	ent.followEntity = nil
	ent.forcedTargetEntity = nil
	ent:SetNWEntity( "targetEntity", ent.targetEntity )
	ent:SetNWEntity( "followEntity", ent.followEntity )
	ent:SetNWBool("moving", false)
	
	ent.moving = false
	ent.damage = 0

	if (ent.changeModel) then
		ent:SetModel( ent.modelString )
	end
	ent:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	ent:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	
	if (ent.moveType == 0) then
		local weld = constraint.Weld( ent, game.GetWorld(), 0, 0, 0, true , false )
		canMove = false
		ent:GetPhysicsObject():EnableMotion(false)
	end
	
	ent.phys = ent:GetPhysicsObject()
	if (IsValid(ent.phys)) then
		ent.phys:Wake()
		ent.phys:SetDamping(ent.damping,ent.damping)
	end
	
	if (ent.changeAngles) then
		ent:SetAngles( ent:GetAngles()+ent.Angles )
	end
	
	--MsgN("Class: " .. ent:GetClass())
	
	--VVV Asi se puede modificar el tono del color VVV
	--self:SetColor(Color(self:GetColor().r/2, self:GetColor().g/2, self:GetColor().b/2, 255))
	
	--print("Finished Setup")
	--UpdatePopulation(ent.population, melonTeam)
	
	--ent:SetNWVector( "targetPos", ent.targetPos )
	ent:SetNWEntity( "targetEntity", ent.targetEntity )

	if (cvars.Number("mw_admin_spawn_time") == 1 and ent.spawnTime ~= nil) then
		timer.Simple( ent.spawnTime-CurTime(), function()
			if (IsValid(ent)) then	
				Spawn(ent)
			end
		end)
	else
		Spawn(ent)
	end
end

function Spawn(ent)
	if (SERVER) then
		
		ent:SetMoveType( ent.moveType )   -- after all, gmod is a physics
		
		ent:SetMaterial(ent.materialString)
		--print("Angles: "..tostring(ent.Angles))
		ent.spawned = true

		ent.HP = ent.maxHP
		--print("modelString: "..ent.modelString)
		ent:SetNWFloat( "maxhealth", ent.maxHP )
		ent:SetNWFloat( "health", ent.HP )
	end
end

function ENT:Welded( ent, parent )
	--script a ejecutar si se spawnea weldeada
	local weld = constraint.Weld( ent, parent, 0, 0, 0, true , false )
	ent.canMove = false
	ent.materialString = "models/shiny"

	ent.parent = parent

	--Resta su poblacion para luego sumar la nueva
	UpdatePopulation(-ent.population, melonTeam)
	ent.population = math.ceil(ent.population/2)
	UpdatePopulation(ent.population, melonTeam)
end

function ENT:Think()
	if (!self.phys:IsAsleep()) then
		if (self.canMove and self:GetVelocity():Length() < 2 and self.moving == false) then
			--ent.phys:SetAngles( ent.Angles )
			local tr = util.QuickTrace( self:GetPos(), self:GetPos()+Vector(0,0,-3), self )
			if (tr.Entity ~= nil) then
				self.phys:Sleep()
			end
		end
	end
	if (self.spawned) then
		self:Update(self)
	end
	--[[if (!self.canMove and self.parent ~= self and !IsValid(self.parent) and tostring(self.parent) ~= "Entity [0][worldspawn]") then
				self.damage = 5
			end]]
	if (!self.canMove and self:GetClass() != "ent_melon_unit_transport") then
		local const = constraint.FindConstraints( self, "Weld" )
		table.Add(const, constraint.FindConstraints( self, "Axis" ))
		if (table.Count(const) == 0) then
			self.damage = 5
		end
	end
end

function ENT:Update( ent )
	----[[
	if (cvars.Bool("mw_admin_playing") ) then
		if (CurTime() > ent.nextSlowThink) then
			ent.nextSlowThink = CurTime()+ent.slowThinkTimer
			ent:SlowThink( ent )
		end

		--Aplicar daño
		if (ent.damage > 0) then
			ent.HP = ent.HP-ent.damage
			ent:SetNWFloat( "health", ent.HP )
			ent.damage = 0
			if (ent.HP <= 0) then
				Die( ent )
			end
		end
		
		--if (ent.targetEntity == ent) then
		--	ent.targetEntity = nil
		--end
		--if (ent.followEntity == ent) then
		--	ent.followEntity = nil
		--end
		--ent:SetNWVector( "targetPos", ent.targetPos )
		ent:SetNWEntity( "targetEntity", ent.targetEntity )
		ent:SetNWEntity( "followEntity", ent.followEntity )
		
		if (ent.canMove) then
			if (ent.followEntity ~= ent) then
				if (IsValid(ent.followEntity)) then
					if (ent.followEntity:GetPos():Distance(ent:GetPos()) > ent.range) then
						ent.targetPos = ent.followEntity:GetPos()+(ent:GetPos()-ent.followEntity:GetPos()):GetNormalized()*ent.range*0.5
						ent.moving = true
					end
				end
			else
				if (ent.chasing) then
					if (IsValid(ent.targetEntity)) then
						if (ent.targetEntity:GetPos():Distance(ent:GetPos()) > ent.range) then
							ent.targetPos = ent.targetEntity:GetPos()+(ent:GetPos()-ent.targetEntity:GetPos()):GetNormalized()*ent.range*0.9
							ent.moving = true
						end
					end
				end
			end
			
			local phys = ent:GetPhysicsObject()
			
			if (IsValid(phys)) then
				---------------------------------------------------------------------------Movimiento
				if (ent.moving and ent:GetVelocity():Length()<ent.speed) then
					if (ent.defensiveStance == false or ent.targetEntity == nil) then
						local moveVector = (ent.targetPos-ent:GetPos()):GetNormalized()*ent.speed
						force = Vector(moveVector.x, moveVector.y, 0)
						phys:ApplyForceCenter (force*phys:GetMass())
					end
				end

				if (ent.moving) then
					if (ent.lastPosition:Distance(ent:GetPos()) < ent.speed/2) then
						ent.stuck = ent.stuck+1
					else
						ent.lastPosition = ent:GetPos()
						ent.stuck = 0
					end

					if (ent.stuck%8 == 7) then
						if (ent.stuck > 40) then
							if (!ent.defensiveStance) then
								ent.targetEntity = nil
								ent:FinishMovement()
								ent.stuck = 0
							end
						else
							if (!ent.defensiveStance || (ent.defensiveStance && !IsValid(ent.targetEntity))) then
								ent:Unstuck()
							end
						end
					end
				end
			end

			if (ent.targetPos:Distance(ent:GetPos()) < 50) then
				ent:FinishMovement()
			end

			ent:SetNWBool("moving", ent.moving)
			ent:NextThink(CurTime() + 0.1)
			return true
		end
	end
	--]]--
end

function ENT:Unstuck()
	local phys = self:GetPhysicsObject()
	phys:ApplyForceCenter (Vector(0,0,self.speed*2.5)*phys:GetMass())
end

function ENT:FinishMovement ()
	if (self.rallyPoints[1] == Vector(0,0,0)) then
		self.moving = false
	else
		self.targetPos = self.rallyPoints[1]
		self:SetNWVector("targetPos", self.rallyPoints[1])
		self.moving = true
		for i=1, 30 do
			self.rallyPoints[i] = self.rallyPoints[i+1]
		end
		self.rallyPoints[30] = Vector(0,0,0)
	end
end

function ENT:RemoveRallyPoints ()
	for i=1, 30 do
		self.rallyPoints[i] = Vector(0,0,0)
	end
end

function ENT:SameTeam(ent)
	if (self:GetNWInt("melonTeam", -1)*ent:GetNWInt("melonTeam",-2) == 0) then
		return false
	end
	return teamgrid[self:GetNWInt("melonTeam", -1)][ent:GetNWInt("melonTeam", -2)];
end

function DefaultThink( ent )
	if (!util.IsInWorld( ent:GetPos() )) then ent:Remove() end
	if (ent.canShoot) then
		local pos = ent:GetPos()
		if (ent.targetEntity == nil or ent.targetEntity.Base == "ent_melon_prop_base" or ent.targetEntity:GetNWInt("propHP",-1) ~= -1) then
			----------------------------------------------------------------------Buscar target
			local foundEnts = ents.FindInSphere(pos, ent.range )
			for k, v in RandomPairs( foundEnts ) do
				--local isConstr = melonTeam
				--if (v:GetClass() == "prop_physics") then
				--	isConstr = v:GetVar('melonTeam')
				--end
				--print(isConstr)
				if (v.Base == "ent_melon_base") then --si es una sandía
					if (v:GetNWInt("melonTeam", 0) ~= ent:GetNWInt("melonTeam", 0)) then -- si tienen distinto equipo
						if (!ent:SameTeam(v)) then -- si no es un aliado
							local tr = util.TraceLine( {
							start = pos,
							endpos = v:GetPos()+v:GetVar("shotOffset",Vector(0,0,0)),
							filter = function( foundEnt )
								if ( foundEnt:GetClass() == "prop_physics") then--si hay un prop en el medio
									return true
								end
								if (ent.careForFriendlyFire) then --No dispara si hay un compañero en el camino
									if ( foundEnt.Base == "ent_melon_base" ) then
										if (foundEnt:GetNWInt("melonTeam", -1) == ent:GetNWInt("melonTeam", 0) and foundEnt ~= ent) then
											return true
										end
									end
								end
							end
							})
							if (tostring(tr.Entity) == '[NULL Entity]') then
							----------------------------------------------------------Encontró target
								ent.targetEntity = v
							end
						end
					end
				end
			end
			-------------------------------------------------Si aun asi no encontró target
			if (ent.targetEntity == nil) then
				for k, v in RandomPairs( foundEnts ) do
					--if (v.Base == "ent_melon_prop_base" or v:GetClass() == "prop_physics") then
						if (v:GetNWInt("melonTeam", ent:GetNWInt("melonTeam", 0)) ~= ent:GetNWInt("melonTeam", 0) and !string.StartWith( v:GetClass(), "ent_melonbullet_" ) and !ent:SameTeam(v)) then --si es de otro equipo
							if (ent.defensiveStance) then
								if (v:GetClass() == "ent_melon_wall") then
									if (ent.stuck > 15) then
										if (IsValid(ent.barrier)) then
											ent.targetEntity = ent.barrier
										else
											ent.targetEntity = v
										end
									end
								else
									ent.targetEntity = v
								end
							else
								ent.targetEntity = v
							end
							--print(v:GetClass())
						end
					--end
				end
			end
		end 

		if (ent.targetEntity ~= nil) then
			----------------------------------------------------------------------Perder target
			----------------------------------------por que no existe
			if (!IsValid(ent.targetEntity)) then
				ent.targetEntity = nil
				ent:SetNWEntity("targetEntity", nil)
				ent.nextSlowThink = CurTime()+0.5
				ent.stuck = 0
				return false
			----------------------------------------por que esta en el 0,0,0
			elseif (ent.targetEntity:GetPos() == Vector(0,0,0)) then
				ent.targetEntity = nil
				ent:SetNWEntity("targetEntity", nil)
				ent.nextSlowThink = CurTime()+0.5
				return false
			end
			----------------------------------------por que es el mismo
			if (ent.targetEntity == ent or ent.forcedTargetEntity == ent) then
				ent.targetEntity = nil
				ent:SetNWEntity("targetEntity", nil)
				ent.forcedTargetEntity = nil
				ent.nextSlowThink = CurTime()+0.5
				return false
			end
			----------------------------------------por que es un aliado
			if (ent:SameTeam(ent.targetEntity) or ent:SameTeam(ent.targetEntity)) then
				ent.targetEntity = nil
				ent:SetNWEntity("targetEntity", nil)
				ent.forcedTargetEntity = nil
				ent.nextSlowThink = CurTime()+0.5
				return false
			end
			----------------------------------------por que está lejos (o muy cerca)
			local targetDist = ent.targetEntity:GetPos():Distance(pos)
			if (IsValid(ent.targetEntity) and (targetDist > ent.range or targetDist < ent.minRange)) then
				--print("loosing target")
				ent.targetEntity = nil
				ent:SetNWEntity("targetEntity", nil)
				ent.forcedTargetEntity = nil
				ent.nextSlowThink = CurTime()+0.5
				return false
			end
			
			----------------------------------------------objetivo forzado
			if (IsValid(ent.forcedTargetEntity)) then
				ent.targetEntity = ent.forcedTargetEntity
			else
				ent.forcedTargetEntity = nil
			end
			
			local tr = util.TraceLine( {
				start = pos,
				endpos = ent.targetEntity:GetPos()+ent.targetEntity:GetVar("shotOffset", Vector(0,0,0)),
				--filter = function( foundEntity ) if (( (foundEntity:GetClass() == "ent_melon_wall" and foundEntity:GetNWInt("melonTeam", 0) == ent:GetNWInt("melonTeam", 1)) or (foundEntity:GetClass() == "prop_physics" and foundEntity:GetNWInt("melonTeam", 0) == ent:GetNWInt("melonTeam", 1)) ) and foundEntity ~= ent.targetEntity ) then return true end end
				filter = function( foundEntity ) if (foundEntity.Base ~= "ent_melon_base" and foundEntity:GetNWInt("melonTeam", 0) == ent:GetNWInt("melonTeam", 1) or foundEntity:GetClass() == "prop_physics" and foundEntity ~= ent.targetEntity) then return true end end
				})
			----------------------------------------por que hay algo en el medio

			if (ent.careForWalls) then
				--print(ent)
				if (tostring(tr.Entity) ~= '[NULL Entity]') then
					ent.targetEntity = nil
					ent:SetNWEntity("targetEntity", nil)
					ent.nextSlowThink = CurTime()+0.5
					return false
				end
			end
			
			if (tostring(tr.Entity) == "Entity [0][worldspawn]") then
				ent.targetEntity = nil
				ent:SetNWEntity("targetEntity", nil)
				ent.nextSlowThink = CurTime()+0.5
				return false
			end
		end
		
		if (ent.targetEntity ~= nil) then
			local distance = ent.targetEntity:GetPos():Distance(ent:GetPos())
			if (distance < ent.range and distance > ent.minRange) then
				if (ent.targetEntity:GetNWInt("melonTeam", 0) ~= ent:GetNWInt("melonTeam", 0)) then
					ent:Shoot( ent )
				end
			end
		end
	end
end

function ENT:PhysicsCollide( colData, physObject )
	if (IsValid(colData.HitEntity)) then
		local other = colData.HitEntity
		if ((other:GetVar('targetPos') == self.targetPos and other:GetVar('moving', false) == false) or self.rallyPoints[1] == other:GetVar('targetPos')) then
			self:FinishMovement()
		end
		if (other:GetClass() == "ent_melon_wall") then
			self.barrier = other
		end
	end
end

function DefaultShoot( ent )
	local pos = ent:GetPos()+ent.shotOffset
	--------------------------------------------------------Disparar
	if (IsValid(ent.targetEntity)) then
		local targetPos = ent.targetEntity:GetPos()+ent.targetEntity:OBBCenter()
		if (ent.targetEntity:GetVar("shotOffset") ~= nil) then
			if (ent.targetEntity:GetVar("shotOffset") ~= Vector(0,0,0)) then
				targetPos = ent.targetEntity:GetPos()+ent.targetEntity:GetVar("shotOffset")
			end
		end
		local bullet = {}
		bullet.Num=1
		bullet.Src=pos
		bullet.Dir=targetPos-pos
		bullet.Spread=Vector(ent.spread,ent.spread,0)
		bullet.Tracer=1	
		bullet.TracerName=ent.tracer
		bullet.Force=2
		---------------------------------------------------------------------Esto va hacer que se aplique el daño le pegue o no
		--[[if (ent.targetEntity.Base == "ent_melon_prop_base") then
			ent.targetEntity:SetNWFloat( "health", ent.targetEntity:GetNWFloat( "health", 1)-ent.damageDeal)
			if (ent.targetEntity:GetNWFloat( "health", 1) <= 0) then
				ent.targetEntity:PropDefaultDeathEffect( ent.targetEntity )
			end
			bullet.Damage=0
		else
			--if (ent.targetEntity:GetClass() == "prop_physics") then --Si es un prop legalizado
			
			bullet.Damage=ent.damageDeal
		end]]
		
		bullet.Damage=ent.damageDeal
		bullet.Distance=ent.range*1.1
		ent.fired = true
		ent:FireBullets(bullet)
		local effectdata = EffectData()
		effectdata:SetScale(1)
		effectdata:SetAngles( (targetPos-pos):Angle()) 
		effectdata:SetOrigin( pos + (targetPos-pos):GetNormalized()*10 )
		util.Effect( "MuzzleEffect", effectdata )
		sound.Play( ent.shotSound, pos )
	end
end

function DefaultDeathEffect( ent )
	local effectdata = EffectData()
	effectdata:SetOrigin( ent:GetPos() )
	util.Effect( ent.deathEffect, effectdata )
	sound.Play( ent.deathSound, ent:GetPos() )
	ent:Remove()
end

function Die( ent )
	if (IsValid(ent)) then
		ent:DeathEffect ( ent )
	end
end

function ENT:PropDefaultDeathEffect( ent )
	local effectdata = EffectData()
	effectdata:SetOrigin( ent:GetPos() )
	util.Effect( ent.deathEffect, effectdata )
	sound.Play( ent.deathSound, ent:GetPos() )
	ent:Remove()
end

function ENT:OnTakeDamage( damage )
	
	if ((damage:GetAttacker():GetNWInt("melonTeam", 0) ~= self:GetNWInt("melonTeam", 0) or not damage:GetAttacker():GetVar('careForFriendlyFire')) and not damage:GetAttacker():IsPlayer()) then 
		if (damage:GetAttacker():GetNWInt("melonTeam", 0) == self:GetNWInt("melonTeam", 0)) then
			self.HP = self.HP - damage:GetDamage()/2
			self.gotHit = true
		else
			self.HP = self.HP - damage:GetDamage()
			self.gotHit = true
		end
		self:SetNWFloat( "health", self.HP )
		if (self.HP <= 0) then
			Die (self)
		end
	end
end

function ENT:OnRemove()
	if (SERVER) then
		if (IsValid(self)) then
			UpdatePopulation(-self.population, self:GetNWInt("melonTeam", 0))
			if (!self.gotHit and CurTime()-self:GetCreationTime() < 30 and !self.fired) then
				if (teamCredits[self:GetNWInt("melonTeam", 0)] != nil) then
					teamCredits[self:GetNWInt("melonTeam", 0)] = teamCredits[self:GetNWInt("melonTeam", 0)]+self.value
				end
				for k, v in pairs( player.GetAll() ) do
					if (v:GetInfo("mw_team") == tostring(self:GetNWInt("melonTeam", 0))) then
						if (self:GetNWInt("melonTeam", 0) != 0) then
							net.Start("TeamCredits")
								net.WriteInt(teamCredits[self:GetNWInt("melonTeam", 0)] ,16)
							net.Send(v)
							v:PrintMessage( HUD_PRINTTALK, "///// "..self.value.." Water Refunded" )
						end
					end
				end
			end
		end
	end
end

function UpdatePopulation (ammount, teamID)
	--if (SERVER) then
	if (ammount != 0 && teamID != 0 && teamID != nil) then
		teamUnits[teamID] = teamUnits[teamID]+ammount
		local ownerPlayers = {}
		ownerPlayers = player.GetAll()
		local i = 0	--Parche horrible: cada vez que elimina a alguien de la lista, al remover a alguien mas busca un lugar antes, ya que la lista se acomodó para rellenar el espacio vacio
		for k, v in pairs( player.GetAll() ) do
			if (v:GetInfoNum("mw_team", 0) ~= teamID) then
				table.remove(ownerPlayers, k-i)
				i = i+1
			end
		end
		net.Start("TeamUnits")
			net.WriteInt(teamUnits[teamID] ,16)
		net.Send(ownerPlayers)
	end
	--end
end

function ENT:BarrackInitialize ()
	self.moveType = MOVETYPE_NONE
	
	self.canMove = false
	self.canShoot = false
	
	self:SetNWBool("active", true)
	self.unitspawned = true
	self:SetNWInt("count", 0)

	self:SetNWFloat("overdrive", 0)
	
	self:SetNWBool("spawned", self.unitspawned)
	self.slowThinkTimer = 3

	self:SetVar('targetPos', self:GetPos()+Vector(150,0,0))
	self:SetNWVector('targetPos', self:GetPos()+Vector(150,0,0))
	
	self.deathSound = "ambient/explosions/explode_9.wav"
	self.deathEffect = "Explosion"

	self.melons = {}

	self.population = 5

	if (self.unit != nil) then
		self.slowThinkTimer = units[self.unit].spawn_time*3
		self.unit_class = units[self.unit].class
		self.unit_cost = units[self.unit].cost
	end	

	self:SetNWFloat("slowThinkTimer", self.slowThinkTimer)
	self:SetNWFloat("nextSlowThink", CurTime())
end

function ENT:BarrackSlowThink()
	local ent = self

	if (self.spawned) then
		if (!self.unitspawned) then
			if (self:GetNWFloat("nextSlowThink") < CurTime()+self:GetNWFloat("overdrive", 0)) then
				if (teamUnits[ent:GetNWInt("melonTeam", 0)] < cvars.Number("mw_admin_max_units")) then
					self:SetNWFloat("overdrive", 0)
					local newMarine = ents.Create( self.unit_class )
					if ( !IsValid( newMarine ) ) then return end -- Check whether we successfully made an entity, if not - bail
					newMarine:SetPos( ent:GetPos() + Vector(0,0,20) + ent.shotOffset)
					
					sound.Play( "ambient/misc/hammer1.wav", ent:GetPos(), 75, 100, 1 )
					
					melonTeam = ent:GetNWInt("melonTeam", 0)
					
					newMarine:Spawn()
					newMarine:SetNWInt("melonTeam", ent:GetNWInt("melonTeam", 0))
					newMarine:Ini(ent:GetNWInt("melonTeam", 0))

					if (cvars.Bool("mw_admin_credit_cost")) then
						newMarine.value = self.unit_cost
					else
						newMarine.value = 0
					end

					if (ent.targetPos == ent:GetPos()) then
						newMarine:SetVar('targetPos', ent:GetPos()+Vector(100,0,0))
						newMarine:SetNWVector('targetPos', ent:GetPos()+Vector(100,0,0))
					else
						newMarine:SetVar('targetPos', ent.targetPos+Vector(0,0,1))
						newMarine:SetNWVector('targetPos', ent.targetPos+Vector(0,0,1))
					end
					newMarine:SetVar('moving', true)
				
					table.insert(ent.melons, newMarine)
					undo.Create("Melon Marine")
					 undo.AddEntity( newMarine )
					 undo.SetPlayer( ent:GetOwner())
					undo.Finish()

					if (self:GetNWBool("active", false)) then
						self.nextSlowThink = CurTime()+self.slowThinkTimer
						self:SetNWFloat("nextSlowThink", self.nextSlowThink)
					end
					self.unitspawned = true
					self:SetNWBool("spawned", self.unitspawned)
				end
			end
		end

		self:SetNWInt("count", 0)
		for k, v in pairs( ent.melons ) do
			if (IsValid(v)) then
				self:SetNWInt("count", self:GetNWInt("count", 0)+1)
			else
				table.remove(ent.melons, k)
			end
		end

		if (self:GetNWBool("active", false)) then
			if (self.unitspawned) then
				if (self:GetNWInt("count", 0) < self:GetNWInt("maxunits", 0) and teamUnits[ent:GetNWInt("melonTeam", 0)] < cvars.Number("mw_admin_max_units")) then
					if (teamCredits[ent:GetNWInt("melonTeam", 0)] >= self.unit_cost or not cvars.Bool("mw_admin_credit_cost")) then
						-- Start Production
						--self:SetNWBool("spawned", false)
						------

						if (cvars.Bool("mw_admin_credit_cost")) then
							teamCredits[self:GetNWInt("melonTeam", 0)] = teamCredits[self:GetNWInt("melonTeam", 0)]-self.unit_cost
							for k, v in pairs( player.GetAll() ) do
								if (v:GetInfo("mw_team") == tostring(self:GetNWInt("melonTeam", 0))) then
									net.Start("TeamCredits")
										net.WriteInt(teamCredits[self:GetNWInt("melonTeam", 0)] ,16)
									net.Send(v)
								end
							end
						end

						self.nextSlowThink = CurTime()+self.slowThinkTimer
						self:SetNWFloat("nextSlowThink", self.nextSlowThink)
						self.unitspawned = false
						self:SetNWBool("spawned", self.unitspawned)
					end
				else
					self.unitspawned = true
					self:SetNWBool("spawned", self.unitspawned)
				end
			end
		--else
		--	self.nextSlowThink = CurTime()+1
		--	self:SetNWFloat("nextSlowThink", self.nextSlowThink)
		--	self.unitspawned = false
		--	self:SetNWBool("spawned", self.unitspawned)
		end
	end
end