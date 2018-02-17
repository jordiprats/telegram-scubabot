from selenium import webdriver
from time import sleep, time
from random import randint

import threading


options = webdriver.ChromeOptions()
options.add_argument('--ignore-certificate-errors')
options.add_argument("--test-type")
options.add_argument("--no-sandbox")
options.add_argument('headless')
options.add_argument('window-size=1200x1920')
options.binary_location = "/usr/bin/chromium-browser"
driver = webdriver.Chrome(chrome_options=options)


driver.get('http://meteo.cat/prediccio/platges/tossa-de-mar-de-la-mar-menuda')


start_time = time()
while time() < start_time + 10:
  sleep(0.1)

driver.save_screenshot("meteocat_mar_menuda.png")


driver.close()
