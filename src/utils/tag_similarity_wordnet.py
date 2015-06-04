import nltk
import numpy as np
import sys

from nltk.corpus import wordnet as wn


def main( maindir ):
    fd = open(maindir+'tags.txt','r')
    l = fd.readlines()
    fd.close()
    
    syns = []
    valid_ind = []
    for i in range(len(l)):
        t = l[i].strip('\n')
        tmp = wn.synsets(t)
        if len(tmp)==0:
            continue
        valid_ind.append(i+1)
        syns.append(tmp[0])
    
    print len(syns)
    print len(valid_ind)
    print len(l)
    
    N = len(syns)
    
    sims = np.array([0.0 for i in range(N*N)])
    sims.shape = N,N
    for i in range(len(syns)):
        sims[i,i]=1
    
    for i in range(len(syns)):
        if i%100==0:
            print i, '/', len(syns)
        for j in range(i+1, len(syns)):
            x = wn.wup_similarity(syns[i], syns[j])
            if x is None:
                continue
            else:
                sims[i,j] = x
                sims[j,i] = x
            #print l[valid_ind[i]].strip('\n'), l[valid_ind[j]].strip('\n'), x
    
    print sims
    
    np.savetxt(maindir+'wordnet_sim.txt', sims, fmt='%.4f')
    
    
    valid_ind.append(len(l))
    vi = [str(x) for x in valid_ind]
    fd = open(maindir+'wordnet.txt','wt')
    fd.write(' '.join(vi))
    fd.close()

#maindir = '/home/zhenxu/workspace/Flickr/data/coupled_sim_/94326334@N00/Run6/'
maindir = sys.argv[1]
main(maindir)
