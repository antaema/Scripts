#!/bin/bash

if [[ $# != 1 ]]; then
	echo 'Numero de argumentos invalido'
	echo 'module [DESCRITION FILE]'
elif [[ ! -f $1 ]]; then
	echo "Arquivo de descricao invalido ou nao existe"
fi

lendo=true
while [[ "$lendo" = true ]]; do
	echo $lendo
	lendo=false
done