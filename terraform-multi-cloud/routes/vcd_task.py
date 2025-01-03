import requests


class VCDTask:
    """
    A class containing constants and methods for interacting with VMware Cloud Director APIs.

    Attributes:
        header_accept: Default header for API requests, specifying JSON format and API version.
        vcd_url_authen_basic: Endpoint for basic authentication in VMware Cloud Director.
        vcd_list_vdc: Endpoint for listing virtual data centers (VDCs).
        vcd_list_org: Endpoint for listing organizations.
        vcd_list_networks_api: Endpoint for listing organizational VDC networks.
        vcd_list_template: Endpoint for listing vApp templates with pagination.
    """

    header_accept = "application/json;version=39.0.0-alpha-1709254007"
    vcd_url_authen_basic = "api/sessions"
    vcd_list_vdc = "cloudapi/1.0.0/vdcs"
    vcd_list_org = "cloudapi/1.0.0/orgs"
    vcd_list_networks_api = "cloudapi/1.0.0/orgVdcNetworks"
    vcd_list_template = "cloudapi/1.0.0/appTemplates?page=1&pageSize=1000"

    @staticmethod
    def authenticate_vcd_account(url_provider, client_username, client_api_token):
        """
        Authenticate to the vCloud Director using client API token.

        Args:
            url_provider: Base URL of the vCloud Director provider.
            client_username: Client username in the format 'user@org_name'.
            client_api_token: API token for authentication.

        Returns:
            Bearer token if successful, otherwise None.
        """
        try:
            org_name = client_username.split("@")[1]
            url = f"{url_provider}/oauth/tenant/{org_name}/token"
            headers = {
                "Accept": VCDTask.header_accept,
                "Content-Type": "application/x-www-form-urlencoded",
            }
            body = f"grant_type=refresh_token&refresh_token={client_api_token}"
            response = requests.post(url, headers=headers, data=body, timeout=15)

            if response.status_code == 200:
                return response.json().get("access_token")
            else:
                print("Failed to retrieve token:", response.status_code, response.text)
        except Exception as e:
            print("Error during authentication:", str(e))

        return None

    @staticmethod
    def fetch_data(url, token):
        """
        Helper function to make a GET request to the vCloud Director API.

        Args:
            url: Full API endpoint URL.
            token: Bearer token for authentication.

        Returns:
            Parsed JSON response as a list of values, or an empty list on failure.
        """
        try:
            headers = {
                "Accept": VCDTask.header_accept,
                "Authorization": f"Bearer {token}",
            }
            response = requests.get(url, headers=headers, timeout=15)
            if response.status_code == 200:
                return response.json().get("values", [])
            else:
                print(
                    f"Failed to fetch data from {url}: {response.status_code}, {response.text}"
                )
        except Exception as e:
            print(f"Error fetching data from {url}:", str(e))

        return []

    @staticmethod
    def list_organizations(url_provider, token):
        """
        Retrieve the list of organizations.

        Args:
            url_provider: Base URL of the vCloud Director provider.
            token: Bearer token for authentication.

        Returns:
            Sorted list of organizations by name.
        """
        url = f"{url_provider}/{VCDTask.vcd_list_org}"
        organizations = VCDTask.fetch_data(url, token)
        return sorted(
            [
                {
                "name": org.get("name", "")
                }
                for org in organizations
            ],
            key=lambda x: x["name"],
        )

    @staticmethod
    def list_vdcs(url_provider, token):
        """
        Retrieve the list of Virtual Data Centers (vDCs).

        Args:
            url_provider: Base URL of the vCloud Director provider.
            token: Bearer token for authentication.

        Returns:
            Sorted list of vDCs by name.
        """
        url = f"{url_provider}/{VCDTask.vcd_list_vdc}"
        vdcs = VCDTask.fetch_data(url, token)
        return sorted(
            [
                {
                    "name": vdc.get("name", "")
                }
                for vdc in vdcs
            ],
            key=lambda x: x["name"]
        )

    @staticmethod
    def list_networks(url_provider, token):
        """
        Retrieve the list of networks.

        Args:
            url_provider: Base URL of the vCloud Director provider.
            token: Bearer token for authentication.

        Returns:
            Sorted list of networks by name.
        """
        url = f"{url_provider}/{VCDTask.vcd_list_networks_api}"
        networks = VCDTask.fetch_data(url, token)
        return sorted(
            [
                {
                    "name": network.get("name", "")
                }
                for network in networks
            ],
            key=lambda x: x["name"],
        )

    @staticmethod
    def list_templates(url_provider, token):
        """
        Retrieve the list of vApp templates.

        Args:
            url_provider: Base URL of the vCloud Director provider.
            token: Bearer token for authentication.

        Returns:
            Sorted list of vApp templates by name.
        """
        url = f"{url_provider}/{VCDTask.vcd_list_template}"
        app_templates = VCDTask.fetch_data(url, token)
        return sorted(
            [
                {
                    "vAppName": app_template.get("name", "")
                }
                for app_template in app_templates
            ],
            key=lambda x: x["vAppName"],
        )

    @staticmethod
    def list_catalogs(url_provider, token):
        """
        Retrieve the list of catalogs.

        Args:
            url_provider: Base URL of the vCloud Director provider.
            token: Bearer token for authentication.

        Returns:
            Sorted list of catalogs by name.
        """
        url = f"{url_provider}/{VCDTask.vcd_list_template}"
        app_templates = VCDTask.fetch_data(url, token)
        catalog_names = [
            {
                "catalogName": app_template.get("catalog", {}).get("name", "")
            }
            for app_template in app_templates
        ]
        unique_catalogs = list(
            {catalog["catalogName"]: catalog for catalog in catalog_names}.values()
        )
        return sorted(unique_catalogs, key=lambda x: x["catalogName"])
