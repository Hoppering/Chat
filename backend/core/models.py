from django.db import models

class User(models.Model):
    name = models.CharField(max_length=50)
    email = models.EmailField(max_length=100)
    date_created = models.DateTimeField(auto_now_add=True)

class Post(models.Model):
    content = models.CharField(max_length=200)
    image = models.ImageField(upload_to = 'images')
    date_created = models.DateTimeField(auto_now_add=True)
    date_update = models.DateTimeField(auto_now=True)
    user = models.ForeignKey('User', on_delete=models.CASCADE)