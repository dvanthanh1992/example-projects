import ssl
from pyVmomi import vim
from pyVim.connect import SmartConnect, Disconnect


class VMwareTask:
    """
    A utility class for managing VMware vCenter tasks.

    This class provides methods for interacting with VMware vCenter Server,
    such as retrieving data about datacenters, clusters, datastores, folders,
    resource pools, and other related objects.

    All methods are static and require a valid `service_instance` object
    obtained by logging into vCenter Server.
    """

    @staticmethod
    def login_vcenter(vcenter_host, vcenter_user, vcenter_pass):
        """
        Login to vCenter Server.

        Args:
            vcenter_host (str): The hostname or IP address of the vCenter Server.
            vcenter_user (str): The username to authenticate with.
            vcenter_pass (str): The password to authenticate with.

        Returns:
            service_instance: An instance of the connection to vCenter Server.
        """
        ssl_context = ssl.create_default_context()
        ssl_context.check_hostname = False
        ssl_context.verify_mode = ssl.CERT_NONE
        service_instance = SmartConnect(
            host=vcenter_host,
            user=vcenter_user,
            pwd=vcenter_pass,
            sslContext=ssl_context,
        )
        return service_instance

    @staticmethod
    def logout_vcenter(service_instance):
        """
        Logout from vCenter Server.

        Args:
            service_instance: The service instance of the active vCenter session.
        """
        Disconnect(service_instance)

    @staticmethod
    def get_datacenters(service_instance):
        """
        Get a list of datacenters in vCenter Server.

        Args:
            service_instance: The service instance of the vCenter session.

        Returns:
            list: A sorted list of datacenter names.
        """
        content = service_instance.RetrieveContent()
        datacenters = []
        for datacenter in content.rootFolder.childEntity:
            if isinstance(datacenter, vim.Datacenter):
                datacenters.append(datacenter.name)
        return sorted(datacenters)

    @staticmethod
    def get_clusters(service_instance):
        """
        Get a list of clusters in vCenter Server.

        Args:
            service_instance: The service instance of the vCenter session.

        Returns:
            list: A sorted list of cluster names.
        """
        content = service_instance.RetrieveContent()
        clusters = []
        for datacenter in content.rootFolder.childEntity:
            if hasattr(datacenter, "hostFolder"):
                cluster_view = datacenter.hostFolder.childEntity
                for cluster in cluster_view:
                    if isinstance(cluster, vim.ClusterComputeResource):
                        clusters.append(cluster.name)
        return sorted(clusters)

    @staticmethod
    def get_datastores(service_instance):
        """
        Get a list of datastores in vCenter Server.

        Args:
            service_instance: The service instance of the vCenter session.

        Returns:
            list: A sorted list of datastore names.
        """
        content = service_instance.RetrieveContent()
        datastores = []
        for datacenter in content.rootFolder.childEntity:
            if hasattr(datacenter, "datastoreFolder"):
                datastore_view = datacenter.datastoreFolder.childEntity
                for datastore in datastore_view:
                    if isinstance(datastore, vim.Datastore):
                        datastores.append(datastore.name)
        return sorted(datastores)

    @staticmethod
    def get_folders(service_instance):
        """
        Get a list of VM folders in vCenter Server.

        Args:
            service_instance: The service instance of the vCenter session.

        Returns:
            list: A sorted list of folder names.
        """
        content = service_instance.RetrieveContent()
        folders = []
        for datacenter in content.rootFolder.childEntity:
            if hasattr(datacenter, "vmFolder"):
                folder_stack = [datacenter.vmFolder]
                while folder_stack:
                    folder = folder_stack.pop()
                    if isinstance(folder, vim.Folder):
                        folders.append(folder.name)
                        folder_stack.extend(folder.childEntity)
        return sorted(folders)

    @staticmethod
    def get_resource_pools(service_instance):
        """
        Get a list of resource pools in vCenter Server.

        Args:
            service_instance: The service instance of the vCenter session.

        Returns:
            list: A sorted list of resource pool names.
        """

        def collect_resource_pools(resource_pool, pools):
            """
            Recursively collect resource pools from a given resource pool.

            Args:
                resource_pool: The current resource pool to process.
                pools (list): The list to store resource pool names.
            """
            pools.append(resource_pool.name)
            if hasattr(resource_pool, "resourcePool"):
                for child_pool in resource_pool.resourcePool:
                    collect_resource_pools(child_pool, pools)

        content = service_instance.RetrieveContent()
        resource_pools = []

        for datacenter in content.rootFolder.childEntity:
            if hasattr(datacenter, "hostFolder"):
                cluster_view = datacenter.hostFolder.childEntity
                for cluster in cluster_view:
                    if isinstance(cluster, vim.ClusterComputeResource):
                        if cluster.resourcePool:
                            collect_resource_pools(cluster.resourcePool, resource_pools)

        return sorted(resource_pools)

    @staticmethod
    def get_network_portgroups(service_instance):
        """
        Get a list of network portgroups in vCenter Server.

        Args:
            service_instance: The service instance of the vCenter session.

        Returns:
            list: A sorted list of network portgroup names.
        """
        content = service_instance.RetrieveContent()
        portgroups = []
        for datacenter in content.rootFolder.childEntity:
            if hasattr(datacenter, "networkFolder"):
                network_view = datacenter.networkFolder.childEntity
                for network in network_view:
                    if isinstance(network, vim.dvs.DistributedVirtualPortgroup):
                        portgroups.append(network.name)
        return sorted(portgroups)

    @staticmethod
    def get_templates(service_instance):
        """
        Get a list of VM templates in vCenter Server.

        Args:
            service_instance: The service instance of the vCenter session.

        Returns:
            list: A sorted list of VM template names.
        """
        content = service_instance.RetrieveContent()
        templates = []

        def collect_templates(folder):
            """
            Recursively collect VM templates from folders.

            Args:
                folder: The current folder to process.
            """
            for entity in folder.childEntity:
                if (
                    isinstance(entity, vim.VirtualMachine)
                    and entity.config
                    and entity.config.template
                ):
                    templates.append(entity.name)
                elif isinstance(entity, vim.Folder):
                    collect_templates(entity)

        for datacenter in content.rootFolder.childEntity:
            if hasattr(datacenter, "vmFolder"):
                collect_templates(datacenter.vmFolder)

        return sorted(templates)
