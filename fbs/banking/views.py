import json
import string
import decimal
from tokenize import generate_tokens
from webbrowser import BackgroundBrowser
from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect, JsonResponse
from django.contrib.auth import authenticate, login, logout
from django.db import IntegrityError
from django.urls import reverse
from datetime import date, datetime, timedelta
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from django.core.mail import send_mail
from django.contrib.auth import authenticate, login
from django.http import JsonResponse
from django.http import HttpResponseBadRequest
from django.views.decorators.csrf import csrf_exempt
# from rest_framework.authtoken.views import ObtainAuthToken
# from rest_framework.response import Response
# from rest_framework_simplejwt.tokens import RefreshToken
import secrets
from django.db.models import Sum
from banking import scheduler_salary
from banking.scheduler_bill import pay_bill
from banking.scheduler_debit import pay_debit
from banking.scheduler_salary import update_bal
from banking.allowance_schedule import schedule_allowance
from twilio.rest import Client
import firebase_admin
# from pyfcm import FCMNotification
from django.db.models import Q
from firebase_admin import credentials, messaging
# from django.contrib.auth.password_validation import make_random_password
import requests
# Imported from current project
from .models import *


# // Import the functions you need from the SDKs you need
# import { initializeApp } from "firebase/app";
# import { getAnalytics } from "firebase/analytics";
# // TODO: Add SDKs for Firebase products that you want to use
# // https://firebase.google.com/docs/web/setup#available-libraries

# // Your web app's Firebase configuration
# // For Firebase JS SDK v7.20.0 and later, measurementId is optional
# const firebaseConfig = {
#   apiKey: "AIzaSyAYpOpo_fRCEgDw3HhGxaYuuwDo5me8_jU",
#   authDomain: "sep-project-72f97.firebaseapp.com",
#   projectId: "sep-project-72f97",
#   storageBucket: "sep-project-72f97.appspot.com",
#   messagingSenderId: "1005077484779",
#   appId: "1:1005077484779:web:9f565a0f08911519389aae",
#   measurementId: "G-6EEJM8Y7DG"
# };

# // Initialize Firebase
# const app = initializeApp(firebaseConfig);
# const analytics = getAnalytics(app);


cred = credentials.Certificate('sep-project-72f97-firebase-adminsdk-r2pjg-58123de2b9.json')
firebase_admin.initialize_app(cred)

# Create your views here.
def index(request):
    # print(request.user.linked_accounts.all())
    linked_accounts = request.user.linked_accounts.all() if request.user.is_authenticated else None
    
    return render(request, "banking/index.html",{
        "linked_accounts": linked_accounts
    })

PASSWORD = "a" # later will update to generate a new one
EMAIL = "a@a.a"

@csrf_exempt
def register(request):
    if request.method == "POST":
       
        user = registration_view_flutter(request)
        user1=[]
        data = json.loads(request.body)
        called_from = data.get('called_from')
        if(called_from=="register"):
            login(request, user)
            user=user.serialize()
            token = str(generate_tokens(user))
            user1.append(user)
            user1.append(token)
            return JsonResponse([ user1], safe=False, status=200)
        else:
            return JsonResponse({'message':'successfully registered user'}, safe=False, status=200)
    else:
        return JsonResponse({'error': 'Invalid credentials'}, safe=False, status=400)

# def register_user(request,called_from):
#     username = request.POST["username"]
#     # fullname = request.POST["fullname"]
#     phone_number = request.POST["phoneNumber"]
#     dateOfBirth = request.POST["dateOfBirth"]
#     privilege = request.POST.get("privilege")

#     if called_from == "register":
#         account = CreditCardDetail.objects.get(phoneNumber=phone_number)
#     elif called_from == "family":
#         account = CreditCardDetail.objects.get(phoneNumber = request.user.account.phoneNumber)

#     user = None
#     try:
#         # Attempt to create new user
#         user = User.objects.create_user(username, EMAIL, PASSWORD, account = account,
#             dateOfBirth = dateOfBirth,
#             privilege = privilege
#             )
#         user.save()

#     except IntegrityError:
#         """
#         Handle possible error here, like:
#             Username already taken
#         """    
#         return render(request, "banking/register.html", {
#             "message": "Username already taken."
#         })


#     if privilege == "Main":
        
#         # User is 'Main' and hence should be linked to the bank account
#         account.linked_users.add(user)
#         account.save()

#     elif privilege == "Sub":
#         allowance_account = Allowance.objects.create(
#             userMain = request.user,
#             userSub = user,
#             allowance = 0.00
#         )
#         allowance_account.save()

#     return user

# def login_view(request):
# 	if request.method == "POST":
        
# 		# scheduler.start() #Attempt to sign user in
# 		username = request.POST["username"]
# 		password = request.POST["password"]
# 		user = authenticate(request, username=username, password=password)

