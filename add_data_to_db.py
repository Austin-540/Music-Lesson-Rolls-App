import csv
from pocketbase import PocketBase 

client = PocketBase('http://127.0.0.1:8090')

admin_data = client.admins.auth_with_password("admin@example.com", "Password023") # This script requires admin privelliges on PB to run #Dont forget to delete that admin account

with open("./music_timetable_replica - Sheet1.csv") as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    data = list(csv_reader)
    print(data)
    
