import numpy as np
import pandas as pd
import requests
import datetime

import requests.packages.urllib3
requests.packages.urllib3.disable_warnings()

# Import tokens
tokens = pd.read_csv('tokens.csv')
def getToken(tokenType):
	return tokens[tokens.name == tokenType].token[0]


# Uber api with different scopes
scopes = ['products', 'price', 'time']

def UberApiResponse(scope, lat, lng):
	if (scope == 'products'):
		parameters = {
		'server_token': getToken('SERVER_TOKEN'),
	    'latitude': lat,
	    'longitude': lng,
		}
		url = 'https://api.uber.com/v1/products'
	elif (scope == 'time'):
		parameters = {
		'server_token': getToken('SERVER_TOKEN'),
	    'start_latitude': lat,
	    'start_longitude': lng,
		}
		url = 'https://api.uber.com/v1/estimates/time'
	elif (scope == 'price'):
		parameters = {
		'server_token': getToken('SERVER_TOKEN'),
	    'start_latitude': lat,
	    'start_longitude': lng,
	    'end_latitude': lat,
	    'end_longitude': lng
		}
		url = 'https://api.uber.com/v1/estimates/price'
	response = requests.get(url, params=parameters)
	return response.json()

def main():
	# Setup SF lat lng grid
	sfLat = [37.734883, 37.803337]
	sfLng = [-122.507491, -122.378402]
	grid_size = 15

	latGrid = np.linspace(sfLat[0], sfLat[1], grid_size)
	lngGrid = np.linspace(sfLng[0], sfLng[1], grid_size)

	grid = np.dstack(np.meshgrid(latGrid, lngGrid)).reshape(-1, 2)

	timeDf, priceDf = pd.DataFrame(), pd.DataFrame()
	for lat, lng in grid:
		timeDfTmp = pd.DataFrame(UberApiResponse('time', lat, lng)['times'])
		timeDfTmp['lat'] = lat
		timeDfTmp['lng'] = lng
		timeDfTmp['time'] = datetime.datetime.now()
		timeDf = timeDf.append(timeDfTmp)
		
		priceDfTmp = pd.DataFrame(UberApiResponse('price', lat, lng)['prices'])
		priceDfTmp['lat'] = lat
		priceDfTmp['lng'] = lng
		priceDfTmp['time'] = datetime.datetime.now()
		priceDf = priceDf.append(priceDfTmp)
		print lat, lng
		
	timeDf.to_csv('UberWaitingTime' + str(datetime.datetime.now().date()) + '.csv', index=False)
	priceDf.to_csv('UberPrice' + str(datetime.datetime.now().date()) + '.csv', index=False)


main()
