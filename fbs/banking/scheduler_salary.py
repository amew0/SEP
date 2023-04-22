# scheduler.py
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from django_apscheduler.jobstores import DjangoJobStore
from apscheduler.triggers.cron import CronTrigger

from .models import *
# from . import scheduler_bill
scheduler_salary = BackgroundScheduler()
scheduler_salary.add_jobstore(DjangoJobStore(), 'default')

def update_bank_balance(phone):
    # Retrieve all users from the database
    # users = User.objects.all()
    account = CreditCardDetail.objects.get(phoneNumber=phone)
    account.balance+=7000
    account.save()
    print("did it")
    print(datetime.now())

def update_bal(phone):
    scheduler_salary.add_job(update_bank_balance, CronTrigger(day=28,hour=10,minute=00), args=[phone])
    print("schedule started now")
    scheduler_salary.start()
    # scheduler.shutdown()