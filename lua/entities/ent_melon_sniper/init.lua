AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")

	MW_Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/props_junk/propane_tank001a.mdl"
	self.moveType = MOVETYPE_VPHYSICS
	self.canMove = true
	
	self.maxHP = 20
	self.speed = 60
	self.range = 500
	self.spread = 0.5
	self.damageDeal = 30

	self.buildingDamageMultiplier = 0.7
	
	self.shotOffset = Vector(0,0,10)

	self.angularDamping = 10
	
	//self:SetPos(self:GetPos()+Vector(0,0,12))
	
	self.nextShot = CurTime()+3
	
	--print("Finished changing stats")
	
	self.population = 3
	
	MW_Setup ( self )
	
	--print("Finished Initialize")
	construct.SetPhysProp( self:GetOwner() , self, 0, nil,  { GravityToggle = true, Material = "ice" } )
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r/1.5, self:GetColor().g/1.5, self:GetColor().b/1.5, 255))
end

function ENT:SlowThink ( ent )
	--local vel = ent.phys:GetVelocity()
	--ent.phys:SetAngles( ent.Angles )
	--ent.phys:SetVelocity(vel)
	MW_UnitDefaultThink ( ent )

end

function ENT:PhysicsUpdate()

	local inclination = self:Align(self:GetAngles():Up(), Vector(0,0,1), 1000)
	self.phys:ApplyForceCenter( Vector(0,0,inclination*100))

	self:DefaultPhysicsUpdate()
end

function ENT:Shoot ( ent )
	if (ent:GetVelocity():Length() < 15 && ent.nextShot < CurTime()) then
		MW_DefaultShoot ( ent )
		for k, v in pairs( player.GetAll() ) do
			sound.Play("physics/metal/metal_computer_impact_bullet1.wav", v:GetPos(), 40, 90, 1)
			sound.Play("weapons/357/357_fire2.wav", v:GetPos(), 40, 80, 1)
		end
		
		sound.Play("physics/metal/metal_computer_impact_bullet1.wav", ent:GetPos(), 100, 90, 1)
		sound.Play("weapons/357/357_fire2.wav", ent:GetPos(), 100, 80, 1)

		ent.nextShot = CurTime()+6
	end
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end