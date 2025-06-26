from django.core.management.base import BaseCommand
from django.contrib.auth.models import User as AuthUser
from django.contrib.auth.hashers import make_password
from django.db import connection

class Command(BaseCommand):
    help = 'Sync legacy users into auth_user table with hashed passwords'

    def handle(self, *args, **kwargs):
        with connection.cursor() as cursor:
            cursor.execute("SELECT UserID, Name, Email, Password FROM User")
            rows = cursor.fetchall()

        created = 0
        for row in rows:
            user_id, name, email, raw_password = row
            username = name.lower().replace(" ", "_")

            if not AuthUser.objects.filter(id=user_id).exists():
                AuthUser.objects.create(
                    id=user_id,
                    username=username,
                    email=email,
                    password=make_password(raw_password),
                    is_active=True,
                )
                created += 1

        self.stdout.write(self.style.SUCCESS(f"✅ Synced {created} users to auth_user"))
