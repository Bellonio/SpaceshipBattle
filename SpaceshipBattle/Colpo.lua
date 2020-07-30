Colpo = Class{}

local colpo_sprite_width = 38
local colpo_sprite_height = 45

local esplosioni_sprite_width = 16
local esplosioni_sprite_height = 16

local VELOCITA_COLPO = 25
local VELOCITA_COLPO_AIUTANTE = 15


function Colpo:init(livello, diChiColpo, cheColpo, rot)
	
		-- *** : i colpi, alcuni, saranno ruotati. VERRANNO RUOTATE ANCHE LE RISPETTIVE COORDINATE X E Y
	
	self.imageColpi = love.graphics.newImage("/altreImmagini/colpi.png")
	colpiQuads = dividiSpritesheets(self.imageColpi, colpo_sprite_width, colpo_sprite_height, 5)

	self.imageEsplosioni = love.graphics.newImage("/altreImmagini/esplosioni.png")
	esplosioniQuads = dividiSpritesheets(self.imageEsplosioni, esplosioni_sprite_width, esplosioni_sprite_height, 10)
	
	self.width = colpo_sprite_width
	self.height = colpo_sprite_height
	
	self.livello = livello
	self.diChiColpo = diChiColpo
	
	self.rotazione = rot
	
		--dopo molte prove ho notato che lo spostamento sulle x era realistico eseguendo questo calcolo
	if self.rotazione > 0 then
		self.spostamento_x = self.rotazione - 10
	elseif self.rotazione < 0 then
		self.spostamento_x = self.rotazione + 10
	else
		self.spostamento_x = 0
	end
	
	if self.diChiColpo == "nave" then
		
		self.x = self.livello.nave.padre.x + self.livello.nave.width/2 - colpo_sprite_width/2
		self.y = self.livello.nave.padre.y - colpo_sprite_height
		self.velocita_colpi = VELOCITA_COLPO	
		self.cheColpo = cheColpo
		
	elseif self.diChiColpo == "boss" then
		
		self.x = self.livello.boss.padre.x + self.livello.boss.width/2 - colpo_sprite_width/2
		
			-- ***
		if self.rotazione > 0 then
			self.y = self.livello.boss.padre.y + self.livello.boss.height - 15
		else
			self.y = self.livello.boss.padre.y + self.livello.boss.height
		end
		
		self.rotazione = -self.rotazione		--la rotazione io l'ho inserita pensando che l'origine del colpo sarebbe stata in basso, con il boss l'origine sara' in alto, quindi devo cambiar di segno la rotazione
		self.velocita_colpi = -VELOCITA_COLPO	
		
		self.cheColpo = cheColpo
		
	else		--colpi degli aiutanti
		
		self.cheColpo = cheColpo
		
			--- ***
		if self.diChiColpo == "aiutante1" then
			
			self.rotazione = 90
			self.velocita_colpi = VELOCITA_COLPO_AIUTANTE

			self.x = self.livello.aiutantiBoss[1].padre.x + self.height
			self.y = self.livello.aiutantiBoss[1].padre.y
			
		else
			
			self.rotazione = -90
			self.velocita_colpi = -VELOCITA_COLPO_AIUTANTE
			
			self.x = self.livello.aiutantiBoss[2].padre.x - self.width
			self.y = self.livello.aiutantiBoss[2].padre.y - self.width
			
		end
		
	end
	
	self.esisto = true			--flag per controllare che il colpo sia o meno andato a segno
	self.timerSpostamento = 0	--ogni tot il colpo si spostera' di self.velocita_colpi
	
end


