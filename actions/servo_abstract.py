import logging

from adafruit_servokit import ServoKit
from dadou_utils.misc import Misc
from dadou_utils.utils_static import UP, DOWN

INPUT_MIN = 0
INPUT_MAX = 99

SERVO_MIN = 0
STEP = 5


class ServoAbstract:

    def __init__(self, type, pwm_channel_nb, default_pos, servo_max, i2c_enabled, pwm_channels_enabled):

        logging.info("init  {} servo".format(type))
        self.enabled = i2c_enabled or pwm_channels_enabled
        if not self.enabled:
            logging.warning("i2c pwm disabled")
            return

        try:
            self.self_pwm_channels = ServoKit(channels=16)
            self.pwm_channel = self.self_pwm_channels.servo[pwm_channel_nb]

        except ValueError as err:
            logging.error("{} : can't connect to i2c".format(type))
            self.enabled = False
            return

        self.type = type
        self.servo_max = servo_max
        self.pwm_channel.angle = default_pos

    def update(self, msg):

        if not self.enabled:
            return

        if msg and self.type in msg:
            if msg[self.type] == UP:
                if self.pwm_channel.angle < self.servo_max - STEP:
                    self.pwm_channel.angle = self.pwm_channel.angle + STEP
            if msg[self.type] == DOWN:
                if self.pwm_channel.angle > STEP:
                    self.pwm_channel.angle = self.pwm_channel.angle - STEP

            else:
                value = int(msg[self.type]*100)
                target_pos = Misc.mapping(value, INPUT_MIN, INPUT_MAX, SERVO_MIN, self.servo_max)
                logging.info("update servo {} with key {} for target {}".format(self.type, value, target_pos))
                self.pwm_channel.angle = target_pos

    def process(self):
        pass