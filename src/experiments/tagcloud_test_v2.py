from pytagcloud import *
from pytagcloud.lang.counter import get_tag_counts

classind=8
tagFile = '../result/'+str(classind)+'_CP/tag_freq.txt'

fd=open(tagFile,'r')
l = fd.readlines()
fd.close()

tmplist = []
for ll in l[2:51]:
    ll = ll.replace('\n','')
        
    tmp = ll.split('\t')
    
    if len(tmp)==2:
        tag = tmp[0]
        count = float(tmp[1])
        tmplist.append((tag,count))
        
    
tags = make_tags(tmplist, maxsize = 50)
create_tag_image(tags, '../result/'+str(classind)+\
                 '_CP/tagcloud.png', \
                 layout = LAYOUT_VERTICAL, size=(600,900), fontname='Lobster')
           


