import json
from tokenize import generate_tokens
from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect, JsonResponse
from django.contrib.auth import authenticate, login, logout
from django.db import IntegrityError
from django.urls import reverse
from datetime import datetime
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from django.core.mail import send_mail
import secrets

# Imported from current project
from .models import *

# Create your views here.
def index(request):
    return render(request, "hotel/index.html")

PASSWORD = "a" # later will update to generate a new one
EMAIL = "a@a.a"

def register(request):
    if request.method == "POST":
        user = register_user(request,"register")
        
        login(request, user)
        return render(request, "hotel/index.html")
    else:
        return render(request, "hotel/register.html")

def register_user(request,called_from):
    username = request.POST["username"]
    # fullname = request.POST["fullname"]
    phone_number = request.POST["phoneNumber"]
    dateOfBirth = request.POST["dateOfBirth"]
    privilege = request.POST.get("privilege")


    if called_from == "register":
        account = CreditCardDetail.objects.get(phoneNumber=phone_number)
    
    elif called_from == "family":
        print(request.user.account.phoneNumber)
        account = CreditCardDetail.objects.get(phoneNumber = request.user.account.phoneNumber)
    else:
        pass

    try:
        # Attempt to create new user
        user = User.objects.create_user(
            username, 
            EMAIL, 
            PASSWORD,
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
        return render(request, "hotel/register.html", {
            "message": "Username already taken."
        }) 
    return user

def login_view(request):
	if request.method == "POST":

		# Attempt to sign user in
		username = request.POST["username"]
		password = request.POST["password"]
		user = authenticate(request, username=username, password=password)

		# Check if authentication successful
		if user is not None:
			login(request, user)
			return render(request, "hotel/index.html")
		else:
			return render(request, "hotel/login.html", {
				"message": "Invalid username and/or password."
			})
	else:
		return render(request, "hotel/login.html")

def logout_view(request):
	logout(request)
	return HttpResponseRedirect(reverse("index"))

def family_member(request):
    if request.method == "POST":
        user = register_user(request,"family")
        return HttpResponseRedirect(reverse("family"))
    else: 
        return render(request, "hotel/family.html")

@csrf_exempt
def login_view_flutter(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            token = str(generate_tokens(user))
            return JsonResponse({'user': user}, status=500)
        else:
            return JsonResponse({'error': 'Invalid credentials'}, status=400)

def registration_view_flutter(request,called_from):
    # if request.method == 'POST':
        data = json.loads(request.body)
        username = data.get["username"]
        phone_number = data.get["phoneNumber"]
        dateOfBirth = data.get["dateOfBirth"]
        privilege = "main"

        if called_from == "register":
            account = CreditCardDetail.objects.get(phoneNumber=phone_number)
    
        elif called_from == "family":
            print(request.user.account.phoneNumber)
            account = CreditCardDetail.objects.get(phoneNumber = request.user.account.phoneNumber)
        else:
            pass

        try:
            # Attempt to create new user
            user = User.objects.create_user(
                username, 
                EMAIL, 
                PASSWORD,
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
            return render(request, "hotel/register.html", {
                "message": "Username already taken."
            }) 
        return user


        # if user is not None:
        #     login(request, user)
        #     token = str(generate_tokens(user))
        #     return JsonResponse({'token': token}, status=500)
        # else:
        #     return JsonResponse({'error': 'Invalid credentials'}, status=400)