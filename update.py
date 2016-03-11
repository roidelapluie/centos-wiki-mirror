from selenium import webdriver
import sys
import time
import os

arg=sys.argv[1]
with open("wiki/%s.moin" % arg) as f:
    page = False
    text = ""
    for l in f.readlines():
        l=l.rstrip('\n')
        l=l.rstrip('\r')
        if page:
            text += "%s\n" % l
        if l.strip() == '---' and not page:
            page = True
driver = webdriver.Firefox()
driver.get("https://wiki.centos.org/%s?action=login" % arg)
elem = driver.find_element_by_name("name")
elem.send_keys("JulienPivotto")
elem = driver.find_element_by_name("password")
try:
    elem.send_keys(os.environ['WIKIPASS'])
except:
    pass
driver.find_element_by_name("login").click()
time.sleep(4)
driver.get("https://wiki.centos.org/%s?action=edit" % arg)
driver.find_element_by_name("savetext").clear()
driver.find_element_by_name("savetext").send_keys(text)
driver.find_element_by_name("button_save").click()
driver.quit()

