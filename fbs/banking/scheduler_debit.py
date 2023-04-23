# scheduler.py
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from django_apscheduler.jobstores import DjangoJobStore
from apscheduler.triggers.cron import CronTrigger

from .models import *
# schedule_debit = BackgroundScheduler()
# schedule_debit.add_jobstore(DjangoJobStore(), 'default')

def pay_debit_monthly(userId,phone,amount,stat,installment):
   
    account = CreditCardDetail.objects.get(phoneNumber=phone)
    if(account.balance>installment):
        account.balance-=installment
        amount-=installment
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
    # if(amount<=0):
    #     schedule_debit.shutdown()
def pay_debit(userId,date,phone,amount,stat,installment):
    runs = int(amount/installment)
    
    schedule_debit = BackgroundScheduler()
    schedule_debit.add_jobstore(DjangoJobStore(), 'default')
    schedule_debit.add_job(pay_debit_monthly, CronTrigger(day=date.day,hour=date.hour,minute=date.minute), args=[userId,phone,amount,stat,installment],max_instances= runs)
    print("schedule_debit started now")
    schedule_debit.start()

