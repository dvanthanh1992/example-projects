import os
import time
from config import EXTENSION_FILE
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait


class DriverHelper:
    """Helper class to manage Selenium WebDriver operations."""

    @staticmethod
    def create_driver(proxy=None):
        """
        Initialize a Selenium WebDriver with optional proxy configuration.

        Args:
            proxy (str, optional): Proxy server URL.

        Returns:
            WebDriver: Configured Selenium WebDriver instance.
        """
        extension_path = os.path.join(
            os.path.dirname(__file__), "extension", EXTENSION_FILE
        )
        grid_url = "http://192.168.145.191:4444/wd/hub"

        chrome_options = webdriver.ChromeOptions()
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--ignore-certificate-errors")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")

        if proxy:
            chrome_options.add_argument(f"--proxy-server={proxy}")
        else:
            chrome_options.add_extension(extension_path)
        return webdriver.Remote(command_executor=grid_url, options=chrome_options)

    @staticmethod
    def measure_performance(url, driver):
        """
        Measure website performance metrics.

        Args:
            url (str): URL to test.
            driver (WebDriver): Selenium WebDriver instance.

        Returns:
            dict: Performance metrics (load time, DOMContentLoaded, etc.).
        """
        start_time = time.time()
        try:
            driver.get(url)
            WebDriverWait(driver, 20).until(
                lambda d: d.execute_script("return document.readyState") == "complete"
            )
            navigation_timing = driver.execute_script(
                """
                let timing = performance.timing;
                return {
                    loadTime: timing.loadEventEnd - timing.navigationStart,
                    domContentLoaded: timing.domContentLoadedEventEnd - timing.navigationStart,
                    firstPaint: timing.responseStart - timing.navigationStart,
                    backend: timing.responseEnd - timing.requestStart
                };
            """
            )
            total_time = time.time() - start_time
            return {
                "url": url,
                "total_time": total_time,
                **navigation_timing,
            }
        except Exception as e:
            return {
                "url": url or "Unknown",
                "error": f"Error loading {url}: {str(e)}",
            }
