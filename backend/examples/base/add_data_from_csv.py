import csv
from pocketbase import PocketBase
from secrets import getSecrets

admin_password = getSecrets()['admin_password']

client = PocketBase('https://app.shcmusiclessonrolls.com')

admin_data = client.admins.auth_with_password("admin@example.com", admin_password) # This script requires admin privelliges on PB to run 

