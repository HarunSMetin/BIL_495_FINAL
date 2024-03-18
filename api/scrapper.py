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
import pandas as pd
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from bs4 import BeautifulSoup as bs
import csv
import time
from scrape import Scrape, ScrapeObjects

start = time.time()
places_json = [
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
        for J in places_json:
            processes = []
            for data in J:
                processes.append(
                    Process(
                        target=_get_reviews, args=(data["name"], data["place_id"], lock)
                    )
                )
            for process in processes:
                process.start()
            for process in processes:
                process.join()
                print("Length Of rewievsResult {} ".format(len(rewievsResult)))

    return rewievsResult


def _get_reviews(inputLoc, inputPlaceId, lock, maxReviews=100, save=False):
    URL = "https://www.google.com/maps/search/?api=1"

    if inputLoc != "":
        URL = URL + ("&query={}".format(requests.utils.quote(inputLoc)))
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
                textandmore = WebDriverWait(upper[ind], 10).until(
                    EC.presence_of_all_elements_located((By.XPATH, "div[2]/div/span"))
                )
            with lock:
                rewievsResult.append(
                    {
                        "place": inputLoc,
                        "rating": rate,
                        "review": clean_string(textandmore[0].text),
                    }
                )

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


def _get_flights(from_, to, departure_date, return_date):
    result = Scrape(to, from_, departure_date, return_date)
    ScrapeObjects(result)

    result.data["Departure datetime"] = result.data["Departure datetime"].dt.strftime(
        "%Y-%m-%dT%H:%M:%S"
    )
    result.data["Arrival datetime"] = result.data["Arrival datetime"].dt.strftime(
        "%Y-%m-%dT%H:%M:%S"
    )
    result.data["Access Date"] = result.data["Access Date"].dt.strftime("%Y-%m-%d")

    aggregated_data = []
    for index, row in enumerate(result.data.to_dict("records")):
        row_data = {key: value for key, value in row.items() if key != "Airline(s)"}
        row_data["id"] = index
        aggregated_data.append(row_data)

    return aggregated_data


# _get_hotels(place, checkin, checkout)
def _get_hotels(place, checkin, checkout):

    driver = webdriver.Chrome()

    url = f"https://www.google.com/travel/hotels/{place}?g2lb=2502548%2C2503781%2C4258168%2C4270442%2C4306835%2C4308226%2C4317915%2C4328159%2C4371335%2C4401769%2C4419364%2C4463666%2C4482194%2C4482438%2C4486153%2C4491350%2C4495816%2C4504283%2C4270859%2C4284970%2C4291517&hl=en-IN&gl=in&ap=EgAwA2gB&q=hotels%20in%20{place}&rp=EL6UyOLs5vfPQRDotoKJvc_3vPQBELHWl5u8lMHO0AEQiNvdjujJnZRrOAFAAEgCogETQmh1YmFuZXN3YXIsIE9kaXNoYQ&ictx=1&sa=X&utm_campaign=sharing&utm_medium=link&utm_source=htls&ts=CAESABo3ChkSFToTQmh1YmFuZXN3YXIsIE9kaXNoYRoAEhoSFAoHCOUPEAIYGRIHCOUPEAIYGhgBMgIQACoPCgsoAUoCIAE6A0lOUhoA&ved=0CAAQ5JsGahcKEwiQ6qvDt4TvAhUAAAAAHQAAAAAQfw"
    driver.get(url)

    soup = bs(driver.page_source, "html.parser")

    ##### Hotel  #####
    hotel_names = soup.find_all("h2", class_="BgYkof ogfYpf ykx2he")[:5]

    #### RATING #####
    ratings = soup.find_all("span", class_="NPG4zc")[:5]

    #### Num of reviews ####
    num_reviews = soup.find_all("span", class_="sSHqwe uTUoTb XLC8M")[:5]

    for i in range(len(hotel_names)):
        review = num_reviews[i]
        wait = WebDriverWait(driver, 10)
        review_bt = wait.until(
            EC.element_to_be_clickable(
                (By.XPATH, f"//span[contains(text(),'{review.text}')]")
            )
        )
        review_bt.click()
        time.sleep(3)

    reviews = []

    for i in range(len(hotel_names), 0, -1):
        driver.switch_to_window(driver.window_handles[i])
        soup = bs(driver.page_source, "html.parser")
        hotel_reviews = soup.find_all("div", class_="K7oBsc")
        hotel_reviews_list = []
        for i in range(len(hotel_reviews)):
            hotel_review = str(hotel_reviews[i].div.span.text)
            try:
                if hotel_review.find(" ...") >= 0:
                    hotel_review = hotel_review.replace(" ...", "")
                next_review = str(
                    hotel_reviews[i + 1].div.span.text
                )  # sometimes detailed review is show when clicked on read more
                if next_review.find(hotel_review) >= 0:
                    continue
            except:
                pass
            hotel_reviews_list.append(hotel_review)
        reviews.append(hotel_reviews_list)

    #### WRITE TO CSV ####
    with open("hotels.csv", mode="w") as csv_file:
        fieldnames = ["Name", "Rating", "Reviews"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)

        writer.writeheader()
        for i in range(len(hotel_names)):
            hotel_reviews = reviews[i]
            review_text = "\n\n".join(hotel_reviews)
            writer.writerow(
                {
                    "Name": f"{hotel_names[i].text}",
                    "Rating": f"{ratings[i].span.text}",
                    "Reviews": f"{review_text}",
                }
            )
