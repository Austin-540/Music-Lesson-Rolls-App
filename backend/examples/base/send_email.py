#!/usr/bin/python

import sqlite3
from secrets import getSecrets
import smtplib, ssl
from tabulate import tabulate
from datetime import datetime
from datetime import date


def sendEmail(contents):
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
        server.login(secrets['my_email'], secrets['my_password'])
        server.sendmail(secrets['my_email'], secrets['reciever_email'], contents)

    cur.execute("DELETE FROM rolls")
    con.commit()
    con.close()

def getStudentDetails(student):
    studentDBDetails = cur.execute("SELECT name, homeroom FROM students WHERE id = ?", student[3]).fetchone()
    print(studentDBDetails)
    return [studentDBDetails[0], studentDBDetails[1], student[6]]


def getLessonTime(student):
    cur.execute("SELECT time FROM lessons WHERE id = ?", student[2])
    time = cur.fetchone()

    weekday = cur.execute("SELECT weekday FROM lessons WHERE id = ?", student[2]).fetchone()
    if weekday[0] != datetime.now().strftime("%A"):
        cur.execute("DELETE FROM rolls")
        con.commit()
        con.close()
        quit()

    date_last_marked = cur.execute("SELECT date_last_marked FROM lessons WHERE id = ?", student[2]).fetchone()
    print(date_last_marked)
    print(date.today().strftime("%d_%m"))
    if f"{int(date.today().strftime('%d'))}_{int(date.today().strftime('%m'))}" == date_last_marked[0]:
        marked_today = True
    else:
        marked_today = False
    return [datetime.strptime(time[0], "%H%M").strftime("%I:%M"), marked_today]


secrets = getSecrets()

con = sqlite3.connect("/home/austin/helloworld/pb_data/data.db")
cur = con.cursor()

cur.execute("SELECT * FROM rolls WHERE final = true")
x = cur.fetchall()
if len(x) == 0: #look for a student where 'final' field is true, otherwise wait until there is one
    con.close()
    print("quitting - no final found")
    quit()



allDetails = []
allRolls = cur.execute("SELECT * FROM rolls").fetchall()
for student in allRolls:
	x = getStudentDetails(student)
	allDetails.append(x)
	time = getLessonTime(student)

secrets = getSecrets() #secrets from secrets.py file

con = sqlite3.connect("/home/austin/helloworld/pb_data/data.db")
cur = con.cursor()

cur.execute("SELECT * FROM rolls WHERE final = true")
x = cur.fetchall()
if len(x) == 0:
    con.close()
    quit()
try:

    allDetails = []
    allRolls = cur.execute("SELECT * FROM rolls").fetchall()
    for student in allRolls:
        x = getStudentDetails(student)
        allDetails.append(x)

    if time[1] == True:
        already_marked = "!!  This lesson has already been marked -- This is the updated information."
    else:
        already_marked = ""

    table = tabulate(allDetails, headers=['Name', 'Homeroom', 'Status'], tablefmt='grid')

    now = datetime.now().strftime("%d-%m-%Y, %H:%M")


    sendEmail(f"""Subject: {now}\n
        {table}

        Lesson start time: {time[0]}
    {already_marked}""")

except Exception as e: 
    sendEmail(f"""Subject: Error while trying to send email \n
    {e}""")
