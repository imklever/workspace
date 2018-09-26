#curl -X GET -H "Content-Length:0" http://127.0.0.1:9999

echo

curl -X GET -H "Content-Length:0" http://127.0.0.1:9999/nihao

echo

curl -X GET -H "Content-Length:0" http://127.0.0.1:9999/rest1
curl -X POST -H "Content-Length:0" http://127.0.0.1:9999/rest1?length=9
curl -X PUT -H "Content-Length:0" http://127.0.0.1:9999/rest1
curl -X DELETE -H "Content-Length:0" http://127.0.0.1:9999/rest1

echo

curl -X GET -H "Content-Length:0" http://127.0.0.1:9999/rest2
curl -X POST -H "Content-Length:0" http://127.0.0.1:9999/rest2?length=9
curl -X PUT -H "Content-Length:0" http://127.0.0.1:9999/rest2
curl -X DELETE -H "Content-Length:0" http://127.0.0.1:9999/rest2

echo
