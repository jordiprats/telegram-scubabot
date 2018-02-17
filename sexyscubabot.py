from selenium import webdriver
from time import sleep
from random import randint

import threading

def hangover():
    sleep(5)
    return

options = webdriver.ChromeOptions()
options.add_argument('--ignore-certificate-errors')
options.add_argument("--test-type")
options.add_argument("--no-sandbox")
options.add_argument('headless')
options.add_argument('window-size=1200x1920')
options.binary_location = "/usr/bin/chromium-browser"
driver = webdriver.Chrome(chrome_options=options)


driver.get('http://meteo.cat/prediccio/platges/tossa-de-mar-de-la-mar-menuda')


t = threading.Thread(target=hangover)
t.start()
t.join()


driver.save_screenshot("meteocat_mar_menuda.png")


driver.close()
