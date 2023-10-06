import unittest

from dadou_utils.com.input_messages_list import InputMessagesList


class MyTestCase(unittest.TestCase):
    def test_input_messages(self):

        InputMessagesList().add_msg({'BR': 'ANIMATION BR'})
        InputMessagesList().add_msg({'BL': 'ANIMATION BL'})

        print(InputMessagesList().get_all())

if __name__ == '__main__':
    unittest.main()
