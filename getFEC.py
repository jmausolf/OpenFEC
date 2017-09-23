from credentials import *
import requests
import json


#REQUEST URL
#example
url = "https://api.data.gov/nrel/alt-fuel-stations/v1/nearest.json?api_key={}&location=Denver+CO".format(api_key)

response = requests.get(url)
data = response.json()
print(data)
