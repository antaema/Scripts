#!/bin/bash

if [[ $# != 1 ]]; then
	echo 'Numero de argumentos invalido'
	echo 'module [DESCRITION FILE]'
elif [[ ! -f $1 ]]; then
	echo "Arquivo de descricao invalido ou nao existe"
fi

OldIFS=$IFS;
IFS=';';
state='0';

for line in $(cat $1); do
	IFS=' ';
	line=$(echo $line | tr -d '\n');
	for token in $line; do       
		IFS=',';
		for subToken in $token; do
			IFS=$OldIFS;
			case $state in
			0)		  
				echo $subToken;
				if [[ "$subtoken" == "executable" ]];then
					echo "1";
				elif [[ "$subtoken" == "10%"  ]];then
					echo "2";
				else
					echo "3";
				fi
			;;
			1) 
				echo "Um" 
			;;
			*) 
				echo "Erro de sintaxe na linha $line" 
			;;
			esac
		done
	done
	IFS=';';
done

