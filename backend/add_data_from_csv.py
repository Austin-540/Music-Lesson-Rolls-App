import csv
from pocketbase import PocketBase
from secrets import getSecrets
import sqlite3
import re

admin_password = getSecrets()['admin_password']

client = PocketBase('http://127.0.0.1:8090')

admin_data = client.admins.auth_with_password("admin@example.com", admin_password) # This script requires admin privelliges on PB to run 

def uploadLesson(listOfDetails):
    homeroom = "0" #Mr White can manually change this if there is a name clash
    students_in_lesson = []
    time = listOfDetails[0]
    for j in range(len(listOfDetails)):
        students_in_lesson.append(listOfDetails[j])
        if listOfDetails[j] != '' and j != 0:
            if listOfDetails[j] not in list_of_names_in_DB:
                client.collection('students').create({"name": listOfDetails[j], "homeroom":homeroom});
    

    all_teachers = client.collection("users").get_full_list() 
    #It is supposedly possible to use the get_one method with a filter to accomplish this, but it was giving me rediculously unhelpful error messages
    print(all_teachers)
    for x in range(len(all_teachers)):
        if all_teachers[x].username == teacher:
            teacher_id = all_teachers[x].id

    all_students = client.collection("students").get_full_list()
    student_db_IDs = []
    for student in students_in_lesson:
        for x in range(len(all_students)):
            if all_students[x].name == student:
                print(all_students[x].name)
                student_db_IDs.append(all_students[x].id)
    
    weekday_pattern = re.compile(r"^[A-Z][a-z]*day$")
    if weekday_pattern.match(date):
        print("weekday valid")
    else:
        print("weekday invalid")
        raise ValueError("Invalid weekday")

    if len(time) == 4:
        print("valid time length")
    else:
        print("time isn't 4 long")
        raise ValueError("The time provided isn't 4 characters long")
    
    if instrument == "":
        raise ValueError("The instrument name was left blank")
    
    client.collection('lessons').create(
        {
            'teacher': teacher_id,
            'instrument': instrument,
            'students': student_db_IDs,
            'weekday' : date,
            'time': time
        }
    )

try:
    students_already_in_DB_obj = client.collection('students').get_full_list()
    students_already_in_DB_list = list(students_already_in_DB_obj)
    list_of_names_in_DB = []
    for i in range(len(students_already_in_DB_list)):
        list_of_names_in_DB.append(students_already_in_DB_list[i].name)
    print(list_of_names_in_DB)

    con = sqlite3.connect('/home/austin/pb_data/data.db')
    cur = con.cursor()

    csv_file = cur.execute("SELECT csv FROM csv_files").fetchone()[0]

    data_lines = csv_file.split('\r\n')
    data=[]
    for i in range(len(data_lines)):
        data.append(data_lines[i].split(','))

    instrument = data[0][0]
    teacher = data[1][0]
    date = data[2][0]

    if data[3][0] != "":
        raise ValueError("A blank line wasn't left for row 4.")


    for i in range(4, len(data)):
        uploadLesson(data[i])

    cur.execute("DELETE FROM csv_files")
    con.commit()
    con.close()

except Exception as exception:
    print(exception)
    client.collection("error_message").create({"error":f"{exception}"})

