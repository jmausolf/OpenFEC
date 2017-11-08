#DEFINE YOUR API KEYS
ak1 = "supersecret1"
ak2 = "supersecret2"
ak3 = "supersecret3"
ak4 = "supersecret4"
ak5 = "supersecret5"

api_keys = [ak1, ak2, ak3, ak4, ak5]

def get_api_key(api_keys):
	used = []
	for key in api_keys:
		yield key
		used.append(key)
	while used:
		for key in used:
			yield key

#CALL IN THE SCRIPT TO CYCLE KEYS
newkey = get_api_key(api_keys)
#next(newkey)



