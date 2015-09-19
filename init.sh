#!/usr/bin/env bash
# -------------------------------------------
# inicializa el entorno para ejecutar ansible
# Este script debe invocarse en el directorio
# del virtualenv, con
#
# . ./init.sh
#
# o
#
# source ./init.sh
# -------------------------------------------

export CWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ANSIBLE_INVENTORY="$CWD/hosts"
export VIRTUALENV_DIR="${VIRTUALENV_DIR:-$CWD/..}"

# Si se nos pasa "-U" en la linea de comandos, actualizar.
# Para actualizar ansible:
function update {
    pip install -U paramiko PyYAML Jinja2 httplib2 six
    pushd .
    cd ansible
    git pull --rebase
    git submodule update --init --recursive
    popd
}

pushd .

# Entrar al virtualenv
cd "$VIRTUALENV_DIR"
source bin/activate

# Activar el entorno de ansible
[ -f ansible/hacking/env-setup ] && source ansible/hacking/env-setup

# Si se nos pasa "-U" en la linea de comandos, actualizar
if [ "x$1" == "x-U" ]; then
    update
fi

# Descifrar el fichero de variables de entorno
export ENVFILE="$CWD/environment"
if [ ! -f "$ENVFILE" ]; then
    echo "********************************************"
    echo "DESCIFRANDO FICHERO CON VARIABLES DE ENTORNO"
    echo "********************************************"
    ansible-vault decrypt --ask-vault-pass --output="$ENVFILE" "$ENVFILE.vault"
fi
source "$ENVFILE"
       
popd
