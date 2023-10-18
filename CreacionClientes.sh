#!/bin/bash

# Comprobar si se han proporcionado los argumentos requeridos
if [ $# -ne 3 ]; then
  echo "Uso: $0 Nombre TamañoDelVolumen NombreDeLaRed"
  exit 1
fi

# Variables
nombre=$1
tamaño_volumen=$2
red=$3

# Crear un nuevo volumen a partir de la plantilla
virsh vol-create-as default "${nombre}.qcow2" ${tamaño_volumen}G --format qcow2 --backing-vol Plantilla-debian.qcow2 --backing-vol-format qcow2

# Crear la máquina virtual
virt-install --connect qemu:///system --virt-type kvm --name "${nombre}" --os-variant debian10 --disk path="/var/lib/libvirt/images/${nombre}.qcow2" --memory 4096 --vcpus 2 --import

# Conectar la máquina virtual a la red especificada
virsh attach-interface "${nombre}" bridge "${red}" --model virtio

# Cambiar el nombre del host de la máquina virtual
virt-customize --connect "qemu:///system" --hostname "${nombre}"

# Iniciar la máquina virtual
virsh start "${nombre}"

echo "La máquina virtual ${nombre} se ha creado y está en funcionamiento."
