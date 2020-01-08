Build a docker container embedding our web server

1/ create Dockerfile

2/ build image
    docker build -t helloworld:${OSVC_CLUSTER_NAME} . 

3/ test image
    docker run --name mytest80 -d -it helloworld:${OSVC_CLUSTER_NAME}
    docker run -e PORT=8080 --name mytest8080 -d -it helloworld:${OSVC_CLUSTER_NAME}
    IP80=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mytest80)
    IP8080=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mytest8080)
    curl http://${IP80}
    curl http://${IP8080}:8080

4/ delete containers
    docker rm -f mytest80 mytest8080

5/ push image to cluster nodes
    # root password is "pyconfr"
    docker save helloworld:${OSVC_CLUSTER_NAME} | (ssh root@c${OSVC_CLUSTER_NUMBER}n1 docker load)
    docker save helloworld:${OSVC_CLUSTER_NAME} | (ssh root@c${OSVC_CLUSTER_NUMBER}n2 docker load)

6/ check that image is correctly imported on cluster nodes
    docker images
