Create a simple python webserver
  - should return message like "Hello World, I am node xxxx serving on port yy"
  - port must be changed using an environment variable

1/ create helloworld.py

2/ execute it
    ./helloworld.py
    PORT=81 ./helloworld.py

3/ test it
    curl http://localhost
    curl http://localhost:81
