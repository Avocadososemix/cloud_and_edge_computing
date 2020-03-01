# A
cd /home/cecuser/Project/stage1/
git clone https://github.com/dockersamples/node-bulletin-board
cd /home/cecuser/Project/stage1/node-bulletin-board/bulletin-board-app
docker image build -t bulletinboard:1.0 .
docker container run --publish 8000:8080 --detach --name bb bulletinboard:1.0

# B
docker run -d --name redis-container -v /var/cec/redis.rdb:/data/dump.rdb redis:latest

# C
#cd /home/cecuser/Project/stage1/
mkdir /home/cecuser/Project/stage1/flask_server
cd /home/cecuser/Project/stage1/flask_server

cat > /home/cecuser/Project/stage1/flask_server/flask_server.py << ENDOFFILE
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'
ENDOFFILE

export FLASK_APP=flask_server.py
export FLASK_DEBUG=1
python3.7 -m flask run &
