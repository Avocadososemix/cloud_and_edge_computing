# A
cd /home/cecuser/Project/stage1/
git clone https://github.com/dockersamples/node-bulletin-board
cd /home/cecuser/Project/stage1/node-bulletin-board/bulletin-board-app
docker image build -t bulletinboard:1.0 .
docker container run --publish 8000:8080 --detach --name bb bulletinboard:1.0
sudo docker start bb

# B
sudo docker run -d --name redis-container -v /var/cec/redis.rdb:/data/dump.rdb redis:latest
sudo docker start redis-container

# C

kill -9 `lsof -i:5000 -t` # kill extra copies of flask running

pip3 install -U Flask
pip3 install redis
pip3 install config
#cd /home/cecuser/Project/stage1/
mkdir -p /home/cecuser/Project/stage1/flask_server
cd /home/cecuser/Project/stage1/flask_server

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
#python3.7 -c 'import flask; flask run'
FLASK_APP=flask_server.py flask run &
