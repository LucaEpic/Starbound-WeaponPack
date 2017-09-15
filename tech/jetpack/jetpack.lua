function init()
  self.doubleTapTimer = 0
  self.active = false
  self.lastMoves = {}
  self.energyPerSecond = config.getParameter("energyCostPerSecond")
  self.techType = config.getParameter("type")
end

function input(args)
  if self.techType == "head" and args.moves["special"] == 1 and self.lastMoves["special"] ~= 1 then --on and off
    if self.active then
      deactivateFly()
    elseif not status.resourceLocked("energy") then
      activateFly()
    end
  elseif args.moves["special"] == 2 and self.lastMoves["special"] ~= 2 then --togle light/cycle brightness
    setLight(true)
  end

  if self.techType == "legs" and args.moves["up"] then
	if not self.lastMoves["up"] then
		if self.doubleTapTimer <= 0 then
			self.doubleTapTimer = 0.35
		else
			if self.active then
			  deactivateFly()
			elseif not status.resourceLocked("energy") then
			  activateFly()
			end
			self.doubleTapTimer = 0
		  end
	  end
  end
  self.lastMoves = args.moves --hold on to old buttons to determine if they're being held
end

function update(args)
  input(args)
  if self.active and not status.resourceLocked("energy") then
    flyControls(args)
    flyAnimation()
    status.addEphemeralEffect("nofalldamage", math.huge)
    status.consumeResource("energy", self.energyPerSecond)
    tech.setParentState("fly")
  end

  if mcontroller.groundMovement() or mcontroller.liquidMovement() then
    status.removeEphemeralEffect("nofalldamage")
  end
end

function activateFly()
  tech.setParentState("fly")
  self.active = true
end

function deactivateFly()
  animator.setParticleEmitterActive("rocketParticles1", false)
  self.active = false
  tech.setParentState()
end

function flyControls(args)
  if args.moves["left"] then
    mcontroller.setXVelocity(-10)
  end
  if args.moves["right"] then
    mcontroller.setXVelocity(10)
  end
  if args.moves["jump"] then
     mcontroller.controlParameters({gravityEnabled = false})
     mcontroller.controlApproachYVelocity(40, 100)
end

function flyAnimation()
    tech.setParentState("fly")
    animator.burstParticleEmitter("rocketParticles1")
end

function uninit()
  status.removeEphemeralEffect("nofalldamage")
  deactivateFly()
end
end
