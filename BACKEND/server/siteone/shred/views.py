# from django.shortcuts import render
from django.template import loader
from django.http import HttpResponse, HttpResponseRedirect
from django.core.urlresolvers import reverse

#imports stravalib library
from stravalib import Client
#imports csv library that allows us to use the writer method to export structured data to text files
import csv
#imports datetime manipulation function
from datetime import datetime
from datetime import timedelta


#Strava keys
STRAVA_CLIENT_SECRET = "d113b3574538daa8f5f9f8bca8dcda61066c2668"
STRAVA_CLIENT_ID = "11671"
WEB_ROOT = "c-24-16-190-14.hsd1.wa.comcast.net:8889" 
# WEB_ROOT = "127.0.0.1:8889" #debug



def index(request):
    context = {'trail_name': 'Sleigh Ride', 'heat_map_type': 'Absolute', 'WEB_ROOT': WEB_ROOT}
    # return render(request, 'shred/index.html', context)
    template = loader.get_template('shred/index.html')
    return HttpResponse(template.render(context))


def token(request):
    code = request.GET.get("code")

    client = Client()
    access_token = client.exchange_code_for_token(client_id=STRAVA_CLIENT_ID,
                                              client_secret=STRAVA_CLIENT_SECRET,
                                              code=code)
    athlete = client.get_athlete()
    activities = client.get_activities()

    activity_list = []
    name_list = []

    for a in activities:
        temp = [a.id, a.name] 
        activity_list.append(temp)

    context = { 'athlete_name': athlete.firstname, 'athlete_id': athlete.id ,'activity_list': activity_list, 'name_list': name_list}
    template = loader.get_template('shred/activities.html')
    return HttpResponse(template.render(context))


def map(request, athlete_id, activity_id):
    athlete_id = athlete_id #421122 #750228
    activity_id = activity_id #577320490 #476912675
    path = "data/" + format(athlete_id) + "_" + format(activity_id) + ".txt"
    file_to_write_to = open(path, "w")
    # print(file_to_write_to.path)
    writer = csv.writer(file_to_write_to, delimiter=',', quotechar='', quoting=csv.QUOTE_NONE)
    #write header row for text file
    activity_tuple = "AthleteID", "ActivityID", "StartTime", "TotalElapsedTime", "TotalDistanceMeters", "MaxSpeedMPH", \
                    "MeasuredTime", "Latitude", "Longitude", "AltitudeMeters", "DistanceMeters", "current_speedMPH", \
                    "CurrentGrade"
    writer.writerow(activity_tuple)

    #this is my super-secret developer access token
    client = Client(access_token="58298d33c3a183c12673691a1ae53d261b08c3a4")

    #activity id is for the last ride I recorded on Strava
    strava_ride = client.get_activity(activity_id)
    max_speed = format(float(strava_ride.max_speed * 2.23693629), '.9f')

    stream_types = "time","distance","latlng","altitude","grade_smooth","velocity_smooth"
    streams = client.get_activity_streams(activity_id, types=stream_types)

    stream_time = streams["time"].data 
    stream_distance = streams["distance"].data 
    stream_lat_lng = streams["latlng"].data 
    stream_altitude = streams["altitude"].data 
    stream_grade = streams["grade_smooth"].data 
    stream_velocity = streams["velocity_smooth"].data

    stream_tuple = zip(stream_time, stream_distance, stream_lat_lng, stream_altitude, stream_grade, stream_velocity)

    combined_array = []
    combined_string = ""

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

    colors = ["#FF0000","#ff1100","#ff2300","#ff3400","#ff4600","#ff5700","#ff6900","#ff7b00","#ff8c00","#ff9e00","#ffaf00","#ffc100","#ffd300","#ffe400","#fff600","#f7ff00","#d4ff00","#c2ff00","#b0ff00","#9fff00","#8dff00","#7cff00","#6aff00","#58ff00","#47ff00","#35ff00","#24ff00","#12ff00","#00ff00"]
    for i in combined_array:
        # check i[3] and based on the result append a color to combined_array[i].append(#fff)
        color_temp = ""
        if float(i[3]) < 1:
            color_temp = colors[0]
        elif float(i[3]) < 2:
            color_temp = colors[1]
        elif float(i[3]) < 3:
            color_temp = colors[2]
        elif float(i[3]) < 4:
            color_temp = colors[3]
        elif float(i[3]) < 5:
            color_temp = colors[4]
        elif float(i[3]) < 6:
            color_temp = colors[5]
        elif float(i[3]) < 7:
            color_temp = colors[6]
        elif float(i[3]) < 8:
            color_temp = colors[7]
        elif float(i[3]) < 9:
            color_temp = colors[8]
        elif float(i[3]) < 10:
            color_temp = colors[9]
        elif float(i[3]) < 11:
            color_temp = colors[10]
        elif float(i[3]) < 12:
            color_temp = colors[11]
        elif float(i[3]) < 13:
            color_temp = colors[12]
        elif float(i[3]) < 14:
            color_temp = colors[13]
        elif float(i[3]) < 15:
            color_temp = colors[14]
        elif float(i[3]) < 16:
            color_temp = colors[15]
        elif float(i[3]) < 17:
            color_temp = colors[16]
        elif float(i[3]) < 18:
            color_temp = colors[17]
        elif float(i[3]) < 19:
            color_temp = colors[18]
        elif float(i[3]) < 20:
            color_temp = colors[19]
        elif float(i[3]) < 21:
            color_temp = colors[20]
        elif float(i[3]) < 22:
            color_temp = colors[21]
        elif float(i[3]) < 23:
            color_temp = colors[22]
        elif float(i[3]) < 24:
            color_temp = colors[23]
        elif float(i[3]) < 25:
            color_temp = colors[24]
        elif float(i[3]) < 26:
            color_temp = colors[25]
        elif float(i[3]) < 27:
            color_temp = colors[26]
        elif float(i[3]) < 28:
            color_temp = colors[27]
        elif float(i[3]) < 29:
            color_temp = colors[28]
        elif float(i[3]) > 29:
            color_temp = colors[28]

        i.append(color_temp)

        combined_string += ','.join(i) + "@"


    context = {'athlete_id': athlete_id, 'activity_id': activity_id, 'start_lat': combined_array[3][1], 'start_lon': combined_array[3][2], 'file_string': combined_string}
    template = loader.get_template('shred/map.html')
    return HttpResponse(template.render(context))


















