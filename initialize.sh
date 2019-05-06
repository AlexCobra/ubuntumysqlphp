#!/bin/bash

echo -e "Intializing environment...\n"

docker pull alexcobra/ubuntumysqlphp
docker run -d -it --name ubuntumysqlphp alexcobra/ubuntumysqlphp 
docker exec ubuntumysqlphp service mysql start && docker exec ubuntumysqlphp service apache2 start
echo -e "\nEnvironment initialized. Please use command 'umprun' to enter environment, command 'exit' to exit it."
