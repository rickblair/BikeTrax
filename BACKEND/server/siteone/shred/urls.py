from django.conf.urls import url

from . import views

app_name = 'shred'
urlpatterns = [
    # ex: /shred/
    url(r'^$', views.index, name='index'),
    # ex: /shred/123/45678
    url(r'^(?P<athlete_id>[0-9]+)/((?P<activity_id>[0-9]+)/)?$', views.compare, name='compare'),
    # url(r'^(?P<state>[0-9]+)/((?P<code>[0-9]+)/)?$', views.map, name='map'),

    # url(r'^(?P<state>[a-z0-9]+)/((?P<code>[az0-9]+)/)?$', views.token, name='token'),

    url(r'^token/$', views.token, name='token'),

]