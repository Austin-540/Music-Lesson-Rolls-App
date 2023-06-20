#!/usr/bin/python

import sqlite3
from secrets import getSecrets
import smtplib, ssl


secrets = getSecrets()

con = sqlite3.connect("/Users/austin/Programming/music_lessons_attendance/backend/examples/base/pb_data/data.db")
cur = con.cursor()

cur.execute("SELECT * FROM rolls WHERE final = true")
x = cur.fetchall()
if len(x) == 0:
    quit()

def sendEmail(contents):
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
        server.login(secrets['my_email'], secrets['my_password'])
        server.sendmail(secrets['my_email'], secrets['reciever_email'], contents)
