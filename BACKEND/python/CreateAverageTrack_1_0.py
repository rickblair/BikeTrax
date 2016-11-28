# Name: CreateAverageTrack.py
#
# Purpose: Create average of GPS tracks from directory of text files in Shred Analytics delimited format
#   e.g., [Latitude], [Longitude]@[Latitude], Longitude@...
#   This script reads GPS tracks and finds the track with the most points. That track is the reference track
#   for the script. For all other tracks the script builds a new list of GPS points so that each track
#   has the same number of points as the reference track. The script does this by finding the closest point
#   in the evaluated track to each point in the reference track. The script uses the distance formula
#   to determine the closest point. The first point and last point of each evaluated track are treated specially
#   and are taken as is for the first point in the 'corrected' or revised track.
#
#   Version: 1.0
#
#   Revision Date: 28 June, 2016
#
#   Author: Mike (JP) Voran


import os
import math
import csv

# this is the source 
sBasePath = "C:\\Users\\mikev\\Documents\\Data SCIENCE!!!\\StEdsRides\\AllVolunteerSegments\\"

# build directory list of files in base path
dirList = os.listdir(sBasePath)

# list to hold info about all .txt files
AllFilesInfo = []

# find all files with a file extension of .txt
files = [file for file in dirList if file.endswith(".txt")]
files.sort()

# iterate through matching .txt files
for file in files:
    # list to hold info about individual .txt files
    SingleFileInfo = []
    # open each .txt file for reading
    openFile = open(os.path.join(sBasePath,file),"r")
    fileContents = openFile.read()
    # eliminates leading and trailing whitespaces including newline characters
    fileContents = fileContents.strip()
    openFile.close()
    # split the contents by the "@" delimiter
    splitContents1 = fileContents.split("@")
    LatList = []
    LonList = []
    for items in splitContents1:
            # split again by "," delimiter
            splitContents2 = items.split(",")
            # add Latitude value to LatList list
            LatList.append(splitContents2[0])
            # add Longitude value to LonList list
            LonList.append(splitContents2[1])
    # list to hold latitude/longitude pairs
    LatLonPairs = []
    LatLonPairs.append(LatList)
    LatLonPairs.append(LonList)
    # add info about individual .txt file: file name, number of lat/lon pairs, the latitude/longitude lists for the file
    SingleFileInfo = [file, len(LatList), LatLonPairs]
    AllFilesInfo.append(SingleFileInfo)
    
# first index == Row in AllFilesInfo
# second index == Row in SingleFileInfo [0 is file name, 1 is # of tracks, 2 is lat/lon pairs
# third index == Latitude list: 0; Longitude list: 1
# fourth index == Row in Latitude or Longitude list
# AllFilesInfo [Level One]
# AllFilesInfo --> SingleFileInfo [Level Two]
# AllFilesInfo --> SingleFileInfo --> LatLonPairs [Level Three]
# AllFilesInfo --> SingleFileInfo --> LatLonPairs --> LatList / LonList [Level Four]

# determine which track has the most number of points
maxPoints = 0
refTrack = 0
for i in range(len(AllFilesInfo)):
    if AllFilesInfo[i][1] > maxPoints:
        maxPoints = AllFilesInfo[i][1]
        refTrack = i

# new list to hold all corrected track data
AllCorrectedFiles = []

