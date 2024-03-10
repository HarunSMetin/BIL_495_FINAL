from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
import json
import time
import re


def clean_string(input_string):
    # Define regex pattern to match punctuation and special characters
    pattern = r"[^\w\s]|[\']/g"

    # Replace punctuation and special characters with spaces
    clean_string = re.sub(pattern, " ", input_string)

    return clean_string


# record start time
start = time.time()

inputLoc = "Quick China Ankara"  # "Mama's Burger Dikmen"
inputPlaceId = "ChIJCSA5AMBJ0xQRZFHOnCFE59M"  #'ChIJ83EOeClF0xQRpmgaAmrCMqA'
maxReviews = 1000


URL = "https://www.google.com/maps/search/?api=1"

if inputLoc != "":
    URL = URL + ("&query={}".format(inputLoc))
if inputPlaceId != "":
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
        WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located(
                (By.XPATH, comments + "[{}]".format(reviewsCount + 1))
            )
        )
        reviews = WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located((By.XPATH, comments))
        )
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
# vzX5Ic
rewievsResult = []
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
                if elem.get_attribute("class") == "hCCjke vzX5Ic google-symbols NhBTye"
            ]
        )
        textandmore = upper[ind].find_elements(By.XPATH, "div[2]/div/span")
        if len(textandmore) > 1:
            textandmore[1].click()
            textandmore = WebDriverWait(upper[ind], 10).until(
                EC.presence_of_all_elements_located((By.XPATH, "div[2]/div/span"))
            )

        rewievsResult.append(
            {
                "place": inputLoc,
                "rating": rate,
                "review": clean_string(textandmore[0].text),
            }
        )
    except Exception as e:
        print(e)
# record end time
end = time.time()

# print the difference between start
# and end time in milli. secs
print("The time of execution of above program is :", (end - start), "seconds.")
# Convert rewievsResult to JSON
json_data = json.dumps(rewievsResult, ensure_ascii=False)

# Write JSON data to a file with utf-8 encoding
with open("reviews.json", "w", encoding="utf-8") as file:
    file.write(json_data)
