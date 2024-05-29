import os
import requests
from error_cmt import TelegramReply
from get_img import WebScraper
from z_variable import Telegram_var, CameraURLs

class TelegramTask:
    @staticmethod
    def identify_messages(chat_id, text):
        parts = text.split()
        if len(parts) == 1 and parts[0].lower() == "/help":
            TelegramReply.help_command(chat_id)
        elif len(parts) == 1 and parts[0].lower() == "/check_list":
            TelegramReply.list_command(chat_id)
        elif len(parts) == 2 and parts[0].lower() == "/check":
            area = parts[1].lower()
            camera_urls = CameraURLs().get_urls_for_area(area)
            folder_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "screenshots")
            os.makedirs(folder_path, exist_ok=True)
            if camera_urls:
                for url in camera_urls:
                    WebScraper.get_camera_gt(area, url, folder_path)
                WebScraper.send_and_cleanup_imgs(chat_id, folder_path)
            else:
                TelegramReply.invalid_area_command(chat_id, area)
        else:
            TelegramReply.invalid_command(chat_id)

    @staticmethod
    def get_updates(offset):
        with requests.get(f"{Telegram_var.telegram_token}/getUpdates?offset={offset}") as response:
            return response.json()

    @staticmethod
    def process_telegram_messages(offset):
        updates = TelegramTask.get_updates(offset)
        message_count = len(updates.get("result", []))
        if message_count > 0:
            i = message_count - 1
            message = updates["result"][i].get("message", {})
            chat_id = message.get("chat", {}).get("id")
            text = message.get("text")
            if message and text:
                TelegramTask.identify_messages(chat_id, text)
            update_id = updates["result"][i].get("update_id")
            offset = update_id + 1
        return offset
