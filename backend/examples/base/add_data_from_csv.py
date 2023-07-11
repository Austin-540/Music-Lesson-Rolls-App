import csv
from pocketbase import PocketBase
from secrets import getSecrets

admin_password = getSecrets()['admin_password']

client = PocketBase('https://app.shcmusiclessonrolls.com')

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