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

# Obtener el nombre del puente asociado a la red
puente=$(virsh --connect qemu:///system net-dumpxml "${red}" | grep -m 1 -oP "<bridge name='\K[^']+")

# Crear un nuevo volumen a partir de la plantilla
virsh --connect qemu:///system vol-create-as default "${nombre}.qcow2" ${tamaño_volumen}G --format qcow2 --backing-vol Plantilla-debian.qcow2 --backing-vol-format qcow2

# Crear la máquina virtual
virt-install --connect qemu:///system --virt-type kvm --name "${nombre}" --os-variant debian10 --disk path="/var/lib/libvirt/images/${nombre}.qcow2" --memory 4096 --vcpus 2 --import

# Conectar la máquina virtual al puente asociado a la red
virsh --connect qemu:///system attach-interface "${nombre}" bridge "${puente}" --model virtio

# Cambiar el nombre del host de la máquina virtual
virt-customize --connect "qemu:///system" --hostname "${nombre}"

# Iniciar la máquina virtual
virsh --connect qemu:///system start "${nombre}"

echo "La máquina virtual ${nombre} se ha creado y está en funcionamiento en el puente ${puente}."
