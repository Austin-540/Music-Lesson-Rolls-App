#!/usr/bin/python

import sqlite3

con = sqlite3.connect("./pb_data/data.db")
cur = con.cursor()

cur.execute("SELECT * FROM rolls WHERE final = true")
x = cur.fetchall
if x.length == 0:
    quit()

