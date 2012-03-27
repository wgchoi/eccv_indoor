#!/usr/bin/python
import sys
import lxml
from lxml import html
import urllib
import urllib2

def get_page(url):
	request = urllib2.Request(url)
	request.add_header('User-Agent', 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)')
	response = urllib2.urlopen(request)
	html = response.read()
	response.close()
	return html

def getImgURL(html):
	alst = html.xpath('//img[@class="browseListImageXL"]')
	# alst = html.xpath('//img')
	imgAddressList = []
	for aitem in alst:
		text = aitem.get('src')
		idx = text.rfind('_')
		print text[0:idx+1]+'9'+text[idx+2:]

category=sys.argv[1]
for i in range(0,500):
	html_txt = get_page('http://www.houzz.com/photos/'+category+'/p/'+str(i*8+1));
	html = lxml.html.fromstring(html_txt);
	getImgURL(html);
