import json
import subprocess


class AzureTask:
    """
    A utility class for managing Azure resources using Azure CLI.

    This class provides methods for logging into Azure using username and password
    and retrieving a list of subscriptions and resources in a subscription.
    """

    @staticmethod
    def login_azure(azure_username, azure_password):
        """
        Login to Azure using Azure CLI with username and password.

        Args:
            username (str): The username for authentication.
            password (str): The password for authentication.

        Raises:
            Exception: If login fails.
        """
        try:
            subprocess.run(
                ["az", "login", "-u", azure_username, "-p", azure_password],
                check=True,
                capture_output=True,
            )
            print("Login successful.")
        except subprocess.CalledProcessError as e:
            print("Login failed.")
            raise ValueError(e.stderr.decode()) from e

    @staticmethod
    def get_all_subscription_ids():
        """
        Retrieve all subscription IDs for the logged-in Azure account.

        Returns:
            list: A list of subscription IDs.
        """
        try:
            result = subprocess.run(
                ["az", "account", "list", "--query", "[].id", "-o", "json"],
                check=True,
                capture_output=True,
                text=True,
            )
            subscription_ids = json.loads(result.stdout)
            return subscription_ids
        except subprocess.CalledProcessError as e:
            print("Failed to retrieve subscription IDs.")
            raise ValueError(e.stderr.decode()) from e

    @staticmethod
    def get_resource_groups(subscription_id):
        """
        Get a list of resource groups in a subscription.

        Args:
            subscription_id (str): The subscription ID for Azure.

        Returns:
            list: A list of resource groups with their names and locations.
        """
        result = subprocess.run(
            ["az", "group", "list", "--subscription", subscription_id, "-o", "json"],
            check=True,
            capture_output=True,
            text=True,
        )
        resource_groups = json.loads(result.stdout)
        resource_group_names = [
            group["name"] for group in resource_groups
            ]
        return resource_group_names
