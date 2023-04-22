# scheduler.py
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from django_apscheduler.jobstores import DjangoJobStore
from apscheduler.triggers.cron import CronTrigger

from .models import *
schedule_bill = BackgroundScheduler()
schedule_bill.add_jobstore(DjangoJobStore(), 'default')

def pay_bill_monthly(userId,phone,amount,stat):
    
    account = CreditCardDetail.objects.get(phoneNumber=phone)
    if(account.balance>amount):
        account.balance-=amount
        Statement=statement.objects.create(
            userId=userId,
            statements=stat
        )
        Statement.save()
        print("did it")
        print(datetime.now())
    else:
        print("not enough balance")
    account.save()
# scheduler.add_job(tasks, 'cron', month='*', day='1')
# scheduler.add_job(update_bank_balance, 'interval', minutes=5)#, args=[user_id])
def pay_bill(userId,date,phone,amount,stat):
    schedule_bill.add_job(pay_bill_monthly, CronTrigger(day=date.day,hour=date.hour,minute=date.minute), args=[userId,phone,amount,stat])
    print("schedule_bill started now")
    schedule_bill.start()
    # scheduler.shutdown()

