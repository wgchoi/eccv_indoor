#!/usr/bin/python
import sys
import lxml
from lxml import html
import urllib
import urllib2

# read page html
def get_page(url):
	request = urllib2.Request(url)
	request.add_header('User-Agent', 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)')
	response = urllib2.urlopen(request)
	html = response.read()
	response.close()
	return html

# parse and print image url
def getImgURL(html):
	# find html item
	alst = html.xpath('//img[@class="browseListImageXL"]')
	imgAddressList = []
	for aitem in alst:
		text = aitem.get('src')
		idx = text.rfind('_')
		# print the file name so we can use "wget"
		print text[0:idx+1]+'9'+text[idx+2:]

category=sys.argv[1]
i=sys.argv[2]
# open and read html
html_txt = get_page('http://www.houzz.com/photos/'+category+'/p/'+i);
# pares html text into html structure
html = lxml.html.fromstring(html_txt);
# print image file urls
getImgURL(html);
