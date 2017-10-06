#!/bin/bash

if [[ $# != 1 ]]; then
	echo 'Numero de argumentos invalido'
	echo 'module [DESCRITION FILE]'
elif [[ ! -f $1 ]]; then
	echo "Arquivo de descricao invalido ou nao existe"
fi

OldIFS=$IFS;
IFS=$'\n';

for line in $(cat $1); do
	state=0;
	step=0;
	first=false
	IFS=', ';
	for token in $line; do 
		echo $token;
		if [[ $first == "false" ]];then
			first=true;
			if [[ $token == //* ]];then
				break;
			fi
		fi
		case $state in
		0)		  
			if [[ "$token" == "program" ]];then
				state=1;
			elif [[ "$token" == "cpu_limit"  ]];then
				state=2;
			elif [[ "$token" == "memory_limit"  ]];then
				state=3;
			elif [[ "$token" == "exit_events"  ]];then
				state=4;
			else
				echo "Erro de sintaxe na linha \"$line\"" ;
				break;
			fi
		;;
		1) 	  
			if [[ "$token" == "=" ]];then
				step=1;
			elif [[ $step == "1" ]];then
				if [[ -f $token ]];then
					programa=$token;
					step=2;
				else
					echo "Erro na linha \"$line\"";
					echo "Progama inexistente"
					break;
				fi
			else
				echo "Erro na linha \"$line\"";
			 	break;
			fi
		;;
		2) 	  
			if [[ "$token" == "=" ]];then
				step=1;
			elif [[ $step == "1" ]];then
				token=$(echo $token | sed 's/%//');
				if [[ $token =~ ^[0-9]+([.,]?[0-9]+)?$ ]];then
					teste=$(echo "$token <= 100.0" | bc);
					if [[ $teste == 1 ]];then
						percentage_cpu=teste;
						step=2;
					else
						echo "Erro na linha \"$line\"";
						echo "Valor maior que 100%"
						break
					fi
				else
					echo "Erro na linha \"$line\"";
					echo "Progama inexistente"
					break;
				fi
			else
				echo "Erro na linha \"$line\"";
			 	break;
			fi
		;;
		3) 	  
			if [[ "$token" == "=" ]];then
				step=1;
			elif [[ $step == "1" ]];then
				token=$(echo $token | sed 's/%//');
				if [[ $token =~ ^[0-9]+([.,]?[0-9]+)?$ ]];then
					teste=$(echo "$token <= 100.0" | bc);
					if [[ $teste == 1 ]];then
						percentage_memory=teste;
						step=2;
					else
						echo "Erro na linha \"$line\"";
						echo "Valor maior que 100%"
						break
					fi
				else
					echo "Erro na linha \"$line\"";
					echo "Progama inexistente"
					break;
				fi
			else
				echo "Erro na linha \"$line\"";
			 	break;
			fi
		;;
		4) 	  
			if [[ "$token" == "=" ]];then
				step=1;
			elif [[ $step == "1" ]];then
				if [[ $token == "keyboard" ]];then
					keyboard=true;
				else
					echo "Erro na linha \"$line\"";
					echo "Progama inexistente"
					break;
				fi
			fi
		;;		
		esac
	done
done

