import re
import asyncio
import paramiko
import asyncssh


def parse_cpu_usage(cpu_line):
    """
    Parse CPU usage from Linux top command output
    Returns total CPU usage percentage
    """
    try:
        pattern = r"(\d+\.\d+)\s*us,\s*(\d+\.\d+)\s*sy,\s*(\d+\.\d+)\s*ni"
        match = re.search(pattern, cpu_line)

        if match:
            us = float(match.group(1))
            sy = float(match.group(2))
            ni = float(match.group(3))
            cpu_usage = us + sy + ni
            return round(cpu_usage, 2)
        return 0
    except Exception as e:
        print(f"CPU parsing error: {e}")
        return 0


async def get_system_metrics(host, username, password):
    """
    Collect system metrics for a given host
    Returns dictionary with hostname, CPU, RAM metrics
    """
    ssh = None
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname=host, username=username, password=password, timeout=5)

        commands = {
            "hostname": "hostname",
            "ip": "hostname -I | awk '{print $1}'",
            "cpu": "top -bn1 | grep 'Cpu(s)'",
            "memory": "cat /proc/meminfo | grep -E '^MemTotal|^MemFree|^MemAvailable'",
        }

        results = {}
        for key, cmd in commands.items():
            stdin, stdout, stderr = ssh.exec_command(cmd)
            results[key] = stdout.read().decode().strip()

        mem_data = {}
        for line in results["memory"].split("\n"):
            try:
                key, value = line.split(":")
                mem_data[key.strip()] = int(value.strip().split()[0])
            except ValueError:
                print(f"Invalid memory line: {line}")
                continue

        total_mem = mem_data.get("MemTotal", 0)
        available_mem = mem_data.get("MemAvailable", 0)
        used_mem = total_mem - available_mem
        total_gb = round(total_mem / 1024 / 1024, 2)
        used_gb = round(used_mem / 1024 / 1024, 2)
        mem_percent = round((used_mem / total_mem) * 100, 2) if total_mem > 0 else 0

        return {
            "hostname": results["hostname"],
            "ip": results["ip"],
            "cpu": f"{parse_cpu_usage(results['cpu'])}%",
            "ram": f"{used_gb}GB/{total_gb}GB ({mem_percent}%)",
        }
    except Exception as e:
        print(f"Error collecting metrics for {host}: {e}")
        return {"hostname": "N/A", "ip": "N/A", "cpu": "N/A", "ram": "N/A"}


async def restart_selenium_node(host, username, password):
    """
    Restart Selenium Node on the given host via SSH.
    """
    try:
        async with asyncssh.connect(
            host, username=username, password=password, known_hosts=None
        ) as conn:
            result = await conn.run("bash selenium_node.sh restart", check=True)
            if result.exit_status == 0:
                print(f"Selenium node restarted successfully on {host}")
                return {"success": True, "output": result.stdout.strip()}
            else:
                print(
                    f"Selenium node restart failed on {host} with exit code {result.exit_status}"
                )
                return {"success": False, "error": result.stderr.strip()}
    except asyncssh.Error as e:
        print(f"SSH error while restarting Selenium node on {host}: {e}")
        return {"success": False, "error": f"SSH Error: {str(e)}"}
    except Exception as e:
        print(f"Unexpected error on {host}: {e}")
        return {"success": False, "error": f"Unexpected Error: {str(e)}"}


async def restart_all_containers(servers):
    """
    Restart Selenium Nodes on all servers concurrently.
    Returns a list of results for each server.
    """

    async def restart_with_timeout(server, timeout=10):
        try:
            return await asyncio.wait_for(
                restart_selenium_node(
                    server["host"], server["username"], server["password"]
                ),
                timeout=timeout,
            )
        except asyncio.TimeoutError:
            print(f"Timeout while restarting Selenium node on {server['host']}")
            return {"success": False, "error": "Timeout"}
        except Exception as e:
            print(f"Unexpected error on {server['host']}: {e}")
            return {"success": False, "error": str(e)}

    tasks = [restart_with_timeout(server) for server in servers]
    results = await asyncio.gather(*tasks, return_exceptions=True)

    final_results = []
    for server, result in zip(servers, results):
        if isinstance(result, dict):
            # Success or failure captured
            final_results.append({"host": server["host"], **result})
        else:
            # Unexpected exception
            final_results.append(
                {"host": server["host"], "success": False, "error": str(result)}
            )

    return final_results
