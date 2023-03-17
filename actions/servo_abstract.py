import logging

from dadou_utils.misc import Misc

INPUT_MIN = 0
INPUT_MAX = 99

SERVO_MIN = 0


class ServoAbstract:

    def __init__(self, type, pwm_channel, default_pos, servo_max, i2c_enabled, pwm_channels_enabled):

        self.enabled = i2c_enabled or pwm_channels_enabled
        if not self.enabled:
            logging.warning("i2c pwm disabled")
            return

        self.type = type
        self.servo_max = servo_max
        self.pwm_channel = pwm_channel
        self.pwm_channel.angle = default_pos

    def update(self, msg):

        if not self.enabled:
            return

        if msg and self.type in msg:
            target_pos = Misc.mapping(msg[self.type], INPUT_MIN, INPUT_MAX, SERVO_MIN, self.servo_max)
            logging.debug("update servo {} with key {} for target {}".format(self.type, msg[self.type], target_pos))
            self.pwm_channel.angle = target_pos
