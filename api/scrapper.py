from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
import json
import time
import re
from multiprocessing import Process, Manager
import requests 

start = time.time()
json = [
    {
        "inputLoc": "The Hunger Ankara",
        "inputPlaceId": "ChIJczooWulP0xQRqKZM1YQEWw0",
        "maxReviews": 100,
    },
    {
        "inputLoc": "Mama's Burger Dikmen",
        "inputPlaceId": "ChIJ83EOeClF0xQRpmgaAmrCMqA",
        "maxReviews": 100,
    },
]

rewievsResult = []

def clean_string(input_string):
    # Define regex pattern to match punctuation and special characters
    pattern = r"[^\w\s]|[\']/g"

    # Replace punctuation and special characters with spaces
    clean_string = re.sub(pattern, " ", input_string)

    return clean_string

def get_all_reviews(json):  
    rewievsResult.clear()
    with Manager() as manager:
        lock = manager.Lock() 
        for J in json: 
            processes = []
            for data in J:
                processes.append(Process(target=_get_reviews, args = (data['name'], data['place_id'],lock))) 
            for process in processes:
                process.start() 
            for process in processes:
                process.join()   
                print("Length Of rewievsResult {} ".format(len(rewievsResult)))

    return rewievsResult
 
 
 
def _get_reviews(inputLoc, inputPlaceId,lock ,maxReviews=100, save = False): 
    URL = "https://www.google.com/maps/search/?api=1" 

    if(inputLoc  != ""):
        URL = URL +("&query={}".format(requests.utils.quote(inputLoc)))
    if(inputPlaceId != ""):
        URL = URL + ("&query_place_id={}".format(inputPlaceId)) 

    driver = webdriver.Firefox()
    driver.get(URL)

    WebDriverWait(driver, 15).until(
        EC.presence_of_element_located(
            (
                By.XPATH,
                "/html/body/div[2]/div[3]/div[8]/div[9]/div/div/div[1]/div[2]/div/div[1]/div/div/div[3]/div/div/button[2]/div[2]/div[2]",
            )
        )
    ).click()

    try:
        info = "/html/body/div[2]/div[3]/div[8]/div[9]/div/div/div[1]/div[2]/div/div[1]/div/div/div[2]/div[3]/div[2]/span/div[1]/button/span[1]/img"
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.XPATH, info))
        ).click()
        comments = "/html/body/div[2]/div[3]/div[8]/div[9]/div/div/div[1]/div[2]/div/div[1]/div/div/div[2]/div[11]/div"
        reviews = WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located((By.XPATH, comments))
        )
        reviewsCount = len(reviews)
        ActionChains(driver).key_down(Keys.END).perform()
        WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located(
                (By.XPATH, comments + "[{}]".format(reviewsCount + 1))
            )
        )
        reviews = WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located((By.XPATH, comments))
        )

        while len(reviews) > reviewsCount and len(reviews) < maxReviews * 3:
            reviewsCount = len(reviews)
            ActionChains(driver).key_down(Keys.END).perform()    
            WebDriverWait(driver,10).until(EC.presence_of_all_elements_located((By.XPATH,comments+"[{}]".format(reviewsCount+1)) ))
            reviews=WebDriverWait(driver,10).until(EC.presence_of_all_elements_located((By.XPATH,comments) ))
    except Exception as e:
        print(e)
    i = 0
    while i < len(reviews):
        if reviews[i].get_attribute("class") == "qCHGyb":
            del reviews[i]
        else:
            i += 1

    reviewsCount = len(reviews)
    #vzX5Ic
    
    for review in reviews:
        try:
            upper = review.find_elements(By.XPATH, "div/div/div")
            ind = len(upper) - 1
            if ind < 0:
                continue
            rating = upper[ind].find_elements(By.XPATH, "div/span/span")
            rate = len(
                [
                    elem
                    for elem in rating
                    if elem.get_attribute("class")
                    == "hCCjke vzX5Ic google-symbols NhBTye"
                ]
            )
            textandmore = upper[ind].find_elements(By.XPATH, "div[2]/div/span")
            if len(textandmore) > 1:
                textandmore[1].click()
                textandmore = WebDriverWait(upper[ind],10).until(EC.presence_of_all_elements_located((By.XPATH,"div[2]/div/span"))) 
            with lock:
                rewievsResult.append({"place": inputLoc ,"rating":rate,"review":clean_string(textandmore[0].text)})

        except Exception as e:
            print(e) 
    # Convert rewievsResult to JSON
    if save:
        json_data = json.dumps(rewievsResult, ensure_ascii=False)

        # Write JSON data to a file with utf-8 encoding
        with open("reviews.json", "a", encoding="utf-8") as file:
            file.write(json_data)
    
    driver.close()
    return rewievsResult

