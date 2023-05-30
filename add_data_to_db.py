import csv
from pocketbase import PocketBase 

client = PocketBase('http://127.0.0.1:8090')

admin_data = client.admins.auth_with_password("admin@example.com", "Password023") # This script requires admin privelliges on PB to run #Dont forget to delete that admin account
students_already_in_DB = client.collection('students').get_full_list()
print(records)

homeroom = "00EXM" #For now, because my CSV file doesn't have homerooms yet


def uploadLesson(listOfDetails):
    time = listOfDetails[0]


with open("./music_timetable_replica - Sheet1.csv") as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    data = list(csv_reader) #CSV_file -> list (rows) of lists (columns)
    print(data)

    instrument = data[0][0]
    teacher = data[1][0]
    date = data[2][0]
    for i in range(len(data)):
        uploadLesson(data[i])
    
