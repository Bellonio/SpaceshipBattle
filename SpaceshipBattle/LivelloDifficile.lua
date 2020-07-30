LivelloDifficile = Class{}

require "AiutanteBoss"

function LivelloDifficile:init()
	
	self.nave = Nave(5)
    self.boss = Boss(25, 3)
    	
    	--nel terzo livello il boss avra' 2 aiutanti
	self.aiutantiBoss = {[1]=AiutanteBoss(self, 1, 1), [2]=AiutanteBoss(self, 2, 1)}
	
    self.colpiNave = {}
    self.contatoreColpiNave = 1
    
    self.colpiBoss = {}
    self.contatoreColpiBoss = 1
    
    self.colpiAiutantiBoss = {}
    self.contatoreColpiAiutantiBoss = 1
    
    
    self.powerUps = {}
    self.contatorePowerUps = 1

	self.timerSparoNave = 1.2
	self.countdownSparoNave = 1.2
	
	self.timerSparoBoss = 0.2
	self.countdownSparoBoss = 1.3
	
	self.timerSparoAiutanti = 1.4
	self.countdownSparoAiutanti = 1.7
	
	self.timerPowerUp = 0
	self.countdownPowerUp = 2
	
		--quale tipo di colpo, inizia sempre con il colpo di base 
	self.cheColpo = 1
	
		--contatore per quanti colpi sparera' per volta la nave'
    self.qtaColpiNave = 1
	
		--timer per quando la nave o il boss saranno distrutti, voglio che lo schermo "si blocchi" per un attimo cosi'' da far capire all'utente cosa e' successo
	self.timerRender = 0
    
end


function LivelloDifficile:update(dt)
	
	math.randomseed(dt)
	
	if statoDelGioco == "partito" then
	
		if self.boss.padre.vita > 0 and self.nave.padre.vita > 0 then
			
			for _,aiutante in pairs(self.aiutantiBoss) do 
				if aiutante.padre.vita > 0 then aiutante:update(dt) end
			end
			
			self.boss:update(dt)
			
			if #self.powerUps > 0 then
				
				for _, powerUp in pairs(self.powerUps) do
					if powerUp.esisto == true then powerUp:update(dt) end
				end
				
			end
			
			self.timerPowerUp = self.timerPowerUp + dt
			self.timerSparoNave = self.timerSparoNave + dt
			self.timerSparoBoss = self.timerSparoBoss + dt
			self.timerSparoAiutanti = self.timerSparoAiutanti + dt
			
			if self.timerPowerUp > self.countdownPowerUp then
					
					--di seguito sceglie un powerup casuale e poi controlla se "serve a qualcosa", e in caso ne sceglie un altro (ad esempio se hai la vita piena non serve a nulla un powerup per la ricarica della salute)
					
				local chePowerUp = math.random(1,4)
				local flagOk = false

				while flagOk == false do
				
					flagOk = true
				
					if chePowerUp == 3 and self.nave.padre.vita == self.nave.padre.vitaIniziale then
						local num = math.random(1,3)
						chePowerUp = num == 3 and 4 or num
						flagOk = false
					end
				
					if chePowerUp == 1 and self.qtaColpiNave == 3 then
						chePowerUp = math.random(2,4)
						flagOk = false
					end
				
					if chePowerUp == 2 and self.cheColpo == 5 then
						local num = math.random(3,5)
						chePowerUp = num == 5 and 1 or num
						flagOk = false
					end
				
					if chePowerUp == 4 and self.countdownSparoNave < 1 then
						chePowerUp = math.random(1,3)
						flagOk = false
					end
				
				end
				
				self.powerUps[self.contatorePowerUps] = PowerUp(
					self,
					chePowerUp, 
					math.random(0, love.graphics.getWidth()-150), 										--posizione X 
					math.random(self.boss.padre.y+self.boss.height+30, love.graphics.getHeight()-200)	--posizione Y
				)
				
				self.contatorePowerUps = self.contatorePowerUps + 1			
				self.timerPowerUp = 0
					
						--ora bisognera' aspettare 1 secondo in piu' per un powerup
				self.countdownPowerUp = self.countdownPowerUp + 1
				
			end
			
			if self.timerSparoAiutanti > self.countdownSparoAiutanti then
				
				self.timerSparoAiutanti = 0

				for _,aiutante in pairs(self.aiutantiBoss) do

					if aiutante.padre.vita > 0 then
						suoni["sparoAiutante"]:play()
						
							--i colpi degli aiutanti avranno sempre potenza 1, saranno girati di 90°, MA non posso mettere la rotazione, altrimenti l'algoritmo andrebbe anche a spostare il colpo sulle y
						self.colpiAiutantiBoss[self.contatoreColpiAiutantiBoss] = Colpo(self, "aiutante"..tostring(aiutante.qualeAiutante), 1, 0)
						self.contatoreColpiAiutantiBoss = self.contatoreColpiAiutantiBoss + 1
					end

				end
				
			end
			
			if self.timerSparoNave > self.countdownSparoNave then
				
				self.timerSparoNave = 0		--resetto countdown
				creaColpiNave(self)			--creo i/il colpi/o
				
			end
			
			if self.timerSparoBoss > self.countdownSparoBoss then

				self.timerSparoBoss = 0

				if self.boss.padre.vita > 0 then

					suoni["sparoBoss"]:play()
						
							--nel livello difficile il boss spara due colpi per volta (dello stesso tipo di quelli della navicella). Angolati di 50°.
							
					self.colpiBoss[self.contatoreColpiBoss] = Colpo(self, "boss", self.cheColpo, -50)
					self.contatoreColpiBoss = self.contatoreColpiBoss + 1
					
					self.colpiBoss[self.contatoreColpiBoss] = Colpo(self, "boss", self.cheColpo, 50)
					self.contatoreColpiBoss = self.contatoreColpiBoss + 1
				
				end
				
			end
			
				--di seguito eseguo i vari update dei vari colpi presenti nella mappa
			if self.nave.padre.vita > 0 and self.colpiNave ~= nil then
				
				for _, colpoNave in pairs(self.colpiNave) do
					if colpoNave.esisto == true then colpoNave:update(dt) end
				end	
				
			end
			
			if self.colpiBoss ~= nil then
				
				for _, colpoBoss in pairs(self.colpiBoss) do
					if colpoBoss.esisto == true then colpoBoss:update(dt) end
				end	
				
			end
			
			if self.colpiAiutantiBoss ~= nil then
				
				for _, colpoAiutanteBoss in pairs(self.colpiAiutantiBoss) do
					if colpoAiutanteBoss.esisto == true then colpoAiutanteBoss:update(dt) end
				end	
				
			end
			
		else
			self.timerRender = self.timerRender + dt
		end	
		
	end
	
