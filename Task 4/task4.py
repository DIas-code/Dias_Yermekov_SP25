from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
import time

driver = webdriver.Chrome()
driver.implicitly_wait(10)  

driver.get("https://www.google.com")

search_box = driver.find_element(By.NAME, "q")
search_box.send_keys("Selenium")
search_box.submit() 

wait = WebDriverWait(driver, 10)
first_result = wait.until(ec.element_to_be_clickable((By.XPATH, "//h3")))

first_result.click()
time.sleep(5)
driver.save_screenshot("selenium_google_result.png")
driver.quit()
