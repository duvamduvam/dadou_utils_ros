from builtins import staticmethod
from os.path import exists

from serial import SerialException

import serial
import logging
import sys

class SerialDevice:
    TERMINATOR = '>'.encode('UTF8')
    USB_ID_PATH = "/dev/serial/by-id/"
    plugged = False
    device = None
    msg_size = 0

    def __init__(self, serial_id, msg_size=0):
        self.serialPath = self.USB_ID_PATH+serial_id
        self.msg_size = msg_size
        self.connect()
        self.buf = bytearray()

    def connect(self):
        try:
            device_exists = exists(self.serialPath)
            if device_exists:
                self.device = serial.Serial(self.serialPath, 115200, timeout=1)
                logging.info('serial connected  : ' + self.serialPath)
                self.plugged = True
            else:
                logging.error("device {} not present".format(self.serialPath))
        except SerialException:
            logging.error("serial id "+self.serialPath+" not present \n", sys.exc_info()[0])
            pass

    def get_msg(self):
        if self.device == None:
            self.connect()
        if self.plugged and self.device.isOpen() and exists(self.serialPath):
            # logging.info("{} connected!".format(self.arduino.port))
            if self.device.inWaiting() > 0:
                if(self.msg_size == 0):
                    line = self.device.readline()
                else:
                    line = self.device.read(self.msg_size)
                    self.device.reset_input_buffer()
                msg = line.decode('UTF8').strip()
                logging.info("received from {} : {}".format(self.serialPath, msg))
                return msg
            #self.device.read(self.device.in_waiting)
            #print(self.device.in_waiting)
        return None

    def get_msg2(self):
        i = self.buf.find(b">")
        if i >= 0:
            r = self.buf[:i+1]
            self.buf = self.buf[i+1:]
            return r.decode()
        while True:
            i = max(1, min(2048, self.device.in_waiting))
            data = self.device.read(i)
            i = data.find(b">")
            if i >= 0:
                r = self.buf + data[:i+1]
                self.buf[0:] = data[i+1:]
                return r.decode()
            else:
                self.buf.extend(data)

    def send_msg(self, msg, flush=False):
        if self.device and self.device.isOpen() and flush:
            self.device.flush()
        if self.device and self.device.isOpen() and msg:
            self.device.write(str.encode("<{}>".format(msg)))
        else:
            logging.error("device {} not open or msg empty".format(self.serialPath))

    def setPlugedIn(self, connected):
        self.plugged = connected
