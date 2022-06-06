#with arguments for dockerfile
docker build --build-arg arg1=ls --build-arg retryCount=2 --build-arg syncCommandDataset=uniprot:/pub/databases/uniprot/ .
docker run --name test c20a00247ae0
docker rm test
docker exec -it test /bin/sh
docker stop test

#without arguments foor dockerfile2
docker build .