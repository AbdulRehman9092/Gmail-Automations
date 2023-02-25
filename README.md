# Gmail-Automations

This repository contains scripts for automating common Gmail tasks, including sending bulk personalized emails and reading unread messages to extract information like One-Time Passwords (OTPs).

## Scripts

### 1. Bulk Email Sender (`Bulk Sending.ps1`)

A PowerShell script for sending personalized bulk emails with attachments using Gmail's SMTP server. It's ideal for outreach campaigns, such as contacting professors for research opportunities.

#### Features
- Sends emails to a list of recipients specified in a text file.
- Supports unique subjects and body content for each recipient.
- Attaches a single, specified file to every email.
- Prompts for credentials securely (requires a Gmail App Password).
- Handles UTF-8 encoding for proper display of special characters.
- Tracks and displays sending progress in the console.

#### Requirements
- Windows PowerShell
- A Gmail account

#### Configuration
Before running the script, you must edit the following variables within `Bulk Sending.ps1`:

1.  `$displayName`: The name you want to appear as the sender.
2.  `$emailFrom`: Your Gmail address.
3.  `$attachmentPath`: The full path to the file you wish to attach (e.g., `C:\Users\YourUser\Desktop\CV.pdf`).
4.  `$dataFile`: The full path to your data file containing recipient information (e.g., `C:\Users\YourUser\Desktop\data.txt`).

#### Data Format
The script reads recipient data from a text file specified by the `$dataFile` variable. Each entry in the file must follow this format:

```
recipient-email@example.com
Subject: The subject of the email
The first line of the email body.
The second line of the email body.
And so on.
```

A blank line should separate each recipient's entry. Refer to `data format.txt` for a concrete example.

#### Usage
1.  Configure the variables in the script as described above.
2.  Prepare your `data.txt` file with all the emails you want to send.
3.  Generate a **Gmail App Password** for your account. You cannot use your regular password. See the [Security](#security-using-gmail-app-passwords) section for instructions.
4.  Open a PowerShell terminal and navigate to the script's directory.
5.  Run the script:
    ```powershell
    .\'Bulk Sending.ps1'
    ```
6.  When prompted, enter your Gmail address as the username and your 16-digit App Password as the password.

### 2. OTP Reader (`imap read.py`)

A Python script that connects to a Gmail account via IMAP, finds the latest unread email, extracts the first 6-digit number (OTP) it finds, and marks the email as read.

#### Features
- Connects securely to the Gmail IMAP server using SSL.
- Isolates and processes only unread emails.
- Parses the email body to find a 6-digit OTP using regular expressions.
- Marks the email as 'seen' to avoid reprocessing.

#### Requirements
- Python 3
- A Gmail account

#### Configuration
Before running the script, edit the following variables in `imap read.py`:

1.  `USERNAME`: Your Gmail address.
2.  `PASSWORD`: Your 16-digit Gmail App Password.

#### Usage
1.  Configure the `USERNAME` and `PASSWORD` variables in the script.
2.  Generate a **Gmail App Password** if you haven't already.
3.  Run the script from your terminal:
    ```bash
    python imap_read.py
    ```
    The script will print the fetched OTP a or a message indicating that no OTP was found.

---

## Security: Using Gmail App Passwords

Both scripts require a **Gmail App Password** to authenticate, not your regular account password. An App Password is a 16-digit code that gives a less secure app or device permission to access your Google Account.

#### How to Generate an App Password
1.  Go to your Google Account settings: [https://myaccount.google.com/](https://myaccount.google.com/).
2.  Navigate to the **Security** tab.
3.  Under "How you sign in to Google," ensure **2-Step Verification** is turned ON. You cannot create App Passwords without it.
4.  In the same section, click on **App passwords**. You may be asked to sign in again.
5.  Click **Select app** and choose "Other (Custom name)".
6.  Give it a recognizable name (e.g., "Python IMAP Script" or "PowerShell Bulk Mailer").
7.  Click **Generate**.
8.  Copy the 16-digit password and paste it directly into the script's password variable. Do not include spaces.
