import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
import firebase_admin
from firebase_admin import credentials, messaging
from django.conf import settings
from .models import *
from django_apscheduler.jobstores import DjangoJobStore

scheduler_allowance = BackgroundScheduler()
scheduler_allowance.add_jobstore(DjangoJobStore(), 'default')

def add_allowance(sub, amount):
    allowance = Allowance.objects.get(userMain=sub)
    allowance.allowance+=amount
    allowance.save()
    print("added allowance")
    # print(datetime.now())
def schedule_allowance(sub, amount, date):
    # Create a scheduler instance
    # scheduler_allowance = BackgroundScheduler()
    # scheduler_allowance.add_jobstore(DjangoJobStore(), 'default')
    # Define the job that will run the reminder function
    scheduler_allowance.add_job(
        add_allowance,
        CronTrigger(hour=date.hour, minute=(date.minute), second=date.second),
        args=[sub, amount]
        # id=f'reminder-{sub}'
    )
    # print("successfully started schedule")
    # Start the scheduler
    scheduler_allowance.start()
    