# scheduler.py
from .models import *
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from django_apscheduler.jobstores import DjangoJobStore
from . import tasks
scheduler = BackgroundScheduler()
scheduler.add_jobstore(DjangoJobStore(), 'default')

def update_bank_balance():
    # Retrieve all users from the database
    # users = User.objects.all()
    account = CreditCardDetail.objects.get(accountNumber='0000-0000-0000-0001')
    account.balance+=1
    account.save()
    print("did it")
    print(datetime.now())

# scheduler.add_job(tasks, 'cron', month='*', day='1')
scheduler.add_job(update_bank_balance, 'interval', minutes=5)#, args=[user_id])
scheduler.start()
# scheduler.shutdown()