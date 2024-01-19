import paho.mqtt.client as mqtt

class MQTT_client:

    client = mqtt.Client()
    topic = "Didier"

    def __init__(self):

        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        # Replace `<USER>`, `<PASSWORD>` and `<XXXXXX>.stackhero-network.com` with your server credentials.
        self.client.username_pw_set("mqtt", "~+2b>oG@wsaqqp1fbbRp")
        #client.tls_set()
        self.client.connect("cloud.duvam.net", 1883, 60)

        self.client.loop_start()

    # Callback running on connection
    def on_connect(self, client, userdata, flags, rc):
        print("Connected with result code "+str(rc))
        # After connection we subscribe to the "$SYS/#" topics (internal topics that will produce lot of data, perfect for our example)
        client.subscribe("{}/#".format(self.topic))

    # Callback running on new message
    def on_message(self, client, userdata, msg):
        # We print each message received
        print("received : {}".format(str(msg.payload.decode())))


    def publish(self, msg):
        result = self.client.publish(self.topic, msg)
        # result: [0, 1]
        status = result[0]
        if status == 0:
            print(f"Send `{msg}` to topic `{self.topic}`")
        else:
            print(f"Failed to send message to topic {self.topic}")

    # Initiate the MQTT client

