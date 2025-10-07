# LokalPress Lite (Cross-Platform Installer)

🚀 **LokalPress Lite** is a lightweight, automated local WordPress development environment powered by **Lando** and **Docker**.  
It allows developers to quickly spin up a fully functional WordPress site without manual server configuration.

---

## 🧭 Quick Reference

| Feature / Info       | Details |
|---------------------|---------|
| Default Admin Username | `admin` |
| Default Admin Password | `nimad` |
| Local Site URL         | Auto-generated during installation (e.g., `lokalpress.lndo.site`) |
| Web Server             | Apache (default for reliability) |
| Database               | MariaDB 10.11 |
| Start Environment      | `lando start` |
| Stop Environment       | `lando stop` |
| View Logs              | `lando logs -s appserver` |
| Composer Install       | `lando composer install` *(if composer.json exists)* |
| Database Import        | `lando db-import db.sql` |

> ⚠️ Make sure to add your chosen site URL to your hosts file if necessary.

---

## 📑 Table of Contents

1. [Overview](#overview)  
2. [Prerequisites](#prerequisites)  
3. [Installation Instructions](#installation-instructions)  
   - [For Linux](#for-linux)  
   - [For Windows (Git Bash / WSL)](#for-windows-git-bash--wsl)  
4. [Setup Walkthrough](#setup-walkthrough)  
5. [Composer Integration](#-composer-integration)  
6. [Optional Steps](#optional-steps)  
7. [Accessing Your Site](#accessing-your-site)  
8. [Tips & Troubleshooting](#tips--troubleshooting)  
9. [License](#license)  

---

## 🧩 Overview

**LokalPress Lite** provides an automated, reliable way to create a local WordPress environment.  

### Key Features

- Fully automated WordPress installation  
- Configurable database credentials  
- Composer integration for PHP dependencies, themes, and plugins  
- Optional database import via `db.sql`  
- Default admin login for quick access  

Designed to **save time**, reduce setup errors, and let developers focus on **building and testing WordPress sites locally**.

---

## ⚙️ Prerequisites

Ensure your machine has the following installed:

### 1. Docker
Required to run local containers.

#### Linux:
```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker

#### Windows:

Install **Docker Desktop** from:
👉 https://www.docker.com/products/docker-desktop

Start Docker Desktop before running the installer.

* * *

### 2\. Lando

Manages WordPress, PHP, and database containers easily.

#### Linux:

`curl -fsSL https://files.lando.dev/install.sh | bash`

#### Windows:

Download and install from:
👉 [https://docs.lando.dev/getting-started/installation.html](https://docs.lando.dev/getting-started/installation.html)

Then verify installation:

`lando version`

> ⚠️ Docker must be running before you start Lando or execute `install.sh`.

* * *

## Installation Instructions

### 🐧 Linux Installation

1.  Clone the repository:

    `git clone https://github.com/nitinprakash/lokalpress.git cd lokalpress`

2.  Make the installer executable:

    `chmod +x install.sh`

3.  Run the installer:

    `./install.sh`

* * *

### 🪟 Windows Installation

> Run all commands inside **Git Bash** or **WSL** (Windows Subsystem for Linux).
> Do **not** use PowerShell or CMD.

1.  Clone the repository:

    `git clone https://github.com/nitinprakash/lokalpress.git cd lokalpress`

2.  Run the installer:

    `bash install.sh`

3.  Follow the prompts to enter:
    -   Site title
    -   Database name, user, and password
    -   Confirm configuration

The script will automatically generate `.lando.yml`, start Lando, and install WordPress.

* * *

## Setup Walkthrough

1.  **Enter Site Details**
    Provide a descriptive site title.

2.  **Enter Database Credentials**
    -   Database Name
    -   Database User
    -   Database Password
3.  **Confirm Your Inputs**
    The installer summarizes your configuration before proceeding.

4.  **Automatic Lando Configuration**
    -   `.lando.yml` generated automatically
    -   Apache as web server
    -   MariaDB 10.11 as database
    -   Site URL like `mysite.lndo.site`
5.  **Composer Setup (Optional)**
    If `composer.json` exists, you’ll be prompted to install dependencies:

    `lando composer install`

6.  **WordPress Installation**
    WordPress core is downloaded and configured automatically.
    Default login credentials:

    -   **Username:** `admin`
    -   **Password:** `nimad`
* * *

## Optional Steps

After installation, you can:

-   **Run Composer Install**
    Installs PHP dependencies if `composer.json` exists.

-   **Import a Database**
    Import your own SQL dump:

    `lando db-import db.sql`

Both steps are optional and prompted automatically by the installer.

* * *

## Accessing Your Site

| Type | URL Example |
| --- | --- |
| **Frontend** | `http://mysite.lndo.site` |
| **Admin Panel** | `http://mysite.lndo.site/wp-admin` |

**Login:**
`admin / nimad`

> ⚠️ If the site doesn’t open, add the hostname to your system’s `hosts` file:
>
> -   **Linux/macOS:** `/etc/hosts`
>
> -   **Windows:** `C:\Windows\System32\drivers\etc\hosts`
>

Add:

`127.0.0.1 mysite.lndo.site`

* * *

## Tips & Troubleshooting

-   **Docker not running:** Start Docker Desktop or `systemctl start docker`.
-   **Lando issues:** Verify with `lando version`.
-   **Database errors:** Ensure the `database` service is running inside Lando.
-   **Restart environment:**

    `lando stop lando start`

-   **Check logs:**

    `lando logs -s appserver`

-   **Changing web server:**
    Modify `.lando.yml` to use NGINX if desired.

* * *

## License

LokalPress Lite is released under the **MIT License**.
You are free to use, modify, and distribute this project with proper attribution.

* * *

> 🧩 **Coming Soon:** Full macOS compatibility.

