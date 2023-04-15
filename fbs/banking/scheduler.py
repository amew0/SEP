# scheduler.py
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from django_apscheduler.jobstores import DjangoJobStore
from apscheduler.triggers.cron import CronTrigger

from .models import *
from . import tasks
scheduler = BackgroundScheduler()
scheduler.add_jobstore(DjangoJobStore(), 'default')

def update_bank_balance():
    # Retrieve all users from the database
    # users = User.objects.all()
    accounts = CreditCardDetail.objects.all()
    for account in accounts:
        account.balance+=100
        account.save()
    print("did it")
    print(datetime.now())

# scheduler.add_job(tasks, 'cron', month='*', day='1')
# scheduler.add_job(update_bank_balance, 'interval', minutes=5)#, args=[user_id])
def update_bal():
    scheduler.add_job(update_bank_balance, CronTrigger(minute='*/10'))#, args=[user_id])
    print("schedule started now")
    scheduler.start()
    # scheduler.shutdown()