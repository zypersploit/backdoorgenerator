def test_detect_eth0_ip():

  expected_ip = "192.168.1.10"
  actual_ip = detect_eth0_ip()
  assert actual_ip == expected_ip, "Failed to detect expected IP address"


if __name__ == "__main__":
  unittest.main()