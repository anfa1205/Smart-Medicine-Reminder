# Smart Medicine Reminder & Dose Tracker 💊

A console-based **Smart Medicine Reminder & Dose Tracker** developed using **8086 Assembly Language** in **EMU8086**.

The program allows users to manage medicines, schedule doses, check reminders, track taken doses, and monitor daily compliance.

---

## 📌 Project Overview

The **Smart Medicine Reminder & Dose Tracker** is a menu-driven 8086 Assembly Language project designed to help users organize their medicine schedules.

The program can store up to **9 medicines**, with each medicine supporting **1 to 3 doses**. Each dose can be assigned an hour from **0 to 23**.

---

## ✨ Features

### 1. Add New Medicine

Add a medicine by entering its name, number of doses, and scheduled time for each dose.

### 2. View All Reports

View all stored medicines, their dose times, and whether each dose is **Taken** or **Not Taken**.

### 3. Time Query

Enter an hour to find which medicines are scheduled to be taken at that time.

### 4. Mark Taken

Select a medicine and dose to mark it as **Taken**.

### 5. Delete Medicine

Delete a stored medicine. The remaining medicine records are shifted to keep the data organized.

### 6. Daily Compliance

View the total number of doses and how many doses have been marked as taken.

---

## 🛠️ Technologies Used

| Technology             | Purpose                               |
| ---------------------- | ------------------------------------- |
| 8086 Assembly Language | Core programming language             |
| EMU8086                | Development and simulation            |
| DOS Interrupts         | Keyboard input and console output     |
| Memory Arrays          | Storing medicine and dose information |

---

## 💾 Data Storage

The program uses memory arrays to store:

* `NAMES` — Medicine names
* `HOURS` — Scheduled dose hours
* `STATUS` — Dose status
* `DOSE_CNT` — Number of doses per medicine
* `COUNT` — Total number of medicines

The program supports **9 medicines** and up to **27 doses** in total.

---

## 🔄 How the Program Works

```text
Start
  │
  ▼
Main Menu
  │
  ├── Add Medicine
  ├── View Reports
  ├── Time Query
  ├── Mark Taken
  ├── Delete Medicine
  └── Compliance
  │
  ▼
Return to Menu
  │
  ▼
Exit
```

---

## 📋 Main Menu

```text
1. Add New Medicine
2. View All Reports
3. Time Query
4. Mark Taken
5. Delete Medicine
6. Compliance
0. Exit
```

---

## 🔢 Capacity

* **Maximum medicines:** 9
* **Doses per medicine:** 1–3
* **Maximum total doses:** 27
* **Valid dose hours:** 0–23

If all medicine slots are occupied, the program displays:

```text
ERROR: System Full!
```

---

## ▶️ How to Run

### Using EMU8086

1. Download or clone this repository.
2. Open `medicine_reminder.asm` in **EMU8086**.
3. Assemble the program.
4. Run the program in the EMU8086 emulator.
5. Use the menu options to interact with the program.

---

## 📁 Project Structure

```text
smart-medicine-reminder/
│
├── medicine_reminder.asm
└── README.md
```

---

## 🎯 Learning Objectives

This project demonstrates:

* 8086 Assembly Language
* Registers and memory addressing
* Arrays and data storage
* Procedures and macros
* Loops and conditional jumps
* Keyboard input and console output
* DOS interrupts
* Menu-driven program design

---

## 👥 Contributors

* **Afeefah Nusaybah Anfa**
* **Dewan Iffaz Hassan**

---

## 💊 Project

**Smart Medicine Reminder & Dose Tracker**

Developed as an **8086 Assembly Language project using EMU8086**.
