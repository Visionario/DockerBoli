# Crear una imagen de Docker para Bolivarcoin/Bolicoin    
### Version del núcleo (core) v2.0.0.2:
> https://github.com/BOLI-Project/BolivarCoin/releases/tag/v2.0.0.2    
 
### VERSION 0.9.0   
---    
## Descripción  

### Dockerfile para construir una imagen de Docker y ejecutar su nodo Bolivarcoin/Bolicoin     
<br />   

[For english, clic here](./README.md)
<br />   


## **Pasos: CONSTRUIR, PREPARAR y EJECUTAR**
---
### **CONSTRUIR** la imagen usando parámetros predeterminados:   
```
docker build . --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t bolicoin-core-alpine:v2.0.0.2
```
> **NOTA**: Lea aquí para saber la importancia de utilizar el UID y GID correctos https://stackoverflow.com/questions/44683119/dockerfile-replicate-the-host-user-uid-and-gid-to-the-image   

<br />   

### **PREPARAR** para ejecutar por primera vez:
1) Cree y vaya a un nuevo directorio *bolidata* donde se alojará la cadena de bloques. Es muy importante que usar la instrucción *mkdir* con su cuenta de usuario (del equipo HOST), evite usar ROOT   
   * > ```mkdir -p /PATH_TO_BOLI_DATA/bolidata```    

2) Copie Generic_Bolivarcoin.conf en el directorio recién creado con el nombre /PATH_TO_BOLI_DATA/Bolivarcoin.conf  
    * > ```cp Generic_Bolivarcoin.conf ./bolidata/Bolivarcoin.conf```   
<br />   
<br />   

3) Abra, y edite a su conveniencia el archivo (recién copiado) Bolivarcoin.conf   
    * **NOTA**: Debe colocar nuevos valores para rpcuser and rpcpassword 
    * O use estos comandos para hacerlo de manera automática
    * > ```sed -i "s/rpcuser=CHANGE_THIS/rpcuser=$(openssl rand -hex 16)/g" Bolivarcoin.conf```  
    * > ```sed -i "s/rpcpassword=CHANGE_THIS/rpcpassword=$(openssl rand -hex 16)/g" Bolivarcoin.conf```   


### **EJECUTAR** contenedor Docker:   
> ```docker run -dit --rm --name boli -p 3893:3893 -v $(pwd)/bolidata:"/bolidata" bolicoin-core-alpine:v2.0.0.2```   
---
<br />   
<br />   

### Si necesita ...:
* Entrar al contenedor en ejecución (usuario 'boli')   
   > docker exec -it boli /bin/sh

 * Ejecutar comandos (user 'boli')    
   > docker exec boli bolivarcoin-cli getinfo  

 * Entrar al contenedor con credenciales **root**    
   > docker exec -it -u 0 boli /bin/sh   
---
<br />   
<br />   

# Author
Asdrúbal Velásquez Lagrave @Visionario   
L.L.A.P. - Live long and prosper   

### Si te ha servido brinda una cerveza!!   
### Te dejo mi billetera Bolicoin/Bolivarcoin:   
> ```bPE39yGPMnwP1NcaUFj8mhYCnMX52T1bb```   

