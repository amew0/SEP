import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
import firebase_admin
from firebase_admin import credentials, messaging
from django.conf import settings
from .models import *
from django_apscheduler.jobstores import DjangoJobStore

# scheduler_allowance = BackgroundScheduler()
# scheduler_allowance.add_jobstore(DjangoJobStore(), 'default')

def add_allowance(sub,main_phone, amount, statSub, statMain):
    if(CreditCardDetail.objects.get(phoneNumber = main_phone).balance > amount):
        allowance = Allowance.objects.get(userSub=sub)
        allowance.allowance+=amount
        
        print("added allowance")
        StatementSub=statement.objects.create(userId=sub,statements=statSub)
        StatementMain=statement.objects.create(userId=allowance.userMain,statements=statMain)
        StatementSub.save()
        StatementMain.save()
        allowance.save()
def schedule_allowance(sub,main_phone, amount, date, statSub, statMain):
    scheduler_allowance = BackgroundScheduler()
    scheduler_allowance.add_jobstore(DjangoJobStore(), 'default')
    scheduler_allowance.add_job(
        add_allowance,
        CronTrigger(day = date.day , hour=date.hour, minute=date.minute),
        args=[sub,main_phone, amount, statSub, statMain]
    )
    # Start the scheduler
    print("scheduler_allowance started")
    scheduler_allowance.start()
    