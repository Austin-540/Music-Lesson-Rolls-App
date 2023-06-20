#!/usr/bin/python

import sqlite3
from secrets import getSecrets
import smtplib, ssl
from tabulate import tabulate


secrets = getSecrets()

con = sqlite3.connect("/Users/austin/Programming/music_lessons_attendance/backend/examples/base/pb_data/data.db")
cur = con.cursor()

cur.execute("SELECT * FROM rolls WHERE final = true")
x = cur.fetchall()
if len(x) == 0:
    con.close()
    quit()

def sendEmail(contents):
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
        server.login(secrets['my_email'], secrets['my_password'])
        server.sendmail(secrets['my_email'], secrets['reciever_email'], contents)

    cur.execute("DELETE FROM rolls")
    con.commit()
    con.close()

def getStudentDetails(student):
    if student[3] == 1:
        status = "Present"
    else:
        status = "Absent"

    studentDBDetails = cur.execute(f"SELECT name, homeroom FROM students WHERE id = '{student[4]}'").fetchone()
    return [studentDBDetails[0], studentDBDetails[1], status]

    

allDetails = []
allRolls = cur.execute("SELECT * FROM rolls").fetchall()
for student in allRolls:
    x = getStudentDetails(student)
    allDetails.append(x)


table = tabulate(allDetails, headers=['Name', 'Homeroom', 'Status'], tablefmt='grid')


sendEmail(table)
