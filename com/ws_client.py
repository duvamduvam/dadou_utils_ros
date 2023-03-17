import asyncio
import json

import websockets
import uvloop

class WsClient:

    #"ws://192.168.1.150:4421"

    def __init__(self, url):
        self.url = url
        uvloop.install()

    @staticmethod
    async def async_send(msg, url):
        async with websockets.connect(url) as websocket:
            await websocket.send(json.dumps(msg))
            response = await websocket.recv()
            print(response)

    def send(self, msg):
        asyncio.run(WsClient.async_send(msg, self.url))

