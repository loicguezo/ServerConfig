# Auto-Notification

This repository contains two Bash scripts designed for monitoring user logins and system disk usage. Notifications are sent via **Telegram Bot**. Below is a detailed explanation of each script, their functionality, and how to set them up.

---

## Scripts Overview

### 1. **PAM Hook Script**
- **Purpose:** Monitors user sessions (login and logout) and sends notifications via Telegram whenever a user connects or disconnects from the system.
- **Trigger:** The script is invoked by **PAM (Pluggable Authentication Module)** during session events (e.g., SSH login).
- **Notification Content:**
  - Username (`$PAM_USER`)
  - Remote host (`$PAM_RHOST`)
  - Timestamp (`$(date)`)

---

### 2. **Disk Monitoring Script**
- **Purpose:** Monitors disk usage on the root filesystem (`/`) and sends an alert if the usage exceeds a predefined threshold.
- **Trigger:** Can be run manually, or scheduled to run periodically using **Cron**.
- **Notification Content:**
  - Current disk usage percentage.
  - Total disk size, used space, and available space.

---

## Prerequisites

1. **Linux Environment:**
   - Both scripts are designed to work on Linux systems.
   - Ensure **PAM** is available for the login monitoring script.

2. **Telegram Bot Setup:**
   - Create a Telegram bot by talking to [BotFather](https://core.telegram.org/bots#botfather).
   - Save the bot token (`TOKEN`).
   - Get your `CHAT_ID` by sending a message to the bot and using an API call like:
     ```bash
     curl https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
     ```
   - Add these variables (`TOKEN` and `CHAT_ID`) to the `.env` file.

3. **Environment File (`.env`):**
   - Place the `.env` file in `/etc/serverconfig/.env`.
   - Example `.env` file:
     ```bash
     TOKEN=your_bot_token_here
     CHAT_ID=your_chat_id_here
     ```

4. **Dependencies:**
   - Ensure `curl` is installed:
     ```bash
     sudo apt install curl
     ```

---
## Installation & Configuration

### 1. **PAM Hook Script**

1. **Place the Script:**
   - Save the script as `/usr/local/bin/sshd-login.sh`.
   - Make it executable:
     ```bash
     sudo chmod +x /usr/local/bin/sshd-login.sh
     ```

2. **Configure PAM:**
   - Edit the PAM configuration for the service you want to monitor. For SSH:
     ```bash
     sudo nano /etc/pam.d/sshd
     ```
   - Add the following line to trigger the script:
     ```bash
     session optional pam_exec.so /usr/local/bin/sshd-login.sh
     ```

3. **Test the Setup:**
   - Log in and out of the system via SSH.
   - Check Telegram for notifications.

---

### 2. **Disk Monitoring Script**

1. **Place the Script:**
   - Save the script as `/usr/local/bin/disk-monitor.sh`.
   - Make it executable:
     ```bash
     sudo chmod +x /usr/local/bin/disk-monitor.sh
     ```

2. **Run Manually:**
   - Execute the script with a threshold percentage:
     ```bash
     /usr/local/bin/disk-monitor.sh
     ```

3. **Automate with Cron:**
   - Schedule the script to run periodically:
     ```bash
     crontab -e
     ```
   - Add a cron job, e.g., to check disk usage every hour:
     ```bash
     0 * * * * /usr/local/bin/disk-monitor.sh
     ```

---

## Security Considerations

1.	Restrict Access to Scripts and .env:
- Ensure only root or authorized users can access these files:
```
sudo chmod 600 /etc/serverconfig/.env
sudo chmod 700 /usr/local/bin/sshd-login.sh
sudo chmod 700 /usr/local/bin/disk-monitor.sh
```

---
## Conclusion

These scripts provide a lightweight solution for real-time session monitoring and disk usage alerts via Telegram. By integrating with PAM and automating periodic checks, they enhance system monitoring and improve administrator response time to critical events.