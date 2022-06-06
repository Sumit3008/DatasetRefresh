# DatasetRefresh
#with arguments for dockerfile
1. docker build --build-arg arg1=ls --build-arg retryCount=2 --build-arg syncCommandDataset=uniprot:/pub/databases/uniprot/ .
2. docker run --name test c20a00247ae0
3. docker rm test
4. docker exec -it test /bin/sh
5. docker stop test

#without arguments foor dockerfile2
1. docker build .
