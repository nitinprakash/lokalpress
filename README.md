# LokalPress Lite

🚀 **LokalPress Lite** is a lightweight, automated local WordPress development environment powered by **Lando** and **Docker**. It allows developers to quickly spin up a fully functional WordPress site without manual server configuration.

* * *

## Quick Reference

| Feature / Info | Details |
| --- | --- |
| Default Admin Username | admin |
| Default Admin Password | nimad |
| Local Site URL | Auto generated during installation (e.g., lokalpress.lndo.site) |
| Web Server | Apache (default for reliability) |
| Database | MariaDB 10.11 |
| Start Environment | lando start |
| Stop Environment | lando stop |
| View Logs | lando logs -s appserver |
| Composer Install | Optional, run if composer.json exists: lando composer install |
| Database Import | Optional, import db.sql: lando db-import db.sql |

> ⚠️ Make sure to add your chosen site URL to your hosts file if necessary.

* * *

## Table of Contents

1.  Overview
    
2.  Prerequisites
    
3.  Installation Instructions
    
4.  Setup Walkthrough
    
5.  Optional Steps
    
6.  Accessing Your Site
    
7.  Tips & Troubleshooting
    
8.  License
    

* * *

## Overview

**LokalPress Lite** provides an automated, reliable way to create a local WordPress environment. Features include:

*   Fully automated WordPress installation
    
*   Configurable database credentials
    
*   Composer integration for PHP dependencies
    
*   Optional database import via `db.sql`
    
*   Default admin login for quick access
    

Designed to **save time**, reduce setup errors, and let developers focus on **building and testing WordPress sites** locally.

* * *

## Prerequisites

Ensure your machine has:

1.  **Docker** – Required to run local containers.
    
    *   macOS: [Docker Desktop](https://docs.docker.com/desktop/install/mac/)
        
    *   Windows: [Docker Desktop](https://docs.docker.com/desktop/install/windows/)
        
    *   Ubuntu:  
        sudo apt update  
        sudo apt install -y docker.io  
        sudo systemctl start docker
        
2.  **Lando** – Manages WordPress, PHP, and database containers.
    
    *   [Lando installation guide](https://docs.lando.dev/getting-started/installation.html)
        

> ⚠️ Docker must be running before starting Lando.

* * *

## Installation Instructions

1.  Clone the repository:  
    git clone [https://github.com/nitinprakash/lokalpress.git](https://github.com/nitinprakash/lokalpress.git)  
    cd lokalpress
    
2.  Make the installer executable:  
    chmod +x install.sh
    
3.  Run the installer:  
    ./install.sh
    

The script will guide you through inputting your site details and database credentials.

* * *

## Setup Walkthrough

1.  **Enter Site Details**    
        
    *   Site Title: friendly name for your WordPress site.
        
2.  **Enter Database Credentials**
    
    *   Database Name: name for MariaDB database.
        
    *   Database User: username to access the database.
        
    *   Database Password: password for database user.
        
3.  **Confirm Your Inputs**
    
    *   Installer summarizes all inputs.
        
    *   If details are incorrect, you can re-enter them.
        
4.  **Automatic Lando Configuration**
    
    *   `.lando.yml` is generated using the provided inputs.
        
    *   Apache is used as the web server.
        
    *   MariaDB 10.11 is used as the database service.
        
5.  **Start Lando Environment**
    
    *   WordPress installed with default credentials:  
        Username: `admin`  
        Password: `nimad`
        

* * *

## Optional Steps

After installation, the installer can:

*   Run Composer Install – installs PHP dependencies if `composer.json` exists.
    
*   Import a Database – import a `db.sql` file into the local WordPress database.
    

> The installer prompts for each optional step to ensure full control.

* * *

## Accessing Your Site

*   Frontend: `http://<your-site-url>`
    
*   WordPress Admin: `http://<your-site-url>/wp-admin`
    
*   Admin Login: `admin / nimad`
    

> ⚠️ Add your site URL to the hosts file if required.

* * *

## Tips & Troubleshooting

*   Docker not running: start Docker Desktop before running the installer.
    
*   Lando issues: verify installation with `lando version`.
    
*   Database connection errors: ensure the MariaDB container is running and credentials match.
    
*   Restarting environment:  
    lando stop  
    lando start
    
*   Access logs:  
    lando logs -s appserver
    
*   Changing web server: Apache is default; advanced users can modify `.lando.yml` to use NGINX.
    

* * *

## License

LokalPress Lite is released under the **MIT License**.  
You are free to use, modify, and distribute this project with proper attribution.
