#!/bin/bash

function check () {
	if [[ "$keyboard" == "keyboard" ]];then
		if [[ -n "$pid" ]]; then
			kill -9 "$pid";
		fi
	fi
}

#trap check SIGTTIN

function trata_erros (){
	kill=$(ps aux | grep -v grep | grep "$0" | awk '{print "kill " $2 " 2>&1 1>/dev/null";}');
	
	case $error in
		0)
			echo "Erro de sintaxe na linha \"$line\""
			echo $kill | sh
		;;
		1) 
			echo "Erro na linha \"$line\"";
			echo "Progama inexistente"
			echo $kill | sh
		;;
		2) 	
			echo "Erro na linha \"$line\"";
			echo "Valor maior que 100%"
			echo $kill | sh
		;;
		3) 	  
			echo 'Numero de argumentos invalido'
			echo 'module [DESCRITION FILE]'
			echo $kill | sh
		;;
		4) 	  
			echo "Arquivo de descricao invalido ou nao existe"
			echo $kill | sh
		;;
		5) 	  
			echo " Não foi definido nenhum progama para ser executado";
			echo $killp | sh;
		;;
		6)
			echo $kill | sh
		;;
		esac
}

function getStatus (){
	pid=$(ps aux | grep -v grep | grep "$programa" | awk '{print $2}');
	cpu_usage=$(ps aux | grep -v grep | grep "$programa" | awk '{print $3}');
	memory_usage=$(ps aux | grep -v grep | grep "$programa" | awk '{print $4}');
}

if [[ $# != 1 ]]; then
	error=3;
	trata_erros;
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
			elif [[ "$token" == "ouput_file"  ]];then
				state=5;
			elif [[ "$token" == "error_file"  ]];then
				state=6;
			else
				error=0;
				trata_erros;
			fi
		;;
		1) 	  
			if [[ "$token" == "=" ]];then
				step=1;
			elif [[ "$step" == "1" ]];then
				if [[ -f "$token" ]];then
					programa=$token;
					step=2;
				else
					error=1;
					trata_erros;
				fi
			else
				error=0;
				trata_erros;
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
						error=2;
						trata_erros;
					fi
				else
					error=0;
					trata_erros;
				fi
			else
				error=0;
				trata_erros;
			fi
		;;
		3) 	  
			if [[ "$token" == "=" ]];then
				step=1;
			elif [[ "$step" == "1" ]];then
				token=$(echo $token | sed 's/%//');
				if [[ "$token" =~ ^[0-9]+([.,]?[0-9]+)?$ ]];then
					teste=$(echo "$token <= 100.0" | bc);
					if [[ "$teste" == "1" ]];then
						percentage_memory=teste;
						step=2;
					else
						error=2;
						trata_erros;
					fi
				else
					error=0;
					trata_erros;
				fi
			else
				error=0;
				trata_erros;
			fi
		;;
		4) 	  
			if [[ "$token" == "=" ]];then
				step=1;
			elif [[ "$step" == "1" ]];then
				if [[ "$token" == "keyboard" ]];then
					keyboard=true;
				else
					error=0;
					trata_erros;
				fi
			else
				error=0;
				trata_erros;
			fi
		;;
		5) 	  
			if [[ "$token" == "=" ]];then
				step=1;
			elif [[ "$step" == "1" ]];then
				if [[ -n "$token"  ]];then
					output_file=$token;
				else
					error=0;
					trata_erros;
				fi
			else
				error=0;
				trata_erros;
			fi
		;;
		6) 	  
			if [[ "$token" == "=" ]];then
				step=1;
			elif [[ $step == "1" ]];then
				if [[ -n "$token"  ]];then
					error_file=$token;
				else
					error=0;
					trata_erros;
				fi
			else
				error=0;
				trata_erros;
			fi
		;;		
		esac
	done
done

if [[ -n "$programa" ]];then
	#se nao definiu arquivo de saida de erro ambos vão para o mesmo lugar
	if [[ -n "$output_file" && -z "$error_file" ]];then
		echo "sudo ./$programa &>$output_file 2>&1 1>|$output_file" | sh;
	elif [[ -z "$output_file" && -n "$error_file" ]];then
		echo "sudo ./$programa 1>/dev/null 2>|$error_file &" | sh;
	else
		echo "sudo ./$programa 1>|$output_file 2>|$error_file &" | sh;
	fi
	IFS=$OldIFS;
	pid=$(ps aux | grep -v grep | grep "$programa" | awk '{print $2}');
	while [[ -n "$pid" ]] ; do
	    sleep 3;
		getStatus;
		killp=$(ps aux | grep -v grep | grep "$programa" | awk '{print "kill " $2 " 1>/dev/null 2>/dev/null";}');
		
		if [[ -n $cpu_limit ]];then
			teste=$(echo "$cpu_usage <= $percentage_cpu" | bc);
		else
			teste=$(echo "$cpu_usage <= 30.0" | bc);
		fi
		if [[ "$teste" == "1" ]];then
			if [[ -n $memory_limit ]];then
				teste=$(echo "$memory_usage <= $percentage_memory" | bc);
			else
				teste=$(echo "$memory_usage <= 30.0" | bc);
			fi
			if [[ "$teste" != "1" ]];then
				echo $killp | sh;
				error=6;
				trata_erros;
			fi
		else
 			echo $killp | sh;
			error=6;
			trata_erros;
		fi
	done
else
	error=5;
	trata_erros;
fi
