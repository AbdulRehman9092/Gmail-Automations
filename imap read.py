import imaplib
import email
import re


def imap():
    """
    Connects to the Gmail IMAP server, fetches the most recent unread email,
    extracts a 6-digit OTP (if present), marks the email as read, and returns the OTP.
    Returns None if no OTP is found or if there are no unread messages.
    """

    IMAP_HOST = "imap.gmail.com"
    IMAP_PORT = 993
    USERNAME = "yourmail@gmail.com"
    PASSWORD = "appPassword"  # Use an App Password if 2FA is enabled

    # --- Connect and Login ---
    try:
        mail = imaplib.IMAP4_SSL(IMAP_HOST, IMAP_PORT)
        mail.login(USERNAME, PASSWORD)
    except Exception as e:
        print(f"Failed to connect or authenticate: {e}")
        return None

    # Select the inbox
    mail.select("inbox")

    # --- Search for UNSEEN (unread) emails ---
    status, messages = mail.search(None, '(UNSEEN)')
    if status != "OK" or not messages[0].split():
        # No unread messages
        mail.logout()
        return None

    # --- Get the latest unread email ID ---
    email_ids = messages[0].split()
    latest_email_id = email_ids[-1]

    # --- Fetch the latest unread email ---
    status, data = mail.fetch(latest_email_id, "(RFC822)")
    if status != "OK":
        mail.logout()
        return None

    raw_email = data[0][1]

    # --- Parse email ---
    msg = email.message_from_bytes(raw_email)
    body = ""

    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            content_disposition = str(part.get("Content-Disposition", ""))
            if content_type == "text/plain" and "attachment" not in content_disposition:
                body = part.get_payload(decode=True).decode(errors="ignore")
                break
    else:
        body = msg.get_payload(decode=True).decode(errors="ignore")

    # --- Extract OTP using regex (6-digit sequence) ---
    otp_match = re.search(r'\b(\d{6})\b', body)
    otp = otp_match.group(1) if otp_match else None

    # --- Mark email as SEEN (read) ---
    mail.store(latest_email_id, '+FLAGS', '\\Seen')

    # --- Logout and return OTP ---
    mail.logout()
    return otp


if __name__ == "__main__":
    otp_value = imap()
    if otp_value:
        print(f"Fetched OTP: {otp_value}")
    else:
        print("No OTP found or no unread emails.")
