AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")
	
	Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/props_phx/construct/metal_plate2x4.mdl"--"models/props_c17/TrapPropeller_Engine.mdl"
	self.moveType = MOVETYPE_VPHYSICS
	self.canMove = true
	self.canShoot = true
	self.speed = 200
	self.force = 100

	self:SetAngles(self:GetAngles()+Angle(90,0,0))

	local offset = Vector(0,0,42)
	self:SetPos(self:GetPos()+offset)

	self.closedpos = self:GetPos()
	self.openedpos = self:GetPos()+Vector(0,0,120)

	self.maxHP = 500

	self.open = false
	self:SetNWBool("open", self.open)
	self.process = 0

	self:SetNWInt("energy", 0)
	self:SetNWInt("maxenergy", 100)
	self:SetNWVector("energyPos", Vector(0,0,0))
	
	--print("Finished changing stats")
	
	self.damping = 4
	
	Setup ( self )

	self.connection = nil
	CalculateConnections(self)
	
	self:GetPhysicsObject():EnableMotion(false)
	--print("Finished Initialize")
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r/2+50, self:GetColor().g/2+50, self:GetColor().b/2+50, 255))
end

function ENT:SlowThink ( ent )
	--DefaultThink ( ent )
end

function ENT:Actuate ()
	--if (self.process <= 0) then
		self.process = 5-self.process
		self.open = !self.open
		self:SetNWBool("open", self.open)
	--end
end

function ENT:Update()
	local energy = math.Round(self:GetNWInt("energy", 0))
	local max = self:GetNWInt("maxenergy", 0)
	self:SetNWString("message", "Energy: "..energy.." / "..max)
	PullEnergy(self)
	if (self.process > 0) then
		if (energy >= 3) then
			local percent = self.process/5
			if (!self.open) then
				self:SetPos(self.openedpos*percent+self.closedpos*(1-percent))
			else
				self:SetPos(self.openedpos*(1-percent)+self.closedpos*(percent))
			end
			self.process = self.process - 0.2
			if (self.process < 0) then
				self.process = 0
			end
			self:SetNWInt("energy", energy-3)
		end
	end
end

function ENT:Shoot ( ent )
	--DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	DefaultDeathEffect ( ent )
end