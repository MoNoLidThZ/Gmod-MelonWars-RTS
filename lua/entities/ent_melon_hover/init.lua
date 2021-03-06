AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")
	
	MW_Defaults ( self )

	--print("Changing stats")
	self.birth = CurTime()

	self.modelString = "models/props_c17/pulleywheels_small01.mdl"
	self.moveType = MOVETYPE_VPHYSICS
	self.canMove = true
	//self:SetAngles(self:GetAngles()+Angle(90,0,0))
	
	self.population = 1

	//self.sphereRadius = 5
	
	self:SetNWBool("done",false)
	
	self.delayedForce = 0
	
	self.damping = 1
	
	self.maxHP = 50
	--print("Finished changing stats")
	
	MW_Setup ( self )
	
	--print("Finished Initialize")
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r/2, self:GetColor().g/2, self:GetColor().b/2, 255))
end

function ENT:SlowThink ( ent )
	
end

function ENT:Shoot ( ent )
	--MW_DefaultShoot ( ent )
end

function ENT:Update (ent)

end

function ENT:Think ()
	if (self.damage > 0) then
		self.HP = self.HP-self.damage
		self:SetNWFloat( "health", self.HP )
		self.damage = 0
		if (self.HP <= 0) then
			MW_Die( self )
		end
	end
		
	local const = constraint.FindConstraints( self, "Weld" )
	if (table.Count(const) == 0) then
		self.damage = 5
	end
end

function ENT:PropellerReady ()
	self:SetNWBool("done",true)
	local foundEnts = ents.FindInSphere(self:GetPos(), 600 )
	for k, v in pairs( foundEnts ) do
		if (v:GetClass() == "ent_melon_hover") then
			v:SetNWBool("done",true)
		end
	end
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end

function ENT:PhysicsUpdate()
	
	--if (self.moving == true) then
	if (self:GetNWBool("done",false) == true) then
		local hoverdistance = 40
		local hoverforce = 200
		local force = 0
		local phys = self:GetPhysicsObject()
		local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos()+Vector(0,0,-hoverdistance*2),
		filter = function( ent ) if ( not ent:GetPhysicsObject():IsMoveable() ) then return true end end,
		mask = MASK_WATER+MASK_SOLID
		} )
		
		local distance = self:GetPos():Distance(tr.HitPos)
		
		if (distance < hoverdistance) then
			force = -(distance-hoverdistance)*hoverforce
			phys:ApplyForceCenter(Vector(0,0,-phys:GetVelocity().z*8))
		else
			force = 0
		end
		
		if (force > self.delayedForce) then
			self.delayedForce = (self.delayedForce*2+force)/3
		else
			self.delayedForce = self.delayedForce*0.5
		end
		phys:ApplyForceCenter(Vector(0,0,self.delayedForce))
		if (IsValid(tr.Entity)) then
			local p = tr.Entity:GetPhysicsObject()
			if (p ~= nil) then
				p:ApplyForceOffset(Vector(0,0,-self.delayedForce), tr.HitPos)
			end
		end
		--[[local mul = 10
		local forcePoint = self:GetPos()+self:GetAngles():Up()*mul
		local forceTarget = self:GetPos()+Vector(0,0,mul)
		phys:ApplyForceOffset( (forceTarget-forcePoint)*mul, forcePoint )
		forcePoint = self:GetPos()+self:GetAngles():Up()*-mul
		forceTarget = self:GetPos()+Vector(0,0,-mul)
		phys:ApplyForceOffset( (forceTarget-forcePoint)*mul, forcePoint )]]
		--end

		self:Align(self:GetAngles():Forward(), Vector(0,0,-1), 10000)
		self:StopAngularVelocity(0.3)
	end
end