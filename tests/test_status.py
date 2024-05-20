import unittest

from utils.status import Status


class TestStatus(unittest.TestCase):

    def test_check_cpu(self):
        Status.check_cpu()


if __name__ == '__main__':
    unittest.main()
