# System Health Check Automation

Automated health check system for monitoring multiple servers using Cocoon workflow automation framework.

> **One-Command Execution** - Check the health of all your servers with a single command!

## Quick Start

### One-Command Execution (Recommended)

**Prerequisites:**
- `curl` or `wget` installed
- `git` installed
- Python 3.x with `pip`
- SSH access to target servers

**Step 1: Create your servers.yaml file**

Create a `servers.yaml` file in your current directory with your server list:

```yaml
all_servers:
  - ip: "10.49.74.104"
    username: "admin"
    password: "your_password"

  - ip: "10.49.74.102"
    username: "admin"
    password: "your_password"
```

**That's it! Only 3 fields required per server: ip, username, password**

**Step 2: Run the health check**

**Linux/Mac:**
```bash
curl -sSL https://raw.githubusercontent.com/DebalGhosh100/health_checkup/main/run_health_check.sh | bash
```

**Windows (PowerShell):**
```powershell
iwr -useb https://raw.githubusercontent.com/DebalGhosh100/health_checkup/main/run_health_check.ps1 | iex
```

The script will automatically:
1. Detect your `servers.yaml` in the current directory
2. Copy it to the storage directory
3. Clone the Cocoon framework temporarily
4. Install dependencies (paramiko, pyyaml)
5. Execute health checks on all configured servers
6. Generate reports in `./health_reports/`
7. Clean up framework files automatically

---

## Features

✅ **Parallel Execution** - Check multiple servers simultaneously  
✅ **Comprehensive Checks** - System info, memory, disk, CPU, network, and services  
✅ **Real-time Logging** - Stream logs from remote servers to local files  
✅ **Service Monitoring** - Verify critical services are running  
✅ **Docker Support** - Check Docker containers status  
✅ **Detailed Reports** - Generate comprehensive health reports for each server  

---

## Manual Installation

If you prefer to run manually:

### Step 1: Clone Both Repositories

```bash
# Clone the Cocoon framework
git clone https://github.com/DebalGhosh100/blocks.git

# Clone this health checkup project
git clone https://github.com/YOUR_USERNAME/health_checkup.git
cd health_checkup
```

### Step 2: Install Dependencies

```bash
pip install -r ../blocks/requirements.txt
```

### Step 3: Configure Servers

Create a `servers.yaml` file in the project root with your servers:

```yaml
all_servers:
  - ip: "10.49.74.104"
    username: "admin"
    password: "secure_password"

  - ip: "10.49.74.105"
    username: "admin"
    password: "secure_password"
```

**Only 3 fields required per server!** No need for name, environment, or role fields.

### Step 4: Configure Services to Monitor

Edit `storage/services.yaml` to customize which services to check:

```yaml
critical_services:
  - sshd
  - nginx
  - mysql
  - docker
  - redis
```

### Step 5: Run Health Check

```bash
python3 ../blocks/blocks_executor.py main.yaml
```

---

## Project Structure

```
health_checkup/
├── servers.yaml           # YOUR server list (create this!)
├── main.yaml              # Main workflow definition
├── servers.yaml.example   # Example server configuration
├── storage/               # Configuration files (auto-populated)
│   ├── servers.yaml       # Copied from root automatically
│   └── services.yaml      # Services to monitor
├── health_reports/        # Generated reports (created automatically)
│   ├── <ip>_health.log    # System health report per server
│   └── <ip>_services.log  # Services status per server
└── README.md              # This file
```

---

## What Gets Checked

### System Health Checks (Sequential)

For each server, the following information is collected:

1. **System Information**
   - OS details
   - Kernel version
   - Architecture

2. **Uptime**
   - System uptime
   - Current load

3. **Memory Usage**
   - Total/Used/Free memory
   - Swap usage

4. **Disk Usage**
   - All mounted filesystems
   - Available space

5. **CPU Information**
   - Model name
   - Number of cores
   - Thread count

6. **Load Average**
   - 1, 5, 15 minute load averages

7. **Running Processes**
   - Top 10 processes by memory usage

8. **Network Interfaces**
   - IP addresses
   - MAC addresses

9. **Active Network Connections**
   - Listening ports
   - Established connections

### Service Health Checks (Parallel)

All servers are checked simultaneously for:

1. **Critical Services Status**
   - Checks if each configured service is running
   - Uses systemctl for service management

2. **Docker Containers** (if Docker is installed)
   - Lists all running containers
   - Shows container status and ports

---

## Monitoring Live Progress

While the health check is running, you can monitor progress in real-time:

**Monitor all system health checks:**
```bash
tail -f ./health_reports/*_health.log
```

**Monitor all service checks:**
```bash
tail -f ./health_reports/*_services.log
```

**Monitor a specific server:**
```bash
tail -f ./health_reports/10.49.74.104_health.log
```

---

## Generated Reports

After execution, you'll find reports in `./health_reports/`:

### System Health Report Format
```
<ip>_health.log - Contains:
├── System Information
├── Uptime and Load
├── Memory Usage
├── Disk Usage
├── CPU Information
├── Running Processes
├── Network Configuration
└── Active Connections
```

### Service Status Report Format
```
<ip>_services.log - Contains:
├── Service Status (✓ Running / ✗ Not Running)
└── Docker Container Status (if applicable)
```

---

## Viewing Reports

