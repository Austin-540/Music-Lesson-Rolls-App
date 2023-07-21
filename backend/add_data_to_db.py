#This file is not used. It has been replaced with /examples/base/add_data_from_csv.py
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





def uploadLesson(listOfDetails):
    homeroom = "00EXM" #For now, because my CSV file doesn't have homerooms yet
    students_in_lesson = []
    time = listOfDetails[0]
    for j in range(len(listOfDetails)):
        students_in_lesson.append(listOfDetails[j])
        if j == 0:
            pass
        elif listOfDetails[j] != '':
            if listOfDetails[j] in list_of_names_in_DB:
                pass
            else:
                client.collection('students').create({"name": listOfDetails[j], "homeroom":homeroom});
    

    all_teachers = client.collection("users").get_full_list() 
    #It is supposedly possible to use the get_one method with a filter to accomplish this, but it was giving me rediculously unhelpful error messages
    print(all_teachers)
    for x in range(len(all_teachers)):
        if all_teachers[x].collection_id['username'] == teacher:
            teacher_id = all_teachers[x].collection_id['id']

    all_students = client.collection("students").get_full_list()
    student_db_IDs = []
    for student in students_in_lesson:
        for x in range(len(all_students)):
            if all_students[x].collection_id['name'] == student:
                print(all_students[x].collection_id['name'])
                student_db_IDs.append(all_students[x].collection_id['id'])
    
    client.collection('lessons').create(
        {
            'teacher': teacher_id,
            'instrument': instrument,
            'students': student_db_IDs,
            'weekday' : date,
            'time': time
        }
    )


with open("./music_timetable_replica - Sheet1.csv") as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    data = list(csv_reader) #CSV_file -> list (rows) of lists (columns)
    print(data)

    instrument = data[0][0]
    teacher = data[1][0]
    date = data[2][0]
    for i in range(4, len(data)):
        uploadLesson(data[i])
    