#         # Create a message payload with the notification data 
#         # response = messaging.send(message)
#         # response = messaging.send(message)
		

# 		# Check if authentication successful
# 		if user is not None:
# 			login(request, user)
# 			return render(request, "banking/index.html")
# 		else:
# 			return render(request, "banking/login.html", {
# 				"message": "Invalid username and/or password."
# 			})
# 	else:
# 		return render(request, "banking/login.html")

@csrf_exempt

def logout_view(request):
    
	logout(request)
   
    
    # return JsonResponse({'message': 'successfully logged out'}, status=200)

	return JsonResponse({'message':'successfully logged out'},status=200)
	# return HttpResponseRedirect(reverse("index"))

# def family_member(request):
#     if request.method == "POST":
#         # user = register_user(request,"family")
#         user = registration_view_flutter(request,"family")

#         return HttpResponseRedirect(reverse("family"))
#     else:
#         loggedInUser = User.objects.get(pk = request.user.id)
        
#         return render(request, "banking/family.html",{
#             "Privilege": loggedInUser.privilege
#         })

@csrf_exempt
def pay_bills(request):
    if request.method == "POST":
        data = json.loads(request.body)
        billAmount = decimal.Decimal(data.get("bill_amount"))
        billType = data.get("bill_name")
        billDescription = data.get("bill_description")
        billMonthly = data.get("bill_scheduled_monthly")
        date = data.get("date")
        # if billMonthly:
        date_time = datetime.strptime(date, '%d/%m/%y %H:%M:%S')
        date = date_time.strftime("%Y-%m-%d")
        user = data.get("user")
        
        account = CreditCardDetail.objects.get(phoneNumber=user[0]['Phone'])
        
        bill = Bill.objects.create(
            accountNumBill=account,
            billType=billType,
            billDescription=billDescription,
            billAmount=billAmount,
            billMonthly=billMonthly,
            date=date
        )
        bill.save()
        if(account.balance>=billAmount):
            account.balance -= billAmount
            msg = "successfully added bill"
            stat=" paid bill, " + str(billType)+", "+billDescription+", an amount of "+str(billAmount)+" AED. "
            Statement=statement.objects.create(
                userId=int(user[0]['UserId']),
                statements=stat
            )
            Statement.save()
            account.save()
            if(billMonthly):
                pay_bill(int(user[0]['UserId']),date_time,user[0]['Phone'],billAmount,stat)
        else:
            msg = "you do not have enough balance to pay"
        return JsonResponse({'message': msg}, safe=False, status=200)

    else:
        return JsonResponse({'error' : "error"}, safe=False, status=400)


@csrf_exempt
def add_debits(request):
    if request.method == "POST":
        data = json.loads(request.body)
        DebitAmount =  decimal.Decimal(data.get("debit_amount"))
        DebitName = data.get("debit_name")
        DebitInstallmentMonthly = decimal.Decimal(data.get("debit_installment"))
        DebitFinalDate = data.get("debit_final_date")
        date_time = datetime.now()
        
        user = data.get("user")
        account = CreditCardDetail.objects.get(phoneNumber=user[0]['Phone'])

        # 
        debit = Debit.objects.create(
            accountNumDebit=account,
            DebitName=DebitName,
            DebitFinalDate=DebitFinalDate,
            DebitAmount=DebitAmount,
            DebitInstallmentMonthly=DebitInstallmentMonthly
            
        )
        debit.save()
        stat="Added Debit, "+ str(DebitName)+ ", of amount "+ str(DebitAmount)+" AED. "
        Statement=statement.objects.create(userId=user[0]['UserId'],statements=stat)
        Statement.save()
        pay_debit(int(user[0]['UserId']),date_time,user[0]['Phone'],DebitAmount,stat,DebitInstallmentMonthly)
        # schedule_reminder(user_id=user[0]['UserId'], reminder_text="Take out the trash")

        return JsonResponse({'message': 'debit added successfully'}, safe=False, status=200)

    else:
        return JsonResponse({'error': 'couldn not process your request'}, safe=False, status=400)

# API
# @login_required
def credit_card_details(request):
    ccds = CreditCardDetail.objects.all()
    if request.method == "GET":
        return JsonResponse([ccd.serialize() for ccd in ccds], safe=False)