function Colpo:update(dt)
	
	self.timerSpostamento = self.timerSpostamento + dt
	
	if self.timerSpostamento > 7/100 then
		
		if self.diChiColpo == "nave" or self.diChiColpo == "boss" then
		
			self.timerSpostamento = 0
			self.y = self.y - self.velocita_colpi
			
			if self.spostamento_x ~= 0 then self.x = self.x + self.spostamento_x end
			
		else
				--i colpi degli aiutanti si spostano sulle x non sulle y
			self.timerSpostamento = 0
			self.x = self.x + self.velocita_colpi
			
			if self.spostamento_x ~= 0 then self.y = self.y - self.spostamento_x end
			
		end
		
	end
		
		--controlli di collisione	
	if self.diChiColpo == "nave" then
		
		
			--collisione col boss
		if ((self.y >= self.livello.boss.padre.y and self.y <= self.livello.boss.padre.y+self.livello.boss.height)
			or (self.y+self.height >= self.livello.boss.padre.y and self.y+self.height <= self.livello.boss.padre.y+self.livello.boss.height))
			and ((self.x >= self.livello.boss.padre.x and self.x <= self.livello.boss.padre.x+self.livello.boss.width) 
			or (self.x+self.width >= self.livello.boss.padre.x and self.x+self.width <= self.livello.boss.padre.x+self.livello.boss.width)) then
			
			suoni["boss_aiutante_colpito"]:play()
			
			self.esisto = false
			
			if self.cheColpo > 2 then		--il colpo da 1 fa 1 danni, quello da 2 fa 2 danni, ma ce ne un altro quadColpo da 2, e questo fara'' 3 danni
				self.livello.boss.padre.vita = self.livello.boss.padre.vita - self.cheColpo+1			
			else
				self.livello.boss.padre.vita = self.livello.boss.padre.vita - self.cheColpo
			end
			
		end
		
		if self.livello.colpiAiutantiBoss ~= nil then
				--collisione aiutanti boss
			for i=1, 2 do
			
				if ((self.y >= self.livello.aiutantiBoss[i].padre.y and self.y <= self.livello.aiutantiBoss[i].padre.y + self.livello.aiutantiBoss[i].width)
					or (self.y+self.height >= self.livello.aiutantiBoss[i].padre.y and self.y+self.height <= self.livello.aiutantiBoss[i].padre.y + self.livello.aiutantiBoss[i].width)) 
					and ((self.x >= self.livello.aiutantiBoss[i].padre.x-self.livello.aiutantiBoss[i].height and self.x <= self.livello.aiutantiBoss[i].padre.x)
					or (self.x+self.width >= self.livello.aiutantiBoss[i].padre.x-self.livello.aiutantiBoss[i].height and self.x+self.width <= self.livello.aiutantiBoss[i].padre.x)) then
						
					self.esisto = false
					self.livello.aiutantiBoss[i].padre.vita = 0
					
				end
				
			end
			
		end
		
			--il colpo ha superato il boss ormai, lo elimino
		if self.y <= 5 then
			self.esisto = false
		end	
		
	elseif self.diChiColpo == "boss" then
		
			--collisione con la nave
		if ((self.y >= self.livello.nave.padre.y and self.y <= self.livello.nave.padre.y+self.livello.nave.height)
			or (self.y-self.height >= self.livello.nave.padre.y and self.y-self.height <= self.livello.nave.padre.y+self.livello.nave.height))
			and ((self.x-self.width >= self.livello.nave.padre.x and self.x-self.width <= self.livello.nave.padre.x+self.livello.nave.width)
			or (self.x >= self.livello.nave.padre.x and self.x <= self.livello.nave.padre.x+self.livello.nave.width)) then
			
			suoni["naveColpita"]:play()
			
			self.esisto = false
			
			if self.cheColpo > 2 then		--il colpo da 1 fa 1 danni, quello da 2 fa 2 danni, ma ce ne un altro quadColpo da 2, e questo fara'' 3 danni		
				self.livello.nave.padre.vita = self.livello.nave.padre.vita - self.cheColpo+1			
			else
				self.livello.nave.padre.vita = self.livello.nave.padre.vita - self.cheColpo
			end
			
		end	
		
			--il colpo ha praticamente superato il limite della mappa ormai, lo elimino
		if self.y >= love.graphics.getHeight()-5 then
			self.esisto = false
		end
		
	else
		
			--collisione con la nave
		if self.diChiColpo == "aiutante1" then
			
			if ((self.y > self.livello.nave.padre.y and self.y < self.livello.nave.padre.y+self.livello.nave.height)
				or (self.y+self.width > self.livello.nave.padre.y and self.y+self.width < self.livello.nave.padre.y+self.livello.nave.height)) 
				and ((self.x > self.livello.nave.padre.x and self.x < self.livello.nave.padre.x+self.livello.nave.width) 
				or (self.x-self.height > self.livello.nave.padre.x and self.x-self.height < self.livello.nave.padre.x+self.livello.nave.width)) then

				suoni["boss_aiutante_colpito"]:play()	
				
				self.esisto = false
				self.livello.nave.padre.vita = self.livello.nave.padre.vita - self.cheColpo
				
			end
			
		else
			
			if ((self.y > self.livello.nave.padre.y and self.y < self.livello.nave.padre.y+self.livello.nave.height)
				or (self.y-self.width > self.livello.nave.padre.y and self.y-self.width < self.livello.nave.padre.y+self.livello.nave.height)) 
				and ((self.x > self.livello.nave.padre.x and self.x < self.livello.nave.padre.x+self.livello.nave.width) 
				or (self.x+self.height > self.livello.nave.padre.x and self.x+self.height < self.livello.nave.padre.x+self.livello.nave.width)) then
			
				suoni["boss_aiutante_colpito"]:play()	
				self.esisto = false
				self.livello.nave.padre.vita = self.livello.nave.padre.vita - self.cheColpo

			end
			
		end
		
	end
	
	if self.livello.nave.padre.vita < 0 then 
		
		self.livello.nave.padre.vita = 0
		suoni["naveDistrutta"]:play()
		
	end

	if self.livello.boss.padre.vita < 0 then self.livello.boss.padre.vita = 0 end
	
end


function Colpo:render()
	
	if self.diChiColpo ~= "boss" then
		
		if self.cheColpo < 4 then
			love.graphics.draw(self.imageColpi, colpiQuads[self.cheColpo], self.x, self.y, math.rad(self.rotazione), 1.5, 1.5)
		else
				--semplicemente i colpi da 4 li voglio piu' grandi
			love.graphics.draw(self.imageColpi, colpiQuads[self.cheColpo], self.x, self.y, math.rad(self.rotazione), 1.8, 1.8)
		end

	else
		
			--colpi del boss, devono essere ruotati di 180°
		if self.cheColpo < 4 then
			love.graphics.draw(self.imageColpi, colpiQuads[self.cheColpo], self.x, self.y, math.rad(self.rotazione+180), 1.4, 1.4)
		else
				--semplicemente i colpi da 4 li voglio piu' grandi
			love.graphics.draw(self.imageColpi, colpiQuads[self.cheColpo], self.x, self.y, math.rad(self.rotazione+180), 1.8, 1.8)
		end	
		
	end
	
end
