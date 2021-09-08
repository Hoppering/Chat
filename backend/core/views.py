from re import S
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .serializers import UserSerializer, PostSerializer
from rest_framework import status
from .models import User, Post
from django.http import JsonResponse
from django.core import serializers


class ChangeDict:
    def sortDict(item):
        return item['id']

class UserView(APIView):
    #permission_classes = (IsAuthenticated,)   

    def get(self, request): 
        user = User.objects.all()
        data = {
            'name': user[0].name,
            'email': user[0].email,
            'date_created': user[0].date_created
        }
        return JsonResponse(data, status=status.HTTP_200_OK)

    def post(self, request):
        data = {
            'name':request.data['name'],
            'email':request.data['email']
        }
        serializer = UserSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data, status=status.HTTP_201_CREATED)
        return JsonResponse(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ListPostsView(APIView):
    #permission_classes = (IsAuthenticated,)   

    def get(self, request): 
        post = Post.objects.all()
        data = []
        for item in post:
            data.append(
                {
            'id': item.id,
            'content': item.content,
            'image': {
                'name': item.image.name,
                'url': item.image.url,
                'height': item.image.height,
                'width': item.image.width,
            },
            'date_created': str(item.date_created)[:10] + ' | ' + str(item.date_created)[10:16],
            'date_update': str(item.date_update)[:10] + ' | ' + str(item.date_created)[10:16],
            'user':{
                'id':item.user.id,
                'name':item.user.name,
            }
                }
            )
        data.sort(key = ChangeDict.sortDict)

        return JsonResponse(data, safe=False, status=status.HTTP_200_OK)

    def post(self, request):
        data = {
            'content':request.data['content'],
            'image':request.FILES['image'],
            'user': request.data['user']
        }

        serializer = PostSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data, status=status.HTTP_201_CREATED)
        return JsonResponse(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        try:
            pk = request.data['id']
            Post.objects.get(id=pk).image.delete()
            Post.objects.filter(id=pk).delete()
        except:
            return Response("Object not found" ,status=status.HTTP_404_NOT_FOUND)
        else:
            return Response(status=status.HTTP_204_NO_CONTENT)

class DetailPostsView(APIView):
    def get(self, request, postid):
        try:
            data = Post.objects.get(id=postid)
            data = {
                'id': data.id,
                'content': data.content,
                'image': {
                    'name': data.image.name,
                    'url': data.image.url,
                    'height': data.image.height,
                    'width': data.image.width,
                },
                'date_created': str(data.date_created)[:10] + ' | ' + str(data.date_created)[10:16],
                'date_update': str(data.date_update)[:10] + ' | ' + str(data.date_created)[10:16],
                'user':{
                    'id':data.user.id,
                    'name':data.user.name,
                }
                    }
        except:
            return Response("Object not found" ,status=status.HTTP_404_NOT_FOUND)
        else:
            return JsonResponse(data, safe=False)

    def put(self, request, postid):
        try:
            if(request.data.get('image') == None):
                data = {
                'content':request.data['content'],
                'image':Post.objects.get(id=postid).image,
                'user': request.data['user']
                }

            else:
                data = {
                    'content':request.data['content'],
                    'image':request.FILES['image'],
                    'user': request.data['user']
                }

            serializer = PostSerializer(data=data)

            if serializer.is_valid():
                post = Post.objects.get(id=postid)
                if(request.data.get('image') == None):
                    post.content = request.data['content']
                    post.image = post.image
                    post.save()
                else:
                    post.image.delete()
                    post.content = request.data['content']
                    post.image = request.FILES['image']
                    post.save()
        except:
            return Response("Object not found" ,status=status.HTTP_404_NOT_FOUND)
        else:
            return JsonResponse(serializer.data, status=status.HTTP_200_OK)
