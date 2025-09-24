from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.firefox.service import Service as FirefoxService
import time

def test_chrome_with_selenium_manager():
    driver = webdriver.Chrome(service=ChromeService())
    driver.get("https://www.google.com")
    print("Chrome title:", driver.title)
    time.sleep(1)
    # print("ok, google")
    driver.quit()

def test_firefox_with_manual_driver():
    gecko_path = r"C:\Users\diase\OneDrive\Рабочий стол\Dias_Yermekov_SP25\Task 2\geckodriver.exe"
    service = FirefoxService(executable_path=gecko_path)

    driver = webdriver.Firefox(service=service)
    driver.get("https://addons.mozilla.org/ru/firefox/")
    print("Firefox title:", driver.title)
    time.sleep(2)
    # print("ok, firefox")
    driver.quit()


test_chrome_with_selenium_manager()
test_firefox_with_manual_driver()