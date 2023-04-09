import asyncio
import json
import logging

from websocket import create_connection
import websocket
import websockets
import uvloop
import socket
from contextlib import closing


class WsClient:

    #"ws://192.168.1.150:4421"

    def __init__(self, host, port, name):

        #websocket = WebSocket("ws://localhost:8001/")
        #self.ws = create_connection(url)

        self.name = name
        self.url = "ws://{}:{}".format(host, port)

        self.activ = self.is_server_listening(host, port)
        if not self.activ:
            logging.error("device {} {} down".format(self.name, self.url))
            return

        logging.info("device {} {} listening".format(self.name, self.url))
        uvloop.install()

    @staticmethod
    def is_server_listening(host, port):
        with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as sock:
            return sock.connect_ex((host, port)) == 0

    @staticmethod
    async def async_send(msg, url):
        async with websockets.connect(url) as websocket:
            await websocket.send(json.dumps(msg))
            response = await websocket.recv()
            logging.debug("server response : {}".format(response))

    def send(self, msg):
        if self.activ:
            logging.info("send {} to {}".format(msg, self.name))
            asyncio.run(WsClient.async_send(msg, self.url))

        #ws = create_connection(self.url)
        #print(ws.recv())
        #print("Sending 'Hello, World'...")
        #json_object = json.dumps(msg, indent=4)
        #ws.send(json_object)
        #print("Sent")
        #print("Receiving...")
        #result = ws.recv()
        #print("Received '%s'" % result)
        #ws.close()

        #with connect(self.url) as websocket:
        #    json_object = json.dumps(msg, indent=4)
        #    websocket.send(json_object)
        #    message = websocket.recv()
        #    print(f"Received: {message}")
        #if self.activ:
        #    try:
        #        #await self.ws.recv()
        #        logging.info("connected {}".format(self.ws.connected))
        #        json_object = json.dumps(msg, indent=4)
        #        self.ws.send(json_object)
        #    except BrokenPipeError:
        #        logging.error("broken ws connection {}".format(self.name))
        #        if reconnect:
        #            self.connect()
        #            #await self.send(msg, False)
        #asyncio.run(WsClient.async_send(msg, self.url))

