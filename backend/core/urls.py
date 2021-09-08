from django.urls import path
from .views import *

urlpatterns = [
    path('user/', UserView.as_view(), name='user_view'),
    path('post/', ListPostsView.as_view(), name = 'list_posts_view'),
    path('post/<int:postid>', DetailPostsView.as_view(), name = 'detail_posts_view')
]
