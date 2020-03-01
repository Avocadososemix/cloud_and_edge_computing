git clone https://github.com/dockersamples/node-bulletin-board
cd node-bulletin-board/bulletin-board-app

docker image build -t bulletinboard:1.0 .

docker container run --publish 8000:8080 --detach --name bb bulletinboard:1.0
