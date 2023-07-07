#!/usr/bin/python

import sqlite3
from secrets import getSecrets
import smtplib, ssl
from tabulate import tabulate
from datetime import datetime

def sendEmail(contents):
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
        server.login(secrets['my_email'], secrets['my_password'])
        server.sendmail(secrets['my_email'], secrets['reciever_email'], contents)

    #cur.execute("DELETE FROM rolls")
    con.commit()
    con.close()

def getStudentDetails(student):
    studentDBDetails = cur.execute(f"SELECT name, homeroom FROM students WHERE id = '{student[4]}'").fetchone()
    return [studentDBDetails[0], studentDBDetails[1], student[3]]


secrets = getSecrets()

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


    table = tabulate(allDetails, headers=['Name', 'Homeroom', 'Status'], tablefmt='grid')

    now = datetime.now().strftime("%d-%m-%Y, %H:%M")

    sendEmail(f"""Subject: {now}\n
    {table}""")
except Exception as e: 
    sendEmail(f"""Subject: Error while trying to send email \n
    {e}""")