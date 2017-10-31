#Write Expected Company Name ID's
"""
## 	Possible company names available in development mode
	of `cleanFEC.py`, e.g.:

	filter_company_ids("Apple", True)

	where True places the code in development mode
"""


#Dictionary of Company Aliases
company_name_ids = {
	"Goldman Sachs" : ['goldman sachs', 'goldman sachs investment', 'goldman sachs bank', 'goldman sachs asset management', 'goldman sachs capital'],
	"Apple" : ['apple', 'apple computer', 'apple computers', 'apple store', 'apple retail store', 'appleinc', 'apple incgeneral counsel', 'apple incchief patent counsel', 'apple incsoftware engineer', 'apple incengineer', 'apple incmarketing manager', 'apple incprogrammer', 'apple inccomputer programmer', 'apple incstudent', 'apple incgovernmt affairs', 'apple inccurrent ual previous', 'apple incorp', 'apple computersoftware engineer', 'apple computerdirector', 'apple computersupply chain', 'apple computergovernment affairs', 'apple computer incsoftware engin', 'apple computer incsrmarketing m', 'apple computerssoftware engineer', 'apple computer incattorney', 'apple computersenior director offi', 'apple computerceo', 'apple computertreasurer', 'apple computermanager government a', 'apple computer incsoftware engine', 'apple computer incregional manage', 'apple computerattorney', 'apple computerpixar animation stud'], #yields about 40 more observations than Apple1 (simple)
	"Apple1" : ['apple', 'apple computer', 'apple computers', 'apple store', 'apple retail store', 'appleinc'],
	#TODO Add more companies
	"Exxon Mobile" : ['exxon mobile', 'exxon mobile corpattorney', 'exxon mobile chemical', 'exxon mobile gas station', 'exxonmobile', 'exxon mobile production', 'exxon mobileaccountant', 'exxon mobile execoration', 'exxon mobile ref supply', 'exxon mobileattorney', 'exxon mobile financial', 'exxon mobileexecutive', 'exxon mobilemanager', 'exxonn mobile']
}