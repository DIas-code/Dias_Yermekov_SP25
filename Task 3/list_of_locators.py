from selenium import webdriver
from selenium.webdriver.common.by import By
import time

driver = webdriver.Chrome()

driver.get("https://phptravels.com/demo/")
time.sleep(3)

first_name = driver.find_element(By.CLASS_NAME, "first_name")
last_name = driver.find_element(By.CLASS_NAME, "email")

print(first_name.get_attribute("placeholder"))
print(last_name.get_attribute("placeholder"))

btn = driver.find_element(By.ID, "demo")
number = driver.find_element(By.ID, "number")
print(btn.text)
print(number.get_attribute("placeholder"))


driver.get("https://phptravels.org/register.php")
time.sleep(3)
inputPostcode = driver.find_element(By.NAME, "postcode")
company = driver.find_element(By.NAME, "companyname")

print(inputPostcode.get_attribute("placeholder"))
print(company.get_attribute("placeholder"))

input_address = driver.find_element(By.CSS_SELECTOR, "#inputAddress1")
input_address2 = driver.find_element(By.CSS_SELECTOR, "input[name=\"address1\"]")
print(input_address.get_attribute("placeholder"))
print(input_address2.get_attribute("placeholder"))

state_input = driver.find_element(By.XPATH, "//input[@name='state']")
state_input2 = driver.find_element(By.XPATH, "//input[@id='stateinput']")
print(state_input.get_attribute("placeholder"))
print(state_input2.get_attribute("placeholder"))
driver.quit()