end


function LivelloDifficile:render()

		--se entra qui e' perche' il boss e la nave sono ancora vivi, oppure se non sono ancora passati i tot secondi
	if self.timerRender < countdownRender then 

			--la nave dovra' smettere di muoversi insieme al mouse nei tot secondi di blocco
		if self.nave.padre.vita > 0 and self.boss.padre.vita > 0 then	
			self.nave:render(true) 		--permetto di muoversi
		else
			self.nave:render(false)  	--non permetto di muoversi
		end
		
		self.boss:render()
		
		for _, aiutante in pairs(self.aiutantiBoss) do
			if aiutante.padre.vita > 0 then aiutante:render() end
		end

			--renderizzo (disegno) i vari colpi sparati		
		if self.colpiNave ~= nil then
		
			for _, colpoNave in pairs(self.colpiNave) do
				if colpoNave.esisto == true then colpoNave:render() end
			end	
			
		end
		
		if self.colpiBoss ~= nil then
			
			for _, colpoBoss in pairs(self.colpiBoss) do
				if colpoBoss.esisto == true then colpoBoss:render() end
			end	
			
		end
		
		if self.aiutantiBoss[1].padre.vita > 0 and self.aiutantiBoss[2].padre.vita > 0 and self.colpiAiutantiBoss ~= nil then
			
			for _, colpoAiutanteBoss in pairs(self.colpiAiutantiBoss) do
				if colpoAiutanteBoss.esisto == true then colpoAiutanteBoss:render() end
			end	

		end
		
		if self.nave.padre.vita > 0 and self.boss.padre.vita > 0 and #self.powerUps > 0 then
			
			for _, powerUp in pairs(self.powerUps) do
				if powerUp.esisto == true then powerUp:render() end
			end
			
		end
		
	else
	
			--countdown terminato, si ha vinto il livello o perso? Controllo
		if self.nave.padre.vita > 0 then
				
				--la nave se vede questi due valori va a settare la posizione del mouse in basso/centro della schermata
			love.mouse.setVisible(true) 
			love.mouse.setGrabbed(false)
			
				--passo al prossimo livello
			livelloGioco = livelloGioco + 1
			
		else
			livelloGioco = -2	--perso
		end

	end
	
end
