import time
import queue
import random
import threading
from datetime import datetime
from driver_helper import DriverHelper
from config import NUM_URLS, LOGIN_PAGE
from report_generator import ReportGenerator

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from urllib.parse import urlencode, urlparse, parse_qs, urlunparse


class LoadTest:
    """Class to perform load testing using Selenium WebDriver."""

    WEBSITES = [
        "https://www.facebook.com",
        "https://www.twitter.com",
        "https://www.amazon.com",
        "https://www.wikipedia.org",
        "https://www.reddit.com",
        "https://www.netflix.com",
        "https://www.linkedin.com",
        "https://www.instagram.com",
        "https://www.github.com",
        "https://www.stackoverflow.com",
        "https://www.microsoft.com",
        "https://www.apple.com",
        "https://www.kenh14.vn",
        "https://phuclong.com.vn",
        "https://gongcha.com.vn",
        "https://www.highlandscoffee.com.vn",
        "https://katinat.vn",
        "https://starbucks.vn",
    ]

    def __init__(self, proxy, org, url, user, password, sessions, mode):
        """
        Initialize LoadTest instance.

        Args:
            proxy (str): Proxy server URL.
            org (str): Organization name.
            url (str): PAC file URL.
            user (str): Keycloak username.
            password (str): Keycloak password.
            num_sessions (int): Number of concurrent sessions.
            mode (str): Test mode - 'conc' for concurrent or 'seq' for sequential.
        """
        self.proxy = proxy
        self.org = org
        self.url = url
        self.user = user
        self.password = password
        self.sessions = sessions
        self.mode = mode
        self.results_queue = queue.Queue()
        self.error_queue = queue.Queue()

    def generate_login_url(self, base_url):
        """
        Generate the login URL by appending the organization name to the query string.

        Args:
            base_url (str): The base login URL.

        Returns:
            str: Updated login URL with the organization name appended.
        """
        parsed_url = urlparse(base_url)
        query_params = parse_qs(parsed_url.query)
        query_params["o"] = self.org
        updated_query = urlencode(query_params, doseq=True)
        updated_url = parsed_url._replace(query=updated_query)
        return urlunparse(updated_url)

    def get_extension_id(self, driver):
        """
        Retrieve the extension ID from chrome://extensions/.

        Args:
            driver: WebDriver instance.

        Returns:
            str: The ID of the extension.
        """
        driver.get("chrome://extensions/")
        time.sleep(1)

        # JavaScript to extract extension IDs from Shadow DOM
        js_code = """
        var extensionsManager = document.querySelector('extensions-manager');
        var extensionsItemList = extensionsManager.shadowRoot.querySelector('extensions-item-list');
        var extensionItem = extensionsItemList.shadowRoot.querySelector('extensions-item');
        if (extensionItem) {
            var extensionId = extensionItem.id;
            return extensionId;
        } else {
            return null;
        }
        """

        # Execute JavaScript to get the extension ID
        extension_id = driver.execute_script(js_code)
        if extension_id is None:
            print("No unique extension found or multiple extensions detected!")

        return extension_id

    def plugin_login(self, driver):
        """
        Perform login sequence for plugin mode.

        Args:
            driver: WebDriver instance.
        """

        base_login_page = f"{LOGIN_PAGE}"
        login_page = self.generate_login_url(base_login_page)
        driver.get(login_page)

        # Wait for Keycloak login button and click Text keyword "Sign with"
        keycloak_button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable(
                (
                    By.XPATH,
                    "//a[contains(@class, 'uk-button-primary') and contains(text(), 'Sign with')]",
                )
            )
        )
        keycloak_button.click()

        # Wait and input username & password
        username_field = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "username"))
        )
        username_field.send_keys(self.user)
        time.sleep(1)

        password_field = driver.find_element(By.ID, "password")
        password_field.send_keys(self.password)
        time.sleep(1)

        # Click Sign In button
        password_field.submit()

        # Switch to first tab
        driver.switch_to.window(driver.window_handles[0])

        # Get extension ID dynamically
        extension_id = self.get_extension_id(driver)

        # Open extension popup
        driver.execute_script(
            f"window.open('chrome-extension://{extension_id}/popup.html')"
        )
        driver.switch_to.window(driver.window_handles[-1])
        driver.get(f"chrome-extension://{extension_id}/popup.html")
        time.sleep(1)

        # Wait and ORG NAME && PAC FILE URL
        org_name_field = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "abbr-org"))
        )
        org_name_field.clear()
        org_name_field.send_keys(self.org)
        time.sleep(1)

        pac_url_field = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "pac-url"))
        )
        pac_url_field.clear()
        pac_url_field.send_keys(self.url)
        time.sleep(1)

        # Click Save button
        save_button = driver.find_element(
            By.XPATH,
            "//button[contains(@class, 'bg-green-500') and contains(text(), 'Save')]",
        )
        save_button.click()
        time.sleep(2)

        # Switch to first tab
        driver.switch_to.window(driver.window_handles[0])
        driver.get("https://www.google.com")

        # Close the extension popup tab
        for handle in driver.window_handles:
            driver.switch_to.window(handle)
            if driver.current_url == f"chrome-extension://{extension_id}/popup.html":
                driver.close()
                break

        # Switch back to the first tab (Google)
        driver.switch_to.window(driver.window_handles[0])

    def run_mode(self, driver, session_id):
        """
        Execute the test scenario based on the selected mode.

        Args:
            driver: WebDriver instance.
            session_id (int): Identifier for the session.
        """
        session_results = []
        if self.mode == "conc":
            # Concurrent mode: Open all tabs and measure performance
            driver.get("https://www.google.com")
            test_sites = random.sample(self.WEBSITES, NUM_URLS)
            for url in test_sites:
                driver.execute_script(f"window.open('{url}', '_blank');")

            # Browse all tabs and measure performance.
            for handle in driver.window_handles:
                driver.switch_to.window(handle)
                url = driver.current_url if driver.current_url else "Unknown"
                metrics = DriverHelper.measure_performance(url, driver)
                if metrics:
                    metrics["session_id"] = session_id
                    session_results.append(metrics)
                    self.results_queue.put(metrics)

        elif self.mode == "seq":
            # Sequential mode: Open tabs one by one
            test_sites = random.sample(self.WEBSITES, NUM_URLS)
            for url in test_sites:
                driver.execute_script(f"window.open('{url}', '_blank');")
                time.sleep(10)

        return session_results

    def session_worker(self, session_id):
        """
        Run a single load test session. Opens NUM_URLS = 10 tabs for testing simultaneously.

        Args:
            session_id (int): Identifier for the session.
        """
        input_proxy = self.proxy
        if "squid" in input_proxy.lower():
            use_proxy = True
            driver = DriverHelper.create_driver(self.proxy)

        elif "proxy" in input_proxy.lower():
            use_proxy = False
            driver = DriverHelper.create_driver(None)

        else:
            use_proxy = True
            driver = DriverHelper.create_driver(self.proxy)

        try:
            if use_proxy:
                # Proxy mode: Directly run the test scenario
                self.run_mode(driver, session_id)
            else:
                # Plugin mode: Login first, then run the test scenario
                self.plugin_login(driver)
                self.run_mode(driver, session_id)

        except Exception as e:
            self.error_queue.put(f"Session {session_id} error: {str(e)}")
        finally:
            driver.quit()

    def run_load_test(self):
        """
        Execute a load test by running multiple sessions concurrently.

        Returns:
            dict: A summary report generated by ReportGenerator.
        """
        threads = []
        start_time = datetime.now()

        # Start threads for each session
        for i in range(self.sessions):
            thread = threading.Thread(target=self.session_worker, args=(i,))
            threads.append(thread)
            thread.start()

        # Wait for all threads to finish
        for thread in threads:
            thread.join()

        end_time = datetime.now()

        # Collect results
        results = []
        while not self.results_queue.empty():
            results.append(self.results_queue.get())
        errors = []
        while not self.error_queue.empty():
            errors.append(self.error_queue.get())

        # Use ReportGenerator to generate the report
        return ReportGenerator.generate_report(
            results=results,
            start_time=start_time,
            end_time=end_time,
            errors=errors,
            session_count=self.sessions,
        )
