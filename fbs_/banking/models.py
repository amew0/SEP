from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.
class CreditCardDetail(models.Model):
    accountNumber = models.CharField(
        max_length = 19) # XXXX-XXXX-XXXX-XXXX
    phoneNumber = models.CharField(
        max_length=15)   # +971 5 XXX-XXXX

PRIVILEGES = [
	('Main', 'Main'),
	('Sub', 'Sub')
]
class User (AbstractUser):
    account = models.ForeignKey(
            CreditCardDetail,
            on_delete = models.SET_NULL, 
            null=True, 
            related_name = "numberU"
        )
    dateOfBirth = models.DateField(null=True)
    privilege = models.TextField(choices = PRIVILEGES,null=True)
    """def __init__(self, *args, **kwargs):
        super().__init__(*args,**kwargs)

        phoneNumber = models.ForeignKey(
            CreditCardDetails,
            on_delete = models.SET_NULL, 
            null=True, 
            related_name = "numberU"
        )
        dateOfBirth = models.DateField(null=True)
        privilege = models.TextField(choices = PRIVILEGES)

        self.phoneNumber = phoneNumber
        self.dateOfBirth = dateOfBirth
        self.privilege = privilege"""
    
    def create_user(self, username, email=None, password=None, **extra_fields):
        """
        Create and save a user with the given username, email, and password.
        """
        phoneNumber = extra_fields.pop('phoneNumber', None)
        dateOfBirth = extra_fields.pop('dateOfBirth', None)
        privilege = extra_fields.pop('privilege', None)
        """
        if phoneNumber is not None and phoneNumber (condition):
            raise ValueError('Phone number must be sth')
        """
        user = super().create_user(username=username,email=email,passowrd=password,**extra_fields)
        user.phoneNumber = phoneNumber
        user.dateOfBirth = dateOfBirth
        user.privilege = privilege

        user.save(using=self._db)
        return user


class Balance (models.Model):
    accountNumB = models.ForeignKey(
        CreditCardDetail,
        on_delete = models.SET_NULL, 
        null=True, 
        related_name = "accountNumB")
    balance = models.DecimalField(
        max_digits = 10, 
        decimal_places = 2)

class Allowance (models.Model):
    userB = models.ForeignKey(
        User, 
        on_delete = models.SET_NULL, 
        null=True, 
        related_name = "userBU")
    allowance = models.DecimalField(
        max_digits = 10, 
        decimal_places = 2)

class Bill (models.Model):
    accountNumBill = models.ForeignKey(
        CreditCardDetail,
        on_delete = models.SET_NULL, 
        null=True, 
        related_name = "accountNumBill")
    billType = models.CharField(
        max_length = 25)
