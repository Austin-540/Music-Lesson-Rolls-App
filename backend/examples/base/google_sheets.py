import gspread
import time
from datetime import date
import sqlite3

def mark_roll(wksheet, name, status):

    print(wksheet.get_all_values())


    find_row = wksheet.find(name).row

    try:
        find_date_col = wksheet.find(f"{date.today().day}/{date.today().month}").col
    except:
        find_date_col = len(wksheet.get_all_values()[0]) + 1
        cell_to_update = f"{chr(ord('@')+find_date_col)}4"
        wksheet.update(cell_to_update, f"{date.today().day}/{date.today().month}")


    wksheet.update(f"{chr(ord('@')+find_date_col)}{find_row}", status)



sa = gspread.service_account(filename="/Users/austin/Downloads/google_sheets/client_secret.json")
sheet = sa.open("Copy of SHC Music Lessons 2023")




con = sqlite3.connect("/Users/austin/Programming/music_lessons_attendance/backend/examples/base/pb_data/data.db")
cur = con.cursor()

all_students = cur.execute("SELECT * FROM rolls").fetchall()

teacher_id = cur.execute("SELECT teacher FROM lessons WHERE id = ?",[all_students[0][2]]).fetchone()[0]

teacher_name = cur.execute("SELECT first_name FROM users WHERE id = ?", [teacher_id]).fetchone()[0]

wksheet = sheet.worksheet(teacher_name)

for student in all_students:
    name = cur.execute("SELECT name FROM students WHERE id = ?", [student[3]]).fetchone()[0]
    status = student[6]
    mark_roll(wksheet, name, status)


