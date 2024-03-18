#!/bin/bash



verify_docker_login(){

USERNAME=$1
PASSWORD=$2

 if ! docker info 2>&1 | grep -q 'ERROR: Cannot connect to the Docker daemon'; then
        echo "Docker is running, checking if logged in..."

        # Check if already logged in by looking for a username in the docker info output
        if docker info 2>&1 | grep -q 'Username'; then
            echo "Already logged into Docker."
        else
            echo "Not logged into Docker, attempting to log in..."
            # Log in to Docker using the provided username and password
            echo $PASSWORD | docker login --username $USERNAME --password-stdin
            if [ $? -eq 0 ]; then
                echo "Docker login successful."
                return 0
            else
                echo "Docker login failed."
                return 1
            fi
        fi
    else
        echo "Docker is not running or you do not have permission to access it."
        return 1
    fi

}

verify_image_exist(){
    IMAGENAME=$1 
    # Check if the image is available in docker 
    availableImage=$(docker images | grep -w "$IMAGENAME" | wc -l)
    if [ "$availableImage" -gt 0 ]; then
         echo "Image $IMAGENAME is available locally."
         return 0
    else
         echo "Image $IMAGENAME is not available locally."
         return 1
    fi
}

verify_container_up(){
    CONTAINERNAME=$1 
    activeContainers=$(docker ps | grep -w "$CONTAINERNAME" | wc -l)
    if [ "$activeContainers" -eq 0 ]; then 
        echo "container $CONTAINERNAME is not active"
        return 1 
    else 
        echo "container $CONTAINERNAME is active "
        return 0
    fi

}

verify_container_available(){
    CONTAINERNAME=$1 
    availableContainers=$(docker ps -a | grep -w "$CONTAINERNAME" | wc -l)
    if [ "$availableContainers" -eq 0 ] ; then 
        echo "container $CONTAINERNAME was not used or deleted"
        return 1 
    else 
        echo "container $CONTAINERNAME was available"
        return 0
    fi
}

prepare_docker_container() {
    DOCKERCONTAINER=$1 
    echo 'inside prepare docekr container $DOCKERCONTAINER '
}

#  if (! verify_container_up 'postgres-idubi') ;then 
#                           if (! verify_container_available 'postgres-idubi' ) then 
#                             if (verify_image_exist 'postgres' ) then 
#                                docker run --name postgres-idubi -e POSTGRES_USER=idubi -e POSTGRES_PASSWORD=idubi -d -p 5432:5432 postgres
#                             ; else  // the image doens not exists need to login
#                              withCredentials([usernamePassword(credentialsId: 'idubi_docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
#                                     sh "verify_docker_login ($DOCKER_USERNAME $DOCKER_PASSWORD)"
#                                 }
#                                 // run the image after login
#                              docker run --name postgres-idubi -e POSTGRES_USER=idubi -e POSTGRES_PASSWORD=idubi -d -p 5432:5432 postgres
#                           ; else // the image available but container not available
#                           docker run --name postgres-idubi -e POSTGRES_USER=idubi -e POSTGRES_PASSWORD=idubi -d -p 5432:5432 postgres
#                         ; else  // the cintainer availabel but stopped
#                         docker start postgres-idubi
#                         // postgres container available but stopped , need to start it 
#                     } else {
#                         sh 'echo ---> postgres is online '
#                     }