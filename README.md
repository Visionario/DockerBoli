# Create a Bolivarcoin/Bolicoin Docker image   
### For Bolivarcoin Core v2.0.0.2:
> https://github.com/BOLI-Project/BolivarCoin/releases/tag/v2.0.0.2    
 
### VERSION 0.9.0   
---   
## [Para español haga clic aquí](./README-es.md)

## Description  
### Dockerfile to construct an docker image for Bolivarcoin/Bolicoin Project    
<br />   

## Clone this repository:
> git clone https://github.com/Visionario/DockerBoli.git   
---

## **STEPS TO USE (BUILD, PREPARE and RUN)**  
---   
### **BUILD** image using defaults:   
```
docker build . --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t bolicoin-core-alpine:v2.0.0.2
```   
> **NOTE**: Why UID and GID is important?, please read https://stackoverflow.com/questions/44683119/dockerfile-replicate-the-host-user-uid-and-gid-to-the-image    
<br />   

### **PREPARE** for first time run:   
1) Create and go to a new boli directory. Very important use mkdir with your host user account  
   * > ```mkdir -p /PATH_TO_BOLI_DATA/bolidata```    

2) Copy Generic_Bolivarcoin.conf to /PATH_TO_BOLI_DATA/bolidata/Bolivarcoin.conf  
    * > ```cp Generic_Bolivarcoin.conf ./bolidata/Bolivarcoin.conf```   

3) Open, edit at your convenience Bolivarcoin.conf
    * **NOTE**: You MUST set rpcuser and rpcpassword 
    * Or use commands below to automatically set
    * > ```sed -i "s/rpcuser=CHANGE_THIS/rpcuser=$(openssl rand -hex 16)/g" Bolivarcoin.conf```  
    * > ```sed -i "s/rpcpassword=CHANGE_THIS/rpcpassword=$(openssl rand -hex 16)/g" Bolivarcoin.conf```   
<br />   

### **RUN** container:   
> ```docker run -dit --rm --name boli -p 3893:3893 -v $(pwd)/bolidata:"/bolidata" bolicoin-core-alpine:v2.0.0.2```   
---   
<br />   

### If you need:   
* Entering to container (user 'boli')   
   > docker exec -it boli /bin/sh   

 * Executing commands (user 'boli')    
   > docker exec boli bolivarcoin-cli getinfo    

 * Entering container using root credentials   
   > docker exec -it -u 0 boli /bin/sh  





# Author   
Asdrúbal Velásquez Lagrave @Visionario   
L.L.A.P. - Live long and prosper   

### Si te ha servido brinda una cerveza!!   
### Te dejo mi billetera Bolicoin/Bolivarcoin:   
> ```bPE39yGPMnwP1NcaUFj8mhYCnMX52T1bb```   

