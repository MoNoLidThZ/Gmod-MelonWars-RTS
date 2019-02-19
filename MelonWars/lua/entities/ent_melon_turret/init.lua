AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")

	Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/combine_turrets/ground_turret.mdl"
	self.speed = 80
	self.spread = 10
	self.damageDeal = 3
	self.maxHP = 40
	self.range = 550
	self.Angles = Angle(180,180,0)	
	self.shotSound = "weapons/ar1/ar1_dist2.wav"
	self.tracer = "AR2Tracer"
	
	self.shotOffset = Vector(0,0,15)
	
	self.canMove = false
	self.canBeSelected = false
	self.moveType = MOVETYPE_NONE
	
	self.slowThinkTimer = 1
	--print("Finished changing stats")
	
	Setup ( self )
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:GetPhysicsObject():EnableMotion(false)
	
	--print("Finished Initialize")
end

function ENT:SlowThink ( ent )
	DefaultThink ( ent )
end

function ENT:Shoot ( ent )
	Shoot ( ent )
	for i = 1, 3 do
		timer.Simple( i/8, function()
			if (IsValid(ent)) then
				Shoot ( ent )
			end
		end)
	end
end

function Shoot( ent )
	local pos = ent:GetPos()+ent.shotOffset
	--------------------------------------------------------Disparar
	if (IsValid(ent.targetEntity)) then
	
		local targetPos = ent.targetEntity:GetPos()
		if (ent.targetEntity:GetVar("shotOffset") ~= nil) then
			targetPos = targetPos-ent.targetEntity:GetVar("shotOffset")
		end
		local bullet = {}
		bullet.Num=1
		bullet.Src=pos
		bullet.Dir=targetPos-pos
		bullet.Spread=Vector(ent.spread,ent.spread,0)
		bullet.Tracer=1	
		bullet.TracerName=ent.tracer
		bullet.Force=2
		bullet.Damage=ent.damageDeal
		ent.fired = true
		ent:FireBullets(bullet)
		local effectdata = EffectData()
		effectdata:SetScale(1)
		effectdata:SetAngles( (targetPos-pos):Angle()) 
		effectdata:SetOrigin( pos + (targetPos-pos):GetNormalized()*10 )
		util.Effect( "MuzzleEffect", effectdata )
		sound.Play( ent.shotSound, pos )
		local angle = (targetPos-pos):Angle() + ent.Angles
		ent:SetAngles( Angle(-angle.x, angle.y, angle.z) )
	end
end

function ENT:DeathEffect ( ent )
	DefaultDeathEffect ( ent )
end