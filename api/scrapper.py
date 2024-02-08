import time
from bs4 import BeautifulSoup
from selenium import webdriver 
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC 
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys 
from selenium.webdriver.remote.webelement import WebElement


inputLoc = "Mama's Burger Dikmen"
inputPlaceId = 'ChIJ83EOeClF0xQRpmgaAmrCMqA' 
maxReviews = 5

URL = "https://www.google.com/maps/search/?api=1" 

if(inputLoc  != ""):
    URL = URL +("&query={}".format(inputLoc))
if(inputPlaceId != ""):
    URL = URL + ("&query_place_id={}".format(inputPlaceId)) 

driver = webdriver.Firefox()
driver.get(URL)

WebDriverWait(driver, 15).until(EC.presence_of_element_located((By.XPATH, "/html/body/div[2]/div[3]/div[8]/div[9]/div/div/div[1]/div[2]/div/div[1]/div/div/div[3]/div/div/button[2]/div[2]/div[2]") )).click()
 

try:
    info = "/html/body/div[2]/div[3]/div[8]/div[9]/div/div/div[1]/div[2]/div/div[1]/div/div/div[2]/div[3]/div[2]/span/div[1]/button/span[1]/img" 
    WebDriverWait(driver, 15).until(EC.presence_of_element_located((By.XPATH, info) )).click()
    comments =  "/html/body/div[2]/div[3]/div[8]/div[9]/div/div/div[1]/div[2]/div/div[1]/div/div/div[2]/div[11]/div"
    reviews = WebDriverWait(driver,10).until(EC.presence_of_all_elements_located((By.XPATH,comments) ))
    reviewsCount = len(reviews) 
    ActionChains(driver).key_down(Keys.END).perform()   
    WebDriverWait(driver,10).until(EC.presence_of_all_elements_located((By.XPATH,comments+"[{}]".format(reviewsCount+1)) )) 
    reviews = WebDriverWait(driver,10).until(EC.presence_of_all_elements_located((By.XPATH,comments) ))
    

    while(len(reviews) > reviewsCount and len(reviews) < maxReviews*3): 
        reviewsCount = len(reviews)
        ActionChains(driver).key_down(Keys.END).perform()    
        WebDriverWait(driver,10).until(EC.presence_of_all_elements_located((By.XPATH,comments+"[{}]".format(reviewsCount+1)) ))
        reviews=WebDriverWait(driver,10).until(EC.presence_of_all_elements_located((By.XPATH,comments) ))
        print(len(reviews))
except Exception as e:
    print(e) 

i = 0
while i < len(reviews):
    if reviews[i].get_attribute("class") == "qCHGyb":
        del reviews[i]
    else:
        i += 1

reviewsCount = len(reviews)
for review in reviews:
    try:
        print(review.find_element(By.XPATH,"").text)
    except Exception as e:
        print("--")  