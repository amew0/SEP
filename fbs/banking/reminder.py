import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
import firebase_admin
from firebase_admin import credentials, messaging
from django.conf import settings

def send_reminder(user_id, reminder_text):
    # Send the reminder to the user, e.g. using email or push notification
    print(f"Sending reminder to user {user_id}: {reminder_text}")
def schedule_reminder(user_id, reminder_text):
    # Create a scheduler instance
    scheduler = BackgroundScheduler()

    # Define the job that will run the reminder function
    scheduler.add_job(
        send_reminder,
        trigger=CronTrigger(hour=22, minute=14, second=0),
        args=[user_id, reminder_text],
        id=f'reminder-{user_id}'
    )

    # Start the scheduler
    scheduler.start()
