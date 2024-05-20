import unittest

from dadou_utils_ros.com.input_messages_list import InputMessagesList


class MyTestCase(unittest.TestCase):
    def test_input_messages(self):

        self.node.publish({'BR': 'ANIMATION BR'})
        self.node.publish({'BL': 'ANIMATION BL'})

        print(InputMessagesList().get_all())

if __name__ == '__main__':
    unittest.main()