# iterate through all files in list
for i in range(len(AllFilesInfo)):
    CorrectedSingleFile = []
    CorrectedLatLonPair = []
    CorrectedLat = []
    CorrectedLon = []
    if i == refTrack: # just add the existing lat/lon values to the list without evaluating them if the track is the reference track
        
        # fileName = sBasePath +  "TESTOUTPUT\\" + AllFilesInfo[i][0] # optional: write revised tracks out to new files
        # ofile = open(fileName, "w", 1)
        
        # iterate through all of the points
        for j in range(0,maxPoints):
            CorrectedLat.append(AllFilesInfo[i][2][0][j])
            CorrectedLon.append(AllFilesInfo[i][2][1][j])
        CorrectedLatLonPair.append(CorrectedLat)
        CorrectedLatLonPair.append(CorrectedLon)
        CorrectedSingleFile = [AllFilesInfo[i][0], maxPoints, CorrectedLatLonPair]
        
        # iterate again to write out all values in list to file
        # for m in range(0,maxPoints):
        #    lineToWrite = CorrectedSingleFile[2][0][m] + ", " + CorrectedSingleFile[2][1][m] + "\n"
        #    ofile.write(lineToWrite)
        # ofile.close()
        
        # append corrected values to master list
        AllCorrectedFiles.append(CorrectedSingleFile)
    else: # evaluate distance for all other tracks
        # fileName = sBasePath +  "TESTOUTPUT\\" + AllFilesInfo[i][0]
        # ofile = open(fileName, "w", 1)
        pointsInCurrTrack = AllFilesInfo[i][1] # how many points does this track have
        for j in range(0,maxPoints): # build maxPoints number of tracks
            if j == 0: # just take the beginning value for the first point
                CorrectedLat.append(AllFilesInfo[i][2][0][0])
                CorrectedLon.append(AllFilesInfo[i][2][1][0])                   
            elif j == (maxPoints -1): # just take the ending value for the last point
                CorrectedLat.append(AllFilesInfo[i][2][0][pointsInCurrTrack - 1])
                CorrectedLon.append(AllFilesInfo[i][2][1][pointsInCurrTrack - 1])
            else: # else evaluate distance
                shortestDistance = 999999
                closestTrack = 0
                # iterate through each point in the evaluated track and find closest point to current point in reference track
                for k in range(0,pointsInCurrTrack):
                    refLat = float(AllFilesInfo[refTrack][2][0][j])
                    refLon = float(AllFilesInfo[refTrack][2][1][j])
                    currLat = float(AllFilesInfo[i][2][0][k])
                    currLon = float(AllFilesInfo[i][2][1][k])
                    distance = math.sqrt((refLat - currLat)**2 + (refLon - currLon)**2) # ye olde distance formula
                    if distance < shortestDistance: # if current distance < shortest distance update shortestDistance variable
                        shortestDistance = distance
                        closestTrack = k
                CorrectedLat.append(AllFilesInfo[i][2][0][closestTrack])
                CorrectedLon.append(AllFilesInfo[i][2][1][closestTrack])
        CorrectedLatLonPair.append(CorrectedLat)
        CorrectedLatLonPair.append(CorrectedLon)
        CorrectedSingleFile = [AllFilesInfo[i][0], maxPoints, CorrectedLatLonPair]
        
        # write out values to file. again, optional
        # for m in range(0,maxPoints):
        #    lineToWrite = str(CorrectedSingleFile[2][0][m]) + ", " + str(CorrectedSingleFile[2][1][m]) + "\n"
        #    ofile.write(lineToWrite)
        # ofile.close()
        
        # append values to master corrected files list
        AllCorrectedFiles.append(CorrectedSingleFile)

# this is where the new average track file is created            
AverageTrack = []
AverageTrack_Lat = []
AverageTrack_Lon = []
numOfTracks = len(AllCorrectedFiles)

fileName = sBasePath +  "TESTOUTPUT\\NewAverageTrack_ShredStyle_PinFirstLast.txt"
ofile = open(fileName, "w", 1)

lineToWrite = ""
for n in range(0,maxPoints): # iterate through all of the points
    avgLat = 0
    avgLon = 0
    for p in range(0,numOfTracks): # iterate through each point as found in each track
        # create a sum of the lat/lon values and then divide by number of tracks to create average
        avgLat = avgLat + float(AllCorrectedFiles[p][2][0][n])
        avgLon = avgLon + float(AllCorrectedFiles[p][2][1][n])
    # round to six decimal places
    outputLat = str(round(avgLat / numOfTracks, 6))
    outputLon = str(round(avgLon / numOfTracks, 6))
    # don't add a '@' character if it's the last item in the list
    if n < (maxPoints - 1):
        lineToWrite = lineToWrite + outputLat + ", " + outputLon + "@"
    else:
        lineToWrite = lineToWrite + outputLat + ", " + outputLon 
ofile.write(lineToWrite)
ofile.close()




    
