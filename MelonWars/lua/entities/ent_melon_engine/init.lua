AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")
	
	Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/thrusters/jetpack.mdl"--"models/props_c17/TrapPropeller_Engine.mdl"
	self.moveType = MOVETYPE_VPHYSICS
	self.canMove = true
	self.canShoot = true
	self.speed = 200
	self.force = 100

	self:SetAngles(self:GetAngles()+Angle(90,180,0))

	local offset = Vector(0,-0.8,0)
	offset:Rotate(self:GetAngles())
	self:SetPos(self:GetPos()+offset)

	self.maxHP = 50
	
	--print("Finished changing stats")
	
	self.damping = 4
	
	Setup ( self )
	
	self:GetPhysicsObject():SetDamping( 1, 300)
	self:GetPhysicsObject():SetMass(150)
	--print("Finished Initialize")
end

function ENT:SlowThink ( ent )
	--DefaultThink ( ent )
end

function ENT:Welded( ent, parent )
	local weld = constraint.Weld( ent, parent, 0, 0, 0, true , false )

	--ent.canMove = false
	ent.materialString = "models/shiny"

	ent.parent = parent

	--Resta su poblacion para luego sumar la nueva
	UpdatePopulation(-ent.population, melonTeam)
	ent.population = math.ceil(ent.population/2)
	UpdatePopulation(ent.population, melonTeam)
end

function ENT:Update( ent )
	----[[
	if (cvars.Bool("mw_admin_playing") ) then

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
		ent:SetNWVector( "targetPos", ent.targetPos )
		--ent:SetNWEntity( "targetEntity", ent.targetEntity )
		ent:SetNWEntity( "followEntity", ent.followEntity )
		
		if (ent.canMove) then
			--[[
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
			]]
			local phys = ent:GetPhysicsObject()
			
			local const = constraint.FindConstraints( self, "Weld" )
			if (table.Count(const) == 0) then
				self.damage = 5
			end
			
			if (IsValid(phys)) then
				---------------------------------------------------------------------------Movimiento
				if (ent.moving and ent:GetVelocity():Length()<ent.speed) then
					local moveVector = (ent.targetPos-ent:GetPos()):GetNormalized()*self.force
					force = Vector(moveVector.x, moveVector.y, 0)
					phys:ApplyForceCenter (force*phys:GetMass())
				end
			end
			
			--if (ent.targetPos:Distance(ent:GetPos()) < 30) then
			--	ent.moving = false
			--end
			
			if (Vector(ent:GetPos().x, ent:GetPos().y, 0):Distance(Vector(ent.targetPos.x, ent.targetPos.y, 0)) < 100) then
				ent:FinishMovement()
			end

			ent:SetNWBool("moving", ent.moving)
			ent:NextThink(CurTime() + 0.01)
			return true
		end
	end
	--]]--
end

function ENT:PhysicsUpdate()
	local mul = 150
	local phys = self:GetPhysicsObject()
	local forcePoint = self:GetPos()+self:GetAngles():Forward()*mul
	local forceTarget = self:GetPos()+Vector(0,0,-mul)
	phys:ApplyForceOffset( (forceTarget-forcePoint)*mul, forcePoint )
	forcePoint = self:GetPos()+self:GetAngles():Forward()*-mul
	forceTarget = self:GetPos()+Vector(0,0,mul)
	phys:ApplyForceOffset( (forceTarget-forcePoint)*mul, forcePoint )
	--phys:ApplyForceCenter( Vector(0,0,(forceTarget-forcePoint):Length()*20))

	local moveVector = (self.targetPos-self:GetPos())
	if (self.moving and moveVector:LengthSqr() > 50) then
		moveVector = moveVector:GetNormalized()
		local mul = 180
		local phys = self:GetPhysicsObject()
		local forcePoint = self:GetPos()+self:GetAngles():Up()*mul
		local forceTarget = self:GetPos()+Vector(moveVector.x,moveVector.y,0)*mul
		phys:ApplyForceOffset( (forceTarget-forcePoint)*-mul, forcePoint )
		forcePoint = self:GetPos()+self:GetAngles():Up()*-mul
		forceTarget = self:GetPos()+Vector(moveVector.x,moveVector.y,0)*-mul
		phys:ApplyForceOffset( (forceTarget-forcePoint)*-mul, forcePoint )
	end
end

function ENT:Shoot ( ent )
	--DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	DefaultDeathEffect ( ent )
end