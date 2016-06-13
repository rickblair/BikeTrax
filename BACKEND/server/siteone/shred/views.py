from django.template import loader
from django.http import HttpResponse, HttpResponseRedirect
from django.core.urlresolvers import reverse
from django.shortcuts import get_object_or_404

#imports stravalib library
from stravalib import Client
#imports csv library that allows us to use the writer method to export structured data to text files
import csv
#imports datetime manipulation function
from datetime import datetime
from datetime import timedelta

#imports models
from .models import Athlete



#Strava keys
STRAVA_CLIENT_SECRET = "d113b3574538daa8f5f9f8bca8dcda61066c2668"
STRAVA_CLIENT_ID = "11671"
# WEB_ROOT = "c-24-16-190-14.hsd1.wa.comcast.net:8889" 
WEB_ROOT = "127.0.0.1:8889" #debug



def index(request):
    context = {'trail_name': 'Sleigh Ride', 'heat_map_type': 'Absolute', 'WEB_ROOT': WEB_ROOT}
    # return render(request, 'shred/index.html', context)
    template = loader.get_template('shred/index.html')
    return HttpResponse(template.render(context))


def token(request):
    # Get temporary code after the request
    code = request.GET.get("code")

    # exchange the code for an access token. 
    client = Client()
    access_token = client.exchange_code_for_token(client_id=STRAVA_CLIENT_ID,
                                              client_secret=STRAVA_CLIENT_SECRET,
                                              code=code)

    # Get Athlete 
    athlete = client.get_athlete()
    
    # See if the athlete exists in our DB
    # current_athlete = get_object_or_404(Athlete, id_strava = athlete.id)

    # current_athlete = ""
    
    try:
        current_athlete = Athlete.objects.get(id_strava = athlete.id)
    except (KeyError, Athlete.DoesNotExist):
        current_athlete = Athlete(first_name=athlete.firstname, last_name=athlete.lastname, access_token=access_token, id_strava = athlete.id )
        current_athlete.save()


    # **************************
    # Prep content for the HTML page.
    # Get Activities. 
    activities = client.get_activities()

    # Make a list of activities to send to the html page. These are all the activities for this athlete. 
    activity_list = []
    name_list = []

    for a in activities:
        temp = [a.id, a.name, a.distance, a.moving_time, a.elapsed_time, a.start_date_local] 
        activity_list.append(temp)

    # information to send to the html page
    context = { 'activity_list': activity_list,  'current_athlete': current_athlete }
    template = loader.get_template('shred/activities.html')
    return HttpResponse(template.render(context))


def map(request, athlete_id, activity_id):

    # athlete_id = athlete_id #421122 #750228
    # activity_id = activity_id #577320490 #476912675


    path = "../../../../../data/" + format(athlete_id) + "_" + format(activity_id) + ".txt"
    file_to_write_to = open(path, "w")
    # print(file_to_write_to.path)
    writer = csv.writer(file_to_write_to, delimiter=',', quotechar='', quoting=csv.QUOTE_NONE)
    #write header row for text file
    activity_tuple = "AthleteID", "ActivityID", "StartTime", "TotalElapsedTime", "TotalDistanceMeters", "MaxSpeedMPH", "MeasuredTime", "Latitude", "Longitude", "AltitudeMeters", "DistanceMeters", "current_speedMPH", "CurrentGrade"
    writer.writerow(activity_tuple)


    # By now the athlete should exist
    current_athlete = Athlete.objects.get(id_strava = athlete_id)

    # Use the access_token ### "58298d33c3a183c12673691a1ae53d261b08c3a4"
    client = Client(access_token=current_athlete.access_token)

    #activity id 
    strava_ride = client.get_activity(activity_id)
    
    # values we are using in calculations and sending to the template
    max_speed = format(float(strava_ride.max_speed * 2.23693629), '.9f')
    average_speed = format(float(strava_ride.average_speed * 2.23693629), '.9f')
    ride_name = strava_ride.name

    # Streams
    stream_types = "time","distance","latlng","altitude","grade_smooth","velocity_smooth"
    streams = client.get_activity_streams(activity_id, types=stream_types)

    stream_time = streams["time"].data 
    stream_distance = streams["distance"].data 
    stream_lat_lng = streams["latlng"].data 
    stream_altitude = streams["altitude"].data 
    stream_grade = streams["grade_smooth"].data 
    stream_velocity = streams["velocity_smooth"].data

    stream_tuple = zip(stream_time, stream_distance, stream_lat_lng, stream_altitude, stream_grade, stream_velocity)

    # combined_array is to collect all the values to do some calculations later.
    combined_array = []

    # combined_string is a string version of the array to send to the template.
    combined_string = ""

    # Getting info from the streams and combining it all into a CSV format. 
    for (tTime,tDistance,tLatLng,tAltitude,tGrade,tVelocity) in stream_tuple:
        current_time = strava_ride.start_date_local + timedelta(seconds=tTime)
        # current_speed = format(float(tVelocity * 2.23693629), '.9f')
        current_speed = tVelocity * 2.23693629
        activity_tuple = athlete_id, activity_id, strava_ride.start_date_local, strava_ride.elapsed_time, \
            float(strava_ride.distance), max_speed, current_time, tLatLng[0], tLatLng[1], \
            tAltitude, tDistance, current_speed, tGrade
        writer.writerow(activity_tuple)

        temp_stuff = []
        temp_stuff.append(format(current_time))
        temp_stuff.append(format(tLatLng[0]))
        temp_stuff.append(format(tLatLng[1]))
        temp_stuff.append(format(current_speed))

        combined_array.append(temp_stuff)
    
    file_to_write_to.close()


    # make special Shred Analytics average speeds that remove all 0 values.     
    sa_average_speed = 0.0
    sa_avg_index = 0

    for i in combined_array:
        # i[3] is speed
        if float(i[3]) > 0.5:
            sa_average_speed = sa_average_speed + float(i[3])
            sa_avg_index = sa_avg_index + 1 

        # Make a string version of the arracy to send to Javascript. 
        combined_string += ','.join(i) + "@"

    # the important calculation
    sa_average_speed = sa_average_speed / sa_avg_index

    context = {'sa_average_speed': sa_average_speed, 'max_speed': max_speed, 'average_speed': average_speed, 'ride_name': ride_name, 'athlete_id': athlete_id, 'activity_id': activity_id, 'start_lat': combined_array[3][1], 'start_lon': combined_array[3][2], 'file_string': combined_string}
    
    template = loader.get_template('shred/map.html')
    return HttpResponse(template.render(context))


















