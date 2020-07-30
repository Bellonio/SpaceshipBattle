PowerUp = Class{}

function PowerUp:init(livello, qualePowerUp, x, y)
	
	self.powerUps = {
		[1] = "PIU' COLPI",
		[2] = "PIU' POTENZA",
		[3] = "RICARICA\nSALUTE",
		[4] = "PIU' VELOCE",
	}
	
	self.dimensionePowerUps = {
			--la funzione per creare il rettangolo e' storta, ho preso le giuste altezze ma creava un rettangolo meno alto
		[1] = {["width"] = 100, ["height"] = 11, ["altInPiu"] = 10},
		[2] = {["width"] = 135, ["height"] = 11, ["altInPiu"] = 10},
		[3] = {["width"] = 90, ["height"] = 30, ["altInPiu"] = 17},
		[4] = {["width"] = 120, ["height"] = 11, ["altInPiu"] = 10}
	}
	
	self.livello = livello
	
	self.esisto = true
	
	self.qualePowerUp = qualePowerUp
	self.str = self.powerUps[self.qualePowerUp] 
	self.x = x
	self.y = y
	
end


function PowerUp:update(dt)
		
		--collisione con la nave
	if ((self.livello.nave.padre.y >= self.y and self.livello.nave.padre.y <= self.y+self.dimensionePowerUps[self.qualePowerUp]["height"]) 
		or (self.livello.nave.padre.y+self.livello.nave.height >= self.y and self.livello.nave.padre.y+self.livello.nave.height <= self.y+self.dimensionePowerUps[self.qualePowerUp]["height"]))
		and ((self.livello.nave.padre.x >= self.x and self.livello.nave.padre.x <= self.x+self.dimensionePowerUps[self.qualePowerUp]["width"])
		or ((self.livello.nave.padre.x+self.livello.nave.width >= self.x and self.livello.nave.padre.x+self.livello.nave.width <= self.x+self.dimensionePowerUps[self.qualePowerUp]["width"]))) then
		
		if self.qualePowerUp == 1 then
			self.livello.qtaColpiNave = self.livello.qtaColpiNave + 1
		elseif self.qualePowerUp == 2 then
			self.livello.cheColpo = self.livello.cheColpo + 1
		elseif self.qualePowerUp == 3 then
			self.livello.nave.padre.vita = self.livello.nave.padre.vita + 2
		else
			self.livello.countdownSparoNave = self.livello.countdownSparoNave - 0.5
		end
		
		self.esisto = false
		
	end
	
end

function PowerUp:render()
	
		--un powerup non e' altro che una scritta con un rettangolo disegnato in torno
	love.graphics.setFont(powerUpFont)
	
	love.graphics.rectangle("line", self.x, self.y, 
		self.dimensionePowerUps[self.qualePowerUp]["width"], 
		self.dimensionePowerUps[self.qualePowerUp]["height"]+self.dimensionePowerUps[self.qualePowerUp]["altInPiu"])
	
	love.graphics.print(self.str, self.x, self.y)
	
	love.graphics.setFont(normalFont)
	
end
