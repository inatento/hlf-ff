# Desplegar red fabric con entorno de firefly

1. Antes de iniciar los componentes de la red de Fabric, como precaución vamos a borrar cualquier contenedor activo y sus volúmenes ejecutando:
```bash
./down_merkaba_network.sh
```

2. Invocando el siguiente script se desplegará una red de Fabric con 3 organizaciones:

```bash
./network.sh up createChannel -ca
```

3. La siguiente instrucción instala el chaincode de Firefly en la red generada en el paso anterior (asumimos que se clonó en el directorio $HOME el repositorio "fabric-samples" de la página oficial de Hyperledger Fabric):

```bash
./install_ccff.sh
```