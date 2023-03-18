from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger

def send_reminder(user_id, reminder_text):
    # Send the reminder to the user, e.g. using email or push notification
    print(f"Sending reminder to user {user_id}: {reminder_text}")
def schedule_reminder(user_id, reminder_text, schedule):
    # Create a scheduler instance
    scheduler = BackgroundScheduler()

    # Define the job that will run the reminder function
    scheduler.add_job(
        send_reminder,
        trigger=CronTrigger.from_crontab(schedule),
        args=[user_id, reminder_text],
        id=f'reminder-{user_id}'
    )

    # Start the scheduler
    scheduler.start()
