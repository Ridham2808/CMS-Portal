<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=00BFFF&height=200&section=header&text=Complaint%20Management%20System&fontSize=50&fontAlignY=35&desc=Next-Gen%20Ticketing%20Platform&descAlignY=55&descAlign=50" alt="CMS Banner" />

  <h2>🌟 A Futuristic Complaint Management & Ticketing Ecosystem 🌟</h2>
  <p>
    Seamlessly resolve, track, and manage user complaints with a robust Java Servlet architecture, real-time WebSocket notifications, and an aesthetically superior User Interface.
  </p>
  
  <br/>
  <a href="https://cms-portal-8jiy.onrender.com" target="_blank">
    <img src="https://img.shields.io/badge/🔴_LIVE_DEMO_-CLICK_HERE_TO_OVERSIGHT-00F0FF?style=for-the-badge&logo=render&logoColor=black&labelColor=2b2b2b" alt="Live Demo Button" />
  </a>
  <br/><br/>

  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/Java-11+-orange.svg?style=for-the-badge&logo=java" alt="Java">
    <img src="https://img.shields.io/badge/Render-Deployed-46E3B7.svg?style=for-the-badge&logo=render&logoColor=white" alt="Render">
    <img src="https://img.shields.io/badge/Aiven-MySQL%20Cloud-FF3A3A.svg?style=for-the-badge&logo=mysql&logoColor=white" alt="Aiven">
    <img src="https://img.shields.io/badge/Docker-Containerized-2496ED.svg?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
    <img src="https://img.shields.io/badge/WebSockets-Real%20Time-black.svg?style=for-the-badge&logo=socket.io" alt="Websockets">
  </p>
</div>

---

## 🚀 Features

Our system is engineered to handle complex user grievances efficiently, ensuring 100% transparency and instantaneous feedback.

- 🔐 **Multi-Role Authentication**: Secure login for `Admin`, `Technician`, and `User`.
- 🎫 **Smart Ticketing**: Lodge complaints with priorities, categories, and severity tags.
- ⚡ **Real-Time Updates**: Instant alerts powered by **WebSockets (wss://)**. No page refreshes!
- 📊 **Futuristic Dashboard**: Glassmorphism UI, advanced filtering, and instant data previews (Powered by Chart.js).
- 👨‍🔧 **Technician Portal**: Dedicated portal for technicians to pick up tickets, update status, and close issues.
- ☁️ **Cloud Native**: Pre-configured for Docker, Render deployments, and Aiven Cloud Database.

---

## 🛠️ Tech Stack & Architecture

### **System Architecture Diagram**

```mermaid
graph TD
    %% Define Styles
    classDef client fill:#003366,stroke:#00BFFF,stroke-width:3px,color:#fff;
    classDef cloud fill:#2b2b2b,stroke:#46E3B7,stroke-width:3px,color:#fff;
    classDef db fill:#4A148C,stroke:#FF3A3A,stroke-width:3px,color:#fff;
    classDef realTime fill:#880E4F,stroke:#F48FB1,stroke-width:3px,color:#fff;

    %% Nodes
    A[🧑‍💻 Modern Browser Client<br>HTML / CSS / JS]:::client
    B[Render Web Service<br>Apache Tomcat container]:::cloud
    C[(Aiven Cloud MySQL<br>defaultdb)]:::db
    D[⚡ NotificationServer<br>WSS Endpoint on Render]:::realTime

    %% Relationships
    A -->|HTTPS GET/POST Request| B
    B <-->|JDBC API Connection| C
    B -.->|Generates JSP Response| A
    
    A <-->|Secure WSS Connection| D
    B -.->|Triggers Update| D
```

### **Core Components**
* **Frontend**: JSP, HTML5, CSS3, Vanilla JS (Glassmorphism UI)
* **Backend Engine**: Java Servlets, JSTL running on Tomcat 9.0
* **Real-time Logic**: `javax.websocket` Api (Supports both local `ws://` and production `wss://`)
* **Database**: Hosted remotely on **Aiven** MySQL 8.
* **Build System**: Apache Maven (`pom.xml`) & Docker (`Dockerfile`).

---

## 📂 Project Structure

```text
📦 cms-portal
 ┣ 📂 src/main/
 ┃ ┣ 📂 java/com/cms/
 ┃ ┃ ┣ 📂 dao/           # Data Access Objects (DB handlers)
 ┃ ┃ ┣ 📂 model/         # Java Beans / Entities
 ┃ ┃ ┣ 📂 servlet/       # Request Controllers
 ┃ ┃ ┣ 📂 util/          # Utilities (DatabaseConfig injected by Render Env)
 ┃ ┃ ┗ 📂 websocket/     # Real-time Servers
 ┃ ┗ 📂 webapp/          # Frontend & WEB-INF
 ┃   ┣ 📂 css/           # Styling & Animations
 ┃   ┣ 📜 WEB-INF/       # web.xml Deployment Descriptor
 ┃   ┣ 📜 index.jsp      # Landing Page
 ┃   ┗ 📜 ...            # Other Dashboards & Views
 ┣ 📜 pom.xml            # Maven Dependencies & Build
 ┣ 📜 Dockerfile         # Docker instructions for Render Cloud
 ┣ 📜 schema.sql         # DB Setup Scripts
 ┣ 📜 alter.sql          # DB Modifications
 ┗ 📜 README.md          # You are here!
```

---

## 🌐 Cloud Deployment Guide (Render + Aiven)

This project has been successfully containerized and deployed to the internet! Here is how the cloud ecosystem works:

### 1️⃣ Database (Aiven Cloud)
Instead of relying on a local MySQL engine, the tables (`schema.sql` & `alter.sql`) were injected into a free MySQL 8 cluster hosted on **Aiven**. 
* Because Aiven protects the DB creation rights and enforces the `defaultdb` name, the SQL scripts are optimized to run sequentially via the `mysql` CLI without `CREATE DATABASE` commands.

### 2️⃣ Web Service (Render.com)
The frontend and backend monolithic `.war` package is hosted on **Render**. 
* We created a multi-stage `Dockerfile` that uses `maven:3.8.4-openjdk-11` to clean and compile the project, and then seamlessly hands it over to `tomcat:9.0-jdk11` to run the active servlets.
* **Security:** Instead of hardcoding the Aiven Database password inside the public GitHub code, `DatabaseConfig.java` pulls the secret dynamically using `System.getenv("AIVEN_PASSWORD")`. The password is securely stored as an Environment Variable inside the Render Dashboard to respect GitHub's Push Protection policies.

---

## ⚙️ How to Setup & Run locally

### 1️⃣ Prerequisites
- **Java JDK 11+** installed.
- **Apache Maven** installed.
- **MySQL Server** installed and running.

### 2️⃣ Database Configuration
1. Login to your local MySQL server: `mysql -u root -p`
2. Create the database and import the schemas.
3. **Configure connection details**: Open `src/main/java/com/cms/util/DatabaseConfig.java` and type in your local MySQL password where the fallback string expects it.

### 3️⃣ Build and Run
1. Open up a terminal in the root project folder.
2. Build the project using Maven:
   ```bash
   mvn clean install
   ```
3. Run the embedded Tomcat server via Maven Plugin:
   ```bash
   mvn tomcat7:run
   ```
4. Access the futuristic CMS Portal at:  
   👉 **http://localhost:9090/**

---

<div align="center">
  <p>Built with ❤️. Taking ticket management to the cloud.</p>
</div>
