import requests
from z_variable import Telegram_var

class TelegramReply:

    @staticmethod
    def invalid_command(chat_id):
        message_error = "Invalid command. Use /help for assistance."
        requests.post(f"{Telegram_var.telegram_token}/sendMessage", data={"chat_id": chat_id, "text": message_error})

    @staticmethod
    def list_command(chat_id):
        help_text = "Available commands:\n"
        help_text += "/check tan_binh\n"
        help_text += "/check binh_thanh\n"
        help_text += "/check quan_1\n"
        help_text += "/check quan_6\n"
        help_text += "/check quan_9\n"
        help_text += "/check quan_12\n"
        help_text += "/check go_vap\n"
        requests.post(f"{Telegram_var.telegram_token}/sendMessage", data={"chat_id": chat_id, "text": help_text})

    @staticmethod
    def help_command(chat_id):
        help_text = "Available commands:\n"
        help_text += "/check_list - Show list area \n"
        help_text += "/check <area> - Show cameras in the specified area\n"
        requests.post(f"{Telegram_var.telegram_token}/sendMessage", data={"chat_id": chat_id, "text": help_text})

    @staticmethod
    def invalid_area_command(chat_id, area):
        message_error = f"Area '{area}' does not exist. Please check again."
        requests.post(f"{Telegram_var.telegram_token}/sendMessage", data={"chat_id": chat_id, "text": message_error})
