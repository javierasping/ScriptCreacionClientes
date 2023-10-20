#!/bin/bash

# Comprobar si se han proporcionado los argumentos requeridos
if [ $# -ne 3 ]; then
  echo "Uso: $0 Nombre TamañoDelVolumen NombreDeLaRed"
  exit 1
fi

# Variables
nombre=$1
tamano_volumen=$2 
red=$3

# Obtener el nombre del puente asociado a la red
puente=$(virsh --connect qemu:///system net-dumpxml "${red}" | grep -m 1 -oP "<bridge name='\K[^']+")

# Crear un nuevo volumen a partir de la plantilla
virsh --connect qemu:///system vol-create-as default "${nombre}.qcow2" "${tamano_volumen}G" --format qcow2 --backing-vol plantilla-taller1.img --backing-vol-format qcow2

# Cambiar el nombre del host de la máquina virtual
sudo virt-customize --connect "qemu:///system" -a "/var/lib/libvirt/images/${nombre}.qcow2" --hostname "${nombre}"

#Red
cp "/var/lib/libvirt/images/${nombre}.qcow2" "/var/lib/libvirt/images/new${nombre}.qcow2"
virt-resize --expand /dev/sda1 "/var/lib/libvirt/images/new${nombre}.qcow2" "/var/lib/libvirt/images/${nombre}.qcow2"

# Crear la máquina virtual
virt-install --connect qemu:///system --noautoconsole --virt-type kvm --name "${nombre}" --os-variant debian10 --disk path="/var/lib/libvirt/images/${nombre}.qcow2",size="${tamano_volumen}",format=qcow2 --memory 4096 --vcpus 2 --import --network bridge="${puente}"

# Iniciar la máquina virtual
virsh --connect qemu:///system start "${nombre}"

echo "La máquina virtual ${nombre} se ha creado y está en funcionamiento en el puente ${puente}."

