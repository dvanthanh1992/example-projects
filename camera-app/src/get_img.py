import os
import requests
import time
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from z_variable import Telegram_var

class WebScraper:

    @staticmethod
    def get_camera_gt(area, camera_url, folder_path):
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--ignore-certificate-errors")
        chrome_options.add_argument("--no-sandbox")
        driver = webdriver.Chrome(service=ChromeService(
            ChromeDriverManager().install()),
            options=chrome_options)
        driver.get(camera_url)
        time.sleep(3)
        screenshot_name = f"{area}-{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
        screenshot_path = os.path.join(folder_path, screenshot_name)
        driver.save_screenshot(screenshot_path)
        driver.quit()

    @staticmethod
    def send_and_cleanup_imgs(chat_id, folder_path):
        files_in_folder = [
            f for f in os.listdir(folder_path) 
            if os.path.isfile(os.path.join(folder_path, f))
        ]

        png_paths = [
            os.path.join(folder_path, f) 
            for f in files_in_folder 
            if f.lower().endswith('.png')
        ]

        for png_path in png_paths:
            with open(png_path, 'rb') as img_file:
                files = {'document': (os.path.basename(png_path), img_file)}
                response = requests.post(
                    f"{Telegram_var.telegram_token}/sendDocument",
                    data={"chat_id": chat_id},
                    files=files
                )
            os.remove(png_path)
