from datetime import datetime
from banking.models import *
from django.core.management.base import BaseCommand

class pay_salary(BaseCommand):
    help = 'Notify users of upcoming birthdays'

    def handle(self):
        acc = CreditCardDetail.objects.all()

        for person in acc:
            person.balance=person.balance+100
        acc.save()
        pass

