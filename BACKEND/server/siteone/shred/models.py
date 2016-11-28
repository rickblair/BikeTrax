from django.db import models

class Athlete(models.Model):
    first_name = models.CharField(max_length=200)
    last_name = models.CharField(max_length=200)
    access_token = models.CharField(max_length=200)
    id_strava = models.IntegerField()
    def __int__(self):
        return self.id_strava