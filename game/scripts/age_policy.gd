extends RefCounted
const GROUPS = ["under13", "teen", "adult"]
static func online(data: Dictionary) -> bool:
	return data.get("age_group", "") in ["teen", "adult"]
static func known(data: Dictionary) -> bool:
	return data.get("age_group", "") in GROUPS
static func minor(data: Dictionary) -> bool:
	return data.get("age_group", "") != "adult"
const COPY = {
"offline_note": ["Practice offline. Results stay on this device.","Vežbaj offline. Rezultati ostaju na ovom uređaju.","Offline üben. Ergebnisse bleiben auf diesem Gerät.","Entraînement hors ligne. Résultats sur cet appareil.","Practica sin conexión. Resultados en este dispositivo.","Pratica offline. Risultati su questo dispositivo."],
"no_services": ["No online rankings, ads or continues after defeat.","Nema online rang-lista, oglasa ni nastavka posle poraza.","Keine Online-Ranglisten, Werbung oder Fortsetzungen nach Niederlagen.","Sans classement en ligne, publicité ni reprise après une défaite.","Sin clasificaciones en línea, anuncios ni continuaciones tras perder.","Niente classifiche online, annunci o continuazioni dopo una sconfitta."],
"title": ["YOUR AGE GROUP", "TVOJ UZRAST", "DEINE ALTERSGRUPPE", "TON ÂGE", "TU EDAD", "LA TUA ETÀ"],
"question": ["How old are you?", "Koliko imaš godina?", "Wie alt bist du?", "Quel âge as-tu ?", "¿Cuántos años tienes?", "Quanti anni hai?"],
"local": ["Only your age group is saved on this device, not your date of birth.", "Na uređaju čuvamo samo grupu uzrasta, ne datum rođenja.", "Nur deine Altersgruppe wird auf diesem Gerät gespeichert, nicht dein Geburtsdatum.", "Seule ta tranche d’âge est enregistrée sur cet appareil, pas ta date de naissance.", "Solo guardamos tu grupo de edad en este dispositivo, no tu fecha de nacimiento.", "Sul dispositivo salviamo solo la fascia d’età, non la data di nascita."],
"under": ["Under 13", "Mlađi od 13", "Unter 13", "Moins de 13 ans", "Menos de 13", "Meno di 13"],
"save": ["CONFIRM", "POTVRDI", "BESTÄTIGEN", "CONFIRMER", "CONFIRMAR", "CONFERMA"],
"info": ["PLAY ON THIS DEVICE", "IGRA NA OVOM UREĐAJU", "AUF DIESEM GERÄT SPIELEN", "JOUER SUR CET APPAREIL", "JUGAR EN ESTE DISPOSITIVO", "GIOCA SU QUESTO DISPOSITIVO"],
"restricted": ["Under 13 or age not set: Campaign and Endless stay available. Records stay on this device. Daily Challenge is offline practice only. No online rankings, ads or continues after defeat.", "Za mlađe od 13 i nepoznat uzrast: Kampanja i Beskraj ostaju dostupni. Rekordi se čuvaju samo na uređaju. Dnevni izazov je offline vežba. Nema online rang-lista, oglasa ni nastavka posle poraza.", "Unter 13 oder Alter unbekannt: Kampagne und Endlos bleiben verfügbar. Rekorde bleiben auf dem Gerät. Die Tagesaufgabe ist nur Offline-Training. Keine Online-Ranglisten, Werbung oder Fortsetzungen nach einer Niederlage.", "Moins de 13 ans ou âge inconnu : campagne et mode infini disponibles. Records sur cet appareil uniquement. Défi quotidien en entraînement hors ligne. Aucun classement en ligne, publicité ou reprise après une défaite.", "Menores de 13 o edad desconocida: campaña e infinito disponibles. Récords solo en el dispositivo. El desafío diario es práctica sin conexión. Sin clasificaciones en línea, anuncios ni continuaciones tras perder.", "Meno di 13 anni o età sconosciuta: campagna e infinito disponibili. Record solo sul dispositivo. Sfida giornaliera solo come pratica offline. Niente classifiche online, annunci o continuazioni dopo una sconfitta."],
"older": ["Online rankings are available. Up to three continues per Endless run require a completed rewarded ad. Ads depend on availability and privacy settings. No ad means no continue.", "Online rang-liste su dostupne. Do tri nastavka u Beskraju zahtevaju odgledan nagrađeni oglas. Oglasi zavise od dostupnosti i privatnosti. Bez oglasa nema nastavka.", "Online-Ranglisten sind verfügbar. Bis zu drei Fortsetzungen pro Endlosrunde erfordern belohnte Werbung. Verfügbarkeit und Datenschutz gelten. Ohne Werbung keine Fortsetzung.", "Classements en ligne disponibles. Jusqu’à trois reprises par partie infinie nécessitent une publicité récompensée complète, selon sa disponibilité et les réglages de confidentialité. Sans publicité, pas de reprise.", "Clasificaciones en línea disponibles. Hasta tres continuaciones por partida infinita requieren un anuncio recompensado completo, según disponibilidad y privacidad. Sin anuncio no hay continuación.", "Classifiche online disponibili. Fino a tre continuazioni per partita infinita richiedono un annuncio con premio completo, secondo disponibilità e privacy. Senza annuncio non si continua."],
"practice": ["OFFLINE PRACTICE", "OFFLINE VEŽBA", "OFFLINE-TRAINING", "ENTRAÎNEMENT HORS LIGNE", "PRÁCTICA SIN CONEXIÓN", "PRATICA OFFLINE"],
"records": ["LOCAL RECORDS", "LOKALNI REKORDI", "LOKALE REKORDE", "RECORDS LOCAUX", "RÉCORDS LOCALES", "RECORD LOCALI"],
"privacy": ["PLAY & PRIVACY", "IGRA I PRIVATNOST", "SPIEL & DATENSCHUTZ", "JEU ET CONFIDENTIALITÉ", "JUEGO Y PRIVACIDAD", "GIOCO E PRIVACY"],
"empty": ["No local records yet.", "Još nema lokalnih rekorda.", "Noch keine lokalen Rekorde.", "Aucun record local.", "Aún no hay récords locales.", "Nessun record locale."],
"error": ["Could not save. Please try again.", "Čuvanje nije uspelo. Pokušaj ponovo.", "Speichern fehlgeschlagen. Bitte erneut versuchen.", "Échec de l’enregistrement. Réessaie.", "No se pudo guardar. Inténtalo de nuevo.", "Salvataggio non riuscito. Riprova."]
}
static func text(key: String, language: String) -> String:
	var index: int=["en","sr","de","fr","es","it"].find(language)
	return COPY[key][maxi(0,index)]
