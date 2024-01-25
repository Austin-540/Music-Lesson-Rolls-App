import gspread
import time
from datetime import date
from datetime import datetime
import sqlite3
from secrets import getSecrets
secrets = getSecrets()
sentEmail = False


def mark_roll(wksheet, name, status):
    all_values = wksheet.get_all_values()
    print(all_values)


    find_row = wksheet.find(name).row

    try:
        find_date_col = wksheet.find(f"{date.today().day}/{date.today().month}").col
    except:
        find_date_col = len(all_values[0]) + 1
        wksheet.insert_cols([[]], col=find_date_col)
        wksheet.update_cell(4, find_date_col, f"{date.today().day}/{date.today().month}")

# chr(ord('@')+find_date_col):find_row
    wksheet.update_cell(find_row, find_date_col, status)
    if status == "Unexplained" and firstTry == True:
        
        last_week_status_cell_col = wksheet.find(f"{date.today().day}/{date.today().month}").col -1
        last_week_status_cell_row = find_row
        last_week_status = all_values[last_week_status_cell_row-1][last_week_status_cell_col-1]
        if last_week_status == "Unexplained":
            print("\n\n\nDouble Unexplained\n\n\n")
            sendEmail(name)
        

def sendEmail(student):
    print("\n\n\nline33\n\n\n")
    import smtplib, ssl
    from secrets import getSecrets
    import sqlite3

    print("\n\n\nline41\n\n\n")
    con = sqlite3.connect("/home/austin/pb_data/data.db")
    cur = con.cursor()

    reciever_email = cur.execute("SELECT email FROM send_absent_notifs_to").fetchall()[0][0]


    print(reciever_email)
    now = datetime.now()
    formatted_date_time = now.strftime("%d-%m-%y %H:%M")
    print("\n\n\nline44\n\n\n")
    contents=f"""Subject: {student} has missed 2 lessons in a row ({formatted_date_time})

{student} has missed 2 of their lessons in a row with the status 'Unexplained'.

Their lesson's teacher is {teacher_name}

This email was sent automatically.
"""
    print(contents)
    port = 465  # For SSL
    # Create a secure SSL context
    context = ssl.create_default_context()

    with smtplib.SMTP_SSL("smtp.gmail.com", port, context=context) as server:
        server.login(secrets['my_email'], secrets['my_password'])
        server.sendmail(secrets['my_email'], reciever_email, contents)
        



def main_stuff():
    sa = gspread.service_account(filename="/home/austin/client_secret.json")
    sheet = sa.open("App - SHC Music Lessons")




    con = sqlite3.connect("/home/austin/pb_data/data.db")
    cur = con.cursor()

    all_students = cur.execute("SELECT * FROM rolls").fetchall()

    teacher_id = cur.execute("SELECT teacher FROM lessons WHERE id = ?",[all_students[0][2]]).fetchone()[0]

    global teacher_name
    teacher_name = cur.execute("SELECT username FROM users WHERE id = ?", [teacher_id]).fetchone()[0]


    wksheet = sheet.worksheet(teacher_name)

    for student in all_students:
        try:
            name = cur.execute("SELECT name FROM students WHERE id = ?", [student[3]]).fetchone()[0]
            status = student[6]
            mark_roll(wksheet, name, status)
        except Exception as error:
            print("Line101")
            firstTry = False
            print(error)
            mark_roll(sheet.worksheet(f"{teacher_name}2"), name, status)
try:
    firstTry = True
    main_stuff()
except Exception as error:
    print("Line109")
    firstTry = False
    print(error)
    try:
        main_stuff()
    except:
        print("Line115")
        main_stuff()
#Try 3 times before failing








# [
#     ['TEST SHEET (please ignore)', '', '', '', '', '', '', ''], 
#     ['Testing', '', '', '', '', '', '', ''], 
#     ['Tuesday', '', '', '', '', '', '', ''], 
#     ['', '', '24/10', '26/10', '1/1', '13/1', '15/1', '16/1'], 
#     ['23:59', 'Test', 'none', 'Present', '', '', '', ''], 
#     ['', '', '', '', '', '', '', ''], 
#     ['13:00', 'Austin', 'Present', '', '', '', '', ''], 
#     ['', 'Test1', 'Present', '', '', '', '', ''], 
#     ['', '', '', '', '', '', '', ''], 
#     ['', 'Test3', '', '', 'Unexplained', '', '', ''], 
#     ['', '', '', '', '', '', '', ''], 
#     ['', 'TestStudent', '', '', '', 'Present', 'Unexplained', 'Unexplained']]
