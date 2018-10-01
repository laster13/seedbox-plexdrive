#!/bin/bash

CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CPURPLE="${CSI}1;35m"
CCYAN="${CSI}1;36m"

###################################################################################################################################################

progress-bar() {
  local duration=${1}
printf '\n'
echo -e "${CGREEN}Patientez ...	${CEND}"
printf '\n'

    already_done() { for ((done=0; done<$elapsed; done++)); do printf "#"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do printf " "; done }
    percentage() { printf "| %s%%" $(( (($elapsed)*100)/($duration)*100/100 )); }
    clean_line() { printf "\r"; }

  for (( elapsed=1; elapsed<=$duration; elapsed++ )); do
      already_done; remaining; percentage
      sleep 0.2
      clean_line
  done
  clean_line
printf '\n'
}

clear
logo.sh 
echo ""
echo -e "${CCYAN}INSTALLATION${CEND}"
	echo -e "${CGREEN}${CEND}"
	echo -e "${CGREEN}   1) Installation de docker && docker-compose ${CEND}"
	echo -e "${CGREEN}   2) Configuration du docker-compose ${CEND}"
	echo -e "${CGREEN}   3) Configuration rclone ${CEND}"
	echo -e "${CGREEN}   4) Configuration plexdrive v-5.0.0 ${CEND}"
	echo -e "${CGREEN}   5) Lancement des applications ${CEND}"
	echo -e "${CGREEN}   6) Configuration plex_autoscan && unionfs_cleaner && plex_dupefinder ${CEND}"
	echo -e "${CGREEN}   7) Sauvegarde des volumes ${CEND}"
	echo -e "${CGREEN}   8) Quitter ${CEND}"
	echo -e ""
	until [[ "$PORT_CHOICE" =~ ^[1-8]$ ]]; do
		read -p "Votre choix [1-8]: " -e -i 1 PORT_CHOICE
	done

	case $PORT_CHOICE in
		1) ## Installation de docker et docker-compose
			logo.sh
			echo -e "${CGREEN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}					INSTALLATION DOCKER ET DOCKER-COMPOSE						   ${CEND}"
			echo -e "${CGREEN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo ""                        
			apt-get install \
                        apt-transport-https \
			apache2-utils \
                        ca-certificates \
                        curl \
                        gnupg2 \
			lsb-release \
                        software-properties-common
                        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
			curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
                        add-apt-repository \
                        "deb [arch=amd64] https://download.docker.com/linux/debian \
                        $(lsb_release -cs) \
                        stable"
                        apt update
                        apt install docker-ce
                        curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
                        chmod +x /usr/local/bin/docker-compose
			clear
			logo.sh
			echo -e "${CCYAN}Installation docker & docker compose terminée${CEND}"
			echo ""
			read -p "Appuyer sur la touche Entrer pour revenir au menu principal"	
			seedbox.sh
		;;

		2) 	## Mise en place des variables necéssaire au docker-compose
			clear
			logo.sh			
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}					PRECISONS SUR LES VARIABLES							  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}		Cette étape permet une installation personnalisée configurable à vos besoins				 ${CEND}"	
			echo -e "${CGREEN}		Une fois les variables définies, la configuration sera complètement automatisée 			 ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}															 ${CEND}"
			echo -e "${CCYAN}				UNE ATTENTION PARTICULIERE EST REQUISE POUR CETTE ETAPE					 ${CEND}"
			echo -e "${CCYAN}															 ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}${CEND}"
			## définition des variables

			echo -e "${CCYAN}Nom de domaine ${CEND}"
			read -rp "DOMAIN = " DOMAIN

			if [ -n "$DOMAIN" ]
			then
			 	export DOMAIN
			fi

			echo  ""
			echo -e "${CCYAN}Nom d'utilisateur ${CEND}"
			read -rp "USERNAME = " USERNAME

			if [ -n "$USERNAME" ]
			then
			 	export USERNAME
			fi

			echo ""
			echo -e "${CCYAN}Adresse mail ${CEND}"
			read -rp "MAIL = " MAIL

			if [ -n "$MAIL" ]
			then
			 	export MAIL
			fi

			echo ""
			echo -e "${CCYAN}Remote crypté, doit pointer vers /home/plexdrive dans votre fichier rclone.conf (Modifier le fichier rclone.conf en conséquence) ${CEND}"
			echo -e "${CRED}TRES IMPORTANT${CGREEN} mettez le "/" à la fin du remote ${CEND}"
			read -rp "RemotePath = " RemotePath

			if [ -n "$RemotePath" ]
			then
			 	export RemotePath
			fi

			echo ""
			echo -e "${CCYAN}Remote crypté dans rclone.conf, celui qui est solicité pour les transferts  ${CEND}"
			echo -e "${CRED}TRES IMPORTANT${CGREEN} mettez le "/" à la fin du remote ${CEND}"
			read -rp "RemoteLocal = " RemoteLocal 

			if [ -n "$RemoteLocal" ]
			then
			 	export RemoteLocal
			fi

			clear
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CGREEN}				LES VARIABLES CI DESSOUS SONT DEFINIES PAR DEFAULT DANS LES CONTAINERS			  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CRED}	  ${CPURPLE}MountPoint:${CRED} Montage crypté plexdrive monté en clair dans:	${CCYAN}/mnt/rclone	  	  ${CEND}"
			echo -e "${CRED}	  ${CPURPLE}MountUnion:${CRED} Montage Unionfs-fuse monté dans:			${CCYAN}/mnt/Union 	  	  ${CEND}"
			echo -e "${CRED}	  ${CPURPLE}MountLocal:${CRED} Montage local par défault monté dans:		${CCYAN}/mnt/Pre   	  	  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CGREEN}				LA VARIABLE CI DESSOUS EST DEFINIE PAR DEFAULT SUR L HOTE			  	  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}	  ${CPURPLE}VOLUMES_ROOT_PATH:${CRED} Emplacement des volumes sur l'hote:	${CCYAN}/mnt/docker	  	  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CGREEN}				VOUS POUVEZ MODIFIER TOUTES CES VARIABLES A VOTRE CONVENANCE				  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}${CEND}"
			
			# Variables par défault, peuvent être modifiée
			export MountPoint=/mnt/rclone
			export MountUnion=/mnt/Union
			export MountLocal=/mnt/Pre
			export VOLUMES_ROOT_PATH=/mnt/docker
			export PLEXDRIVE_MOUNT_POINT=/home/plexdrive

			read -rp "Voulez-vous modifier les variables ci dessus ? (o/n) : " EXCLUDE
				if [[ "$EXCLUDE" = "o" ]] || [[ "$EXCLUDE" = "O" ]]; then
					echo -e "${CCYAN}Par défault le montage crypté plexdrive est monté en clair dans le dossier /mnt/rclone ${CEND}"
					read -rp "MountPoint = " MountPoint

						if [ -n "$MountPoint" ]
						then
			 				export MountPoint
						else
			 				MountPoint=/mnt/rclone
			 				export MountPoint
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Par défault le montage unionfs est: /mnt/Union ${CEND}"
					read -rp "MountUnion = " MountUnion

						if [ -n "$MountUnion" ]
						then
							export MountUnion
						else
			 				MountUnion=/mnt/Union
			 				export MountUnion
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Par défault le montage du dossier local est : /mnt/Pre ${CEND}"
					read -rp "MountLocal = " MountLocal

						if [ -n "$MountLocal" ]
						then
			 				export MountLocal
						else
			 				MountLocal=/mnt/Pre
			 				export MountLocal
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Par défault le montage des volumes est dans : /mnt/docker ${CEND}"
					read -rp "VOLUMES_ROOT_PATH = " VOLUMES_ROOT_PATH

						if [ -n "$VOLUMES_ROOT_PATH" ]
						then
			 				export VOLUMES_ROOT_PATH
						else
			 				VOLUMES_ROOT_PATH=/mnt/docker
			 				export VOLUMES_ROOT_PATH
						fi
				fi

			clear
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CGREEN}				ORGANISATION DES DOSSIERS EN LOCAL							  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CGREEN}		Pour que Unionfs fonctionne, il faut que l'arborescence montée en local corresponde			  ${CEND}"
			echo -e "${CGREEN}		exactement à celle montée par rclone (plexdrive crypté monté en clair par rclone).			  ${CEND}"
			echo -e "${CRED}		Il est donc nécessaire de créer les mêmes dossiers que ceux existant sur Gdrive.			  ${CEND}"
			echo -e "${CCYAN}		exemple: Films ou Media/Films (sans "/" devant Media) et sans ACCENTS					  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			
			## Création des dossiers locaux pour unionfs
			mkdir -p ${VOLUMES_ROOT_PATH}
			touch ${VOLUMES_ROOT_PATH}/local.txt	
			read -rp "Taper ok pour démarrer: " EXCLUDE
			cat <<- EOF > ${VOLUMES_ROOT_PATH}/local.txt
			EOF

			if [[ "$EXCLUDE" = "ok" ]] || [[ "$EXCLUDE" = "OK" ]]; then
    			echo -e "${CCYAN}\nTapez le nom des dossiers, à la fin de chaque saisie appuyer sur la touche Entrée et taper ${CPURPLE}STOP${CEND}${CCYAN} si vous avez terminé.\n${CEND}"
    			while :
    			do		
        		read -p "" EXCLUDEPATH
        			if [[ "$EXCLUDEPATH" = "STOP" ]] || [[ "$EXCLUDEPATH" = "stop" ]]; then
            			break
        			fi
        		echo "$EXCLUDEPATH" >> ${VOLUMES_ROOT_PATH}/local.txt
    			done
			fi

			while IFS=: read user
			do
			mkdir -p ${VOLUMES_ROOT_PATH}/plexdrive/Pre/$user
			done < ${VOLUMES_ROOT_PATH}/local.txt

			FILMS=$(grep -E 'films|film|Films|FILMS|MOVIES|Movies|movies|movie|VIDEOS|VIDEO|Video|Videos' ${VOLUMES_ROOT_PATH}/local.txt | cut -d: -f2 | cut -d ' ' -f2)
			SERIES=$(grep -E 'series|TV|tv|Series|SERIES|SERIES TV|Series TV|series tv|serie tv|serie TV|series TV' ${VOLUMES_ROOT_PATH}/local.txt | cut -d: -f2 | cut -d ' ' -f2-3)
			ANIMES=$(grep -E 'ANIMES|ANIME|Animes|Anime|Animation|ANIMATION|animes|anime' ${VOLUMES_ROOT_PATH}/local.txt | cut -d: -f2 | cut -d ' ' -f2)
			MUSIC=$(grep -E 'MUSIC|Music|music|Musiques|Musique|MUSIQUE|MUSIQUES|musiques|musique' ${VOLUMES_ROOT_PATH}/local.txt | cut -d: -f2 | cut -d ' ' -f2)
			
			export FILMS
			export SERIES
			export ANIMES
			export MUSIC
			rm ${VOLUMES_ROOT_PATH}/local.txt

			clear
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}				LES VARIABLES CI DESSOUS DONT DEFINIES PAR DEFAULT				  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CRED}	${CCYAN}TRAEFIK_DASHBOARD_URL:${CRED}	traefik.${DOMAIN}	  						  ${CEND}"
			echo -e "${CRED}	${CCYAN}PLEX_FQDN:${CRED}		plex.${DOMAIN} 			  				  	  ${CEND}"
			echo -e "${CRED}	${CCYAN}EMBY_FQDN:${CRED}		emby.${DOMAIN} 							  	  ${CEND}"
			echo -e "${CRED}	${CCYAN}MEDUSA_FQDN:${CRED}		medusa.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}RTORRENT_FQDN:${CRED}		rtorrent.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}RADARR_FQDN:${CRED}		radarr.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}SONARR_FQDN:${CRED}		sonarr.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}JACKETT_FQDN:${CRED}		jackett.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}				VOUS POUVEZ MODIFIER TOUTES CES VARIABLES A VOTRE CONVENANCE				  ${CEND}"	
			echo -e "${CGREEN}				TAPER ENSUITE SUR LA TOUCHE ENTREE POUR VALIDER 					  ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"

			export PROXY_NETWORK=traefik_proxy
			export TRAEFIK_DASHBOARD_URL=traefik.${DOMAIN}
			export PLEX_FQDN=plex.${DOMAIN}
			export EMBY_FQDN=emby.${DOMAIN}
			export MEDUSA_FQDN=medusa.${DOMAIN}
			export RTORRENT_FQDN=rtorrent.${DOMAIN}
			export RADARR_FQDN=radarr.${DOMAIN}
			export SONARR_FQDN=sonarr.${DOMAIN}
			export JACKETT_FQDN=jackett.${DOMAIN}
			export WATCHER_FQDN=watcher.${DOMAIN}

			read -rp "Voulez-vous modifier les variables ci dessus ? (o/n) : " EXCLUDE
				if [[ "$EXCLUDE" = "o" ]] || [[ "$EXCLUDE" = "O" ]]; then

			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}				JUSTE SAISIR LE SOUS DOMAINE ET NON LE DOMAINE						  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"

					echo -e "${CCYAN}Sous domaine de Traefik${CEND}"
					read -rp "TRAEFIK_DASHBOARD_URL = " TRAEFIK_DASHBOARD_URL

						if [ -n "$TRAEFIK_DASHBOARD_URL" ]
						then
			 				export TRAEFIK_DASHBOARD_URL=${TRAEFIK_DASHBOARD_URL}.${DOMAIN}
						else
			 				TRAEFIK_DASHBOARD_URL=traefik.${DOMAIN}
			 				export TRAEFIK_DASHBOARD_URL
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Plex${CEND}"
					read -rp "PLEX_FQDN = " PLEX_FQDN

						if [ -n "$PLEX_FQDN" ]
						then
							export PLEX_FQDN=${PLEX_FQDN}.${DOMAIN}
						else
			 				PLEX_FQDN=plex.${DOMAIN}
			 				export PLEX_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Emby${CEND}"
					read -rp "EMBY_FQDN = " EMBY_FQDN

						if [ -n "$EMBY_FQDN" ]
						then
			 				export EMBY_FQDN=${EMBY_FQDN}.${DOMAIN}
						else
			 				EMBY_FQDN=emby.${DOMAIN}
			 				export EMBY_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Medusa${CEND}"
					read -rp "MEDUSA_FQDN = " MEDUSA_FQDN

						if [ -n "$MEDUSA_FQDN" ]
						then
			 				export MEDUSA_FQDN=${MEDUSA_FQDN}.${DOMAIN}
						else
			 				MEDUSA_FQDN=medusa.${DOMAIN}
			 				export MEDUSA_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Rtorrent${CEND}"
					read -rp "RTORRENT_FQDN = " RTORRENT_FQDN

						if [ -n "$RTORRENT_FQDN" ]
						then
			 				export RTORRENT_FQDN=${RTORRENT_FQDN}.${DOMAIN}
						else
			 				RTORRENT_FQDN=rtorrent.${DOMAIN}
			 				export RTORRENT_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Radarr${CEND}"
					read -rp "RADARR_FQDN = " RADARR_FQDN

						if [ -n "$RADARR_FQDN" ]
						then
			 				export RADARR_FQDN=${RADARR_FQDN}..${DOMAIN}
						else
			 				RADARR_FQDN=radarr.${DOMAIN}
			 				export RADARR_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Sonarr${CEND}"
					read -rp "SONARR_FQDN = " SONARR_FQDN

						if [ -n "$SONARR_FQDN" ]
						then
			 				export SONARR_FQDN=${SONARR_FQDN}.${DOMAIN}
						else
			 				SONARR_FQDN=sonarr.${DOMAIN}
			 				export SONARR_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Jackett${CEND}"
					read -rp "JACKETT_FQDN = " JACKETT_FQDN

						if [ -n "$JACKETT_FQDN" ]
						then
			 				export JACKETT_FQDN=${JACKETT_FQDN}.${DOMAIN}
						else
			 				JACKETT_FQDN=jackett.${DOMAIN}
			 				export JACKETT_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de watcher3${CEND}"
					read -rp "WATCHER_FQDN = " WATCHER_FQDN

						if [ -n "$WATCHER_FQDN" ]
						then
			 				export WATCHER_FQDN=${WATCHER_FQDN}.${DOMAIN}
						else
			 				WATCHER_FQDN=watcher.${DOMAIN}
			 				export WATCHER_FQDN
						fi

				fi

			## création d'une authentification pour rtorrent
			VAR=$(htpasswd -c /etc/apache2/.htpasswd $USERNAME 2>/dev/null)
			VAR=$(sed -e 's/\$/\$$/g' /etc/apache2/.htpasswd 2>/dev/null)
			export VAR

			## Création d'un fichier .env
			docker network create traefik_proxy 2>/dev/null
			docker network create torrent 2>/dev/null

			cat <<- EOF > /mnt/.env
			FILMS=$FILMS
			SERIES=$SERIES
			ANIMES=$ANIMES
			MUSIC=$MUSIC
			VOLUMES_ROOT_PATH=$VOLUMES_ROOT_PATH
			VAR=$VAR
			MAIL=$MAIL
			USERNAME=$USERNAME
			DOMAIN=$DOMAIN
			PLEXDRIVE_MOUNT_POINT=$PLEXDRIVE_MOUNT_POINT
			MountPoint=$MountPoint
			MountUnion=$MountUnion
			MountLocal=$MountLocal
			RemotePath=$RemotePath
			RemoteLocal=$RemoteLocal
			PROXY_NETWORK=$PROXY_NETWORK
			TRAEFIK_DASHBOARD_URL=$TRAEFIK_DASHBOARD_URL
			PLEX_FQDN=$PLEX_FQDN
			EMBY_FQDN=$EMBY_FQDN
			MEDUSA_FQDN=$MEDUSA_FQDN
			RTORRENT_FQDN=$RTORRENT_FQDN
			RADARR_FQDN=$RADARR_FQDN
			SONARR_FQDN=$SONARR_FQDN
			JACKETT_FQDN=$JACKETT_FQDN
			WATCHER_FQDN=$WATCHER_FQDN
			EOF

			## Création d'un fichier traefik.toml
			mkdir -p ${VOLUMES_ROOT_PATH}/traefik
			cat <<- EOF > ${VOLUMES_ROOT_PATH}/traefik/traefik.toml
			defaultEntryPoints = ["https","http"]

			[api]
			entryPoint = "traefik"
			dashboard = true

			[entryPoints]
			  [entryPoints.http]
			  address = ":80"
			    [entryPoints.http.redirect]
			    entryPoint = "https"
			  [entryPoints.https]
			  address = ":443"
			    [entryPoints.https.tls]
			    minVersion = "VersionTLS12"
			    cipherSuites = [
			      "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
			      "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
			      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
			      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
			      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
			      "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA"
			    ]
			  [entryPoints.traefik]
			  address = ":8080"

			[acme]
			email = "${MAIL}"
			storage = "/etc/traefik/acme/acme.json"
			entryPoint = "https"
			onHostRule = true
			onDemand = false
			  [acme.httpChallenge]
			  entryPoint = "http"

			[docker]
			endpoint = "unix:///var/run/docker.sock"
			domain = "${DOMAIN}"
			watch = true
			exposedbydefault = false
			EOF
						
			## creation du docker-compose personnalisé dans lequel viendront s'incrémenter les variables du fichier .envt
			cat <<- EOF > /mnt/docker-compose.yml
			version: '3'
			services:

			  traefik:
			    image: traefik
			    container_name: traefik
			    restart: unless-stopped
			    hostname: traefik
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${TRAEFIK_DASHBOARD_URL}
			      - traefik.port=8080
			      - traefik.docker.network=${PROXY_NETWORK}
			    volumes:
			      - /var/run/docker.sock:/var/run/docker.sock:ro  
			      - ${VOLUMES_ROOT_PATH}/traefik/traefik.toml:/traefik.toml:ro
			      - ${VOLUMES_ROOT_PATH}/letsencrypt/certs:/etc/traefik/acme:rw
			    ports:
			      - "80:80"
			      - "443:443"
			    networks:
			      - proxy

			  plexdrive:
			    container_name: plexdrive
			    image: laster13/plexdrive-rclone
			    restart: unless-stopped
			    cap_add:
			      - SYS_ADMIN
			      - MKNOD
			    privileged: true
			    devices:
			      - /dev/fuse
			    security_opt:
			      - apparmor:unconfined
			    environment:
			      - RemotePath=${RemotePath}
			      - RemoteLocal=${RemoteLocal}
			      - MountUnion=${MountUnion}
			      - MountLocal=${MountLocal}
			      - MountPoint=${MountPoint}
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone:/root/.config/rclone
			      - ${VOLUMES_ROOT_PATH}/plexdrive/config:/config
			      - ${VOLUMES_ROOT_PATH}/plexdrive/Union:${MountUnion}:shared
			      - ${VOLUMES_ROOT_PATH}/plexdrive/Pre:${MountLocal}:shared
			      - ${VOLUMES_ROOT_PATH}/plexdrive/rclone:${MountPoint}:shared
			      - ${VOLUMES_ROOT_PATH}/plexdrive/crypte:${PLEXDRIVE_MOUNT_POINT}:shared
			    networks:
			      - proxy

			  plex:
			    container_name: plex
			    image: laster13/plex
			    restart: unless-stopped
			    hostname: plex
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${PLEX_FQDN}
			      - traefik.port=32400
			      - traefik.docker.network=${PROXY_NETWORK}
			    healthcheck:
			      disable: true
			    environment:
			      - MountUnion=${MountUnion}
			      - MountLocal=${MountLocal}
			      - MountPoint=${MountPoint}
			      - TZ=Europe/Paris
			      - PLEX_CLAIM=
			      - PLEX_UID=0
			      - PLEX_GID=0
			    ports:
			      - 32400:32400
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/plexdrive/Union:${MountUnion}:shared
			      - ${VOLUMES_ROOT_PATH}/plex/config:/config
			      - /dev/shm:/transcode
			    networks:
			      - proxy

			  emby:
			    container_name: emby
			    image: emby/embyserver
			    restart: unless-stopped
			    hostname: emby
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${EMBY_FQDN}
			      - traefik.port=8096
			      - traefik.docker.network=${PROXY_NETWORK}
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/plexdrive/Union:${MountUnion}:shared
			      - ${VOLUMES_ROOT_PATH}/plex/Pre:${MountLocal}:shared
			      - ${VOLUMES_ROOT_PATH}/emby/config:/config:rw
			      - /etc/localtime:/etc/localtime:ro
			    environment:
			      - MountUnion=${MountUnion}
			      - MountLocal=${MountLocal}
			      - MountPoint=${MountPoint}
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    networks:
			      - proxy

			  sonarr:
			    container_name: sonarr
			    image: linuxserver/sonarr
			    restart: unless-stopped
			    hostname: sonarr
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${SONARR_FQDN}
			      - traefik.port=8989
			      - traefik.docker.network=${PROXY_NETWORK}
			    environment:
			      - /etc/localtime:/etc/localtime:ro
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/sonarr/config:/config
			      - ${VOLUMES_ROOT_PATH}/rutorrent/downloads:/downloads
			      - ${VOLUMES_ROOT_PATH}/plexdrive/Union/${SERIES}:/tv
			    networks:
			      - proxy

			  radarr:
			    container_name: radarr
			    image: linuxserver/radarr
			    restart: unless-stopped
			    hostname: radarr
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${RADARR_FQDN}
			      - traefik.port=7878
			      - traefik.docker.network=${PROXY_NETWORK}
			    environment:
			      - /etc/localtime:/etc/localtime:ro
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/radarr/config:/config
			      - ${VOLUMES_ROOT_PATH}/rutorrent/downloads:/downloads
			      - ${VOLUMES_ROOT_PATH}/plexdrive/Union/${FILMS}:/movies
			    networks:
			      - proxy

			  watcher:
			    image: linuxserver/watcher
			    container_name: watcher
			    restart: unless-stopped
			    hostname: watcher
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${WATCHER_FQDN}
			      - traefik.port=9090
			      - traefik.docker.network=${PROXY_NETWORK}
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/plexdrive/Union/${FILMS}:/movies
			      - ${VOLUMES_ROOT_PATH}/rutorrent/downloads:/downloads
			      - ${VOLUMES_ROOT_PATH}/watcher/config:/config
			    environment:
			      - /etc/localtime:/etc/localtime:ro
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    networks:
			      - proxy

			  medusa:
			    image: linuxserver/medusa
			    container_name: medusa
			    restart: unless-stopped
			    hostname: medusa
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${MEDUSA_FQDN}
			      - traefik.port=8081
			      - traefik.docker.network=${PROXY_NETWORK}
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/plexdrive/Union/${SERIES}:/tv
			      - ${VOLUMES_ROOT_PATH}/rutorrent/downloads:/downloads
			      - ${VOLUMES_ROOT_PATH}/medusa/config:/config
			    environment:
			      - /etc/localtime:/etc/localtime:ro
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    networks:
			      - proxy
				  
			  torrent:
			    container_name: torrent
			    image: xataz/rtorrent-rutorrent
			    restart: unless-stopped
			    hostname: torrent
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${RTORRENT_FQDN}
			      - traefik.port=8080
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    environment:
			      - UID=1001
			      - GID=1001
			      - DHT_RTORRENT=on
			      - PORT_RTORRENT=6881
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/rutorrent/downloads:/data/torrents
			      - ${VOLUMES_ROOT_PATH}/rutorrent/data:/data
			      - ${VOLUMES_ROOT_PATH}/rutorrent/config:/config
			    networks:
			      - torrent
			      - proxy

			  jackett:
			    container_name: jackett
			    image: xataz/jackett
			    restart: unless-stopped
			    hostname: jackett
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${JACKETT_FQDN}
			      - traefik.port=9117
			      - traefik.docker.network=${PROXY_NETWORK}
			    ports:
			      - 9117:9117
			    environment:
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/Jackett/config:/config
			      - ${VOLUMES_ROOT_PATH}/Jackett/downloads:/downloads
			    networks:
			      - proxy

			networks:
			  torrent:
			  proxy:
			    external:
			      name: ${PROXY_NETWORK}
			EOF

			clear
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}					VERIFICATION DE LA CONFORMITE DU DOCKER-COMPOSE					  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			read -p "Appuyer sur la touche Entrer pour continuer"
			nano /mnt/docker-compose.yml
			progress-bar 20
			cd /mnt
			docker-compose up -d plexdrive traefik 2>/dev/null
			echo ""
			echo -e "${CCYAN}La configuration des variables s'est parfaitement déroulée ${CEND}"
			echo ""
			read -p "Appuyer sur la touche Entrer pour continuer"
			seedbox.sh
		;;

		3)
			clear
			export $(xargs </mnt/.env)
			logo.sh
			echo -e "${CGREEN}----------------------------${CEND}"
			echo -e "${CCYAN}  CONFIGURATION DE RCLONE    ${CEND}"
			echo -e "${CGREEN}----------------------------${CEND}"
			echo ""
			echo -e "${CGREEN}   1) Tentative de récupération ${CCYAN}"rclone.conf"${CGREEN} à partir du serveur ${CEND}"
			echo -e "${CGREEN}   2) Edition d'un fichier rclone.conf ${CEND}"
			echo -e "${CGREEN}   3) Configuration rclone.conf à partir de l'utilitaire ${CRED}rclone config${CGREEN}${CEND}"
			echo -e "${CGREEN}   4) Retour au menu principal ${CEND}"
			until [[ "$RCLONE" =~ ^[1-4]$ ]]; do
			echo ""
			read -p "rclone choix [1-4]: " -e -i 1 RCLONE
			done
			case $RCLONE in
				1) ## recherche fichier rclone.conf déjà présent sur le serveur
				var=$(ls -a ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone/ 2>/dev/null | sed -e "/\.$/d" | wc -l )
				progress-bar 20
				echo ""
      				RESULTAT=$(find /root/.config/rclone -name rclone.conf 2>/dev/null)

					if [ -z "$RESULTAT" ]
					then
						echo -e "${CCYAN}Pas de fichier rclone.conf trouvé${CEND}"
						progress-bar 20
						echo ""

					elif [ "$var" -eq 0 ]
					then
						DEST=${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone/
      						cp $RESULTAT ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone 2>/dev/null
						echo -e "${CRED}------------------------------------------------------------------------------------------------------------------------${CEND}"
						echo -e "${CCYAN}  Les fichiers de configuration ont bien été transférés vers le dossier $DEST						${CEND}"
						echo -e "${CRED}------------------------------------------------------------------------------------------------------------------------${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour retourner au menu principal"

					else
						echo ""
						echo -e "${CCYAN}Le fichier rclone.conf est déjà présent dans ${VOLUMES_ROOT_PATH}/plexdrive/.config/rclone .. Veuillez vérifier${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour continuer"
					fi

				seedbox.sh
				;;

				2) ## éditer un fichier rclone.conf
				var=$(ls -a ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone/ 2>/dev/null | sed -e "/\.$/d" | wc -l)

				if [ "$var" -ne 0 ]
				then
					progress-bar 20
					echo ""
					echo -e "${CCYAN}Le fichier rclone.conf est déjà présent dans ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone .. Veuillez vérifier${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour revenir au menu principal"
					seedbox.sh
				fi
				echo ""
				read -rp "Voulez-vous créer un fichier de configuration rclone.conf ? (o/n) : " EXCLUDE
				cat <<- EOF >> ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone/rclone.conf
				EOF

				if [[ "$EXCLUDE" = "o" ]] || [[ "$EXCLUDE" = "O" ]]; then
    				echo -e "${CCYAN}\nColler votre configuration avec le clic droit, à la fin de la saisie appuyer sur la touche Entrée et Taper ${CPURPLE}STOP${CEND}${CCYAN} pour poursuivre le script.\n${CEND}"
    				while :
    				do		
        			read -p "" EXCLUDEPATH
        				if [[ "$EXCLUDEPATH" = "STOP" ]] || [[ "$EXCLUDEPATH" = "stop" ]]; then
            				break
        				fi
        				echo "$EXCLUDEPATH" >> ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone/rclone.conf
    				done
				else
					seedbox.sh
				fi
				
				echo ""
				progress-bar 20
				echo ""
				echo -e "${CCYAN}Le fichier rclone.conf a été créé avec succés${CEND}"
				echo ""
				read -p "Appuyer sur la touche Entrer pour revenir au menu principal"
				seedbox.sh
				;;

				3) ## création d'un nouveau rclone.conf
				var=$(ls -a ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone/ 2>/dev/null | sed -e "/\.$/d" | wc -l)

				if [ "$var" -ne 0 ]
				then
					progress-bar 20
					echo ""
					echo -e "${CCYAN}Le fichier rclone.conf est déjà présent ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/rclone .. Veuillez vérifier${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour revenir au menu principal"
					seedbox.sh

				else
					docker exec -ti plexdrive rclone config
					echo -e "${CCYAN}Le fichier rclone.conf a été créé avec succés${CEND}"
					read -p "Appuyer sur la touche Entrer pour revenir au menu principal"
					seedbox.sh

				fi

				;;

				4)
				seedbox.sh

				;;

			esac
		;;

		4)
			clear
			logo.sh
			export $(xargs </mnt/.env)
			echo ""
			echo -e "${CRED}-----------------------------------${CEND}"
			echo -e "${CCYAN}  CONFIGURATION Plexdrive V-5.0.0 ${CEND}"
			echo -e "${CRED}-----------------------------------${CEND}"
			echo ""
			echo -e "${CGREEN}   1) Création de la configuration plexdrive avec ${CRED}rclone config${CGREEN}${CEND}"
			echo -e "${CGREEN}   2) Retour menu principal ${CEND}"
			until [[ "$PLEXDRIVE" =~ ^[1-2]$ ]]; do
			echo ""
			read -p "plexdrive choix [1-2]: " -e -i 1 PLEXDRIVE
			done

			case $PLEXDRIVE in
				1) ## création des fichiers plexdrive
					RESULT1=$(ls -a ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/.plexdrive/ 2>/dev/null | sed -e "/\.$/d" | wc -l)

					if [ "$RESULT1" -ne 0 ]
					then
						progress-bar 20
						echo ""
						echo -e "${CCYAN}Les fichiers de configuration sont déjà présents dans ${VOLUMES_ROOT_PATH}/plexdrive/config/.config/.plexdrive .. Veuillez vérifier${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour revenir au menu principal"
						seedbox.sh
					else
						echo -e "${CRED}--------------------------------------------------------------${CEND}"
						echo -e "${CCYAN}  Une fois le token rentré, APPUYER SUR CTRL-C   ${CEND}"
						echo -e "${CCYAN}  Nul besoin d'attendre la fin de création des fichiers      ${CEND}"
						echo -e "${CRED}--------------------------------------------------------------${CEND}"
						trap "echo Vous avez appuyé sur les touches CTRL-C - poursuite du script" 2
						echo ""
						docker exec -i plexdrive sh -c "plexdrive mount -c /config/.config/.plexdrive --cache-file=/config/.config/.plexdrive/cache.bolt -o allow_other /home/plexdrive"
						echo ""
						echo ""

						# Vérification des montages
						setterm -cursor off
						var=$(docker exec plexdrive ls -a ${MountPoint} 2>/dev/null | sed -e "/\.$/d" | wc -l)

						while [ $var -eq 0 ]; do
							for (( i=0;i<=5;i++))
							do
							echo -en "\033[1A"
							echo -en "\033[0;92mLes configurations de plexdrive/rclone/unionfs sont en cours, veuillez patienter 1mn environ ...\033[0m\n";
							sleep 1s;
							echo -en "\033[1A"
							echo -en "                                                                                                        \n";                                                                         
							sleep 0.6s;
							done
							echo -en "                                                                                                        \n";
							echo -en "\033[1A"
							var=$(docker exec plexdrive ls -a ${MountPoint} 2>/dev/null | sed -e "/\.$/d" | wc -l)
							docker exec -ti plexdrive s6-svc -t /var/run/s6/services/rclone 2>/dev/null
						done

						echo -e "${CCYAN}La configuration de Plexdrive est terminée, tous les montages sont vérifiés et fonctionnels${CEND}"
						setterm -cursor on
						echo ""
						cd /mnt
						docker-compose restart plexdrive 2>/dev/null
						read -p "Appuyer sur la touche Entrer pour revenir au menu principal"
						seedbox.sh
				fi

				;;

				2)
				seedbox.sh

				;;

			esac

		;;

		5)
			clear
			logo.sh	
			export $(xargs </mnt/.env)
			cd /mnt
			APPLI=""
			sortir=false
			while [ !sortir ]
			do
			echo ""
			echo -e "${CRED}-----------------${CEND}"
			echo -e "${CCYAN}  APPLICATIONS  ${CEND}"
			echo -e "${CRED}-----------------${CEND}"
			echo ""
			echo -e "${CGREEN}   1) Plex ${CEND}"
			echo -e "${CGREEN}   2) Emby ${CEND}"
			echo -e "${CGREEN}   3) Rtorrent ${CEND}"
			echo -e "${CGREEN}   4) Sonarr ${CEND}"
			echo -e "${CGREEN}   5) Medusa ${CEND}"
			echo -e "${CGREEN}   6) Radarr ${CEND}"
			echo -e "${CGREEN}   7) Watcher ${CEND}"
			echo -e "${CGREEN}   8) Jackett ${CEND}"
			echo -e "${CGREEN}   9) Retour Menu Principal ${CEND}"
			echo ""
			read -p "Appli choix [1-8]: " -e -i 1 APPLI
			echo ""			
			case $APPLI in
				1)
				# Vérification du montage rclone avec le remote crypté plexdrive et lancement applis
				MPOINT=${VOLUMES_ROOT_PATH}/plexdrive/rclone

				if mountpoint -q ${MPOINT}; then

					if ps -e | grep -q Plex; then
						echo -e "${CGREEN}Plex est déjà lancé${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour retourner au menu"
						clear
						logo.sh
					else
						# CLAIM pour Plex
						echo ""
						echo -e "${CCYAN}Un token est nécéssaire pour AUTHENTIFIER le serveur Plex ${CEND}"
						echo -e "${CCYAN}Pour obtenir un identifiant CLAIM, allez à cette adresse et copier le dans le terminal ${CEND}"
						echo -e "${CRED}https://www.plex.tv/claim/ ${CEND}"
						echo ""
						read -rp "CLAIM = " CLAIM

						if [ -n "$CLAIM" ]
						then
							sed -i -e "s/PLEX_CLAIM=/PLEX_CLAIM=${CLAIM}/g" /mnt/docker-compose.yml
						fi

						## Lancement de Plex
						docker-compose up -d plex 2>/dev/null
						echo ""
						echo -e "${CGREEN}IMPORTANT${CCYAN}: Les noms de bibliothèques doivent être identiques à ceux des dossiers créés pour Unionfs ${CGREEN}(SANS ACCENTS)${CEND}"
						progress-bar 20
						echo ""
						echo -e "${CGREEN}Installation de Plex réussie${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour continuer"
						clear
						logo.sh
					fi

				else
					echo -e "${CGREEN}IMPORTANT${CCYAN}: rclone n'est pas monté, vérifiez votre configuration ${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh

				fi

				;;

				2)
				MPOINT=${VOLUMES_ROOT_PATH}/plexdrive/rclone

				if mountpoint -q ${MPOINT}; then

					if docker ps -a | grep -q emby; then
						echo -e "${CGREEN}Emby est déjà lancé${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour retourner au menu"
						clear
						logo.sh
					else
						docker-compose up -d emby 2>/dev/null
						echo ""
						progress-bar 20
						echo ""
						echo -e "${CGREEN}Installation de Emby réussie${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour continuer"
						clear
						logo.sh
					fi

				else
					echo -e "${CGREEN}IMPORTANT${CCYAN}: rclone n'est pas monté, vérifiez votre configuration ${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh

				fi

				;;

				3)
				if docker ps -a | grep -q torrent; then
					echo -e "${CGREEN}rtorrent est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d torrent
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de Rtorrent réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				4)
				MPOINT=${VOLUMES_ROOT_PATH}/plexdrive/rclone

				if mountpoint -q ${MPOINT}; then

					if docker ps -a | grep -q sonarr; then
						echo -e "${CGREEN}Sonarr est déjà lancé${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour retourner au menu"
						clear
						logo.sh
					else
						docker-compose up -d sonarr 2>/dev/null
						progress-bar 20
						echo ""
						echo -e "${CGREEN}Installation de Sonarr réussie${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour continuer"
						clear
						logo.sh
					fi

				else
					echo -e "${CGREEN}IMPORTANT${CCYAN}: rclone n'est pas monté, vérifiez votre configuration ${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh

				fi

				;;

				5)
				MPOINT=${VOLUMES_ROOT_PATH}/plexdrive/rclone

				if mountpoint -q ${MPOINT}; then

					if docker ps -a | grep -q medusa; then
						echo -e "${CGREEN}Medusa est déjà lancé${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour retourner au menu"
						clear
						logo.sh
					else
						docker-compose up -d medusa 2>/dev/null
						progress-bar 20
						echo ""
						echo -e "${CGREEN}Installation de medusa réussie${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour continuer"
						clear
						logo.sh
					fi

				else
					echo -e "${CGREEN}IMPORTANT${CCYAN}: rclone n'est pas monté, vérifiez votre configuration ${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh

				fi

				;;

				6)
				MPOINT=${VOLUMES_ROOT_PATH}/plexdrive/rclone

				if mountpoint -q ${MPOINT}; then

					if docker ps -a | grep -q radarr; then
						echo -e "${CGREEN}Radarr est déjà lancé${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour retourner au menu"
						clear
						logo.sh
					else
						docker-compose up -d radarr 2>/dev/null
						progress-bar 20
						echo ""
						-e "${CGREEN}Installation de Radarr réussie${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour continuer"
						clear
						logo.sh
					fi

				else
					echo -e "${CGREEN}IMPORTANT${CCYAN}: rclone n'est pas monté, vérifiez votre configuration ${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh

				fi

				;;

				7)
				MPOINT=${VOLUMES_ROOT_PATH}/plexdrive/rclone

				if mountpoint -q ${MPOINT}; then

					if docker ps -a | grep -q watcher; then
						echo -e "${CGREEN}Watcher est déjà lancé${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour retourner au menu"
						clear
						logo.sh
					else
						docker-compose up -d watcher 2>/dev/null
						progress-bar 20
						echo ""
						echo -e "${CGREEN}Installation de Watcher réussie${CEND}"
						echo ""
						read -p "Appuyer sur la touche Entrer pour continuer"
						clear
						logo.sh
					fi

				else
					echo -e "${CGREEN}IMPORTANT${CCYAN}: rclone n'est pas monté, vérifiez votre configuration ${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh

				fi

				;;


				8)
				if docker ps -a | grep -q jackett; then
					echo -e "${CGREEN}Jackett est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d jackett
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de Jackett réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				9)
				sortir=true
				seedbox.sh

				;;

			esac
			done

		;;

		6)	
			export $(xargs </mnt/.env)
			clear
			logo.sh
			CONFIG=""
			sortir=false
			while [ !sortir ]
			do
			echo -e "${CRED}------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}  CONFIGURATION PLEX_AUTOSCAN - UNIONFS_CLEANER - PLEX_DUPEFINDER${CEND}"
			echo -e "${CRED}------------------------------------------------------------------${CEND}"
			echo ""
			echo -e "${CGREEN}   1) plex_autoscan (Plex) ${CEND}"
			echo -e "${CGREEN}   2) unionfs_cleaner (Plex et Emby) ${CEND}"
			echo -e "${CGREEN}   3) plex_dupefinder (Plex) ${CEND}"
			echo -e "${CGREEN}   4) Retour Menu Principal ${CEND}"
			echo ""
			read -p "Config choix [1-4]: " -e -i 1 CONFIG
			case $CONFIG in
				1)
				## Récupération du token de plex
				docker exec -ti plex grep -E -o "PlexOnlineToken=.{0,22}" /config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml > ${VOLUMES_ROOT_PATH}/plex/token.txt
				TOKEN=$(grep PlexOnlineToken ${VOLUMES_ROOT_PATH}/plex/token.txt | cut -d '=' -f2 | cut -c2-21)
				export TOKEN

				## configuration plex_autoscan
				cd ${VOLUMES_ROOT_PATH}/plex/config/plex_autoscan
				docker exec plex /plex_autoscan/scan.py sections
				sed -i 's/\/var\/lib\/plexmediaserver/\/config/g' config.json
				docker exec -ti plex /plex_autoscan/scan.py sections >plex.log

				for i in `seq 1 50`;
				do
   					var=$(grep "$i: " plex.log | cut -d: -f2 | cut -d ' ' -f2-3)
   					if [ -n "$var" ]
   					then
     					echo "$i" "$var"
   					fi 
				done > categories.log

				ID_FILM=$(grep -E 'films|film|Films|FILMS|MOVIES|Movies|movies|movie|VIDEOS|VIDEO|Video|Videos' categories.log | cut -d: -f1 | cut -d ' ' -f1)
				ID_SERIE=$(grep -E 'series|TV|tv|Series|SERIES|SERIES TV|Series TV|series tv|serie tv|serie TV|series TV' categories.log | cut -d: -f1 | cut -d ' ' -f1)
				ID_ANIME=$(grep -E 'ANIMES|ANIME|Animes|Anime|Animation|ANIMATION|animes|anime' categories.log | cut -d: -f1 | cut -d ' ' -f1)
				ID_MUSIC=$(grep -E 'MUSIC|Music|music|Musiques|Musique|MUSIQUE|MUSIQUES|musiques|musique' categories.log | cut -d: -f1 | cut -d ' ' -f1)

				cat <<- EOF >> /mnt/.env
				ID_FILM=$ID_FILM
				ID_SERIE=$ID_SERIE
				ID_ANIME=$ID_ANIME
				ID_MUSIC=$ID_MUSIC
				EOF

				cat <<- EOF > ${VOLUMES_ROOT_PATH}/plex/config/plex_autoscan/config.json
				{
				  "DOCKER_NAME": "plex",
				  "GDRIVE": {
				    "CLIENT_ID": "",
				    "CLIENT_SECRET": "",
				    "ENABLED": false,
				    "POLL_INTERVAL": 60,
				    "SCAN_EXTENSIONS":[
				      "webm","mkv","flv","vob","ogv","ogg","drc","gif",
				      "gifv","mng","avi","mov","qt","wmv","yuv","rm",
				      "rmvb","asf","amv","mp4","m4p","m4v","mpg","mp2",
				      "mpeg","mpe","mpv","m2v","m4v","svi","3gp","3g2",
				      "mxf","roq","nsv","f4v","f4p","f4a","f4b","mp3",
				      "flac","ts"
				  ]
				  },
				  "PLEX_ANALYZE_DIRECTORY": true,
				  "PLEX_ANALYZE_TYPE": "basic",
				  "PLEX_DATABASE_PATH": "/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db",
				  "PLEX_EMPTY_TRASH": false,
				  "PLEX_EMPTY_TRASH_CONTROL_FILES": [
				    "${MountUnion}/mounted.bin"
				  ],
				  "PLEX_EMPTY_TRASH_MAX_FILES": 100,
				  "PLEX_EMPTY_TRASH_ZERO_DELETED": true,
				  "PLEX_LD_LIBRARY_PATH": "/usr/lib/plexmediaserver",
				  "PLEX_LOCAL_URL": "http://localhost:32400",
				  "PLEX_SCANNER": "/usr/lib/plexmediaserver/Plex\\\ Media\\\ Scanner",
				  "PLEX_SECTION_PATH_MAPPINGS": {
				    "${ID_FILM}": [
				      "/${FILMS}/"
				    ],
				    "${ID_SERIE}": [
				      "/${SERIES}/"
				    ],
				    "${ID_ANIME}": [
				      "/${ANIMES}/"
				    ],
				    "${ID_MUSIC}": [
				      "/${MUSIC}/"
				    ]
				  },
				  "PLEX_SUPPORT_DIR": "/config/Library/Application\\\ Support",
				  "PLEX_TOKEN": "${TOKEN}",
				  "PLEX_USER": "root",
				  "PLEX_WAIT_FOR_EXTERNAL_SCANNERS": true,
				  "RCLONE_RC_CACHE_EXPIRE": {
				    "ENABLED": false,
				    "MOUNT_FOLDER": "/mnt/rclone",
				    "RC_URL": "http://localhost:5572"
				  },
				  "RUN_COMMAND_BEFORE_SCAN": "",
				  "SERVER_ALLOW_MANUAL_SCAN": true,
				  "SERVER_FILE_EXIST_PATH_MAPPINGS": {
				  },
				  "SERVER_IGNORE_LIST": [
				    "/.grab/",
				    ".DS_Store",
				    "Thumbs.db"
				  ],
				  "SERVER_IP": "plex",
				  "SERVER_MAX_FILE_CHECKS": 10,
				  "SERVER_PASS": "9c4b81fe234e4d6eb9011cefe514d915",
				  "SERVER_PATH_MAPPINGS": {
				      "${MountUnion}/${FILMS}/": [
				          "/movies/"
				      ],
				      "${MountUnion}/${SERIES}/": [
				          "/tv/"
				      ],
				      "${MountUnion}/${ANIMES}/": [
				          "/animes/"
				      ],
				      "${MountUnion}/${MUSIC}/": [
				          "/music/"
				      ]
				  },
				  "SERVER_PORT": 3468,
				  "SERVER_SCAN_DELAY": 1,
				  "SERVER_SCAN_FOLDER_ON_FILE_EXISTS_EXHAUSTION": false,
				  "SERVER_SCAN_PRIORITIES": {
				    "1": [
				      "/${FILMS}/"
				    ],
				    "2": [
				      "/${SERIES}/"
				    ],
				    "3": [
				      "/${ANIMES}/"
				    ],
				    "4": [
				      "/${MUSIC}/"
				    ]
				  },
				  "SERVER_USE_SQLITE": false,
				  "USE_DOCKER": false,
				  "USE_SUDO": false
				}
				EOF

				echo ""
				nano ${VOLUMES_ROOT_PATH}/plex/config/plex_autoscan/config.json
				progress-bar 20
				echo ""
				docker exec -ti plex s6-svc -t /var/run/s6/services/plex_autoscan
				echo -e "${CCYAN}La configuration de plex_autoscan s'est déroulée avec succés${CEND}"
				cd ${VOLUMES_ROOT_PATH}/plex/config/plex_autoscan/
				echo ""
				read -p "Appuyer sur la touche Entrer pour continuer"
				clear
				logo.sh

				;;

				2)
				export $(xargs </mnt/.env)
				cat <<- EOF > ${VOLUMES_ROOT_PATH}/plexdrive/config/unionfs_cleaner/config.json
				{
				    "cloud_folder": "${MountPoint}",
				    "dry_run": false,
				    "du_excludes": [],
				    "local_folder": "${MountLocal}",
				    "local_folder_check_interval": 1,
				    "local_folder_size": 1,
				    "local_remote": "${RemoteLocal}",
				    "lsof_excludes": [
				        ".partial~"
				    ],
				    "pushover_app_token": "$",
				    "pushover_user_token": "",
				    "rclone_bwlimit": "",
				    "rclone_checkers": 16,
				    "rclone_chunk_size": "8M",
				    "rclone_excludes": [
				        "**partial~",
				        "**_HIDDEN",
				        ".unionfs/**",
				        ".unionfs-fuse/**"
				    ],
				    "rclone_remove_empty_on_upload": {
				        "${MountLocal}/${FILMS}": 1,
				        "${MountLocal}/${SERIES}": 1
				    },
				    "rclone_transfers": 8,
				    "remote_folder": "${RemoteLocal}",
				    "slack_webhook_url": "",
				    "unionfs_folder": "${MountLocal}/.unionfs-fuse",
				    "use_config_manager": false,
				    "use_git_autoupdater": true,
				    "use_upload_manager": true
				}
				EOF

				nano ${VOLUMES_ROOT_PATH}/plexdrive/config/unionfs_cleaner/config.json
				clear
				echo -e "${CCYAN}La configuration de unionfs_cleaner s'est déroulée avec succés${CEND}"
				echo ""
				read -p "Appuyer sur la touche Entrer pour continuer"
				logo.sh
				;;

				3)
				export $(xargs </mnt/.env)
				## Récupération du token de plex
				docker exec -ti plex grep -E -o "PlexOnlineToken=.{0,22}" /config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml > ${VOLUMES_ROOT_PATH}/plex/token.txt
				TOKEN=$(grep PlexOnlineToken ${VOLUMES_ROOT_PATH}/plex/token.txt | cut -d '=' -f2 | cut -c2-21)
				export TOKEN

				## Configuration du config.json		
				rm -rf ${VOLUMES_ROOT_PATH}/plex/config/plex_dupefinder/config.json
				cat <<- EOF >> ${VOLUMES_ROOT_PATH}/plex/config/plex_dupefinder/config.json
				{
				  "AUDIO_CODEC_SCORES": {
				    "Unknown": 0,
				    "aac": 1000,
				    "ac3": 1000,
				    "dca": 2000,
				    "dca-ma": 4000,
				    "eac3": 1250,
				    "flac": 2500,
				    "mp2": 500,
				    "mp3": 1000,
				    "pcm": 2500,
				    "truehd": 4500,
				    "wmapro": 200
				  },
				  "AUTO_DELETE": true,
				  "FILENAME_SCORES": {
				    "*.avi": -1000,
				    "*.ts": -1000,
				    "*.vob": -5000,
				    "*1080p*BluRay*": 15000,
				    "*720p*BluRay*": 10000,
				    "*HDTV*": -1000,
				    "*PROPER*": 1500,
				    "*REPACK*": 1500,
				    "*Remux*": 20000,
				    "*WEB*CasStudio*": 5000,
				    "*WEB*KINGS*": 5000,
				    "*WEB*NTB*": 5000,
				    "*WEB*QOQ*": 5000,
				    "*WEB*SiGMA*": 5000,
				    "*WEB*TBS*": -1000,
				    "*WEB*TROLLHD*": 2500,
				    "*WEB*VISUM*": 5000,
				    "*dvd*": -1000
				  },
				  "PLEX_SECTIONS": {
				    "${FILMS}": ${ID_FILM},
				    "${SERIES}": ${ID_SERIE}

				  },
				  "PLEX_SERVER": "http://plex:32400",
				  "PLEX_TOKEN": "${TOKEN}",
				  "SCORE_FILESIZE": true,
				  "SKIP_LIST": [],
				  "VIDEO_CODEC_SCORES": {
				    "Unknown": 0,
				    "h264": 10000,
				    "h265": 5000,
				    "hevc": 5000,
				    "mpeg1video": 250,
				    "mpeg2video": 250,
				    "mpeg4": 500,
				    "msmpeg4": 100,
				    "msmpeg4v2": 100,
				    "msmpeg4v3": 100,
				    "vc1": 3000,
				    "vp9": 1000,
				    "wmv2": 250,
				    "wmv3": 250
				  },
				  "VIDEO_RESOLUTION_SCORES": {
				    "1080": 10000,
				    "480": 3000,
				    "4k": 20000,
				    "720": 5000,
				    "Unknown": 0,
				    "sd": 1000
				  }
				}
			EOF

			nano ${VOLUMES_ROOT_PATH}/plex/config/plex_dupefinder/config.json
			clear
			echo ""
			echo -e "${CCYAN}La configuration de plex_dupefinder s'est déroulée avec succés${CEND}"
			echo ""
			read -p "Appuyer sur la touche Entrer pour continuer"
			logo.sh

			;;

				4)
				sortir=true
				seedbox.sh

				;;

			esac
			done

			;;

		7)	
			clear
			logo.sh
			export $(xargs </mnt/.env)
			CONFIG=""
			sortir=false
			while [ !sortir ]
			do
			echo -e "${CCYAN}----------------------------------${CEND}"
			echo -e "${CCYAN}  	SAUVEGARDE DES VOLUMES	   ${CEND}"
			echo -e "${CCYAN}----------------------------------${CEND}"
			echo ""
			echo -e "${CGREEN}   1) Installation Borg ${CEND}"
			echo -e "${CGREEN}   2) Configuration de la sauvegarde programmée${CEND}"
			echo -e "${CGREEN}   3) Retour Menu Principal ${CEND}"
			echo ""
			read -p "Sauve choix [1-3]: " -e -i 1 SAUVE

			case $SAUVE in
				1)
				#Installation Borg
				cd /tmp
				wget https://github.com/borgbackup/borg/releases/download/1.1.7/borg-linux64
				mv borg-linux64 /usr/local/bin/borg
				chmod a+x /usr/local/bin/borg

				;;

				2)
				# Définition des variables
				echo ""
				echo -e "${CCYAN}Préciser le chemin de la sauvegarde ${CEND}"
				read -rp "Repo = " Repo
				export Repo
				mkdir -p $Repo

				# Initialisation du repo
				borg init -e repokey $Repo
				echo ""
			   	echo -e "${CCYAN}Veuillez à nouveau retaper la passphrase ${CEND}"
				echo ""
				read -rp "Passphrase = " Passphrase
				export Passphrase
				mkdir /root/.borg
				cat <<- EOF >> /root/.borg/passphrase
				$Passphrase 
				EOF

				chmod 700 /root/.borg/passphrase
				Backup=$(date +%Y-%m-%d)
				export Backup
				echo ""
				read -rp "Voulez-vous exclure des dossiers de la sauvegarde ? (o/n) : " EXCLUDE
				echo ""
				cat <<- EOF >> /root/.borg/exclusions
				## 1 chemin par ligne 
				## exemple ${VOLUMES_ROOT_PATH}/plexdrive*
				EOF

				if [[ "$EXCLUDE" = "o" ]] || [[ "$EXCLUDE" = "O" ]]; then
    				echo -e "${CCYAN}${CPURPLE}\nEntrez un chemin par ligne avec * à la fin${CEND}${CCYAN}, appuyer ensuite sur la touche Entrée pour continuer ou ${CPURPLE}STOP${CEND}${CCYAN} pour terminer.\n${CEND}"
    				while :
    				do		
        				read -p "" EXCLUDEPATH
        				if [[ "$EXCLUDEPATH" = "STOP" ]] || [[ "$EXCLUDEPATH" = "stop" ]]; then
            				break
        				fi
        				echo "$EXCLUDEPATH" >> /root/.borg/exclusions
    				done
				else
					echo -e "${CCYAN}Tous les dossiers seront sauvegardés, ATTENTION, cela peut prendre beaucoup de temps et de place selon la capacité des dossiers${CEND}"
				fi
				echo -e "${CCYAN}Le fichier "exclusions" est bien enregistré${CEND}"
				progress-bar 20

				cat <<- EOF >> /etc/cron.daily/borg-backup
				#!/bin/sh

				set -e
				export BORG_PASSPHRASE=$Passphrase
				borg create -v --stats --compression zlib,6 --exclude-from ~/.borg/exclusions $Repo::$Backup

				# Nettoyage des anciens backups
				# On conserve
				# - une archive par jour les 7 derniers jours,
				# - ne archive par semaine pour les 4 dernières semaines,
				# - une archive par mois pour les 6 derniers mois.
				borg prune -v $Repo --keep-daily=7 --keep-weekly=4 --keep-monthly=6
				EOF

				chmod 775 /etc/cron.daily/borg-backup

			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}		La configuration de la sauvegarde s'est bien déroulée et est enregistrée dans "/etc/cron.daily"		  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CRED}				NETTOYAGE DES ANCIENS BACKUPS								  ${CEND}"
			echo -e "${CPURPLE}	On conserve:													  ${CEND}"
			echo -e "${CPURPLE}	- une archive par jour les 7 derniers jours									  ${CEND}"
			echo -e "${CPURPLE}	- une archive par semaine pour les 4 dernières semaines								  ${CEND}"
			echo -e "${CPURPLE}	- une archive par mois pour les 6 derniers mois									  ${CEND}"
			echo -e "${CPURPLE}	Les points de montage ainsi que les librairies Plex et Emby ne devraient pas être concernés par la sauvegarde	  ${CEND}"
			echo -e "${CPURPLE}	Vous devriez les mentionner dans les exclusions. (trop volumineux)						  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}		Pour restaurer l'archive :										 ${CEND}"	
			echo -e "${CGREEN}		1) On affiche le nom de l'archive									 ${CEND}"
			echo -e "${CGREEN}		borg list /path-to-repo											 ${CEND}"
			echo -e "${CGREEN}															 ${CEND}"
			echo -e "${CGREEN}		2) On restaure l'archive										 ${CEND}"
			echo -e "${CGREEN}		borg extract /path-to-repo::<nom_de_l'archive>								 ${CEND}"
			echo -e "${CGREEN}															 ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}															 ${CEND}"
			echo -e "${CCYAN}				Configuration de la sauvegarde terminée							 ${CEND}"
			echo -e "${CCYAN}															 ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			read -p "Appuyer sur la touche Entrer pour continuer"
			clear
			logo.sh
				;;

				3)
				sortir=true
				seedbox.sh

				;;

			esac
			done

			;;

		8)
		exit 0

		;;

	esac
