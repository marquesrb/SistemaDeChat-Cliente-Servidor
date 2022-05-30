#!/bin/bash

#• create usuario senha: cria um novo usuario de nome usuario e de senha com valor senha. 
#• passwd usuario antiga nova: modifica a senha do usuario usuario de antiga para nova. 
#• login usuario senha: loga como o usuario de nome usuario com a senha senha. 
#• quit: encerra a execucao do cliente. Caso o usuario nao tenha feito logout, faz logout antes de encerrar;
#O cliente deve suportar os seguintes comandos apos usuario logar: 
#• list: lista os nomes de todos os usuarios logados, um por linha, inclusive o proprio usuario; ´
#• logout: desloga do sistema mas nao encerra a execucao do cliente; 
#• msg usuario mensagem: Escreve na tela do usuario usuario a mensagem mensagem. 
#• reset: limpa os registros

TEMP=$SECONDS
cd /tmp

function serv {
	> register.txt ; > login.txt
	mkfifo pipe1
	printf "servidor> " 
	read VAR
	while [ "$VAR" != "quit" ]; do
 		case $VAR in
			time) echo $(( SECONDS - TEMP )) ;;  
			list) cat login.txt   ;;
			reset) > register.txt ;;
		esac
	printf "servidor> "
	read VAR
	done 
	rm register.txt
	rm login.txt
	rm pipe1
	exit
}

function cli {
	printf "cliente> "
	read VAR
	while [ "$VAR" != "quit" ]; do
		OP=$(echo $VAR |cut -d" " -f1)
		case $OP in
			create) creat $VAR ;; 
			passwd) pass $VAR  ;;
			login)  log $VAR   ;;
			*) echo "Erro"     ;;
		esac
	printf "cliente> "
	read VAR
	done
	exit
}

function creat {
	VAR=$(grep "$2" register.txt)
	if [ "$2" = "$VAR" ]; then
		echo "Erro"
	else 
		echo "$2 $3" >> register.txt
	fi
}

function pass {
	VAR=$(grep -i "$2" register.txt)
	LINE=$(grep -n "$2" register.txt | cut -d":" -f1)
		if [ "$VAR" = "$2 $3" ]; then
			sed -i ''$LINE's/'$3'/'$4'/' register.txt
		else
			echo "Erro"
		fi
}

function log {
	VAR=$(grep -i "$2" register.txt)
	NUM=$(grep -n "$2" register.txt | cut -d":" -f1)
	TERM=$(tty)
	if [ "$VAR" = "$2 $3" ]; then
		if ! [ $(grep -i "$2" login.txt) ]; then
			sed -i ''$NUM's|$| '$TERM'|g' register.txt
			echo "$2" >> login.txt
			printf "cliente> "
        	read VAR2
			USER=$2
			while [ 0 ]; do
        		VAR3=$(echo $VAR2 |cut -d" " -f1)
				case $VAR3 in
        			list) cat login.txt  ;;
					msg) msg $USER $VAR2 ;;
					quit) sed -i '/'$2'/d' login.txt
					exit ;;
					logout) sed -i '/'$2'/d' login.txt
					return ;;
					*) echo "Erro" ;;
				esac
			printf "cliente> "
			read VAR2
			done
		else
			echo "Erro"
		fi
	else
		echo "Erro"
	fi

}

function msg 
{
	TERM=$(grep -i "$3" register.txt | cut -d" " -f3)
	printf "[Mensagem do $1]:${VAR2#$2*$3}" > pipe1 &
	cat pipe1 >> $TERM ; printf "\n""cliente> " >>  $TERM
}

if [ "$1" = "servidor" ]; then
        serv
else
        cli
fi





