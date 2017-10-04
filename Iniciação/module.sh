#!/bin/bash

if [[ $# != 1 ]]; then
	echo 'Numero de argumentos invalido'
	echo 'module [DESCRITION FILE]'
elif [[ ! -f $1 ]]; then
	echo "Arquivo de descricao invalido ou nao existe"
fi

OldIFS=$IFS;
IFS=';';

for line in $(cat $1); do
      IFS=' ';
      line=$(echo $line | tr -d '\n');
      for token in $line; do       
      		IFS=',';
      		for subToken in $token; do
               if [[ -n "$subToken" ]]; then
         		 echo $subToken;
               fi 
         	done
      done
   IFS=';';
done

