import csv
from pocketbase import PocketBase 

client = PocketBase('http://127.0.0.1:8090')

admin_data = client.admins.auth_with_password("admin@example.com", "Password023") # This script requires admin privelliges on PB to run 
#Dont forget to delete that admin account


students_already_in_DB_obj = client.collection('students').get_full_list()
students_already_in_DB_list = list(students_already_in_DB_obj)
list_of_names_in_DB = []
for i in range(len(students_already_in_DB_list)):
    list_of_names_in_DB.append(students_already_in_DB_list[i].collection_id['name'])
print(list_of_names_in_DB)



homeroom = "00EXM" #For now, because my CSV file doesn't have homerooms yet


def uploadLesson(listOfDetails):
    time = listOfDetails[0]
    for j in range(len(listOfDetails)):
        if j == 0:
            pass
        elif listOfDetails[j] != '':
            # if students_already_in_DB[0]
            client.collection('students').create({"name": listOfDetails[j]});


with open("./shorter_csv.csv") as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    data = list(csv_reader) #CSV_file -> list (rows) of lists (columns)
    print(data)

    instrument = data[0][0]
    teacher = data[1][0]
    date = data[2][0]
    for i in range(len(data)):
        # uploadLesson(data[i])
        pass
    
