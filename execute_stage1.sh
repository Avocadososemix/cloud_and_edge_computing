# Before Starting this process, I installed python 3 for Flask. These will only need to be ran once, and would be counterintuitive
# to run in the bash script.

# sudo apt update
# sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
# curl -O https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
# tar -xf Python-3.7.3.tar.xz
# cd Python-3.7.3
# ./configure --enable-optimizations
# make -j 8
# sudo make altinstall
# sudo apt-get install pip3
# pip3 install flask
# pip3 install redis  # this is a python library that allows interfacing with Redis



# Stop all prior running containers and remove them so script can be tested from fresh slate.
docker container stop $(docker container ls -aq)
docker system prune

# A - Setup the bulletinboard according to instructions on https://docs.docker.com/get-started/part2/

cd /home/cecuser/Project/stage1/
git clone https://github.com/dockersamples/node-bulletin-board
cd /home/cecuser/Project/stage1/node-bulletin-board/bulletin-board-app
docker image build -t bulletinboard:1.0 .
docker container run --publish 8000:8080 --detach --name bb bulletinboard:1.0
sudo docker start bb

# B - Setup Dockerized Redis

# change redis config file to point to snapshot location.
sed -i -e 's/#dbfilename*/dbfilename "redis.rdb"/g' /etc/redis/redis.conf
sed -i -e 's/#dir */dir "var/cec/"g' /etc/redis/redis.conf
# get and run the redis container, and point it to use the local redis.rdb file in /var/cec/
sudo docker run -d --name redis-container -v /var/cec/redis.rdb:/data/dump.rdb redis:latest
sudo docker start redis-container

# C - Setup Flask webserver that returns a value from the rdb factorized.

# kill extra copies of flask running if some are still on from testing.
kill -9 `lsof -i:5000 -t` 

pip3 install -U Flask
pip3 install redis

# Setup directory for flask application
mkdir -p /home/cecuser/Project/stage1/flask_server
cd /home/cecuser/Project/stage1/flask_server

# Begin creating web-server.
cat > /home/cecuser/Project/stage1/flask_server/flask_server.py << ENDOFFILE

from flask import Flask
import redis

app = Flask(__name__)

r = redis.StrictRedis(host="localhost", port=6379, db=0)
@app.route('/')
def factorial():
    value = r.get(r.randomkey()) 
    text = 'Factorial of '
    text += str(int(value))
    text += ' " '
    factorial = 1
    for i in range(1,int(value)+1:
        factorial = factorial * i
    text += str(factorial)
    return text
ENDOFFILE

export FLASK_APP='flask_server.py'
export FLASK_DEBUG=1
# Run the web-server in the background.
FLASK_APP=flask_server.py flask run &
