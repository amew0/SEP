from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('register', views.register, name="register"),
    path('login_flutter', views.login_view_flutter, name="login_flutter"),
    path('register_flutter', views.registration_view_flutter, name="register_flutter"),
    path('login', views.login_view, name="login"),
    path("logout", views.logout_view, name="logout"),
    path("family", views.family_member, name="family"),
]