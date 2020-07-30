push = require "push"
Class = require "class"
require "Guida"
require "LivelloEasy"
require "LivelloMedio"
require "LivelloDifficile"

require "Nave"
require "Colpo"
require "Boss"
require "ClassePadreNavicella"
require "PowerUp"



VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720


local timerSecondoLivello
local flagFattoCountdown


function love.load()
	
	normalFont = love.graphics.newFont("/fonts/normalFont.ttf", 15)
	powerUpFont = love.graphics.newFont("/fonts/powerUpFont.ttf", 23)
	fontVittoriaSconfitta = love.graphics.newFont("/fonts/fontVittoriaSconfitta.ttf", 33)
	fontScrittaVita = love.graphics.newFont("/fonts/fontScrittaVita.otf", 25)
	
	suoni = {
		["soundtrack"] = love.audio.newSource("suoni/soundtrack.wav", "stream"),
		["sparoNave"] = love.audio.newSource("suoni/sparoNave.wav", "stream"),
		["sparoBoss"] = love.audio.newSource("suoni/sparoBoss.wav", "stream"),
		["sparoAiutante"] = love.audio.newSource("suoni/sparoAiutante.wav", "stream"),
		["naveColpita"] = love.audio.newSource("suoni/naveColpita.wav", "static"),
		["boss_aiutante_colpito"] = love.audio.newSource("suoni/boss_aiutante_colpito.wav", "static"),
		["vittoria"] = love.audio.newSource("suoni/vittoria.wav", "static"),
		["naveDistrutta"] = love.audio.newSource("suoni/naveDistrutta.mp3", "static")
	}
	
	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle("SPACESHIP BATTLE")

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
    
	sfondo = love.graphics.newImage("/altreImmagini/sfondo.png")
    resetCompleto()
    
end



function resetCompleto()
	
	love.graphics.setFont(normalFont)
	
		--la nave se vede questi due valori va a settare la posizione del mouse in basso/centro della schermata
	love.mouse.setVisible(true) 
	love.mouse.setGrabbed(false)
	
	spaceshipScelta = 1			--la prima spaceship che vedra' l'utente, la prima
	
		--classe che spiega un minimo i comandi e permette la scelta della navicella
	guida = Guida()
    statoDelGioco = "guida"
    
    livelloGioco = 1			--incomincera' ovviamente dal livello 1
    
    	--i livelli non mi servono ancora, percio' li creero' dopo
    flagLivelloMedioCreato = false
    flagLivelloDifficileCreato = false
    
	livelloEasy = LivelloEasy()
	
		--variabile che mi permette di "bloccare" tutto per poco tempo quando nave o boss vengono distrutti, per far capire all'utente cosa e' successo
	countdownRender = 1.3
	
		--di seguito due variabili per livello che mi servono per mostrare un msg all'utente per tot secondi
	timerLivello = 0
	flagFattoCountdown = false
	
	timerLivello2 = 0
	flagFattoCountdown2 = false
	
end


	--funzione che utilizzero' per dividere uno spritesheet in diversi quad, ritornata sotto forma di table con indici ordinati. Semplicemente prende come parametri l'immagine, le dimensioni di un quad e la qta di quad presenti
function dividiSpritesheets(img, sprWidth, sprHeight, qtaSprite)
	
	local quads = {}
	
	for contatore = 1, qtaSprite do
		quads[contatore] = love.graphics.newQuad(0, (sprHeight*(contatore-1)), sprWidth, sprHeight, img:getDimensions())
		contatore = contatore + 1
	end
	
	return quads
	
end


function love.keypressed(key)
	if key == "escape" then
		
		love.event.quit()
		
	elseif key == "return" then
		
		if statoDelGioco == "guida" then
			statoDelGioco = "fermo"
		elseif statoDelGioco == "fermo" then
			statoDelGioco = "partito"
		end
		
	elseif key == "r" then
		
		if statoDelGioco == "vittoria" or statoDelGioco == "sconfitta" then
			resetCompleto()
		end
		
	else
			--devo poter cambiare navicella solamente durante la guida
		if statoDelGioco == "guida" then
			if key == "left" then
				if spaceshipScelta > 1 then	spaceshipScelta = spaceshipScelta - 1 end
			elseif key == "right" then
				if spaceshipScelta < 8 then	spaceshipScelta = spaceshipScelta + 1 end
			end
		end
		
	end
	
end


function love.update(dt)
	if livelloGioco == 1 then

		livelloEasy:update(dt)
		
	elseif livelloGioco == 2 then
		
			--se ancora non l'avevo creato, lo creo
		if flagLivelloMedioCreato == false then
			livelloMedio = LivelloMedio()
			flagLivelloMedioCreato = true		--cosi smettera' di crearlo ad ogni giro dell'update
		end
		
			--timer per mostrare una scritta all'utente
		if flagFattoCountdown == false then
			timerLivello = timerLivello + dt
			if timerLivello > 3.5 then
				flagFattoCountdown = true
				statoDelGioco = "fermo"
			end
		else
			livelloMedio:update(dt)
		end
		
	elseif livelloGioco == 3 then
			--se ancora non l'avevo creato, lo creo
		if flagLivelloDifficileCreato == false then
			livelloDifficile = LivelloDifficile()
			flagLivelloDifficileCreato = true		--cosi smettera' di crearlo ad ogni giro dell'update
		end
		
			--timer per mostrare una scritta all'utente
		if flagFattoCountdown2 == false then
			timerLivello2 = timerLivello2 + dt
			if timerLivello2 > 4 then
				flagFattoCountdown2 = true
				statoDelGioco = "fermo"
			end
		else
			livelloDifficile:update(dt)
		end
		
	end
	
