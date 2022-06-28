import asyncio
import websockets
import uvloop

class WsClient:

    #"ws://192.168.1.150:4421"

    def __init__(self, url):
        self.url = url

    @staticmethod
    async def async_send(msg, url):
        async with websockets.connect(url) as websocket:
            await websocket.send(msg)
            response = await websocket.recv()
            print(response)

    def send(self, msg):
        uvloop.install()
        asyncio.run(WsClient.async_send(msg, self.url))