@csrf_exempt
def login_view_flutter(request):
    if request.method == 'POST':
        # scheduler.start()
        
        user_agent = request.META.get('HTTP_USER_AGENT')
        if 'Mobile' in user_agent:
            print(user_agent)
            print("ya")
        data = json.loads(request.body)
        print(data)
        username = data.get('username')
        password = data.get('password')
        fcm_token = data.get('token')
        print(username)
        print(password)
        print(fcm_token)
        user = authenticate(request, username=username, password=password)
        # update_bal()
        user1=[]
        if user is not None:
            login(request, user)
            user=user.serialize()
            print(user["Privilege"])

            # check for possible birthdays of family members
            # Get all Allowance objects where userMain is the given User object
            allowances = Allowance.objects.filter(userMain=user['UserId'])

            # Get the date two days from now
            today = date.today()
            two_days_ahead = today + timedelta(days=2)
            print(two_days_ahead.day)
            # Filter the allowances list to include only those with userSub
            # whose date of birth is two days ahead of today
            birthdays = []
            for allowance in allowances:
                user_sub = allowance.userSub
                dob = user_sub.dateOfBirth
                print(dob.month)
                if dob.day == two_days_ahead.day & dob.month == two_days_ahead.month:
                    birthdays.append(dob)
            print(birthdays)
            # The birthdays list should contain all the dates of birth
            # that are two days ahead for the given user's sub-users

            if len(birthdays) !=0:
                # Construct a message payload to send to the FCM token
                message = messaging.Message(
                    data={
                        'title': 'django',
                        'body': string(birthdays),
                    },
                    token=fcm_token,
                )

                # Send the message to the FCM token
                response = messaging.send(message)
                print('Successfully sent message:', response)
            #send notification for birthday voucher here
            # if(user['Privilege']=='Main'):
            #     birthdays = 
            token = str(generate_tokens(user))
            # print(type(generator(token)))
            user1.append(user)
            user1.append(token)
            # return JsonResponse({'message': 'success'} , status=200)
            # return JsonResponse({'token': token}, status=200) #,{'token': token} ,[ user.serialize()]
            return JsonResponse([ user1], safe=False, status=200)

        else:
            return JsonResponse({'error': 'Invalid credentials'}, status=400)

@csrf_exempt
def registration_view_flutter(request):
    # if request.method == 'POST':
        data = json.loads(request.body)
        print("called view")
        # print(request.body)
        username = data.get('username')
        phone_number = data.get('phonenumber')
        dateOfBirth = data.get('dateofbirth')
        userMain = data.get('user')
        alphabet = string.ascii_letters + string.digits
        password = ''.join(secrets.choice(alphabet) for i in range(12))
        print(password)
        account_sid = 'AC0215eb4c081834ccb49951637b791194'
        auth_token = '7bee7dff2621b0cf3eee3058f89da322'

        # Create a Twilio client
        client = Client(account_sid, auth_token)

        # The message to send
        message = client.messages.create(
            body="your password for your new banking account is: "+str(password),
            from_='+15076903504',  # Your Twilio phone number
            to=str(phone_number)     # The recipient's phone = number
        )

        # Return a response indicating success or failure
        if message.sid:
            print("sms sent")
        else:
            print("sms not sent")
        privilege = data.get('privilege')
        called_from = data.get('called_from')
        if called_from == "register":
            account = CreditCardDetail.objects.get(phoneNumber=phone_number)
            update_bal(phone_number)
        elif called_from == "family":
            account = CreditCardDetail.objects.get(phoneNumber = userMain[0]['Phone'])
        try:
            # Attempt to create new user
            user = User.objects.create_user(
                username, 
                EMAIL, 
                password,
                account = account,
                dateOfBirth = dateOfBirth,
                privilege = privilege
                )
            user.save()

        except IntegrityError:
            """
            Handle possible error here, like:
                Username already taken
            """    
            # return render(request, "hotel/register.html", {
            #     "message": "Username already taken."
            # }) 
        
        if called_from == "family":
            if privilege == "Sub":
                allowance_account = Allowance.objects.create(
                    userMain = User.objects.get(id = userMain[0]['UserId']),
                    userSub = user,
                    allowance = 0.00
                )
                allowance_account.save()
            else:
                account.linked_users.add(user)
                account.save()
        else:
            pass

        # try:
        #     # Attempt to create new user
        #     user = User.objects.create_user(
        #         username, 
        #         EMAIL, 
        #         password,
        #         account = account,
        #         dateOfBirth = dateOfBirth,
        #         privilege = privilege
        #         )
        #     user.save()

        # except IntegrityError:
        #     """
        #     Handle possible error here, like:
        #         Username already taken
        #     """    
        #     # return render(request, "hotel/register.html", {
        #     #     "message": "Username already taken."
        #     # }) 
        return user


        # if user is not None:
        #     login(request, user)
        #     token = str(generate_tokens(user))
        #     return JsonResponse({'token': token}, status=500)
        # else:
        #     return JsonResponse({'error': 'Invalid credentials'}, status=400)