end


	--funzione che usero' in ogni livello per creare i colpi della nave, qui per semplicita' passo direttamente il livello in cui si trova la nave che sta per sparare, in questo modo ho accesso a tutti gli attributi della classe
function creaColpiNave(livello)
	suoni["sparoNave"]:play()
	
	if livello.qtaColpiNave == 1 then

			--devo creare un colpo... creo un colpo solo con 0° di rotazione. E lo aggiungo alla lista (table con indici ordinati) del livello			
		livello.colpiNave[livello.contatoreColpiNave] = Colpo(livello, "nave", livello.cheColpo, 0)
		livello.contatoreColpiNave = livello.contatoreColpiNave + 1
		
	elseif livello.qtaColpiNave == 2 then
		
			--devo creare due colpi... creo due colpi con rotazioni opposte, e randomiche. E li aggiungo alla lista (table con indici ordinati) del livello
		local flag = 1
		local rotazione = math.random(13, 35)
		for i=1, livello.qtaColpiNave do
			livello.colpiNave[livello.contatoreColpiNave] = Colpo(livello, "nave", livello.cheColpo, flag==1 and rotazione or -rotazione)
			livello.contatoreColpiNave = livello.contatoreColpiNave + 1
			flag = -flag
		end	
					
	else	--non elseif perche' ho deciso per pura e semplice comodita' che il max di colpi e' 3
		
			--devo creare ter colpi... creo due colpi con rotazioni opposte, e randomiche, e uno con 0° di rotazione. E li aggiungo alla lista (table con indici ordinati) del livello
		local flag = 1
		local rotazione = math.random(13, 35)
		for i=1, livello.qtaColpiNave do
			
			if i ~= 2 then		--il colpo centrale sara' quello con rotazione 0°
				livello.colpiNave[livello.contatoreColpiNave] = Colpo(livello, "nave", livello.cheColpo, flag==1 and rotazione or -rotazione)
				livello.contatoreColpiNave = livello.contatoreColpiNave + 1
				flag = -flag
			else
				livello.colpiNave[livello.contatoreColpiNave] = Colpo(livello, "nave", livello.cheColpo, 0)
				livello.contatoreColpiNave = livello.contatoreColpiNave + 1
			end
			
		end
		
	end
	
end


function love.draw()
		
		--disegno lo sfondo, sempre e comunque. Come prima cosa (se lo facessi dopo altro, quell'altro verrebbe nascosto)
	love.graphics.draw(sfondo)
		
	if statoDelGioco ~= "vittoria" then
			--imposto una musica di sottofondo, a volume piu' basso rispetto gli altri suoni
		suoni["soundtrack"]:setVolume(0.5)
		suoni["soundtrack"]:play()
	end
	
	if statoDelGioco ~= "guida" then
		
		if livelloGioco == 1 then
			
			stampaMsgPerPartire()
			livelloEasy:render()
			
		elseif livelloGioco == 2 then
			
			if flagFattoCountdown == false then

				if timerLivello < 3 then
					
					love.graphics.print("BENE HAI SUPERATO IL LIVELLO ...", 280, love.graphics.getHeight()/2-10)
					
					if timerLivello > 1.5 then
						love.graphics.print("FACILE", love.graphics.getWidth()/2+120, love.graphics.getHeight()/2-10)
					end
					
				else
					
					love.graphics.print("LA NAVICELLA VERRA' RIPRISTINATA", love.graphics.getWidth()/2-300, love.graphics.getHeight()/2-10)
					
				end
				
			else
				stampaMsgPerPartire()
				livelloMedio:render()
			end
			
		elseif livelloGioco == 3 then
			
			if flagFattoCountdown2 == false then
				
				if timerLivello2 < 4 then
					love.graphics.print("COMPLIMENTI, MA DEVI ANCORA SUPERARE L'ULTIMO LIVELLO !", 200, love.graphics.getHeight()/2-10)
				else
				
					love.graphics.print("LA NAVICELLA VERRA' RIPRISTINATA", love.graphics.getWidth()/2-300, love.graphics.getHeight()/2-10)
					
				end
			else
				stampaMsgPerPartire()
				livelloDifficile:render()
			end
			
		elseif livelloGioco == 4 then			--non ho altri livelli, vittoria
			
			statoDelGioco = "vittoria"

			suoni["vittoria"]:play()
			
			love.graphics.setFont(fontVittoriaSconfitta)
			love.graphics.setColor(0,1,0,1)
			
			love.graphics.print("\t\tCOMPLIMENTI !\nHAI TERMINATO IL GIOCO !", love.graphics.getWidth()/2-200, love.graphics.getHeight()/2-10)
			
			love.graphics.setColor(1,1,1,1)
			love.graphics.setFont(normalFont)
			
			love.graphics.print("Premi 'r' per riprovare.", love.graphics.getWidth()/2-150, love.graphics.getHeight()/2+80)
			
			
		elseif livelloGioco == -2 then			--perso
			
			love.graphics.setFont(fontVittoriaSconfitta)
			love.graphics.setColor(1,0,0,1)
			
			love.graphics.print("OH NO, HAI PERSO !!!", love.graphics.getWidth()/2-180, love.graphics.getHeight()/2-10)
			
			love.graphics.setColor(1,1,1,1)
			love.graphics.setFont(normalFont)
			
			love.graphics.print("Premi 'r' per riprovare.", love.graphics.getWidth()/2-180, love.graphics.getHeight()/2+40)
			
			statoDelGioco = "sconfitta"
		end
	else
		guida:render()
	end
end


function stampaMsgPerPartire()

	if statoDelGioco == "fermo" then
		love.graphics.print("PREMI INVIO PER PARTIRE ...", love.graphics.getWidth()/2-200, love.graphics.getHeight()-300)
	end

end
