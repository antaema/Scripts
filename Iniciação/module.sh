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
   for token in $line; do
      echo $token;
   done
   IFS=';';
done

