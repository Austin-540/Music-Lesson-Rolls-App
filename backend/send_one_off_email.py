#!/usr/bin/python
import sqlite3
from my_secrets import getSecrets
import smtplib, ssl
from tabulate import tabulate
from datetime import datetime
from datetime import date
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


def sendEmail(contents, subject):
    msg = MIMEMultipart()
    msg['From'] = secrets['my_email']
    msg['To'] = secrets['reciever_email']
    msg['Subject'] = subject
    body = f"""\
<pre>
<code>
{contents}
</code>
</pre>
    """
    msg.attach(MIMEText(body, 'html'))

    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
        server.login(secrets['my_email'], secrets['my_password'])
        server.sendmail(secrets['my_email'], secrets['reciever_email'], msg.as_string())

    # context = ssl.create_default_context()
    # with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
    #     server.login(secrets['my_email'], secrets['my_password'])
    #     server.sendmail(secrets['my_email'], secrets['reciever_email'], contents)


secrets = getSecrets()

con = sqlite3.connect("/home/austin/pb_data/data.db")
cur = con.cursor()

if len(cur.execute("SELECT * FROM one_off_rolls WHERE final = true").fetchall()) == 0:
    print("Quitting -- non final")
    quit()

data = cur.execute("SELECT * FROM one_off_rolls").fetchall()

print(data)

formatted_data = []

for i in range(len(data)):
    formatted_data.append([data[i][2], "Present"])

time = cur.execute("SELECT time FROM one_off_rolls").fetchone()

sendEmail(f"""{tabulate(formatted_data, tablefmt='grid', headers=["Name", "Status"])}

Lesson start time: {time[0]}""", str(datetime.now()))

cur.execute("DELETE FROM one_off_rolls")
con.commit()
con.close()

