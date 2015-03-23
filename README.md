# docker
Last after data, elasticsearch, mongodb:
sudo docker run -e ROOT_PASS=test --name test_apache -p IP:80:80 -p IP:2222:22 -p IP:9001:9001 --restart="always" --link test_elasticsearch:elasticsearch --link test_mongodb:mongodb --volumes-from="test_data" -d webtales/rubedo-docker-apache
