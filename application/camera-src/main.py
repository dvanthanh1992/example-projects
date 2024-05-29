import time
from telegram import TelegramTask

offset = 0
while True:
    offset = TelegramTask.process_telegram_messages(offset)
    time.sleep(1)