**List all reports:**
```bash
ls -lh ./health_reports/
```

**View a specific report:**
```bash
cat ./health_reports/10.49.74.104_health.log
```

**View all reports concatenated:**
```bash
cat ./health_reports/*_health.log
```

**Search for issues across all reports:**
```bash
grep -i "error\|fail\|not running" ./health_reports/*.log
```

---

## Customization

### Adding More Servers

Simply add entries to your `servers.yaml`:

```yaml
all_servers:
  - ip: "192.168.1.100"
    username: "admin"
    password: "password"

  - ip: "192.168.1.101"
    username: "admin"
    password: "password"
```

**That's it!** Just 3 fields: ip, username, password

### Adding More Services to Monitor

Edit `storage/services.yaml`:

```yaml
critical_services:
  - sshd
  - nginx
  - your-custom-service
```

### Customizing Health Checks

Edit `main.yaml` to add custom checks. For example, to check disk space warnings:

```yaml
run: |
  echo "--- Disk Space Warnings ---"
  df -h | awk '$5+0 > 80 {print "WARNING: " $6 " is " $5 " full"}'
```

---

## Scheduling Regular Health Checks

### Using Cron (Linux/Mac)

Run health checks every day at 2 AM:

```bash
crontab -e
```

Add this line:
```
0 2 * * * cd /path/to/health_checkup && curl -sSL https://raw.githubusercontent.com/DebalGhosh100/blocks/main/run_blocks.sh | bash -s main.yaml storage >> health_check.log 2>&1
```

### Using Task Scheduler (Windows)

1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (daily at 2 AM)
4. Action: Start a program
5. Program: `powershell.exe`
6. Arguments: `-File C:\path\to\run_health_check.ps1`

Create `run_health_check.ps1`:
```powershell
cd C:\path\to\health_checkup
iwr -useb https://raw.githubusercontent.com/DebalGhosh100/blocks/main/run_blocks.ps1 | iex
```

---

## Troubleshooting

### SSH Connection Issues

**Problem:** Cannot connect to server

**Solutions:**
- Verify IP address is correct
- Check SSH credentials
- Test manual SSH: `ssh user@host`
- Ensure firewall allows SSH (port 22)

### Permission Denied for Service Checks

**Problem:** Cannot check service status

**Solutions:**
- Some service checks require sudo privileges
- Update the health check command to use sudo:
  ```yaml
  run: echo "password" | sudo -S systemctl status service_name
  ```

### Missing Dependencies

**Problem:** `paramiko` or `pyyaml` not found

**Solutions:**
```bash
pip install paramiko>=3.4.0 pyyaml>=6.0
```

---

## Best Practices

1. **Secure Credentials**
   - Don't commit passwords to git
   - Use environment variables or secrets management
   - Consider SSH key authentication instead of passwords

2. **Regular Monitoring**
   - Schedule health checks daily or hourly
   - Set up alerts for critical issues
   - Archive old reports regularly

3. **Report Analysis**
   - Review disk usage trends
   - Monitor memory consumption patterns
   - Track service availability

4. **Customize for Your Stack**
   - Add checks specific to your applications
   - Monitor custom metrics
   - Alert on threshold violations

---

## Advanced Usage

### Filtering by Environment

To check only production servers, modify the loop in `main.yaml`:

```yaml
- for:
    individual: server
    in: ${servers.production_servers}  # Create this in servers.yaml
    run-remotely:
      # ... health check commands
```

### Adding Email Alerts

Add an email notification block at the end of `main.yaml`:

```yaml
- run: |
    echo "Health check completed" | mail -s "Health Check Report" admin@example.com
```

### Integrating with Monitoring Tools

Export reports to your monitoring system:

```yaml
- run: |
    curl -X POST https://your-monitoring-tool.com/api/reports \
      -H "Content-Type: application/json" \
      -d @./health_reports/summary.json
```

---

## Example Output

```
============================================
   System Health Check - Starting
   Time: Wed Nov 20 10:30:00 UTC 2025
============================================

[1/3] Checking Web Server 1 (10.49.74.104)...
[2/3] Checking Web Server 2 (10.49.74.102)...
[3/3] Checking Database Server (10.107.237.21)...

============================================
   Health Check Summary
============================================

Reports generated in ./health_reports/

Available reports:
-rw-r--r-- 1 user user 4.2K Nov 20 10:30 10.49.74.104_health.log
-rw-r--r-- 1 user user 4.1K Nov 20 10:30 10.49.74.102_health.log
-rw-r--r-- 1 user user 4.3K Nov 20 10:30 10.107.237.21_health.log

--- Quick Summary ---
Total servers checked: 3

Health check completed at: Wed Nov 20 10:31:15 UTC 2025
============================================
```

---

## Contributing

Found a bug or want to add a feature? Contributions are welcome!

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## License

This project uses the Cocoon framework. Please refer to the main Cocoon repository for licensing information.

---

## Related Projects

- **Cocoon Framework**: https://github.com/DebalGhosh100/blocks
- **Cocoon Examples**: https://github.com/DebalGhosh100/blocks/tree/main/examples

---

## Support

For issues or questions:
- Open an issue on GitHub
- Check the Cocoon framework documentation
- Review the examples in the main Cocoon repository

---

**Happy Monitoring! 🏥**

Keep your infrastructure healthy with automated checks!