@csrf_exempt
def get_statement(request):

    data = json.loads(request.body)
    all_statements=[]
    user=data.get('user')
    if user[0]['Privilege'] == "Main":
        # stats = statement.objects.get(userId=user[0]['UserId'])
        # queryset = statement.objects.filter(userId=user[0]['UserId']).values()
        queryset = statement.objects.filter(Q(userId=user[0]['UserId'])).values_list('statements', flat=True)
        # result_str = json.dumps(list(queryset))
        result_str = list(queryset)

        # statements_list = list(queryset)
        # for stat in stats:
        #     print(stat.statements)
        #     all_statements.append(stat.statements)
        print(result_str)
        return JsonResponse([result_str], safe=False, status=200)

    else:
        bills = Bill.objects.filter(billUser=request.user)

    return JsonResponse({'error': 'Invalid credentials'}, status=400)
def bday_voucher(request):
    pass

@csrf_exempt
def allowance_api(request):
    if request.method == "POST":
        data = json.loads(request.body)

        userMain = data.get('userMain') # id
        userSub = data.get('userSub') # username
        amount = decimal.Decimal(data.get('amount')) # username
        date = data.get('date') # yy-mm-dd-hh-mm-ss
        instant = data.get('instant')
        user = data.get('user')
        # 2023-03-28-07-25-17
        date_formatted = datetime.strptime(date, '%d/%m/%y %H:%M:%S')
        subId = User.objects.get(username=userSub)
        allowance = Allowance.objects.get(userSub=subId.id)
        
        if(instant & (CreditCardDetail.objects.get(phoneNumber = user[0]['Phone']).balance > amount)):
            allowance.allowance += amount
        allowance.dateTime=date_formatted
        allowance.save()
        statSub=" Received an allowance of "+ str(amount)+ " AED from Main "
        statMain=" Sent an allowance of "+ str(amount)+ " AED to " + str(userSub)
        StatementSub=statement.objects.create(userId=subId.id,statements=statSub)
        StatementSub.save()
        StatementMain=statement.objects.create(userId=userMain,statements=statMain)
        StatementMain.save()
        schedule_allowance(subId.id,user[0]['Phone'], int(amount), date_formatted, statSub, statMain)
        
        return JsonResponse({"message": "Success"}, safe=False, status=200)
    else:

        mainSsubs = Allowance.objects.filter(userMain = request.user).values()
        print(mainSsubs)
        return JsonResponse(
            list(mainSsubs),
            safe=False, 
            status=200)

@csrf_exempt
def chatbot(request):
    # print(request.user)
    data = json.loads(request.body)
    user = data.get('user')
    if(user[0]['Privilege']=='Main'):
        accNum = user[0]['Account']
        acc = CreditCardDetail.objects.get(accountNumber=accNum)
        current_balance = acc.balance
        print(current_balance)
        current_bills = Bill.objects.filter(accountNumBill=acc).aggregate(Sum('billAmount'))
        current_bills = float(current_bills['billAmount__sum'])
        print(current_bills)
        # current_bills = Bill.objects.filter(accountNumBill='0000-0000-0000-0000').aggregate(Sum('billAmount'))['amount__bill']
        current_debits = Debit.objects.filter(accountNumDebit=acc).aggregate(Sum('DebitAmount'))
        current_debits = float(current_debits['DebitAmount__sum'])
        print(current_debits)
        safe_spend = float(current_balance) - (current_bills+ current_debits)
        
        message = f'''Amount safe to spend is {str(safe_spend)}. After the 28th of this month, including your salary the amount safe to spend will be {str(safe_spend+7000)}.'''
        print(message)
        
    else:
        message = "this is only for Main users"
    

        # current_debits = Debit.objects.filter(accountNumDebit='0000-0000-0000-0000').aggregate(Sum('DebitAmount'))['amount__debit']
    
    return JsonResponse(message, safe=False, status=200)

@csrf_exempt
def nfc(request):
    data = json.loads(request.body)
    user = data.get('user')
    privilege=user[0]['Privilege']
    if(privilege=='Main'):
        accNum = user[0]['Account']
        acc = CreditCardDetail.objects.get(accountNumber=accNum)
        if(acc.balance>=20):
            acc.balance = acc.balance - 20
            stat=" Paid through NFC an amount of 20 AED"
            Statement=statement.objects.create(userId=user[0]['UserId'],statements=stat)
            Statement.save()
            msg="success"
        else:
            msg="not enough balance"
        acc.save()
    else:
        allowance_account = Allowance.objects.get(userSub=user[0]['UserId'])
        if(allowance_account.allowance>=20):
            allowance_account.allowance = allowance_account.allowance - 20
            stat=" Paid through NFC an amount of 20 AED"
            Statement=statement.objects.create(userId=user[0]['UserId'],statements=stat)
            Statement.save()
            msg="success"
        else:
            msg="not enough balance"
        allowance_account.save()
    return JsonResponse({"message": msg}, safe=False, status=200)


