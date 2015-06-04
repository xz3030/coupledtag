from pytagcloud import *
from pytagcloud.lang.counter import get_tag_counts

classind=1
tagFile = '../result/'+str(classind)+'_CP/tag_with_count'

fd=open(tagFile,'r')
l = fd.readlines()
fd.close()

tmplist = []
for ll in l:
    ll = ll.replace('\n','')
    if ll.startswith('Class'):
        cl = int(ll[6:7])
        print cl
        if cl!=1:
            print tmplist
            tags = make_tags(tmplist, maxsize = 80)
            create_tag_image(tags, '../result/'+str(classind)+'_CP/tagcloud_'+str(cl-1)+'.png',\
                             layout = LAYOUT_HORIZONTAL, size=(900,600), fontname='Lobster')
        tmplist = []
        
    tmp = ll.split('\t')
    
    if len(tmp)==2:
        tag = tmp[0]
        count = int(tmp[1])
        if count>10:
            tmplist.append((tag,count))
    
tags = make_tags(tmplist, maxsize = 80)
create_tag_image(tags, '../result/'+str(classind)+\
                 '_CP/tagcloud_'+str(cl)+'.png', \
                 layout = LAYOUT_HORIZONTAL, size=(900,600), fontname='Lobster')
           


