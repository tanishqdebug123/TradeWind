import os
import django
from django.contrib.auth.hashers import make_password
from django.db import connection

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'tradewind_backend.settings')
django.setup()

def hash_existing_passwords():
    with connection.cursor() as cursor:
        # Fetch all user IDs and their plaintext passwords
        cursor.execute("SELECT UserID, Password FROM User")
        users = cursor.fetchall()

        for user_id, plaintext in users:
            hashed = make_password(plaintext)
            cursor.execute("UPDATE User SET Password = %s WHERE UserID = %s", [hashed, user_id])

        print(f"✅ Hashed and updated {len(users)} user passwords.")

if __name__ == "__main__":
    #hash_existing_passwords()
    print("Hashing existing passwords is not needed in this version of the app.")