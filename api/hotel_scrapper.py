from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains 
from selenium.webdriver.common.keys import Keys
from datetime import datetime 
import re
import requests 
from enum import Enum
from time import sleep 
from bs4 import BeautifulSoup
import json

class HotelType(Enum):
    spa = 0
    hostel = 1
    boutique = 2
    bed_and_breakfast = 3
    beach = 4
    motel = 5
    apartment = 6
    inn = 7
    resort = 8
    other = 9

class HotelOptions(Enum):
    free_wifi = 0
    free_breakfast = 1
    restaurant = 2
    bar = 3
    kid_friendly = 4
    pet_friendly = 5
    free_parking = 6
    parking = 7
    ev_charger = 8
    room_service = 9
    fitness_center = 10
    spa = 11
    pool = 12
    indoor_pool = 13
    outdoor_pool = 14
    air_conditioned = 15
    wheelchair_accessible = 16
    beach_access = 17
    all_inclusive_available = 18

class Hotel_Api:

    #USAGE : 
    #findHotel("Istanbul" ,  "2024-05-18", "2024-06-01",2000, 3000, stars=[4,5], hotelType=['spa', 'hostel'], hotelOptions=['free_wifi', 'free_breakfast'], adults=2, childeren= 0)
    def __init__(self):
        pass 
    
    def findHotel( self, queryString:str ,checkin:str , checkout:str, budgetLower:int ,budgetUpper:int ,stars =[] , hotelType =[] ,hotelOptions = [], adults = 1, childeren = 0):
        URL = "https://www.google.com/travel" 

        if(queryString  != ""):
            URL = URL +("/search?q={}".format(requests.utils.quote(queryString)))

        options = webdriver.ChromeOptions()
        options.add_experimental_option('prefs', {'intl.accept_languages': 'en,en_US'})
        options.add_experimental_option("detach", True)
        driver = webdriver.Chrome(options=options)   
        driver.get(URL)
        driver.maximize_window() 
        sleep(2)

        self.setFilters(stars, hotelType, hotelOptions, driver)
        self.setDate(checkin, checkout, driver)
        self.setPeopleCount(adults, childeren, driver)
        #self.setBudget(budgetLower, budgetUpper, driver)
        result = {"relevance":{}, "lowest_price":{}, "highest_rating":{}, "most_viewed":{}}
        
        hotels_Path = "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[2]/div[2]/main/c-wiz/span/c-wiz/c-wiz"
        search_index = 0
        for i in ["relevance", "lowest_price", "highest_rating", "most_viewed"]:
            if search_index != 0 :
                self.setSearchIndex(search_index, driver)

            hotels = WebDriverWait(driver, 15).until(
                EC.presence_of_all_elements_located(
                    (
                        By.XPATH,
                        hotels_Path,
                    )
                )
            ) 
            hotelIndex=0

            for h in hotels: 
                hotelIndex = hotelIndex + 1
                if h.get_attribute("jsrenderer") == "hAbFdb": 
                    HTMLInner = h.get_attribute('innerHTML')
                    soup = BeautifulSoup(HTMLInner, 'html.parser')
                    hotel_name = soup.find("h2", class_="BgYkof").text.strip()
                    print("Hotel Name:", hotel_name)

                    starting_price =int(self.remove_non_decimal_chars(soup.find("span", class_="qQOQpe").text.strip()))
                    print("Starting Price:", starting_price)

                    amenities = [item.text.strip() for item in soup.select(".RJM8Kc .XX3dkb .QYEgn")]
                    print("Amenities:", amenities)
                    
                    try:
                        hotel_rate = float(soup.find("span", class_="KFi5wf lA0BZ").text.strip() )
                        print("Hotel Rate:", hotel_rate)
                    except Exception as e:
                        print(e)
                        hotel_rate = 0

                    try:
                        hotel_review_count = int(self.remove_non_decimal_chars(soup.find("span", class_="jdzyld XLC8M").text.strip()))
                        print("Hotel Review Count:", hotel_review_count)
                    except Exception as e:
                        print(e)
                        hotel_review_count = 0

                    href_attribute = "https://www.google.com" +soup.find("div").find("a")["href"]
                    print("Href Attribute:", href_attribute)  
                    
                    result[i][hotelIndex] = {
                        "hotel_name": hotel_name,
                        "starting_price": starting_price,
                        "amenities": amenities,
                        "hotel_rate": hotel_rate,
                        "hotel_review_count": hotel_review_count,
                        "href_attribute": href_attribute
                    }
                    
            search_index = search_index + 1

        return json.dumps(result, indent=4, ensure_ascii=False)

    def setDate(self, checkin:str, checkout:str, driver):
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[2]/div/div/div[2]/div[1]/div/input",
                )
            )
        ).click()
        checkinDate = self.convert_to_date(checkin)
        checkoutDate = self.convert_to_date(checkout) 
        
        checkinDay=checkinDate.day
        checkinMonth=checkinDate.month
        checkinYear=checkinDate.year
        checkoutDay=checkoutDate.day
        checkoutMonth=checkoutDate.month
        checkoutYear=checkoutDate.year

        now = datetime.now().date()
        months_difference_start_now = (checkinYear - now.year ) * 12 + abs(checkinMonth- now.month ) 
        print("Difference in months:", months_difference_start_now) 
        for i in range(0, months_difference_start_now):
            WebDriverWait(driver, 15).until(
                EC.element_to_be_clickable(
                    (
                        By.XPATH,
                        "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[2]/div/div[2]/div/div[2]/div[3]/div[1]/div/div/div[3]/div/div/button",
                    )
                )
            ).click()

        
        monthsXPATH = "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[2]/div/div[2]/div/div[2]/div[3]/div[1]/div/div/div[1]/div/div[{}]".format(months_difference_start_now+1)+"/div[3]"
 
        weeks = WebDriverWait(driver, 15).until(
            EC.presence_of_all_elements_located(
                (
                    By.XPATH,
                    monthsXPATH,
                )
            )
        )  
        matchday = str(checkinDay)
        for week in weeks:
            days = week.find_elements(By.XPATH, "div") 
            COUNT_WEEK = 1
            for day in days:
                COUNT_DAY = 1
                for singleday in day.find_elements(By.XPATH, "div"):
                    if singleday.text.strip() == matchday:
                        dayList = day.find_elements(By.XPATH, "div")
                        if dayList:
                            dayList[-1].click()
                        break 
                    COUNT_DAY += 1
                COUNT_WEEK += 1
 
        months_difference_end_start = (checkoutYear - checkinYear ) * 12 + abs(checkoutMonth - checkinMonth)
        print("Difference in months:", months_difference_end_start)
        for i in range(0, months_difference_end_start):
            WebDriverWait(driver, 15).until(
                EC.element_to_be_clickable(
                    (
                        By.XPATH,
                        "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[2]/div/div[2]/div/div[2]/div[3]/div[1]/div/div/div[3]/div/div/button",
                    )
                )
            ).click()
        monthsXPATH = "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[2]/div/div[2]/div/div[2]/div[3]/div[1]/div/div/div[1]/div/div[{}]".format(months_difference_start_now + months_difference_end_start+1)+"/div[3]"
 
        weeks = WebDriverWait(driver, 15).until(
            EC.presence_of_all_elements_located(
                (
                    By.XPATH,
                    monthsXPATH,
                )
            )
        ) 
        matchday= str(checkoutDay)
        for week in weeks:
            days = week.find_elements(By.XPATH, "div") 
            COUNT_WEEK = 1
            for day in days:  
                COUNT_DAY = 1
                for singleday in day.find_elements(By.XPATH, "div"):
                    if singleday.text.strip() == matchday:
                        dayList = day.find_elements(By.XPATH, "div")
                        if dayList:  
                            dayList[-1].click()
                        break 
                    COUNT_DAY += 1
                COUNT_WEEK += 1
        
        WebDriverWait(driver, 15).until(
            EC.element_to_be_clickable(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[2]/div/div[2]/div/div[2]/div[4]/div/button[2]",
                )
            )
        ).click()

    def setPeopleCount(self, adults, childs, driver):
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[3]/div/div/div/div[1]/div",
                )
            )
        ).click()

        adultsCount= int ( WebDriverWait(driver, 15).until(
            EC.presence_of_element_located(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[3]/div/div/div/div[2]/div[2]/div[1]/div[1]/div[2]/div/span[2]",
                )
            )
        ).text)
        a = adults-adultsCount
        if a > 0:
            for i in range(a):
                WebDriverWait(driver, 15).until(
                    EC.element_to_be_clickable(
                        (
                            By.XPATH,
                            "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[3]/div/div/div/div[2]/div[2]/div[1]/div[1]/div[2]/div/span[3]/button",
                        )
                    )
                ).click()
        elif a < 0:
            for i in range(abs(a)):
                WebDriverWait(driver, 15).until(
                    EC.element_to_be_clickable(
                        (
                            By.XPATH,
                            "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[3]/div/div/div/div[2]/div[2]/div[1]/div[1]/div[2]/div/span[1]/button",
                        )
                    )
                ).click()
        else:
            pass

        childsCount= int ( WebDriverWait(driver, 15).until(
            EC.presence_of_element_located(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[3]/div/div/div/div[2]/div[2]/div[1]/div[2]/div[2]/div/span[2]/span[1]",
                )
            )
        ).text)

        c = childs-childsCount
        if c > 0:
            for i in range(c):
                WebDriverWait(driver, 15).until(
                    EC.element_to_be_clickable(
                        (
                            By.XPATH,
                            "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[3]/div/div/div/div[2]/div[2]/div[1]/div[2]/div[2]/div/span[3]/button",
                        )
                    )
                ).click()
        elif c < 0:
            for i in range(abs(c)):
                WebDriverWait(driver, 15).until(
                    EC.element_to_be_clickable(
                        (
                            By.XPATH,
                            "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[3]/div/div/div/div[2]/div[2]/div[1]/div[2]/div[2]/div/span[1]/button",
                        )
                    )
                ).click()
        else:
            pass
        
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[1]/div[3]/div/div/div/div[2]/div[2]/div[2]/div[2]/button",
                )
            )
        ).click()

    def setFilters(self,stars ,hotelType, hotelOptions, driver):
        
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[2]/div[1]/div/div/div[1]/div/button",
                )
            )
        ).click()         
        

  
        if len(hotelType)!= 0: 
            hotelTypesList = WebDriverWait(driver, 15).until(
                EC.presence_of_all_elements_located(
                    ( 
                        By.XPATH,
                        "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[2]/div[1]/div/div[2]/div[3]/div/div[2]/div/div[1]/div/div/section[3]/div/div[2]/div/div",
                    )
                )
            )
            for element in hotelType:
                if element == HotelType.spa.name:
                    hotelTypesList[0].click()
                elif element == HotelType.hostel.name:
                    hotelTypesList[1].click()
                elif element == HotelType.boutique.name:
                    hotelTypesList[2].click()
                elif element == HotelType.bed_and_breakfast.name:
                    hotelTypesList[3].click()
                elif element == HotelType.beach.name:
                    hotelTypesList[4].click()
                elif element == HotelType.motel.name:
                    hotelTypesList[5].click()
                elif element == HotelType.apartment.name:
                    hotelTypesList[6].click()
                elif element == HotelType.inn.name:
                    hotelTypesList[7].click()
                elif element == HotelType.resort.name:
                    hotelTypesList[8].click()
                elif element == HotelType.other.name:
                    hotelTypesList[9].click()

        if len(hotelOptions)!= 0:
            hotelOptionsList = WebDriverWait(driver, 15).until(
                EC.presence_of_all_elements_located(
                    (
                        By.XPATH,
                        "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[2]/div[1]/div/div[2]/div[3]/div/div[2]/div/div[1]/div/div/section[7]/div/div[1]/div/div/div/div",
                    )
                )
            ) 
            for element in hotelOptions:
                if element == HotelOptions.free_wifi.name:
                    hotelOptionsList[0].click()
                elif element == HotelOptions.free_breakfast.name:
                    hotelOptionsList[1].click()
                elif element == HotelOptions.restaurant.name:
                    hotelOptionsList[2].click()
                elif element == HotelOptions.bar.name:
                    hotelOptionsList[3].click()
                elif element == HotelOptions.kid_friendly.name:
                    hotelOptionsList[4].click()
                elif element == HotelOptions.pet_friendly.name:
                    hotelOptionsList[5].click()
                elif element == HotelOptions.free_parking.name:
                    hotelOptionsList[6].click()
                elif element == HotelOptions.parking.name:
                    hotelOptionsList[7].click()
                elif element == HotelOptions.ev_charger.name:
                    hotelOptionsList[8].click()
                elif element == HotelOptions.room_service.name:
                    hotelOptionsList[9].click()
                elif element == HotelOptions.fitness_center.name:
                    hotelOptionsList[10].click()
                elif element == HotelOptions.spa.name:
                    hotelOptionsList[11].click()
                elif element == HotelOptions.pool.name:
                    hotelOptionsList[12].click()
                elif element == HotelOptions.indoor_pool.name:
                    hotelOptionsList[13].click()
                elif element == HotelOptions.outdoor_pool.name:
                    hotelOptionsList[14].click()
                elif element == HotelOptions.air_conditioned.name:
                    hotelOptionsList[15].click()
                elif element == HotelOptions.wheelchair_accessible.name:
                    hotelOptionsList[16].click()
                elif element == HotelOptions.beach_access.name:
                    hotelOptionsList[17].click()
                elif element == HotelOptions.all_inclusive_available.name:
                    hotelOptionsList[18].click()

        starsList = WebDriverWait(driver, 15).until(
            EC.presence_of_all_elements_located(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[2]/div[1]/div/div[2]/div[3]/div/div[2]/div/div[1]/div/div/section[6]/div/div/div/div",
                )
            )
        ) 
        if len(stars) == 0:
            stars = [2,3,4,5]
        print(len(starsList))
        for element in stars:
            if element == 2:
                starsList[0].click()
            elif element == 3:
                starsList[1].click()
            elif element == 4:
                starsList[2].click()
            elif element == 5:
                starsList[3].click()
    
    def setSearchIndex(self, index, driver):
        try: 
            WebDriverWait(driver, 15).until(
                EC.element_to_be_clickable(
                    (
                        By.XPATH,
                        "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[2]/div[1]/div/div/div[1]/div/button",
                    )
                )
            ).click()         

            WebDriverWait(driver, 15).until(
                EC.presence_of_element_located(
                    (
                        By.XPATH,
                        "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[2]/div[1]/div/div[2]/div[3]/div/div[2]/div/div[1]/div/div/section[1]/div/div/div/div["+str(index+1)+"]/div/input", 
                    )  
                )
            ).click()      

            WebDriverWait(driver, 15).until(
                EC.element_to_be_clickable(
                    (
                        By.XPATH,
                        "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[1]/c-wiz/div/div/div[1]/div/div[2]/div[1]/div/div/div[1]/div/button",
                    )
                )
            ).click()     
        except Exception as e:
            print(e)
            pass
    
    def setBudget(self, budgetLower, budgetUpper, driver):
        budgetButtonsList = WebDriverWait(driver, 15).until(
            EC.presence_of_all_elements_located(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[2]/div[2]/main/c-wiz/span/c-wiz/c-wiz[1]/div[1]/div/div", 
                )
            )
        ) 
        WebDriverWait(driver, 15).until(
            EC.element_to_be_clickable(
                (
                    By.XPATH,
                    
                   f"/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[2]/div[2]/main/c-wiz/span/c-wiz/c-wiz[1]/div[1]/div/div[{len(budgetButtonsList)}]", 
                )
            )
        ).click()  
        WebDriverWait(driver, 15).until(
            EC.element_to_be_clickable(
                (
                    By.XPATH,
                    
                   f"/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[2]/div[2]/main/c-wiz/span/c-wiz/c-wiz[1]/div[1]/div/div[{len(budgetButtonsList)}]", 
                )
            )
        ).click() 
        budgetOptions = WebDriverWait(driver, 15).until(
            EC.presence_of_all_elements_located(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[2]/div[2]/main/c-wiz/span/c-wiz/c-wiz[1]/div[2]/div[1]/div/div[2]/span/c-wiz/div[1]/div/div[1]/div",
                )
            )
        )
        for option in budgetOptions:  
            price = int(self.remove_non_decimal_chars(option.find_element(By.CLASS_NAME, "Ey6Xve").text))
            
            print("price" , price)
            if price >= budgetLower and price <= budgetUpper: 
                
                first = option.find_element(By.CLASS_NAME, "UpMUPd").find_element(By.CLASS_NAME, "VbKBg") 
                first.click() 
        
        WebDriverWait(driver, 15).until(
            EC.element_to_be_clickable(
                (
                    By.XPATH,
                    "/html/body/c-wiz[2]/div/c-wiz/div[1]/div[1]/div[2]/div[2]/main/c-wiz/span/c-wiz/c-wiz[1]/div[2]/div[1]/div/div[2]/span/c-wiz/div[1]/div/div[2]/div[2]/button"
                )
            )
        ).click()   

    def clean_string(input_string):
        # Define regex pattern to match punctuation and special characters
        pattern = r"[^\w\s]|[\']/g"

        # Replace punctuation and special characters with spaces
        clean_string = re.sub(pattern, " ", input_string)

        return clean_string
    def convert_to_date(self , input_str:str):
         
        try:
            return datetime.strptime(input_str, '%Y-%m-%d').date()
        except ValueError:
            pass
    def remove_non_decimal_chars(self,input_string):
        try:
            print("remove_non_decimal_chars: ", input_string)
            return re.sub(r'[^\d]', '', input_string)
        except ValueError:
            return 0  