from django.conf.urls import url

from . import views

app_name = 'shred'
urlpatterns = [
    # ex: /shred/
    url(r'^$', views.index, name='index'),
    # ex: /shred/123/45678
    url(r'^(?P<athlete_id>[0-9]+)/((?P<activity_id>[0-9]+)/)?$', views.map, name='map'),
]