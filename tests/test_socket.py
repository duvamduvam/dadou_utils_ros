import socket
import unittest


class MyTestCase(unittest.TestCase):
    def test_gethostip(self):
        ip = socket.gethostbyname_ex("control.local")
        print(ip)


if __name__ == '__main__':
    unittest.main()
